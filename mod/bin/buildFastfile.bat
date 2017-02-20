@echo off
echo Building 'mod.ff'...
    linker_pc.exe -language english -compress mod
echo Copying 'mod.ff' to Release directory...
    copy /Y ..\zone\english\mod.ff Release\mod.ff
pause
exit 0