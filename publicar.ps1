# Publica la carpeta "publico" de la bóveda de Obsidian en la wiki.
# Normalmente se ejecuta con PUBLICAR-WIKI.bat, desde la carpeta de la bóveda.
# Uso manual:
#   powershell -ExecutionPolicy Bypass -File publicar.ps1 -Boveda "C:\ruta\a\la\boveda"

param(
    [string]$Boveda = (Join-Path $env:USERPROFILE "Documents\Valeion\Vaelion")
)

$boveda = Join-Path (Resolve-Path $Boveda) "publico"
$wiki   = $PSScriptRoot

# Seguridad: si la carpeta publico no existe o no tiene portada, no se toca nada.
# (robocopy /MIR deja content idéntica a publico: una carpeta vacía borraría la wiki.)
if (-not (Test-Path (Join-Path $boveda "index.md"))) {
    Write-Host "No encuentro $boveda\index.md. Nada publicado." -ForegroundColor Red
    exit 1
}

robocopy $boveda (Join-Path $wiki "content") /MIR /XD .obsidian /NFL /NDL /NJH /NJS
if ($LASTEXITCODE -ge 8) {
    Write-Host "Error al copiar los archivos (robocopy $LASTEXITCODE)." -ForegroundColor Red
    exit 1
}

Set-Location $wiki
git add content
git commit -m "Actualizar wiki $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git pull --rebase
git push

Write-Host "Listo. GitHub reconstruye el sitio en 1-2 minutos:" -ForegroundColor Green
Write-Host "https://jpcavada.github.io/campana-dnd-2026/"
