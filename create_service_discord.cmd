@echo off

:: Проверка пути
set scriptPath=%~dp0
set "path_no_spaces=%scriptPath: =%"
if not "%scriptPath%"=="%path_no_spaces%" (
    echo Путь содержит пробелы.
    echo Пожалуйста, используйте путь к файлу без пробелов.
    >nul pause
    exit /b
)

:: Сообщение перед выполнением
echo.
echo Скрипт создает службу для обхода DPI в сети (клава -^> для удаления старой службы).
echo Если вы согласны, нажмите любую клавишу, чтобы продолжить
echo.
pause

set BIN=%~dp0zapret\zapret-winws\
set ARGS=--wf-tcp=443 --wf-udp=443,50000-65535 ^
--filter-udp=443 --hostlist=\"%BIN%list-discord.txt\" --dpi-desync=fake --dpi-desync-udplen-increment=10 --dpi-desync-repeats=6 --dpi-desync-udplen-pattern=0xDEADBEEF --dpi-desync-fake-quic=\"%BIN%quic_initial_www_google_com.bin\" --new ^
--filter-udp=50000-65535 --dpi-desync=fake,tamper --dpi-desync-any-protocol --dpi-desync-fake-quic=\"%BIN%quic_initial_www_google_com.bin\" --new ^
--filter-tcp=443 --hostlist=\"%BIN%list-discord.txt\" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls=\"%BIN%tls_clienthello_www_google_com.bin\"

set SRVCNAME=zapret-discord

net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"
sc create "%SRVCNAME%" BINPath="\"%BIN%winws.exe\" %ARGS%" DisplayName="zapret DPI bypass: Discord" start=auto
sc description "%SRVCNAME%" "zapret DPI bypass software"
sc start "%SRVCNAME%"

echo.
echo Сообщение для завершения работы скрипта. . . & >nul pause & exit