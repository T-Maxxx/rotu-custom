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
#include scripts\include\strings;

init()
{
    debugPrint("in _classes::init()", "fn", level.nonVerbose);

    precache();

    level.player_stat_rank["soldier"] = 430;
    level.player_stat_rank["stealth"] = 431;
    level.player_stat_rank["armored"] = 432;
    level.player_stat_rank["engineer"] = 433;
    level.player_stat_rank["scout"] = 434;
    level.player_stat_rank["medic"] = 435;
}

precache()
{
    precacheString(&"ROTUSCRIPT_AVAILABLE_SKILLPOINTS");
    precacheString(&"ROTUSCRIPT_CLASS_NOT_AVAIL");
    precacheString(&"ROTUSCRIPT_ADMIN_OVERRIDE_REJOIN");
    precacheString(&"ROTUSCRIPT_WILL_SPAWN_AFTER_WAVE");
    precacheString(&"ROTUSCRIPT_ADMIN_OVERRIDE_DEAD");
    precacheString(&"ROTUSCRIPT_WILL_SPAWN_NEED_MORE");
    precacheString(&"ROTUSCRIPT_NOT_ENOUGH_UP_CHANGE_CLASS");
    precacheString(&"ROTUSCRIPT_CANT_CHANGE_CLASS_WHEN_ZOM_DOWN");
    precacheString(&"ROTUSCRIPT_PICK_CLASS");
}

getSkillpoints(rank)
{
    debugPrint("in _classes::getSkillpoints()", "fn", level.nonVerbose);

    modRank = rank + 110 * self.pers["prestige"];
    if (!level.dvar["game_class_ranks"]) {
        self.skillpoints = 0;
        self skillPointsNotify(self.skillpoints);
        self setclientdvar("ui_skillpoints", self.skillpoints);
        return;
    }
    self.rank["soldier"] = self getstat(level.player_stat_rank["soldier"]);
    wait 0.05;
    self.rank["stealth"] = self getstat(level.player_stat_rank["stealth"]);
    wait 0.05;
    self.rank["medic"] = self getstat(level.player_stat_rank["medic"]);
    wait 0.05;
    self.rank["scout"] = self getstat(level.player_stat_rank["scout"]);
    wait 0.05;
    self.rank["armored"] = self getstat(level.player_stat_rank["armored"]);
    wait 0.05;
    self.rank["engineer"] = self getstat(level.player_stat_rank["engineer"]);

    self.skillpoints = 0;
    spent  = self.rank["soldier"] + self.rank["stealth"] + self.rank["medic"];
    spent += self.rank["scout"] + self.rank["armored"] + self.rank["engineer"];

    earned = modRank * 2;
    self.skillpoints = earned - spent;
    if (self.rankHacker) {self.skillpoints = 0;}
    if (modRank * 2 > 174) {self.skillpoints = 174 - spent;}

    // When new players get demoted, they may have spent more skillpoints than
    // their new lower rank qualifies them for.  We don't un-spend their skillpoints,
    // we just set available skillpoints to zero until they have been promoted
    // enough to actually earn new skillpoints. This also ensures the skillpoints
    // menu functions properly
    if (self.skillpoints < 0) {self.skillpoints = 0;}

    self skillPointsNotify(self.skillpoints);
    self setclientdvar("ui_skillpoints", self.skillpoints);
}

/**
 * @brief Notifies a player when they have skillpoints to spend
 *
 * @param points integer The number of skillpoints the player has available to spend
 *
 * @returns nothing
 */
skillPointsNotify(points)
{
    debugPrint("in _classes::skillPointsNotify()", "fn", level.nonVerbose);

    if (points > 0) {
        if (!isdefined(self.skillPointsHud)) {
            self.skillPointsHud = newClientHudElem(self);
            self.skillPointsHud.elemType = "font";
            self.skillPointsHud.font = "default";
            self.skillPointsHud.fontscale = 1.6;
            self.skillPointsHud.x = 6;
            self.skillPointsHud.y = 420;
            self.skillPointsHud.color = (1, 0.8, 0.4);
            self.skillPointsHud.glowAlpha = 0;
            self.skillPointsHud.hideWhenInMenu = true;
            self.skillPointsHud.archived = false;
            self.skillPointsHud.alignX = "center";
            self.skillPointsHud.alignY = "middle";
            self.skillPointsHud.horzAlign = "center";
            self.skillPointsHud.vertAlign = "top";
            self.skillPointsHud.alpha = 1;
            self.skillPointsHud.label = &"ROTUSCRIPT_AVAILABLE_SKILLPOINTS";
        }
        self.skillPointsHud setValue(points);
    } else {
        if (isdefined(self.skillPointsHud))
        self.skillPointsHud destroy();
    }
}

increaseClassRank(type)
{
    debugPrint("in _classes::increaseClassRank()", "fn", level.nonVerbose);

    if (!level.dvar["game_class_ranks"]) {return ;}

    if (self.skillpoints > 0) {
        newrank = self.rank[type] + 1;
        if (isdefined(newrank) && newrank < 30) {
            self.rank[type] = newrank;
            self.skillpoints -= 1;
            self skillPointsNotify(self.skillpoints);
            self setclientdvar("ui_skillpoints", self.skillpoints);
            self setstat(level.player_stat_rank[type], newrank);
        }
    }
}

/**
 * @brief When a class is picked in the UI, sets class properties and opens abilities menu
 *
 * @param class string The player's chosen class
 *
 * @returns nothing
 */
pickClass(class)
{
    debugPrint("in _classes::pickClass()", "fn", level.nonVerbose);

    // The class they chose isn't enabled anymore.  Update UI, have them pick another
    if(!isClassEnabled(class)) {
        enableClasses();
        self iprintlnbold(&"ROTUSCRIPT_CLASS_NOT_AVAIL");
        return;
    }

    if (isValidClass(class)) {
        self setclientdvars("ui_class_rank", level.player_stat_rank[class]);
        self.class = class;
        self.pers["class"] = class;
        self setclientdvar("ui_loadout_class", class);
        self setclientdvar("ui_secondary_ability", "@ROTUUI_NONE");
        self setclientdvar("ui_secondary_ability_4", 0);
        self setclientdvar("ui_secondary_ability_5", 0);
        self openMenu(game["menu_changeclass_ability"]);
        self.secondaryAbility = "none";
    }
}


/**
 * @brief Is this a valid game class?
 *
 * @param class string A game class to check for validity
 *
 * @returns boolean indicating whether \c class is a valid game class
 */
isValidClass(class)
{
    debugPrint("in _classes::isValidClass()", "fn", level.nonVerbose);

    if ((class == "soldier") || (class == "stealth") || (class == "armored") ||
        (class == "scout") || (class == "medic") || (class == "engineer"))
    {
        return true;
    }
    return false;
}


/**
 * @brief Is this class enabled?
 *
 * @param class string The game class to check if it is enabled
 *
 * @returns boolean indicating whether \c class is enabled
 */
isClassEnabled(class)
{
    debugPrint("in _classes::isClassEnabled()", "fn", level.medVerbosity);

    // Admin can always be any class
    if (scripts\server\_adminInterface::isAdmin(self)) {return true;}

    // Ensure at least 40% of players are either soldiers, scouts, or armored,
    // when there are at least 7 players in the game
    constraintSatisfied = false;
    constraint = getClassPlayerCount("soldier") + getClassPlayerCount("armored") + getClassPlayerCount("scout");
    if ((constraint > int(level.activePlayers * 0.40)) ||
        (level.activePlayers <= 6)) {
        constraintSatisfied = true;
    }

    switch(class) {
        // No limit on number of soldiers, scouts, and armored
        case "soldier":         // Fall through
        case "armored":         // Fall through
        case "scout":
            return true;
        // Stealth, medics, and engineers are limited to 15% of active players, plus 1,
        // or a minimum limit of 2
        case "stealth":
            if(!constraintSatisfied) {return false;}
            if ((getClassPlayerCount("stealth") < int(level.activePlayers * 0.20) + 1) ||
                (getClassPlayerCount("stealth") <= 2))
            {
                return true;
            }
            break;
        case "medic":
            if(!constraintSatisfied) {return false;}
            if ((getClassPlayerCount("medic") < int(level.activePlayers * 0.20) + 1) ||
                (getClassPlayerCount("medic") <= 2))
            {
                return true;
            }
            break;
        case "engineer":
            if(!constraintSatisfied) {return false;}
            if ((getClassPlayerCount("engineer") < int(level.activePlayers * 0.20) + 1) ||
                (getClassPlayerCount("engineer") <= 2))
            {
                return true;
            }
    }
    return false;
}

/**
 * @brief Counts the number of each class currently in the game
 *
 * @param class string The game class to count
 *
 * @returns integer The number of players with this \c class
 */
getClassPlayerCount(class)
{
    debugPrint("in _classes::getClassPlayerCount()", "fn", level.medVerbosity);

    players = level.players;
    count = 0;
    for(i=0; i<players.size; i++) {
        if (players[i].curClass != class) {continue;}
        count++;
    }
    return count;
}

/**
 * @brief Enables/disables certain classes in the choose class menu
 *
 * @returns nothing
 */
enableClasses()
{
    debugPrint("in _classes::enableClasses()", "fn", level.veryLowVerbosity);

    if (!isDefined(self)) {return;}

    if (self isClassEnabled("stealth")) {self setclientdvar("stealth_enabled", 1);}
    else {self setclientdvar("stealth_enabled", 0);}

    if (self isClassEnabled("medic")) {self setclientdvar("medic_enabled", 1);}
    else {self setclientdvar("medic_enabled", 0);}

    if (self isClassEnabled("engineer")) {self setclientdvar("engineer_enabled", 1);}
    else {self setclientdvar("engineer_enabled", 0);}
}

/**
 * @brief Monitors the number of each class in the game and updates the choose class menu
 *
 * @returns nothing
 */
monitorEnabledClasses()
{
    debugPrint("in _classes::monitorEnabledClasses()", "fn", level.nonVerbose);

    self endon("menu_changeclass_allies_closed");
    self endon("disconnect");

    while (1) {
        enableClasses();
        wait 3;
    }
}


pickSecondary(ability)
{
    debugPrint("in _classes::pickSecondary()", "fn", level.nonVerbose);

    if (self.class != "none") {
        rank = self getClassRank(self.class);
        if (scripts\players\_abilities::isAbilityAllowed(self.class, rank, "SC", ability)) {
            self.secondaryAbility = ability;
            self setclientdvar("ui_secondary_ability", "@ABILITIES_" + toUpper(self.class) + "_SC_" + ability);
        }
    }
}

/**
 * @brief Accepts a player's choice of class and begins the spawning process
 *
 * @param forceSpawn boolean Whether to ovverride spawning restrictions.  Used only
 *                           for _adminCommands::spawnPlayer().
 *
 * @returns nothing
 */
acceptClass(forceSpawn)
{
    debugPrint("in _classes::acceptClass()", "fn", level.nonVerbose);

    if (!isDefined(forceSpawn)) {forceSpawn = false;}

    // The class they chose isn't enabled anymore.  Update UI, have them pick another
    if(!isClassEnabled(self.class)) {
        enableClasses();
        self iprintlnbold(&"ROTUSCRIPT_CLASS_NOT_AVAIL");
        return;
    }

    // for _adminCommands::spawnPlayer() command
    if (forceSpawn) {
        self.curClass = self.class;
        self setclientdvar("ui_loadout_class", self.curClass);
        self.mayRespawn = true;
        self thread scripts\players\_players::joinAllies();
        self thread scripts\players\_players::spawnPlayer();
        self closeMenu();
        self closeInGameMenu();
        self notify("menu_changeclass_allies_closed");
        return;
    }

    if (self.class != "none") {
        self closeMenu();
        self closeInGameMenu();

        // Is the player trying to change their class?
        self.isChangingClass = false;
        if ((self.spawnCount > 0) && (isDefined(self.curClass)) && (self.class != self.curClass)) {
            self.isChangingClass = true;
        }

        if ((self.hasPreviouslyJoined) && (self.spawnCount == 0)) {
            // The player has previously connected, then 'left' the game, is
            // now back, and has never spawned this session
            if (level.waveIntermission) {
                /// spawn player
                debugPrint(self.name + " has rejoined game for first time, spawning now", "val");
                self thread scripts\players\_players::joinAllies();
                self thread scripts\players\_players::spawnPlayer();
                self notify("menu_changeclass_allies_closed");
                return;
            } else {
                if (scripts\server\_adminInterface::isAdmin(self)) {
                    // Player is an admin
                    /// spawn player
                    self iprintlnbold(&"ROTUSCRIPT_ADMIN_OVERRIDE_REJOIN");
                    debugPrint(self.name + " has rejoined game, has never spawned, mid-wave, admin override, spawning now", "val");
                    self thread scripts\players\_players::joinAllies();
                    self thread scripts\players\_players::spawnPlayer();
                    self notify("menu_changeclass_allies_closed");
                } else {
                    /// spawn after current wave ends
                    debugPrint(self.name + " has rejoined game for first time, spawning after wave", "val");
                    self iprintlnbold(&"ROTUSCRIPT_WILL_SPAWN_AFTER_WAVE");
                    self thread scripts\players\_players::spawnPlayerNextIntermission();
                    self notify("menu_changeclass_allies_closed");
                    return;
                }
            }
        }

        debugPrint(self.name + " .spawnCount: " + self.spawnCount + " .isChangingClass: " + self.isChangingClass + " .pers[team]: " + self.pers["team"] + " .isSpectating: " + self.isSpectating, "val");
        cost = getDvarInt("shop_item1_costs") + getDvarInt("shop_item2_costs") + getDvarInt("shop_item3_costs");

        if (self.spawnCount == 0) {
            // Player has never spawned this session
            if (scripts\players\_players::enoughPlayersAlive()) {
                // There are enough players alive to join the game
                /// spawn player
                debugPrint(self.name + " has never spawned, enough players, spawning now", "val");
                self thread scripts\players\_players::joinAllies();
                self thread scripts\players\_players::spawnPlayer();
                self notify("menu_changeclass_allies_closed");
            } else {
                if (scripts\server\_adminInterface::isAdmin(self)) {
                    // Player is an admin
                    /// spawn player
                    self iprintlnbold(&"ROTUSCRIPT_ADMIN_OVERRIDE_DEAD");
                    debugPrint(self.name + " has never spawned, not enough players, spawning now, admin override", "val");
                    self thread scripts\players\_players::joinAllies();
                    self thread scripts\players\_players::spawnPlayer();
                    self notify("menu_changeclass_allies_closed");
                } else {
                    // Player is not admin
                    debugPrint(self.name + " has never spawned, not enough players, spawning when more players alive", "val");
                    /// spawn when enough players alive
                    self iprintlnbold(&"ROTUSCRIPT_WILL_SPAWN_NEED_MORE");
                    self thread scripts\players\_players::spawnPlayerWhenMorePlayersAreAlive();
                    self notify("menu_changeclass_allies_closed");
                }
            }
        } else {
            // Player has spawned at least once this session
            if (self.isSpectating) {
                // Player is a spectator
                if (self.isChangingClass) {
                    // Player is trying to change their class
                    if (self.points > cost) {
                        // Player has enough points to pay for class change
                        /// change class, respawn, charge cost
                        debugPrint(self.name + " is spectator, has spawned, is changing class, has money, spawning now", "val");
                        self scripts\players\_players::incUpgradePoints(-1*cost);
                        self thread scripts\players\_players::changeClass(cost);
                        self notify("menu_changeclass_allies_closed");
                    } else {
                        // Player does not have enough points
                        /// don't change class, spawn when wave ends
                        self iprintlnbold(&"ROTUSCRIPT_NOT_ENOUGH_UP_CHANGE_CLASS", cost);

                        // reset class properties changed in pickClass()
                        self setclientdvars("ui_class_rank", level.player_stat_rank[self.curClass]);
                        self.class = self.curClass;
                        self.pers["class"] = self.curClass;
                        self setclientdvar("ui_loadout_class", self.curClass);

                        if (level.waveIntermission) {
                            debugPrint(self.name + " is spectator, has spawned, is changing class, has no money, spawning now with same class", "val");
                            self thread scripts\players\_players::joinAllies();
                            self thread scripts\players\_players::spawnPlayer(true);
                            self notify("menu_changeclass_allies_closed");
                        } else {
                            debugPrint(self.name + " is spectator, has spawned, is changing class, has no money, spawning next intermission with same class", "val");
                            self iprintlnbold(&"ROTUSCRIPT_WILL_SPAWN_AFTER_WAVE");
                            self thread scripts\players\_players::spawnPlayerNextIntermission();
                            self notify("menu_changeclass_allies_closed");
                        }
                    }
                } else {
                    // Player is not trying to change their class
                    /// restore ammo, health, infected, respawn when wave ends
                    if (level.waveIntermission) {
                        debugPrint(self.name + " is spectator, has spawned, is not changing class, spawning now with same class", "val");
                        self thread scripts\players\_players::joinAllies();
                        self thread scripts\players\_players::spawnPlayer(true);
                        self notify("menu_changeclass_allies_closed");
                    } else {
                        debugPrint(self.name + " is spectator, has spawned, is not changing class, spawning next intermission with same class", "val");
                        self iprintlnbold(&"ROTUSCRIPT_WILL_SPAWN_AFTER_WAVE");
                        self thread scripts\players\_players::spawnPlayerNextIntermission(true);
                        self notify("menu_changeclass_allies_closed");
                    }
                }
            } else {
                // Player is not a spectator
                if (self.isChangingClass) {
                    // Player is trying to change their class
                    if ((self.isZombie) || (self.isDown)) {
                        // Player is down or a zombie
                        /// do nothing
                        debugPrint(self.name + " is not spectator, has spawned, is changing class, not spawning: down or a zombie", "val");
                        self iprintlnbold(&"ROTUSCRIPT_CANT_CHANGE_CLASS_WHEN_ZOM_DOWN");
                        self notify("menu_changeclass_allies_closed");
                        return;
                    } else {
                        // Player is not down or a zombie
                        if (self.points > cost) {
                            // Player has enough points to pay for class change
                            /// change class, respawn, charge cost
                            debugPrint(self.name + " is not spectator, has spawned, is changing class, has money, spawning now", "val");
                            self scripts\players\_players::incUpgradePoints(-1*cost);
                            self thread scripts\players\_players::changeClass(cost);
                            self notify("menu_changeclass_allies_closed");
                        } else {
                            // Player does not have enough points
                            /// do nothing
                            debugPrint(self.name + " is not spectator, has spawned, is changing class, has no money, not spawning", "val");
                            self iprintlnbold(&"ROTUSCRIPT_NOT_ENOUGH_UP_CHANGE_CLASS", cost);
                            self notify("menu_changeclass_allies_closed");
                            return;
                        }
                    }
                } else {
                    // Player is not trying to change their class
                    /// do nothing
                    self notify("menu_changeclass_allies_closed");
                    return;
                }
            }
        }
    } else  {
        self iprintlnbold(&"ROTUSCRIPT_PICK_CLASS");
    }
}

getClassRank(class)
{
    debugPrint("in _classes::getClassRank()", "fn", level.nonVerbose);

    if (!level.dvar["game_class_ranks"]) {return 29;}
    else {return self getStat(level.player_stat_rank[class]);}
}
