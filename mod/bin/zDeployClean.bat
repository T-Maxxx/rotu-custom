@echo off
set MODPATH=D:\Games\CoD4-1.8\mods\rotu_test
echo Cleaning up deploy directory...
    del %MODPATH%\*.iwd
    del %MODPATH%\*.ff
    del %MODPATH%\*.cfg
    del %MODPATH%\*.log
    del %MODPATH%\*.csv
exit