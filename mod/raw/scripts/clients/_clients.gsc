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

init()
{
    debugPrint("in _clients::init()", "fn", level.nonVerbose);

    precache();

    level.players = [];
    level.activePlayers = 0;
    SetupCallbacks();

}

precache()
{
    debugPrint("in _clients::precache()", "fn", level.nonVerbose);

    precacheStatusIcon("hud_status_connecting");
    precacheString(&"ROTUSCRIPT_CONNECTED");
    precacheString(&"ROTUSCRIPT_CONNECTED_TITLED");
}

SetupCallbacks()
{
    debugPrint("in _clients::SetupCallbacks()", "fn", level.nonVerbose);

    level.callbackPlayerConnect = ::Callback_PlayerConnect;
    level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
    level.callbackPlayerDamage = ::Callback_PlayerDamage;
    level.callbackPlayerKilled = ::Callback_PlayerKilled;
}

catchBot()
{
    debugPrint("in _clients::catchBot()", "fn", level.nonVerbose);

    //RELOADING ZOMBIE :]
    if(self getStat(512) == 100) {
        level.loadBots = 0;
        self.isBot = true;
        self thread scripts\bots\_bots::loadBot();

        return 1;
    }

    return 0;
}

Callback_PlayerConnect()
{
    debugPrint("in _clients::Callback_PlayerConnect()", "fn", level.nonVerbose);

    self.isBot = false;

    self catchBot();

    self.statusicon = "hud_status_connecting";
    self.hasBegun = false;
    self waittill("begin");
    self.hasBegun = true;

    //self setclientdvars("rotu2_publickey", getsubstr(level.str,5), "rotu2_baseurl", getdvar("sv_wwwbaseurl"));

    self.statusicon = "";
    //self.sessionteam = "spectator";
    //self.sessionstate = "spectator";
    self.pers["team"] = "free";

    if (!self.isBot) {
        self scripts\server\_ranks::loadPlayerRank();
        self scripts\players\_weapons::initPlayerWeapons();

        if (self.title == "") {iPrintln( &"ROTUSCRIPT_CONNECTED", self.name );}
        else {iPrintln( &"ROTUSCRIPT_CONNECTED_TITLED", self.name, self.title );}

        self setClientDvars( "cg_drawSpectatorMessages", 1,
                             "ui_hud_hardcore", 0,
                             "player_sprintTime", 10,
                             "ui_uav_client", 1 ,
                             "ui_hintstring", "",
                             "ui_reviveby", "",
                             "cg_enemynamefadein", 999999999,
                             "cg_enemynamefadeout", 0,
                             "ui_clientcmd", "empty",
                             "r_filmusetweaks", 0,
                             "cg_fovscale", 1,
                             "ui_healthbar", -1,
                             "ui_upgradepoints", "0",
                             "ui_specialtext", "");

        // Set the clan-specific message on the player's main menu
        self setClientDvar("ui_main_menu_clan_text", getDvar("server_main_menu_clan_text"));

        lpselfnum = self getEntityNumber();
        self.guid = self getGuid();
        logPrint("J;" + self.guid + ";" + lpselfnum + ";" + self.name + "\n");


        waittillframeend;

        level.players[level.players.size] =  self;
        level notify("connected", self);

        self thread scripts\players\_players::onPlayerConnect();
        self thread scripts\gamemodes\_hud::onPlayerConnect();
        self thread scripts\players\_players::joinAllies();

    }
}

Callback_PlayerDisconnect()
{
    debugPrint("in _clients::Callback_PlayerDisconnect()", "fn", level.nonVerbose);

    if (self.isBot || !self.hasBegun) {return;}

    lpselfnum = self getEntityNumber();
    lpGuid = self getGuid();
    message = "Q;" + lpGuid + ";" + lpselfnum + ";" + self.name;

    self scripts\players\_players::cleanup(message);

    logPrint(message + "\n");

    wait 0.05;
    level.players = removeFromArray(level.players, self);

    self notify( "disconnect" );
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
    debugPrint("in _clients::Callback_PlayerDamage()", "fn", level.fullVerbosity);

    if (self.isBot) {
        self thread scripts\bots\_bots::Callback_BotDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
    } else {
        self thread scripts\players\_players::onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
    }

}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
    debugPrint("in _clients::Callback_PlayerKilled()", "fn", level.veryHighVerbosity);

    if (self.isBot) {
        self thread scripts\bots\_bots::Callback_BotKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
    } else {
        self thread scripts\players\_players::onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
    }
}
