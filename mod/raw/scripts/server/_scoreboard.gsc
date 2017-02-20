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
    debugPrint("in _scoreboard::init()", "fn", level.nonVerbose);

    precacheShader("faction_128_usmc");
    setdvar("g_TeamIcon_Allies", "faction_128_usmc");
    setdvar("g_TeamColor_Allies", "0.6 0.64 0.69");
    setdvar("g_ScoresColor_Allies", "0.6 0.64 0.69");

    precacheShader("faction_128_ussr");
    setdvar("g_TeamIcon_Axis", "faction_128_ussr");
    setdvar("g_TeamColor_Axis", "0.62 0.28 0.28");
    setdvar("g_ScoresColor_Axis", "0 0 0 0");

    setdvar("g_ScoresColor_Spectator", ".25 .25 .25");
    setdvar("g_ScoresColor_Free", ".76 .78 .10");
    setdvar("g_teamColor_MyTeam", ".6 .8 .6" );
    setdvar("g_teamColor_EnemyTeam", "1 .45 .5" );
}
