@echo off
echo Building '2d.iwd'...
    del Release\2d.iwd
    7z.exe a -tzip Release\2d.iwd ..\raw\images
pause
exit 0