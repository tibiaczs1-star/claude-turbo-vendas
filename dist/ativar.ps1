# ==============================================================================
# ATIVADOR 1-CLIQUE Claudio Turbo (CATALOGO CRUZEIRO DO SUL & JUNIOR PLAY)
# ==============================================================================
$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   Claudio Turbo - INSTALADOR DE 1-CLIQUE (CZS LABS)" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$licenseFile = Join-Path $env:USERPROFILE ".claudio-license.txt"
$license = ""

if (Test-Path $licenseFile) {
    $license = (Get-Content $licenseFile -Raw).Trim()
}

if (-not $license) {
    Write-Host "[!] Digite ou cole a Chave de Licenca que voce recebeu no WhatsApp:" -ForegroundColor Yellow
    $license = Read-Host "Chave de Licenca"
    if (-not $license) {
        Write-Host "[!] Chave nao informada. Ativacao cancelada." -ForegroundColor Red
        return
    }
    $license = $license.Trim()
    $license | Set-Content $licenseFile -Encoding utf8
}

Write-Host "[+] Licenca vinculada: $license" -ForegroundColor Green

# 1. Desconecta sessao antiga da Anthropic
cmd /c "claude logout 2>nul"

# 2. Configura variaveis de ambiente de usuario
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', 'http://127.0.0.1:20129', 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_API_KEY', $license, 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_MODEL', 'claude-fable-5.1-free', 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_SMALL_FAST_MODEL', 'claude-fable-5-free', 'User')

# 3. Baixa o aplicativo executavel nativo Claudio.exe para a Area de Trabalho
$desktop = [System.Environment]::GetFolderPath('Desktop')
$desktopExe = Join-Path $desktop "🎮 Claudio.exe"

Write-Host "[*] Baixando aplicativo oficial Claudio.exe..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tibiaczs1-star/claude-turbo-vendas/main/dist/Claudio.exe" -OutFile $desktopExe -UseBasicParsing
    Write-Host "[✓] Aplicativo Claudio.exe instalado na sua Area de Trabalho!" -ForegroundColor Green
} catch {
    Write-Host "[!] Nao foi possivel baixar o .exe diretamente, instalando iniciador rapido..." -ForegroundColor Yellow
}

# 4. Baixa tambem o iniciador bat de contingencia em C:\claude
$destDir = "C:\claude"
if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
$batPath = Join-Path $destDir "iniciar-claude-turbo.bat"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tibiaczs1-star/claude-turbo-vendas/main/dist/iniciar-claude-turbo.bat" -OutFile $batPath -UseBasicParsing

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   SUCESSO! Claudio Turbo configurado e liberado!" -ForegroundColor Green
Write-Host "   Icone '🎮 Claudio.exe' pronto na sua Area de Trabalho!" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Inicia o Claudio imediatamente
if (Test-Path $desktopExe) {
    & "$desktopExe"
} else {
    & "$batPath"
}
