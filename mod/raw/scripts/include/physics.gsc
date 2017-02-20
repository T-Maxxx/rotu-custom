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

delayStartRagdoll(ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath)
{
    debugPrint("in physics::delayStartRagdoll()", "fn", level.highVerbosity);

    if (isDefined(ent)) {
        deathAnim = ent getcorpseanim();
        if (animhasnotetrack(deathAnim, "ignore_ragdoll")) {return;}
    }

    wait(0.1);

    if (level.dvar["game_extremeragdoll"]) {
        if (!isDefined(vDir)) {vDir = (0,0,0);}

        if (!isDefined(ent.origin)) {
            // weapons causing this are m60e4_acog_mp (aa12) and c4_mp
            //logPrint("physics bug: weapon is: " + sWeapon + "ent.type: " + ent.type + "\n"); // taff
            // If ent.origin isn't defined, it isn't a player or bot, so we don't have to worry about ragdoll
            return;
        }
        explosionPos = ent.origin + ( 0, 0, getHitLocHeight( sHitLoc ) );
        explosionPos -= vDir * 20;
        //thread debugLine( ent.origin + (0,0,(explosionPos[2] - ent.origin[2])), explosionPos );
        explosionRadius = 10;
        explosionForce = .75;
        if (sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_EXPLOSIVE" ||
            isSubStr(sMeansOfDeath, "MOD_GRENADE") || isSubStr(sMeansOfDeath, "MOD_PROJECTILE") ||
            sHitLoc == "head" || sHitLoc == "helmet")
        {
            explosionForce = 2.5;
        }

        ent startragdoll(1);
        wait .05;

        if (!isDefined(ent)) {return;}

        // apply extra physics force to make the ragdoll go crazy
        physicsExplosionSphere(explosionPos, explosionRadius, explosionRadius / 2, explosionForce);
        return;
    } else {
        if (!isDefined(ent)) {return;}
        if (ent isRagDoll()) {return;}

        deathAnim = ent getcorpseanim();
        startFrac = 0.35;

        if (animhasnotetrack(deathAnim, "start_ragdoll")) {
            times = getnotetracktimes( deathAnim, "start_ragdoll" );
            if (isDefined(times)) {startFrac = times[0];}
        }

        waitTime = startFrac * getanimlength(deathAnim);
        wait(waitTime);

        if (isDefined(ent)) {
            println("Ragdolling after " + waitTime + " seconds");
            ent startragdoll(1);

            iprintlnbold("HEYA");
        }
    }
}

getHitLocHeight(sHitLoc)
{
    debugPrint("in physics::getHitLocHeight()", "fn", level.highVerbosity);

    switch (sHitLoc) {
        case "helmet":
        case "head":
        case "neck":
            return 60;
        case "torso_upper":
        case "right_arm_upper":
        case "left_arm_upper":
        case "right_arm_lower":
        case "left_arm_lower":
        case "right_hand":
        case "left_hand":
        case "gun":
            return 48;
        case "torso_lower":
            return 40;
        case "right_leg_upper":
        case "left_leg_upper":
            return 32;
        case "right_leg_lower":
        case "left_leg_lower":
            return 10;
        case "right_foot":
        case "left_foot":
            return 5;
    }
    return 48;
}

drop(origin, drop)
{
    debugPrint("in physics::drop()", "fn", level.lowVerbosity);

    trace = bulletTrace(origin, origin + (0,0,-1 * drop), false, self);

    //if(trace["fraction"] < 1 && !isdefined(trace["entity"]))
   // {
        //smooth clamp
//        self SetOrigin(trace["position"]);
        //if (!isdefined(trace["entity"]))
        //self.Mover.origin = trace["position"];// + (0.0, 5.0, 0.0);
        return trace["position"];
  // }
}

dropPlayer(origin, drop)
{
    // 7th most-called function (2% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    return playerPhysicsTrace(origin, origin + (0,0,-1 * drop));
}

vectorscale(vector, scale)
{
    debugPrint("in physics::vectorscale()", "fn", level.lowVerbosity);

    return vector * scale;
}
