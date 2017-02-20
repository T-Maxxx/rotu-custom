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

    maps\mp\_sbase_structs::main();
    maps\mp\mp_sbase_soundfx::main();
    maps\mp\sbase_bobbing::main();

    ambientPlay("ambient_middleeast_ext");
    maps\mp\_compass::setupMiniMap("compass_map_mp_sbase");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setExpFog(0, 1800, 0.33, 0.39, 0.545313, 1);
    setdvar("r_specularcolorscale", "2.9");
    setdvar("r_glowbloomintensity0", ".25");
    setdvar("r_glowbloomintensity1", ".25");
    setdvar("r_glowskybleedintensity0", ".3");
    setdvar("compassmaxrange", "2500");

    thread maps\mp\mp_sbase_waypoints::load_waypoints();
    thread maps\mp\mp_sbase_tradespawns::load_tradespawns();
    convertToNativeWaypoints();

    loadHurtTriggers("trigger_hurt");

    waitUntilFirstPlayerSpawns();

    umiEditorMode = false; // toggle true/false to switch between editor and game mode

    if (umiEditorMode) {
        devDrawAllPossibleSpawnpoints();
        maps\mp\_umiEditor::initMapEditor();
        maps\mp\_umiEditor::initWeaponShopEditor("0 2 4 6 8 10 12 14 16 18");
        maps\mp\_umiEditor::initEquipmentShopEditor("1 3 5 7 9 11 13 15 17 19");
        maps\mp\_umiEditor::devDumpEntities();
    } else {
        buildWeaponShopsByTradespawns("0 2 4 6 8 10 12 14 16 18");
        buildShopsByTradespawns("1 3 5 7 9 11 13 15 17 19");
    }

    buildZombieSpawnsByClassname("mp_dm_spawn");
    if (umiEditorMode) {
        // Do Nothing
    } else {
        startGame();
    }
}
