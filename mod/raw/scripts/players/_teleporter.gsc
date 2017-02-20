/* Localized. */
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

#include scripts\include\data;
#include scripts\include\utility;
#include common_scripts\utility;

init()
{
    debugPrint("in _teleporter::init()", "fn", level.nonVerbose);

    precache();

    

    level.teleporter = [];
    level.teles = 0;
    level.teles_held = 0;
}

precache()
{
    precacheModel( "bx_teleporter" );
    precacheShellShock( "teleporter" );

    precacheString(&"ROTUSCRIPT_CANNOT_PLACE_HERE");
    precacheString(&"ROTUSCRIPT_PRESS_TO_USE_TELEPORT");

    level.portalFX = loadfx("misc/spirit");
}

giveTeleporter()
{
    debugPrint("in _teleporter::giveTeleporter()", "fn", level.lowVerbosity);

    self.carryObj = spawn("script_model", (0,0,0));
    self.carryObj.origin = self.origin + (0,0,32) + AnglesToForward(self.angles)*48;
    self.carryObj.angles = (self.angles[0], self.angles[1], self.angles[2]);

    self.carryObj linkto(self);
    self.carryObj setmodel("tag_origin");
    self.carryObj setcontents(2);

    wait 0.05;

    playfxontag(level.portalFX, self.carryObj, "tag_origin");

    self.carryObj thread onDeath();

    level.teles_held ++;

    self.canUse = false;
    self disableweapons();
    self thread placeTele();
}


onDeath()
{
    debugPrint("in _teleporter::onDeath()", "fn", level.lowVerbosity);

    self waittill("death");
    level.teles_held -= 1;
}


placeTele()
{
    debugPrint("in _teleporter::placeTele()", "fn", level.lowVerbosity);

    wait 1;
    while (1)
    {
        if (self attackbuttonpressed())
        {
            if (self deploy())
            {
                self.carryObj unlink();
                wait .05;
                self.carryObj delete();

                self.canUse = true;
                self enableweapons();

                return ;
            }
        }
        wait .05;
    }

}

/**
 * @brief Emplaces a teleporter if the location is acceptable
 *
 * @returns boolean True is the teleporter was emplaced, false otherwise
 */
deploy()
{
    debugPrint("in _teleporter::deploy()", "fn", level.lowVerbosity);

    self endon("disconnect");
    self endon("death");

    angles =  self getPlayerAngles();
    start = self.origin + (0,0,40) + vectorscale(anglesToForward( angles ), 20);
    end = self.origin + (0,0,40) + vectorscale(anglesToForward( angles ), 38);

    left = vectorscale(anglesToRight( angles ), -10);
    right = vectorscale(anglesToRight( angles ), 10);
    back = vectorscale(anglesToForward( angles ), -6);

    // Do not let a teleporter be placed too close to the shop or ammo crate
    tooCloseToAmmoShop = false;
    useObjects = level.useObjects;
    for (i=0; i<useObjects.size; i++) {
        if ((!isDefined(useObjects[i])) || (!isDefined(useObjects[i].type))) {continue;}
        if ((useObjects[i].type == "extras") ||
            (useObjects[i].type == "ammobox")) {
            if (distance(useObjects[i].origin, self.origin) < 150) {
                tooCloseToAmmoShop = true;
                break;
            }
        }
    }

    canPlantThere1 = BulletTracePassed( start, end, true, self);
    canPlantThere2 = BulletTracePassed( start + (0,0,-7) + left, end + left + back, true, self);
    canPlantThere3 = BulletTracePassed( start + (0,0,-7) + right , end + right + back, true, self);
    if ((!canPlantThere1) || (!canPlantThere2) || (!canPlantThere3) || (tooCloseToAmmoShop)) {
        self iPrintlnBold(&"ROTUSCRIPT_CANNOT_PLACE_HERE");
        return false;
    }

    trace = bulletTrace( end + (0,0,100), end - (0,0,300), false, self );
    self thread spawnTeleporter( self.origin, (0,angles[1]+90,0), 2 );

    return true;
}


/**
 * @brief Creates a teleporter
 *
 * @param origin vector The location where the teleporter will spawn
 * @param angles vector The orientation of the teleporter
 * @param spawnDelay float How long to wait before teleporter begins working
*/
spawnTeleporter(origin, angles, spawnDelay)
{
    debugPrint("in _teleporter::spawnTeleporter()", "fn", level.lowVerbosity);

    if(!isDefined(angles)) {angles = (0,0,0);}
    if(!isDefined(spawnDelay)) {spawnDelay = .05;}

    level.teles++;

    // Setup some variables
    teleporter = undefined;
    final_destination = undefined;

    // Spawn teleporter with trigger
    level.teleporter[level.teleporter.size] = spawn("script_model", origin);
    teleporter = level.teleporter[level.teleporter.size -1];
    teleporter setModel("bx_teleporter");
    teleporter.angles = angles;
    teleporter.trigger = spawn("trigger_radius", teleporter.origin, 0, 40, 128);
    teleporter setcontents(2);

    // Loop sound
    // Don't play.  Sound file is missing, besides, it was *really* irritating.
//     teleporter playLoopSound("teleporter_loop");

    wait spawnDelay;

    level scripts\players\_usables::addUsable(teleporter, "teleporter", &"ROTUSCRIPT_PRESS_TO_USE_TELEPORT", 128);

    teleporter thread destroyInTime(level.dvar["game_portal_time"]);
    while(isDefined(teleporter)) {
        // Wait until someone use Teleporter
        teleporter.trigger waittill("trigger", user);

        // Show message to everyone, let they know what player did...
        //iPrintln( user.name + " ^7teleported." );

        // Get best destination away from enemies. We want to be safe there!
        //final_destination = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( destination );

        // Teleport user to destination
        if (user.isBot) {
            if ((isDefined(level.wp.size)) && (level.wp.size > 0)) {
                // This map uses waypoints
                wp = level.wp[randomint(level.wp.size)];
                user thread teleOut(self, wp.origin, user.angles);
            } else {
                // This is a legacy map that doesn't use waypoints
                spawn = scripts\gamemodes\_survival::getRandomSpawn();
                user thread teleOut(self, spawn.origin, user.angles);
            }
        }
        wait 1.5;
    }
}

destroyInTime(time)
{
    debugPrint("in _teleporter::destroyInTime()", "fn", level.lowVerbosity);

    wait time;
    level scripts\players\_usables::removeUsable(self);
    level.teleporter = removeFromArray(level.teleporter, self);
    level.teles -= 1;
    self delete();
}

teleOut( teleporter, origin, angles )
{
    debugPrint("in _teleporter::teleOut()", "fn", level.lowVerbosity);

    self endon("disconnect");
    self endon("death");
    //self endon("teleported");

    //self notify("teleported");
    if (!self.canTeleport)
    return;

    self.canTeleport = false;
    self thread enableTele(4);

    // Play sound
    teleporter playSound( "telein" );

    self shellShock( "teleporter", 1.4);
    wait 0.18;

    self setPlayerAngles( angles );

    if (self.isBot)
    {
        self.myWaypoint = undefined;
        self.underway = false;
        self.linkObj.origin = origin;
    }
    else
    {
        self setorigin( origin);
    }

    wait 0.4;
    self playSound( "teleout" );
}

enableTele(time)
{
    debugPrint("in _teleporter::enableTele()", "fn", level.lowVerbosity);

    wait time;
    self.canTeleport = true;
}
