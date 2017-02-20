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
    debugPrint("in _ranks::init()", "fn", level.nonVerbose);

    level.rank = [];
    setupRanks();
}

setupRanks()
{
    debugPrint("in _ranks::setupRanks()", "fn", level.nonVerbose);

    i = 1;
    for (;;) {
        dvar = getdvar("rank_custom_"+i);
        if (dvar == "") {return;}
        else {addRank(dvar);}
        i++;
    }
}

loadPlayerRank()
{
    debugPrint("in _ranks::loadPlayerRank()", "fn", level.nonVerbose);

    self.title = "";
    self.overrideStatusIcon = "";
    self.power = 0;
    guid = self getGuid();

    if (guid == "") {
        self.title = "^5HOST";
        self.power = 100;
        return 1;
    }

    for (i=0; i<level.rank.size; i++) {
        struct = level.rank[i];
        for (ii=0; ii<struct.players.size; ii++) {
            if (struct.players[ii] == getSubStr(guid, 24, 32)) {
                self.title = struct.title;
                self.power = struct.power;
                self.overrideStatusIcon = struct.icon;
                self.statusicon = self.overrideStatusIcon;
                return 1;
            }
        }
    }
    return 0;
}

addGuid(rank_title, guid)
{
    debugPrint("in _ranks::addGuid()", "fn", level.lowVerbosity);

    for (i=1; i<level.rank.size; i++) {
        if (IsSubStr(rank_title, level.rank[i].title)) {
            level.rank[i].players[level.rank[i].players.size] = guid;
            return;
        }
    }
}

addRank(title, power, icon)
{
    debugPrint("in _ranks::addRank()", "fn", level.lowVerbosity);

    struct = spawnstruct();
    struct.ID = level.rank.size;
    level.rank[level.rank.size] = struct;
    struct.title = title;
    struct.power = power;
    if (!isdefined(icon)) {icon = "";}
    struct.players = [];
}
