@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

::Управление запуском сервиса Flowseal
::Файлы должны находиться в корне - там где расположен батник

::Выводим меню выбора
echo.
echo Выберите файл, который хотите выполнить с определенными параметрами (например > запустить на определенных условиях).
echo Если выбираете, будьте готовы записать, какие именно параметры используются после
echo.
pause
cls

pushd "%~dp0"

set BIN_PATH=%~dp0zapret\zapret-winws\

::Ищем .bat файлы в текущей директории, исключая файлы, начинающиеся с "service"
set "count=0"
for %%f in (*.bat) do (
    set "filename=%%~nxf"
    if /i not "!filename:~0,7!"=="service" (
        set /a count+=1
        echo !count!. %%f
        set "file!count!=%%f"
    )
)

:: Выбор файла
set "choice=bat/"
set /p "choice=Введите номер файла: "

if "!choice!"=="" goto :eof

set "selectedFile=!file%choice%!"
if not defined selectedFile (
    echo Ошибка входа, завершение.
    pause
    goto :eof
)

:: Настраиваем параметры
set "args="
set "capture=0"
set QUOTE="

for /f "tokens=*" %%a in ('type "!selectedFile!"') do (
    set "line=%%a"

    echo !line! | findstr /i "%BIN%winws.exe" >nul
    if not errorlevel 1 (
        set "capture=1"
    )

    if !capture!==1 (
        if not defined args (
            set "line=!line:*%BIN%winws.exe"=!"
        )

        set "temp_args="
        for %%i in (!line!) do (
            set "arg=%%i"

            if not "!arg!"=="^" (
                if "!arg:~0,1!" EQU "!QUOTE!" (
                    set "arg=!arg:~1,-1!"

                    echo !arg! | findstr ":" >nul
                    if !errorlevel!==0 (
                        set "arg=\!QUOTE!!arg!\!QUOTE!"
                    ) else if "!arg:~0,1!"=="@" (
                        set "arg=\!QUOTE!@%~dp0!arg:~1!\!QUOTE!"
                    ) else if "!arg:~0,5!"=="%%BIN%%" (
                        set "arg=\!QUOTE!!BIN_PATH!!arg:~5!\!QUOTE!"
                    ) else (
                        set "arg=\!QUOTE!%~dp0!arg!\!QUOTE!"
                    )
                )

                set "temp_args=!temp_args! !arg!"
            )
        )

        if not "!temp_args!"=="" (
            set "args=!args! !temp_args!"
        )
    )
)

:: Завершаем настройку параметров
set ARGS=%args%
echo Итоговые параметры: !ARGS!

set SRVNAME=zapret

net stop %SRVNAME%
sc delete %SRVNAME%
sc create %SRVNAME% binPath="\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName="zapret DPI bypass" start=auto
sc description %SRVNAME% "zapret DPI bypass software"
sc start %SRVNAME%

pause