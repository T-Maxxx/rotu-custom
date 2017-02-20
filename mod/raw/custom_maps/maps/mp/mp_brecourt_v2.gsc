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

    maps\mp\mp_brecourt_v2_fx::main();
    thread maps\createfx\mp_brecourt_v2_fx::Add_FX();

    maps\mp\_compass::setupMiniMap("compass_map_mp_bre89");

    setExpFog(300, 1400, 0.5, 0.5, 0.5, 0);

    if (getDvar("scr_brecourt_rain") == "") {setDvar("scr_brecourt_rain", 1);}
    level.brecourt_rain = getDvarInt( "scr_brecourt_rain" );

    if (level.brecourt_rain) {
        ambientPlay("ambient_farm");
        thread maps\createfx\mp_brecourt_v2_fx::Add_Rain();
    } else {ambientPlay("ambient_pipeline");}

    game["allies"] = "sas";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "woodland";
    game["axis_soldiertype"] = "woodland";

    setdvar( "r_specularcolorscale", "1" );
    setdvar("r_glowbloomintensity0",".25");
    setdvar("r_glowbloomintensity1",".25");
    setdvar("r_glowskybleedintensity0",".3");
    setdvar("compassmaxrange","1800");

    thread maps\mp\mp_brecourt_v2_waypoints::load_waypoints();
    thread maps\mp\mp_brecourt_v2_tradespawns::load_tradespawns();
    convertToNativeWaypoints();

    waitUntilFirstPlayerSpawns();

    umiEditorMode = false; // toggle true/false to switch between editor and game mode

    if (umiEditorMode) {
        devDrawAllPossibleSpawnpoints();
        maps\mp\_umiEditor::initMapEditor();
        maps\mp\_umiEditor::initWeaponShopEditor("0 2 4 6");
        maps\mp\_umiEditor::initEquipmentShopEditor("1 3 5 7");
    } else {
        buildWeaponShopsByTradespawns("0 2 4 6");
        buildShopsByTradespawns("1 3 5 7");
    }

    buildZombieSpawnsByClassname("mp_dm_spawn");
    if (umiEditorMode) {
        // Do Nothing
    } else {startGame();}
}

// addobj(name, origin, angles)
// {
// ent = spawn("trigger_radius", origin, 0, 48, 148);
// ent.targetname = name;
// ent.angles = angles;
// }
