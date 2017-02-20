@echo off
    del Release\rotu_svr_custom.iwd
echo Building 'rotu_svr_custom.iwd'...
    7z.exe a -tzip Release\rotu_svr_custom.iwd ..\raw\custom_scripts ..\raw\custom_maps\maps
pause
exit 0