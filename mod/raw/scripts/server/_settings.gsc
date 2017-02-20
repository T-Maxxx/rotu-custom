/* Localization not required. */
/******************************************************************************
    Reign of the Undead, v2.x

    Copyright (c) 2010-2013 Reign of the Undead Team.
    See AUTHORS.txt for a listing.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    The contents of the end-game credits must be kept, and no modification of its
    appearance may have the effect of failing to give credit to the Reign of the
    Undead creators.

    Some assets in this mod are owned by Activision/Infinity Ward, so any use of
    Reign of the Undead must also comply with Activision/Infinity Ward's modtools
    EULA.
******************************************************************************/

#include scripts\include\utility;

init()
{
    debugPrint("in _settings::init()", "fn", level.nonVerbose);

    level.dvar = [];
    loadSettings();
    // For our implementation of doKick(), we need a backup of the kickBanTime (which
    // is actually the tempBan time) to prevent an edge case race condition
    level.kickBanTimeBackup = getDvar("sv_kickBanTime");
}



/**
 * @brief Loads game settings
 *
 * Default, minimum, and maximum values are defined here.  These default values
 * are loaded unless they are over-ridden by settings made in config files
 *
 * @returns nothing
 */
loadSettings()
{
    debugPrint("in _settings::loadSettings()", "fn", level.nonVerbose);

    // These dvarType functions are defined and documented following the loadSettings() function
    dvarBool(   "bot",      "scores",               0);
    dvarInt(    "bot",      "count",                20,     0,      63); // Amount of bots loaded

    dvarBool(   "zom",      "orbituary",            0);
    dvarBool(   "zom",      "dominoeffect",         1);
    dvarBool(   "zom",      "dynamicdifficulty",    1);
    dvarBool(   "zom",      "infection",            1);
    dvarBool(   "zom",      "headshotonly",         0);
    dvarBool(   "zom",      "spawnprot",            1);
    dvarBool(   "zom",      "spawnprot_decrease",   1);
    dvarBool(   "zom",      "spawnprot_tank",       0);
    dvarInt(    "zom",      "infectiontime",        25,     0,      120); // [s]
    dvarFloat(  "zom",      "spawnprot_time",       6,      0,      30);  // [s]

    dvarBool(   "game",     "extremeragdoll",       1);
    dvarBool(   "game",     "friendlyfire",         0);
    dvarBool(   "game",     "welcomemessages",      0);
    dvarBool(   "game",     "mapvote",              1);
    dvarBool(   "game",     "use_custom",           1);
    dvarBool(   "game",     "mg_overheat",          1);
    dvarBool(   "game",     "class_ranks",          1);
    dvarInt(    "game",     "difficulty",           2,      1,      5);
    dvarInt(    "game",     "mapvote_time",         20,     5,      60); // [s]
    dvarInt(    "game",     "mapvote_count",        8,      1,      15);
    dvarInt(    "game",     "rewardscale",          25,     1,      10000);
    dvarInt(    "game",     "startpoints",          2000,   0,      100000);
    dvarInt(    "game",     "max_mg_barrels",       4,      0,      20);
    dvarInt(    "game",     "max_turrets",          5,      0,      12);
    dvarInt(    "game",     "max_barrels",          12,     0,      30);
    dvarInt(    "game",     "max_portals",          3,      0,      10);
    dvarFloat(  "game",     "mg_overheat_speed",    2.5,    0.25,   10);
    dvarFloat(  "game",     "mg_cooldown_speed",    1,      0.2,    10);
    dvarFloat(  "game",     "mg_barrel_time",       150,    10,     99999); // [s]
    dvarFloat(  "game",     "portal_time",          180,    10,     99999); // [s]
    dvarFloat(  "game",     "turret_time",          120,    10,     99999); // [s]
    dvarFloat(  "game",     "spawn_requirement",    0.5,    0,      1);
    dvarString( "game",     "mapvote_style",        "2.2");
    dvarInt(    "game",     "assistance_max_rank",  30,     15,      30);

    dvarBool(   "hud",      "survivors_left",       1);
    dvarBool(   "hud",      "survivors_down",       1);
    dvarBool(   "hud",      "wave_number",          1);

    dvarString( "server",   "provider",             "Pulsar");
    dvarString( "server",   "customizer",           "");

    dvarBool(   "env",      "ambient",              1);
    dvarBool(   "env",      "fog",                  1);
    dvarBool(   "env",      "override_vision",      1);
    dvarInt(    "env",      "fog_start_distance",   200,    0,      10000);
    dvarInt(    "env",      "fog_half_distance",    480,    0,      10000);
    dvarInt(    "env",      "fog_red",              5,      0,      255);
    dvarInt(    "env",      "fog_green",            0,      0,      255);
    dvarInt(    "env",      "fog_blue",             5,      0,      255);
    dvarInt(    "env",      "blur",                 .1,     0,      10);

    dvarBool(   "surv",     "waw_alwayspay",        1);
    dvarBool(   "surv",     "slow_start",           1);
    dvarBool(   "surv",     "find_stuck",           1);
    dvarBool(   "surv",     "endround_revive",      1);
    dvarInt(    "surv",     "specialinterval",      2,      1,      20);
    dvarInt(    "surv",     "specialwaves",         5,      1,      100);
    dvarInt(    "surv",     "zombies_initial",      10,     1,      1000);
    dvarInt(    "surv",     "zombies_perplayer",    10,     1,      1000);
    dvarInt(    "surv",     "zombies_perwave",      5,      1,      1000);
    dvarInt(    "surv",     "wavesystem",           2,      0,      2);
    dvarInt(    "surv",     "timeout",              30,     2,      120); // [s]
    dvarInt(    "surv",     "waw_costs",            750,    1,      100000);
    dvarInt(    "surv",     "slow_waves",           3,      1,      10);
    dvarInt(    "surv",     "stuck_tollerance",     30,     10,     360);
    dvarInt(    "surv",     "waves_repeat",         2,      1,      100);
    dvarString( "surv",     "defaultmode",          "waves_special");
    dvarString( "surv",     "weaponmode",           "upgrade"); //wawzombies or upgrade
    dvarString( "surv",     "waw_spawnprimary",     "none");
    dvarString( "surv",     "waw_spawnsecondary",   "beretta_mp");

    dvarInt(    "shop",     "item1_costs",          2000,   1,      250000); // [upgrade points]
    dvarInt(    "shop",     "item2_costs",          1500,   1,      250000);
    dvarInt(    "shop",     "item3_costs",          3500,   1,      250000);
    dvarInt(    "shop",     "item4_costs",          1000,   1,      250000);
    dvarInt(    "shop",     "item5_costs",          1250,   1,      250000);
    dvarInt(    "shop",     "item6_costs",          10000,  1,      250000);
    dvarInt(    "shop",     "defensive1_costs",     1000,   1,      250000);
    dvarInt(    "shop",     "defensive2_costs",     1250,   1,      250000);
    dvarInt(    "shop",     "defensive3_costs",     1750,   1,      250000);
    dvarInt(    "shop",     "defensive4_costs",     4000,   1,      250000);
    dvarInt(    "shop",     "defensive5_costs",     7500,   1,      250000);
    dvarInt(    "shop",     "defensive6_costs",     10000,  1,      250000);
    dvarInt(    "shop",     "defensive7_costs",     10000,  1,      250000);
    dvarInt(    "shop",     "defensive8_costs",     10000,  1,      250000);
    dvarInt(    "shop",     "support1_costs",       2500,   1,      250000);
    dvarInt(    "shop",     "support2_costs",       15000,  1,      250000);
    dvarInt(    "shop",     "support3_costs",       20000,  1,      250000);
    dvarInt(    "shop",     "support4_costs",       30000,  1,      250000);
    dvarInt(    "shop",     "support5_costs",       50000,  1,      250000);

    dvarString( "g",     "teamname_axis",   "^9Zombies");
    dvarString( "g",     "teamname_allies",   "^8Survivors...");

    count = getDvarInt("admin_number_of_admins_defined");
    for(i=1; i <= count; i++) {
        /// Create dvars for admin properties listed in config file
        dvarString( "admin", "guid_admin" + i);
        dvarBool(   "admin", "superAdmin_admin" + i, 0);

        if (getDvar("admin_canConnectToRcon_admin" + i) != "") {
            dvarBool(   "admin", "canConnectToRcon_admin" + i, 0);
        }
        if (getDvar("admin_canKillPlayer_admin" + i) != "") {
            dvarBool(   "admin", "canKillPlayer_admin" + i, 0);
        }
        if (getDvar("admin_canBoomPlayer_admin" + i) != "") {
            dvarBool(   "admin", "canBoomPlayer_admin" + i, 0);
        }
        if (getDvar("admin_canSpawnPlayer_admin" + i) != "") {
            dvarBool(   "admin", "canSpawnPlayer_admin" + i, 0);
        }
        if (getDvar("admin_canWarnPlayer_admin" + i) != "") {
            dvarBool(   "admin", "canWarnPlayer_admin" + i, 0);
        }
        if (getDvar("admin_canKickPlayer_admin" + i) != "") {
            dvarBool(   "admin", "canKickPlayer_admin" + i, 0);
        }
        if (getDvar("admin_canBanPlayer_admin" + i) != "") {
            dvarBool(   "admin", "canBanPlayer_admin" + i, 0);
        }
        if (getDvar("admin_canBouncePlayer_admin" + i) != "") {
            dvarBool(   "admin", "canBouncePlayer_admin" + i, 0);
        }
        if (getDvar("admin_canRemovePlayerWarnings_admin" + i) != "") {
            dvarBool(   "admin", "canRemovePlayerWarnings_admin" + i, 0);
        }
        if (getDvar("admin_canHealPlayer_admin" + i) != "") {
            dvarBool(   "admin", "canHealPlayer_admin" + i, 0);
        }
        if (getDvar("admin_canTeleportPlayer_admin" + i) != "") {
            dvarBool(   "admin", "canTeleportPlayer_admin" + i, 0);
        }
        if (getDvar("admin_canDropPlayerWeapon_admin" + i) != "") {
            dvarBool(   "admin", "canDropPlayerWeapon_admin" + i, 0);
        }
        if (getDvar("admin_canFinish_admin" + i) != "") {
            dvarBool(   "admin", "canFinish_admin" + i, 0);
        }
        if (getDvar("admin_canRestart_admin" + i) != "") {
            dvarBool(   "admin", "canRestart_admin" + i, 0);
        }
        if (getDvar("admin_canKillZombies_admin" + i) != "") {
            dvarBool(   "admin", "canKillZombies_admin" + i, 0);
        }
        if (getDvar("admin_canChangeMap_admin" + i) != "") {
            dvarBool(   "admin", "canChangeMap_admin" + i, 0);
        }
    }

    /*dvarString("surv_defaultmode", "waves_special"); // In case the map doesn't set the gamemode
    dvarString("surv_wave_system", "pp"); // The way wave size is calculated (pp/pw/pppw)
    dvarInt("surv_preparetime", 10, 0, 100);


    dvarInt("surv_wave_zombiespp", 5, 1, 100); // Zombies per player in wave one
    dvarInt("surv_wave_zombiespp_inc", 5, 1, 100); // Increase in zombies per player per wave
    dvarInt("surv_wave_zombiespw", 20, 1, 5000); // Zombies in wave 1
    dvarInt("surv_wave_zombiespw_inc", 10, 1, 1000); // Increase in zombies per wave

    dvarInt("surv_wave_zombiehealth", 200, 1, 1000); // Initial zombie health
    dvarInt("surv_wave_zombiehealth_inc", 10, 1, 200); // Zombie health increase per wave
    dvarInt("surv_wave_zombiehealthpp_inc", 5, 1, 200); // Zombie health increase per player

    dvarInt("surv_wave_spawnspeed", 5, 1, 1000); // Wait time in seconds between a zombie spawn
    dvarFloat("surv_wave_spawnspeedpw_dec", .3, 0, 10); // Wait time in seconds percentage change per wave
    dvarFloat("surv_wave_spawnspeedpp_prc", .9, 0, 1); // Wait time in seconds percentage change per player

    dvarFloat("surv_wave_dog_prc", .01, 0, 1); // 10 percent chance at spawning a dog
    dvarFloat("surv_wave_burning_prc", .03, 0, 1);
    dvarFloat("surv_wave_toxic_prc", .02, 0, 1);
    //dvarFloat("surv_wave_spc_toxic", .02, 0, 1);

    dvarInt("surv_spc_waveinterval", 5, 1, 20); // Amount of normal waves before a special one
    dvarInt("surv_spc_specialwaves", 4, 1, 20); // Amount of special waves before victory
    dvarString("surv_spc_specialwave1", "dogs");
    dvarString("surv_spc_specialwave2", "burning");
    dvarString("surv_spc_specialwave3", "toxic");
    dvarString("surv_spc_specialwave4", "boss");

    dvarBool("zombie_obituary", 0);
    dvarBool("zombie_dominoeffect", 1);
    dvarFloat("zombie_dif_spawn_pp", 10, 1, 63);
    dvarFloat("zombie_dif_death_pp", 2, 1, 63);
    dvarBool("zombie_dynamicdifficulty", 1);
    dvarBool("extreme_ragdoll", 1);
    dvarBool("rotu_persistentitems", 0);
    dvarBool("rotu_friendlyfire", 0);*/

    level.rewardScale = level.dvar["game_rewardscale"]; // kill score multiplication factor
} // End function loadSettings()



/**
 * @brief Internal utility function to finalise formatting, then set level dvars
 * @internal
 *
 * @param type string The type of variable to set. One of [bot | zom | game | hud | server | env | surv | shop]
 * @param dvar string The name of the dvar to set
 * @param val variant The value to assign to the dvar
 *
 * @returns nothing
 */
finishDvar(type, dvar, val)
{
    debugPrint("in _settings::finishDvar()", "fn", level.veryLowVerbosity);

    setDvar(type + "_" + dvar, val);
    level.dvar[type + "_" + dvar] = val;
}


/**
 * @brief Sets a variant type dvar with (preferentially) a custom choice, otherwise a default value
 *
 * @param type string The type of variable to set. One of [bot | zom | game | hud | server | env | surv | shop]
 * @param dvar string The name of the dvar to set
 * @param def  variant The default value to assign to the dvar.
 * @param values  variant[] An variant array of acceptable choices
 *
 * @returns nothing
 */
dvarChoice(type, dvar, def, values)
{
    debugPrint("in _settings::dvarChoice()", "fn", level.lowVerbosity);

    var = type + "_" + dvar;
    val = getDvar(var);

    // If the custom value is acceptable, use it; otherwise use the default choice
    for (i=0; i<values.size; i++) {
        if (values[i] == val) {
            finishDvar(type, dvar, val);
            return;
        }
    }
    finishDvar(type, dvar, def);
}



/**
 * @brief Sets a string type dvar with (preferentially) a custom value, otherwise a default value
 *
 * @param type string The type of variable to set. One of [bot | zom | game | hud | server | env | surv | shop]
 * @param dvar string The name of the dvar to set
 * @param def  string The default value to assign to the dvar
 *
 * @returns nothing
 */
dvarString(type, dvar, def)
{
    debugPrint("in _settings::dvarString()", "fn", level.nonVerbose);

    var = type + "_" + dvar;
    val = getDvar(var);

    // If a custom value isn't set, use the default; otherwise use the custom value
    if (val == "") {
        finishDvar(type, dvar, def);
    } else {
        finishDvar(type, dvar, val);
    }
}



/**
 * @brief Sets a boolean type dvar with (preferentially) a custom value, otherwise a default value
 *
 * @param type string The type of variable to set. One of [bot | zom | game | hud | server | env | surv | shop]
 * @param dvar string The name of the dvar to set
 * @param def  int    The default value to assign to the dvar. 0 for false, 1 for true
 *
 * @returns nothing
 */
dvarBool(type, dvar, def)
{
    debugPrint("in _settings::dvarBool()", "fn", level.nonVerbose);

    var = type + "_" + dvar;

    // If a custom value isn't set, use the default; otherwise use the custom value
    if (getDvar(var) == "") {
        finishDvar(type, dvar, def);
    } else {
        val = getDvarInt(var);

        // Ensure the custom value is a 0 or 1
        if (val > 1) {val = 1;}
        if (val < 0) {val = 0;}

        finishDvar(type, dvar, val);
    }
}



/**
 * @brief Sets an integer type dvar with (preferentially) a custom value, otherwise a default value
 *
 * @param type string The type of variable to set. One of [bot | zom | game | hud | server | env | surv | shop]
 * @param dvar string The name of the dvar to set
 * @param def  int    The default value to assign to the dvar.
 * @param min  int    The minimum value that can be assigned.
 * @param max  int    The maximum value that can be assigned.
 *
 * @returns nothing
 */
dvarInt(type, dvar, def, min, max)
{
    debugPrint("in _settings::dvarInt()", "fn", level.nonVerbose);

    var = type + "_" + dvar;

    // If a custom value isn't set, use the default; otherwise use the custom value
    if (getDvar(var) == "") {
        /// N.B. @p min and @p max are only relevant if a custom value is used
        finishDvar(type, dvar, def);
    } else {
        val = getDvarInt(var);

        // TODO: These next two blocks are very clumsy.  Refactor after dev
        // environment is set up and I am able to test the changes
        // Ensure that  min <= value <= max
        if (isdefined(max)) {
            if (val > max) {val = max;}
        }
        if (isdefined(min)) {
            if (val < min) {val = min;}
        }

        finishDvar(type, dvar, val);
    }
} // End function dvarInt()



/**
 * @brief Sets an float type dvar with (preferentially) a custom value, otherwise a default value
 *
 * @param type string The type of variable to set. One of [bot | zom | game | hud | server | env | surv | shop]
 * @param dvar string The name of the dvar to set
 * @param def  float  The default value to assign to the dvar.
 * @param min  float  The minimum value that can be assigned.
 * @param max  float  The maximum value that can be assigned.
 *
 * @returns nothing
 */
dvarFloat(type, dvar, def, min, max)
{
    debugPrint("in _settings::dvarFloat()", "fn", level.nonVerbose);

    var = type + "_" + dvar;

    // If a custom value isn't set, use the default; otherwise use the custom value
    if (getDvar(var) == "")
        /// N.B. @p min and @p max are only relevant if a custom value is used
        finishDvar(type, dvar, def);
    else
    {
        val = getDvarFloat(var);

        // TODO: These next two blocks are very clumsy.  Refactor after dev
        // environment is set up and I am able to test the changes
        // Ensure that  min <= value <= max
        if (isdefined(max)) {
            if (val > max) {val = max;}
        }
        if (isdefined(min)) {
            if (val < min) {val = min;}
        }

        finishDvar(type, dvar, val);
    }
} // End function dvarInt()
