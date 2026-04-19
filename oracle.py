import os
import sys
import json
import subprocess
import requests
import re
from flask import Flask, jsonify, send_from_directory, request

import time

app = Flask(__name__)

PORT = 5050
DASHBOARD_PATH = os.path.dirname(os.path.abspath(__file__))
IG_BASE_URL = "https://www.instant-gaming.com/en/search/"
CACHE_FILE = "games_cache.json"
CACHE_EXPIRY = 86400  # 24 hours
ANTI_CHEAT_URL = "https://raw.githubusercontent.com/AreWeAntiCheatYet/AreWeAntiCheatYet/master/games.json"
STEAM_SEARCH_URL = "https://store.steampowered.com/api/storesearch/?l=french&cc=FR&term="

def get_anti_cheat_data():
    now = time.time()
    if os.path.exists(CACHE_FILE):
        if now - os.path.getmtime(CACHE_FILE) < CACHE_EXPIRY:
            try:
                with open(CACHE_FILE, 'r') as f:
                    return json.load(f)
            except: pass
    
    try:
        response = requests.get(ANTI_CHEAT_URL)
        data = response.json()
        with open(CACHE_FILE, 'w') as f:
            json.dump(data, f)
        return data
    except Exception as e:
        print(f"🔱 [ORACLE] Error fetching Anti-Cheat data: {e}")
        return []

def search_steam_store(query):
    try:
        url = f"{STEAM_SEARCH_URL}{requests.utils.quote(query)}"
        res = requests.get(url, timeout=5)
        if res.ok:
            return res.json().get('items', [])
    except: pass
    return []

def get_protondb_summary(appid):
    try:
        url = f"https://www.protondb.com/api/v1/reports/summaries/{appid}.json"
        res = requests.get(url, timeout=5)
        if res.ok:
            return res.json()
    except: pass
    return None

@app.route('/api/shiva/compatibility')
def check_compatibility():
    query = request.args.get('q', '').lower()
    data = get_anti_cheat_data()
    
    if not query:
        # Top popular games as default
        top_games = ["Call of Duty", "Apex Legends", "Counter-Strike", "Valorant", "Elden Ring", "Fortnite", "Destiny 2", "Rust", "Rainbow Six Siege", "Overwatch 2"]
        results = [g for g in data if any(tg.lower() in g.get('name', '').lower() for tg in top_games)]
        return jsonify(results[:12])

    results = []
    # 1. Search Anti-Cheat DB
    ac_matches = [g for g in data if query in g.get('name', '').lower()]
    
    # 2. Search Steam Store (Enrichment)
    steam_items = search_steam_store(query)
    
    # Merge AC results with Steam data
    for game in ac_matches[:8]:
        game_name = game.get('name', '').lower()
        # Find match in Steam search
        steam_match = next((s for s in steam_items if query in s['name'].lower()), None)
        if steam_match:
            summary = get_protondb_summary(steam_match['id'])
            if summary:
                game['protondb'] = summary.get('tier')
                game['appid'] = steam_match['id']
        results.append(game)

    # 3. Fallback: If no AC matches, show Steam results
    if not results:
        for sm in steam_items[:5]:
            summary = get_protondb_summary(sm['id'])
            results.append({
                "name": sm['name'],
                "status": "Inconnu (Pas d'Anti-Cheat bloquant détecté)",
                "anticheats": [],
                "protondb": summary.get('tier') if summary else "pending",
                "appid": sm['id'],
                "reference": f"https://www.protondb.com/app/{sm['id']}"
            })

    return jsonify(results)

# 🔱 LOGIQUE DE RECONNAISSANCE (SCRAPER)
def fetch_gaming_data(mode='preorder', query=None):
    try:
        IGR_TAG = "?igr=shivaos"
        if query:
            url = f"https://www.instant-gaming.com/en/search/?q={requests.utils.quote(query)}&platform%5B%5D=1&hitsPerPage=100"
        elif mode == 'store':
            url = f"https://www.instant-gaming.com/fr/pc/tendances/{IGR_TAG}"
        else:
            # PREORDER mode
            url = f"https://www.instant-gaming.com/en/search/?platform%5B%5D=1&product_types%5B%5D=preorder&hitsPerPage=100&igr=shivaos"

        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Referer': 'https://www.google.com/'
        }
        
        response = requests.get(url, headers=headers, timeout=10)
        if not response.ok: return []

        html = response.text
        # Extraction du noyau JSON
        match = re.search(r'window\.searchResults\s*=\s*(\{.*?\});', html, re.DOTALL)
        if not match: return []

        data = json.loads(match.group(1))
        hits = data.get('hits', [])
        
        results = []
        for hit in hits:
            prod_id = hit.get('prod_id') or hit.get('objectID')
            if not prod_id: continue
            
            results.append({
                "id": prod_id,
                "name": hit.get('fullname') or hit.get('name', 'Unknown Artifact'),
                "price": hit.get('price_formatted', 'TBD').replace('&nbsp;', ' '),
                "image": f"https://gaming-cdn.com/images/products/{prod_id}/orig/{prod_id}.jpg",
                "status": "PRE-ORDER" if hit.get('preorder') == 1 else "AVAILABLE",
                "category": hit.get('main_tag', 'PC Game'),
                "url": f"https://www.instant-gaming.com/en/{prod_id}-/{IGR_TAG}"
            })
            
        return results
    except Exception as e:
        print(f"🚨 [ORACLE] Scraping error: {e}")
        return []

@app.route('/api/shiva/pulse')
def pulse():
    mode = request.args.get('mode', 'preorder')
    query = request.args.get('q')
    
    # 🔱 Fusion avec les apps locales si on est en mode Library
    if mode == 'library':
        return jsonify([
            {"id": "steam", "name": "STEAM OS", "price": "INSTALLED", "image": "assets/steam.png", "status": "ACTIVE", "category": "Gaming", "cmd": "steam"},
            {"id": "discord", "name": "NEURAL COMMS", "price": "INSTALLED", "image": "assets/discord.png", "status": "ACTIVE", "category": "Social", "cmd": "discord"}
        ])

    data = fetch_gaming_data(mode, query)
    return jsonify(data)

@app.route('/api/launch', methods=['POST'])
def launch_app():
    try:
        data = request.json
        cmd = data.get('cmd')
        if not cmd: return jsonify({"error": "No cmd"}), 400
        subprocess.Popen(cmd.split(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve(path):
    if path != "" and os.path.exists(os.path.join(DASHBOARD_PATH, path)):
        return send_from_directory(DASHBOARD_PATH, path)
    else:
        return send_from_directory(DASHBOARD_PATH, 'index.html')

if __name__ == '__main__':
    print(f"🔱 [SHIVA ORACLE PULSE v2] ACTIVATED ON PORT {PORT}")
    app.run(host='0.0.0.0', port=PORT, debug=False)
