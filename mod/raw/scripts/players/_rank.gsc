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

#include common_scripts\utility;
#include scripts\include\hud;
#include scripts\include\utility;

init()
{
    debugPrint("in _rank::init()", "fn", level.nonVerbose);

    level.scoreInfo = [];
    level.rankTable = [];

    level.rankedMatch = 1;

    precacheShader("white");

    precacheString(&"ROTUSCRIPT_KICKED_FOR_RANKHACKING");
    precacheString(&"ROTUSCRIPT_KICKED_FOR_PRESTIGEHACKING");
    precacheString(&"ROTUSCRIPT_DEMERIT_1");
    precacheString(&"ROTUSCRIPT_DEMERIT_MANY");
    precacheString(&"ROTUSCRIPT_DEMERIT_CHECK_FIRE");
    precacheString(&"ROTUSCRIPT_DEMERIT_KILL_BURN_NEAR_PLRS");
    precacheString(&"ROTUSCRIPT_DEMERIT_REVIVE");
    precacheString(&"ROTUSCRIPT_DEMERIT_IGNORE_REVIVE");
    precacheString(&"ROTUSCRIPT_DEMERIT_CURE_SELF");
    precacheString(&"ROTUSCRIPT_DEMERIT_IGNORING_CURE_YOURSELF");
    precacheString(&"ROTUSCRIPT_YOU_LOST_POINTS_BECAUSE_DEMERITS");
    precacheString(&"ROTUSCRIPT_RANK_DEMOTED");
    precacheString(&"ROTUSCRIPT_RANK_PLAYER_WAS_DEMOTED");

    registerScoreInfo("kill", 10);
    registerScoreInfo("assist0", 1);
    registerScoreInfo("assist1", 2);
    registerScoreInfo("assist2", 3);
    registerScoreInfo("assist3", 5);
    registerScoreInfo("assist4", 7);
    registerScoreInfo("assist5", 10);
    registerScoreInfo("revive", 50);
    registerScoreInfo("revive_cover", 40); // providing covering fire for a revive
    registerScoreInfo("headshot", 10);
    registerScoreInfo("suicide", 0);
    registerScoreInfo("teamkill", 0);

    registerScoreInfo("challenge", 250);

    /// tableLookup(fileName, keyColumn, keyValue, dataColumn)
    /// tableLookupIString(fileName, keyColumn, keyValue, dataColumn)
    // zero-indexed max number of ranks, i.e. 54
    level.maxRank = int(tableLookup("mp/rankTable.csv", 0, "maxrank", 1));
    // number of prestige levels, i.e. 45
    level.maxPrestige = int(tableLookup("mp/rankIconTable.csv", 0, "maxprestige", 1));

    // For every row/column location in rankIconTable.csv, precache the rank icon
    for (column = 0; column <= level.maxPrestige; column++)
    {
        for (row = 0; row <= level.maxRank; row++)
        {
            precacheShader(tableLookup("mp/rankIconTable.csv", 0, row, column + 1));
        }
    }

    // Load all the basic info about the ranks from rankTable.csv
    rankId = 0;
    rankName = tableLookup("mp/ranktable.csv", 0, rankId, 1);
    assert(isDefined(rankName) && rankName != "");
    while (isDefined(rankName) && rankName != "")
    {
        // rankID, i.e. "pfc1"
        level.rankTable[rankId][1] = tableLookup("mp/ranktable.csv", 0, rankId, 1);
        // rank starts at this rankXP level, i.e. 0
        level.rankTable[rankId][2] = tableLookup("mp/ranktable.csv", 0, rankId, 2);
        // need to earn this many rankXP points while this rank to get next rank, i.e. 10
        level.rankTable[rankId][3] = tableLookup("mp/ranktable.csv", 0, rankId, 3);
        // next rank starts at this rankXP, i.e. 10
        level.rankTable[rankId][7] = tableLookup("mp/ranktable.csv", 0, rankId, 7);
        // localized string name for the rank
        precacheString(tableLookupIString("mp/ranktable.csv", 0, rankId, 16));

        rankId++;
        rankName = tableLookup("mp/ranktable.csv", 0, rankId, 1);
    }

    level.statOffsets = [];
    level.statOffsets["weapon_assault"] = 290;
    level.statOffsets["weapon_lmg"] = 291;
    level.statOffsets["weapon_smg"] = 292;
    level.statOffsets["weapon_shotgun"] = 293;
    level.statOffsets["weapon_sniper"] = 294;
    level.statOffsets["weapon_pistol"] = 295;
    level.statOffsets["perk1"] = 296;
    level.statOffsets["perk2"] = 297;
    level.statOffsets["perk3"] = 298;

    level.numChallengeTiers = 10;

    //buildChallegeInfo();
}

isRegisteredEvent(type)
{
    debugPrint("in _rank::isRegisteredEvent()", "fn", level.lowVerbosity);

    if (isDefined(level.scoreInfo[type]))
    {
        return true;
    }
    else
    {
        return false;
    }
}

registerScoreInfo(type, value)
{
    debugPrint("in _rank::registerScoreInfo()", "fn", level.nonVerbose);

    level.scoreInfo[type]["value"] = value;
}

getScoreInfoValue(type)
{
    debugPrint("in _rank::getScoreInfoValue()", "fn", level.veryHighVerbosity);

    return (level.scoreInfo[type]["value"]);
}

getScoreInfoLabel(type)
{
    debugPrint("in _rank::getScoreInfoLabel()", "fn", level.lowVerbosity);

    return (level.scoreInfo[type]["label"]);
}

getRankInfoMinXP(rankId)
{
    debugPrint("in _rank::getRankInfoMinXP()", "fn", level.absurdVerbosity);

    return int(level.rankTable[rankId][2]);
}

getRankInfoXPAmt(rankId)
{
    debugPrint("in _rank::getRankInfoXPAmt()", "fn", level.absurdVerbosity);

    return int(level.rankTable[rankId][3]);
}

getRankInfoMaxXp(rankId)
{
    debugPrint("in _rank::getRankInfoMaxXp()", "fn", level.nonVerbose);

    return int(level.rankTable[rankId][7]);
}

getRankInfoFull(rankId)
{
    debugPrint("in _rank::getRankInfoFull()", "fn", level.nonVerbose);

    return tableLookupIString("mp/ranktable.csv", 0, rankId, 16);
}

getRankInfoIcon(rankId, prestigeId)
{
    debugPrint("in _rank::getRankInfoIcon()", "fn", level.lowVerbosity);

    return tableLookup("mp/rankIconTable.csv", 0, rankId, prestigeId + 1);
}

getRankInfoUnlockWeapon(rankId)
{
    debugPrint("in _rank::getRankInfoUnlockWeapon()", "fn", level.lowVerbosity);

    return tableLookup("mp/ranktable.csv", 0, rankId, 8);
}

getRankInfoUnlockPerk(rankId)
{
    debugPrint("in _rank::getRankInfoUnlockPerk()", "fn", level.lowVerbosity);

    return tableLookup("mp/ranktable.csv", 0, rankId, 9);
}

getRankInfoUnlockChallenge(rankId)
{
    debugPrint("in _rank::getRankInfoUnlockChallenge()", "fn", level.lowVerbosity);

    return tableLookup("mp/ranktable.csv", 0, rankId, 10);
}

getRankInfoUnlockFeature(rankId)
{
    debugPrint("in _rank::getRankInfoUnlockFeature()", "fn", level.lowVerbosity);

    return tableLookup("mp/ranktable.csv", 0, rankId, 15);
}

getRankInfoUnlockCamo(rankId)
{
    debugPrint("in _rank::getRankInfoUnlockCamo()", "fn", level.lowVerbosity);

    return tableLookup("mp/ranktable.csv", 0, rankId, 11);
}

getRankInfoUnlockAttachment(rankId)
{
    debugPrint("in _rank::getRankInfoUnlockAttachment()", "fn", level.lowVerbosity);

    return tableLookup("mp/ranktable.csv", 0, rankId, 12);
}

getRankInfoLevel(rankId)
{
    debugPrint("in _rank::getRankInfoLevel()", "fn", level.lowVerbosity);

    return int(tableLookup("mp/ranktable.csv", 0, rankId, 13));
}

onPlayerConnect()
{
    debugPrint("in _rank::onPlayerConnect()", "fn", level.nonVerbose);

    //for(;;)
    //{
    //  level waittill( "connected", player );

    self.pers["rankxp"] = self scripts\players\_persistence::statGet("rankxp");
    rankId = self getRankForXp(self getRankXP());
    self.pers["rank"] = rankId;
    self.pers["participation"] = 0;

    self scripts\players\_persistence::statSet("rank", rankId);
    self scripts\players\_persistence::statSet("minxp", getRankInfoMinXp(rankId));
    self scripts\players\_persistence::statSet("maxxp", getRankInfoMaxXp(rankId));
    self scripts\players\_persistence::statSet("lastxp", self.pers["rankxp"]);

    prestige = self getPrestigeLevel();

    self.rankHacker = false;
    if (prestige > 1)
    {
        stat = self getstat(253);
        if (rankId > stat)
        {
            if (rankId < 20)
            {
                self setstat(253, rankId);
            }
            else
            {
                self.rankHacker = true;
                iprintln(&"ROTUSCRIPT_KICKED_FOR_RANKHACKING", self.name);
                Kick(self getEntityNumber());
            }
        }
        else
        {
            if (stat != rankId)
                self setstat(253, rankId);
        }
    }
    self.rankUpdateTotal = 0;

    // for keeping track of rank through stat#251 used by menu script
    // attempt to move logic out of menus as much as possible
    self.cur_rankNum = rankId;
    assertex(isdefined(self.cur_rankNum), "rank: " + rankId + " does not have an index, check mp/ranktable.csv");
    self setStat(251, self.cur_rankNum);

    if (prestige != self getstat(210))
    {
        self.rankHacker = true;
        iprintln(&"ROTUSCRIPT_KICKED_FOR_PRESTIGEHACKING", self.name);
        Kick(self getEntityNumber());
    }

    self setRank(rankId, prestige);
    self.pers["prestige"] = prestige;

    self setclientdvar("ui_lobbypopup", "");

    //player updateChallenges();
    //player.explosiveKills[0] = 0;
    self.xpGains = [];

    self thread scripts\players\_classes::getSkillpoints(rankId);

    // Initial upgrade point bonus for prestige level
    if (!self.hasPreviouslyJoined && prestige)
    {
        scripts\players\_players::incUpgradePoints(int(75 * prestige));
    }
    //}
    //         self thread doDemote();
}

roundUp(floatVal)
{
    debugPrint("in _rank::roundUp()", "fn", level.lowVerbosity);

    if (int(floatVal) != floatVal)
    {
        return int(floatVal + 1);
    }
    else
    {
        return int(floatVal);
    }
}

giveRankXP(type, value)
{
    debugPrint("in _rank::giveRankXP()", "fn", level.veryHighVerbosity);

    self endon("disconnect");

    if (self.rankHacker)
        return;

    /*if ( level.teamBased && (!level.playerCount["allies"] || !level.playerCount["axis"]) )
        return;
    else if ( !level.teamBased && (level.playerCount["allies"] + level.playerCount["axis"] < 2) )
        return;*/

    if (!isDefined(value))
        value = getScoreInfoValue(type);

    if (!isDefined(self.xpGains[type]))
        self.xpGains[type] = 0;

    /*switch( type )
    {
        case "kill":
        case "headshot":
        case "suicide":
        case "teamkill":
        case "assist":
        case "capture":
        case "defend":
        case "return":
        case "pickup":
        case "assault":
        case "plant":
        case "defuse":
            if ( level.numLives >= 1 )
            {
                multiplier = max(1,int( 10/level.numLives ));
                value = int(value * multiplier);
            }
            break;
    }*/

    self.xpGains[type] += value;

    self incRankXP(value);

    if (updateRank())
        self thread updateRankAnnounceHUD();

    //if ( isDefined( self.enableText ) && self.enableText && !level.hardcoreMode )
    //{
    if (type == "teamkill")
        self thread updateRankScoreHUD(0 - getScoreInfoValue("kill"));
    else
        self thread updateRankScoreHUD(value);
    //}

    /*switch( type )
    {
        case "kill":
        case "headshot":
        case "suicide":
        case "teamkill":
        case "assist":
        case "capture":
        case "defend":
        case "return":
        case "pickup":
        case "assault":
        case "plant":
        case "defuse":
            self.pers["summary"]["score"] += value;
            self.pers["summary"]["xp"] += value;
            break;

        case "win":
        case "loss":
        case "tie":
            self.pers["summary"]["match"] += value;
            self.pers["summary"]["xp"] += value;
            break;

        case "challenge":
            self.pers["summary"]["challenge"] += value;
            self.pers["summary"]["xp"] += value;
            break;

        default:
            self.pers["summary"]["misc"] += value;  //keeps track of ungrouped match xp reward
            self.pers["summary"]["match"] += value;
            self.pers["summary"]["xp"] += value;
            break;
    }

    self setClientDvars(
            "player_summary_xp", self.pers["summary"]["xp"],
            "player_summary_score", self.pers["summary"]["score"],
            "player_summary_challenge", self.pers["summary"]["challenge"],
            "player_summary_match", self.pers["summary"]["match"],
            "player_summary_misc", self.pers["summary"]["misc"]
        );*/
}

setPrestige(newPrestige)
{
    debugPrint("in _rank::setPrestige()", "fn", level.lowVerbosity);

    if (true)
    {
        return;
    } // for disabling function
    if (newPrestige > level.maxPrestige)
    {
        return;
    }

    self.pers["prestige"] = newPrestige;
    self setStat(2326, self.pers["prestige"]);
    self setStat(210, self.pers["prestige"]);

    self scripts\players\_persistence::statSet("rankxp", 0);
    self scripts\players\_persistence::statSet("rank", 0);
    self scripts\players\_persistence::statSet("minxp", int(level.rankTable[0][2]));
    self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[0][7]));
    self setStat(252, 0);
    self setStat(253, 0);
    self.pers["rankxp"] = 0;
    self setRank(0, self.pers["prestige"]);
    self thread resetRank(.5);
}

prestigeUp()
{
    debugPrint("in _rank::prestigeUp()", "fn", level.lowVerbosity);

    //if (self.rankHacker)
    //return;

    if (self.pers["prestige"] == level.maxPrestige)
    {
        return;
    }
    if (self getRank() < level.maxRank)
    {
        return;
    }

    self.canGetSpecialWeapons = true;

    //self.pers["rank"] = 0;
    self.pers["prestige"] += int(self.pers["rankxp"] / (getRankInfoMaxXp(level.maxRank) - 10));
    self setStat(2326, self.pers["prestige"]);
    self setStat(210, self.pers["prestige"]);
    /*rankId = 0;
    self.pers["rank"] = 0;
    self setRank(rankId, self.pers["prestige"]);
    wait 100;
    //self scripts\players\_classes::getSkillpoints(rankId);
    wait 0.05;
    self setStat( 252, rankId );
    self setStat( 253, rankId );
    self.pers["rankxp"] = 0;
    self scripts\players\_persistence::statSet( "rankxp", 0 );
    self scripts\players\_persistence::statSet( "rank", rankId );
    self scripts\players\_persistence::statSet( "minxp", int(level.rankTable[rankId][2]) );
    self scripts\players\_persistence::statSet( "maxxp", int(level.rankTable[rankId][7]) );
    self updateRankAnnounceHUD();*/
    self scripts\players\_persistence::statSet("rankxp", 0);
    self scripts\players\_persistence::statSet("rank", 0);
    self scripts\players\_persistence::statSet("minxp", int(level.rankTable[0][2]));
    self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[0][7]));
    self setStat(252, 0);
    self setStat(253, 0);
    self.pers["rankxp"] = 0;
    self setRank(0, self.pers["prestige"]);
    //updateRank();
    self thread resetRank(.5);
}

resetRank(delay)
{
    debugPrint("in _rank::resetRank()", "fn", level.lowVerbosity);

    self endon("disconnect");
    wait delay;
    rankId = self getRankForXp(self getRankXP());
    self.pers["rank"] = rankId;

    self scripts\players\_classes::getSkillpoints(rankId);
}

updateRank()
{
    debugPrint("in _rank::updateRank()", "fn", level.veryHighVerbosity);

    if (self.rankHacker)
        return;

    newRankId = self getRank();
    if (newRankId == self.pers["rank"])
        return false;

    oldRank = self.pers["rank"];
    rankId = self.pers["rank"];
    self.pers["rank"] = newRankId;

    while (rankId <= newRankId)
    {
        self scripts\players\_persistence::statSet("rank", rankId);
        self scripts\players\_persistence::statSet("minxp", int(level.rankTable[rankId][2]));
        self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[rankId][7]));

        // set current new rank index to stat#252
        self setStat(252, rankId);
        self setStat(253, rankId);

        rankId++;
    }
    self logString("promoted from " + oldRank + " to " + newRankId + " timeplayed: " + self scripts\players\_persistence::statGet("time_played_total"));

    self setRank(newRankId, self.pers["prestige"]);
    self scripts\players\_classes::getSkillpoints(newRankId);
    return true;
}

updateRankAnnounceHUD()
{
    debugPrint("in _rank::updateRankAnnounceHUD()", "fn", level.nonVerbose);

    self endon("disconnect");

    self notify("update_rank");
    self endon("update_rank");

    team = self.pers["team"];
    if (!isdefined(team))
        return;

    newRankName = self getRankInfoFull(self.pers["rank"]);

    /*subRank = int(rank_char[rank_char.size-1]);

    if ( subRank == 2 )
    {
        textLabel = newRankName;
        notifyText = &"RANK_ROMANI";
    }
    else if ( subRank == 3 )
    {
        textLabel = newRankName;
        notifyText = &"RANK_ROMANII";
    }
    else
    {
        notifyText = newRankName;
    }

    thread scripts\players\_hud_message::notifyMessage( notifyData );*/

    rank_char = level.rankTable[self.pers["rank"]][1];
    subRank = int(rank_char[rank_char.size - 1]);

    self glowMessage(&"RANK_PROMOTED", "", (0, 1, 0), 5, 90, 2, "mp_level_up");

    rank_char = level.rankTable[self.pers["rank"]][1];
    subRank = int(rank_char[rank_char.size - 1]);

    if (subRank == 1)
    {
        for (i = 0; i < level.players.size; i++)
        {
            player = level.players[i];
            player iprintln(&"RANK_PLAYER_WAS_PROMOTED", self, newRankName);
        }
    }
}

endGameUpdate()
{
    debugPrint("in _rank::endGameUpdate()", "fn", level.lowVerbosity);

    player = self;
}

updateRankScoreHUD(amount)
{
    debugPrint("in _rank::updateRankScoreHUD()", "fn", level.absurdVerbosity);
}

getRank()
{
    debugPrint("in _rank::getRank()", "fn", level.absurdVerbosity);

    rankXp = self.pers["rankxp"];
    rankId = self.pers["rank"];

    if (rankXp < (getRankInfoMinXP(rankId) + getRankInfoXPAmt(rankId)))
    {
        return rankId;
    }
    else
    {
        return self getRankForXp(rankXp);
    }
}

getRankForXp(xpVal)
{
    debugPrint("in _rank::getRankForXp()", "fn", level.nonVerbose);

    rankId = 0;
    rankName = level.rankTable[rankId][1];
    assert(isDefined(rankName));

    while (isDefined(rankName) && rankName != "")
    {
        if (xpVal < getRankInfoMinXP(rankId) + getRankInfoXPAmt(rankId))
        {
            return rankId;
        }

        rankId++;
        if (isDefined(level.rankTable[rankId]))
        {
            rankName = level.rankTable[rankId][1];
        }
        else
        {
            rankName = undefined;
        }
    }

    rankId--;
    return rankId;
}

getSPM()
{
    debugPrint("in _rank::getSPM()", "fn", level.lowVerbosity);

    rankLevel = (self getRank() % 61) + 1;
    return 3 + (rankLevel * 0.5);
}

getPrestigeLevel()
{
    debugPrint("in _rank::getPrestigeLevel()", "fn", level.nonVerbose);

    return self scripts\players\_persistence::statGet("plevel");
}

getRankXP()
{
    debugPrint("in _rank::getRankXP()", "fn", level.absurdVerbosity);

    return self.pers["rankxp"];
}

incRankXP(amount)
{
    debugPrint("in _rank::incRankXP()", "fn", level.absurdVerbosity);

    xp = self getRankXP();
    newXp = (xp + amount);

    if (self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP(level.maxRank))
    {
        newXp = getRankInfoMaxXP(level.maxRank);
        if (self.pers["prestige"] != level.maxPrestige)
        {
            // ready to prestige
            self.canGetSpecialWeapons = false;
        }
    }

    self.pers["rankxp"] = newXp;
    self scripts\players\_persistence::statSet("rankxp", newXp);
}

increaseDemerits(amount, reason)
{
    debugPrint("in _rank::increaseDemerits()", "fn", level.nonVerbose);

    if (!isDefined(self))
    {
        return;
    }

    message1 = &"ROTUSCRIPT_EMPTY";
    message2 = &"ROTUSCRIPT_EMPTY";
    if (amount == 1)
    {
        message1 = &"ROTUSCRIPT_DEMERIT_1";
    }
    else
    {
        message1 = &"ROTUSCRIPT_DEMERIT_MANY";
    }

    switch (reason)
    {
    case "burning":
        if (amount == 0)
        {
            message1 = &"ROTUSCRIPT_DEMERIT_CHECK_FIRE";
        }
        else
        {
            message2 = &"ROTUSCRIPT_DEMERIT_KILL_BURN_NEAR_PLRS";
        }
        break;
    case "wave_intermission_revive":
        if (amount == 0)
        {
            message1 = &"ROTUSCRIPT_DEMERIT_REVIVE";
        }
        else
        {
            message2 = &"ROTUSCRIPT_DEMERIT_IGNORE_REVIVE";
        }
        break;
    case "gone_zombie":
        if (amount == 0)
        {
            message1 = &"ROTUSCRIPT_DEMERIT_CURE_SELF";
        }
        else
        {
            message2 = &"ROTUSCRIPT_DEMERIT_IGNORING_CURE_YOURSELF";
        }
        break;
    }
    self iPrintLnBold(message1, message2);

    demerits = self.pers["demerits"] + amount;
    if (demerits >= level.maxDemerits)
    {
        noticePrint("Taking 500 rank points from " + self.name + " for being a poor team player.");
        self decreaseRankPoints(500);
        demerits = 0;
    }
    self.pers["demerits"] = demerits;
    self setStat(2356, self.pers["demerits"]);
}

/**
 * @brief Reduces a players rank XP, possibly demoting the player
 *
 * @param amount integer The amount to reduce the player's rank XP by
 *
 * @returns nothing
 */
decreaseRankPoints(amount)
{
    debugPrint("in _rank::decreaseRankPoints()", "fn", level.lowVerbosity);

    if (!isDefined(self))
    {
        return;
    }

    currentRankXP = self getRankXP();
    currentPrestigeLevel = self getPrestigeLevel();
    previousPrestigeLevel = currentPrestigeLevel - 1;
    currentRankId = self getRank();

    if (currentRankXP > amount)
    {
        // we can reduce the points without worrying about prestige level
        newRankXp = currentRankXP - amount;
        newRankId = getRankForXp(newRankXp);
        if (currentRankId != newRankId)
        {
            // player was demoted

            self.pers["rankxp"] = newRankXp;
            self scripts\players\_persistence::statSet("rankxp", newRankXp);

            // set new rank
            self.pers["rank"] = newRankId;
            self scripts\players\_persistence::statSet("rank", newRankId);
            self scripts\players\_persistence::statSet("minxp", int(level.rankTable[newRankId][2]));
            self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[newRankId][7]));

            // set current new rank index to stat#252
            self setStat(252, newRankId);
            self setStat(253, newRankId);

            self setRank(self.pers["rank"], self.pers["prestige"]);

            rankCount = currentRankId - newRankId;
            noticePrint("Demoted " + self.name + " " + rankCount + " ranks.");
            self thread demotionAnnouncement(newRankId);
        }
        else
        {
            // just took rank points

            self.pers["rankxp"] = newRankXp;
            self scripts\players\_persistence::statSet("rankxp", newRankXp);

            self iPrintLnBold(&"ROTUSCRIPT_YOU_LOST_POINTS_BECAUSE_DEMERITS", amount);
            noticePrint("Took " + amount + " rank points from " + self.name);
        }
    }
    else if (currentPrestigeLevel == 0)
    {
        // new player, just take all their points
        newRankXp = 0;
        newRankId = getRankForXp(newRankXp);
        if (currentRankId != newRankId)
        {
            // player was demoted

            self.pers["rankxp"] = newRankXp;
            self scripts\players\_persistence::statSet("rankxp", newRankXp);

            // set new rank
            self.pers["rank"] = newRankId;
            self scripts\players\_persistence::statSet("rank", newRankId);
            self scripts\players\_persistence::statSet("minxp", int(level.rankTable[newRankId][2]));
            self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[newRankId][7]));

            // set current new rank index to stat#252
            self setStat(252, newRankId);
            self setStat(253, newRankId);

            self setRank(self.pers["rank"], self.pers["prestige"]);

            rankCount = currentRankId - newRankId;
            noticePrint("Demoted " + self.name + " " + rankCount + " ranks.");
            self thread demotionAnnouncement(newRankId);
        }
        else
        {
            self.pers["rankxp"] = newRankXp;
            self scripts\players\_persistence::statSet("rankxp", newRankXp);
            self iPrintLnBold(&"ROTUSCRIPT_YOU_LOST_POINTS_BECAUSE_DEMERITS", currentRankXP);
        }
    }
    else
    {
        // we can take the points, but we will cross a prestige boundary, & player is demoted
        newRankXp = int(level.rankTable[level.maxRank][7]) + currentRankXP - amount;
        newRankId = getRankForXp(newRankXp);
        newPrestigeLevel = previousPrestigeLevel;

        self.pers["rankxp"] = newRankXp;
        self scripts\players\_persistence::statSet("rankxp", newRankXp);

        // set new rank
        self.pers["rank"] = newRankId;
        self scripts\players\_persistence::statSet("rank", newRankId);
        self scripts\players\_persistence::statSet("minxp", int(level.rankTable[newRankId][2]));
        self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[newRankId][7]));

        // set current new rank index to stat#252
        self setStat(252, newRankId);
        self setStat(253, newRankId);

        // set new prestige level
        self.pers["prestige"] = newPrestigeLevel;
        self setStat(2326, self.pers["prestige"]);
        self setStat(210, self.pers["prestige"]);

        self setRank(self.pers["rank"], self.pers["prestige"]);

        rankCount = level.maxRank - newRankId + currentRankId;
        noticePrint("Demoted " + self.name + " " + rankCount + " ranks.");
        self thread demotionAnnouncement(newRankId);
    }
}

demotionAnnouncement(newRankId)
{
    debugPrint("in _rank::demotionAnnouncement()", "fn", level.lowVerbosity);

    if (!isDefined(self))
    {
        return;
    }

    self glowMessage(&"ROTUSCRIPT_RANK_DEMOTED", "", decimalRgbToColor(255, 0, 0), 5, 90, 2, "mp_level_up");

    newRankName = tableLookupIString("mp/ranktable.csv", 0, newRankId, 5);

    // Inform other players that player was demoted
    for (i = 0; i < level.players.size; i++)
    {
        player = level.players[i];
        player iprintln(&"ROTUSCRIPT_RANK_PLAYER_WAS_DEMOTED", self.name, newRankName);
    }
}
