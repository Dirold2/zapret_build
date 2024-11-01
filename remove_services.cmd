@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

pushd "%~dp0"

echo.
echo Чтобы выйти нажмите Ctrl+C или любую другую комбинацию (или ^> завершите по через переменные).
echo Если вы согласны, нажмите любую клавишу, чтобы продолжить
echo.
pause
cls

echo.
echo Останавливаем службу zapret . . .
echo.
net stop "%SRVNAME%"
sc delete "%SRVNAME%"

echo.
echo Ваша работа завершена. Нажмите любую клавишу, чтобы выйти . . . & >nul pause & exit