@echo off

:: Проверка пути
set scriptPath=%~dp0
set "path_no_spaces=%scriptPath: =%"
if not "%scriptPath%"=="%path_no_spaces%" (
    echo Внимание! Путь содержит пробелы.
    echo Пожалуйста, измените путь и запустите снова.
    >nul pause
    exit /b
)

:: Сообщение о начале выполнения
echo.
echo Пожалуйста, убедитесь, что вы прочли инструкцию (подсказка -> инструкция в другом документе).
echo Если вы готовы, нажмите любую клавишу, чтобы продолжить настройку
echo.
pause

set BIN=%~dp0zapret\zapret-winws\
set ARGS=--wf-tcp=443-65535 --wf-udp=443-65535 ^
--wf-tcp=80,443,50000-65535 --wf-udp=443,50000-65535 ^
--filter-udp=443 --hostlist="%BIN%list-general.txt" --dpi-desync=fake --dpi-desync-udplen-increment=10 --dpi-desync-repeats=6 --dpi-desync-udplen-pattern=0xDEADBEEF --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--filter-udp=50000-65535 --dpi-desync=fake,tamper --dpi-desync-any-protocol --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--filter-tcp=80 --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--filter-tcp=443 --hostlist="%BIN%list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
--dpi-desync=fake,disorder2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig

set SRVCNAME=zapret

net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"
sc create "%SRVCNAME%" binPath="\"%BIN%winws.exe\" %ARGS%" DisplayName="zapret DPI bypass: General" start=auto
sc description "%SRVCNAME%" "zapret DPI bypass software"
sc start "%SRVCNAME%"

echo.
echo Всё готово! Нажмите любую клавишу, чтобы закрыть . . . & >nul pause & exit