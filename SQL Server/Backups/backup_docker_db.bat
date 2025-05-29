@echo off
setlocal enabledelayedexpansion

:: Configuracion de la base de datos
set "CONTAINER_NAME=SqlServer-FabiaNatura"
set "DB_NAME=FabiaNatura"
set "SA_PASSWORD=Rodrigo2024"
set "HOST_BACKUP_DIR=C:\BackupsFabiaNatura"
set "CONTAINER_BACKUP_DIR=/var/opt/mssql/backup"
set "EXIT_CODE=0"

echo ========================================
echo  RESPALDO DE BASE DE DATOS
echo ========================================
echo.
echo Iniciando proceso de respaldo...
echo ----------------------------------------
echo Contenedor: %CONTAINER_NAME%
echo Base de datos: %DB_NAME%
echo Ruta de respaldo: %HOST_BACKUP_DIR%

:: Crear directorio de respaldo si no existe
if not exist "%HOST_BACKUP_DIR%" (
    echo Creando directorio de respaldo...
    mkdir "%HOST_BACKUP_DIR%"
    if !ERRORLEVEL! NEQ 0 (
        echo [ERROR] No se pudo crear el directorio de respaldo.
        set "EXIT_CODE=1"
        goto :final
    )
    echo [OK] Directorio creado exitosamente.
)

:: Verificar si el contenedor está ejecutándose
docker ps --filter "name=%CONTAINER_NAME%" --format "{{.Names}}\t{{.Status}}" | findstr %CONTAINER_NAME% >nul
if !ERRORLEVEL! NEQ 0 (
    echo [ERROR] El contenedor %CONTAINER_NAME% no esta en ejecucion.
    echo Intente iniciar el contenedor con: docker-compose up -d
    set "EXIT_CODE=1"
    goto :final
)

:: Obtener fecha y hora en formato ISO 8601
for /f "delims=" %%a in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>nul') do set "BACKUP_DATE=%%a"
if "%BACKUP_DATE%"=="" (
    echo [ERROR] No se pudo obtener la fecha actual.
    set "EXIT_CODE=1"
    goto :final
)

set "BACKUP_FILE=%DB_NAME%_backup_%BACKUP_DATE%.bak"
set "CONTAINER_FULL_PATH=%CONTAINER_BACKUP_DIR%/%BACKUP_FILE%"
set "HOST_FULL_PATH=%HOST_BACKUP_DIR%\%BACKUP_FILE%"

echo.
echo ----------------------------------------
echo Iniciando respaldo de la base de datos...
echo Archivo de salida: %BACKUP_FILE%
echo ----------------------------------------

:: Crear directorio en el contenedor si no existe
docker exec %CONTAINER_NAME% mkdir -p %CONTAINER_BACKUP_DIR% >nul

:: Realizar el backup
docker exec %CONTAINER_NAME% /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "%SA_PASSWORD%" -C -Q "BACKUP DATABASE [%DB_NAME%] TO DISK = N'%CONTAINER_FULL_PATH%' WITH FORMAT, INIT, NAME = 'Backup de %DB_NAME% del %BACKUP_DATE%'"

if !ERRORLEVEL! NEQ 0 (
    set "EXIT_CODE=1"
    echo.
    echo [ERROR] No se pudo completar el respaldo.
    echo.
    echo [ERROR] Ocurrio un error durante el proceso de respaldo.
    echo Verifique los mensajes de error y la conexion al contenedor.
) else (
    echo.
    echo [EXITO] Respaldo completado correctamente.
    echo.
    echo ============ RESUMEN =================
    echo Base de datos: %DB_NAME%
    echo Archivo creado: %BACKUP_FILE%
    echo Ruta en contenedor: %CONTAINER_FULL_PATH%
    echo Ruta en host: %HOST_FULL_PATH%
    
    :: Verificar tamaño del archivo
    echo.
    echo Verificando archivo de respaldo...
    for /f "tokens=*" %%i in ('docker exec %CONTAINER_NAME% ls -la %CONTAINER_FULL_PATH% 2^>^&1 ^| find "%BACKUP_FILE%"') do (
        echo Tamano: %%~i
    )
    echo ========================================
    
    :: Copiar el archivo al host
    echo.
    echo Copiando archivo al host...
    docker cp %CONTAINER_NAME%:%CONTAINER_FULL_PATH% "%HOST_FULL_PATH%"
    if !ERRORLEVEL! EQU 0 (
        echo [OK] Archivo copiado correctamente a:
        echo %HOST_FULL_PATH%
    ) else (
        echo [ADVERTENCIA] No se pudo copiar el archivo al host.
    )
)

:final
echo.
if !EXIT_CODE! EQU 0 (
    echo Proceso de respaldo finalizado correctamente.
) else (
    echo El proceso de respaldo ha finalizado con errores.
)
echo.
echo Presione una tecla para continuar...
pause > nul
exit /b !EXIT_CODE!