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

echo.
echo Чтобы выйти нажмите Ctrl+C или любую другую комбинацию (или ^> завершите по через переменные).
echo Если вы согласны, нажмите любую клавишу, чтобы продолжить
echo.
pause
cls

echo.
echo Останавливаем службу zapret . . .
echo.

net stop "zapret"
net delete "zapret"

sc stop zapret
sc delete zapret

echo.
echo Ваша работа завершена. Нажмите любую клавишу, чтобы выйти . . . & >nul pause & exit