@echo off
setlocal enabledelayedexpansion

:: Configuracion de la base de datos
set "SQL_SERVER=DESKTOP-6A5UV7A\SQLEXPRESS"
set "DB_NAME=FabiaNatura"
set "BACKUP_PATH=C:\BackupsFabiaNatura"
set "EXIT_CODE=0"

echo ========================================
echo  RESPALDO DE BASE DE DATOS
echo ========================================
echo.
echo Iniciando proceso de respaldo...
echo ----------------------------------------
echo Servidor: %SQL_SERVER%
echo Base de datos: %DB_NAME%
echo Ruta de respaldo: %BACKUP_PATH%

:: Crear directorio de respaldo si no existe
if not exist "%BACKUP_PATH%" (
    echo Creando directorio de respaldo...
    mkdir "%BACKUP_PATH%"
    if !ERRORLEVEL! NEQ 0 (
        echo [ERROR] No se pudo crear el directorio de respaldo.
        set "EXIT_CODE=1"
        goto :final
    )
    echo [OK] Directorio creado exitosamente.
)

:: Obtener fecha y hora en formato ISO 8601
for /f "delims=" %%a in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>nul') do set "BACKUP_DATE=%%a"
if "%BACKUP_DATE%"=="" (
    echo [ERROR] No se pudo obtener la fecha actual.
    set "EXIT_CODE=1"
    goto :final
)

set "BACKUP_FILE=%DB_NAME%_backup_%BACKUP_DATE%.bak"
set "FULL_PATH=%BACKUP_PATH%\%BACKUP_FILE%"

echo.
echo ----------------------------------------
echo Iniciando respaldo de la base de datos...
echo Archivo de salida: %BACKUP_FILE%
echo ----------------------------------------

:: Realizar el backup
sqlcmd -S %SQL_SERVER% -Q "BACKUP DATABASE [%DB_NAME%] TO DISK = '%FULL_PATH%' WITH FORMAT, MEDIANAME = 'VentasBD2_Backups', NAME = 'Backup de %DB_NAME% del %BACKUP_DATE%';" -t 30 2>nul
if %ERRORLEVEL% NEQ 0 (
    set "EXIT_CODE=1"
    echo.
    echo [ERROR] No se pudo completar el backup.
    if exist "%FULL_PATH%" (
        echo Eliminando archivo de respaldo incompleto...
        del "%FULL_PATH%"
    )
    echo.
    echo [ERROR] Ocurrio un error durante el proceso de respaldo.
    echo Verifique los mensajes de error y la conexion al servidor.
) else (
    echo.
    echo [EXITO] Respaldo completado correctamente.
    echo.
    echo ============ RESUMEN =================
    echo Base de datos: %DB_NAME%
    echo Archivo creado: %BACKUP_FILE%
    echo Ruta completa: %FULL_PATH%
    if exist "%FULL_PATH%" (
        for %%F in ("%FULL_PATH%") do set "SIZE=%%~zF"
        echo Tamano: !SIZE! bytes
    )
    echo ========================================
)

:final
echo.
if %EXIT_CODE% EQU 0 (
    echo Proceso de respaldo finalizado correctamente.
) else (
    echo El proceso de respaldo ha finalizado con errores.
)
echo.
echo Presione una tecla para continuar...
pause > nul
exit /b %EXIT_CODE%