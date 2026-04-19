#!/bin/bash

# 🔱 SHIVA OS - UI SYNCHRONIZER (Liquid Glass)
# Ce script applique l'identité visuelle Shiva OS sur KDE Plasma.

ORANGE='\033[0;33m'
NC='\033[0m'

echo -e "${ORANGE}🔱 SYNCHRONISATION DE L'INTERFACE SHIVA OS...${NC}"

# 1. Application du Wallpaper Officiel
WALLPAPER_PATH="/usr/share/wallpapers/ShivaOS/contents/images/1920x1080.jpg"
if [ -f "$WALLPAPER_PATH" ]; then
    echo "🖼️ Application du fond d'écran Liquid Glass..."
    plasma-apply-wallpaperimage "$WALLPAPER_PATH"
else
    echo "⚠️ Wallpaper ShivaOS introuvable."
fi

# 2. Application du Thème Global (Onyx & Orange)
# Note: On suppose que le look-and-feel est installé sous le nom 'org.shivaos.liquidglass'
echo "🎨 Application du thème Global Shiva OS..."
plasma-apply-lookandfeel org.kde.breezedark.desktop # Fallback vers Breeze Dark
# Ici on pourra ajouter les commandes kreadconfig5 pour forcer la couleur d'accent Orange

# 3. Réglage de la barre des tâches (Icon-only task manager)
echo "💎 Optimisation du Panel..."
# Logicielle spécifique à KDE via scripting plasma-desktop si nécessaire

echo -e "${ORANGE}🔱 INTERFACE SYNCHRONISÉE. RELANCEZ PLASMA POUR APPLIQUER TOUS LES RÉGLAGES.${NC}"
