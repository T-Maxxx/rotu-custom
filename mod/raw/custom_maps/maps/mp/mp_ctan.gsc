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
    maps\mp\mp_ctan_fx::main();
    maps\createfx\mp_ctan_fx::main();
    maps\mp\_load::main();

    deletePickupItems();
    deleteSomeSabotageEntities(); // all except for "tn:bombzone", these are BMP and T-55/54
    deleteHqEntities();
    deleteCtfEntities();
    deleteTurrets();
    deleteUnusedSpawnpoints(true, true, true, true);

    ambientPlay("ambient_overgrown_day");
    maps\mp\_compass::setupMiniMap("compass_map_mp_ctan");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_specularcolorscale", "1");
    setdvar("r_glowbloomintensity0",".25");
    setdvar("r_glowbloomintensity1",".25");
    setdvar("r_glowskybleedintensity0",".3");
    setdvar("compassmaxrange","2200");

    thread maps\mp\mp_ctan_waypoints::load_waypoints();
    thread maps\mp\mp_ctan_tradespawns::load_tradespawns();
    convertToNativeWaypoints();

    waitUntilFirstPlayerSpawns();

    umiEditorMode = false; // toggle true/false to switch between editor and game mode

    if (umiEditorMode) {
        devDrawAllPossibleSpawnpoints();
        maps\mp\_umiEditor::initMapEditor();
        maps\mp\_umiEditor::initWeaponShopEditor("0 2 4 6 8 10 12 14");
        maps\mp\_umiEditor::initEquipmentShopEditor("1 3 5 7 9 11 13 15");
//         maps\mp\_umiEditor::devDumpEntities();

    } else {
        buildWeaponShopsByTradespawns("0 2 4 6 8 10 12 14");
        buildShopsByTradespawns("1 3 5 7 9 11 13 15");
    }

    buildZombieSpawnsByClassname("mp_dm_spawn");
    if (umiEditorMode) {
        // Do Nothing
    } else {
        startGame();
    }
}

deleteSomeSabotageEntities()
{
    origins = [];
    index = 0;

    sabotageEntities[0] = "sab_bomb_axis";
    sabotageEntities[1] = "sab_bomb_allies";
    sabotageEntities[2] = "sab_bomb";
    sabotageEntities[3] = "sd_bomb";
    for (i=0; i<sabotageEntities.size; i++) {
        ents = getentarray(sabotageEntities[i], "targetname");
        for (j=0; j<ents.size; j++) {
            origins[index] = ents[j].origin;
            index++;
        }
    }
    for (i=0; i<origins.size; i++) {
        deleteNearbyEntities(origins[i], 5, 30);
    }
}
