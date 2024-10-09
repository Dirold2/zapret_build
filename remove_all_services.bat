@echo off

set SRVNAME=zapret

echo.
echo Остановка службы zapret . . .
echo.
net stop "%SRVNAME%"
sc delete "%SRVNAME%"

echo.
echo Остановка службы zapret-discord . . .
echo.
set SRVNAME=zapret-discord

sc stop windivert
net stop "%SRVNAME%"
sc delete "%SRVNAME%"

echo.
echo Задача завершена успешно. Нажмите любую клавишу . . . & >nul pause & exit