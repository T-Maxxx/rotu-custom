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
#include scripts\include\utility;

init()
{
    debugPrint("in _persistence::init()", "fn", level.nonVerbose);

    level.persistentDataInfo = [];

    level.persPlayerData = [];

    level thread onPlayerConnect();
//     debugStatsTable();
}


onPlayerConnect()
{
    debugPrint("in _persistence::onPlayerConnect()", "fn", level.nonVerbose);

    for(;;) {
        level waittill("connected", player);

        //player setClientDvar("ui_xpText", "1");
        player.enableText = true;
    }

}

restoreData()
{
    debugPrint("in _persistence::restoreData()", "fn", level.nonVerbose);

    struct = level.persPlayerData[self.guid];
    if (!isdefined(struct)) {
        struct = spawnstruct();
        level.persPlayerData[self.guid] = struct;
        struct.unlock["primary"] = 0;
        struct.unlock["secondary"] = 0;
        struct.unlock["extra"] = 0;
        struct.primary = level.spawnPrimary;
        struct.primaryAmmoStock = 10;
        struct.primaryAmmoClip = 10;
        struct.secondary = level.spawnSecondary;
        struct.secondaryAmmoStock = 0;
        struct.secondaryAmmoClip = 0;
        struct.extra = "none";
        struct.extraAmmoStock = 0;
        struct.extraAmmoClip = 0;
        struct.points = level.dvar["game_startpoints"];
        struct.isDown = false;
        struct.downOrigin = (0,0,0);
        struct.class = "";
    }
    self.persData = struct;

    self.points = struct.points;
    self.unlock["primary"] = struct.unlock["primary"];
    self.unlock["secondary"] = struct.unlock["secondary"];
    self.unlock["extra"] = struct.unlock["extra"];

}


debugStatsTable()
{
    debugPrint("in _persistence::debugStatsTable()", "fn", level.lowVerbosity);

    for (i=0; i<2500; i++) {
        debugPrint(tableLookup("mp/playerStatsTable.csv", 0, i, 0) + ":" + tableLookup("mp/playerStatsTable.csv", 0, i, 1), "val");
    }
}


// ==========================================
// Script persistent data functions
// These are made for convenience, so persistent data can be tracked by strings.
// They make use of code functions which are prototyped below.

/*
=============
statGet

Returns the value of the named stat
=============
*/
statGet(dataName)
{
    debugPrint("in _persistence::statGet()", "fn", level.veryLowVerbosity);

    //if ( !level.onlineGame )
    //  return 0;

    return self getStat(int(tableLookup("mp/playerStatsTable.csv", 1, dataName, 0)));
}

/*
=============
setStat

Sets the value of the named stat
=============
*/
statSet(dataName, value)
{
    debugPrint("in _persistence::statSet()", "fn", level.absurdVerbosity);

    //if ( !level.rankedMatch )
    //  return;

    self setStat(int(tableLookup("mp/playerStatsTable.csv", 1, dataName, 0)), value);
}

/*
=============
statAdd

Adds the passed value to the value of the named stat
=============
*/
statAdd(dataName, value)
{
    debugPrint("in _persistence::statAdd()", "fn", level.lowVerbosity);

    //if ( !level.rankedMatch )
    //  return;

    curValue = self getStat(int(tableLookup("mp/playerStatsTable.csv", 1, dataName, 0)));
    self setStat(int(tableLookup("mp/playerStatsTable.csv", 1, dataName, 0)), value + curValue);
}
