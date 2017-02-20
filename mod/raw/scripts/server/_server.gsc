/* Localized. */
/******************************************************************************
    Reign of the Undead, v2.x

    Copyright (c) 2010-2013 Reign of the Undead Team.
    See AUTHORS.txt for a listing.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    The contents of the end-game credits must be kept, and no modification of its
    appearance may have the effect of failing to give credit to the Reign of the
    Undead creators.

    Some assets in this mod are owned by Activision/Infinity Ward, so any use of
    Reign of the Undead must also comply with Activision/Infinity Ward's modtools
    EULA.
******************************************************************************/

#include scripts\include\utility;

init()
{
    debugPrint("in _server::init()", "fn", level.nonVerbose);

    precacheString(&"ROTUSCRIPT_DIDYOUKNOW");
    precacheString(&"ROTUSCRIPT_ADMIN_PREFIX");
    precacheString(&"ROTUSCRIPT_MOD");

    debugPrint("Running debug version of rotu_svr_scripts.iwd.", "val");
    if (level.printFunctionEntryMessages) {
        debugPrint("Printing function entrance messages", "val");
    } else {
        debugPrint("Not printing function entrance messages", "val");
    }
    if (level.printValueMessages) {
        debugPrint("Printing value messages", "val");
    } else {
        debugPrint("Not printing value messages", "val");
    }
    if (level.printSignalMessages) {
        debugPrint("Printing signal messages", "val");
    } else {
        debugPrint("Not printing signal messages", "val");
    }
    if (level.printWarningMessages) {
        debugPrint("Printing warning messages", "val");
    } else {
        debugPrint("Not printing warning messages", "val");
    }
    debugPrint("Debug message verbosity set to: " + level.debugVerbosity, "val");

    if (!isDefined(game["allies"])) {game["allies"] = "marines";}
    if (!isDefined(game["axis"])) {game["axis"] = "opfor";}

    level.starttime = getTime();
    level.activePlayers = 0;

    level.gametype = toLower(getDvar("g_gametype"));
    level.modversion = &"ROTUSCRIPT_MOD";
    level.dedicated = getDvar("dedicated");

    /**
     * Many maps try to load dust_trail_IR, but it generates errors
     * about it not being precached.  Effects cannot be precached after a call to
     * wait(), so we force it to be precached here so it is available when the
     * maps call for it.
     */
    level.barricadefx = loadfx("dust/dust_trail_IR");

    /** Many maps try to run shellshock("default_mp", 1), but there
     * was no such shock file, which caused errors about it not being precached.
     * We copied Activision's default.shock file as default_mp.shock, and precache
     * it here to stop these errors
     */
    precacheshellshock("default_mp");

    /**
     * Many maps try to precache these bottles too late, and we can't
     * fix all the maps individually, so we precache them here to stop these errors.
     */
    precacheModel("com_bottle1");
    precacheModel("com_bottle2");
    precacheModel("com_bottle3");
    precacheModel("com_bottle4");

    // Used by UMI so stock barrels don't look like the barrels we use as barricades
    precachemodel("com_barrel_blue_rust");

    currentMap = getdvar("mapname");
    currentMapName = scripts\server\_mapvoting22::mapTextName(currentMap);
    noticePrint("Starting map " + currentMapName + " (" + currentMap + ").");

    thread scripts\server\_settings::init();
    thread maps\mp\_umiEditor::init();
    thread scripts\server\_ranks::init();
    thread scripts\server\_welcome::init();
    thread scripts\server\_maps::init();
    thread scripts\server\_environment::init();
    thread scripts\clients\_clients::init();
    thread scripts\players\_players::init();
    thread scripts\gamemodes\_gamemodes::init();
    thread scripts\bots\_bots::init();
    thread scripts\server\_adminCommands::init();
    thread scripts\server\_rconInterface::init();
    thread scripts\server\_adminInterface::init();
    thread scripts\server\_scoreboard::init();
    thread scripts\level\signals::init();

    level.ascii = scripts\include\strings::buildPrintableAscii();

    // code to manage main popup menu (open on 'b' keypress)
    thread scripts\server\_main_popup::init();
    thread showDevelopmentConsoleMessages();
    buildIntermissionDidYouKnowMessages();
    thread intermissionDidYouKnowMessages();
    thread scripts\players\_players::watchPlayersData();
    thread scripts\players\_players::correctPlayerCounts();
    thread scripts\players\_players::onWaveIntermissionBegins();
    thread scripts\players\_players::onWaveIntermissionEnds();
    thread verifyRconPassword();

    noticePrint("Server is running and waiting for players to connect.");
    runTestCode();
}

/**
 * @brief Set up game configs and execute them (if it not exist).
 */
initConfigs()
{
    debugPrint("in _server::initConfigs()", "fn", level.nonVerbose);

    // Deploy configs. (Deployment WIP)
    /*deployConfig("admin.cfg", "admin_default.cfg");
    deployConfig("damage.cfg", "damage_default.cfg");
    deployConfig("didyouknow.cfg", "didyouknow_default.cfg");
    deployConfig("easy.cfg", "easy_default.cfg");
    deployConfig("game.cfg", "game_default.cfg");
    deployConfig("mapvote.cfg", "mapvote_default.cfg");
    deployConfig("server.cfg", "server_default.cfg");
    deployConfig("startnewserver.cfg", "startnewserver_default.cfg");
    deployConfig("weapons.cfg", "weapons_default.cfg");*/
    
    // Execute main config.
    //exec("exec server.cfg");
    
    // Execute default configs instead of original.
    executeDefaultConfig("server");
    executeDefaultConfig("admin");
    executeDefaultConfig("damage");
    executeDefaultConfig("didyouknow");
    //executeDefaultConfig("easy");  No, no, no. Not always required :)
    executeDefaultConfig("game");
    executeDefaultConfig("mapvote");
    executeDefaultConfig("startnewserver");
    executeDefaultConfig("weapons");
}

/**
 * @brief Copy config from FF to mod directory if not exist.
 * @TODO: Work in progress, CoD4x not allowing to open files from FF, behaviour changed to ::executeDefaultConfig.
 */
 /*
deployConfig(name, ffname)
{
    debugPrint("in _server::deployConfig()", "fn", level.nonVerbose);

    if (!FS_TestFile(name)) // If file not exist - deploy.
    {
        f_ffname = FS_FOpen(ffname, "read");
        if (!f_ffname)
        {
            warnPrint("File '" + ffname + "' not exist, deploy config ignored.");
            return;
        }
        
        f_name = FS_FOpen(name, "write");
        if (!f_name)
        {
            warnPrint("Can not copy config to '" + name + "'.");
            FS_FClose(f_ffname);
            return;
        }

        noticePrint("Deploying config file '" + ffname + "' to '" + name + "'.");
        line = FS_ReadLine(f_ffname);
        while(isDefined(line))
        {
            FS_WriteLine(f_name, line);
            line = FS_ReadLine(f_ffname);
        }
        FS_FClose(f_ffname);
        FS_FClose(f_name);
    }
}*/

/**
 * @brief Executes default config file called <name>_default.cfg if <name>.cfg not exist in mod directory.
 * @param name A name of config to execute against.
 */
executeDefaultConfig(name)
{
    debugPrint("in _server::deployConfig()", "fn", level.nonVerbose);

    if (!FS_TestFile(name + ".cfg"))
    {
        noticePrint("Config file '" + name + ".cfg' not exist, executing '" + name + "_default.cfg'.");
        exec("exec " + name + "_default.cfg");
    }
}


/**
 * @brief Checks for and tries to fix an incorrect rcon password
 *
 * @returns nothing
 */
verifyRconPassword()
{
    debugPrint("in _server::verifyRconPassword()", "fn", level.nonVerbose);

    wait 5;
    resetCount = 0;
    while ((getdvar("rcon_password") != getdvar("rcon_password_backup")) &&
           (resetCount < 4))
    {
        warnPrint("rcon_password is incorrect.  Resetting it using the backup rcon password.");
        setdvar("rcon_password", getdvar("rcon_password_backup"));
        resetCount++;
        wait 3;
    }
    if (getdvar("rcon_password") != getdvar("rcon_password_backup")) {
        errorPrint("We failed to fix the incorrect rcon password.");
        return;
    }
}


/**
 * @brief Shows console messages about this being a test and development server
 *
 * @returns nothing
 */
showDevelopmentConsoleMessages()
{
    debugPrint("in _server::showDevelopmentConsoleMessages()", "fn", level.nonVerbose);

    wait 15;
    message1 = getDvar("admin_message1");
    message2 = getDvar("admin_message2");
    message3 = getDvar("admin_message3");

    while(true) {
        if (message1 != "") {
            iPrintln(&"ROTUSCRIPT_ADMIN_PREFIX", message1);
            wait 3;
        }
        if (message2 != "") {
            iPrintln(&"ROTUSCRIPT_ADMIN_PREFIX", message2);
            wait 3;
        }
        if (message3 != "") {
            iPrintln(&"ROTUSCRIPT_ADMIN_PREFIX", message3);
        }
        wait 180; // show messages every 3 minutes
    }
}



readLogMessages()
{
    debugPrint("in _server::readLogMessages()", "fn", level.lowVerbosity);
    /// To use the file commands, we need to be inside /# ... #/ tags
    /#

    /// N.B. These file commands require +set developer 1 in the game command line
    logFilename = "C:\\Program Files (x86)\\Activision\\Call of Duty 4 - Modern Warfare\\Mods\\rotu21\\oct_mp.log";
    chatFilename = "C:\\Program Files (x86)\\Activision\\Call of Duty 4 - Modern Warfare\\Mods\\rotu21\\chat.log";
    debugPrint("logFilename: " + logFilename, "val");
    debugPrint("chatFilename: " + chatFilename, "val");
    logFile = 0;
    logFile = openfile(logFilename, "read");
//     assertex( logFile != -1, "Could not open file: " + logFilename );
    chatFile = openfile(chatFilename, "write");
//     assertex( chatFile != -1, "Could not open file: " + chatFilename );

    /// @todo still can't work with files
    line = FReadLn(logFile);
    line = "test lorem ipsum\n";
    fprintln(chatFile, line);

    CloseFile(logFile);
    CloseFile(chatFile);
    debugPrint("test", "val");

    #/
}

/**
 * @brief Shows 'Did You Know' messages between waves
 *
 * @returns nothing
 */
intermissionDidYouKnowMessages()
{
    debugPrint("in _server::intermissionDidYouKnowMessages()", "fn", level.nonVerbose);

    self endon("game_ended");

    while(1) {
        level waittill("wave_finished");
        wait 3;
        index = randomInt(level.didYouKnow.size);
        for (i=0; i<4; i++) {
            iPrintln(&"ROTUSCRIPT_DIDYOUKNOW", level.didYouKnow[index]);
            index++;
            if (index == level.didYouKnow.size) {index = 0;}
            wait 5;
        }
    }
}

/**
 * @brief Loads the did you know data from the config file
 *
 * @returns nothing
 */
buildIntermissionDidYouKnowMessages()
{
    debugPrint("in _server::buildIntermissionDidYouKnowMessages()", "fn", level.nonVerbose);

    level.didYouKnow = [];
    for (i=0; i<60; i++) {
        get = getdvar("surv_did_you_know"+(i+1));
        if(get == "") {break;}
        level.didYouKnow[i] = get;
    }
}

/**
 * @brief A convenient spot to put test code that will be executed when the server starts
 *
 * @returns nothing
 */
runTestCode()
{
    debugPrint("in _server::runTestCode()", "fn", level.nonVerbose);

//     maps\mp\_umi::devDumpEntities();
//     maps\mp\_umi::devDumpCsvWaypointsToBtd();
    //     thread maps\mp\_umiEditor::devDrawWaypoints(true);
}
