@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

pushd "%~dp0"
set BIN=%~dp0zapret\zapret-winws\
start "zapret: main" /min "%BIN%winws.exe" --wf-raw="@lists\default\rules.txt" ^
    --wf-tcp=80,443,50000-65535 --wf-udp=443,50000-65535 --filter-udp=443 --hostlist="lists\list-general.txt" --dpi-desync=fake --dpi-desync-udplen-increment=10 --dpi-desync-repeats=6 --dpi-desync-udplen-pattern=0xDEADBEEF --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
    --filter-udp=50000-65535 --dpi-desync=fake,tamper --dpi-desync-any-protocol --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
    --filter-tcp=80 --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
    --filter-tcp=443 --hostlist="lists\list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^

    --dpi-desync=fake,disorder2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
    --filter-tcp=443 --hostlist="lists\default\list-discord.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
    --wf-l3=ipv4 --filter-tcp=443 --dpi-desync=disorder2 --dpi-desync-any-protocol --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

    --filter-tcp=443 --hostlist="lists\default\list-discord-ip.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
    --wf-l3=ipv4 --wf-udp=443 --dpi-desync=fake --dpi-desync-repeats=5