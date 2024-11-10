@echo off
color 0A
setlocal enabledelayedexpansion

chcp 65001 > nul

rem Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Требуются права администратора. Пожалуйста, запустите скрипт от имени администратора.
    pause
    exit /b 1
)

:menu
cls
echo Flowseal Service Manager
echo -------------------------
echo 1. Установить сервис
echo 2. Удалить сервис
echo 3. Удалить WinDivert
echo q. Выход
echo.
set /p "choice=Выберите действие: "

if "%choice%"=="1" goto :install_service
if "%choice%"=="2" goto :delete_service
if "%choice%"=="3" goto :delete_windivert
if /i "%choice%"=="q" exit /b 0
if /i "%choice%"=="" exit /b 0

echo Неверный выбор. Пожалуйста, попробуйте снова.
pause
goto :menu

:install_service
cls
echo Установка сервиса...
rem Ваш код установки сервиса
pushd "%~dp0"

rem Ищем .bat файлы в текущей директории, исключая файлы, начинающиеся с "service"
set "count=0"
for %%f in (*.bat) do (
    set "filename=%%~nxf"
    if /i not "!filename:~0,7!"=="service" (
        set /a count+=1
        echo !count!. %%f
        set "file!count!=%%f"
    )
)

rem Выводим меню выбора
echo.
set "choice="
set /p "choice=Введите номер файла или 'q' для выхода (по умолчанию 1): "

if /i "%choice%"=="q" (
    goto :menu
)

if /i "%choice%"=="" (
    set "choice=1"
)

cls

set BIN_PATH=%~dp0zapret\zapret-winws\

if "!choice!"=="" goto :eof

set "selectedFile=!file%choice%!"
if not defined selectedFile (
    echo Ошибка: Неверный выбор файла.
    echo Пожалуйста, запустите скрипт снова и выберите корректный номер.
    pause
    goto :menu
)

if not exist "!selectedFile!" (
    echo Ошибка: Файл !selectedFile! не найден.
    echo Пожалуйста, убедитесь, что файл существует и запустите скрипт снова.
    pause
    goto :menu
)

rem Настраиваем параметры
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

rem Завершаем настройку параметров
set ARGS=%args%
echo.
echo Итоговые параметры:
echo -------------------
echo !ARGS!
echo -------------------
echo.

set /p "confirm=Вы уверены, что хотите продолжить? (Y/n): "
if /i "%confirm%"=="n" (
    echo Операция отменена пользователем.
    pause
    goto :menu
)

set SRVNAME=zapret

net stop %SRVNAME% 2>nul
sc delete %SRVNAME% 2>nul

sc create %SRVNAME% binPath="\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName="zapret DPI bypass" start=auto
if %errorlevel% neq 0 (
    echo Ошибка: Не удалось создать сервис.
    pause
    goto :menu
)

sc description %SRVNAME% "zapret DPI bypass software"
sc start %SRVNAME%
if %errorlevel% neq 0 (
    echo Ошибка: Не удалось запустить сервис.
    pause
    goto :menu
)

echo Сервис успешно настроен и запущен.
pause
goto :menu

:delete_service
cls
set /p "confirm=Вы уверены, что хотите удалить сервис zapret? (y/N): "
if /i not "%confirm%"=="y" (
    echo Удаление отменено пользователем.
    pause
    goto :menu
)

echo Удаление сервиса...
net stop zapret 2>nul
sc delete zapret
echo Сервис zapret удален.
pause
goto :menu

:delete_windivert
cls
set /p "confirm=Вы уверены, что хотите удалить WinDivert? (y/N): "
if /i not "%confirm%"=="y" (
    echo Удаление отменено пользователем.
    pause
    goto :menu
)

echo Удаление WinDivert...
sc stop windivert 2>nul
sc delete windivert
sc stop WinDivert14 2>nul
sc delete WinDivert14
echo WinDivert удален.
pause
goto :menu
