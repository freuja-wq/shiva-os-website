#!/bin/bash

# 🔱 SHIVA OS - SYSTEM DIAGNOSTIC REPORT (v1.0)
# Utilisez ce script pour générer un rapport à partager sur Discord.

CYAN='\033[0;36m'
ORANGE='\033[0;33m'
NC='\033[0m'

echo -e "${ORANGE}🔱 GÉNÉRATION DU RAPPORT SYSTÈME SHIVA OS...${NC}"
echo -e "---------------------------------------------------"

# 1. Infos OS
echo -e "${CYAN}[SYSTEME]${NC}"
lsb_release -d | cut -f2
echo -n "Kernel: " && uname -sr
echo -n "Uptime: " && uptime -p

# 2. Infos GPU & Drivers
echo -e "\n${CYAN}[GRAPHISMES]${NC}"
if lspci | grep -i nvidia > /dev/null; then
    echo "GPU: NVIDIA Detected"
    nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null || echo "Driver: NVIDIA Not Loaded"
else
    echo "GPU: Non-NVIDIA / Mesa"
    glxinfo | grep "OpenGL renderer string" | cut -d: -f2
fi
echo -n "Mesa: " && glxinfo | grep "Mesa" | head -1 | awk '{print $3}' || echo "N/A"

# 3. CPU & RAM
echo -e "\n${CYAN}[MATÉRIEL]${NC}"
grep -m 1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//'
free -h | grep "Mem:" | awk '{print "RAM total: " $2 " / Utilisé: " $3}'

# 4. Shiva Ecosystem Status
echo -e "\n${CYAN}[SHIVA STATUS]${NC}"
systemctl is-active shiva-store.service > /dev/null && echo "✅ Shiva Store: ONLINE" || echo "❌ Shiva Store: OFFLINE"

echo -e "---------------------------------------------------"
echo -e "${ORANGE}🔱 COPIEZ CE BLOC POUR DEMANDER DE L'AIDE SUR DISCORD !${NC}"
