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

#include scripts\include\physics;
#include scripts\include\entities;
#include scripts\include\hud;
#include scripts\include\utility;
#include scripts\include\strings;
#include scripts\include\array;

init()
{
    debugPrint("in _players::init()", "fn", level.nonVerbose);

    level.activePlayers = 0;
    level.alivePlayers = 0;
    level.playerspawns = "";
    level.intermission = 1;
    level.waveIntermission = true;
    level.maxDemerits = getDvarInt("surv_max_demotion_demerits");
    level.reviveFailureDemeritFactor = getDvarInt("surv_intermission_revive_failure_demerit_factor");
    level.uniquePlayers = [];

    precache();

    level.callbackPlayerLastStand = ::Callback_PlayerLastStand;

    thread scripts\players\_menus::init();
    thread scripts\players\_classes::init();
    thread scripts\players\_abilities::init();
    scripts\players\_weapons::init();
    thread scripts\players\_playermodels::init();
    thread scripts\players\_usables::init();
    thread scripts\players\_infection::init();
    thread scripts\players\_persistence::init();
    thread scripts\players\_damagefeedback::init();
    thread scripts\players\_barricades::init();
    thread scripts\players\_turrets::init();
    thread scripts\players\_teleporter::init();
    thread scripts\players\_rank::init();
    //thread scripts\players\_challenges::buildChallegeInfo();
    thread uav();
}

precache()
{
    debugPrint("in _players::precache()", "fn", level.nonVerbose);

    level._effect["flashlight"] = Loadfx("misc/flashlight");
    level.medkitFX = loadfx("misc/medkit");

    // headicons
    precacheHeadIcon("hud_icon_lowhp");
    precacheHeadIcon("headicon_medhp");
    precacheHeadIcon("headicon_admin");
    precacheHeadIcon("headicon_medic");
    precacheHeadIcon("headicon_engineer");

    // scoreboard status icons
    precacheStatusIcon("icon_down");
    precacheStatusIcon("icon_admin");
    precacheStatusIcon("icon_spec");
    precacheStatusIcon("icon_dev");

    precacheString(&"ROTUSCRIPT_AUTOTEXT_IM_DOWN_HELP");
    precacheString(&"ROTUSCRIPT_HOLD_USE_TO_REVIVE");
    precacheString(&"ROTUSCRIPT_PLAYER_DOWNED");
    precacheString(&"ROTUSCRIPT_KEEP_RUNNING_TO_SURVIVE");
    precacheString(&"ROTUSCRIPT_GOT_AUTOREVIVED");
    precacheString(&"ROTUSCRIPT_YOURE_BUGGED");
    precacheString(&"ROTUSCRIPT_CLASS_CHANGED_TO");
    precacheString(&"ROTUSCRIPT_PRESS_USE_TO_CURE");

    scripts\players\_shop::precache();
    scripts\players\_spree::precache();
}

/**
 * @brief Periodically shows zombies on the minimap
 *
 * @returns nothing
 */
uav()
{
    debugPrint("in _players::uav()", "fn", level.nonVerbose);

    level endon("game_ended");

    if (getDvar("ui_always_show_zombies") == "0")
    {
        visibleDuration = getDvarInt("ui_show_zombies_duration");
        hiddenDuration = getDvarInt("ui_hide_zombies_duration");

        if ((visibleDuration == 0) && (hiddenDuration == 0))
        {
            return;
        }

        while (1)
        {
            wait hiddenDuration;
            for (i = 0; i < level.players.size; i++)
            {
                level.players[i] setClientDvar("g_compassShowEnemies", 1);
            }
            wait visibleDuration;
            for (i = 0; i < level.players.size; i++)
            {
                if (level.players[i].curClass != "scout")
                { // do not turn off scout's drone ability
                    level.players[i] setClientDvar("g_compassShowEnemies", 0);
                }
            }
        }
    }
}

setDown(isDown)
{
    debugPrint("in _players::setDown()", "fn", level.veryLowVerbosity);

    self.isDown = isDown;
    self.persData.isDown = isDown;
    if (isDown)
    {
        self.downOrigin = self.origin;
    }
}

/**
 * @brief Informs teammates a player is down and where they are
 *
 * @returns nothing
 */
downed()
{
    debugPrint("in _players::downed()", "fn", level.nonVerbose);

    self endon("disconnect");

    while (1)
    {
        self waittill("downed");
        if (self isNewPlayer())
        {
            // Do Nothing.  No minimap or autotext feedback if we are giving new
            // player assistance
        }
        else
        {
            self autoText(&"ROTUSCRIPT_AUTOTEXT_IM_DOWN_HELP");
            while ((self.isDown) && (!self.isZombie))
            {
                self pingplayer();
                wait 3;
            }
        }
    }
}

/**
 * @brief Prints an automatic message to the text console
 *
 * @param message string The message to say
 *
 * @returns nothing
 */
autoText(message)
{
    debugPrint("in _players::autoText()", "fn", level.nonVerbose);

    if (!isDefined(message))
    {
        errorPrint("_players::autoText() called with undefined message.");
        return;
    }
    self sayall(message);
}

Callback_PlayerLastStand(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
    debugPrint("in _players::Callback_PlayerLastStand()", "fn", level.nonVerbose);

    // remove any usables on this player
    level scripts\players\_usables::removeUsable(self);
    wait 0.05;

    self endon("disconnect");

    useObjects = level.useObjects;
    for (i = 0; i < useObjects.size; i++)
    {
        if (((useObjects[i].type == "extras") || (useObjects[i].type == "ammobox")) &&
            (distance(self.origin, useObjects[i].origin) < 80))
        {
            self setOrigin(self.originalSpawnLocation);
            debugPrint(self.name + " is down within 80 units of shop/ammo crate. Teleporting to spawn point.", "val");
            break;
        }
    }
    self notify("downed");

    //self.health = int(self.maxhealth / 4);
    self.lastDownTime = getTime();

    self setDown(true);
    self.isTargetable = false;

    // abort any usables this player was using when they went down
    self scripts\players\_usables::usableAbort();

    self.lastStandWeapons = self getweaponslist();
    self.lastStandAmmoStock = [];
    self.lastStandAmmoClip = [];
    for (i = 0; i < self.lastStandWeapons.size; i++)
    {
        self.lastStandAmmoClip[i] = self getWeaponAmmoClip(self.lastStandWeapons[i]);
        self.lastStandAmmoStock[i] = self getWeaponAmmoStock(self.lastStandWeapons[i]);
    }

    self.lastStandWeapon = self GetCurrentWeapon();

    self setclientdvars("ui_hintstring", "", "ui_specialtext", "@ROTUUI_SPECIAL_UNAVAILABLE");

    level scripts\players\_usables::addUsable(self, "revive", &"ROTUSCRIPT_HOLD_USE_TO_REVIVE", 96);
    wait 0.05;

    for (i = 0; i < level.useObjects.size; i++)
    {
        ent = level.useObjects[i];
        if (ent != self)
        {
            continue;
        }
        if (ent.type == "revive")
        {
            debugPrint(self.name + " has a revive usable.", "val");
        }
        else
        {
            debugPrint(self.name + " does NOT have a revive usable.", "val");
        }
    }

    iPrintln(&"ROTUSCRIPT_PLAYER_DOWNED", self.name);
    self.deaths++;
    self.isAlive = false;

    self setStatusIcon("icon_down");

    self removeTimers();

    //self usableAbort();

    self.health = 10;
    self updateHealthHud(0);

    weaponslist = self getweaponslist();
    for (i = 0; i < weaponslist.size; i++)
    {
        weapon = weaponslist[i];

        if (weapon == self.secondary) //scripts\players\_weapons::isPistol( weapon )
        {
            self switchtoweapon(weapon);
            continue;
        }
        else
            self takeweapon(weapon);
    }

    // Help new players out
    if (self isNewPlayer())
    {
        self thread assistNewPlayers();
    }
    else
    {
        // only decrement counter if player isn't a noob, so the game won't end
        // when they go down if they are the only player
        level.alivePlayers--;
    }
}

/**
 * @brief Is this a new player eligible for new player assistance?
 *
 * @returns boolean Indicating whether to give assistance or not
 */
isNewPlayer()
{
    debugPrint("in _players::isNewPlayer()", "fn", level.nonVerbose);

    prestige = self scripts\players\_persistence::statGet("plevel");
    rank = self.pers["rank"];
    if ((prestige < 1) &&
        (rank < level.dvar["game_assistance_max_rank"]) &&
        (self.newPlayerAssistCount < 3))
    {
        return true;
    }
    return false;
}

/**
 * @brief Make the game a bit easier for new players
 *
 * For players that have never prestiged, and whose rank is less than 30,
 * we help them out a bit.  When they go down, we automatically revive them, cure
 * them if needed, and give them some spending money.  We also inform them that
 * running is the key to survival.
 *
 * @returns nothing
 */
assistNewPlayers()
{
    debugPrint("in _players::assistNewPlayers()", "fn", level.nonVerbose);

    self thread revive();
    self.sessionstate = "playing";
    self defaultHeadicon();

    self.newPlayerAssistCount++;

    wait 0.05;

    if (self.infected)
    {
        self scripts\players\_infection::cureInfection();
    }

    rank = self.pers["rank"];
    max = level.dvar["game_assistance_max_rank"];
    if (rank < int(0.33 * max))
    {
        self scripts\players\_players::incUpgradePoints(1000);
    }
    else if (rank < int(0.66 * max))
    {
        self scripts\players\_players::incUpgradePoints(500);
    }
    else if (rank < max)
    {
        self scripts\players\_players::incUpgradePoints(250);
    }
    self iprintlnbold(&"ROTUSCRIPT_KEEP_RUNNING_TO_SURVIVE");
}

restoreAmmo()
{
    debugPrint("in _players::restoreAmmo()", "fn", level.nonVerbose);

    weapons = self getweaponslist();
    for (i = 0; i < weapons.size; i++)
    {
        if (scripts\players\_weapons::canRestoreAmmo(weapons[i]))
        {
            self GiveMaxAmmo(weapons[i]);
            self setWeaponAmmoClip(weapons[i], weaponClipSize(weapons[i]));
        }
    }
}

onPlayerConnect()
{
    debugPrint("in _players::onPlayerConnect()", "fn", level.nonVerbose);

    if (level.gameEnded)
    {
        self.sessionstate = "intermission";
    }

    // Keep track of players that have already joined this game at least once
    self.uniqueId = self.name + self.guid;
    if (!inArray(level.uniquePlayers, self.uniqueId))
    {
        // never joined this game, so add them to the array
        level.uniquePlayers[level.uniquePlayers.size] = self.uniqueId;
        debugPrint(self.name + " has joined the game for the first time", "val");
        self.hasPreviouslyJoined = false;
    }
    else
    {
        debugPrint(self.name + " has previously joined this game", "val");
        self.hasPreviouslyJoined = true;
    }

    self.isObj = false;
    self.useObjects = [];
    self.class = "none";
    self.curClass = "none";
    self.mayRespawn = true;
    self.isAlive = false;
    self.isActive = false;
    self.isSpectating = true;
    self.isDown = false;
    self.reviveCount = 0;                      // How many players they revived
    self.reviveCoverCount = 0;                 // How many times they provided covering fire during the revival of another player
    self.friendlyDamageCount = 0;              // How many teammates have you damaged by killing flamers this game
    self.intermissionReviveCount = 0;          // How many players they revived during intermission
    self.lastUpTime = getTime();               // The time the player was last revived or not a zombie
    self.lastDownTime = getTime();             // The time the player was last downed
    self.isReviving = false;                   // Is the player currently reviving another player?
    self.waveIntermissionZombieAttackers = []; // tracks players that damage this player-zombie during wave intermission
    self.canGetSpecialWeapons = false;
    self.ammoBoxRestoreTime = 40;  // for engineers, default to 40 sec restore time for ammo boxes
    self.ownsTurret = false;       // does the player own a defense turret?
    self.spawnCount = 0;           // how many times has the player spawned this session
    self.isChangingClass = false;  // is the player trying to change their class?
    self.newPlayerAssistCount = 0; // keep track of new player assistance counts

    self.pers["generalWarnings"] = self getStat(2354);
    if (!isDefined(self.pers["generalWarnings"]))
    {
        self.pers["generalWarnings"] = 0;
        self setStat(2354, self.pers["generalWarnings"]);
    }

    self.pers["badLanguageWarnings"] = self getStat(2355);
    if (!isDefined(self.pers["badLanguageWarnings"]))
    {
        self.pers["badLanguageWarnings"] = 0;
        self setStat(2355, self.pers["badLanguageWarnings"]);
    }

    self.pers["demerits"] = self getStat(2356);
    if (!isDefined(self.pers["demerits"]))
    {
        self.pers["demerits"] = 0;
        self setStat(2356, self.pers["demerits"]);
    }

    self.nighvision = false;
    self setStatusIcon("icon_spec");
    self.zombieObjectiveIndex = -1; // the index of the 'kill' objective when a player is a zombie

    self thread scripts\players\_persistence::restoreData();
    self thread scripts\players\_shop::playerSetupShop();
    self thread scripts\players\_rank::onPlayerConnect();
    self thread scripts\server\_environment::onPlayerConnect();

    /// Force open the change class menu when a player joins the server
    self thread scripts\players\_classes::monitorEnabledClasses();
    self openMenu(game["menu_changeclass_allies"]);

    wait 0.05;

    if ((self scripts\players\_rank::getRankXP() == int(level.rankTable[level.maxRank][7])) &&
        (self.pers["prestige"] != level.maxPrestige))
    {
        needToPrestige = true;
    }
    else
    {
        needToPrestige = false;
    }

    // Players that prestige can get special weapons in last half of game
    if ((self scripts\players\_rank::getPrestigeLevel() < 1) || // have never prestiged
        (needToPrestige))                                       // need to prestige
    {
        self.canGetSpecialWeapons = false;
    }
    else
    {
        self.canGetSpecialWeapons = true;
    }

    if ((level.canBuyRaygun) && (self.canGetSpecialWeapons))
    {
        self setclientdvar("ui_raygun", 1); // enable raygun in shop
    }
    else
    {
        self setclientdvar("ui_raygun", 0); // disable raygun in shop
    }

    self setclientdvars("g_scriptMainMenu", game["menu_class"], "cg_thirdperson", 0, "r_filmusetweaks", 0, "ui_class_ranks", (1 - level.dvar["game_class_ranks"]), "ui_specialrecharge", 0);

    // Always show zombies on minimap if configured in server.cfg
    if (getDvar("ui_always_show_zombies") == "1")
    {
        self setClientDvar("g_compassShowEnemies", 1);
    }

    // Let teammates know the player needs help
    self thread downed();

    self.isLocked = false; // is the player locked due to pending admin action?
    self.lockedBy = "";    // name of admin that locked the player

    markAdminMenuAsDirty();

    // monitor player signals for debugging purposes
    self thread scripts\level\signals::noLongerAZombie();
    self thread scripts\level\signals::death();
    self thread scripts\level\signals::disconnect();
}

/**
 * @brief Restores a player's default headicon when they are no longer infected or have low health
 *
 * @returns nothing
 */
defaultHeadicon()
{
    debugPrint("in _players::defaultHeadicon()", "fn", level.fullVerbosity);

    if (!isDefined(self))
    {
        return;
    }

    // Ensure we don't remove the infected icon on revive
    if (self.infected)
    {
        if (self.headicon != "icon_infection")
        {
            self.headicon = "icon_infection";
        }
        return;
    }

    headicon = "";
    if (self.curClass == "medic")
    {
        headicon = "headicon_medic";
    }
    else if (self.curClass == "engineer")
    {
        headicon = "headicon_engineer";
    }
    else if ((scripts\server\_adminInterface::isAdmin(self)) && (!self.admin.isStealthSession))
    {
        headicon = "headicon_admin";
        if ((self.sessionstate == "playing") || (self.sessionstate == "dead"))
        {
            self.statusicon = "icon_admin";
        }
    }
    if (self.headicon != headicon)
    {
        self.headicon = headicon;
        self.headiconteam = "allies";
    }
}

onWaveIntermissionBegins()
{
    debugPrint("in _players::onWaveIntermissionBegins()", "fn", level.nonVerbose);

    level endon("game_ended");

    while (1)
    {
        level waittill("wave_finished");
        players = level.players;
        for (i = 0; i < players.size; i++)
        {
            players[i].intermissionReviveCount = 0;
            // reset new player assistance counts between waves
            players[i].newPlayerAssistCount = 0;
        }
        level.waveIntermission = true;
        level.waveEndedTime = getTime();
        printPlayersData(); // <debug />
    }
}

onWaveIntermissionEnds()
{
    debugPrint("in _players::onWaveIntermissionEnds()", "fn", level.nonVerbose);

    level endon("game_ended");

    while (1)
    {
        level waittill("start_monitoring");
        level.waveIntermission = false;
        level.waveBeganTime = getTime();
        punishPlayers = false;

        printPlayersData();

        downPlayerCount = level.activePlayers - level.alivePlayers;
        debugPrint("level.waveBeganTime: " + level.waveBeganTime, "val");

        if (downPlayerCount > 0)
        {
            // We may need to punish for failing to revive
            players = level.players;
            for (i = 0; i < players.size; i++)
            {
                if ((players[i].isDown) && (players[i].lastDownTime < level.waveEndedTime))
                {
                    // player was down when wave ended, and was still down when the next wave began
                    // so we need to see who we punish, if anyone
                    debugPrint("Punish players for: " + players[i].name + " lastDownTime: " + players[i].lastDownTime + " waveEndedTime: " + level.waveEndedTime, "val");
                    punishPlayers = true;
                    break;
                }
            }

            // Give players revive credit for damaging a player-zombie during intermission
            for (i = 0; i < players.size; i++)
            {
                for (j = 0; j < players[i].waveIntermissionZombieAttackers.size; j++)
                {
                    if (!isDefined(players[i].waveIntermissionZombieAttackers[j]))
                    {
                        continue;
                    }
                    creditPlayer = scripts\include\adminCommon::getPlayerByEntityNumber(players[i].waveIntermissionZombieAttackers[j]);
                    if (!isDefined(creditPlayer))
                    {
                        continue;
                    }
                    creditPlayer.intermissionReviveCount++;
                }
                emptyArray = [];
                players[i].waveIntermissionZombieAttackers = emptyArray;
            }

            if (punishPlayers)
            {
                for (i = 0; i < players.size; i++)
                {
                    // don't punish players that aren't actually in the game
                    if (!players[i].isActive)
                    {
                        continue;
                    }
                    if (players[i].isSpectating)
                    {
                        continue;
                    }

                    // Assume player was up the entire intermission
                    aliveTime = level.waveBeganTime - level.waveEndedTime;
                    if ((players[i].lastDownTime < level.waveEndedTime) &&
                        (players[i].lastUpTime < level.waveEndedTime))
                    {
                        // player did not go up or down during the intermission, so
                        // is their most recent event lastDownTime or lastUpTime?
                        if (players[i].lastDownTime > players[i].lastUpTime)
                        {
                            // player was actually down the entire intermission
                            aliveTime = 0;
                        }
                    }
                    else if ((players[i].lastDownTime < level.waveEndedTime) &&
                             (players[i].lastUpTime > level.waveEndedTime))
                    {
                        // player was down when wave ended, and
                        // player was revived during the intermission, so subtract
                        // the amount of intermission time they were down
                        aliveTime -= players[i].lastUpTime - level.waveEndedTime;
                    }
                    else if ((players[i].lastDownTime > level.waveEndedTime) &&
                             (players[i].lastUpTime > level.waveEndedTime) &&
                             (players[i].lastUpTime < level.waveBeganTime))
                    {
                        // player went down during the intermission, and was
                        // up before the intermission ended, so subtract the
                        // time they were down during the intermission, plus a buffer
                        aliveTime -= int(1.25 * (players[i].lastUpTime - players[i].lastDownTime));
                    }
                    else if ((players[i].lastDownTime > level.waveEndedTime) &&
                             (players[i].lastUpTime < level.waveEndedTime))
                    {
                        // player went down during the intermission, and was
                        // still down when the intermission ended, so recalculate
                        // their alive time
                        aliveTime = players[i].lastDownTime - level.waveEndedTime;
                    }

                    //                     aliveTime = level.waveBeganTime - players[i].lastUpTime;
                    debugPrint(players[i].name + " lastUpTime: " + players[i].lastUpTime, "val");
                    debugPrint(players[i].name + " aliveTime: " + aliveTime, "val");
                    timeout = level.dvar["surv_timeout"];
                    twoReviveTime = (timeout - 2) * 1000;
                    oneReviveTime = (int(timeout / 2) + 1) * 1000;
                    debugPrint("twoReviveTime: " + twoReviveTime + "ms oneReviveTime: " + oneReviveTime + "ms", "val");
                    if (aliveTime > twoReviveTime)
                    { // time in ms
                        // player was alive long enough to revive at least two people
                        if (players[i].intermissionReviveCount < 2)
                        {
                            debugPrint(downPlayerCount + " down players, " + players[i].name + " revived " + players[i].intermissionReviveCount + ", could have revived two.", "val");
                            demeritCount = int((2 - players[i].intermissionReviveCount) * level.reviveFailureDemeritFactor);
                            players[i] thread scripts\players\_rank::increaseDemerits(demeritCount, "wave_intermission_revive");
                        }
                        else
                        {
                            debugPrint("No Demerits: " + players[i].name + " revived " + players[i].intermissionReviveCount + ", could have revived two.", "val");
                        }
                    }
                    else if (aliveTime > oneReviveTime)
                    { // time in ms
                        // player was alive long enough to revive at least one person
                        if (players[i].intermissionReviveCount < 1)
                        {
                            debugPrint(downPlayerCount + " down players, " + players[i].name + " revived " + players[i].intermissionReviveCount + ", could have revived one.", "val");
                            demeritCount = int((1 * level.reviveFailureDemeritFactor));
                            players[i] thread scripts\players\_rank::increaseDemerits(demeritCount, "wave_intermission_revive");
                        }
                        else
                        {
                            debugPrint("No Demerit: " + players[i].name + " revived " + players[i].intermissionReviveCount + ", could have revived one.", "val");
                        }
                    }
                    players[i].intermissionReviveCount = 0;
                }
            }
        }
        // revive any players that were down the entire wave intermission
        players = level.players;
        for (i = 0; i < players.size; i++)
        {
            if ((players[i].isDown) &&
                (!players[i].isZombie) &&
                (players[i].lastDownTime < level.waveEndedTime))
            {
                // player was down when wave ended, and was still down when the next wave began
                players[i] thread scripts\players\_players::revive();
                players[i] notify("damage", 0);
                iprintln(&"ROTUSCRIPT_GOT_AUTOREVIVED", players[i].name);
                players[i] setclientdvar("ui_reviveby", "");
                players[i].lastUpTime = getTime();
            }
        }
    }
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
    debugPrint("in _players::onPlayerKilled()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");
    if (self.isZombie)
    {
        wait 1;
        self TakeAllWeapons();
        self.isZombie = false;
        self.lastUpTime = getTime();
        self notify("no_longer_a_zombie");
        debugPrint("signal no_longer_a_zombie emitted for " + self.name, "val");
        if (self.myBody != "")
        {
            self setmodel(self.myBody);
        }
        if (self.myHead != "")
        {
            self attach(self.myHead);
        }
        self setclientdvar("cg_thirdperson", 0);
        self permanentTweaksOff();
        if (self.sessionstate != "spectator")
        {
            if (isDefined(self.tombEnt))
            {
                self setorigin(self.tombEnt.origin, self.tombEnt.angles);
                self.tombEnt delete ();
            }
            else
            {
                self setorigin(self.origin, self.angles);
                self iprintlnbold(&"ROTUSCRIPT_YOURE_BUGGED");
            }

            self thread revive();
            self.sessionstate = "playing";
            self defaultHeadicon();
        }
        return;
    }
    // CLEANUP
    self cleanup();

    self endon("spawned");

    self notify("killed_player");
    self.lastDownTime = getTime();

    if (self.sessionteam == "spectator")
        return;

    if (sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
        sMeansOfDeath = "MOD_HEAD_SHOT";

    if (level.dvar["zom_orbituary"])
        obituary(self, attacker, sWeapon, sMeansOfDeath);

    self.sessionstate = "dead";

    self.mayRespawn = false;

    //if (isplayer(attacker) && attacker != self)
    //attacker.score++;
    //self.deaths++;

    body = self clonePlayer(deathAnimDuration);

    doRagdoll = true;

    if (doRagdoll)
    {
        if (self isOnLadder() || self isMantling())
            body startRagDoll();

        thread delayStartRagdoll(body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath);
    }
}

resetSpawning()
{
    debugPrint("in _players::resetSpawning()", "fn", level.nonVerbose);

    for (i = 0; i < level.players.size; i++)
    {
        self.mayRespawn = true;
    }
}

onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
    debugPrint("in _players::onPlayerDamage()", "fn", level.veryHighVerbosity);

    if (self.sessionteam == "spectator")
    {
        return;
    }

    if (isdefined(eAttacker))
    {
        if (isplayer(eAttacker))
        {
            if (eAttacker.team == self.team)
            {
                if (self.isZombie)
                {
                    if (level.waveIntermission)
                    {
                        // track the players that damage a player-zombie during wave intermission,
                        // so we can credit their intermission revive count appropriately
                        attackerEntityNumber = eAttacker getEntityNumber();
                        if (!inIntArray(self.waveIntermissionZombieAttackers, attackerEntityNumber))
                        {
                            self.waveIntermissionZombieAttackers[self.waveIntermissionZombieAttackers.size] = attackerEntityNumber;
                        }
                    }
                    // Give the player attacking the player-zombie some points to
                    // pay for expended ammo
                    //                     eAttacker scripts\players\_players::incUpgradePoints(iDamage);
                    /// Attempt to limit number of unique strings to stop string overflow errors
                    eAttacker scripts\players\_players::incUpgradePoints(20);
                    self scripts\bots\_bots::Callback_BotDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
                    updateHealthHud(self.health / self.maxhealth);
                    return;
                }
                else if (!getDvarInt("game_allowfriendlyfire") && eAttacker != self)
                { // level.dvar["game_allowfriendlyfire"]
                    // if we don't allow friendly fire, a player can only injure teammates
                    // if they are a player-zombie
                    if (!eAttacker.isZombie)
                    {
                        return;
                    }
                }
            }
            else
            {
                if (!level.hasReceivedDamage)
                {
                    level.hasReceivedDamage = 1;
                }
            }
        }
    }

    if (self.god)
    {
        return;
    }
    if (self.isDown)
    {
        return;
    }

    if (!isDefined(vDir))
        iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

    if (!(iDFlags & level.iDFLAGS_NO_PROTECTION))
    {
        iDamage = int(iDamage * self.damageDoneMP);
        if (self.heavyArmor)
        {
            if (self.health / self.maxhealth >= .65)
            {
                iDamage = int(iDamage / 2);
                self thread screenFlash((0, 0, .7), .35, .5);
            }
        }
        if (iDamage < 1)
            iDamage = 1;

        if (sWeapon == "ak74u_acog_mp" || sWeapon == "barrett_acog_mp")
            return;

        iDamage = int(iDamage * self.incdammod);

        if (issubstr(sMeansOfDeath, "GRENADE"))
            return;

        // Last Man Standing ability
        // 80% less damage when busy(reviving, shop, weapon upgrades) if last man standing
        if (level.alivePlayers == 1 && self.hasLastManStanding && self.isBusy)
        {
            iDamage = int(iDamage * 0.20);
            if (iDamage < 1)
            {
                iDamage = 1;
            }
        }

        self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
        updateHealthHud(self.health / self.maxhealth);
    }
}

watchHP()
{
    debugPrint("in _players::watchHP()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");
    self endon("spawned"); // end this instance before a respawn

    while (1)
    {
        wait 0.5;
        if (!self.infected)
        {
            if ((self.isDown) && (self.headicon == ""))
            {
                continue;
            }
            if ((self.isDown) && (self.headicon != ""))
            {
                // If you aren't infected, and are down, ensure there is no headicon
                self.headicon = "";
                continue;
            }
            if (self.health <= 40)
            {
                // if you aren't infected, have really low health, are not down,
                // then toggle the lowhp headicon every half second
                if (self.headicon == "hud_icon_lowhp")
                {
                    self.headicon = "";
                }
                else
                {
                    self.headicon = "hud_icon_lowhp";
                }
                continue;
            }
            if (self.health <= 75)
            {
                // if you aren't infected, have low health, are not down,
                // then show the medium hp headicon
                if (self.headicon != "headicon_medhp")
                {
                    self.headicon = "headicon_medhp";
                }
                continue;
            }
            self defaultHeadicon(); // restore default headicon
        }
    }
}

doAreaDamage(range, damage, attacker)
{
    debugPrint("in _players::doAreaDamage()", "fn", level.nonVerbose);

    for (i = 0; i <= level.bots.size; i++)
    {
        target = level.bots[i];
        if (isdefined(target) && isalive(target))
        {
            distance = distance(self.origin, target.origin);
            if (distance < range)
            {
                target.isPlayer = true;
                target.entity = target;
                target damageEnt(
                    self,            // eInflictor = the entity that causes the damage (e.g. a claymore)
                    attacker,        // eAttacker = the player that is attacking
                    damage,          // iDamage = the amount of damage to do
                    "MOD_EXPLOSIVE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
                    "none",          // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
                    self.origin,     // damagepos = the position damage is coming from
                    vectorNormalize(target.origin - self.origin));
            }
        }
    }
}

printPlayersData()
{
    debugPrint("in _players::printPlayersData()", "fn", level.veryLowVerbosity);

    players = level.players;
    if (players.size == 0)
    {
        return;
    }
    header = "name                   index playerNumber    guid                    active alive down bot spectating";
    debugPrint(header, "val");
    for (i = 0; i < players.size; i++)
    {
        if (!isDefined(players[i]))
        {
            continue;
        }
        name = leftPad(players[i].name, " ", 20);
        index = i;
        number = players[i] getEntityNumber();
        guid = players[i] getGuid();
        active = players[i].isActive;
        alive = players[i].isAlive;
        spectating = players[i].isSpectating;
        down = players[i].isDown;
        if (!isDefined(down))
        {
            down = "undef";
        }
        bot = players[i].isBot;
        line = name + " \t" + index + " \t" + number + " " + guid + " \t" + active + " \t" + alive + " \t" + down + " \t" + bot + "\t" + spectating;
        debugPrint(line, "val");
    }
    alive = level.alivePlayers;
    active = level.activePlayers;
    down = active - alive;
    debugPrint("alive: " + alive + " active: " + active + " down: " + down, "val");
}

watchPlayersData()
{
    debugPrint("in _players::watchPlayersData()", "fn", level.nonVerbose);

    while (1)
    {
        wait 30;
        printPlayersData();
    }
}

/**
 * @brief Manually correct the number of Alive/Down players
 *
 * There are bugs and race conditions that can cause the player status counts to become
 * incorrect, leading to the game failing to end when it should, or preventing players
 * from joining when they should be able to join.  While we endeavor to kill those bugs,
 * this function serves to ensure the game isn't screwed up for too long in the case
 * of a missed bug or a race condition.
 *
 * @returns nothing
 */
correctPlayerCounts()
{
    debugPrint("in _players::correctPlayerCounts()", "fn", level.nonVerbose);

    self endon("game_ended");

    while (1)
    {
        wait 3;
        alivePlayers = 0;
        downPlayers = 0;
        activePlayers = 0;
        players = level.players;
        for (i = 0; i < players.size; i++)
        {
            // spectators have isActive == false, and isAlive == true
            if ((isDefined(players[i].isActive)) && (players[i].isActive))
            {
                activePlayers++;
            }
            if ((isDefined(players[i].isAlive)) && (players[i].isAlive))
            {
                alivePlayers++;
            }
            if ((isDefined(players[i].isDown)) && (players[i].isDown))
            {
                downPlayers++;
            }
        }
        if (level.activePlayers != activePlayers)
        {
            level.activePlayers = activePlayers;
            level.downPlayers = downPlayers;
            debugPrint("level.activePlayers was incorrect; correcting.");
        }
        if (level.alivePlayers != alivePlayers)
        {
            level.alivePlayers = alivePlayers;
            level.downPlayers = downPlayers;
            debugPrint("level.alivePlayers was incorrect; correcting.");
        }
    }
}

// CLEANUP ON DEATH (SPEC) OR DISCONNECT
cleanup(message)
{
    debugPrint("in _players::cleanup()", "fn", level.nonVerbose);

    if (!isDefined(self))
    {
        noticePrint("Player disconnected before _players::cleanup() could run.");
        if (isDefined(message))
        {
            noticePrint(message);
        }
        markAdminMenuAsDirty();
        level.activePlayers--;
        level.alivePlayers--;
        return;
    }

    for (i = 0; i < level.minigunTurrets.size; i++)
    {
        if ((isDefined(level.minigunTurrets[i].gun.owner)) && (level.minigunTurrets[i].gun.owner == self))
        {
            debugPrint("From players::cleanup(), trying to remove turret " + level.minigunTurrets[i].id, "val");
            thread scripts\players\_turrets::removeTurret(level.minigunTurrets[i]);
        }
    }
    for (i = 0; i < level.grenadeTurrets.size; i++)
    {
        if ((isDefined(level.grenadeTurrets[i].gun.owner)) && (level.grenadeTurrets[i].gun.owner == self))
        {
            debugPrint("From players::cleanup(), trying to remove turret " + level.grenadeTurrets[i].id, "val");
            thread scripts\players\_turrets::removeTurret(level.grenadeTurrets[i]);
        }
    }

    playerName = self.name;

    if (self.isDown)
    {
        level scripts\players\_usables::removeUsable(self);
    }
    self scripts\players\_usables::usableAbort();
    if (isDefined(self.parachute))
    {
        self.parachute delete ();
    }
    if (isdefined(self.infection_overlay))
    {
        self.infection_overlay destroy();
    }
    if (isdefined(self.tombEnt))
    {
        self.tombEnt delete ();
    }
    if (isdefined(self.carryObj))
    {
        if (isDefined(self.carryObj.gun))
        { // the player is carrying a defense turret
            turret = self.carryObj;
            self.carryObj unlink();
            wait .05;
            turret.isBeingMoved = false;
            turret.gun.primaryAngles = vectorToAngles(anglesToForward(turret.gun.angles));
            turret.gun.primaryUnitVector = vectorNormalize(anglesToForward(turret.gun.angles));

            // Must undefine self.carryObj or the turret gets delete()'d when
            // the player leaves the game
            self.carryObj = undefined;

            // good attempt to get turret.gun to rotate
            turret.gun unlink();
            thread scripts\players\_turrets::removeTurret(turret);
        }
        else
        {
            debugPrint("Deleting self.carryObj", "val");
            self.carryObj delete ();
        }
    }

    // if player was a zombie, remove the kill objective
    if ((isDefined(self.zombieObjectiveIndex)) && (self.zombieObjectiveIndex != -1))
    {
        objective_state(self.zombieObjectiveIndex, "empty");
        objective_delete(self.zombieObjectiveIndex);
        // mark index as available
        level.objectiveIndexAvailability[self.zombieObjectiveIndex] = 1;
        self.zombieObjectiveIndex = -1;
    }

    markAdminMenuAsDirty();

    self.headicon = "";
    self setStatusIcon("");

    self.isTargetable = false;

    level scripts\players\_usables::removeUsable(self);
    self scripts\players\_usables::usableAbort();

    self destroyProgressBar();

    self setclientdvars("r_filmusetweaks", 0, "ui_upgradepoints", "0", "ui_specialtext", "");
    if (self.isActive)
    {
        level.activePlayers--;
        self.isActive = false;
        if (self.isAlive)
        {
            level.alivePlayers--;
            self.isAlive = false;

            if (self.primary != "none")
            {
                self.persData.primaryAmmoClip = self getweaponammoclip(self.primary);
                self.persData.primaryAmmoStock = self getweaponammostock(self.primary);
            }
            if (self.secondary != "none")
            {
                self.persData.secondaryAmmoClip = self getweaponammoclip(self.secondary);
                self.persData.secondaryAmmoStock = self getweaponammostock(self.secondary);
            }
            if (self.extra != "none")
            {
                self.persData.extraAmmoClip = self getweaponammoclip(self.extra);
                self.persData.extraAmmoStock = self getweaponammostock(self.extra);
            }
        }
    }

    self notify("end_trance");
    self updateHealthHud(-1);

    debugPrint("Finished _players::cleanup() for player: " + playerName, "val");
}

/**
 * @brief For each admin, mark their admin menu as dirty
 * We do this when a player joins or leaves the game
 *
 * @returns nothing
 */
markAdminMenuAsDirty()
{
    debugPrint("in _players::markAdminMenuAsDirty()", "fn", level.nonVerbose);

    players = level.players;
    for (i = 0; i < players.size; i++)
    {
        if (isDefined(players[i].admin))
        {
            players[i].admin.isAdminMenuDirty = true;
        }
    }
}

/**
 * @brief Are enough players alive to permit spawning a new player?
 *
 * @returns boolean Whether to allow spawning or not
 */
enoughPlayersAlive()
{
    debugPrint("in _players::enoughPlayersAlive()", "fn", level.nonVerbose);

    if ((level.activePlayers == 0) ||
        (level.alivePlayers / level.activePlayers >= level.dvar["game_spawn_requirement"]))
    {
        return true;
    }
    return false;
}

spawnPlayerWhenMorePlayersAreAlive()
{
    debugPrint("in _players::spawnPlayerWhenMorePlayersAreAlive()", "fn", level.lowVerbosity);

    self endon("disconnect");
    level endon("game_ended");
    //     self endon("spawned");
    self endon("spawned_player");

    debugPrint("Waiting until enough players are alive to spawn " + self.name, "val");

    while (1)
    {
        wait 2;
        if (enoughPlayersAlive())
        {
            self joinAllies();
            self spawnPlayer();
        }
    }
}

/**
 * @brief Changes a player's class
 *
 * @param cost integer How much we charged they player to change their class
 *
 * @returns nothing
 */
changeClass(cost)
{
    debugPrint("in _players::changeClass()", "fn", level.nonVerbose);
    debugPrint("in _players::changeClass()", "val");

    // Force dead player's body to be their old class, not their new class
    self setclientdvar("ui_loadout_class", self.curClass);
    self suicide();
    wait 0.05;

    // Spawn the player as their new class
    self.curClass = self.class;
    self setclientdvar("ui_loadout_class", self.curClass);
    self.mayRespawn = true;
    self joinAllies();
    self spawnPlayer();
    self iprintlnbold(&"ROTUSCRIPT_CLASS_CHANGED_TO", self.curClass, cost);
}

/**
 * @brief Waits until intermission to change a player's class
 * @deprecated
 * @returns nothing
 */
changeClassNextIntermission()
{
    debugPrint("in _players::changeClassNextIntermission()", "fn", level.nonVerbose);

    self endon("disconnect");
    level endon("game_ended");
    self endon("join_spectator");
    self endon("menu_changeclass_allies_closed");

    debugPrint("Waiting until wave intermission to change " + self.name + " class from " + self.curClass + " to " + self.class, "val");

    while (1)
    {
        level waittill("wave_finished");
        wait 1;
        debugPrint("Wave intermission began, changing class of " + self.name, "val");
        self changeClass();
        break;
    }
}

spawnPlayerNextIntermission(preserveState)
{
    debugPrint("in _players::spawnPlayerNextIntermission()", "fn", level.nonVerbose);

    self endon("disconnect");
    level endon("game_ended");
    self endon("spawned_player");

    debugPrint("Waiting until wave intermission to spawn " + self.name, "val");

    if (!isDefined(preserveState))
    {
        preserveState = false;
    }

    while (1)
    {
        level waittill("wave_finished");
        wait 1;
        debugPrint("Wave intermission began, trying to spawn " + self.name, "val");
        self.curClass = self.class;
        self.mayRespawn = true;
        self joinAllies();
        self spawnPlayer(preserveState);
    }
}

spawnPlayer(preserveState)
{
    debugPrint("in _players::spawnPlayer()", "fn", level.nonVerbose);

    debugPrint(self.name + ": sessionstate: " + self.sessionstate, "val");
    debugPrint(self.name + ": sessionteam: " + self.sessionteam, "val");
    debugPrint("level.waveIntermission: " + level.waveIntermission, "val");

    debugPrint(self.name + " spawning as " + self.class, "val");

    if (!isDefined(preserveState))
    {
        preserveState = false;
    }

    if (level.gameEnded)
    {
        return;
    }

    if (self.sessionteam == "spectator")
    {
        debugPrint(self.name + "'s self.sessionteam is spectator, aborting spawnPlayer()", "val");
        return;
    }

    debugPrint(self.name + " about to emit 'spawned' signal", "val");
    self notify("spawned");

    // Setting neccesary variables
    self.team = self.pers["team"];
    self.sessionteam = self.team;
    self.sessionstate = "playing";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;

    if (!preserveState)
    {
        self.health = 100;
        self.infected = false;
    }
    self.headicon = "";

    self.hasDoneCombat = false;
    self.visible = true;
    self.isTargetable = true;
    self.inTrance = false;
    self.trance = "";
    self.isDown = false;
    self.isZombie = false;
    self.isBusy = false;
    self.hasFlashLight = true;
    self.flaslightOn = false;
    self.hasParachute = false;
    self.isObj = false;
    self.isParachuting = false;
    self.god = false;
    self.isActive = true;
    self.isSpectating = false;
    self.canUse = true;
    self.entoxicated = false;
    self.onTurret = false;
    self.tweaksOverride = 0;
    self.tweaksPermanent = 0;
    self.tweakBrightness = "0.25";
    self.tweakContrast = "1.4";
    self.tweakDarkTint = "1 1 1";
    self.tweakLightTint = "1 1 1";
    self.tweakDesaturation = "0";
    self.tweakInvert = "0";
    self.tweakFovScale = 1;
    self.canTeleport = true;
    self.canUseSpecial = true;
    self.specialRecharge = 100.0; // Just to avoid bugs with UI bar.
    self.incdammod = 1;
    self.emplacedC4 = [];
    self.emplacedTnt = [];
    self setStatusIcon("");

    // Getting spawn loc and spawning
    if (level.playerspawns == "")
    {
        spawn = getRandomTdmSpawn();
    }
    else
    {
        spawn = getRandomEntity(level.playerspawns);
    }

    origin = spawn.origin;
    angles = spawn.angles;

    self spawn(origin, angles);

    if (self.persData.class != self.curClass)
    {
        resetUnlocks();
    }

    // Setting random player class model
    self.curClass = self.class;
    self.persData.class = self.curClass;

    self scripts\players\_playermodels::setPlayerClassModel(self.curClass);

    self setclientdvars("cg_thirdperson", 0, "ui_upgradepoints", self.points, "ui_specialtext", "@ROTUUI_SPECIAL_UNAVAILABLE", "ui_specialrecharge", 1);

    self scripts\players\_abilities::loadClassAbilities(self.curClass);

    self SetMoveSpeedScale(self.speed);
    if (!preserveState)
    {
        self.health = self.maxhealth;
        self updateHealthHud(1);
    }
    else
    {
        self.health = int(self.savedHealthRatio * self.maxhealth);
        self updateHealthHud(self.health / self.maxhealth);
    }

    waittillframeend;

    /// Set up action slots
    /// action slot 4 is reserved for class ability items, such as medkits for medics
    self.nightvision = true; // Enable night vision by default, at no cost
    if (self.nightvision)
    {
        self setActionSlot(1, "nightvision");
    }

    // Give weapons
    self scripts\players\_weapons::initPlayerWeapons();
    self scripts\players\_weapons::givePlayerWeapons();

    self.emplacedClaymores = [];
    // protect player for 2 seconds after spawning
    self.god = true;
    self thread removeSpawnProtection(2);

    // thread some functions
    // these looped functions should endon("spawn") to ensure
    // only one instance is running in case we are respawning a player
    self thread scripts\players\_usables::checkForUsableObjects();
    self thread scripts\players\_weapons::watchWeaponUsage();
    self thread scripts\players\_weapons::watchWeaponSwitching();
    self thread scripts\players\_weapons::watchC4();
    self thread scripts\players\_weapons::watchTnt();
    self thread scripts\players\_weapons::watchClaymores();
    self thread scripts\players\_weapons::deleteExplosivesOnDisconnect();
    self thread scripts\players\_abilities::watchSpecialAbility();
    self thread watchHP();

    self thread scripts\server\_welcome::onPlayerSpawn();
    self thread scripts\players\_spree::onPlayerSpawn();

    self.isAlive = true;
    self.spawnCount++;
    self.isChangingClass = false;
    level.alivePlayers++;
    level.activePlayers++;
    debugPrint(self.name + ": sessionstate: " + self.sessionstate, "val");
    debugPrint(self.name + ": sessionteam: " + self.sessionteam, "val");
    self notify("spawned_player");
    debugPrint("Spawned " + self.name, "val");
}

removeSpawnProtection(time)
{
    debugPrint("in _players::removeSpawnProtection()", "fn", level.nonVerbose);

    while (time > 0)
    {
        time -= 1;
        wait 1;
    }
    // We don't ensure self is defined here, because we would rather have the runtime
    // error than run the risk that a player's trickery might leave the .god property
    // set to true.
    self.god = false;
}

resetUnlocks()
{
    debugPrint("in _players::resetUnlocks()", "fn", level.nonVerbose);

    self.unlock["primary"] = 0;
    self.unlock["secondary"] = 0;
    self.unlock["extra"] = 0;
    self.persData.unlock["primary"] = 0;
    self.persData.unlock["secondary"] = 0;
    self.persData.unlock["extra"] = 0;

    self.persData.primary = getdvar("surv_" + self.class + "_unlockprimary" + self.unlock["primary"]);
    self.persData.secondary = getdvar("surv_" + self.class + "_unlocksecondary" + self.unlock["secondary"]);

    self.persData.primaryAmmoClip = WeaponClipSize(self.persData.primary);
    self.persData.primaryAmmoStock = WeaponMaxAmmo(self.persData.primary);

    self.persData.secondaryAmmoClip = WeaponClipSize(self.persData.secondary);
    self.persData.secondaryAmmoStock = WeaponMaxAmmo(self.persData.secondary);

    self.persData.extraAmmoClip = 0;
    self.persData.extraAmmoStock = 0;
}

setStatusIcon(icon)
{
    debugPrint("in _players::setStatusIcon()", "fn", level.veryLowVerbosity);

    if (self.overrideStatusIcon == "")
    {
        self.statusicon = icon;
    }
}

bounce(direction)
{
    debugPrint("in _players::bounce()", "fn", level.nonVerbose);

    self endon("disconnect");
    self endon("death");
    for (i = 0; i < 2; i++)
    {
        self.health = (self.health + 899);
        self finishPlayerDamage(self, self, 900, 0, "MOD_PROJECTILE", "rpg_mp", direction, direction, "none", 0);
        wait 0.05;
    }
}

fullHeal(speed)
{
    debugPrint("in _players::fullHeal()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");

    while (self.health < self.maxhealth)
    {
        self.health += speed;
        updateHealthHud(self.health / self.maxhealth);
        wait .1;
    }
}

////////////////////////////////////////////////////////
// Increase player upgrade points by amount of 'inc'. //
////////////////////////////////////////////////////////
incUpgradePoints(inc)
{
    debugPrint("in _players::incUpgradePoints()", "fn", level.absurdVerbosity);

    self endon("disconnect");

    if (!isDefined(inc) || !isDefined(self))
        return;

    self.points += inc;
    self.persData.points += inc;
    if (inc > 0)
    {
        self.score += inc;
    }
    self setclientdvar("ui_upgradepoints", self.points);
    self thread upgradeHud(inc);
}

joinAllies()
{
    debugPrint("in _players::joinAllies()", "fn", level.nonVerbose);

    if (level.gameEnded)
    {
        return;
    }

    if (self.pers["team"] != "allies")
    {
        //if (isalive(self))
        //self suicide();

        self.sessionteam = "allies";
        self setclientdvar("g_scriptMainMenu", game["menu_class"]);
        self.pers["team"] = "allies";

        //self spawnPlayer();
    }
}

joinSpectator()
{
    debugPrint("in _players::joinSpectator()", "fn", level.nonVerbose);

    if (level.gameEnded)
    {
        return;
    }

    if (self.pers["team"] != "spectator")
    {
        if (isalive(self))
        {
            // save health ratio, as we may need it later
            self.savedHealthRatio = self.health / self.maxhealth;
            self suicide();
        }

        debugPrint(self.name + " spawning as a spectator", "val");
        self.isActive = false;
        self.zombie = false;
        self.isAlive = false;
        self.isSpectating = true;

        self notify("join_spectator");

        self.pers["team"] = "spectator";
        self.sessionteam = "spectator";
        self.sessionstate = "spectator";

        spawns = getentarray("mp_global_intermission", "classname");
        debugPrint("Trying to spawn " + self.name + " as spectator; spawns.size = " + spawns.size, "val");
        spawn = spawns[randomint(spawns.size)]; /// @bug randomint param 0 bug

        self setclientdvar("cg_thirdperson", 1);

        spawnSpectator(spawn.origin, spawn.angles);
    }
}

spawnSpectator(origin, angles)
{
    debugPrint("in _players::spawnSpectator()", "fn", level.lowVerbosity);

    self notify("spawned");

    resettimeout();

    self.sessionstate = "spectator";
    self.spectatorclient = -1;
    self.friendlydamage = undefined;

    self spawn(origin, angles);
}

revive()
{
    debugPrint("in _players::revive()", "fn", level.nonVerbose);

    if (level.gameEnded)
    {
        return;
    }

    // Give me back my weapons!
    level.alivePlayers++;
    self.isAlive = true;
    weapons = self.lastStandWeapons;

    ammoClip = self.lastStandAmmoClip;
    ammoStock = self.lastStandAmmoStock;

    keptWeapons = self getweaponslist();
    keptAmmoStock = [];
    keptAmmoClip = [];
    for (i = 0; i < keptWeapons.size; i++)
    {
        keptAmmoClip[i] = self getWeaponAmmoClip(keptWeapons[i]);
        keptAmmoStock[i] = self getWeaponAmmoStock(keptWeapons[i]);
    }

    self takeallweapons();

    if (self.lastStandWeapon == "none")
    {
        if (weapons.size == 0)
        {
            if (keptWeapons.size != 0)
            {
                self.lastStandWeapon = keptWeapons[0];
            }
        }
        else
        {
            self.lastStandWeapon = weapons[0];
        }
    }

    self spawn(self.origin, self.angles);

    for (i = 0; i < keptWeapons.size; i++)
    {
        self giveweapon(keptWeapons[i]);
        self setWeaponAmmoClip(keptWeapons[i], keptAmmoClip[i]);
        self setWeaponAmmoStock(keptWeapons[i], keptAmmoStock[i]);
    }
    for (i = 0; i < weapons.size; i++)
    {
        if (!self HasWeapon(weapons[i]))
        {
            self giveweapon(weapons[i]);
            self setWeaponAmmoClip(weapons[i], ammoClip[i]);
            self setWeaponAmmoStock(weapons[i], ammoStock[i]);
        }
    }

    self setspawnweapon(self.lastStandWeapon);
    self switchtoweapon(self.lastStandWeapon);

    list = self getweaponslist();

    // RELOADING PLAYER!
    self setDown(false);
    level scripts\players\_usables::removeUsable(self);
    self.isTargetable = true;
    self notify("revived");

    if (self.infected)
        level scripts\players\_usables::addUsable(self, "infected", &"ROTUSCRIPT_PRESS_USE_TO_CURE", 96);

    self scripts\players\_abilities::loadClassAbilities(self.curClass);

    self setMoveSpeedScale(self.speed);
    self.health = self.maxhealth;

    self updateHealthHud(1);

    /// Fixed: invincibility bug
    self.visible = true;
    self.isTargetable = true;
    self.isGod = false;
    self.god = false;
    self.inTrance = false;
    self.trance = "";
    self notify("end_trance");

    // Remove the 'down' icon from the scoreboard
    setStatusIcon("");
    self defaultHeadicon();

    // Restore night vision after a player is revived
    self.nightvision = true;
    if (self.nightvision)
    {
        self setActionSlot(1, "nightvision");
    }

    self thread scripts\players\_usables::checkForUsableObjects();

    self thread scripts\players\_weapons::watchWeaponUsage();
    self thread scripts\players\_weapons::watchWeaponSwitching();
    // We call watchC4() here because c4 shouldn't work while down, but
    // needs to be restarted upon revive.  We do not call watchClaymores() or
    // watchTnt(), because those should keep working while down.  Calling it here
    // caused an extra instance of watchClaymores() to run every time a player
    // was revived, causing the emplacedClaymores array to be wrong.
    self thread scripts\players\_weapons::watchC4();
    self thread scripts\players\_weapons::deleteExplosivesOnDisconnect();

    wait 0.05;
    self switchtoweapon(self.lastStandWeapon);
} // End function revive()

execClientCommand(cmd)
{
    debugPrint("in _players::execClientCommand()", "fn", level.nonVerbose);

    self setClientDvar("ui_clientcmd", cmd);
    self openMenuNoMouse(game["menu_clientcmd"]);
}
