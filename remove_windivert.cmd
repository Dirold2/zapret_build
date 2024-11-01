@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

pushd "%~dp0"

:: Запуск инициализации
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