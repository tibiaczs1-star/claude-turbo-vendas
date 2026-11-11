@echo off
setlocal enabledelayedexpansion
title Claude Turbo Client v2.2.0 (Auto-Update Ativo)

set "LOCAL_VERSION=2.2.0"
set "UPDATE_URL=https://raw.githubusercontent.com/tibiaczs1-star/claude-turbo-vendas/main/version.json"
set "SCRIPT_URL=https://raw.githubusercontent.com/tibiaczs1-star/claude-turbo-vendas/main/dist/iniciar-claude-turbo.bat"
set "LICENSE_FILE=%USERPROFILE%\.claude-turbo-license.txt"

echo ========================================================
echo    CLAUDE TURBO - CLIENTE BLINDADO (v%LOCAL_VERSION%)
echo    Catalogo Cruzeiro do Sul & Junior Play
echo ========================================================
echo.

:: 1. VERIFICACAO DE AUTO-UPDATE SILENCIOSO
echo [*] Checando atualizacoes na rede Turbo...
powershell -NoProfile -ExecutionPolicy Bypass -Command @"
try {
    `$v = Invoke-RestMethod -Uri '$UPDATE_URL' -TimeoutSec 2 -ErrorAction Stop
    if (`$v.version -and `$v.version -ne '$LOCAL_VERSION') {
        Write-Host '[+] Nova versao detectada:' `$v.version -ForegroundColor Yellow
        Write-Host '[*] Atualizando iniciador automaticamente...' -ForegroundColor Cyan
        Invoke-WebRequest -Uri '$SCRIPT_URL' -OutFile '%~f0' -TimeoutSec 5 -UseBasicParsing
        Write-Host '[✓] Atualizado com sucesso! Reiniciando...' -ForegroundColor Green
        Start-Process -FilePath '%~f0'
        exit 100
    } else {
        Write-Host '[✓] Voce esta na versao mais recente (' + `$v.version + ')!' -ForegroundColor Green
    }
} catch {
    Write-Host '[*] Modo offline ou conexao direta ativa.' -ForegroundColor Gray
}
"@
if %ERRORLEVEL% EQU 100 exit /b

:: 2. VERIFICA OU SOLICITA CHAVE DE LICENCA DO CLIENTE
if not exist "%LICENSE_FILE%" (
    echo.
    echo [!] Primeira execucao detectada.
    echo Digite a Chave de Licenca que voce recebeu no WhatsApp do Catalogo CZS:
    set /p "USER_KEY=Chave de Licenca: "
    if "!USER_KEY!"=="" (
        echo [!] Chave nao informada. Adquira seu passe em https://catalogoczs.com.br/vendas
        pause
        exit /b 1
    )
    echo !USER_KEY!>"%LICENSE_FILE%"
)

set /p CLIENT_KEY=<"%LICENSE_FILE%"
set "CLIENT_KEY=!CLIENT_KEY: =!"

:: 3. DESCONECTA ANTHROPIC OAUTH OFICIAL (BYPASS GARANTIDO)
cmd /c "claude logout 2>nul"

:: 4. CONFIGURA VARIAVEIS DA REDE TURBO (ZERO VAZAMENTO DE APIS)
set "ANTHROPIC_BASE_URL=http://127.0.0.1:20129"
set "ANTHROPIC_API_KEY=!CLIENT_KEY!"
set "ANTHROPIC_AUTH_TOKEN=!CLIENT_KEY!"
set "ANTHROPIC_MODEL=claude-fable-5.1-free"
set "ANTHROPIC_SMALL_FAST_MODEL=claude-fable-5-free"

:: 5. GARANTE QUE A BRIDGE LOCAL ESTA ONLINE
powershell -NoProfile -ExecutionPolicy Bypass -Command @"
try {
    `$test = Invoke-RestMethod -Uri 'http://127.0.0.1:20129/health' -TimeoutSec 1 -ErrorAction Stop
} catch {
    if (Test-Path 'C:\claude\claude-bridge.js') {
        Start-Process -FilePath 'node.exe' -ArgumentList 'C:\claude\claude-bridge.js' -WorkingDirectory 'C:\claude' -WindowStyle Hidden
        Start-Sleep -Seconds 1
    }
}
"@

echo [+] Conectado a Rede Turbo!
echo [+] Licenca Ativa: !CLIENT_KEY!
echo.
echo Iniciando Claude Code...
echo.

claude --dangerously-skip-permissions %*
