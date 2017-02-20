@echo off
set MODPATH=D:\Games\CoD4-1.8\mods\rotu_test

echo Copying configs...
copy /Y ..\raw\admin_default.cfg %MODPATH%\admin.cfg
copy /Y ..\raw\damage_default.cfg %MODPATH%\damage.cfg
copy /Y ..\raw\didyouknow_default.cfg %MODPATH%\didyouknow.cfg
copy /Y ..\raw\easy_default.cfg %MODPATH%\easy.cfg
copy /Y ..\raw\game_default.cfg %MODPATH%\game.cfg
copy /Y ..\raw\mapvote_default.cfg %MODPATH%\mapvote.cfg
copy /Y ..\raw\server_default.cfg %MODPATH%\server.cfg
copy /Y ..\raw\startnewserver_default.cfg %MODPATH%\startnewserver.cfg
copy /Y ..\raw\weapons_default.cfg %MODPATH%\weapons.cfg