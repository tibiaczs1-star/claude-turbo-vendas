# ==============================================================================
# ATIVADOR 1-CLIQUE Claudio Turbo (CATALOGO CRUZEIRO DO SUL & JUNIOR PLAY)
# ==============================================================================
$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   Claudio Turbo - INSTALADOR DE 1-CLIQUE (CZS LABS)" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$licenseFile = Join-Path $env:USERPROFILE ".claude-turbo-license.txt"
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

# 3. Baixa o iniciador oficial
$destDir = "C:\claude"
if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
$batPath = Join-Path $destDir "iniciar-claude-turbo.bat"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tibiaczs1-star/claude-turbo-vendas/main/dist/iniciar-claude-turbo.bat" -OutFile $batPath -UseBasicParsing

# 4. Cria atalho na Area de Trabalho
$desktop = [System.Environment]::GetFolderPath('Desktop')
$desktopBat = Join-Path $desktop "?? Iniciar Claudio Turbo.bat"

@"
@echo off
call "$batPath" %*
"@ | Set-Content -Path $desktopBat -Encoding ASCII

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   SUCESSO! Claudio Turbo configurado e liberado!" -ForegroundColor Green
Write-Host "   Atalho criado na sua Area de Trabalho!" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Inicia o Claude
& "$batPath"
