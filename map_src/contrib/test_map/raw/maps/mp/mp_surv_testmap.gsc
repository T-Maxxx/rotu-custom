/******************************************************************************
    Reign of the Undead, v2.x

    Test map for beginning map-makers contributed by Jerkan.  Thanks!

    Copyright (c) 2013 Jerkan
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

/// Provides hooks into the mod for your map
#include maps\mp\_zombiescript;
/// Provides some debugging functions
#include scripts\include\utility;

/**
 * @brief Map execution begins in the main() function
 *
 * @returns nothing
 */
main()
{
    // Log some info that may be helpful for debugging
    mapName = "Test Map (mp_surv_testmap)";
    mapVersion = "1.0"; // change this for every release of this map that has the same name
    mapAuthor = "Jerkan";
    testedWith = "2.1, 2.2";
    message = "Loading " + mapName + " version " + mapVersion + " by ";
    message += mapAuthor + ", tested with RotU " + testedWith;
    noticePrint(message); // prints a notice to server_mp.log
    /// Include the following notice if you aren't the original author, and have
    /// modified the author's original map.  This helps with debugging.
    noticePrint("Map modified by Mark A. Taff");

    // Begin loading the map
    maps\mp\_load::main();

    maps\mp\_compass::setupMiniMap("compass_map_mp_surv_testmap");

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

    setdvar("env_fog", "0");

    //maps\mp\mp_surv_testmap_fx::main(); //In this map there is no FX

    /// precache() *must* be called before waittillStart() or any other wait() calls!
    /// You can't precache anything after a call to wait()!
    precache();
    waittillStart();
    buildAmmoStock("ammostock");
    buildWeaponUpgrade("weaponupgrade");
    buildSurvSpawn("spawngroup1", 1);
    buildSurvSpawn("spawngroup2", 1);
    buildSurvSpawn("spawngroup3", 1);

    buildBarricade("staticbarricade", 8, 400, level.barricadefx, level.barricadefx);

    startSurvWaves();
}

/**
 * @brief Precache models, materials, and effects
 *
 * @returns nothing
 */
precache()
{
    level.barricadefx = LoadFX("dust/dust_trail_IR");
}

/*******************************************************************************
 * Please include this comment block at the end of each *.gsc file in your map.
 * Doing so increases the byte size of the file, which makes it easier for users
 * to make minor changes to the compiled version of your map, such as fixing bugs.
 *******************************************************************************
 *******************************************************************************
 ******************************************************************************/
