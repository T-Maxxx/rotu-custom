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

    maps\mp\_compass::setupMiniMap("compass_map_mp_surv_tunnel");

    ambientPlay("ambient_crossfire");
    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_specularcolorscale", "2");
    setdvar("compassmaxrange","1800");

    // still use internal waypoints
//     thread maps\mp\mp_surv_tunnel_waypoints::load_waypoints();
//     convertToNativeWaypoints();

    waitUntilFirstPlayerSpawns();

    // bottom floor mg
    mg1 = spawnTurret("turret_mp", (105.23,-1210.29,41.125), "saw_bipod_stand_mp");
    mg1 setmodel("weapon_saw_MG_setup");
    mg1.angles = (0,100,0);
    mg1 setTopArc(30);      // degrees
    mg1 setBottomArc(45);   // degrees

    // top floor mg
    mg2 = spawnTurret("turret_mp", (-123.268,-1209.63,208.125), "saw_bipod_stand_mp");
    mg2 setmodel("weapon_saw_MG_setup");
    mg2.angles = (0,75,0);
    mg2 setTopArc(0);       // degrees
    mg2 setBottomArc(50);   // degrees

    umiEditorMode = false;  // toggle true/false to switch between editor and game mode

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
        thread spawnpoint_protection();
    }
}

spawnpoint_protection()
{
    killzones = getentarray("killzone","targetname");
    for(i = 0; i < killzones.size; i++)
        killzones[i] thread kill_player();
}

kill_player()
{
    while(1)
    {
        self waittill ("trigger",other);
        if(other.team == self.script_noteworthy)
            other suicide();
    }
}
