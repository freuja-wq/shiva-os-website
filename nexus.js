/**
 * SHIVA OS - NEXUS LOGIC ENGINE v5.0 🔱
 * Handles SPA navigation, Store automation, and Light/Dark themes.
 */

let currentMode = 'store';

document.addEventListener('DOMContentLoaded', () => {
    console.log("🔱 [SHIVA OS] NEXUS ENGINE v5.1 ACTIVATED");
    initTheme();
    loadLibrary('store');
    initSearch();
    initShield();
    checkHardware();
});

/**
 * FAQ / SANCTUM ENGINE
 */
function toggleFaq(el) {
    const item = el.parentElement;
    const isOpen = item.classList.contains('open');
    document.querySelectorAll('.faq-item').forEach(i => i.classList.remove('open'));
    if (!isOpen) item.classList.add('open');
}

/**
 * NEXUS SHIELD - COMPATIBILITY ENGINE
 */
function initShield() {
    const shieldSearch = document.getElementById('shield-search');
    if (!shieldSearch) return;
    
    // Initial fetch for popular games
    fetchCompatibility();

    let shieldTimer;
    shieldSearch.addEventListener('input', (e) => {
        clearTimeout(shieldTimer);
        shieldTimer = setTimeout(() => {
            fetchCompatibility(e.target.value);
        }, 300);
    });
}

async function fetchCompatibility(query = "") {
    const shieldGrid = document.getElementById('shield-results');
    if (!shieldGrid) return;

    try {
        const url = `/api/shiva/compatibility?q=${encodeURIComponent(query)}`;
        const response = await fetch(url);
        const games = await response.json();

        shieldGrid.innerHTML = "";
        
        games.forEach(game => {
            const statusClass = game.status.toLowerCase().includes('running') || game.status.toLowerCase().includes('supported') ? 'status-verified' : 
                               game.status.toLowerCase().includes('broken') || game.status.toLowerCase().includes('denied') || game.status.toLowerCase().includes('incompat') ? 'status-unsupported' : 'status-playable';
            const statusLabel = game.status.toUpperCase();
            
            // ProtonDB Badge Logic
            let protonBadge = "";
            if (game.protondb && game.protondb !== "pending") {
                const tier = game.protondb.toLowerCase();
                protonBadge = `<span class="proton-tier tier-${tier}">${game.protondb}</span>`;
            }

            const card = document.createElement('div');
            card.className = "shield-card";
            card.innerHTML = `
                <div class="status-badge ${statusClass}">${statusLabel}</div>
                <h4 style="font-size: 1rem; margin-bottom: 5px;">${game.name}${protonBadge}</h4>
                <p style="font-size: 0.75rem; opacity: 0.5;">
                    ${game.anticheats && game.anticheats.length > 0 ? `Anti-Cheat: ${game.anticheats.join(', ')}` : 'Aucun Anti-Cheat bloquant détecté'}
                </p>
                <div style="margin-top: 15px; font-size: 11px; color: var(--shiva-orange); cursor: pointer;" onclick="window.open('${game.reference || 'https://www.protondb.com/app/' + game.appid}', '_blank')">VOIR LES DÉTAILS →</div>
            `;
            shieldGrid.appendChild(card);
        });
    } catch (error) {
        console.error("🔱 [SHIELD] Signal lost:", error);
    }
}

/**
 * HARDWARE ALLIANCE - DETECTION ENGINE
 */
async function checkHardware() {
    const hwDisplay = document.getElementById('hardware-alliance-status');
    if (!hwDisplay) return;

    try {
        const ua = navigator.userAgent;
        let gpu = "AMD RDNA / NVIDIA Ready";
        let cpu = "Generic x86_64";

        if (ua.includes("Intel")) cpu = "Intel Core Detected";
        if (ua.includes("AMD")) cpu = "AMD Ryzen Detected";

        hwDisplay.innerHTML = `
            <div class="hardware-pill">🛠️ ${cpu}</div>
            <div class="hardware-pill">🎮 ${gpu}</div>
            <div class="hardware-pill">🔱 Shiva Kernel 7.0 Compatible</div>
        `;
    } catch (e) {}
}

/**
 * THEME ENGINE (Dark/Light)
 */
function initTheme() {
    const toggle = document.getElementById('theme-toggle');
    const root = document.documentElement;
    const savedTheme = localStorage.getItem('shiva-theme') || 'dark';
    
    if (savedTheme === 'light') {
        root.classList.add('light-mode');
    }

    if (toggle) {
        toggle.innerText = savedTheme === 'light' ? "🌙" : "🌓";
        toggle.addEventListener('click', () => {
            const isLight = root.classList.toggle('light-mode');
            localStorage.setItem('shiva-theme', isLight ? 'light' : 'dark');
            toggle.innerText = isLight ? "🌙" : "🌓";
        });
    }
}

/**
 * SPA SECTION SWITCHING
 */
function switchSection(sectionId) {
    console.log(`🔱 [SHIVA OS] NAVIGATING TO: ${sectionId}`);
    
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('onclick').includes(sectionId)) {
            link.classList.add('active');
        }
    });

    const sections = document.querySelectorAll('section');
    sections.forEach(section => section.classList.remove('active'));
    
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    if (sectionId === 'store') {
        loadLibrary(currentMode);
    }
}

/**
 * STORE ENGINE - TENDANCES MODE
 */
async function loadLibrary(mode, query = "") {
    currentMode = mode;
    const grid = document.getElementById('library-grid');
    if (!grid) return;

    grid.innerHTML = "<p style='opacity:0.4; padding:40px;'>Chargement des jeux...</p>";

    try {
        const url = query
            ? `/api/shiva/pulse?q=${encodeURIComponent(query)}`
            : `/api/shiva/pulse?mode=${mode}`;
        const response = await fetch(url);
        const games = await response.json();

        grid.innerHTML = "";

        if (!games || games.length === 0) {
            grid.innerHTML = "<p style='opacity:0.4; padding:40px'>Aucun jeu trouvé.</p>";
            return;
        }

        games.forEach(game => {
            const card = document.createElement('div');
            card.className = "glass-card";
            card.innerHTML = `
                <div class="card-image-container" style="height: 200px; border-radius: 20px; overflow: hidden; margin-bottom: 20px; background: rgba(0,0,0,0.3);">
                    <img src="${game.image}" style="width: 100%; height: 100%; object-fit: cover; display: block;" alt="${game.name}" onerror="this.parentElement.innerHTML='<div style=height:100%;display:flex;align-items:center;justify-content:center;font-size:40px>🎮</div>'">
                </div>
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div class="badge">${game.category}</div>
                    <div style="font-family: var(--font-mono); font-weight: 900; color: var(--shiva-orange); font-size: 1rem;">${game.price}</div>
                </div>
                <h3 style="margin-top: 15px; text-transform: uppercase; font-size: 1rem; line-height: 1.3;">${game.name}</h3>
                <p style="font-size: 0.8rem; opacity: 0.4; margin-top: 5px;">${game.status}</p>
                <div style="margin-top:25px"><button class="btn-primary" style="padding:10px 20px;font-size:9px" onclick="window.open('${game.url}','_blank')">ACHETER</button></div>
            `;
            grid.appendChild(card);
        });
    } catch (error) {
        console.error("🔱 [SHIVA OS] Oracle signal failure:", error);
        grid.innerHTML = "<p style='opacity:0.4; padding:40px;'>Erreur de connexion Oracle.</p>";
    }
}

/**
 * SEARCH ENGINE
 */
function initSearch() {
    const searchInput = document.getElementById('store-search');
    if (!searchInput) return;
    let debounceTimer;
    searchInput.addEventListener('input', (e) => {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
            loadLibrary(currentMode, e.target.value);
        }, 500);
    });
}

/**
 * COPY BUTTON UTIL
 */
document.addEventListener('click', (e) => {
    if (e.target.classList.contains('copy-btn')) {
        const command = e.target.previousElementSibling.innerText;
        navigator.clipboard.writeText(command).then(() => {
            const original = e.target.innerText;
            e.target.innerText = "COPIED!";
            e.target.style.background = "#fff";
            setTimeout(() => {
                e.target.innerText = original;
                e.target.style.background = "var(--shiva-orange)";
            }, 2000);
        });
    }
});
