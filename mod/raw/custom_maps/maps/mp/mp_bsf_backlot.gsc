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

    maps\mp\_compass::setupMiniMap("compass_map_bsf_backlot");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_glowbloomintensity0", ".25");
    setdvar("r_glowbloomintensity1", ".25");
    setdvar("r_glowskybleedintensity0", ".3");
    setdvar("r_specularcolorscale", "1");
    setdvar("compassmaxrange","2000");

    thread maps\mp\mp_bsf_backlot_waypoints::load_waypoints();
    convertToNativeWaypoints();

    precache();
    waitUntilFirstPlayerSpawns();

    umiEditorMode = true;  // toggle true/false to switch between editor and game mode

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
    buildZombieSpawnByTargetname("spawngroup5", 1);
    buildZombieSpawnByTargetname("spawngroup6", 1);
    buildZombieSpawnByTargetname("spawngroup7", 1);
    buildZombieSpawnByTargetname("spawngroup8", 1);
    buildZombieSpawnByTargetname("spawngroup9", 1);
    buildZombieSpawnByTargetname("spawngroup10", 1);
    buildZombieSpawnByTargetname("spawngroup11", 1);
    buildZombieSpawnByTargetname("spawngroup12", 1);
    buildZombieSpawnByTargetname("spawngroup13", 1);
    buildZombieSpawnByTargetname("spawngroup14", 1);
    buildZombieSpawnByTargetname("spawngroup15", 1);
    buildZombieSpawnByTargetname("spawngroup16", 1);
    buildZombieSpawnByTargetname("spawngroup17", 1);
    buildZombieSpawnByTargetname("spawngroup18", 1);
    buildZombieSpawnByTargetname("spawngroup19", 1);

    buildBarricadesByTargetname("woodbarricade", 5, 400, level.barricadefx, level.barricadefx);
    buildBarricadesByTargetname("fencebarricade", 4, 400, level.barricadefx, level.barricadefx);

    if (umiEditorMode) {
        // Do Nothing
    } else {
        startGame();
    }
}

precache()
{
    level.barricadefx = LoadFX("dust/dust_trail_IR");
}
