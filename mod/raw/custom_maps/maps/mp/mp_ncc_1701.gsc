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

    ambientPlay("ambient_backlot_ext");
    maps\mp\_compass::setupMiniMap("compass_map_mp_ncc_1701");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "allies";
    game["defenders"] = "axis";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_specularcolorscale", "1");
    setdvar("r_glowbloomintensity0", ".25");
    setdvar("r_glowbloomintensity1", ".25");
    setdvar("r_glowskybleedintensity0", ".3");
    setdvar("compassmaxrange", "1800");

    thread maps\mp\mp_ncc_1701_waypoints::load_waypoints();
    //thread maps\mp\mp_ncc_1701_tradespawns::load_tradespawns();
    convertToNativeWaypoints();

    loadTransporters();
    loadDoors();
    loadElevator("elevator", "switch", (55,1131,-308), (55,1131,445));  // turbolift

    waitUntilFirstPlayerSpawns();

    umiEditorMode = true; // toggle true/false to switch between editor and game mode

    if (umiEditorMode) {
        devDrawAllPossibleSpawnpoints();
        maps\mp\_umiEditor::initMapEditor();
        //maps\mp\_umiEditor::initWeaponShopEditor("0 2 4 6 8");
        //maps\mp\_umiEditor::initEquipmentShopEditor("1 3 5 7 9");
//         maps\mp\_umiEditor::devDumpEntities();

    } else {
        //buildWeaponShopsByTradespawns("0 2 4 6 8");
        //buildShopsByTradespawns("1 3 5 7 9");
    }

    buildZombieSpawnsByClassname("mp_dm_spawn");
    if (umiEditorMode) {
        // Do Nothing
    } else {
        startGame();
    }
}

loadDoors()
{
    door = spawnStruct();
    door.trigger = getEnt("door_trigger", "targetname");
    door.panelA = getEnt("door1", "targetname");
    door.panelB = getEnt("door2","targetname");
    door.distance = 47;
    door.dimension = "x"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door1_trigger", "targetname");
    door.panelA = getEnt("door3", "targetname");
    door.panelB = getEnt("door4","targetname");
    door.distance = 39;
    door.dimension = "x"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door2_trigger", "targetname");
    door.panelA = getEnt("door5", "targetname");
    door.panelB = getEnt("door6","targetname");
    door.distance = 39;
    door.dimension = "x"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door3_trigger", "targetname");
    door.panelA = getEnt("door7", "targetname");
    door.panelB = getEnt("door8","targetname");
    door.distance = 39;
    door.dimension = "x"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door4_trigger", "targetname");
    door.panelA = getEnt("door9", "targetname");
    door.panelB = getEnt("door10","targetname");
    door.distance = 39;
    door.dimension = "x"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door5_trigger", "targetname");
    door.panelA = getEnt("door11", "targetname");
    door.panelB = getEnt("door12","targetname");
    door.distance = 39;
    door.dimension = "y"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door6_trigger", "targetname");
    door.panelA = getEnt("door13", "targetname");
    door.panelB = getEnt("door14","targetname");
    door.distance = 39;
    door.dimension = "y"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door7_trigger", "targetname");
    door.panelA = getEnt("door15", "targetname");
    door.panelB = getEnt("door16","targetname");
    door.distance = 42;
    door.dimension = "y"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door8_trigger", "targetname");
    door.panelA = getEnt("door17", "targetname");
    door.panelB = getEnt("door18","targetname");
    door.distance = 42;
    door.dimension = "y"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door9_trigger", "targetname");
    door.panelA = getEnt("door19", "targetname");
    door.panelB = getEnt("door20","targetname");
    door.distance = 42;
    door.dimension = "y"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door10_trigger", "targetname");
    door.panelA = getEnt("door21", "targetname");
    door.panelB = getEnt("door22","targetname");
    door.distance = 42;
    door.dimension = "y"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door11_trigger", "targetname");
    door.panelA = getEnt("door23", "targetname");
    door.panelB = getEnt("door24","targetname");
    door.distance = 42;
    door.dimension = "y"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door12_trigger", "targetname");
    door.panelA = getEnt("door25", "targetname");
    door.panelB = getEnt("door26","targetname");
    door.distance = 42;
    door.dimension = "y"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);

    door = spawnStruct();
    door.trigger = getEnt("door13_trigger", "targetname");
    door.panelA = getEnt("door27", "targetname");
    door.panelB = getEnt("door28","targetname");
    door.distance = 42;
    door.dimension = "x"; // x|y|z
    door.closed = true;
    door.trigger thread watchDoor(door);
}

watchDoor(door)
{
    while (1) {
        self waittill("trigger", player);
        if (door.closed) {
            thread moveDoor(door, player);
        }
    }
}

moveDoor(door, player)
{
    door.closed = false;
    if (door.dimension == "x") {
        door.panelA moveX(door.distance,0.5,0.2,0.2);
        door.panelB moveX(door.distance * -1,0.5,0.2,0.2);
    } else if (door.dimension == "y") {
        door.panelA moveY(door.distance,0.5,0.2,0.2);
        door.panelB moveY(door.distance * -1,0.5,0.2,0.2);
    } else { // z
        door.panelA moveZ(door.distance,0.5,0.2,0.2);
        door.panelB moveZ(door.distance * -1,0.5,0.2,0.2);
    }
    door.panelA waittill ("movedone");

    if (isDefined(player) && player isTouching(door.trigger)){
        while(isDefined(player) && player isTouching(door.trigger)) {
            wait .1; // Wait until player is no longer touching the trigger
        }
    }

    if (door.dimension == "x") {
        door.panelA moveX(door.distance * -1,0.5,0.2,0.2);
        door.panelB moveX(door.distance,0.5,0.2,0.2);
    } else if (door.dimension == "y") {
        door.panelA moveY(door.distance * -1,0.5,0.2,0.2);
        door.panelB moveY(door.distance,0.5,0.2,0.2);
    } else { // z
        door.panelA moveZ(door.distance * -1,0.5,0.2,0.2);
        door.panelB moveZ(door.distance ,0.5,0.2,0.2);
    }
    door.panelA waittill ("movedone");
    door.closed = true;
}

loadTransporters()
{
    transporters = getEntArray("enter", "targetname");
    for (i=0; i<transporters.size; i++) {
        transporters[i] thread watchTransporters();
    }
}

watchTransporters()
{
    while (1) {
        self waittill("trigger", player);
        destination = getEnt(self.target, "targetname");
        player setOrigin(destination.origin);
        player setPlayerAngles(destination.angles);
        wait 0.1;
    }
}
