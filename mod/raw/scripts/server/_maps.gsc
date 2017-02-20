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

#include scripts\include\data;
#include scripts\include\utility;

init()
{
    debugPrint("in _maps::init()", "fn", level.nonVerbose);

    level.onChangeMap = ::blank;
    if (level.dvar["game_mapvote"] == 1) {
        thread scripts\server\_mapvoting22::init();
    } else {
        thread scripts\server\_maprotation::init();
    }

    thread logPlayersAtGameEnd();
    applyMapFixes();

    // enable some features found on non-rotu maps
    if (isDefined(level.glidePads)) {
        for (i=0; i<level.glidePads.size; i++) {
            level.glidePads[i].trigger thread watchGlidePad(level.glidePads[i]);
        }
    }

    if (isDefined(level.elevators)) {
        for (i=0; i<level.elevators.size; i++) {
            for (j=0; j<level.elevators[i].triggers.size; j++) {
                level.elevators[i].triggers[j] thread watchElevatorTrigger(level.elevators[i]);
            }
        }
    }

    if (isDefined(level.mapTeleporters)) {
        for (i=0; i<level.mapTeleporters.size; i++) {
            level.mapTeleporters[i].trigger thread watchMapTeleporters(level.mapTeleporters[i]);
        }
    }

    if (isDefined(level.mapHurtTriggers)) {
        for (i=0; i<level.mapHurtTriggers.size; i++) {
            level.mapHurtTriggers[i].trigger thread watchHurtTriggers(level.mapHurtTriggers[i]);
        }
    }

    // cyclical animations
    if (isDefined(level.mapAnimations)) {
        for (i=0; i<level.mapAnimations.size; i++) {
            thread mapAnimation(level.mapAnimations[i]);
        }
    }
}

blank(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
{}

/**
 * @brief Apply map-specific fixes
 *
 * Many maps contain programming errors that lead to runtime errors.  Since we
 * don't have access to the source code for the maps, we apply custom fixes here
 * as a work around when we can.
 *
 * @returns nothing
 */
applyMapFixes()
{
    debugPrint("in _maps::applyMapFixes()", "fn", level.nonVerbose);

    currentMap = getdvar("mapname");

    debugPrint(currentMap + ": bg_falldamagemaxheight: " + getdvar("bg_falldamagemaxheight"), "val");
    debugPrint(currentMap + ": bg_falldamageminheight: " + getdvar("bg_falldamageminheight"), "val");
    debugPrint(currentMap + ": jump_height: " + getdvar("jump_height"), "val");

    switch (currentMap) {
        case "mp_fnrp_quake3_arena": // fixed in the map itself, leave fn for other maps.
            // jump_height is 350
/*            setdvar("bg_falldamagemaxheight", 750);
            setdvar("bg_falldamageminheight", 700);
            level.fallDamageMaxHeight = 750;
            level.fallDamageMinHeight = 700;*/
            break;
    }
}

getMaprotation()
{
    debugPrint("in _maps::getMaprotation()", "fn", level.lowVerbosity);

    level.currentmap = getdvar("mapname");

    level.maprotation = [];
    index = 0;
    dissect_sv_rotation = dissect(getdvar("sv_maprotation"));

    gametype = 0;
    map = 0;
    nextgametype = "";
    for (i=0; i<dissect_sv_rotation.size; i++)
    {
        if (!map)
        {
            if (dissect_sv_rotation[i] == "gametype")
            {
                gametype = 1;
                continue;
            }
            if (gametype)
            {
                gametype = 0;
                nextgametype = dissect_sv_rotation[i];
                continue;
            }
            if (dissect_sv_rotation[i] == "map")
            {
                map = 1;
                continue;
            }
        }
        else
        {
            //level.maprotation[index] = nextgametype;
            level.maprotation[index] = dissect_sv_rotation[i];
            nextgametype = "";
            index += 1;
            map  =0;
        }
    }
}

getNextMap()
{
    debugPrint("in _maps::getNextMap()", "fn", level.lowVerbosity);

    level.currentmap = getdvar("mapname");
    for (i=0; i<level.maprotation.size; i++)
    {
        if (tolower(level.maprotation[i]) == tolower(level.currentmap))
        {
            new_index = i+1;
            if (new_index >= level.maprotation.size)
            {
                new_index = new_index - level.maprotation.size;
            }
            return level.maprotation[new_index];
        }
    }
    if (level.maprotation.size>0)
    return level.maprotation[0];
    else
    return undefined;
}


/**
 * @brief Logs the players in the game when it ended
 * This let's us see who left the game before the server successfully restarted,
 * so we can warn or ban them for potentially hanging the server.
 *
 * @returns nothing
 */
logPlayersAtGameEnd()
{
    debugPrint("in _maps::logPlayersAtGameEnd()", "fn", level.nonVerbose);

    level endon("starting_map_change");

    flag = true;
    while(flag) {
        level waittill("game_ended");
        noticePrint("Players in the game when the game ended:");
        for (i=0; i<level.players.size; i++) {
            playerGuid = "";
            playerName = "";
            playerGuid = level.players[i].guid;
            playerName = level.players[i].name;

            noticePrint(playerGuid + ":" + playerName);
        }
        flag = false;
    }
}


changeMap(mapname)
{
    debugPrint("in _maps::changeMap()", "fn", level.nonVerbose);

    level notify("starting_map_change");
    /** @todo log all the players here(?): guid, name.  Then do the same when the
     * server starts, and look for players that left during server restart, then
     * ban them for behavior that can crash the server.
     */

    noticePrint("Changing map to " + mapname);
    // Don't change the map if there aren't any players (because we can't!!!)
    if (level.players.size < 1) {
        errorPrint("There are no players, so we can't change the map, as we depend on using a player's console to change the map.");
        map_restart(false);
        return;
    }

    serverRestartAttempts = 0;
    // Since the real rcon password has to be changed to allow a client to restart
    // the server, we always use the backup copy.  Basically, we treat rcon_password
    // as read/write, and rcon_password_backup as read-only.
    rconPassword = getdvar("rcon_password_backup");
    rconBackupPassword = getdvar("rcon_password_backup");

    if ((rconPassword == "") || (rconBackupPassword == "")) {
        errorPrint("You need to set rcon_password and rcon_password_backup in the server.cfg file for the server to run properly.");
        return;
    }

    // When a client executes the mapchange dvar using the temporary password, the
    // real rcon password will be reset from the temp password, the server will be killed,
    // and the (new) map will be started.
    setdvar("mapchange", "set rcon_password " + rconPassword + ";killserver;map " + mapname);

    // Force all the players to reconnect to the server
    for (i=0; i<level.players.size; i++) {
        level.players[i] setclientdvar("hastoreconnect", "1");
    }

    while(1) {
        // create and set a temporary rcon password
        tempPassword = "temp" + randomint(10000);
        setdvar("rcon_password", tempPassword);

        selectedPlayerGuid = "";
        selectedPlayerName = "";

        // randomly select one of the current players
        if (level.players.size == 1) { // If only one player, randomInt() will return an error
            playerIndex = 0;
        } else if (level.players.size > 1) {
            playerIndex = randomint(level.players.size - 1);
        } else {
            errorPrint("All players left the game before we could ask them to change the map, so we can't change the map");
            map_restart(false);
            // Restore rcon password from backup
            setdvar("rcon_password", rconBackupPassword);
            return;
        }

        selectedPlayerGuid = level.players[playerIndex].guid;
        selectedPlayerName = level.players[playerIndex].name;
        // TODO: GUYS WHAT THE FUCK?! Use "exec()" command.
        if (isdefined(level.players[playerIndex])) {
            // have that random player execute the commands to restart the
            // server and change the map
            noticePrint("Asking " + selectedPlayerName + ":" + selectedPlayerGuid + " to restart the server.");
            level.players[playerIndex] scripts\players\_players::execClientCommand("rcon login " + tempPassword + ";rcon vstr mapchange");
        } else {
            errorPrint("The selected player left the game after he was selected, but before he could restart the server.");
            errorPrint("The selected player was: " + selectedPlayerName + ":" + selectedPlayerGuid);
        }
        wait 1;

        // reset the real rcon password
        setdvar("rcon_password", rconBackupPassword);
        serverRestartAttempts++;

        // Log whether the rcon password was properly reset or not
        if (getdvar("rcon_password") != rconBackupPassword) {
            errorPrint("Your rcon password was not properly reset after server restart attempt " + serverRestartAttempts + ".");
        } else {
            noticePrint("Your rcon password was properly reset after restart attempt " + serverRestartAttempts + ".");
        }

        // give up after six (why six Bipo?) attempts
        if (serverRestartAttempts > 5) {
            errorPrint("Failed to restart the server after " + serverRestartAttempts + ".");
            map_restart(false);
            level notify("map_change_failed");
        }
    }
} // End function changeMap()

/**
 * @brief Continuouly animates a script_brushmodel animation spec'd in a map
 *
 * @param animation struct The animation to perform
 *
 * @returns nothing
 * @since RotU 2.2.3
 */
mapAnimation(animation)
{
    debugPrint("in _maps::mapAnimation()", "fn", level.nonVerbose);

    level endon("game_ended");

    if (animation.type == "linear") {
        while (1) {
            for (i=0; i<animation.steps.size; i++) {
                animation.model moveTo(animation.steps[i].destination, animation.steps[i].time);
                wait animation.steps[i].time;
                wait animation.steps[i].delay;
            }
            wait animation.delay;
            if (animation.reversible) {
                for (i=animation.steps.size - 1; i>=0; i--) {
                    animation.model moveTo(animation.steps[i].origin, animation.steps[i].time);
                    wait animation.steps[i].time;
                    wait animation.steps[i].delay;
                }
                wait animation.delay;
            }
        }
    } else if (animation.type == "rotate") {
        while (1) {
            /// @todo implement rotating cyclical animations
        }
    }
}

/**
 * @brief Initiates a glide when a player trips the trigger
 *
 * @param pad struct The pad to watch for trigger events
 *
 * @returns nothing
 * @since RotU 2.2.3
 */
watchGlidePad(pad)
{
    debugPrint("in _maps::watchGlidePad()", "fn", level.nonVerbose);

    while (1) {
        self waittill("trigger", player);

        pad thread glidePlayer(player);
        wait 0.05;
    }
}

/**
 * @brief Moves a player along a glide path
 *
 * @param player entity The player to move
 *
 * @returns nothing
 * @since RotU 2.2.3
 */
glidePlayer(player)
{
    debugPrint("in _maps::glidePlayer()", "fn", level.nonVerbose);

    // self is the pad
    player setOrigin(self.origin1);
    mover = spawn("script_origin", player.origin);
    player linkTo(mover);

    if (isDefined(self.time12)) {
        mover moveTo(self.origin2, self.time12);
        wait self.time12;
    }
    if (isDefined(self.time23)) {
        mover moveTo(self.origin3, self.time23);
        wait self.time23;
    }
    if (isDefined(self.time34)) {
        mover moveTo(self.origin4, self.time34);
        wait self.time34;
    }
    if (isDefined(self.time45)) {
        mover moveTo(self.origin5, self.time45);
        wait self.time45;
    }
    if (isDefined(self.time56)) {
        mover moveTo(self.origin6, self.time56);
        wait self.time56;
    }
    player unlink();
    mover delete();
}

/**
 * @brief Operates elevators
 *
 * @param elevator struct The elevator to operate
 *
 * @returns nothing
 * @since RotU 2.2.3
 */
watchElevatorTrigger(elevator)
{
    debugPrint("in _maps::watchElevatorTrigger()", "fn", level.nonVerbose);

    while (1) {
        self waittill("trigger", player);

        if (self.targetname == elevator.triggers[0].targetname) {
            // call for elevator at trigger
            if (elevator.model.origin == elevator.positionA) {
                // elevator is already there, so user wants to go to positionB
                elevator.model moveTo(elevator.positionB, elevator.time);
                wait elevator.time;
            } else {
                // elevator first needs to come to positionA
                elevator.model moveTo(elevator.positionA, elevator.time);
                wait elevator.time;
                continue; // wait for next trigger event
            }
        }
        wait 0.05;
    }
}

/**
 * @brief Operates a built-in teleporter
 *
 * @param mapTeleporter struct The teleporter to operate
 *
 * @returns nothing
 * @since RotU 2.2.3
 */
watchMapTeleporters(mapTeleporter)
{
    debugPrint("in _maps::watchMapTeleporters()", "fn", level.nonVerbose);

    while (1) {
        self waittill("trigger", player);

        player setOrigin(mapTeleporter.destination);
        wait 0.05;
    }
}

/**
 * @brief Watches hurt triggers and teleports player to spawnpoint when triggered
 *
 * @param trigger struct The hurt trigger to watch
 *
 * @returns nothing
 * @since RotU 2.2.3
 */
watchHurtTriggers(trigger)
{
    debugPrint("in _maps::watchHurtTriggers()", "fn", level.nonVerbose);

    while (1) {
        self waittill("trigger", player);

        if (self.origin != trigger.origin) {
            // not the trigger we are waiting for
            wait 0.05;
            continue;
        }

        if ((isDefined(player.isActive)) && (isDefined(player.isAlive)) &&
            (player.isActive) && (player.isAlive))
        {
            player setOrigin(player.originalSpawnLocation);
            player thread hurtPlayer();
            wait 0.05;
        } else {
            // not actually a human player
            wait 0.05;
        }
    }
}

/**
 * @brief Downs a player after they have triggered a hurt trigger and been teleported
 *
 * @returns nothing
 * @since RotU 2.2.3
 */
hurtPlayer()
{
    debugPrint("in _maps::hurtPlayer()", "fn", level.nonVerbose);

    interval = 1;
    damage = 65;
    self.isPlayer = true;
    while ((!self.isDown)) {
        self [[level.callbackPlayerDamage]] (self, self, damage, 0, "MOD_EXPLOSIVE", "none", self.origin, (0,0,0), "none", 0);
        wait interval;
    }
}
