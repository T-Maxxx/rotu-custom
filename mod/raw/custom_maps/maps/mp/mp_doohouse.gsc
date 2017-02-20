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
    maps\mp\mp_doohouse_sound_fx::main();
    maps\mp\_load::main();

    deleteSabotageEntities();
    deleteHqEntities();
    deleteCtfEntities();
    deleteUnusedSpawnpoints(true, true, true, true);
    deletePickupItems();

    level._effect["fliegen"] = loadfx ("misc/insects_carcass_runner");
    maps\mp\_fx::loopfx("fliegen", (800, -1216, 16), 1);
    maps\mp\_fx::loopfx("fliegen", (-672, 160, 32), 1);

    level._effect["staub2"] = loadfx ("dust/room_dust_200");
    maps\mp\_fx::loopfx("staub2", (0, 0, 0), 1);

    level._effect["asche"] = loadfx ("smoke/amb_ash");
    maps\mp\_fx::loopfx("asche", (0, 0, 0), 1);

    level._effect["rauch"] = loadfx ("smoke/heli_engine_smolder");
    maps\mp\_fx::loopfx("rauch", (-384, 1232, 92), 1);

    level._effect["zigi"] = loadfx ("smoke/cigarsmoke_exhale");
    maps\mp\_fx::loopfx("zigi", (969, -585, 256.5), 1, (969, -585, 266.5));
    maps\mp\_fx::loopfx("zigi", (483, -1235, 256.5), 2, (483, -1235, 266.5));
    maps\mp\_fx::loopfx("zigi", (-969, 599.5, 256.5), 1, (-969, 599.5, 266.5));
    maps\mp\_fx::loopfx("zigi", (-969, 847, 256.5), 3, (-969, 847, 266.5));
    maps\mp\_fx::loopfx("zigi", (-614, 1234.5, 256.5), 2, (-614, 1234.5, 266.5));

    level._effect["feuertv"] = loadfx ("fire/tv_fire");
    maps\mp\_fx::loopfx("feuertv", (781.5, -853.5, 55), 1);
    maps\mp\_fx::loopfx("feuertv", (-31.5, 607, 32), 1);

    level._effect["adler"] = loadfx ("misc/hawks");
    maps\mp\_fx::loopfx("adler", (0, 0, 900), 3, (0, 10, 1200));

    maps\mp\_breakable_windows::main();

    maps\mp\_compass::setupMiniMap("compass_map_mp_doohouse");

    ambientPlay("ambient_backlot_ext");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_glowbloomintensity0",".25");
    setdvar("r_glowbloomintensity1",".25");
    setdvar("r_glowskybleedintensity0",".3");
    setdvar("r_specularcolorscale", "1");
    setdvar("compassmaxrange","1800");

    thread maps\mp\mp_doohouse_waypoints::load_waypoints();
    thread maps\mp\mp_doohouse_tradespawns::load_tradespawns();
    convertToNativeWaypoints();

    waitUntilFirstPlayerSpawns();

    umiEditorMode = false;  // toggle true/false to switch between editor and game mode

    if (umiEditorMode) {
        devDrawAllPossibleSpawnpoints();
        maps\mp\_umiEditor::initMapEditor();
        maps\mp\_umiEditor::initWeaponShopEditor("0 2 4");
        maps\mp\_umiEditor::initEquipmentShopEditor("1 3 5");
    } else {
        buildWeaponShopsByTradespawns("0 2 4");
        buildShopsByTradespawns("1 3 5");
    }

//     maps\mp\_umiEditor::initMapEditor();
    buildZombieSpawnsByClassname("mp_dm_spawn");

    if (umiEditorMode) {
        // Do Nothing
    } else {
        startGame();
    }
}
