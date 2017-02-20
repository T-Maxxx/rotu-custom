@echo off
del Release\rotu_configs.iwd
echo Building 'rotu_configs.iwd'
    7z.exe a -tzip Release\rotu_configs.iwd -x!fileSysCheck.cfg ..\raw\*.cfg
echo Done.
pause
exit 0
