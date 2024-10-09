@echo off

set SRVNAME=zapret-discord

sc stop windivert
net stop "%SRVNAME%"
sc delete "%SRVNAME%"

echo ������ ���� ������ �⮡� ������� ���� . . . & >nul pause & exit /b
