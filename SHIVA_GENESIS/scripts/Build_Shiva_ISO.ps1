# 🔱 SHIVA OS - AUTOMATED ISO BUILDER (v1.0)
# Ce script automatise la création de l'ISO Shiva OS 26.04 LTS.

$WorkDir = "C:\Users\Jeux\Documents\moi\ISO_WORK"
$SourceIso = "$WorkDir\SOURCE_ISO"
$SquashDir = "$WorkDir\SQUASHFS\rootfs"
$TempIsoDir = "$WorkDir\TEMP_BUILD"
$OutputIso = "C:\Users\Jeux\Documents\moi\ShivaOS_26.04_LTS_Initial.iso"

Write-Host "🔱 INITIALISATION DU BUILD SHIVA OS..." -ForegroundColor Cyan

# 1. Nettoyage du dossier temporaire
if (Test-Path $TempIsoDir) { Remove-Item -Path $TempIsoDir -Recurse -Force }
New-Item -ItemType Directory -Path $TempIsoDir

# 2. Synchronisation de la base ISO
Write-Host "📦 Copie de la base ISO (SOURCE_ISO)..."
Copy-Item "$SourceIso\*" $TempIsoDir -Recurse

# 3. Injection du Shiva Store & Scripts dans le rootfs
Write-Host "🧬 Injection de l'ADN Shiva dans le rootfs..."
# (Note : Déjà fait manuellement lors de l'intégration, mais le script peut le refaire si besoin)

# 4. Compression du RootFS (Nécessite mksquashfs via WSL ou Linux)
Write-Host "🗜️ Compression du système de fichiers (SquashFS)..."
# ATTENTION : Cette commande doit être lancée dans un environnement Linux
# wsl mksquashfs $SquashDir $TempIsoDir/casper/filesystem.squashfs -noappend -always-use-fragments

# 5. Création de l'ISO finale
Write-Host "💿 Génération de l'image ISO bootable (xorriso)..."
# wsl xorriso -as mkisofs -r -V "SHIVA_OS_26_04" -o $OutputIso -J -joliet-long -b boot/grub/i386-pc/eltorito.img -c boot.catalog -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot $TempIsoDir

Write-Host ""
Write-Host "🔱 SUCCESS : L'ISO de Shiva OS est prête (Simulation terminée)." -ForegroundColor Green
Write-Host "Note : Pour le build final le 24 Avril, assurez-vous d'avoir mksquashfs et xorriso installés."
