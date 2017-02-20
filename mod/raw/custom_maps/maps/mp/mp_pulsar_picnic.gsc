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
    level._effect["fire"] = loadfx ("fire/firelp_small_pm_a");
    level._effect["campfire"] = loadfx ("fire/firelp_small_pm");
    maps\mp\_fx::loopfx("fire", (2020, 1728, 175), 3);
    maps\mp\_fx::loopfx("fire", (2020, 1345, 175), 3);
    maps\mp\_fx::loopfx("fire", (2020, 960, 175), 3);
    maps\mp\_fx::loopfx("fire", (2020, 575, 175), 3);
    maps\mp\_fx::loopfx("fire", (2020, 192, 175), 3);
    maps\mp\_fx::loopfx("fire", (2020, -192, 175), 3);
    maps\mp\_fx::loopfx("fire", (2020, -575, 175), 3);
    maps\mp\_fx::loopfx("fire", (2020, -960, 175), 3);
    maps\mp\_fx::loopfx("fire", (2020, -1345, 175), 3);
    maps\mp\_fx::loopfx("fire", (2020, -1728, 175), 3);

    maps\mp\_fx::loopfx("fire", (-1728, -2012, 175), 3);
    maps\mp\_fx::loopfx("fire", (-1344, -2012, 175), 3);
    maps\mp\_fx::loopfx("fire", (-960, -2012, 175), 3);
    maps\mp\_fx::loopfx("fire", (-575, -2012, 175), 3);
    maps\mp\_fx::loopfx("fire", (-192, -2012, 175), 3);
    maps\mp\_fx::loopfx("fire", (192, -2012, 175), 3);
    maps\mp\_fx::loopfx("fire", (575, -2012, 175), 3);
    maps\mp\_fx::loopfx("fire", (960, -2012, 175), 3);
    maps\mp\_fx::loopfx("fire", (1344, -2012, 175), 3);
    maps\mp\_fx::loopfx("fire", (1728, -2012, 175), 3);

    maps\mp\_fx::loopfx("fire", (-2012, -1792, 175), 3);
    maps\mp\_fx::loopfx("fire", (-2012, -1408, 175), 3);
    maps\mp\_fx::loopfx("fire", (-2012, -1024, 175), 3);
    maps\mp\_fx::loopfx("fire", (-2012, -640, 175), 3);
    maps\mp\_fx::loopfx("fire", (-2012, -256, 175), 3);

    maps\mp\_fx::loopfx("fire", (-960, 2018, 370), 3);
    maps\mp\_fx::loopfx("fire", (-575, 2018, 370), 3);
    maps\mp\_fx::loopfx("fire", (-192, 2018, 370), 3);
    maps\mp\_fx::loopfx("fire", (192, 2018, 370), 3);
    maps\mp\_fx::loopfx("fire", (575, 2018, 370), 3);
    maps\mp\_fx::loopfx("fire", (960, 2018, 370), 3);
    maps\mp\_fx::loopfx("fire", (1344, 2018, 370), 3);
    maps\mp\_fx::loopfx("fire", (1728, 2018, 370), 3);

    maps\mp\_fx::loopfx("fire", (-2012, 192, 225), 3);
    maps\mp\_fx::loopfx("fire", (-2012, 575, 225), 3);

    maps\mp\_fx::loopfx("fire", (-1216, 1935, 380), 3);
    maps\mp\_fx::loopfx("fire", (-1792, 1924, 380), 3);

    maps\mp\_fx::loopfx("fire", (-1664, 2030, 380), 3);
    maps\mp\_fx::loopfx("fire", (-1344, 2030, 380), 3);

    maps\mp\_fx::loopfx("campfire", (450, 512, 30), 3);

    maps\mp\_load::main();
    maps\mp\_teleport::main();
    maps\mp\elevator::main();

    maps\mp\_compass::setupMiniMap("compass_map_mp_pulsar_picnic");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_specularcolorscale", "1");
    setdvar("compassmaxrange","2000");

    thread maps\mp\mp_pulsar_picnic_waypoints::load_waypoints();
    convertToNativeWaypoints();

    waitUntilFirstPlayerSpawns();

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
    buildZombieSpawnByTargetname("spawngroup5", 1);

    if (umiEditorMode) {
        // Do Nothing
    } else {
        thread messagealert1();
        thread messagealert2();
        thread messagealert3();
        thread messagealert4();
        thread quake();
        startGame();
    }
}

messagealert1()
{
    trigger = getent("message1", "targetname"); // this finds the entity you created (the trigger)

    while (1) {
        trigger waittill ("trigger", user);
        wait 1;
        iprintlnbold("Welcome to Zombies !!!");    //prints inbold " !!!" to all the users on the map, feel free to change the text :)
        wait 300;
    }
}

messagealert2()
{
    trigger = getent("message2", "targetname"); // this finds the entity you created (the trigger)

    while (1) {
        trigger waittill ("trigger", user);
        wait 1;
        iprintlnbold("Map created by UnionJack");
        wait 300;
    }
}

messagealert3()
{
    trigger = getent("message3", "targetname"); // this finds the entity you created (the trigger)

    while (1) {
        trigger waittill ("trigger", user);
        wait 1;
        iprintlnbold("Visit our website");
        wait 300;
    }
}

messagealert4()
{
    trigger = getent("message4", "targetname"); // this finds the entity you created (the trigger)

    while (1) {
        trigger waittill ("trigger", user);
        wait 1;
        iprintlnbold("Someone is in the secret room !!!");
        wait 120;
    }
}

quake()
{
    trigger = getent("earthquake", "targetname");   // this finds the entity you created (the trigger)
    quake = getent("quake", "targetname");          // this finds the entity you created (the origin named quake)
    sound = getent("sound", "targetname");          // this finds the entity you created (the origin named sound)
    while (1) {
        trigger waittill ("trigger", user);
        wait 1;
        iprintlnbold("Do not panic its a EARTHQUAKE !!!");    //prints inbold "EAARRTHHHQUUAAKKE!!!" to all the users on the map, feel free to change the text :)
        sound PlaySound( "artillery_impact" );
        sound PlaySound( "elm_quake_sub_rumble");  //plays the sound of an earthquake at the origin "sound"
        Earthquake( 0.7, 8, quake.origin, 10000 ); // (magnitude of the earthquake, length, at what origin, and the radius) these values can be changed apart from the origin
        sound PlaySound( "artillery_impact" );
        wait 1;
    }
}
