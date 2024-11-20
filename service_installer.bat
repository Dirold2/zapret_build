@echo off
color 0A
setlocal enabledelayedexpansion

chcp 65001 > nul

pushd "%~dp0"

rem Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Требуются права администратора. Пожалуйста, запустите скрипт от имени администратора.
    pause
    exit /b 1
)

rem Проверка наличия curl
where curl >nul 2>&1
if %errorlevel% neq 0 (
    echo Ошибка: curl не найден. Пожалуйста, установите его для работы скрипта.
    set "curl_missing=true"
) else (
    set "curl_missing=false"
)

:menu
cls
echo Flowseal Service Manager
echo -------------------------
echo 1. Установить сервис
echo 2. Удалить сервис
echo 3. Удалить WinDivert
echo 4. Обновить конфиги
echo 5. Обновить сервис
echo q. Выход
echo.
set /p "choice=Выберите действие: "

if "%choice%"=="1" goto :install_service
if "%choice%"=="2" goto :delete_service
if "%choice%"=="3" goto :delete_windivert
if "%choice%"=="4" (
    if !curl_missing! == false (
        goto :update_config
    ) else (
        echo Не удалось обновить файлы, так как curl не установлен.
        pause
        goto :menu
    )
)
if "%choice%"=="5" (
    if !curl_missing! == false (
        goto :update_service
    ) else (
        echo Не удалось обновить файлы, так как curl не установлен.
        pause
        goto :menu
    )
)
if /i "%choice%"=="q" exit /b 0

echo Неверный выбор. Пожалуйста, попробуйте снова.
pause
goto :menu

rem Функция для обновления и резервного копирования файлов
:update_files
rem Создание папки lists\default, если она не существует
if not exist "lists\default" (
    mkdir "lists\default"
)

rem Создание папки для резервных копий, если она не существует
if not exist "lists\backup" (
    mkdir "lists\backup"
)

rem Проверка доступности gist.githubusercontent.com
ping -n 1 gist.githubusercontent.com >nul
if errorlevel 1 (
    echo Сайт gist.githubusercontent.com недоступен. Операция отменена.
    goto :eof
)

rem Функция для проверки и обновления файлов
call :check_and_backup "list-discord.txt" "0d9543e5c7fae7af78a13300b613f5e9"
call :check_and_backup "list-discord-ip.txt" "6c87b8887b350e3edf7d0b447425c13e"
call :check_and_backup "list-youtube.txt" "98d1e6c4471cd1cdf4362a403e2fa405"
call :check_and_backup "list-global.txt" "b261a8c7f5ec35ed6332f9ef4f4f8f74"

echo Обновление файлов завершено.
goto :eof

rem Функция для проверки наличия файла, резервного копирования и загрузки
:check_and_backup
set "filename=lists\default\%~1"
set "gist_url=https://gist.githubusercontent.com/Dirold2/%~2/raw/%~1"

if exist "%filename%" (
    echo Файл %filename% найден. Перемещаем в папку backup...
    move /y "%filename%" "lists\backup\%~n1_old.txt"
) else (
    echo Файл %filename% отсутствует. Скачиваем...
)
curl -# -o "%filename%" "%gist_url%"
goto :eof

:update_config
cls
call :update_files
pause
goto :menu

:update_service
cls
setlocal enabledelayedexpansion
echo Обновление сервиса general...

rem Проверка наличия файла general.bat
if not exist "%~dp0general.bat" (
    echo Ошибка: файл general.bat не найден. Убедитесь, что он существует в текущей директории.
    pause
    goto :menu
)

rem Считывание текущей версии из файла general.bat
set "current_version="
for /f "tokens=2 delims= " %%a in ('findstr "rem " "%~dp0general.bat"') do (
    set "current_version=%%a"
    goto :version_read
)
:version_read

if not defined current_version (
    echo Ошибка: не удалось определить текущую версию из файла general.bat.
    pause
    goto :menu
)

echo Текущая версия: %current_version%

rem Получение новой версии и файла
set "new_file_url=https://gist.githubusercontent.com/Dirold2/c2c0458d3b599d2866cd48991f877750/raw/general.bat"

rem Скачиваем новый файл во временную папку
set "temp_path=%temp%\general_new.bat"
curl -# -o "%temp_path%" "%new_file_url%"
if errorlevel 1 (
    echo Ошибка: не удалось загрузить новый файл general.bat.
    pause
    goto :menu
)

rem Считывание версии из нового файла
set "new_version="
for /f "tokens=2 delims= " %%a in ('findstr "rem " "%temp_path%"') do (
    set "new_version=%%a"
    goto :new_version_read
)
:new_version_read

if not defined new_version (
    echo Ошибка: не удалось определить новую версию из скачанного файла.
    del "%temp_path%"
    pause
    goto :menu
)

echo Новая версия: %new_version%

rem Сравнение версий
if "%current_version%" == "%new_version%" (
    echo Версия %current_version% уже актуальна. Обновление не требуется.
    del "%temp_path%"
    pause
    goto :menu
)

rem Выполнение обновления
echo Обновляется файл general.bat с версии %current_version% на %new_version%...
rename "%~dp0general.bat" "general-old.bat"
move "%temp_path%" "%~dp0general.bat"
if errorlevel 1 (
    echo Ошибка при замене файла. Обновление отменено.
    pause
    goto :menu
)

echo Файл успешно обновлён.
pause
goto :menu

:install_service
cls
echo Установка сервиса...
set "args="
set "capture=0"
set QUOTE="

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

if /i "%choice%"=="q" goto :menu
if /i "%choice%"=="й" goto :menu
if /i "%choice%"=="д" goto :menu
if /i "%choice%"=="l" goto :menu

if "%choice%"=="" set "choice=1"

cls

set BIN_PATH=%~dp0zapret\zapret-winws\

if "!choice!"=="" goto :eof

set "selectedFile=!file%choice%!"
if not defined selectedFile call :show_error "Неверный выбор файла. Пожалуйста, запустите скрипт снова и выберите корректный номер."

if not exist "!selectedFile!" call :show_error "Файл !selectedFile! не найден. Пожалуйста, убедитесь, что файл существует."

rem Настраиваем параметры
for /f "tokens=*" %%a in ('type "!selectedFile!"') do (
    set "line=%%a"

    REM Проверка на наличие %BIN%winws.exe в строке
    echo !line! | findstr /i "%BIN%winws.exe" >nul
    if not errorlevel 1 (
        set "capture=1"
    )

    REM Обработка захвата
    if !capture! == 1 (
        if not defined args (
            set "line=!line:*%BIN%winws.exe"=!"
        )

        set "temp_args="
        
        REM Обработка каждого аргумента
        for %%i in (!line!) do (
            set "arg=%%i"

            REM Игнорирование символа ^
            if not "!arg!"=="^" (
                REM Обработка кавычек
                if "!arg:~0,1!" EQU "!QUOTE!" (
                    set "arg=!arg:~1,-1!"

                    REM Если аргумент содержит ":", обрабатываем его
                    echo !arg! | findstr ":" >nul
                    if !errorlevel! == 0 (
                        set "arg=\!QUOTE!!arg!\!QUOTE!"
                    ) else if "!arg:~0,1!" == "@" (
                        set "arg=\!QUOTE!@%~dp0!arg:~1!\!QUOTE!"
                    ) else if "!arg:~0,5!" == "%%BIN%%" (
                        set "arg=\!QUOTE!!BIN_PATH!!arg:~5!\!QUOTE!"
                    ) else (
                        set "arg=\!QUOTE!%~dp0!arg!\!QUOTE!"
                    )
                )
                set "temp_args=!temp_args! !arg!"
            )
        )

        REM Добавление аргументов в список
        if not "!temp_args!"=="" (
            set "args=!args!!temp_args!"
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

cls
call :update_files
cls

set SRVNAME=zapret

net stop %SRVNAME% 2>nul
sc delete %SRVNAME% 2>nul

sc create %SRVNAME% binPath="\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName="zapret DPI bypass" start=auto
if %errorlevel% neq 0 call :show_error "Не удалось создать сервис."

sc description %SRVNAME% "zapret DPI bypass software"
sc start %SRVNAME%
if %errorlevel% neq 0 call :show_error "Не удалось запустить сервис."

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

endlocal