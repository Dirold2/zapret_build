@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

rem Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Требуются права администратора. Пожалуйста, запустите скрипт от имени администратора.
    pause
    exit /b 20
)

pushd "%~dp0"

rem  Запуск инициализации
echo.
echo Данная запись будет удалена и инициализация завершена (если > продолжить на данном инициализировании).
echo Если вы готовы, нажмите любую клавишу, иначе дождитесь завершения цикла
echo.
pause
cls

echo Windivert deleting . . .

sc stop windivert
sc delete windivert

net stop "WinDivert"
net delete "WinDivert"

net stop "WinDivert14"
net delete "WinDivert14"

echo.
echo Готово к завершению инициализации . . . & >nul pause & exit