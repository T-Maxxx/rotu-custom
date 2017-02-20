/* Not required localization. */
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

damageEnt(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, damagepos, damagedir)
{
    debugPrint("in entities::damageEnt()", "fn", level.medVerbosity);

    if (self.isPlayer) {
        self.damageOrigin = damagepos;
        self.entity thread [[level.callbackPlayerDamage]](
            eInflictor,     // eInflictor The entity that causes the damage.(e.g. a turret)
            eAttacker,      // eAttacker The entity that is attacking.
            iDamage,        // iDamage Integer specifying the amount of damage done
            0,              // iDFlags Integer specifying flags that are to be applied to the damage
            sMeansOfDeath,  // sMeansOfDeath Integer specifying the method of death
            sWeapon,        // sWeapon The weapon number of the weapon used to inflict the damage
            damagepos,      // vPoint The point the damage is from?
            damagedir,      // vDir The direction of the damage
            "none",         // sHitLoc The location of the hit
            0               // psOffsetTime The time offset for the damage
        );
    } else {
        // destructable walls and such can only be damaged in certain ways.
        if (self.isADestructable && (sWeapon == "artillery_mp" || sWeapon == "claymore_mp")) {
            return;
        }

        self.entity notify("damage", iDamage, eAttacker, (0,0,0), (0,0,0), "mod_explosive", "", "" );
    }
}

getClosestEntity(targetname, type)
{
    debugPrint("in entities::getClosestEntity()", "fn", level.lowVerbosity);

    if (!isdefined(type)) {type = "targetname";}

    ents = getentarray(targetname, type);
    nearestEnt = undefined;
    nearestDistance = 9999999999;
    for (i=0; i<ents.size; i++) {
        ent = ents[i];
        distance = Distance(self.origin, ent.origin);

        if(distance < nearestDistance) {
            nearestDistance = distance;
            nearestEnt = ent;
        }
    }
    return nearestEnt;
}

getClosestPlayer()
{
    debugPrint("in entities::getClosestPlayer()", "fn", level.lowVerbosity);

    ents = level.players;
    nearestEnt = undefined;
    nearestDistance = 9999999999;
    for (i=0; i<ents.size; i++) {
        ent = ents[i];
        distance = Distance(self.origin, ent.origin);

        if(distance < nearestDistance) {
            nearestDistance = distance;
            nearestEnt = ent;
        }
    }
    return nearestEnt;
}

getClosestPlayerArray()
{
    debugPrint("in entities::getClosestPlayerArray()", "fn", level.highVerbosity);

    playerCount = level.players.size;

    nearPlayers = [];
    nearDistance = [];
    for (i=0; i<playerCount; i++) {
        nearDistance[i] = 999999999;
    }

    for (i=0; i<playerCount; i++) {
        player = level.players[i];
        if (player.isAlive) {
            if (player.isTargetable) {
                distance = distanceSquared(self.origin, player.origin);
                for (j=0; j<playerCount; j++) {
                    if(distance < nearDistance[j]) {
                        for (k=i; k>=j; k--) {
                            nearDistance[k+1] = nearDistance[k];
                            nearPlayers[k+1] = nearPlayers[k];
                        }
                        nearDistance[j] = distance;
                        nearPlayers[j] = player;
                    }
                }
            }
        }
    }
    return nearPlayers;
}

getClosestTarget()
{
    debugPrint("in entities::getClosestTarget()", "fn", level.highVerbosity);

    ents = level.players;
    nearestEnt = undefined;
    nearestDistance = 9999999999;
    for (i=0; i<ents.size; i++) {
        ent = ents[i];
        if (!isDefined(ent)) {continue;}
        distance = Distance(self.origin, ent.origin);
        if (ent.isAlive) {
            if (!ent.isTargetable) {continue;}
            if (distance < nearestDistance) {
                nearestDistance = distance;
                nearestEnt = ent;
            }
        }
    }
    return nearestEnt;
}

getRandomEntity(targetname)
{
    debugPrint("in entities::getRandomEntity()", "fn", level.lowVerbosity);

    ents = getentarray(targetname, "targetname");
    if (ents.size > 0) {
        return ents[randomint(ents.size)];
    }
}

getRandomTdmSpawn()
{
    debugPrint("in entities::getRandomTdmSpawn()", "fn", level.lowVerbosity);

    currentSpawns = getentarray("mp_tdm_spawn", "classname");
    return currentSpawns[randomint(currentSpawns.size)];
}
