@echo off
setlocal enabledelayedexpansion

:: Configuración
set "BACKUP_PATH=C:\BackupsFabiaNatura"
set "DIAS_A_ELIMINAR=0"

:: Inicializar contadores
set /a total_zip=0
set /a total_bak=0
set /a eliminados_zip=0
set /a eliminados_bak=0

echo =============================================================
echo  LIMPIEZA DE BACKUPS ANTIGUOS
echo =============================================================
echo.
echo Ruta de busqueda: %BACKUP_PATH%\
echo Se eliminaran archivos con mas de %DIAS_A_ELIMINAR% dias de antiguedad
echo.

:: Verificar si el directorio existe
if not exist "%BACKUP_PATH%" (
    echo [ERROR] El directorio de backups no existe: %BACKUP_PATH%
    pause
    exit /b 1
)

echo Listando archivos...
echo =============================================================

:: Mostrar archivos ZIP
echo.
echo [ARCHIVOS .ZIP]
echo ----------------------------------------------------------
for /f "delims=" %%F in ('dir /b /a-d "%BACKUP_PATH%\*.zip" 2^>nul') do (
    set /a total_zip+=1
    echo [!total_zip!] %%~nxF - Creado el %%~tF
)

:: Mostrar archivos BAK
echo.
echo [ARCHIVOS .BAK]
echo ----------------------------------------
for /f "delims=" %%F in ('dir /b /a-d "%BACKUP_PATH%\*.bak" 2^>nul') do (
    set /a total_bak+=1
    echo [!total_bak!] %%~nxF
)

set /a total_archivos=total_zip + total_bak

echo.
echo =============================================================
echo Procesando archivos con mas de %DIAS_A_ELIMINAR% dias...
echo =============================================================

:: Eliminar archivos ZIP antiguos
echo.
echo [ELIMINANDO .ZIP antiguos]
echo ------------------------------------------------------------------
for /f "delims=" %%F in ('forfiles /P "%BACKUP_PATH%" /M "*.zip" /D -%DIAS_A_ELIMINAR% /C "cmd /c echo @path" 2^>nul') do (
    if exist "%%F" (
        echo [ELIMINANDO] %%~nxF - Creado el %%~tF
        del /F /Q "%%F"
        if !ERRORLEVEL! EQU 0 (
            set /a eliminados_zip+=1
            echo [ELIMINADO] %%~nxF
        ) else (
            echo [ERROR] No se pudo eliminar %%~nxF
        )
        echo ----------------------------------------------------------
    )
)

:: Eliminar archivos BAK antiguos
echo.
echo [ELIMINANDO .BAK antiguos]
echo ------------------------------------------------------------------
for /f "delims=" %%F in ('forfiles /P "%BACKUP_PATH%" /M "*.bak" /D -%DIAS_A_ELIMINAR% /C "cmd /c echo @path" 2^>nul') do (
    if exist "%%F" (
        echo [ELIMINANDO] %%~nxF - Creado el %%~tF
        del /F /Q "%%F"
        if !ERRORLEVEL! EQU 0 (
            set /a eliminados_bak+=1
            echo [ELIMINADO] %%~nxF
        ) else (
            echo [ERROR] No se pudo eliminar %%~nxF
        )
        echo -----------------------------------------------------------
    )
)

set /a archivos_eliminados=eliminados_zip + eliminados_bak

echo.
echo ============ RESUMEN GENERAL ====================
echo Total archivos revisados: %total_archivos%
echo Total archivos eliminados: %archivos_eliminados%
echo ===============================================
echo.
echo Proceso de limpieza finalizado.
echo.

:end
echo.
echo Presione una tecla para continuar...
pause > nul
exit /b 0