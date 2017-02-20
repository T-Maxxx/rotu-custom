/******************************************************************************
 *    Reign of the Undead, v2.x
 *
 *    Copyright (c) 2010-2014 Reign of the Undead Team.
 *    See AUTHORS.txt for a listing.
 *
 *    Permission is hereby granted, free of charge, to any person obtaining a copy
 *    of this software and associated documentation files (the "Software"), to
 *    deal in the Software without restriction, including without limitation the
 *    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *    sell copies of the Software, and to permit persons to whom the Software is
 *    furnished to do so, subject to the following conditions:
 *
 *    The above copyright notice and this permission notice shall be included in
 *    all copies or substantial portions of the Software.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *    SOFTWARE.
 *
 *    The contents of the end-game credits must be kept, and no modification of its
 *    appearance may have the effect of failing to give credit to the Reign of the
 *    Undead creators.
 *
 *    Some assets in this mod are owned by Activision/Infinity Ward, so any use of
 *    Reign of the Undead must also comply with Activision/Infinity Ward's modtools
 *    EULA.
 ******************************************************************************/

#include maps\mp\_umi;

main()
{
    /**
     * @bug this map crashes when run with +set developer_script 1, which means
     * we can't draw waypoint links.  The error is:
     *
     * Error: unknown function: (file 'maps/mp/mp_burgundy_bulls_fx.gsc', line 20)
     *        maps\createfx\mp_burgundy_bulls_fx::main();
     *
     * It seems to run just fine with +set developer_script 1 though
     */
    maps\mp\mp_burgundy_bulls_fx::main();
    thread maps\createfx\mp_burgundy_bulls_fx::Add_FX();
    maps\mp\_load::main();

    deleteSabotageEntities();
    deleteHqEntities();
    deleteCtfEntities();
    deleteUnusedSpawnpoints(true, true, true, true);

    maps\mp\_compass::setupMiniMap("compass_map_mp_burgundy_bulls");

    setExpFog(850, 2500, 0.7, 0.7, 0.6, 0);
    ambientPlay("ambient_overgrown_day");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar( "r_specularcolorscale", "1" );
    setdvar("r_glowbloomintensity0",".1");
    setdvar("r_glowbloomintensity1",".1");
    setdvar("r_glowskybleedintensity0",".1");
    setdvar("compassmaxrange","1600");

    thread maps\mp\mp_burgundy_bulls_waypoints::load_waypoints();
    thread maps\mp\mp_burgundy_bulls_tradespawns::load_tradespawns();
    convertToNativeWaypoints();

    waitUntilFirstPlayerSpawns();
    buildWeaponShopsByTradespawns("0 2 4 6 8");
    buildShopsByTradespawns("1 3 5 7 9");

    buildZombieSpawnsByClassname("mp_dm_spawn");
    startGame();
}
