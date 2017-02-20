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
    maps\mp\_load::main();

    deletePickupItems();
    deleteSabotageEntities();
    deleteHqEntities();
    deleteCtfEntities();
    deleteUnusedSpawnpoints(true, true, true, true);

//    maps\mp\_compass::setupMiniMap("compass_map_mp_surv_new_moon_lg");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("compassmaxrange", "1800");
    ambientPlay("ambient_backlot_ext");

    // No fence walking
    setDvar("g_gravity", "1100"); //800
    setDvar("jump_height", "21"); //39
    level.barrier = spawn("trigger_radius", (-57.5216,-382.574,136.125), 0, 3, 110 );
    level.barrier setContents(1);
    level.barrier2 = spawn("trigger_radius", (30.1555,-383.331,128.125), 0, 3, 110 );
    level.barrier2 setContents(1);
    level.barrier3 = spawn("trigger_radius", (-43.2222,-382.921,136.125), 0, 3, 110 );
    level.barrier3 setContents(1);
    level.barrier4 = spawn("trigger_radius", (-12.7801,-382.759,136.125), 0, 3, 110 );
    level.barrier4 setContents(1);
    level.barrier5 = spawn("trigger_radius", (6.47138,-382.542,136.125), 0, 3, 110 );
    level.barrier5 setContents(1);

    maps\mp\mp_surv_ZombieDesert_fx::main();
    maps\createfx\mp_surv_ZombieDesert_fx::main();

   thread maps\mp\mp_surv_zombiedesert_waypoints::load_waypoints();
   convertToNativeWaypoints();

    waitUntilFirstPlayerSpawns();

    umiEditorMode = false; // toggle true/false to switch between editor and game mode

    if (umiEditorMode) {
        devDrawAllPossibleSpawnpoints();
        maps\mp\_umiEditor::initMapEditor();
    } else {
        buildWeaponShopsByTargetname("ammostock");
        buildShopsByTargetname("weaponupgrade");
    }

    buildZombieSpawnByTargetname("spawngroup1", 1);
    buildZombieSpawnByTargetname("spawngroup2", 1);
    buildZombieSpawnByTargetname("spawngroup3", 1);
    buildZombieSpawnByTargetname("spawngroup4", 1);

    if (umiEditorMode) {
        // Do Nothing
    } else {
        startGame();
    }
}
