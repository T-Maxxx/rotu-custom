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

#include scripts\include\waypoints;
#include scripts\include\entities;
#include scripts\include\physics;
#include scripts\include\hud;
#include scripts\include\utility;

init()
{
    debugPrint("in _bots::init()", "fn", level.nonVerbose);

    precache();

    loadWaypoints();

    level.bots = [];
    level.botsAlive = 0;
    level.zomInterval = .2;
    level.zomSpeedScale = .2 / level.zomInterval;
    level.zomPreference = 64 * 64;
    level.zombieSight = 2048;
    level.zomIdleBehavior = "";
    level.zomTarget = "player_closest";
    level.loadBots = 1;
    level.botsLoaded = false;
    level.zomTargets = [];
    level.slowBots = 1;
    level.burningZombieDemeritSize = getDvarInt("surv_burning_zombie_demerit_size");

    wait 1;
    if (level.loadBots)
    {
        loadBots(level.dvar["bot_count"]);
    }

    scripts\bots\_types::initZomTypes();

    scripts\bots\_types::initZomModels();

    level.botsLoaded = true;
}

precache()
{
    debugPrint("in _bots::precache()", "fn", level.nonVerbose);

    // weapons used for animations
    precacheitem("bot_zombie_walk_mp");
    precacheitem("bot_zombie_stand_mp");
    precacheitem("bot_zombie_run_mp");
    precacheitem("bot_zombie_melee_mp");
    precacheitem("bot_dog_idle_mp");
    precacheitem("bot_dog_run_mp");
    precacheitem("defaultweapon_mp");

    /*precachemodel("body_sp_russian_loyalist_a_dead");
    precachemodel("body_sp_russian_loyalist_b_dead");
    precachemodel("body_sp_russian_loyalist_c_dead");
    precachemodel("body_sp_russian_loyalist_d_dead");*/

    precachemodel("izmb_zombie1_body");
    precachemodel("izmb_zombie2_body");
    precachemodel("izmb_zombie2_head");
    precachemodel("izmb_zombie3");
    precachemodel("body_complete_sp_zakhaevs_son");

    precachemodel("bo_quad");

    precachemodel("cyclops");
    //precachemodel("zombie_wolf");

    precachemodel("body_complete_sp_vip");
    precachemodel("body_complete_sp_russian_farmer");

    precachemodel("tag_origin");

    precachemodel("german_sheperd_dog");
    precachemodel("body_hellknight");
    precachemodel("cyclops");

    //PreCacheShellShock("zombiedamage");
    preCacheShellShock("boss");
    precacheshellshock("toxic_gas_mp");

    level.burningFX = loadfx("fire/firelp_med_pm");
    level.burningDogFX = loadfx("fire/firelp_small_pm_rotu");
    level.toxicFX = loadfx("misc/toxic_gas");
    level.explodeFX = Loadfx("explosions/pyromaniac");
    level.soulFX = loadfx("misc/soul");
    level.goundSpawnFX = loadfx("misc/ground_rising");
    level.soulspawnFX = loadfx("misc/soulspawn");
}

loadBots(amount)
{
    debugPrint("in _bots::loadBots()", "fn", level.nonVerbose);

    for (i = 0; i < amount; i++)
    {

        bot = addtestclient();

        if (!isdefined(bot))
        {
            println("Could not add bot");
            i = i - 1;
            wait 1;
            continue;
        }

        bot loadBot(); // No thread
    }
    level notify("bots_loaded");
}

loadBot()
{
    debugPrint("in _bots::loadBot()", "fn", level.nonVerbose);

    level.bots[level.bots.size] = self;

    self.isBot = true;
    self.hasSpawned = false;
    self.spawnPoint = undefined;

    // Wait till properly connected
    while (!isdefined(self.pers["team"]))
    {
        wait .05;
    }

    self botJoinAxis();

    wait .1;
    self setStat(512, 100); // Yes we are indeed a bot
    self setrank(255, 0);
    self.linkObj = spawn("script_model", (0, 0, 0));
}

botJoinAxis()
{
    debugPrint("in _bots::botJoinAxis()", "fn", level.nonVerbose);

    self.sessionteam = "axis";
    self.pers["team"] = "axis";
}

//SPAWNING BOTS
getAvailableBot()
{
    debugPrint("in _bots::getAvailableBot()", "fn", level.fullVerbosity);

    for (i = 0; i < level.bots.size; i++)
    {
        if (level.bots[i].hasSpawned == false)
        {
            return level.bots[i];
        }
    }
    return undefined;
}

spawnZombie(type, spawnpoint, bot)
{
    debugPrint("in _bots::spawnZombie()", "fn", level.fullVerbosity);

    if (!isdefined(bot))
    {
        bot = getAvailableBot();
        if (!isdefined(bot))
        {
            return undefined;
        }
    }

    bot.readyToBeKilled = false;
    bot.hasSpawned = true;
    bot.currentTarget = undefined;
    bot.targetPosition = undefined;
    bot.type = type;

    bot.team = bot.pers["team"];
    bot.sessionteam = bot.team;
    bot.sessionstate = "playing";
    bot.spectatorclient = -1;
    bot.killcamentity = -1;
    bot.archivetime = 0;
    bot.psoffsettime = 0;
    bot.statusicon = "";

    bot scripts\bots\_types::loadZomStats(type);
    if (!isdefined(bot.meleeSpeed))
    {
        iprintlnbold("ERROR");
        setdvar("error_0", type);
        setdvar("error_1", bot.name);
        wait 5;
    }

    bot.maxHealth = int(bot.maxHealth * level.dif_zomHPMod);
    bot.health = bot.maxHealth;
    bot.isDoingMelee = false;
    bot.damagedBy = [];

    bot.alertLevel = 0; // Has this zombie been alerted?
    bot.myWaypoint = undefined;
    bot.underway = false;
    bot.canTeleport = true;
    bot.quake = false;

    bot scripts\bots\_types::loadAnimTree(type);

    bot.animWeapon = bot.animation["stand"];
    bot TakeAllWeapons();
    bot.pers["weapon"] = bot.animWeapon;
    bot giveweapon(bot.pers["weapon"]);
    bot givemaxammo(bot.pers["weapon"]);
    bot setspawnweapon(bot.pers["weapon"]);
    bot switchtoweapon(bot.pers["weapon"]);

    if (isdefined(spawnpoint.angles))
    {
        bot spawn(spawnpoint.origin, spawnpoint.angles);
    }
    else
    {
        bot spawn(spawnpoint.origin, (0, 0, 0));
    }

    level.botsAlive++;
    wait 0.05;

    bot scripts\bots\_types::loadZomModel(type);
    bot freezeControls(true);

    bot.linkObj.origin = bot.origin;
    bot.linkObj.angles = bot.angles;

    bot.incdammod = 1;
    if ((bot.type != "tank" && bot.type != "boss") ||
        (level.dvar["zom_spawnprot_tank"]))
    {
        if (level.dvar["zom_spawnprot"])
        {
            bot.incdammod = 0;
            bot thread endSpawnProt(level.dvar["zom_spawnprot_time"], level.dvar["zom_spawnprot_decrease"]);
        }
    }

    wait 0.05;
    bot scripts\bots\_types::onSpawn(type);
    bot linkto(bot.linkObj);
    bot zomGoIdle();
    bot thread zomMain();
    bot thread zomGroan();
    bot.readyToBeKilled = true;

    /*if (level.zomTarget != "")
    {
        if (level.zomTarget == "player_closest")
        {
            ent = bot getClosestPlayer();
            if (isdefined(ent))
            bot zomSetTarget(ent.origin);
        }
        else
        bot zomSetTarget(bot getClosestEntity(level.zomTarget).origin);
    }*/
    //if (isdefined(spawnpoint.target))
    //bot zomSetTarget(bot getRandomEntity(spawnpoint.target).origin);

    return bot;
}

/**
 * @brief Ends zombie spawn invincibility after a time, or over time
 *
 * @param time integer The time in seconds
 * @param decrease boolean Decrease gradually over time?
 *
 * @returns nothing
 */
endSpawnProt(time, decrease)
{
    debugPrint("in _bots::endSpawnProt()", "fn", level.highVerbosity);

    self endon("death");

    if (decrease)
    {
        for (i = 0; i < 10; i++)
        {
            wait time / 10;
            self.incdammod += .1;
        }
    }
    else
    {
        wait time;
        self.incdammod = 1;
    }
}

// BOTS MAIN

Callback_BotDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
    debugPrint("in _bots::Callback_BotDamage()", "fn", level.fullVerbosity);

    if (!self scripts\bots\_types::onDamage(self.type, sMeansOfDeath, sWeapon, iDamage, eAttacker))
    {
        return;
    }
    self.alertLevel += 200;

    if ((isdefined(eAttacker)) && (isplayer(eAttacker)))
    {
        if (eAttacker.curClass == "armored")
        {
            if (sMeansOfDeath == "MOD_MELEE")
            {
                if (iDamage > self.health)
                {
                    eAttacker scripts\players\_abilities::rechargeSpecial(self.health / 25);
                }
                else
                {
                    eAttacker scripts\players\_abilities::rechargeSpecial(iDamage / 25);
                }
            }
        }
        if (eAttacker.curClass == "scout" && sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
        {
            eAttacker scripts\players\_abilities::rechargeSpecial(iDamage / 40);
        }
        // Medic's Transfusion primary ability
        if ((eAttacker.curClass == "medic") && (eAttacker.transfusion) && (distance(eAttacker.origin, self.origin) < 48))
        {
            health = int(0.15 * iDamage);
            eAttacker.health += health;
            if (eAttacker.health > eAttacker.maxHealth)
            {
                eAttacker.health = eAttacker.maxHealth;
            }
            eAttacker updateHealthHud(eAttacker.health / eAttacker.maxHealth);
        }

        if (!isDefined(self.incdammod))
        {
            debugPrint("BUG: self.incdammod not set; setting to 1 for : " + self.name, "val");
            self.incdammod = 1;
        }
        iDamage = int(iDamage * eAttacker scripts\players\_abilities::getDamageModifier(sWeapon, sMeansOfDeath, self, iDamage) * self.incdammod);

        //         eAttacker notify("damaged_bot", self);
        eAttacker notify("damaged_bot", self, sMeansOfDeath);

        eAttacker scripts\players\_damagefeedback::updateDamageFeedback(0);
        if (self.isBot)
        {
            self thread addToAssist(eAttacker, iDamage);
        }
    }

    if (self.sessionteam == "spectator")
    {
        return;
    }

    if (!isDefined(vDir))
    {
        iDFlags |= level.iDFLAGS_NO_KNOCKBACK;
    }

    if (!(iDFlags & level.iDFLAGS_NO_PROTECTION))
    {
        if (iDamage < 1)
        {
            iDamage = 1;
        }

        //         // for debugging many_bosses damage bugs
        //         if ((isDefined(level.waveType)) && (level.waveType == "many_bosses")) {
        //             if (isDefined(eAttacker.name)) {attackerName = eAttacker.name;}
        //             else {attackerName = "N/A";}
        //             noticePrint("finishPlayerDamage(," + attackerName + "," + iDamage + ",N/A," + sMeansOfDeath + "," + sWeapon + ",,,,)");
        //         }
        self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
    }
}

addToAssist(player, damage)
{
    debugPrint("in _bots::addToAssist()", "fn", level.fullVerbosity);

    for (i = 0; i < self.damagedBy.size; i++)
    {
        if (self.damagedBy[i].player == player)
        {
            self.damagedBy[i].damage += damage;
            return;
        }
    }
    struct = spawnstruct();
    struct.player = player;
    struct.damage = damage;
    self.damagedBy[self.damagedBy.size] = struct;
}

Callback_BotKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
    debugPrint("in _bots::Callback_BotKilled()", "fn", level.veryHighVerbosity);

    self unlink();

    if (self.sessionteam == "spectator")
    {
        return;
    }

    if (sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
    {
        sMeansOfDeath = "MOD_HEAD_SHOT";
    }

    if (level.dvar["zom_orbituary"])
    {
        obituary(self, attacker, sWeapon, sMeansOfDeath);
    }

    self.sessionstate = "dead";

    isBadKill = false;

    if (isplayer(attacker) && attacker != self)
    {
        if ((self.type == "burning") ||
            (self.type == "burning_dog") ||
            (self.type == "burning_tank"))
        {
            // No demerits if weapon is claymore or defense turrets, since player
            // has no control over when it detonates/fires
            switch (sWeapon)
            {
            case "claymore_mp": // Fall through
            case "turret_mp":
            case "none": // minigun and grenade turrets are "none"
                // Do nothing
                break;
            default:
                players = level.players;
                for (i = 0; i < players.size; i++)
                {
                    if (!isDefined(players[i]))
                    {
                        continue;
                    }
                    if (attacker != players[i])
                    {
                        if ((!players[i].isDown) &&
                            (distance(self.origin, players[i].origin) < 150))
                        {
                            attacker thread scripts\players\_rank::increaseDemerits(level.burningZombieDemeritSize, "burning");
                            isBadKill = true;
                        }
                    }
                }
                break;
            }
        }
        if (!isBadKill)
        {
            // No credit for kills that hurt teammates
            attacker.kills++;

            attacker thread scripts\players\_rank::giveRankXP("kill");
            attacker thread scripts\players\_spree::checkSpree();

            if (attacker.curClass == "stealth")
            {
                attacker scripts\players\_abilities::rechargeSpecial(10);
            }
            attacker scripts\players\_players::incUpgradePoints(10 * level.rewardScale);
            giveAssists(attacker);
        }
    }

    corpse = self scripts\bots\_types::onCorpse(self.type);
    if (self.soundType == "zombie")
    {
        self zomSound(0, "zom_death", randomint(6));
    }

    if (corpse > 0)
    {
        if (self.type == "toxic")
        {
            deathAnimDuration = 20;
        }

        body = self clonePlayer(deathAnimDuration);

        if (corpse > 1)
        {
            thread delayStartRagdoll(body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath);
        }
    }
    else
    {
        self setorigin((0, 0, -10000));
    }

    level.dif_killedLast5Sec++;

    wait 1;
    self.hasSpawned = false;
    level.botsAlive -= 1;

    //level.zom_deaths ++;
    level notify("bot_killed");
}

giveAssists(killer)
{
    debugPrint("in _bots::giveAssists()", "fn", level.highVerbosity);

    for (i = 0; i < self.damagedBy.size; i++)
    {
        struct = self.damagedBy[i];
        if (isdefined(struct.player))
        {
            if (struct.player.isActive && struct.player != killer)
            {
                struct.player.assists++;
                if (struct.damage > 400)
                {
                    struct.player thread scripts\players\_rank::giveRankXP("assist5");
                    struct.player thread scripts\players\_players::incUpgradePoints(10 * level.rewardScale);
                }
                else if (struct.damage > 200)
                {
                    struct.player thread scripts\players\_rank::giveRankXP("assist4");
                    struct.player thread scripts\players\_players::incUpgradePoints(7 * level.rewardScale);
                }
                else if (struct.damage > 100)
                {
                    struct.player thread scripts\players\_rank::giveRankXP("assist3");
                    struct.player thread scripts\players\_players::incUpgradePoints(5 * level.rewardScale);
                }
                else if (struct.damage > 50)
                {
                    struct.player thread scripts\players\_rank::giveRankXP("assist2");
                    struct.player thread scripts\players\_players::incUpgradePoints(3 * level.rewardScale);
                }
                else if (struct.damage > 25)
                {
                    struct.player thread scripts\players\_rank::giveRankXP("assist1");
                    struct.player thread scripts\players\_players::incUpgradePoints(3 * level.rewardScale);
                }
                else if (struct.damage > 0)
                {
                    struct.player thread scripts\players\_rank::giveRankXP("assist0");
                    struct.player thread scripts\players\_players::incUpgradePoints(2 * level.rewardScale);
                }
            }
        }
    }
    self.damagedBy = undefined;
}

zomMain()
{
    debugPrint("in _bots::zomMain()", "fn", level.veryHighVerbosity);

    self endon("disconnect");
    self endon("death");

    self.lastTargetWp = -2;
    self.nextWp = -2;
    //self.intervalScale = 1;
    update = 0;

    while (1)
    {
        switch (self.status)
        {
        case "idle":
            zomWaitToBeTriggered();

            switch (level.zomIdleBehavior)
            {
            case "magic":
                if (update == 5)
                {
                    if (level.zomTarget != "")
                    {
                        if (level.zomTarget == "player_closest")
                        {
                            ent = self getClosestTarget();
                            if (isDefined(ent))
                            {
                                self zomSetTarget(ent.origin);
                            }
                        }
                        else
                        {
                            self zomSetTarget(getRandomEntity(level.zomTarget).origin);
                        }
                    }
                    else
                    {
                        ent = self getClosestTarget();
                        if (isdefined(ent))
                        {
                            self zomSetTarget(ent.origin);
                        }
                    }
                    update = 0;
                }
                else
                {
                    update++;
                }
                break;
            }

            break;

        case "triggered":

            if ((isDefined(self.bestTarget)) && ((update == 10) || (self.bestTarget.isDown)))
            { // find new target when current target goes down
                self.bestTarget = zomGetBestTarget();
                update = 0;
            }
            else
            {
                update++;
            }
            if (isdefined(self.bestTarget))
            {
                self.lastMemorizedPos = self.bestTarget.origin;
                if (!checkForBarricade(self.bestTarget.origin))
                {
                    if (distance(self.bestTarget.origin, self.origin) < self.meleeRange)
                    {
                        self thread zomMoveLockon(self.bestTarget, self.meleeTime, self.meleeSpeed);
                        self zomMelee();
                        //doWait = false;
                    }
                    else
                    {
                        zomMovement();
                        self zomMoveTowards(self.bestTarget.origin);
                        //doWait = false;
                    }
                }
                else
                {
                    self zomMelee();
                }
            }
            else
            {
                self zomGoSearch();
            }

            break;

        case "searching":

            zomWaitToBeTriggered();
            if (isdefined(self.lastMemorizedPos))
            {
                if (!checkForBarricade(self.lastMemorizedPos))
                {
                    if (distance(self.lastMemorizedPos, self.origin) > 48)
                    {
                        zomMovement();
                        self zomMoveTowards(self.lastMemorizedPos);
                        //doWait = false;
                    }
                    else
                    {
                        self.lastMemorizedPos = undefined;
                    }
                }
                else
                {
                    self zomMelee();
                }
            }
            else
            {
                zomGoIdle();
            }

            break;

        case "stunned":
            wait 1.25;
            zomGoIdle();
            break;
        }

        //if (doWait)
        wait level.zomInterval;
    }
}

zomGetBestTarget()
{
    debugPrint("in _bots::zomGetBestTarget()", "fn", level.fullVerbosity);

    if (!isDefined(self.currentTarget))
    {
        for (i = 0; i < level.players.size; i++)
        {
            player = level.players[i];
            if (zomSpot(player))
            {
                self.currentTarget = player;
                return player;
            }
            wait 0.05;
        }
        // if zombie can't see any players, just grab the closest player
        ent = self getClosestTarget();
        if (isDefined(ent))
        {
            self zomSetTarget(ent.origin);
            return ent;
        }
    }
    else
    {
        if (!zomSpot(self.currentTarget))
        {
            self.currentTarget = undefined;
            return undefined;
        }

        targetdis = distancesquared(self.origin, self.currentTarget.origin) - level.zomPreference;
        for (i = 0; i < level.players.size; i++)
        {
            player = level.players[i];
            if (!isDefined(player))
            {
                continue;
            }
            if (distancesquared(self.origin, player.origin) < targetdis)
            {
                if (zomSpot(player))
                {
                    self.currentTarget = player;
                    return player;
                }
            }
        }
        return self.currentTarget;
    }
}

zomMovement()
{
    // 12th most-called function (2% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    self.cur_speed = 0;

    if ((self.alertLevel >= 200 && (!self.walkOnly || self.quake)) || self.sprintOnly)
    {
        self setanim("sprint");
        self.cur_speed = self.runSpeed;
        if (self.quake)
        {
            Earthquake(0.25, .3, self.origin, 380);
        }

        if (level.dvar["zom_dominoeffect"])
        {
            thread alertZombies(self.origin, 480, 5, self);
        }
    }
    else
    {
        self setanim("walk");
        self.cur_speed = self.walkSpeed;
        if (self.quake)
        {
            Earthquake(0.17, .3, self.origin, 320);
        }
    }
}

zomGoIdle()
{
    debugPrint("in _bots::zomGoIdle()", "fn", level.fullVerbosity);

    self setanim("stand");
    self.cur_speed = 0;
    self.alertLevel = 0;
    self.status = "idle";
    //iprintlnbold("IDLE!");
}

zomGoStunned()
{
    debugPrint("in _bots::zomGoStunned()", "fn", level.fullVerbosity);

    // no stunning in final wave!
    if (level.currentWave < level.totalWaves)
    {
        self setanim("stand");
        self.cur_speed = 0;
        self.alertLevel = 0;
        self.status = "stunned";
        //iprintlnbold("STUNNED!");
    }
}

zomGoTriggered()
{
    debugPrint("in _bots::zomGoTriggered()", "fn", level.absurdVerbosity);

    self.status = "triggered";
    //self.update = 10;
    self.bestTarget = zomGetBestTarget();
    //iprintlnbold("TRIGGERED!");
}

zomGoSearch()
{
    debugPrint("in _bots::zomGoSearch()", "fn", level.fullVerbosity);

    self.status = "searching";
    //iprintlnbold("SEARCHING!");
}

zomWaitToBeTriggered()
{
    // 17th most-called function (1% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    for (i = 0; i < level.players.size; i++)
    {
        player = level.players[i];
        if (self zomSpot(player))
        {
            self zomGoTriggered();
            break;
        }
    }
}

zomSpot(target)
{
    // 4th most-called function (6% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    if (!isDefined(target))
    {
        return false;
    }
    if (!target.isObj)
    {
        if (!target.isAlive)
            return false;

        if (!target.isTargetable)
            return false;
    }

    if (!target.visible)
        return false;

    distance = distance(self.origin, target.origin);

    if (distance > level.zombieSight)
        return false;

    /*switch (target getStance())
  {
    case "stand":
    if (distance < 256)
    return 1;
    break;
    case "crouch":
    if (distance < 148)
    return 1;
    break;
    case "prone":
    if (distance < 96)
    return 1;
    break;
  }*/

    /*speed = Length(target GetVelocity());

  if (speed > 80 && distance < 256)
  return 1;
  if (speed > 160 && distance < 416)
  return 1;
  if (speed > 240 && distance < 672)
  return 1;*/

    dot = 1.0;

    //if nearest target hasn't attacked me, check to see if it's in front of me
    fwdDir = anglestoforward(self getplayerangles());
    dirToTarget = vectorNormalize(target.origin - self.origin);
    dot = vectorDot(fwdDir, dirToTarget);

    //try see through smoke
    /*if(!SmokeTrace(self GetEyePos(), self.bestTarget GetEyePos()))
  {
    return false;
  }*/

    //in front of us and is being obvious
    if (dot > -0.2)
    {
        //do a ray to see if we can see the target
        if (!target.isObj)
        {
            visTrace = bullettrace(self.origin + (0, 0, 68), target getPlayerHeight(), false, self);
        }
        else
        {
            visTrace = bullettrace(self.origin + (0, 0, 68), target.origin + (0, 0, 20), false, self);
        }
        if (visTrace["fraction"] == 1)
        {
            //line(self.origin + (0,0,68), visTrace["position"], (0,1.0,0));
            return true;
        }
        else
        {
            if (isdefined(visTrace["entity"]))
                if (visTrace["entity"] == target)
                    return true;
            //line(self.origin + (0,0,68), visTrace["position"], (1,0,0));
            return false;
        }
    }

    return false;
}

setAnim(animation)
{
    // 6th most-called function (2% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    if (isdefined(self.animation[animation]))
    {
        self.animWeapon = self.animation[animation];
        self TakeAllWeapons();
        self.pers["weapon"] = self.animWeapon;
        self giveweapon(self.pers["weapon"]);
        self givemaxammo(self.pers["weapon"]);
        //self SetWeaponAmmoClip(self.pers["weapon"], 30);
        //self SetWeaponAmmoStock(self.pers["weapon"], 0);
        self setspawnweapon(self.pers["weapon"]);
        //self switchtoweapon(self.pers["weapon"]); // SetSpawnWeapon is enough.
    }
}

getPlayerHeight()
{
    // 16th most-called function (1% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    stance = self getStance();
    if (stance == "prone")
        return self.origin + (0, 0, 22);
    else if (stance == "crouch")
        return self.origin + (0, 0, 40);
    return self.origin + (0, 0, 68);
}

zomMoveTowards(target_position)
{
    // 13th most-called function (2% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    self endon("disconnect");
    self endon("death");

    //self thread pushOutOfPlayers();

    if (!isdefined(self.myWaypoint))
    {
        self.myWaypoint = getNearestWp(self.origin);
    }

    targetWp = getNearestWp(target_position);

    nextWp = self.nextWp;

    direct = false;
    //
    //if (distancesquared(target_position, self.origin) <= distancesquared(level.Wp[targetWp].origin, self.origin) || targetWp == self.myWaypoint)
    if (self.underway)
    {

        //if (targetWp == self.myWaypoint)
        //
        //if (distancesquared(target_position, self.origin) >= distancesquared(level.Wp[nextWp].origin, self.origin))
        //direct = true;

        if (targetWp == self.myWaypoint) //|| distancesquared(target_position, self.origin) <= distancesquared(level.Wp[nextWp].origin, self.origin)
        {
            direct = true;
            self.underway = false;
            self.myWaypoint = undefined;
        }
        else
        {
            if (!isdefined(nextWp))
                return;
            if (targetWp == nextWp)
            {

                if (distancesquared(target_position, self.origin) <= distancesquared(level.Wp[nextWp].origin, self.origin))
                {
                    direct = true;
                    self.underway = false;
                    self.myWaypoint = undefined;
                }
            }
        }
    }
    else
    {
        //if (self.lastTargetWp != targetWp || self.myWaypoint == nextWp )
        if (targetWp == self.myWaypoint)
        {
            //iprintln(level.wp[getNearestWp(self.origin)].origin+":"+level.wp[getNearestWp(target_position)].origin);
            direct = true;
            self.underway = false;
            self.myWaypoint = undefined;
        }
        else
        {
            //time = GetTime();
            nextWp = AStarSearch(self.myWaypoint, targetWp);
            //newtime = GetTime()-time;
            //iprintlnbold("MILISEC:" + newtime);
            self.nextWp = nextWp;
            self.underway = true;
        }
    }

    //self.lastTargetWp = targetWp;

    //TARGET SET! MOVING!
    //line(self.origin, target_position, (0,0,1));
    // @todo: COD4X-BOTS If we want a cod4x bots support it's the best place for bot movement functions.
    if (direct)
    {
        moveToPoint(target_position, self.cur_speed);
        /*lineCol = (1,0,0);
        line(level.Wp[self.myWaypoint].origin, target_position, lineCol);*/
    }
    else
    {
        /*lineCol = (1,0,0);
        line(level.Wp[self.myWaypoint].origin, level.Wp[nextWp].origin, lineCol);*/
        if (isdefined(nextWp))
        {
            /// @todo BUG: massive runtime errors if not defined, try this hack as a temp fix. map specific?
            /// for some maps, level.wp.size == 0.  Legacy maps do not use the waypoints system
            if (!isDefined(level.Wp[nextWp]))
            {
                errorPrint("level.Wp[nextWp] is undefined on map: " + getdvar("mapname"));
                //self zomGoIdle();
                //return;
            }
            moveToPoint(level.Wp[nextWp].origin, self.cur_speed);
            if (distance(level.Wp[nextWp].origin, self.origin) < 64)
            {
                self.underway = false;
                self.myWaypoint = nextWp;
                //if (self.myWaypoint != nextWp)
                //nextWp = AStarSearch(self.myWaypoint, targetWp);
                //else
                //break;
            }
        }
        /*else

            self zomGoIdle();
        */
    }
}

/* COD4X-BOTS - botLookAtPlayer here. */
zomMoveLockon(player, time, speed)
{
    debugPrint("in _bots::zomMoveLockon()", "fn", level.veryHighVerbosity);

    intervals = int(time / level.zomInterval);
    for (i = 0; i < intervals; i++)
    {
        if (!isDefined(player))
        {
            continue;
        }
        if (!isDefined(self))
        {
            continue;
        }
        dis = distance(self.origin, player.origin);
        if (dis > 48)
        {
            pushOutDir = VectorNormalize((self.origin[0], self.origin[1], 0) - (player.origin[0], player.origin[1], 0));
            self moveToPoint(player.origin + pushOutDir * 32, speed);
            self pushOutOfPlayers();
        }
        targetDirection = vectorToAngles(VectorNormalize(player.origin - self.origin));
        self SetPlayerAngles(targetDirection);
        wait level.zomInterval;
    }
}

pushOutOfPlayers() // ON SELF
{
    debugPrint("in _bots::pushOutOfPlayers()", "fn", level.absurdVerbosity);

    //push out of other players
    //players = level.players;
    players = getentarray("player", "classname");
    for (i = 0; i < players.size; i++)
    {
        player = players[i];

        if (player == self || !isalive(player))
            continue;
        self thread pushout(player.origin);
    }
    for (i = 0; i < level.dynamic_barricades.size; i++)
    {
        if (isdefined(level.dynamic_barricades[i]))
        {
            if (level.dynamic_barricades[i].hp > 0)
                self thread pushout(level.dynamic_barricades[i].origin);
        }
    }
    /*for (i=0; i <level.barricades.size; i++)
  {
    if (isdefined(level.barricades[i]))
    {
        if (level.barricades[i].hp > 0)
        self thread pushout(level.barricades[i].parts[0].startPosition);
    }
  }*/
}

pushout(org)
{
    // 18th most-called function (1% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    linkObj = self.linkObj;
    distance = distance(org, linkObj.origin);
    minDistance = 28;
    if (distance < minDistance) //push out
    {
        pushOutDir = VectorNormalize((linkObj.origin[0], linkObj.origin[1], 0) - (org[0], org[1], 0));
        pushoutPos = linkObj.origin + (pushOutDir * (minDistance - distance));
        linkObj.origin = (pushoutPos[0], pushoutPos[1], self.origin[2]);
    }
}

/* COD4X-BOTS - do melee action here. */
zomMelee()
{
    debugPrint("in _bots::zomMelee()", "fn", level.veryHighVerbosity);

    self endon("disconnect");
    self endon("death");
    self.movementType = "melee";
    /*if (self hasAnim("run"))
    {
        self setAnim("run2melee");
        wait .4;
    }
    else
    {
        self setAnim("stand2melee");
        wait .6;
    }*/
    self setAnim("melee");
    wait .6;
    if (self.quake)
        Earthquake(0.25, .2, self.origin, 380);
    if (isalive(self))
    {
        self zomDoDamage(70);
        self zomSound(0, "zom_attack", randomint(8));
    }
    wait .6;
    /*wait .5;
    if (isalive(self))
    {
        self zombieDoDamage(90, 30);
        self zombieSound(0, "zom_attack", randomint(10));
    }
    wait .5;
    if (isalive(self))
    {
        self zombieDoDamage(90, 30);
        self zombieSound(0, "zom_attack", randomint(10));
    }
    wait .7;*/
    self setAnim("stand");
    //self.movementType = "walk";

    //self setAnim("run");
    //self thread zombieMelee();
}

infection(chance)
{
    debugPrint("in _bots::infection()", "fn", level.medVerbosity);

    if (self.infected)
        return;

    chance = self.infectionMP * chance;
    if (randomfloat(1) < chance)
    {
        self thread scripts\players\_infection::goInfected();
    }
}

/**
 * @brief Moves a zombie to/towards a desired position
 *
 * @param goalPosition vector The desired new position of the zombie
 * @param speed integer ??? How fast the zombie should move
 *
 * @returns nothing
 */
moveToPoint(goalPosition, speed)
{
    // 8th most-called function (2% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    dis = distance(self.linkObj.origin, goalPosition);

    if (dis < speed)
    {
        speed = dis;
    }
    else
    {
        speed = speed * level.zomSpeedScale;
    }

    targetDirection = vectorToAngles(VectorNormalize(goalPosition - self.linkObj.origin));
    step = anglesToForward(targetDirection) * speed;

    self SetPlayerAngles(targetDirection);

    // tentative new position for zombie
    newPos = self.linkObj.origin + step + (0, 0, 40);
    // find ground level below tentative new position
    dropNewPos = dropPlayer(newPos, 200);
    if (isDefined(dropNewPos))
    {
        newPos = (dropNewPos[0], dropNewPos[1], self compareZ(goalPosition[2], dropNewPos[2]));
    }
    // now actually move the zombie to the new position
    self.linkObj moveto(newPos, level.zomInterval, 0, 0);
}

compareZ(goalPositionZ, dropNewZ)
{
    // 9th most-called function (2% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    deltaZ = dropNewZ - self.origin[2];
    limit = 60; //30
    if (deltaZ > limit)
    {
        // new position would be more than 30 units higher than current position
        if (goalPositionZ > dropNewZ)
        {
            // goalPositionZ is even higher, limit delta height to 'limit' units
            return self.origin[2] + limit;
        }
        else
        {
            return goalPositionZ;
        }
    }
    if (deltaZ < -1 * limit)
    {
        // new position would be more than 30 units lower than current position
        if (goalPositionZ < dropNewZ)
        {
            // dropNewZ is even lower, np
            return dropNewZ;
        }
        else
        {
            return goalPositionZ;
        }
    }
    // deltaZ is +/- limit units of current height, so just return the new height
    return dropNewZ;
}

/* COD4X-BOTS Will be useless because of "real melee" hits? */
zomAreaDamage(range)
{
    debugPrint("in _bots::zomAreaDamage()", "fn", level.lowVerbosity);

    for (i = 0; i <= level.players.size; i++)
    {
        target = level.players[i];
        if (isdefined(target) && isalive(target))
        {
            distance = distance(self.origin, target.origin);
            if (distance < range)
            {
                target.isPlayer = true;
                //target.damageCenter = self.Mover.origin;
                target.entity = target;
                target damageEnt(
                    self,                                   // eInflictor = the entity that causes the damage (e.g. a claymore)
                    self,                                   // eAttacker = the player that is attacking
                    int(self.damage * level.dif_zomDamMod), // iDamage = the amount of damage to do
                    "MOD_EXPLOSIVE",                        // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
                    self.pers["weapon"],                    // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
                    self.origin,                            // damagepos = the position damage is coming from
                    //(0,self GetPlayerAngles()[1],0) // damagedir = the direction damage is moving in
                    vectorNormalize(target.origin - self.origin));
            }
        }
    }
}

zomDoDamage(range)
{
    debugPrint("in _bots::zomDoDamage()", "fn", level.highVerbosity);

    meleeRange = range;
    closest = getClosestPlayerArray();
    for (i = 0; i <= closest.size; i++)
    {
        target = closest[i];
        if (isdefined(target))
        {
            distance = distance(self.origin, target.origin);
            if (distance < meleeRange)
            {
                fwdDir = anglestoforward(self getplayerangles());
                dirToTarget = vectorNormalize(target.origin - self.origin);
                dot = vectorDot(fwdDir, dirToTarget);
                if (dot > .5)
                {
                    target.isPlayer = true;
                    //target.damageCenter = self.Mover.origin;
                    target.entity = target;
                    target damageEnt(
                        self,                                   // eInflictor = the entity that causes the damage (e.g. a claymore)
                        self,                                   // eAttacker = the player that is attacking
                        int(self.damage * level.dif_zomDamMod), // iDamage = the amount of damage to do
                        "MOD_MELEE",                            // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
                        self.pers["weapon"],                    // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
                        self.origin,                            // damagepos = the position damage is coming from
                        //(0,self GetPlayerAngles()[1],0) // damagedir = the direction damage is moving in
                        vectorNormalize(target.origin - self.origin));
                    self scripts\bots\_types::onAttack(self.type, target);
                    if (level.dvar["zom_infection"])
                        target infection(self.infectionChance);
                    //target shellshock("zombiedamage", 1);
                    break;
                }
            }
        }
    }
    /*for (i=0; i<level.attackable_obj.size; i++)
    {
        obj = level.attackable_obj[i];
        distance = distance2d(self.origin, obj.origin);
        if (distance <meleeRange )
        {
            fwdDir = anglestoforward(self getplayerangles());
            dirToTarget = vectorNormalize(obj.origin-self.origin);
            dot = vectorDot(fwdDir, dirToTarget);
            if (dot > .5)
            {
                obj notify("damage", self.damage);
            }
        }


    }*/
    for (i = 0; i < level.barricades.size; i++)
    {
        ent = level.barricades[i];
        distance = distance2d(self.origin, ent.origin);
        if (distance < meleeRange * 2)
        {
            ent thread scripts\players\_barricades::doBarricadeDamage(self.damage * level.dif_zomDamMod);
            break;
        }
    }
    for (i = 0; i < level.dynamic_barricades.size; i++)
    {
        ent = level.dynamic_barricades[i];
        distance = distance2d(self.origin, ent.origin);
        if (distance < meleeRange)
        {
            ent thread scripts\players\_barricades::doBarricadeDamage(self.damage * level.dif_zomDamMod);
            break;
        }
    }
}

zomGroan()
{
    debugPrint("in _bots::zomGroan()", "fn", level.veryHighVerbosity);

    self endon("death");
    self endon("disconnect");

    if (self.soundType == "dog")
        return;

    for (;;)
    {
        //self zombieSound(randomfloat(.5), "zom_run", 0);
        if (self.isDoingMelee == false)
        {
            if (self.alertLevel == 0)
            {
            }
            else if (self.alertLevel < 200)
            {
                self zomSound(randomfloat(.5), "zom_walk", randomint(7));
            }
            else
            {
                self zomSound(randomfloat(.5), "zom_run", randomint(6));
            }
        }
        wait 3 + randomfloat(3);
    }
}

zomSound(delay, sound, random)
{
    debugPrint("in _bots::zomSound()", "fn", level.fullVerbosity);

    if (delay > 0)
    {
        self endon("death");
        wait delay;
    }
    sound = sound + random;
    if (isalive(self))
        self playSound(sound);
}

zomSetTarget(target)
{
    debugPrint("in _bots::zomSetTarget()", "fn", level.highVerbosity);

    //wait .5;
    //self.targetPosition = getentarray(target, "targetname")[0].origin;
    //self.alertLevel = 1;
    self zomGoSearch();
    self.lastMemorizedPos = target;
}

checkForBarricade(targetposition)
{
    // 11th most-called function (2% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!
    debugPrint("in _bots::checkForBarricade()", "fn", level.lowVerbosity);

    for (i = 0; i < level.barricades.size; i++)
    {
        ent = level.barricades[i];
        if (self istouching(ent) && ent.hp > 0)
        {
            fwdDir = vectorNormalize(targetposition - self.origin);
            dirToTarget = vectorNormalize(ent.origin - self.origin);
            dot = vectorDot(fwdDir, dirToTarget);
            if (dot > 0 && dot < 1)
            {
                return 1;
            }
        }
    }
    for (i = 0; i < level.dynamic_barricades.size; i++)
    {
        ent = level.dynamic_barricades[i];
        if (distance(self.origin, ent.origin) < 48 && ent.hp > 0)
        {
            fwdDir = vectorNormalize(targetposition - self.origin);
            dirToTarget = vectorNormalize(ent.origin - self.origin);
            dot = vectorDot(fwdDir, dirToTarget);
            if (dot > 0 && dot < 1)
            {
                return 1;
            }
        }
    }
    return 0;
}

alertZombies(origin, distance, alertPower, ignoreEnt)
{
    // 14th most-called function (1.5% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    for (i = 0; i < level.bots.size; i++)
    {
        if (isdefined(ignoreEnt))
        {
            if (level.bots[i] == ignoreEnt)
                continue;
        }
        dist = distance(origin, level.bots[i].origin);
        if (dist < distance)
        {
            zombie = level.bots[i];
            if (isalive(zombie) && isdefined(zombie.status))
            {
                zombie.alertLevel += alertPower;
                //if (!isdefined(zombie.
                //zombie.lastMemorizedPos = origin;
                if (zombie.status == "idle")
                    zombie zomGoSearch();
            }
        }
    }
}
