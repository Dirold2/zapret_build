@echo off
setlocal enabledelayedexpansion

:: Flowseal Service Manager
:: Этот скрипт управляет сервисом Flowseal DPI bypass
:: Автор: [dirold2]
:: Дата последнего обновления: [10.11.2024]

chcp 65001 > nul

rem Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ошибка: Требуются права администратора.
    echo Пожалуйста, запустите скрипт от имени администратора.
    pause
    exit /b 1
)

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
set "choice=bat/"
set /p "choice=Введите номер файла или 'q' для выхода: "

if /i "%choice%"=="q" (
    exit /b 0
)

cls

set BIN_PATH=%~dp0zapret\zapret-winws\

if "!choice!"=="" goto :eof

set "selectedFile=!file%choice%!"
if not defined selectedFile (
    echo Ошибка: Неверный выбор файла.
    echo Пожалуйста, запустите скрипт снова и выберите корректный номер.
    pause
    exit /b 1
)

if not exist "!selectedFile!" (
    echo Ошибка: Файл !selectedFile! не найден.
    echo Пожалуйста, убедитесь, что файл существует и запустите скрипт снова.
    pause
    exit /b 1
)

rem  Настраиваем параметры
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

rem  Завершаем настройку параметров
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
    exit /b 0
)

set SRVNAME=zapret

net stop %SRVNAME% 2>nul
if %errorlevel% neq 0 echo Предупреждение: Не удалось остановить сервис. Возможно, он не был запущен.

sc delete %SRVNAME% 2>nul
if %errorlevel% neq 0 echo Предупреждение: Не удалось удалить сервис. Возможно, он не существовал.

sc create %SRVNAME% binPath="\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName="zapret DPI bypass" start=auto
if %errorlevel% neq 0 (
    echo Ошибка: Не удалось создать сервис.
    pause
    exit /b 1
)

sc description %SRVNAME% "zapret DPI bypass software"
if %errorlevel% neq 0 echo Предупреждение: Не удалось установить описание сервиса.

sc start %SRVNAME%
if %errorlevel% neq 0 (
    echo Ошибка: Не удалось запустить сервис.
    pause
    exit /b 1
)

echo Сервис успешно настроен и запущен.

pause