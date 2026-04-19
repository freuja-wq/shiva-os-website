# 🔱 SHIVA OS GENESIS FORGE - Ver v1.2
# "Forger le futur du Gaming sous Linux"
# Engine: Linux Kernel 7.0+ (EEVDF Scheduler) & Zen Tuning

set -e

# --- AUTO-UPDATE (VÉRIFICATION DÉPÔT) ---
REMOTE_VERSION_URL="https://shivaos.com/genesis/scripts/Shiva_Forge.sh"
echo "🔍 Vérification des mises à jour sur le dépôt Shiva OS..."
# Ici on pourrait comparer les versions, mais pour la simplicité du lancement :
# Le script peut se retélécharger s'il est lancé avec un flag --update
if [[ "$1" == "--update" ]]; then
    echo "📡 Téléchargement de la dernière version depuis le serveur..."
    curl -s -O $REMOTE_VERSION_URL
    echo "✅ Forge mise à jour. Relancez le script."
    exit 0
fi

# --- COULEURS ---
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${ORANGE}🔱 INITIALISATION DE LA FORGE SHIVA OS...${NC}"

# --- ÉTAPE 1 : DÉPÔTS SYSTEME ---
echo -e "${CYAN}📦 Étape 1 : Préparation des Forges (PPAs)...${NC}"
sudo add-apt-repository -y ppa:dbermond/mesa-git      # Mesa Git (Derniers drivers)
sudo add-apt-repository -y ppa:dylanvanassche/liquorix # Noyau Liquorix
sudo add-apt-repository -y ppa:lutris-team/lutris      # Lutris Official
sudo apt update

# --- ÉTAPE 2 : LE CONTRÔLEUR DE VOL (DRIVERS) ---
echo -e "${CYAN}🏎️  Étape 2 : Détection et installation des drivers NVIDIA...${NC}"
if lspci | grep -i nvidia > /dev/null; then
    echo "🟢 GPU NVIDIA détecté. Forage des drivers propriétaires (Version Stable)..."
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt update
    sudo apt install -y nvidia-driver-535 nvidia-settings # Version LTS Stable conseillée
else
    echo "🔵 Pas de GPU NVIDIA détecté ou Drivers Mesa déjà actifs."
fi

# --- ÉTAPE 3 : LE NOYAU (LE CŒUR) ---
echo -e "${CYAN}⚙️  Étape 3 : Greffe du Noyau Liquorix (Kernel 7.x Gaming Optimized)...${NC}"
sudo apt install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64

# --- ÉTAPE 4 : LE KIT DE COMBAT (APPS GAMING) ---
echo -e "${CYAN}🎮 Étape 4 : Forge de l'Armurerie Gaming...${NC}"
sudo apt install -y steam lutris heroic-launcher bottles mangohud gamemode \
                     vlc obs-studio discord-canary ufw git curl python3-pip

# --- ÉTAPE 5 : LES OPTIONNELS (DEPÔT) ---
# echo -e "${CYAN}💼 Étape 5 : Installation de la suite utilitaire (Optionnel)...${NC}"
# sudo apt install -y libreoffice libreoffice-l10n-fr gimp inkscape transmission \
#                      btop tree htop fastfetch wireguard-tools

# --- ÉTAPE 6 : OPTIMISATION GPU ---
echo -e "${CYAN}⚡ Étape 6 : Injection Vulkan & Mesa Haute Performance...${NC}"
sudo apt upgrade -y   # Appliquer les drivers Mesa Git
sudo apt install -y mesa-vulkan-drivers libvulkan1 vulkan-tools

# --- ÉTAPE 7 : CONFIGURATION SHIVA (TUNING) ---
echo -e "${CYAN}🔧 Étape 7 : Calibration du système...${NC}"

# 1. Optimisation des limites pour le gaming (Esync/Fsync)
echo "👑 Réglage des limites système..."
cat <<EOF | sudo tee /etc/security/limits.d/shiva-gaming.conf
* hard nofile 1048576
* soft nofile 1048576
EOF

# 2. Configuration MangoHUD (Style Shiva Orange)
echo "🔱 Forge de l'Overlay MangoHUD..."
mkdir -p ~/.config/MangoHud
cat <<EOF > ~/.config/MangoHud/MangoHud.conf
fps_limit=0
vsync=0
gl_vsync=0
legacy_layout=0
horizontal
hud_no_margin
font_size=16
background_alpha=0.4
text_color=FF8C00
gpu_text=GPU
cpu_text=CPU
vram
ram
fps
frame_timing
EOF

# --- ÉTAPE 8 : ACTIVATION DES SERVICES ---
echo -e "${CYAN}🚀 Étape 8 : Activation des réacteurs...${NC}"
sudo systemctl enable --now shiva-store.service || echo "⚠️ Service Store pas encore installé sur cette machine"
sudo ufw allow 5050/tcp # Port de l'Oracle Shiva
sudo ufw enable

echo -e ""
echo -e "${ORANGE}🔱 FORGE TERMINÉE ! REDÉMARREZ POUR ACTIVER LE NOYAU L'OS.${NC}"
echo -e "SHIVA OS 26.04 LTS — Pure Gaming Ecosystem."
