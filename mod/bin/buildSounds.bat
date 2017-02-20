@echo off
echo Rebuilding 'sound.iwd'...
    del Release\sound.iwd
    7z.exe a -tzip Release\sound.iwd ..\raw\sound -xr!*.wav
pause
exit 0