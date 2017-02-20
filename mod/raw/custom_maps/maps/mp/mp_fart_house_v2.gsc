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

    deleteSabotageEntities();
    deleteHqEntities();
    deleteCtfEntities();
    deleteUnusedSpawnpoints(true, true, true, true);
    deletePickupItems();
    // remove fighters and stock vending machine triggers
    deleteEntitiesByTargetname("fighter");
    deleteEntitiesByTargetname("pf411_auto1");
    deleteEntitiesByTargetname("pf419_auto1");
    deleteEntitiesByTargetname("pf427_auto1");
    deleteEntitiesByTargetname("pf443_auto1");
    deleteEntitiesByTargetname("heal");

    maps\mp\_compass::setupMiniMap("compass_map_mp_fart_house_v2");

    ambientPlay("ambient_overgrown_day");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_specularcolorscale", "1");
    setdvar("r_glowbloomintensity0",".1");
    setdvar("r_glowbloomintensity1",".1");
    setdvar("r_glowskybleedintensity0",".1");
    setdvar("compassmaxrange","2500");

//     setdvar("g_speed","325"); // was 190 by default
    setdvar("bg_falldamagemaxheight","1100"); // was 300 by default
    setdvar("bg_falldamageminheight","1099"); // was 128 by default
    setdvar("jump_height","50"); // was 39 by default

    thread maps\mp\mp_fart_house_v2_waypoints::load_waypoints();
    thread maps\mp\mp_fart_house_v2_tradespawns::load_tradespawns();
    convertToNativeWaypoints();

    loadGlidePad("jumppad1", "air11", "air12", "air13", "air14", "air15");
    loadGlidePad("jumppad2", "air21", "air22", "air23", "air24", "air25");
    loadGlidePad("jumppad3", "air31", "air32", "air33", "air34", "air35");
    loadGlidePad("jumppad4", "air41", "air42", "air43", "air44", "air45");
    loadGlidePad("jumppad5", "air51", "air52", "air53", "air54", "air55");

    loadElevator("elevator1", "switch1", (-1936,2045,603), (-1936,2045,-467));  // bookcase by kitchen door
    loadElevator("elevator2", "switch2", (1936,2358,603), (1936,2358,-467));    // LR by wicker basket
    loadElevator("elevator3", "switch3", (-2108,416,893), (-2108,416,155));     // in wall by piano
    loadElevator("elevator4", "switch4", (-424,4156,637), (-424,4156,-613));    // in BR wall
    loadElevator("elevator5", "switch5", (1165,4004,455), (1165,4004,-431));    // LR grandfather clock
    loadElevator("elevator6", "switch6", (1164,86,610), (1164,86,-586));        // LR wardrobe
    loadElevator("elevator7", "switch7", (-4072,2101,700), (-4072,2101,-565));  // kitchen
    loadElevator("elevator8", "switch8", (-880,5736,696), (-880,5736,-560));    // BR
    loadElevator("monorail1", "monoswitch1", (1672,2201,858), (-1671,2201,858));// monorail

    loadMapTeleporter("tele1", "exit1");
    loadMapTeleporter("tele2", "exit2");
    loadMapTeleporter("tele3", "exit3");
    loadMapTeleporter("tele4", "exit4");
    loadMapTeleporter("tele5", "exit5");

    loadHurtTriggers("trigger_hurt");

    waitUntilFirstPlayerSpawns();

    umiEditorMode = false;  // toggle true/false to switch between editor and game mode

    if (umiEditorMode) {
        devDrawAllPossibleSpawnpoints();
        maps\mp\_umiEditor::initMapEditor();
        maps\mp\_umiEditor::initWeaponShopEditor("0 2 4 6 8 10 12 14");
        maps\mp\_umiEditor::initEquipmentShopEditor("1 3 5 7 9 11 13 15");
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
