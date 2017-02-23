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

#include scripts\include\data;
#include scripts\include\utility;
#include scripts\include\hud;
#include scripts\include\entities;

init()
{
    debugPrint("in _usables::init()", "fn", level.nonVerbose);

    precache();

    level.useObjects = [];
    thread debugUsables();
}

precache()
{
    precacheString(&"ROTUSCRIPT_INFECTION_CURED_BY");
    precacheString(&"ROTUSCRIPT_GOT_REVIVED_BY");
    precacheString(&"ROTUSCRIPT_GOT_COVERED_BY");
}

debugUsables()
{
    debugPrint("in _usables::debugUsables()", "fn", level.nonVerbose);

    wait 10;
    useObjects = level.useObjects;
    for (i = 0; i < useObjects.size; i++)
    {
        if ((useObjects[i].type == "extras") ||
            (useObjects[i].type == "ammobox"))
        {
        }
    }
}

addUsable(ent, type, hintstring, distance)
{
    debugPrint("in _usables::addUsable()", "fn", level.veryLowVerbosity);

    self.useObjects[self.useObjects.size] = ent;
    ent.occupied = false;
    ent.type = type;
    ent.hintstring = hintstring;
    if (isdefined(distance))
    {
        ent.distance = distance;
    }
    else
    {
        ent.distance = 96;
    }

    if (ent.type == "revive")
    {
        debugPrint("Added revive usable to: " + ent.name, "val");
    }
}

removeUsable(ent)
{
    debugPrint("in _usables::removeUsable()", "fn", level.lowVerbosity);

    for (i = 0; i < level.players.size; i++)
    {
        player = level.players[i];
        if (isdefined(player.curEnt))
        {
            if (player.curEnt == ent)
            {
                player usableAbort();
                player.curEnt = undefined;
            }
        }
    }

    self.useObjects = removeFromArray(self.useObjects, ent);
    if ((isDefined(ent.isPlayer)) && (ent.isPlayer))
    {
        debugPrint("Finished removing usables from: " + ent.name, "val");
    }
}

checkForUsableObjects()
{
    debugPrint("in _usables::checkForUsableObjects()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");
    self endon("downed");
    self endon("spawned"); // end this instance before a respawn

    self.curEnt = undefined;
    hasPressedF = false;
    isUsing = false;

    while (1)
    {
        // Don't let the player use this usable if they aren't allowed to use it
        if (!self.canUse)
        {
            //             debugPrint(self.name + " can't use this " + self.curEnt.type + " usable, aborting.", "val");
            self usableAbort();
            wait .1;
            continue;
        }
        // If player isn't near a usable, try to find a usable
        if (!isdefined(self.curEnt))
        {
            //             debugPrint(self.name + " self.curEnt is undefined", "val");
            /// @bug: unreviveable: seems to be self.curEnt is undefined, and getBetterUseObj(1024)
            /// is not finding the revive usable
            if (self.isBusy)
            {
                self.isBusy = false;
            }

            if (getBetterUseObj(1024))
            {
                //                 debugPrint(self.name + " Found a better use object: 1024", "val");
                continue;
            }
            wait .2;
        }
        else
        {
            // player is near a usable
            /*            if (self.curEnt.type == 1) {
                debugPrint("entity type '1' bug, name: " + self.name, "val");
                debugPrint("entity type '1' bug, hintstring: " + self.curEnt.hintstring, "val");
            }*/
            log = false;
            if (self.curEnt.type == "revive")
            {
                //log = true;
            }
            if (log)
            {
                debugPrint(self.name + "'s current usable entity is of type: " + self.curEnt.type, "val");
            }
            dis = distance(self.origin, self.curEnt.origin);
            if (log)
            {
                debugPrint("distance between " + self.name + " and usable origin is: " + dis, "val");
            }
            if (!self.isBusy)
            {
                if (log)
                {
                    debugPrint(self.name + " is not busy", "val");
                }
                if (self.curEnt.occupied)
                {
                    // another player is using this usable
                    if (log)
                    {
                        debugPrint("The " + self.curEnt.type + " usable is occupied", "val");
                    }
                    self.curEnt = undefined;
                    self setclientdvar("ui_hintstring", "");
                    continue;
                }
                if (getBetterUseObj(dis))
                {
                    if (log)
                    {
                        debugPrint("Found a better usable object within " + dis + " of type: " + self.curEnt.type, "val");
                    }
                    continue;
                }
            }
            // Is the player within range of this usable?
            if (dis <= self.curEnt.distance)
            {
                if (log)
                {
                    debugPrint(self.name + " dis: " + dis + " is <= self.curEnt.distance: " + self.curEnt.distance, "val");
                }
                if (log)
                {
                    debugPrint(self.name + " is within range of the usable of type: " + self.curEnt.type, "val");
                }

                /// @bug Attempt to solve the unrevivable bug--doesn't seem to be the issue
                // Ensure the UI hintstring is properly set
                if ((self.curEnt.type == "revive") && (self.curEnt.hintstring != &"ROTUSCRIPT_HOLD_USE_TO_REVIVE"))
                {
                    errorPrint("Revive hintstring was incorrect; correcting.");
                    // correct for this player
                    self.curEnt.hintstring = &"ROTUSCRIPT_HOLD_USE_TO_REVIVE";
                    self setclientdvar("ui_hintstring", self.curEnt.hintstring);
                    // correct for the level
                    for (i = 0; i < level.useObjects.size; i++)
                    {
                        if (level.useObjects[i] == self.curEnt)
                        {
                            level.useObjects[i].hintstring = &"ROTUSCRIPT_HOLD_USE_TO_REVIVE";
                            break;
                        }
                    }
                }
                if (self useButtonPressed())
                {
                    if (hasPressedF == false && self isOnGround() && !self.curEnt.occupied)
                    {
                        self thread usableUse();
                        hasPressedF = true;
                    }
                }
                else
                {
                    if (hasPressedF == true)
                    {
                        self usableAbort();
                        hasPressedF = false;
                    }
                }
            }
            else
            {
                if (log)
                {
                    debugPrint(self.name + " is NOT within range of the usable of type: " + self.curEnt.type, "val");
                }
                if (log)
                {
                    debugPrint("dis: " + dis + " is > self.curEnt.distance: " + self.curEnt.distance + ", Aborting", "val");
                }
                self usableAbort();
            }
            wait .05;
        }
    }
}

watchUsablesData()
{
    debugPrint("in _usables::watchUsablesData()", "fn", level.lowVerbosity);

    while (!isDefined(level.players))
    {
        debugPrint("Waiting for level.players to be defined", "val");
        wait 2;
    }

    player = undefined;

    // <debug>
    taffJoined = false;
    while (!taffJoined)
    {
        debugPrint("Waiting for taff to join", "val");
        player = scripts\include\adminCommon::getPlayerByShortGuid("dcf4d9e5"); // taff
        if (isDefined(player))
        {
            taffJoined = true;
            break;
        }
        else
        {
            wait 3;
        }
    }

    player thread printPlayerUsablesData();
    player endon("disconnect");

    while (1)
    {
        wait 45;
        player printLevelUsablesData();
    }
    // </debug>
}

printLevelUsablesData()
{
    debugPrint("in _usables::printLevelUsablesData()", "fn", level.lowVerbosity);

    if (level.useObjects.size == 0)
    {
        return;
    }
    header = "name           canUse isPlayer  occupied   origin                range   type        hintstring";
    debugPrint(header, "val");
    for (i = 0; i < level.useObjects.size; i++)
    {
        ent = level.useObjects[i];
        canUse = self canUseObj(ent);
        isPlayer = isPlayer(ent);
        occupied = ent.occupied;
        entOrigin = ent.origin;
        /*        self.origin = self.origin;
        distance = distance(self.origin, ent.origin);*/
        if (isDefined(ent.name))
        {
            name = ent.name;
        }
        else
        {
            name = "undefined";
        }
        if (isDefined(ent.type))
        {
            type = ent.type;
        }
        else
        {
            type = "undefined";
        }
        if (isDefined(ent.hintstring))
        {
            hintstring = ent.hintstring;
        }
        else
        {
            hintstring = "undefined";
        }
        if (isDefined(ent.distance))
        {
            range = ent.distance;
        }
        else
        {
            range = "undefined";
        }
        line = name + " \t" + canUse + " \t" + isPlayer + " \t" + occupied + " \t" + entOrigin + " \t\t" + range + " \t" + type + " \t" + hintstring;
        debugPrint(line, "val");
    }
}

printPlayerUsablesData()
{
    debugPrint("in _usables::printPlayerUsablesData()", "fn", level.lowVerbosity);
    self endon("disconnect");

    while (1)
    {
        wait 2;
        //         debugPrint("Checking self.useObjects.size", "val");
        if (self.useObjects.size == 0)
        {
            continue;
        }
        debugPrint("Checking self.shortGuid", "val");
        if (self.shortGuid != "dcf4d9e5")
        {
            continue;
        } // only for taff
        header = "playerName   name           canUse isPlayer  occupied   origin                range   distance   type        hintstring";
        debugPrint(header, "val");
        for (i = 0; i < self.useObjects.size; i++)
        {
            ent = self.useObjects[i];
            canUse = self canUseObj(ent);
            isPlayer = isPlayer(ent);
            occupied = ent.occupied;
            entOrigin = ent.origin;
            selfOrigin = self.origin;
            distance = distance(self.origin, ent.origin);
            if (isDefined(ent.name))
            {
                name = ent.name;
            }
            else
            {
                name = "undefined";
            }
            if (isDefined(ent.type))
            {
                type = ent.type;
            }
            else
            {
                type = "undefined";
            }
            if (isDefined(ent.hintstring))
            {
                hintstring = ent.hintstring;
            }
            else
            {
                hintstring = "undefined";
            }
            if (isDefined(ent.distance))
            {
                range = ent.distance;
            }
            else
            {
                range = "undefined";
            }
            line = self.name + " \t" + name + " \t" + canUse + " \t" + isPlayer + " \t" + occupied + " \t" + entOrigin + " \t\t" + range + " \t" + distance + " \t" + type + " \t" + hintstring;
            debugPrint(line, "val");
        }
    }
}

getBetterUseObj(distance)
{
    // 15th most-called function (1% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    foundEnt = 0;

    // self is the player running around

    /// @todo need to re-write this function for clarity and to fix logic errors

    // search for better usable objects in the level array
    for (i = 0; i < level.useObjects.size; i++)
    {
        /// @todo need a debugEntity() to print entity info for debugging
        ent = level.useObjects[i];
        if (!canUseObj(ent))
        {
            continue;
        }
        if ((foundEnt == 1) && (!isplayer(ent)))
        {
            continue;
        }
        dis = distance(self.origin, ent.origin);
        if (dis <= ent.distance && !ent.occupied && dis < distance)
        {
            self setclientdvar("ui_hintstring", ent.hintstring);
            self.curEnt = ent;
            foundEnt = 1;
        }
    }
    if (foundEnt)
    {
        //         debugPrint("Found better level usable", "val");
        return 1;
    }

    // search for better usable objects in the players own array
    for (i = 0; i < self.useObjects.size; i++)
    {
        ent = self.useObjects[i];
        dis = distance(self.origin, ent.origin);
        if (dis <= ent.distance && !ent.occupied && dis < distance)
        {
            self setclientdvar("ui_hintstring", ent.hintstring);
            self.curEnt = ent;
            //             debugPrint("Found better player usable", "val");
            return 1;
        }
    }
    return 0;
}

canUseObj(obj)
{
    // 3rd most-called function (13% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    if (obj == self)
    {
        return 0;
    }
    if (!isDefined(obj.type))
    {
        /// @bug somehow, we are getting objects with no .type property!
        errorPrint("Usable object has no type! Printing current usables.");
        printLevelUsablesData();
        printPlayerUsablesData();
        return 0;
    }
    if (obj.type == "infected" && !self.canCure)
    {
        return 0;
    }
    else if (obj.type == "turret")
    {
        if ((!isDefined(obj.gun.owner)) || (self != obj.gun.owner))
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }

    return 1;
}

usableUse()
{
    debugPrint("in _usables::usableUse()", "fn", level.lowVerbosity);

    self setclientdvar("ui_hintstring", "");
    if (isdefined(self.curEnt))
    {
        if (!canUseObj(self.curEnt))
        {
            self usableAbort();
            return;
        }
        self notify("used_usable");
        switch (self.curEnt.type)
        {
        case "revive":
            self.curEnt.occupied = true;
            self.isBusy = true;
            self.curEnt setclientdvar("ui_reviveby", self.name);
            self freezecontrols(1);
            self disableWeapons();
            self progressBar(self.revivetime);
            self thread reviveInTime(self.revivetime, self.curEnt);
            break;
        case "infected":
            if (!self.curEnt.isDown)
            {
                iprintln(&"ROTUSCRIPT_INFECTION_CURED_BY", self.curEnt.name, self.name);
                self.curEnt scripts\players\_infection::cureInfection();
                self scripts\players\_players::incUpgradePoints(20 * level.dvar["game_rewardscale"]);
                self thread scripts\players\_rank::giveRankXP("revive");
            }

            break;
        case "weaponpickup":
            self scripts\players\_weapons::swapWeapons(self.curEnt.wep_type, self.curEnt.myWeapon);
            break;
        case "objective":
            level notify("obj_used" + self.curEnt.usable_obj_id);
            break;
        case "extras": // shop
            self setclientdvar("ui_points", self.points);
            self closeMenu();
            self closeInGameMenu();
            self openMenu(game["menu_extras"]);
            break;
        case "teleporter":
            if (level.teleporter.size > 1)
            {
                index = randomint(level.teleporter.size - 1);
                ent = level.teleporter[index];
                if (ent == self.curEnt)
                    ent = level.teleporter[index + 1];
                self thread scripts\players\_teleporter::teleOut(self.curEnt, ent.origin, ent.angles);
            }
            else
            {
                ent = getRandomTdmSpawn();
                self thread scripts\players\_teleporter::teleOut(self.curEnt, ent.origin, ent.angles);
            }

            break;
        case "ammobox": // weapons crate
            if (level.ammoStockType == "ammo")
            {
                self.isBusy = true;
                self freezecontrols(1);
                self disableWeapons();
                self progressBar(self.curEnt.loadtime);
                self thread ammoInTime(self.curEnt.loadtime);
            }
            if (level.ammoStockType == "upgrade")
            {
                wep = self getcurrentWeapon();
                if (wep == self.primary)
                    scripts\gamemodes\_upgradables::doUpgrade("primary");
                if (wep == self.secondary)
                    scripts\gamemodes\_upgradables::doUpgrade("secondary");
                if (wep == self.extra)
                    scripts\gamemodes\_upgradables::doUpgrade("extra");
            }
            if (level.ammoStockType == "weapon")
            {
                if (!isdefined(self.box_weapon))
                {
                    if (self.points >= level.dvar["surv_waw_costs"])
                    {
                        if (level.dvar["surv_waw_alwayspay"])
                            self scripts\players\_players::incUpgradePoints(-1 * level.dvar["surv_waw_costs"]);
                        scripts\gamemodes\_mysterybox::mystery_box(self.curEnt);
                    }
                }
                else
                {
                    if (self.box_weapon.done)
                    {
                        self scripts\players\_weapons::swapWeapons(self.box_weapon.slot, self.box_weapon.weaponName);
                        self.box_weapon delete ();
                        if (!level.dvar["surv_waw_alwayspay"])
                            self scripts\players\_players::incUpgradePoints(-1 * level.dvar["surv_waw_costs"]);
                    }
                }
            }
            break;
        case "barricade":
            self.isBusy = true;
            self freezecontrols(1);
            self disableWeapons();
            self progressBar(1);
            self thread restoreBarricadeInTime(1);
            break;
        case "turret":
            self scripts\players\_turrets::moveDefenseTurret(self.curEnt);
            break;
        case "equipmentShop":
            self maps\mp\_umiEditor::devMoveEquipmentShop(self.curEnt);
            break;
        case "weaponsShop":
            self maps\mp\_umiEditor::devMoveWeaponShop(self.curEnt);
            break;
        case "waypoint":
            self maps\mp\_umiEditor::devMoveWaypoint(self.curEnt);
            break;
        }
    }
}

usableAbort()
{
    debugPrint("in _usables::usableAbort()", "fn", level.absurdVerbosity);

    self notify("usable_abort");
    self setclientdvar("ui_hintstring", "");
    if (isdefined(self.curEnt))
    {
        switch (self.curEnt.type)
        {
        case "revive":
            self.isBusy = false;
            self.isReviving = false;
            self.curEnt setclientdvar("ui_reviveby", "");
            self.curEnt.occupied = false;
            self freezecontrols(0);
            self EnableWeapons();
            self destroyProgressBar();
            break;
        case "ammobox":
            if (level.ammoStockType == "ammo")
            {
                self.isBusy = false;
                self freezecontrols(0);
                self EnableWeapons();
                self destroyProgressBar();
            }
            break;
        case "barricade":
            self.isBusy = false;
            self freezecontrols(0);
            self EnableWeapons();
            self destroyProgressBar();
            break;
        }
        self.curEnt = undefined;
    }
}

restoreBarricadeInTime(time)
{
    debugPrint("in _usables::restoreBarricadeInTime()", "fn", level.lowVerbosity);

    self endon("death");
    self endon("disconnect");
    self endon("usable_abort");
    wait time;

    self thread restoreBarricade();

    self thread usableAbort();
}

restoreBarricade()
{
    debugPrint("in _usables::restoreBarricade()", "fn", level.lowVerbosity);

    if (self.curEnt scripts\players\_barricades::restorePart())
        self scripts\players\_players::incUpgradePoints(3 * level.dvar["game_rewardscale"]);
}

reviveInTime(time, player)
{
    debugPrint("in _usables::reviveInTime()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");
    self endon("usable_abort");
    // self is the reviver
    self.isReviving = true;
    wait 1.25;
    covering = self coveringPlayers();
    wait time - 1.25;

    self thread finishRevive(player, covering);
}

coveringPlayers()
{
    debugPrint("in _usables::coveringPlayers()", "fn", level.nonVerbose);

    players = level.players;
    index = 0;
    covering = [];
    for (i = 0; i < players.size; i++)
    {
        if ((players[i].isAlive) &&
            (distance(self.origin, players[i].origin) < 144) &&
            (self.name != players[i].name)) // &&
                                            //             (!self.isBusy))
                                            //             (!self.isReviving))
        {
            covering[index] = players[i] getEntityNumber();
            index++;
        }
    }
    return covering;
}

finishRevive(player, startCovering)
{
    debugPrint("in _usables::finishRevive()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");
    self destroyProgressBar();
    self freezecontrols(0);
    if (isdefined(player) && isalive(player))
    {
        endCovering = self coveringPlayers();
        player thread scripts\players\_players::revive();
        player notify("damage", 0);
        iprintln(&"ROTUSCRIPT_GOT_REVIVED_BY", player.name, self.name);
        player setclientdvar("ui_reviveby", "");
        player.lastUpTime = getTime();

        self thread scripts\players\_rank::giveRankXP("revive");
        self scripts\players\_players::incUpgradePoints(40 * level.dvar["game_rewardscale"]);
        self scripts\players\_abilities::rechargeSpecial(15);
        self.reviveCount++;

        // No credit for covering during wave intermission
        if (level.waveIntermission)
        {
            self.intermissionReviveCount++;
        }
        else
        {
            for (i = 0; i < startCovering.size; i++)
            {
                for (j = 0; j < endCovering.size; j++)
                {
                    if (startCovering[i] == endCovering[j])
                    {
                        // this player covered during the revive, give them credit for it
                        coveringPlayer = scripts\include\adminCommon::getPlayerByEntityNumber(startCovering[i]);
                        debugPrint(coveringPlayer.name + " covered the revival of " + player.name, "val");
                        coveringPlayer thread scripts\players\_rank::giveRankXP("revive_cover");
                        coveringPlayer scripts\players\_players::incUpgradePoints(30 * level.dvar["game_rewardscale"]);
                        coveringPlayer scripts\players\_abilities::rechargeSpecial(10);
                        coveringPlayer.reviveCoverCount++;
                        iprintln(&"ROTUSCRIPT_GOT_COVERED_BY", coveringPlayer.name, player.name);
                    }
                }
            }
        }
    }
    self.isReviving = false;
    wait .5;
    self EnableWeapons();
    self thread usableAbort();
}

ammoInTime(time)
{
    debugPrint("in _usables::ammoInTime()", "fn", level.lowVerbosity);

    self endon("death");
    self endon("disconnect");
    self endon("usable_abort");
    wait time;

    self destroyProgressBar();
    self freezecontrols(0);
    weaponsList = self GetWeaponsList();
    for (idx = 0; idx < weaponsList.size; idx++)
    {
        if (weaponsList[idx] == "claymore_mp")
        {
            continue;
        }
        if (weaponsList[idx] == "tnt_mp")
        {
            continue;
        }
        if (weaponsList[idx] == "c4_mp")
        {
            continue;
        }
        if (weaponsList[idx] == "frag_grenade_mp")
        {
            continue;
        }

        self giveMaxAmmo(weaponsList[idx]);
    }
    wait .5;
    self EnableWeapons();
}
