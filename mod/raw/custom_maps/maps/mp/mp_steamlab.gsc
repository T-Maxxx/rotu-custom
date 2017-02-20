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
    maps\mp\_rotate_stuff::main();
    maps\mp\_destructables_obj::main();

    deletePickupItems();
    deleteSabotageEntities();
    deleteHqEntities();
    deleteCtfEntities();
    deleteUnusedSpawnpoints(true, true, true, true);

    maps\mp\_compass::setupMiniMap("compass_map_mp_steamlab");

    // set some default dvars
    if (getDvar("lab_sounds") == "") {setDvar("lab_sounds", "1");}
    if (getDvar("lab_fxs") == "") {setDvar("lab_fxs", "1");}
    if (getDvar("lab_switches") == "") {setDvar("lab_switches", "1");}
    if (getDvar("lab_ambient") == "") {setDvar("lab_ambient", "1");}
    if (getDvar("lab_darker") == "") {setDvar("lab_darker", "0");}

    // process the map dvars
    if (getDvar("lab_switches") == "1") {maps\mp\_lights_off::main();}
    if (getDvar("lab_fxs") == "1") {maps\mp\_steamlab_structs::main();}
    if (getDvar("lab_sounds") == "1") {maps\mp\_steamlab_sounds::main();}
    if (getDvar("lab_ambient") == "1") {ambientPlay("lab_ambient");}

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_specularcolorscale", "1");
    setdvar("r_glowbloomintensity0", ".25");
    setdvar("r_glowbloomintensity1", ".25");
    setdvar("r_glowskybleedintensity0", ".3");
    setdvar("compassmaxrange", "1800");

    thread maps\mp\mp_steamlab_waypoints::load_waypoints();
    thread maps\mp\mp_steamlab_tradespawns::load_tradespawns();
    convertToNativeWaypoints();

    loadAnimations();
    loadDoors();

    waitUntilFirstPlayerSpawns();

    umiEditorMode = false; // toggle true/false to switch between editor and game mode

    if (umiEditorMode) {
        devDrawAllPossibleSpawnpoints();
        maps\mp\_umiEditor::initMapEditor();
    } else {
        buildWeaponShopsByTradespawns("0 2 4 6 8 10");
        buildShopsByTradespawns("1 3 5 7 9 11");
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
    // milk crate
    steps = [];
    step = spawnStruct();
    step.origin = (-83, -895, 688);
    step.destination = (-83, -895, 690);
    step.velocity = 2;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_obj", "linear", steps, true, 0.1);

    // water bottle
    steps = [];
    step = spawnStruct();
    step.origin = (29, -897.1, 683);
    step.destination = (29, -897.1, 685);
    step.velocity = 2;
    step.delay = 0;
    steps[steps.size] = step;
    loadCyclicalAnimation("bobbing_obj2", "linear", steps, true, 0.1);
}

loadDoors()
{
    level.doorDown = true;
    level.doorMoving = false;

    trigger = getentarray("open", "targetname");

    if (isDefined(trigger)) {
        for (i=0; i<trigger.size; i++) {
            trigger[i] thread watchDoor();
        }
    }
}

watchDoor()
{
    while (1) {
        self waittill ("trigger");
        if (!level.doorMoving) {thread moveDoor();}
    }
}

moveDoor()
{
    door = getent("door", "targetname");

    level.doorMoving = true;
    height = 100;
    speed = 4;

    if (getDvar("lab_sounds") == "1") {door playSound ("roll_door");}
    if (level.doorDown) {
        door moveZ(height, speed);
        door waittill("movedone");
        level.doorDown = false;
    } else {
        door moveZ(height - (height * 2), speed);
        door waittill ("movedone");
        level.doorDown = true;
    }
    level.doorMoving = false;
}
