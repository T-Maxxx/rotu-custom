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

    maps\mp\_compass::setupMiniMap("compass_map_mp_surv_bjwifi_fort");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_glowbloomintensity0", ".25");
    setdvar("r_glowbloomintensity1", ".25");
    setdvar("r_glowskybleedintensity0", ".3");
    setdvar("compassmaxrange","2000");

    maps\mp\mp_surv_fort_v3_fx::main();
    maps\mp\mp_surv_fort_v3_soundfx::main();

//     thread maps\mp\mp_lake_waypoints::load_waypoints();
//     thread maps\mp\mp_lake_tradespawns::load_tradespawns();
//     convertToNativeWaypoints();

    precache();
    loadCentralTrap("trig_aktiv", "bat", "prsten", "aktiv", 1000);      // 5000
    loadRotatingTrap("trig2_aktiv", "rot_dio", "aktiv2", 1000);         // 5000
    loadSpikeTrap("trig3_aktiv", "trap3", "aktiv3", 1000);              // 5000
    loadFireTrap("trig_aktiv4", "vatra1", "vatra2", "vatra3", "vatra4", "brush_death", "aktiv_trap4", 1000);     // 5000
    loadElectricTrap("trig_elec", "electric1", "electric2", "electric3", "electric4",
                     "electric5", "electric6", "brush_death5", "aktiv_trap5", 1000);     // 5000

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

    buildBarricadesByTargetname("staticbarricade", 8, 200, level.barricadefx, level.barricadefx);

    thread exit1();
    thread exit2();
    thread exit3();
    thread exit4();
    //thread generator_on();//I'll finish this after the traps works well
    //thread gen_on_hide();

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

exit1()
{

    door1 = getEnt( "Gate1", "targetname" );
    door1_m1 = getEnt( "Gate1_model1", "targetname" );
    door1_m2 = getEnt( "Gate1_model2", "targetname" );
    trig1 = getEnt( "debris1", "targetname" );
    fx_d1 = getent ( "fx_d1" ,"targetname" ); //origin

    needpoints = 10000;

    while(1)
    {
        trig1 waittill( "trigger", player );

        if( player.points < needpoints + 1500 )
        {
            player iPrintlnBold( "^3You need ^1"+needpoints+" (+1500) ^3points to open the door!" );
            continue;
        }

        player scripts\players\_players::incUpgradePoints(-1*needpoints);


        trig1 delete();
        door1 delete();
        door1_m1 delete();
        door1_m2 delete();

        buildSurvSpawn("spawngroup5", 1);   //Is this good? I want to turn on one spawngroup after the door is open
        //Is it possible? then Turn off one spawngroup? I have tried: (spawngroup1 delete(); and buildSurvSpawn("spawngroup0)", 1);=>This is not good

        fx = PlayFX( level._effect["wallExp_concrete"], fx_d1.origin );
        fx_d1 PlaySound("power_up_grab");

        iprintlnbold ("^1" + player.name + " ^2has open Gate1!^7");
        wait 2;
        iprintlnbold ("^1Be careful! ^3The zombies are coming through the Gate 1^7");

        break;
    }
}

exit2()
{

    door2 = getEnt( "Barrier2", "targetname" );
    door2_m1 = getEnt( "Barrier2_model1", "targetname" );
    door2_m2 = getEnt( "Barrier2_model2", "targetname" );
    door2_m3 = getEnt( "Barrier2_model3", "targetname" );
    door2_m4 = getEnt( "Barrier2_model4", "targetname" );
    door2_m5 = getEnt( "Barrier2_model5", "targetname" );
    trig2 = getEnt( "debris2", "targetname" );
    fx_d2 = getent ( "fx_d2" ,"targetname" ); //origin

    needpoints = 10000;

    while(1)
    {
        trig2 waittill( "trigger", player );
        if( player.points < needpoints + 1500 )
        {
            player iPrintlnBold( "^3You need ^1"+needpoints+" (+1500) ^3points to open the door!" );
            continue;
        }
        player scripts\players\_players::incUpgradePoints(-1*needpoints);

        trig2 delete();
        door2 delete();
        door2_m1 delete();
        door2_m2 delete();
        door2_m3 delete();
        door2_m4 delete();
        door2_m5 delete();

        buildSurvSpawn("spawngroup6", 1);

        fx = PlayFX( level._effect["wallExp_concrete"], fx_d2.origin );
        fx_d2 PlaySound("power_up_grab");


        iprintlnbold ("^1" + player.name + " ^2has open Barrier 2!^7");
        wait 2;
        iprintlnbold ("^1Be careful! ^3The zombies are coming through the Barrier 2^7");

        break;
    }
}


exit3()
{

    door3 = getEnt( "Gate3", "targetname" );
    door3_m = getEnt( "Gate3_model", "targetname" );
    trig3 = getEnt( "debris3", "targetname" );
    fx_d3 = getent ( "fx_d3" ,"targetname" ); //origin

    needpoints = 10000;

    while(1)
    {
        trig3 waittill( "trigger", player );

        if( player.points < needpoints + 1500 )
        {
            player iPrintlnBold( "^3You need ^1"+needpoints+" (+1500) ^3points to open the door!" );
            continue;
        }
        player scripts\players\_players::incUpgradePoints(-1*needpoints);

        trig3 delete();
        door3 delete();
        door3_m delete();

        buildSurvSpawn("spawngroup7", 1);

        fx = PlayFX( level._effect["wallExp_concrete"], fx_d3.origin );
        fx_d3 PlaySound("power_up_grab");


        iprintlnbold ("^1" + player.name + " ^2has open Gate 3!^7");
        wait 2;
        iprintlnbold ("^1Be careful! ^3The zombies are coming through the Gate 3^7");

        break;
    }
}


exit4()
{

    door4 = getEnt( "Barrier4", "targetname" );
    door4_m = getEnt( "Barrier4_model", "targetname" );
    trig4 = getEnt( "debris4", "targetname" );
    fx_d4 = getent ( "fx_d4" ,"targetname" ); //origin

    needpoints = 10000;

    while(1)
    {
        trig4 waittill( "trigger", player );

        if( player.points < needpoints + 1500 )
        {
            player iPrintlnBold( "^3You need ^1"+needpoints+" (+1500) ^3points to open the door!" );
            continue;
        }
        player.points -= needpoints;

        trig4 delete();
        door4 delete();
        door4_m delete();

        buildSurvSpawn("spawngroup8", 1);

        fx = PlayFX( level._effect["wallExp_concrete"], fx_d4.origin );
        fx_d4 PlaySound("power_up_grab");

        iprintlnbold ("^1" + player.name + " ^2has open Barrier 4!^7");
        wait 1;
        iprintlnbold ("^1Be careful! ^3The zombies are coming through the Barrier 4^7");

        break;
    }
}

gen_on_hide()
{
    mon_on = getEnt( "mon_on", "targetname" );
    mon_on hide();
}

generator_on()
{
    mon_off = getEnt( "mon_off", "targetname" );
    mon_on = getEnt( "mon_on", "targetname" );
    trig = getEnt( "gen_trigger", "targetname" );

    trig waittill( "trigger", player );

    // Trap - Trigger name, trip name, price, function
    //buildTrap("trig_aktiv", "Central", 10000, ::trap_1);
    //buildTrap("trig2_aktiv", "Rotating", 5000, ::trap_2);
    //buildTrap("trig3_aktiv", "Spike", 5000, ::trap_3);
    //buildTrap("trig_aktiv4", "Fire", 5000, ::trap_4);
    //buildTrap("trig_elec", "Electric", 5000, ::trap_5);

    mon_on PlaySound("turn_on");

    mon_off hide();
    mon_on show();

    thread generator_rotate();
}

generator_rotate()
{
    rotate_obj = getentarray("rotate","targetname");
    if (isDefined(rotate_obj))
    {
        for (i = 0; i < rotate_obj.size; i++)
        {
            rotate_obj[i] thread ra_rotate();
        }
    }
}

ra_rotate()
{
    if (!isdefined(self.speed))
        self.speed = 10;
    if (!isdefined(self.script_noteworthy))
        self.script_noteworthy = "z";

    while (true)
    {
        // rotateYaw(float rot, float time, <float acceleration_time>, <float deceleration_time>);
        if (self.script_noteworthy == "z")
            self rotateYaw(360,self.speed);
        else if (self.script_noteworthy == "x")
            self rotateRoll(360,self.speed);
        else if (self.script_noteworthy == "y")
            self rotatePitch(360,self.speed);
        wait self.speed - 0.1; // removes the slight hesitation that waittill("rotatedone"); gives.
        // self waittill("rotatedone");
    }
}
