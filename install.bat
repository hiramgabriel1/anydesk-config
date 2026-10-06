@echo off
setlocal EnableExtensions

title Configuracion automatica de AnyDesk

echo ==========================================
echo       CONFIGURANDO ANYDESK
echo ==========================================
echo.

:: ==========================================
:: BUSCAR ANYDESK
:: ==========================================

set "ANYDESK="

if exist "%ProgramFiles%\AnyDesk\AnyDesk.exe" (
    set "ANYDESK=%ProgramFiles%\AnyDesk\AnyDesk.exe"
)

if not defined ANYDESK if exist "%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe" (
    set "ANYDESK=%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe"
)

if not defined ANYDESK (
    echo [ERROR] No se encontro AnyDesk.
    echo.
    pause
    exit /b 1
)

echo [OK] AnyDesk encontrado:
echo %ANYDESK%
echo.

:: ==========================================
:: COMPROBAR ADMINISTRADOR
:: ==========================================

net session >nul 2>&1

if %errorlevel% neq 0 (
    echo [INFO] Solicitando permisos de administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo [OK] Permisos de administrador confirmados.
echo.

:: ==========================================
:: INICIAR SERVICIO
:: ==========================================

echo [1/4] Iniciando servicio de AnyDesk...

sc config AnyDesk start= auto >nul 2>&1
sc start AnyDesk >nul 2>&1

timeout /t 5 /nobreak >nul

echo [OK] Servicio iniciado.
echo.

:: ==========================================
:: INICIAR ANYDESK
:: ==========================================

echo [2/4] Iniciando AnyDesk...

start "" "%ANYDESK%"

timeout /t 5 /nobreak >nul

echo [OK] AnyDesk iniciado.
echo.

:: ==========================================
:: CONFIGURAR CONTRASENA
:: ==========================================

echo [3/4] Configurando acceso desatendido...

set "PASSWORD=x"

"%ANYDESK%" --set-password "%PASSWORD%" >nul 2>&1

if %errorlevel% neq 0 (
    echo [ADVERTENCIA] No se pudo configurar automaticamente la contrasena.
    echo.
    echo Intenta configurarla manualmente desde:
    echo AnyDesk ^> Settings ^> Security ^> Unattended Access
    echo.
) else (
    echo [OK] Acceso desatendido configurado.
)

timeout /t 2 /nobreak >nul

:: ==========================================
:: OBTENER ID
:: ==========================================

echo [4/4] Obteniendo ID de AnyDesk...
echo.

set "ANYDESK_ID="

for /f "delims=" %%A in ('"%ANYDESK%" --get-id 2^>nul') do (
    set "ANYDESK_ID=%%A"
)

if not defined ANYDESK_ID (
    echo [ERROR] No se pudo obtener automaticamente el ID.
    echo.
    echo Abre AnyDesk y revisa el ID mostrado en pantalla.
    echo.
    pause
    exit /b 1
)

set "ANYDESK_ID=%ANYDESK_ID: =%"

:: ==========================================
:: GUARDAR INFORMACION EN LA USB
:: ==========================================

set "OUTPUT=%~dp0ANYDESK_INFO.txt"

(
    echo ==========================================
    echo       INFORMACION DE ANYDESK
    echo ==========================================
    echo.
    echo ID: %ANYDESK_ID%
    echo PASSWORD: %PASSWORD%
    echo.
    echo Acceso desatendido: CONFIGURADO
    echo Servicio: AUTOMATICO
    echo.
    echo ==========================================
) > "%OUTPUT%"

echo.
echo ==========================================
echo       CONFIGURACION TERMINADA
echo ==========================================
echo.
echo ID: %ANYDESK_ID%
echo PASSWORD: %PASSWORD%
echo.
echo Informacion guardada en:
echo %OUTPUT%
echo.
echo ==========================================

pause
endlocal