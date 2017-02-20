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

    maps\mp\_compass::setupMiniMap("compass_map_mp_firingrange_v2");
    visionSetNaked("mp_firingrange_v2");

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
    setdvar("compassmaxrange","2000");

    thread maps\mp\mp_firingrange_v2_waypoints::load_waypoints();
    thread maps\mp\mp_firingrange_v2_tradespawns::load_tradespawns();
    convertToNativeWaypoints();

    loadAnimations();

    waitUntilFirstPlayerSpawns();

    umiEditorMode = false; // toggle true/false to switch between editor and game mode

    if (umiEditorMode) {
        devDrawAllPossibleSpawnpoints();
        maps\mp\_umiEditor::initMapEditor();
    } else {
        buildWeaponShopsByTradespawns("0 2 4 6");
        buildShopsByTradespawns("1 3 5 7");
    }

    buildZombieSpawnsByClassname("mp_dm_spawn");
    if (umiEditorMode) {
        // Do Nothing
    } else {
        startGame();
    }
}

loadAnimations()
{
    // animate the targets
    steps = [];
    step = spawnStruct();
    step.origin = (7644, -2393, 7);
    step.destination = (7644, -2640, 7);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr1", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (7455, -2403, -4);
    step.destination = (7455, -2145, -4);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr2", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (7249, -2142, -8);
    step.destination = (7249, -2375, -8);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr3", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (7645, -2095, 7);
    step.destination = (7645, -2346, 7);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr4", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (7249, -2706, -8);
    step.destination = (7249, -2930, -8);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr5", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (4935, -1764, 39);
    step.destination = (5060, -1764, 39);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr6", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (6511, -2966, 118);
    step.destination = (6511, -2855, 118);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr7", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (6376, -2855, 118);
    step.destination = (6376, -2966, 118);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr8", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (6515, -2154, -17);
    step.destination = (6515, -2280, -17);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr9", "linear", steps, true, 0.1);

    // bobbing_fr10 excluded as it isn't clear what kind of mostion it is supposed to have

    steps = [];
    step = spawnStruct();
    step.origin = (3968, -2236, 41);
    step.destination = (3751, -2236, 41);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr11", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (3940, -1604, 35);
    step.destination = (3820, -1604, 35);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_fr12", "linear", steps, true, 0.1);

    steps = [];
    step = spawnStruct();
    step.origin = (4444, -2364, 90);
    step.destination = (4412, -2277, 90);
    step.velocity = 50;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_h4", "linear", steps, true, 0.1);
}
