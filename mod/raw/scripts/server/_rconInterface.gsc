/* Localization not required. */
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
/**
 * @file _rconInterface.gsc This file sets up the RCON interface to the admin commands
 */

#include scripts\include\utility;

init()
{
    debugPrint("in _rconInterface::init()", "fn", level.nonVerbose);

    level.cmd = [];
    thread watchCmd();

    addCmd("boom", ::boomPlayer);
    addCmd("change_map", ::changeMap);
    addCmd("restart_map", ::restartMap);
    addCmd("finish_map", ::finishMap);
    addCmd("kill_zombies", ::killZombies);

    precache();
}

precache()
{
    debugPrint("in _rconInterface::precache()", "fn", level.nonVerbose);
}

/**
 * @brief Adds an rcon command to the commands array
 *
 * @param dvar string The name of the dvar that will be the flag for this command, contains the args
 * @param script The name of the function to call when the flag is set
 *
 * @returns nothing
 */
addCmd(dvar, script)
{
    debugPrint("in _rconInterface::addCmd()", "fn", level.nonVerbose);

    cmd = spawnstruct();
    level.cmd[level.cmd.size] = cmd;
    cmd.dvar = dvar;
    cmd.script = script;
    setdvar(dvar, "");
}

/**
 * @brief Checks for commands that have their flag set, then executes that command
 *
 * @returns nothing
 */
watchCmd()
{
    debugPrint("in _rconInterface::watchCmd()", "fn", level.nonVerbose);

    while(1) {
        for (i=0; i<level.cmd.size; i++) {
            cmd = level.cmd[i];
            val = getdvar(cmd.dvar);
            if (val!="") {
                setdvar(cmd.dvar, "" );
                [[cmd.script]](StrTok(val, "&"));
            }
        }
        wait 0.25;
    }
}

/**
 * @brief Rcon hook for killing zombies
 *
 * @returns nothing
 */
killZombies()
{
    debugPrint("in _rconInterface::killZombies()", "fn", level.lowVerbosity);

    scripts\server\_adminCommands::killZombies(level.rconAdmin);
}

/**
 * @brief Rcon hook for exploding a player
 *
 * @param args array The first element contains the player number
 *
 * @returns nothing
 */
boomPlayer(args)
{
    debugPrint("in _rconInterface::boomPlayer()", "fn", level.lowVerbosity);

    players = getentarray("player", "classname");
    for (i=0; i<players.size; i++) {
        if (players[i] getEntityNumber() == int(args[0])) {
            players[i] scripts\server\_adminCommands::explodePlayer(level.rconAdmin);
            return;
        }
    }
}

/**
 * @brief Rcon hook for changing the map
 *
 * @param args array The first element contains map to change to
 *
 * @returns nothing
 */
changeMap(args)
{
    debugPrint("in _rconInterface::changeMap()", "fn", level.lowVerbosity);

    mapname = args[0];
    if (scripts\server\_adminCommands::validateMap(mapname)) {
        scripts\server\_adminCommands::changeMap(level.rconAdmin, mapname);
    } else {
        noticePrint("Admin " + level.rconAdmin.name + " changed the map to " + mapname + ", which may be an invalid map");
        scripts\server\_maps::changeMap(mapname);
    }
}

/**
 * @brief Rcon hook for restarting the current map
 *
 * @returns nothing
 */
restartMap()
{
    debugPrint("in _rconInterface::restartMap()", "fn", level.lowVerbosity);

    scripts\server\_adminCommands::restartMap(level.rconAdmin);
}

/**
 * @brief Rcon hook for finishing the current map
 *
 * @returns nothing
 */
finishMap()
{
    debugPrint("in _rconInterface::finishMap()", "fn", level.lowVerbosity);

    scripts\server\_adminCommands::finishMap(level.rconAdmin);
}
