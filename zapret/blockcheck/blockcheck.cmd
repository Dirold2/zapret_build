@echo off

cd /d "%~dp0"
FOR /F "tokens=* USEBACKQ" %%F IN (`cygwin\bin\cygpath -C OEM -a -m zapret\blog.sh`) DO (
SET P='%%F'
)

"tools\elevator" cygwin\bin\bash -i "%P%"
