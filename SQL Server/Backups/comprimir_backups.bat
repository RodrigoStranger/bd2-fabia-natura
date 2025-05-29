@echo off
setlocal enabledelayedexpansion

:: Configuración
set "BACKUP_PATH=C:\BackupsFabiaNatura"
set "DIAS_ANTIGUEDAD=0"

echo ========================================
echo  COMPRESION DE BACKUPS (.ZIP Nativo Windows)
echo ========================================
echo.
echo Ruta de búsqueda: %BACKUP_PATH%\*.bak
echo Se comprimiran archivos con más de %DIAS_ANTIGUEDAD% días de antigüedad
echo.

:: Verificar si el directorio existe
if not exist "%BACKUP_PATH%" (
    echo [ERROR] El directorio de backups no existe: %BACKUP_PATH%
    goto :end
)

:: Contadores
set /a total_archivos=0
set /a archivos_comprimidos=0

echo Listando archivos .bak...
echo ----------------------------------------

for %%F in ("%BACKUP_PATH%\*.bak") do (
    if exist "%%F" (
        set /a total_archivos+=1
        echo [ARCHIVO !total_archivos!] %%~nxF - Creado el %%~tF
    )
)

echo.
echo Comprimiendo archivos con más de %DIAS_ANTIGUEDAD% días...
echo ----------------------------------------

for /f "delims=" %%F in ('forfiles /P "%BACKUP_PATH%" /M *.bak /D -%DIAS_ANTIGUEDAD% /C "cmd /c echo @path" 2^>nul') do (
    if exist "%%F" (
        set "ARCHIVO=%%~F"
        set "ZIPDEST=%%~dpnF.zip"

        echo [COMPRIMIENDO] %%~nxF - Destino: !ZIPDEST!
        
        powershell -Command "Compress-Archive -Path '!ARCHIVO!' -DestinationPath '!ZIPDEST!' -Force"

        if exist "!ZIPDEST!" (
            del /F /Q "!ARCHIVO!"
            set /a archivos_comprimidos+=1
            echo [COMPRIMIDO] %%~nxF
        ) else (
            echo [ERROR] No se pudo comprimir %%~nxF
        )
        echo ----------------------------------------
    )
)

:mostrar_resumen
echo.
echo ============ RESUMEN =================
echo Total de archivos .bak encontrados: !total_archivos!
echo Archivos comprimidos: !archivos_comprimidos!
echo ========================================
echo.
echo Proceso finalizado.
echo.

:end
echo Presione una tecla para continuar...
pause > nul