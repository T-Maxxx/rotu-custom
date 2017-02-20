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

#include common_scripts\utility;
#include scripts\include\utility;
#include scripts\include\matrix;

init()
{
    debugPrint("in _turrets::init()", "fn", level.nonVerbose);

    level.sentry_turret_model["minigun"] = "mw2_sentry_turret";
    level.sentry_base_model["minigun"] = "mw3_sentry_gl_base";
    level.sentry_turret_model["gl"] = "mw3_sentry_gl_turret";
    level.sentry_base_model["gl"] = "mw3_sentry_gl_base";

    precacheModel(level.sentry_turret_model["minigun"]);
    precacheModel(level.sentry_base_model["minigun"]);
    precacheModel(level.sentry_turret_model["gl"]);
    precacheModel(level.sentry_base_model["gl"]);

    precacheString(&"ROTUSCRIPT_PRESS_TO_MOVE_TURRET");
    precacheString(&"ROTUSCRIPT_CANT_DEPLOY_CLOSE_TO_SHOP");
    precacheString(&"ROTUSCRIPT_CANT_DEPLOY_CLOSE_TO_BARREL");
    precacheString(&"ROTUSCRIPT_CANT_DEPLOY_CLOSE_TO_TELEPORT");
    precacheString(&"ROTUSCRIPT_CANT_DEPLOT_CLOSE_TO_BARRICADE");
    precacheString(&"ROTUSCRIPT_CANT_DEPLOY_TURRET_HERE");
    precacheString(&"ROTUSCRIPT_TURRET_DEPLOYED_BY");

    level._effect["turret_flash"] = loadFx("muzzleflashes/custom_minigun_flash");
    level._effect["overheat"] = loadFx("smoke/heli_engine_smolder");

    level.effect_sentry_hit["gl"] = loadFx("explosions/grenadeExp_blacktop");
    level.effect_sentry_hit["minigun"] = loadFx("impacts/flesh_hit_body_fatal_exit");

    level.effect_sentry_impact["gl"] = level.effect_sentry_hit["gl"];
    level.effect_sentry_impact["minigun"] = loadFx("impacts/large_metalhit_1");

    level.redLaserSight = loadFx("misc/laser_sight_red");
    level.greenLaserSight = loadFx("misc/laser_sight_green");
    level.blueLaserSight = loadFx("misc/laser_sight_blue");
    level.test = loadFx("fire/firelp_small_pm_rotu");

    // Create the Mk19 Grenade turrets for this game
    level.maxGrenadeTurrets = getDvarInt("game_max_grenade_turrets");
    level.maxGrenadeTurretAmmo = getDvarInt("game_grenade_turret_max_ammo");
    level.grenadeTurretMinimumDamage = getDvarInt("game_grenade_turret_min_damage");
    level.grenadeTurretPrestigeUnlock = getDvarInt("game_grenade_turret_prestige_unlock");
    level.grenadeTurretCount = 0;
    level.grenadeTurrets = [];
    thread createGrenadeTurrets();

    // Create the Minigun turrets for this game
    level.maxMinigunTurrets = getDvarInt("game_max_minigun_turrets");
    level.maxMinigunTurretAmmo = getDvarInt("game_minigun_turret_max_ammo");
    level.minigunTurretMinimumDamage = getDvarInt("game_minigun_turret_min_damage");
    level.minigunTurretPrestigeUnlock = getDvarInt("game_minigun_turret_prestige_unlock");
    level.minigunTurretCount = 0;
    level.minigunTurrets = [];
    thread createMinigunTurrets();

    level.turretTargetDelay = getDvarFloat("game_defense_turret_target_delay");

    level.engagements = 0;
    level.misses = 0;
    level.playersHit = 0;
    level.botsHit = 0;
    level.targetRequests = 0;
    level.unknownEntityHits = 0;
    level.undefinedTraceEntities = 0;
}

/**
 * @brief Creates the maximum number of grenade turrets at startup
 *
 * @returns nothing
 */
createGrenadeTurrets()
{
    debugPrint("in _turrets::createGrenadeTurrets()", "fn", level.nonVerbose);

    for (i=0; i<level.maxGrenadeTurrets; i++) {
        thread createGrenadeTurret();
        wait 0.5;
    }
}

/**
 * @brief Creates the maximum number of minigun turrets at startup
 *
 * @returns nothing
 */
createMinigunTurrets()
{
    debugPrint("in _turrets::createMinigunTurrets()", "fn", level.nonVerbose);

    for (i=0; i<level.maxMinigunTurrets; i++) {
        thread createMinigunTurret();
        wait 0.5;
    }
}

/**
 * @brief Creates a grenade turret
 *
 * Grenade and minigun turrets are created when the game starts, and are never
 * deleted.  Rather, they are moved and hidden.  This is to prevent any forced
 * player disconnects as we experienced with the MG+Barrels.
 *
 * @returns nothing
 */
createGrenadeTurret()
{
    debugPrint("in _turrets::createGrenadeTurret()", "fn", level.nonVerbose);

    // Put the turret in an out-of-the-way spot to prevent the 'Press F to use'
    // usable from showing up
    origin = (0,0,-8900);

    // height of top of gun mount.  good value for gl
    heightOffset = 20;
    turret = spawn("script_model", origin);
    turret.spawnOrigin = origin;
    turret.spawnAngles = turret.angles;
    turret.gun = spawn("script_model", origin + (0,0,heightOffset));
    turret.gun.spawnAngles = turret.gun.angles;

    turret.gun.turretType = "gl";

    turret.gun setModel(level.sentry_turret_model[turret.gun.turretType]);
    turret setModel(level.sentry_base_model[turret.gun.turretType]);

    // makes gun show up with base when you buy it
    turret.gun linkto(turret);

    turret.gun setContents(0);
    turret setContents(0);

    turret.gun.fireSpeed = 1;
    turret.gun.numBullets = 1;
    turret.gun.minDamage = level.grenadeTurretMinimumDamage;
    turret.gun.slewRate = 720;  // gun slew rate, in degrees per second
    turret.gun.barrelTag = "tag_turret";
    turret.gun.maxAmmo = level.maxGrenadeTurretAmmo;    // max ammo
    turret.gun.ammo = turret.gun.maxAmmo;               // current ammmo

    turret.owner = undefined;

    // Hide the turret
    turret hide();
    turret.gun hide();

    // Mark the turret as not being deployed
    turret.isDeployed = false;

    // track whether the turret is currently being killed
    turret.isBeingKilled = false;

    turret.id = "gl-" + level.grenadeTurrets.size;

    // Add the turret to the level array
    level.grenadeTurrets[level.grenadeTurrets.size] = turret;

    level scripts\players\_usables::addUsable(turret, "turret", &"ROTUSCRIPT_PRESS_TO_MOVE_TURRET", 80);

    thread watchTurretOwnership(turret);
}

/**
 * @brief Creates a minigun turret
 *
 * Grenade and minigun turrets are created when the game starts, and are never
 * deleted.  Rather, they are moved and hidden.  This is to prevent any forced
 * player disconnects as we experienced with the MG+Barrels.
 *
 * @returns nothing
 */
createMinigunTurret()
{
    debugPrint("in _turrets::createMinigunTurret()", "fn", level.nonVerbose);

    // Put the turret in an out-of-the-way spot to prevent the 'Press F to use'
    // usable from showing up
    origin = (0,0,-9000);

    // height of top of gun mount.  good value for minigun
    heightOffset = 30;
    turret = spawn("script_model", origin);
    turret.spawnOrigin = origin;
    turret.spawnAngles = turret.angles;
    turret.gunBarrel = spawn("script_model", origin + (0,0,heightOffset));
    turret.gun = spawn("script_model", origin + (0,0,heightOffset));
    turret.gun.spawnAngles = turret.gun.angles;

    turret.gun.turretType = "minigun";

    turret.gun setModel(level.sentry_turret_model[turret.gun.turretType]);
    turret setModel(level.sentry_base_model[turret.gun.turretType]);

    turret.gunBarrel setModel(level.sentry_turret_model[turret.gun.turretType]);
    // hide extra tripod on the main minigun and the barrel
    turret.gun hidePart("tag_base");
    turret.gun hidePart("tag_barrel"); // hides barrel

    // hide all parts of second minigun, then show just the barrel
    turret.gunBarrel hidePart("tag_base");
    turret.gunBarrel hidePart("tag_swivel");
    turret.gunBarrel hidePart("tag_gun");
    turret.gunBarrel LinkTo(turret.gun, "j_barrel_anchor", (0,0,0), (0,0,0));

    // makes gun show up with base when you buy it
    turret.gun linkto(turret);

    turret.gunBarrel setContents(0);

    turret.gun setContents(0);
    turret setContents(0);

    turret.gun.fireSpeed = 0.2;
    turret.gun.numBullets = 4;
    turret.gun.minDamage = level.minigunTurretMinimumDamage;
    turret.gun.slewRate = 720;   // gun slew rate, in degrees per second
    turret.gun.barrelTag = "j_barrel_anchor";
    turret.gun.maxAmmo = level.maxMinigunTurretAmmo;    // max ammo
    turret.gun.ammo = turret.gun.maxAmmo;               // current ammo

    turret.owner = undefined;

    // Hide the turret
    turret hide();
    turret.gun hide();
    turret.gunBarrel hide();

    // Mark the turret as not being deployed
    turret.isDeployed = false;

    // track whether the turret is currently being killed
    turret.isBeingKilled = false;

    turret.id = "minigun-" + level.minigunTurrets.size;

    // Add the turret to the level array
    level.minigunTurrets[level.minigunTurrets.size] = turret;

    level scripts\players\_usables::addUsable(turret, "turret", &"ROTUSCRIPT_PRESS_TO_MOVE_TURRET", 80);

    thread watchTurretOwnership(turret);
}

/// runs some code to test the matrix library for development purposes
/*testMatrix()
{
    /// linear algebra testing
    matrix = zeros(3,3);
    printMatrix(matrix);

    matrix = ones(3,3);
    printMatrix(matrix);

    matrix = zeros(1,5);
    printMatrix(matrix);

    matrix = zeros(5,1);
    printMatrix(matrix);

    matrix = eye(4);
    printMatrix(matrix);

    setValue(matrix, 2, 1, 8);
    data = value(matrix, 2, 1);
    debugPrint("data: " + data, "val");
    printMatrix(matrix);
    setValue(matrix, 4, 4, 6);
    printMatrix(matrix);
    setValue(matrix, 1, 1, 10);
    printMatrix(matrix);
    matrix = transpose(matrix);
    printMatrix(matrix);

    data = [];
    data[0] = 1;
    data[1] = 3;
    data[2] = 5;
    data[3] = 7;
    matrix = rowVector(data);
    printMatrix(matrix);
    matrix = columnVector(data);
    printMatrix(matrix);

    matrix = transpose(matrix);
    printMatrix(matrix);

    matrix = zeros(2,3);
    setValue(matrix, 1, 1, 1);
    setValue(matrix, 1, 2, 3);
    setValue(matrix, 1, 3, 5);
    setValue(matrix, 2, 1, 2.2);
    setValue(matrix, 2, 2, 4);
    setValue(matrix, 2, 3, 6);
    printMatrix(matrix);

    matrix = transpose(matrix);
    printMatrix(matrix);

    matrix = transpose(matrix);
    printMatrix(matrix);

    matrix = augment(matrix);
    printMatrix(matrix);

    A = zeros(2,3);
    setValue(A, 1, 1, 4);
    setValue(A, 1, 2, 0);
    setValue(A, 1, 3, 5);
    setValue(A, 2, 1, -1);
    setValue(A, 2, 2, 3);
    setValue(A, 2, 3, 2);

    B = zeros(2,3);
    setValue(B, 1, 1, 1);
    setValue(B, 1, 2, 1);
    setValue(B, 1, 3, 1);
    setValue(B, 2, 1, 3);
    setValue(B, 2, 2, 5);
    setValue(B, 2, 3, 7);

    C = addMatrices(A, B);
    printMatrix(C);

    A = zeros(2,2);
    setValue(A, 1, 1, 5);
    setValue(A, 1, 2, 1);
    setValue(A, 2, 1, 3);
    setValue(A, 2, 2, -2);

    B = zeros(2,2);
    setValue(B, 1, 1, 2);
    setValue(B, 1, 2, 0);
    setValue(B, 2, 1, 4);
    setValue(B, 2, 2, 3);

    AB = matrixMultiply(A, B);
    printMatrix(AB);

    BA = matrixMultiply(B, A);
    printMatrix(BA);

    detB = determinant(B);
    debugPrint("determinant of B: " + detB, "val");

    printMatrix(B);
    inverseB = inverseMatrix(B);
    printMatrix(inverseB);
    C = inverseMatrix(inverseB);
    printMatrix(C);

    printMatrix(B);
    I = matrixMultiply(B, inverseB);
    printMatrix(I);

    A = zeros(3,5);
    setValue(A, 1, 1, 4);
    setValue(A, 1, 2, 0);
    setValue(A, 1, 3, 5);
    setValue(A, 1, 4, 6);
    setValue(A, 1, 5, 2);
    setValue(A, 2, 1, -1);
    setValue(A, 2, 2, 3);
    setValue(A, 2, 3, -2);
    setValue(A, 2, 4, 0);
    setValue(A, 2, 5, 0);
    setValue(A, 3, 1, -1);
    setValue(A, 3, 2, 3);
    setValue(A, 3, 3, 9);
    setValue(A, 3, 4, 4);
    setValue(A, 3, 5, 2);

    printMatrix(A);
    D = partition(A,":",":");
    printMatrix(D);
    E = partition(A,":", "2");
    printMatrix(E);
    G = partition(A,":", "5");
    printMatrix(G);
    H = partition(A,":", "1");
    printMatrix(H);
    J = partition(A,":", "2:4");
    printMatrix(J);
    F = partition(A,"1:2", "2:5");
    printMatrix(F);
    K = partition(A,"3", "2:5");
    printMatrix(K);

    L = stringToIntegerMatrix("[1 2  3 4; 5 6   7 8; 9 4      3 2]");
    printMatrix(L);

    M = stringToIntegerMatrix("[1 2; 3 4]");
    N = stringToIntegerMatrix("[5 6; 2 8]");
    O = matrixMultiply(M,N);
    printMatrix(O);

    printMatrix(A);
    P = ref(A);
    printMatrix(P);
    Q = rref(A);
    printMatrix(Q);

    R = stringToIntegerMatrix("[1 2 3; 4 5 6; 7 8 9]");
    S = solve(R);
    printMatrix(S);

    R = stringToIntegerMatrix("[1 0 -2; 3 1 -2; -5 -1 9]");
    printMatrix(R);
    T = inverseMatrix(R);
    if (isDefined(T)) {
        printMatrix(T);
    }
    U = stringToIntegerMatrix("[1 0 -2; 3 1 -2; -5 -1 9]");
    V = stringToIntegerMatrix("[1 2 4; 4 9 -2; 8 -7 3]");
    W = appendMatrix(U, V);
    printMatrix(W);

    X = stringToIntegerMatrix("[2 -8 6 8; 3 -9 5 10; -3 0 1 -2; 1 -4 0 6]");
    detX = determinant(X);
    debugPrint("detX: " + detX, "val");
}*/

/**
 * @brief Finds the first available deployable turret
 *
 * @param turretType The type of turret to find
 * \c turretType is one of "gl" or "minigun"
 *
 * @returns the turret if one is deployable, otherwise returns undefined
 */
deployableTurret(turretType)
{
    debugPrint("in _turrets::deployableTurret()", "fn", level.nonVerbose);

    if (turretType == "gl") { // grenade turret
        // Iterate through the grenade turrets and return the first one that
        // is deployable
        for (i=0; i<level.grenadeTurrets.size; i++) {
            if (!level.grenadeTurrets[i].isDeployed) { // turret.isDeployed = false;
                level.grenadeTurrets[i].isDeployed = true;
                return level.grenadeTurrets[i];
            }
        }
    } else { // minigun turret
        // Iterate through the minigun turrets and return the first one that
        // is deployable
        for (i=0; i<level.minigunTurrets.size; i++) {
            if (!level.minigunTurrets[i].isDeployed) {
                level.minigunTurrets[i].isDeployed = true;
                return level.minigunTurrets[i];
            }
        }
    }
}

/**
 * @brief Gives a grenade turret to the player
 *
 * @param turret The grenade turret to give to the player
 *
 * @returns nothing
 */
giveGrenadeTurret(turret)
{
    debugPrint("in _turrets::giveGrenadeTurret()", "fn", level.nonVerbose);

    if (isDefined(turret)) {
        level.grenadeTurretCount++;
        debugPrint("level.grenadeTurretCount: " + level.grenadeTurretCount, "val");
        debugPrint("Giving turret " + turret.id + " to " + self.name, "val");

        turret show();
        turret.gun show();
        turret.gun.owner = self;
        turret.gun.owner.ownsTurret = true;

        // Make the player carry the grenade turret
        self.carryObj = turret;
        self.carryObj.origin = self.origin + AnglesToForward(self.angles)*48;
        self.carryObj.angles = self.angles;
        self.carryObj.master = self;

        self.carryObj linkto(self);
        self.carryObj setcontents(2);

        self.canUse = false;
        self disableweapons();

        // Let the player place the grenade turret
        self thread emplaceDefenseTurret(turret);

    } else {
        // There aren't any deployable grenade turrets
        // We can't get here, since _shop.gsc prevents us from buying a grenade turret
        // unless there is less than the maximum deployed
        errorPrint("There isn't a deployable grenade turret, but level.grenadeTurretCount says there is.");
        debugPrint("level.grenadeTurretCount: " + level.grenadeTurretCount, "val");
    }
}

/**
 * @brief Gives a minigun turret to the player
 *
 * @param turret The minigun turret to give to the player
 *
 * @returns nothing
 */
giveMinigunTurret(turret)
{
    debugPrint("in _turrets::giveMinigunTurret()", "fn", level.nonVerbose);

    if (isDefined(turret)) {
        level.minigunTurretCount++;
        debugPrint("Giving turret " + turret.id + " to " + self.name, "val");

        turret show();
        turret.gun show();
        turret.gunBarrel show();
        turret.gun.owner = self;
        turret.gun.owner.ownsTurret = true;

        // Make the player carry the MG+barrel
        self.carryObj = turret;
        self.carryObj.origin = self.origin + AnglesToForward(self.angles)*48;
        self.carryObj.angles = self.angles;
        self.carryObj.master = self;

        self.carryObj linkto(self);

        self.canUse = false;
        self disableweapons();

        // Let the player place the minigun turret
        self thread emplaceDefenseTurret(turret);

    } else {
        // There aren't any deployable minigun turrets
        // We can't get here, since _shop.gsc prevents us from buying a minigun turret
        // unless there is less than the maximum deployed
        errorPrint("There isn't a deployable minigun turret, but level.minigunTurretCount says there is.");
    }
}

/// Only used for development
primarySectorLaser(turret)
{
    debugPrint("in _turrets::primarySectorLaser()", "fn", level.lowVerbosity);

    self endon("death");
    self endon("disconnect");

    wait 0.05;
    playFXOnTag(level.greenLaserSight, turret.gun, turret.gun.barrelTag);
}


/**
 * @brief Places a defense turret at an acceptable location on the map
 *
 * @param turret The turret to emplace
 *
 * @returns nothing
 */
emplaceDefenseTurret(turret)
{
    debugPrint("in _turrets::emplaceDefenseTurret()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");
    self endon("joined_spectators");

    self thread zombieEmplaceDefenseTurret(turret);

    turret.isBeingMoved = true;

    wait 1;
    useObjects = level.useObjects;
    while (1) {
        // Do not let them emplace the turret hanging in the air
        if (!self isOnGround()) {
            wait 0.05;
            continue;
        }
        if (self attackbuttonpressed()) {
            tooCloseToAmmoShop = false;
            tooCloseToBarricade = false;
            tooCloseToBarrel = false;
            tooCloseToTeleporter = false;

            for (i=0; i<useObjects.size; i++) {
                /// @bug Fixed. On Madhouse Alaska map, somehow useObjects[i].type is undefined sometimes;
                /// The error prevents emplacing the turret, and generates infinite errors until the game ends normally.
                if ((!isDefined(useObjects[i])) || (!isDefined(useObjects[i].type))) {continue;}
                if ((useObjects[i].type == "extras") ||
                    (useObjects[i].type == "ammobox")) {
                    if (distance(useObjects[i].origin, self.origin) < 130) {
                        tooCloseToAmmoShop = true;
                        break;
                    }
                }
            }
            if (tooCloseToAmmoShop) {
                self iPrintlnBold(&"ROTUSCRIPT_CANT_DEPLOY_CLOSE_TO_SHOP");
                wait 0.5;
                continue;
            }

            for (i=0; i<level.dynamic_barricades.size; i++) {
                if (level.dynamic_barricades[i].type == 1) {minimumDistance = 110;}
                else {minimumDistance = 60;}
                if (distance(level.dynamic_barricades[i].origin, self.origin) < minimumDistance) {
                    tooCloseToBarrel = true;
                    break;
                }
            }
            if (tooCloseToBarrel) {
                self iPrintlnBold(&"ROTUSCRIPT_CANT_DEPLOY_CLOSE_TO_BARREL");
                wait 0.5;
                continue;
            }

            for (i=0; i<level.teleporter.size; i++) {
                if (distance(level.teleporter[i].origin, self.origin) < 140) {
                    tooCloseToTeleporter = true;
                    break;
                }
            }
            if (tooCloseToTeleporter) {
                self iPrintlnBold(&"ROTUSCRIPT_CANT_DEPLOY_CLOSE_TO_TELEPORT");
                wait 0.5;
                continue;
            }

            for (i=0; i<level.barricades.size; i++) {
                if (distance(level.barricades[i].origin, self.origin) < 300) {
                    tooCloseToBarricade = true;
                    break;
                }
            }
            if (tooCloseToBarricade) {
                self iPrintlnBold(&"ROTUSCRIPT_CANT_DEPLOT_CLOSE_TO_BARRICADE");
                wait 0.5;
                continue;
            }

            // We ensure we have a clear line of sight from the turret's pivot to
            // the surface of a cylinder of radius 45-55 units whose axial line
            // extends vertically through the turret's pivot.  We check the sight
            // line every 15 degrees and at a range of heights above the base.
            // This ensures the turret can't be placed inside of walls and such,
            // or where it may rotate into walls and such.
            angles = turret.gun.angles;
            pivot = self.origin + (0,0,20) + vectorscale(anglesToForward(angles), 20);
            base =  self.origin + (0,0,0) + vectorscale(anglesToForward(angles), 20);
            if (turret.gun.turretType == "gl") {
                length = 45;
            } else { // minigun
                length = 55;
            }
            okToPlant = true;
            for (h = 5; h<70; h = h + 10) {
                for (i=0; i<360; i = i + 15) {
                    end = base + (length * cos(i), length * sin(i), h);
                    if (!sightTracePassed(pivot, end, false, turret)) {
                        okToPlant = false;
                        break;
                    }
                }
                if(!okToPlant) {break;}
            }
            if (!okToPlant) {
                self iPrintlnBold(&"ROTUSCRIPT_CANT_DEPLOY_TURRET_HERE");
                wait 0.5;
                continue;
            } else { // place the turret
                self.carryObj unlink();
                wait .05;
                turret.isBeingMoved = false;
                turret.gun.primaryAngles = vectorToAngles(anglesToForward(turret.gun.angles));
                turret.gun.primaryUnitVector = vectorNormalize(anglesToForward(turret.gun.angles));

                // Must undefine self.carryObj or the turret gets delete()'d when
                // the player leaves the game
                self.carryObj = undefined;

                // good attempt to get turret.gun to rotate
                turret.gun unlink();

                self.canUse = true;
                self enableweapons();
                iprintln(&"ROTUSCRIPT_TURRET_DEPLOYED_BY", self.name);
                self thread beDefenseTurret(turret);
                self notify("turret_emplaced");
                return;
            }
        }
        wait .05;
    }
}

/**
 * @brief Drops a defense turret when a player becomes a zombie
 * Since the player didn't allow enough time to emplace the turret before becoming
 * a zombie, we don't let the turret fire until after the player-zombie is killed,
 * picks up the turret, then re-emplaces it.
 *
 * @param turret The turret to emplace
 *
 * @returns nothing
 */
zombieEmplaceDefenseTurret(turret)
{
    debugPrint("in _turrets::zombieEmplaceDefenseTurret()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");
    self endon("joined_spectators");

    self endon("no_longer_a_zombie");
    self endon("turret_emplaced");

    self waittill("zombify");
    turret.isBeingMoved = true;

    useObjects = level.useObjects;
    self.carryObj unlink();
    wait .05;
    turret.isBeingMoved = false;
    turret.gun.primaryAngles = vectorToAngles(anglesToForward(turret.gun.angles));
    turret.gun.primaryUnitVector = vectorNormalize(anglesToForward(turret.gun.angles));

    // Must undefine self.carryObj or the turret gets delete()'d when
    // the player leaves the game
    self.carryObj = undefined;

    // good attempt to get turret.gun to rotate
    turret.gun unlink();

    self.canUse = true;
    self enableweapons();
    self thread turretGoIdle(turret);
}

/**
 * @brief Returns the turret to the primary direction the player wants to cover
 *
 * @param turret The turret that should go idle
 *
 * @returns nothing
 */
turretGoIdle(turret)
{
    debugPrint("in _turrets::turretGoIdle()", "fn", level.veryHighVerbosity);

    self endon("joined_spectators");
    self endon("disconnect");

    turret endon("no_ammo");

    currentAngles = turret.gun getTagAngles(turret.gun.barrelTag);
    deltaAngle = length(turret.gun.primaryAngles - currentAngles);
    if (deltaAngle != 0) {
        slewTime = deltaAngle / turret.gun.slewRate;
        turret.gun rotateTo(turret.gun.primaryAngles, slewTime);
    } // else we are already at the idle position
}

/**
 * @brief Plays an animation and begins target tracking on turret emplacement
 *
 * @param turret The turret to animate
 *
 * @returns nothing
 */
beDefenseTurret(turret)
{
    debugPrint("in _turrets::beDefenseTurret()", "fn", level.nonVerbose);

    self endon("joined_spectators");
    self endon("disconnect");

    turret endon("no_ammo");

    // Cool, but totally unessesary, animation of turret emplacement
    self thread turretGoIdle(turret);
    wait 0.5;
    self yawTurret(turret, -120);
    wait 1.5;
    self yawTurret(turret, 240);
    wait 1;
    self thread turretGoIdle(turret);
    self thread trackTarget(turret);
}

/**
 * @brief Yaws the turret relative to its local coordinate system
 *
 * @param turret The turret to yaw
 * @param yawAngle The angle local through which to yaw the turret.
 * Negative angles are (as viewed from above) ccw, and positive angles are cw.
 *
 * @returns nothing
 */
yawTurret(turret, yawAngle)
{
    debugPrint("in _turrets::yawTurret()", "fn", level.nonVerbose);

    self endon("joined_spectators");
    self endon("disconnect");

    turret endon("no_ammo");

    turret.gun rotateYaw(yawAngle, abs(yawAngle / turret.gun.slewRate));
}

/**
 * @brief Makes the turret appear to track a target
 * This function also requests targets and requests that a target be engaged.  We
 * only get the turret's point of aim 'close enough' before we try to engage the
 * target.
 *
 * @param turret The turret to have track targets
 *
 * @returns nothing
 */
trackTarget(turret)
{
    debugPrint("in _turrets::trackTarget()", "fn", level.nonVerbose);

    self endon("joined_spectators");
    self endon("disconnect");

    turret endon("no_ammo");
    turret endon("turret_being_moved");

    turret.gun.trackingLimit = 10;         // max number of times we should try to aim the turret at the target
    turret.gun.trackingCount = 0;          // number of times we have tried to track this target
    turret.gun.engagementLimit = 3;        // max number of failed target engagements
    turret.gun.engagementCount = 0;        // number of times we have failed to engage this target

    while (1) {
        t_predict = 0.01;
        t_slew = 0;
        mode = "follow";
        turret.gun.trackingCount = 0;
        while (!level.waveIntermission) {
            turret.gun.trackingBegan = getTime();
            turret.gun.trackingCount = 0;
            turret.gun.engagementCount = 0;
            while (isDefined(turret.gun.targetPlayer)) {
                if (mode == "follow") {  // follow target
                    // aiming point on target, 48 inches up from feet
                    r_target = turret.gun.targetPlayer.origin + (0,0,turret.gun.targetPlayer.turretAimHeight);
                    // bots are hidden at (0,0,-10000), so bail if bot is on it's way to limbo
                    if (r_target[2] < -9300) {
                        self nextTarget(turret);
                        continue;
                    }
                    r_barrel = turret.gun getTagOrigin(turret.gun.barrelTag);

                    turret.gun.angles = turret.gun getTagAngles(turret.gun.barrelTag);

                    r_target_relative_to_gun =  r_target - r_barrel;
                    turret.gun.aimingAngles = vectorToAngles(r_target_relative_to_gun);

                    distance = length(r_target_relative_to_gun);
                    if (distance < 25) {distance = 25;}
                    tolerance = atan(6/distance);  // tolerance is a 12 inch diameter circle on target

                    delta_theta = length(turret.gun.aimingAngles - turret.gun.angles);
                    t_slew_min = abs(delta_theta / turret.gun.slewRate);
                    if (t_slew_min <= 0) {t_slew = 0.00001;}
                    else {t_slew = t_slew_min;}

    //                 debugPrint("delta_theta: " + delta_theta + " t_slew: " + t_slew + " t_slew_min: " + t_slew_min, "val");
                    if (turret.isBeingKilled) {return;}
                    if (delta_theta < tolerance) {
                        // the turret is generally pointing int the target's direction
                        trackingTime = (getTime() - turret.gun.trackingBegan) / 1000;
                        if (turret isInView(turret.gun.targetPlayer) == -1) {
                            // zombie isn't in view anymore!
//                             debugPrint("Zombie isn't in view anymore.", "val");
                            // move on to next target
                            self nextTarget(turret);
                            continue;
                        } else {
                            visibilityAmount = turret.gun.targetPlayer SightConeTrace(turret.gun.origin, turret);
//                             debugPrint("Target visibility: " + visibilityAmount, "val");
                        }
                        if ((!isAlive(turret.gun.targetPlayer)) || (turret.gun.targetPlayer.sessionstate == "dead")) {
                            // zombie isn't alive anymore!
//                             debugPrint("Zombie isn't alive anymore.", "val");
                            // move on to next target
                            self nextTarget(turret);
                            continue;
                        }
//                         debugPrint("Engaging target.  Tracking time was: " + trackingTime + " seconds.", "val");
                        if (!self engageTarget(turret)) {
                            if (turret.isBeingKilled) {return;}
                            if (!isDefined(turret.gun.targetPlayer)) {
                                // target was killed (perhaps by someone else), move on to next target
                                self nextTarget(turret);
                                continue;
                            }
                            // we failed to engage the target
                            turret.gun.engagementCount++;
                            turret.gun.trackingBegan = getTime();
                            if (turret.gun.engagementCount >= turret.gun.engagementLimit) {
//                                 debugPrint("Engagement count exceeded on bot: " + turret.gun.targetPlayer.name, "val");
                                // move on to next target
                                turret.gun.badTarget = turret.gun.targetPlayer.name;
                                self nextTarget(turret);
                                continue;
                            }
                        } else {
                            // we hit the target
                            if (turret.isBeingKilled) {return;}
                            turret.gun.badTarget = undefined;
                            if (!isDefined(turret.gun.targetPlayer)) {
                                // target was killed, move on to next target
                                self nextTarget(turret);
                                continue;
                            } else {
                                // target is still alive, re-engage
                                wait 0.05;
                                turret.gun.trackingCount = 0;
                                turret.gun.trackingBegan = getTime();
                                continue;
                            }
                        }
                    } else {
                        // the turret has failed to generally point in the target's direction
                        if (turret.gun.trackingCount > turret.gun.trackingLimit) {
                            // if we can't zero in on target within trackingLimit tries,
                            // move on to next target
//                             debugPrint("Failed to track target.", "val");
                            self nextTarget(turret);
                            continue;
                        }
                    }
                    turret.gun rotateTo(turret.gun.aimingAngles, t_slew);
                    // wait until gun barrel is rotated to aiming angles.  Too many
                    // rapid calls to rotateTo() creates serious jittering that prevents
                    // the gun from settling on the target
                    while (length(turret.gun.aimingAngles - turret.gun getTagAngles(turret.gun.barrelTag)) > tolerance) {
                        wait 0.05;
                    }
                    turret.gun.trackingCount++;
                } else { // lead target
                    /* Not Implemented */
                }
            } // end while targetPlayer is defined
            /// @bug FIXED. This hackish delay is required or COD thinks I have an infinite loop, even when I don't
            wait 0.05;
//             debugPrint("turret.gun.targetPlayer is undefined, looking for new targets.", "val");
            self selectTarget(turret);
            if (isDefined(turret.gun.targetPlayer)) {
//                 debugPrint("Found one target.", "val");
            } else {
                // no targets were found, wait one second before we try again
                wait 1;
            }
        } // end while not intermission
        level waittill("start_monitoring");
        wait 2 + randomFloatRange(0.5, 1.5);
    } // end while(1)

}

/**
 * @brief Prepares trackTarget() to get a new target
 *
 * @param turret The turret to prepare for a new target
 *
 * @returns nothing
 */
nextTarget(turret)
{
    debugPrint("in _turrets::nextTarget()", "fn", level.highVerbosity);

    turret endon("no_ammo");
    turret endon("turret_being_moved");

    self thread turretGoIdle(turret);
    turret.gun.targetPlayer = undefined;

    wait level.turretTargetDelay;
}

/**
 * @brief Engages a target when requested by trackTarget()
 *
 * @param turret The turret to use to enagage the target
 *
 * @returns boolean true if the engagement was successful, false otherwise
 */
engageTarget(turret)
{
    debugPrint("in _turrets::engageTarget()", "fn", level.veryHighVerbosity);

    self endon("joined_spectators");
    self endon("disconnect");
    turret endon("turret_being_moved");

    // getEye() only hits targets about 20% of the time, I do *much* better
    // doing the math myself
    startOrigin = turret.gun getTagOrigin(turret.gun.barrelTag);
    origin = turret.gun.targetPlayer.origin;
    botAimPoint = origin + (0,0,turret.gun.targetPlayer.turretAimHeight);

    predictedOffset = ((turret.gun.targetPlayer getVelocity()) * 0.01);
    endOrigin = origin + predictedOffset;
    endOrigin = origin + (0,0,turret.gun.targetPlayer.turretAimHeight);
    firingVector = endOrigin - startOrigin;

    longerVector = firingVector * 1.025;
    endOrigin = startOrigin + longerVector;

    // used for muzzle flash
    fw = anglesToForward(vectorToAngles(firingVector));

    trace = bullettrace(startOrigin, endOrigin, true, turret);
    postTraceLocation = turret.gun.targetPlayer.origin;

    level.engagements++;
    engageTarget = false;
    ent = undefined;
    hitPosition = undefined;

    if ((isDefined(trace["entity"])) && (!isPlayer(trace["entity"]))) {
        /** These are errors in the bullettrace() function. When a zombie carcas
         *  is only the ground, bullettrace() still hits their former body (now invisible).
         *  This happens 10-30% of the time, modally about 25% of the time.
         *  In these cases, we just assume a hit.
         */
        ent = turret.gun.targetPlayer;
        hitPosition = botAimPoint;
        level.unknownEntityHits++;
        engageTarget = true;
    } else if (!isDefined(trace["entity"])) {
        // These are cases where we actually missed the target
        level.undefinedTraceEntities++;
    } else {
        // The hit entity is a player (human or bot)
        ent = trace["entity"];
        hitPosition = trace["position"];
        if (trace["entity"].isBot) {
            level.botsHit++;
            engageTarget = true;
        } else {
            level.playersHit++;
        }
    }

//     debugPrint("engagements   unknownEntityHits    undefinedTraceEntities   players  bots", "val");
//     debugPrint(level.engagements + "\t\t    " + level.unknownEntityHits + "\t\t\t" + level.undefinedTraceEntities + "\t\t    " + level.playersHit + "\t    " + level.botsHit, "val");
//     debugPrint("Hit percentage: " + (((level.botsHit + level.unknownEntityHits) / level.engagements) * 100) + " percent", "val");

    if (!engageTarget) {
//         debugPrint("We can not engage this target.", "val");
        wait 0.2;
        return false;
    } else {
//         debugPrint("Firing at target.", "val");
        if (turret.gun.turretType == "gl") { // grenade turret
            for (i=0; i<turret.gun.numBullets; i++) {
                if ((!isAlive(ent)) || (ent.sessionstate == "dead")) {
                    self thread turretGoIdle(turret);
                    turret.gun.targetPlayer = undefined;
                    break;
                }

                playFx(level._effect["turret_flash"], startOrigin, fw);
                playFx(level.effect_sentry_hit[turret.gun.turretType], hitPosition);
                ent playsound("mrk_grenade_3");
                range = 200;
                m = ((40 - turret.gun.minDamage) / range);
                for (i=0; i<level.bots.size; i++) {
                    target = level.bots[i];
                    if ((target.sessionstate != "playing") || (!target.readyToBeKilled)) {continue;}
                    dist = distance(hitPosition, target.origin + (0,0,30));
                    damage = int(m * dist + turret.gun.minDamage + randomInt(12));
                    if (dist < range) {
                        target.isPlayer = true;
                        target.entity = target;
                        target thread [[level.callbackPlayerDamage]](turret, turret.gun.owner, damage, 0, "MOD_EXPLOSIVE", "turret_mp", hitPosition, vectornormalize((target.origin + (0,0,30)) - hitPosition), "none", 0);
                    }
                }
//                 damage = int(turret.gun.minDamage + randomInt(12));
//                 ent thread [[level.callbackPlayerDamage]](turret, turret.gun.owner, damage, 0, "MOD_EXPLOSIVE", "turret_mp", turret.gun.origin, vectornormalize(endOrigin - startOrigin), "none", 0);
                turret.gun.ammo--;
                if (turret.gun.ammo <= 0) {
                    debugPrint("Turret is out of ammo.", "val");
                    turret.gun.targetPlayer = undefined;
                    turret.isBeingKilled = true;
                    removeTurret(turret);
                    turret notify("no_ammo");
                    wait 0.05;
                    return true;
                }
                wait turret.gun.fireSpeed;
            }
        } else if (turret.gun.turretType == "minigun") { // minigun
            turret playsound("weap_minigun_spin_over_plr");
            turret.gunBarrel unlink(); // unlink barrel so it can rotate
            turret.gunBarrel RotateRoll(720, 3, 0, 0);
            for (i=0; i<turret.gun.numBullets; i++) {
                if ((!isAlive(ent)) || (ent.sessionstate == "dead")) {
                    self thread turretGoIdle(turret);
                    turret.gun.targetPlayer = undefined;
                    break;
                }

                playFx(level._effect["turret_flash"], startOrigin + fw * 40, fw);
                endOrigin = turret.gun.targetPlayer.origin + (0,0,turret.gun.targetPlayer.turretAimHeight);
                playFx(level.effect_sentry_hit[turret.gun.turretType], endOrigin);
                ent thread [[level.callbackPlayerDamage]](turret, turret.gun.owner, int(turret.gun.minDamage + randomInt(12)), 0, "MOD_RIFLE_BULLET", "turret_mp", turret.gun.origin, vectornormalize(endOrigin - startOrigin), "none", 0);
                turret.gun.ammo--;
                if (turret.gun.ammo <= 0) {
                    debugPrint("Turret is out of ammo.", "val");
                    turret.gun.targetPlayer = undefined;
                    // relink barrel
                    turret.gunBarrel LinkTo(turret.gun, "j_barrel_anchor", (0,0,0), (0,0,0));
                    turret.isBeingKilled = true;
                    removeTurret(turret);
                    turret notify("no_ammo");
                    wait 0.05;
                    return true;
                }
                wait turret.gun.fireSpeed;
                if (!isDefined(turret.gun.targetPlayer)) {break;}
            }
            // relink barrel
            turret.gunBarrel LinkTo(turret.gun, "j_barrel_anchor", (0,0,0), (0,0,0));
        }
        self thread turretGoIdle(turret);
        return true;
    }
}

/**
 * @brief Intelligently selects the best target for the turret
 * We consider the type of zombie, distance, visibility, and the differential
 * angle bewteen the zombie and the turret's primary vector.
 *
 * @param turret The turret to find a target for
 *
 * @returns nothing
 */
selectTarget(turret)
{
    debugPrint("in _turrets::selectTarget()", "fn", level.veryHighVerbosity);

    self endon("joined_spectators");
    self endon("disconnect");

    turret endon("no_ammo");
    turret endon("turret_being_moved");

    // Stop searching for a target when the wave ends
    level endon("wave_finished");

    beginTime = getTime();

    turret.gun.primaryTarget = undefined;
    bestTarget = undefined;
    bestDot = -2;

    players = level.players;

    level.targetRequests++;
//     debugPrint("Target requests: " + level.targetRequests, "val");

    // search through the bots looking for the best targets
    for(i=0; i<level.bots.size; i++) {
        if ((isDefined(turret.isBeingKilled)) && (turret.isBeingKilled)) {return;}
        zombie = level.bots[i];
        // I added the readyToBeKilled property because zombies can be spawned,
        // playing, and alive, and yet *still* not be on the map!
        if ((zombie.sessionstate != "playing") || (!zombie.readyToBeKilled)) {continue;}
        else if ((isDefined(turret.gun.badTarget)) && (zombie.name == turret.gun.badTarget)) {
            // On occasion, we miss a target.  This makes sure we don't constantly
            // keep trying to hit a target that we can't hit.
//             debugPrint("Skipping this zombie because we just failed to hit it.", "val");
            continue;
        } else if (zombie.origin[2] < -9300) {
            // bots are hidden at (0,0,-10000), so bail if bot is on it's way to limbo
            continue;
        } else {
            // Cyclops are priority targets!
            if (zombie.type == "cyclops") {
                if (turret isInView(zombie) != -1) {
                    turret.gun.targetPlayer = zombie;
                    endTime = getTime();
                    selectionTime = endTime - beginTime;
//                     debugPrint("Target selection took " + selectionTime + " ms.", "val");
                    return;
                } else {
                    // cyclops isn't in view, try next zombie
                    continue;
                }
            } else {
                // score this zombie as a potential target

                safeToEngageTarget = true;
                if ((zombie.type == "burning") ||
                    (zombie.type == "burning_dog") ||
                    (zombie.type == "toxic"))
                {
                    for (j=0; j<level.players.size; j++) {
                        if (!isDefined(players[j])) {continue;}
                        if ((!players[j].isDown) && (distance(zombie.origin, players[j].origin) < 220)) {
                            // We don't engage targets if we might hurt friendlies
                            safeToEngageTarget = false;
                            break;
                        }
                    }
                    if (!safeToEngageTarget) {
//                         debugPrint("It isn't safe to engage this zombie.", "val");
                        continue;
                    }
                }

                // We don't target zombies that aren't in range/view
                if (turret isInView(zombie) == -1) {continue;}

                // We compare the unit vector for the gun's primary vector with
                // the unit vector in the direction from the gun to the target.
                // Since both vectors are of unit length, the dot product is really
                // just a numerical representation of the angle between gun barrel primary vector
                // and the target, and the range is consequently a real number from [-1,1], where 1
                // means the target is directly in front of the gun's primary vector,
                // -1 means it is directly behind the gun, and zero, of course, means
                // the target is directly to the right or left of the gun barrel.
                //
                // Since we want the turrets to preferentially cover their assigned
                // field of fire, we prefer the target with the largest dot product.
                u_target = vectorNormalize((zombie.origin + (0,0,zombie.turretAimHeight)) - turret.gun.origin);
                dot = vectorDot(turret.gun.primaryUnitVector, u_target);

                if (dot > bestDot) {
                    // have a new best dot
                    bestDot = dot;
                    bestTarget = zombie;
                }
            } // end scoring else
        }
    } // end for

    if (isDefined(bestTarget)) {
        turret.gun.targetPlayer = bestTarget;
        endTime = getTime();
    } else {
        endTime = getTime();
//         debugPrint("No targets found.", "val");
    }
    selectionTime = endTime - beginTime;
//     debugPrint("Target selection took " + selectionTime + " ms.", "val");
}

/**
 * @brief Determines if a given target is in range and view of the turret
 *
 * @param target The zombie to evaluate
 *
 * @returns integer If the zombie is in range and in view, returns the distance
 * from the turret to the target, otherwise returns -1.
 */
isInView(target)
{
    // 21st most-called function (0.3% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    self endon("no_ammo");

    aimPoint = target.origin + (0,0,target.turretAimHeight);
    dist = distance(self.gun.origin, aimPoint);

    turretRange = 2160;
    if (dist < turretRange) {
        visibilityAmount = target SightConeTrace(self.gun.origin, self);
        if (visibilityAmount != 0) {return dist;}
        else {
            return -1;
        }
    }
    return -1;
}

/**
 * @brief Ensures a turret gets recycled if a player doesn't leave the game cleanly
 *
 * @param turret The turret to watch
 *
 * @returns nothing
 */
watchTurretOwnership(turret)
{
    debugPrint("in _turrets::watchTurretOwnership()", "fn", level.nonVerbose);

    // Sometimes players do not leave the game cleanly, so they may still own a
    // turret even after they left the game
    type = turret.gun.turretType;
    while (1) {
        wait 5;
        if (!isDefined(turret)) {
            errorPrint("Returning from watchTurretOwnership() because " + type + " turret doesn't exist!");
            return;
        }
        if ((turret.isDeployed) && (!isDefined(turret.gun.owner))) {
            /// @bug Fixed. Prevent a race condition--give players::cleanup()
            /// enough time to remove the turret before we suspect it failed
            wait 1;
            if ((turret.isDeployed) && (!isDefined(turret.gun.owner))) {
                debugPrint("From watchTurretOwnership(), trying to remove turret " + turret.id, "val");
                removeTurret(turret);
            }
        }
    }
}

/**
 * @brief Removes a turret from the map, and prepares it to be re-purchased
 *
 * @param turret The turret to remove
 *
 * @returns nothing
 */
removeTurret(turret)
{
    debugPrint("in _turrets::removeTurret()", "fn", level.nonVerbose);

    debugPrint("Removing turret " + turret.id, "val");

    if (turret.gun.turretType == "gl") {
        turret hide();
        turret.gun hide();

        // Re-link turret.gun and re-set angles to prepare turret for moving
        turret.gun linkto(turret);
        turret.gun.ammo = turret.gun.maxAmmo;
        if (isDefined(turret.gun.owner)) {
            turret.gun.owner scripts\players\_usables::removeUsable(turret);
            turret.gun.owner.ownsTurret = false;
            turret.gun.owner = undefined;
        }
        turret.origin = turret.spawnOrigin;
        turret.angles = turret.spawnAngles;
        wait 0.05;

        // rotate the gun back to its spawn position, then relink it
        turret.gun unlink();
        turret.gun.angles = turret.gun.spawnAngles;
        turret.gun rotateTo(turret.gun.angles, 0.01);
        wait 0.05;
        turret.gun linkto(turret);

        level.grenadeTurretCount--;
        turret.isBeingKilled = false;
        turret.isDeployed = false;
        debugPrint("level.grenadeTurretCount: " + level.grenadeTurretCount, "val");
    } else if (turret.gun.turretType == "minigun") {
        turret hide();
        turret.gun hide();
        turret.gunBarrel hide();

        // Re-link turrent.gun and re-set angles to prepare turret for moving
        turret.gun linkto(turret);
        turret.gun.ammo = turret.gun.maxAmmo;
        if (isDefined(turret.gun.owner)) {
            turret.gun.owner.ownsTurret = false;
            turret.gun.owner = undefined;
        }
        turret.origin = turret.spawnOrigin;
        turret.angles = turret.spawnAngles;
        wait 0.05;

        // rotate the gun back to its spawn position, then relink it
        turret.gun unlink();
        turret.gun.angles = turret.gun.spawnAngles;
        turret.gun rotateTo(turret.gun.angles, 0.01);
        wait 0.05;
        turret.gun linkto(turret);

        level.minigunTurretCount--;
        turret.isBeingKilled = false;
        turret.isDeployed = false;
        debugPrint("level.minigunTurretCount: " + level.minigunTurretCount, "val");
    }
}

/**
 * @brief Allows a turret to be picked up and moved
 *
 * @param turret The turret to move
 *
 * @returns nothing
 */
moveDefenseTurret(turret)
{
    debugPrint("in _turrets::moveDefenseTurret()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");

    if ((isDefined(turret.gun.owner)) && (turret.gun.owner == self)) {
        turret notify("turret_being_moved");
        turret.gun.owner scripts\players\_usables::removeUsable(turret);

        // Re-link turrent.gun and re-set angles to prepare turret for moving
        turret.isBeingMoved = true;
        turret.gun.angles = turret.gun.primaryAngles;
        turret.gun rotateTo(turret.gun.primaryAngles, 0.01);
        turret.gun linkto(turret);

        // Make the player carry the grenade turret
        self.carryObj = turret;
        self.carryObj.origin = self.origin + AnglesToForward(self.angles)*48;
        self.carryObj.angles = self.angles;
        self.carryObj.master = self;

        self.carryObj linkto(self);
        self.carryObj setcontents(2);

        self.canUse = false;
        self disableweapons();

        // Let the player place the grenade turret
        self thread emplaceDefenseTurret(turret);
    }
}


/**
 * @brief Calculates the absolute value
 *
 * @param number The number to find the absolute value for
 *
 * @returns the absolute value
 */
abs(number)
{
    debugPrint("in _turrets::abs()", "fn", level.fullVerbosity);

    if (number >= 0) {return number;}
    else {return number * -1;}
}


/**
 * @brief Computes the angle between two vectors
 *
 * @param a The first vector
 * @param b The second vector
 *
 * @returns The angle between the two vectors, in degrees
 */
angleBetweenTwoVectors(a, b)
{
    debugPrint("in _turrets::angleBetweenTwoVectors()", "fn", level.lowVerbosity);

    aDotB = vectorDot(a, b);
    magnitudeA = length(a);
    magnitudeB = length(b);

    argument = aDotB / (magnitudeA * magnitudeB);

    // Guard against floating point representation errors,
    // and maybe save a call to acos()
    if (argument >= 1) {theta = 0;}
    else if (argument <= -1) {theta = 180;}
    else {theta = acos(argument);}

    return theta;
}
