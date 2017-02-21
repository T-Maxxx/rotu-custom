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

#include scripts\include\hud;
#include scripts\include\utility;

init()
{
    debugPrint("in _abilities::init()", "fn", level.nonVerbose);

    precache();
    thread loadSpecialAbilitySettings();
}

precache()
{
    debugPrint("in _abilities::precache()", "fn", level.nonVerbose);

    level.heal_glow_body    = loadfx( "misc/heal_glow_body");
    level.heal_glow_effect  = loadfx( "misc/heal_glow");
    level.healingEffect     = loadfx( "misc/healing" );

    //precacheItem("helicopter_mp"); // This is the medkit

    precacheString(&"ROTUSCRIPT_CURED_BY");
    precacheString(&"ROTUSCRIPT_INVALID_WEAPON");
    precacheString(&"ROTUSCRIPT_MEDKIT_IN");
    precacheString(&"ROTUSCRIPT_AMMOBOX_IN");
}

/**
 * @brief Loads the recharge time and duration properties for special abilities
 *
 * @returns nothing
 */
loadSpecialAbilitySettings()
{
    debugPrint("in _abilities::loadSpecialAbilitySettings()", "fn", level.nonVerbose);

    // Stealth special
    level.special["fake_death"]["recharge_time"] = 40;

    // Soldier special
    level.special["rampage"]["recharge_time"] = 50;
    level.special["rampage"]["duration"] = 15;

    // Medic special
    level.special["aura"]["recharge_time"] = 60;
    level.special["aura"]["duration"] = 20;

    // Armored Special
    level.special["invincible"]["recharge_time"] = 60;
    level.special["invincible"]["duration"] = 20;

    // Scout special
    level.special["escape"]["recharge_time"] = 40;
    level.special["escape"]["duration"] = 10;

    // Engineer special
    level.special["ammo"]["recharge_time"] = 60;

    level.special_quickescape_duration = 6;
    level.special_quickescape_intermission = 15;
    level.special_stealthmove_intermission = 10;
}

/**
 * @brief Sets a players abilites to the default state, before any class or special abilities are loaded
 *
 * @returns nothing
 */
resetAbilities()
{
    debugPrint("in _abilities::resetAbilities()", "fn", level.nonVerbose);

    self notify("reset_abilities");
    self.stealthMp = 1;
    self.maxhealth = 100;
    self.speed = 1;
    self.revivetime = 5;

    self clearPerks();

    self.canAssasinate = false;
    self.isHitman = false;
    self.focus = -1;
    self.weaponMod = "";
    self.bulletMod = "";
    self.weaponNoiseMP = 1;
    self.immune = false;
    self.transfusion = false;
    self.canCure = false;
    self.hasMedicine = false;
    self.canSearchBodies = false;
    self.explosiveExpert = false;
    self.heavyArmor = false;
    self.specialtyReload = false;
    self.hasFastReload = false;
    self.hasLastManStanding = false;
    self.damageDoneMP = 1;
    self.infectionMP = 1;
    self.canZoom = true;
    self.headshotMP = 1;
    self.medkitTime = 12;
    self.medkitHealing = 25;
    self.auraHealing = 50;
    self.specialRecharge = 100.0;

    self.special["ability"] = "none";
    self.special["recharge_time"] = 60;
    self.special["duration"] = 10;

    self setclientdvar("ui_specialtext", "@ROTUUI_SPECIAL_LOCKED");
}


getDamageModifier(weapon, means, target, damage)
{
    debugPrint("in _abilities::getDamageModifier()", "fn", level.fullVerbosity);

    MP = 1;
    if (issubstr(self.weaponMod, "soldier")) {
        if (scripts\players\_weapons::isRifle(weapon)) {
            MP += .1;
        }
    }
    if (issubstr(self.weaponMod, "assasin")) {
        /** @bug We are getting two errors here on occasion
         *     'Weapon name "none" is not valid.'  and
         *     'cannot cast undefined to bool:'
         *
         * If weapon=="none", it isn't a valid weapon, we get first error
         * which makes weaponIsBoltActio(weapon) return undefined instead of boolean
         *
         * How can a player cause gamage to another if their weapon is "none"???
         */
        if (weapon == "none") {
//   3:10 Notice: Weapon equal 'none' error.
//   3:10 Notice: self.name: |PZA| Pulsar
//   3:10 Notice: self.weaponMod: assasinhitman means: MOD_EXPLOSIVE
// was exploding barrel

            noticePrint("Weapon equal 'none' error.");
            noticePrint("self.name: " + self.name);
            noticePrint("self.weaponMod: " + self.weaponMod + " means: " + means);
            return 1; // i.e. unity damage modifier
        }
        if (weapon == "turret_mp") { // hack for minigun turret
            return 1;
        }
        if (!WeaponIsBoltAction(weapon) && !WeaponIsSemiAuto(weapon)) {
            MP -= .15;
        } else {
            MP += .05;
        }
        if (!scripts\players\_weapons::isSilenced(weapon)) {
            MP -= .15;
        } else {
            MP += .05;
        }
        if (means == "MOD_MELEE") {
            MP += .3;
        }
    }
    if (issubstr(self.weaponMod, "hitman")) {
        if (!WeaponIsBoltAction(weapon) && !WeaponIsSemiAuto(weapon) && means == "MOD_HEAD_SHOT") {
            MP += .45;
        }
        if (!target scripts\bots\_bots::zomSpot(self)) {
            MP += .15;
        }
    }
    if (issubstr(self.weaponMod, "strength")) {
        if (means == "MOD_MELEE") {
            MP += .35;
        }
    }
    if (issubstr(self.weaponMod, "engineer")) {
        if (means == "MOD_EXPLOSIVE") {
            MP += .1;
        }
        if (scripts\players\_weapons::isLMG(weapon) ||
            scripts\players\_weapons::isRifle(weapon))
        {
            MP += .05;
        }
        if (scripts\players\_weapons::isShotgun(weapon) ) {
            MP += .1;
        }
    }
    if (issubstr(self.weaponMod, "armored")) {
        if (scripts\players\_weapons::isLMG(weapon)) {
            MP += .15;
        }
        if (scripts\players\_weapons::isSniper(weapon) ||
            scripts\players\_weapons::isPistol(weapon) ||
            scripts\players\_weapons::isSMG(weapon))
        {
            MP -= .15;
        }
    }
    if (issubstr(self.weaponMod, "scout")) {
        if (scripts\players\_weapons::isLMG(weapon) ||
            scripts\players\_weapons::isRifle(weapon))
        {
            MP -= .15;
        }
        if (scripts\players\_weapons::isSniper(weapon) ||
            scripts\players\_weapons::isPistol(weapon) ||
            scripts\players\_weapons::isSMG(weapon))
        {
            MP += .1;
        }
    }
    MP = MP * self.upgrade_damMod;
    return MP;
}


/**
 * @brief Is this ability allowed?
 *
 * @param class string The class of the player
 * @param rank integer The rank of the player
 * @param type string The type of the ability [PR|PS|SC] for (primary, passive, secondary)
 * @param ability string The ability slot. For primary [AB1|AB2|AB3].  For Passive
 * [AB1|AB2|AB3|AB4]. For secondary [AB1|AB2|AB3|AB4|AB5], though AB4 and AB5 are
 * not implemented for Secondary.
 *
 * @returns boolean Whether the ability is allowed or not
 */
isAbilityAllowed(class, rank, type, ability)
{
    debugPrint("in _abilities::isAbilityAllowed()", "fn", level.medVerbosity);

    if (type == "PR") { // Primary abilities
        if ((ability == "AB1") && (rank >= 5)) {return true;}
        else if ((ability == "AB2") && (rank >= 15)) {return true;}
        else if ((ability == "AB3") && (rank >= 25)) {return true;}
        return false; // fail early
    }
    if (type == "PS") { // Passive abilities
        if (ability == "AB1") {return true;}
        else if ((ability == "AB2") && (rank >= 10)) {return true;}
        else if ((ability == "AB3") && (rank >= 20)) {return true;}
        else if ((ability == "AB4") && (rank >= 30)) {return true;}
        return false; // fail early
    }
    if (type == "SC") { // Secondary abilities
        if ((ability == "AB1") && (rank >= 5)) {return true;}
        else if ((ability == "AB2") && (rank >= 10)) {return true;}
        else if ((ability == "AB3") && (rank >= 20)) {return true;}
        else if (ability == "AB4") {
            // Do nothing
        } else if (ability == "AB5") {
            // Do nothing
        }
    }
    return false;
}

/**
 * @brief Main logic for loading the class abilities
 *
 * @param class string the class to load the abilities for
 *
 * @returns nothing
 */
loadClassAbilities(class)
{
    debugPrint("in _abilities::loadClassAbilities()", "fn", level.nonVerbose);

    // Set default properties for all classes
    self resetAbilities();
    // Set default properties for this class
    self loadGeneralAbilities(class);
    rank = scripts\players\_classes::getClassRank(class) + 1;

    // Primary Abilities
    if (isAbilityAllowed(class, rank, "PR", "AB1")) {
        self loadAbility(class, "PR", "AB1");
    }
    if (isAbilityAllowed(class, rank, "PR", "AB2")) {
        self loadAbility(class, "PR", "AB2");
    }
    if (isAbilityAllowed(class, rank, "PR", "AB3")) {
        self loadAbility(class, "PR", "AB3");
    }

    // Passive Abilities
    if (isAbilityAllowed(class, rank, "PS", "AB1")) {
        self loadAbility(class, "PS", "AB1");
    }
    if (isAbilityAllowed(class, rank, "PS", "AB2")) {
        self loadAbility(class, "PS", "AB2");
    }
    if (isAbilityAllowed(class, rank, "PS", "AB3")) {
        self loadAbility(class, "PS", "AB3");
    }
    if (isAbilityAllowed(class, rank, "PS", "AB4")) {
        self loadAbility(class, "PS", "AB4");
    }

    // Secondary Ability
    if (isAbilityAllowed(class, rank, "SC", self.secondaryAbility)) {
        self loadAbility(class, "SC", self.secondaryAbility);
    }
}

/**
 * @brief Sets the abilities that do not depend on rank
 *
 * @param class string The class to set the default abilities for
 *
 * @returns nothing
 */
loadGeneralAbilities(class)
{
    debugPrint("in _abilities::loadGeneralAbilities()", "fn", level.nonVerbose);

    self setperk("specialty_pistoldeath");
    switch (class) {
        case "soldier":
            self.maxhealth = 120;
        break;
        case "stealth":
            self.maxhealth = 100;
            self setperk("specialty_quieter");
        break;
        case "medic":
            self.maxhealth = 100;
        break;
        case "scout":
            self.maxhealth = 80;
            self setperk("specialty_longersprint");
            self.speed = 1.05;
        break;
        case "amored":
            self.maxhealth = 140;
            self.speed = 0.9;
        break;
    }
}

/**
 * @brief Loads a special ability
 *
 * @param special string The name of the special ability
 *
 * @returns nothing
 */
loadSpecialAbility(special)
{
    debugPrint("in _abilities::loadSpecialAbility()", "fn", level.nonVerbose);

    self.special["ability"] = special;

    if (isdefined(level.special[special]["recharge_time"])) {
        self.special["recharge_time"] = level.special[special]["recharge_time"];
    }

    if (isdefined(level.special[special]["duration"])) {
        self.special["duration"] = level.special[special]["duration"];
    }

    self setclientdvar("ui_specialtext", "@ROTUUI_SPECIAL_AVAILABLE");
}

/**
 * @brief Calls class-specific loadAbility functions for Primary and Passive abilities
 *
 * @param class string The class of the player
 * @param type string The type of the ability [PR|PS|SC] for (primary, passive, secondary)
 * @param ability string The ability slot. For primary [AB1|AB2|AB3].  For Passive
 * [AB1|AB2|AB3|AB4].
 *
 * @returns nothing
 */
loadAbility(class, type, ability)
{
    debugPrint("in _abilities::loadAbility()", "fn", level.medVerbosity);

    switch (class) {
        case "soldier":
            if (type=="PR") {self thread loadSoldierPrimaryAbility(ability);}
            else if (type=="PS") {self thread loadSoldierPassiveAbility(ability);}
        break;
        case "stealth":
            if (type=="PR") {self thread loadStealthPrimaryAbility(ability);}
            else if (type=="PS") {self thread loadStealthPassiveAbility(ability);}
        break;
        case "medic":
            if (type=="PR") {self thread loadMedicPrimaryAbility(ability);}
            else if (type=="PS") {self thread loadMedicPassiveAbility(ability);}
        break;
        case "armored":
            if (type=="PR") {self thread loadArmoredPrimaryAbility(ability);}
            else if (type=="PS") {self thread loadArmoredPassiveAbility(ability);}
        break;
        case "engineer":
            if (type=="PR") {self thread loadEngineerPrimaryAbility(ability);}
            else if (type=="PS") {self thread loadEngineerPassiveAbility(ability);}
        break;
        case "scout":
            if (type=="PR") {self thread loadScoutPrimaryAbility(ability);}
            else if (type=="PS") {self thread loadScoutPassiveAbility(ability);}
        break;
    }
}

/**
 * @brief Loads the primary abilities for soldiers
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadSoldierPrimaryAbility(ability)
{
    debugPrint("in _abilities::loadSoldierPrimaryAbility()", "fn", level.nonVerbose);

    switch (ability) {
        case "AB1": // Rampage
            self loadSpecialAbility("rampage");
        break;
        case "AB2": // Focus
            self.focus = 1;
        break;
        case "AB3": // Last Man Standing
            self.hasLastManStanding = true;
        break;
    }
}

/**
 * @brief Loads the passive abilities for soldiers
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadSoldierPassiveAbility(ability)
{
    debugPrint("in _abilities::loadSoldierPassiveAbility()", "fn", level.nonVerbose);

    switch (ability) {
        case "AB1": // Rifle Expertise
            self.weaponMod += "soldier";
        break;
        case "AB2": // Gun Master
            self.hasFastReload = true;
            self SetPerk("specialty_fastreload");
        break;
        case "AB3": // Regeneration
            self thread regenerate(1, 1);
        break;
        case "AB4": // Immunity
            self.maxhealth += 5;
            self.immune = true;
            self.infectionMP = 0;
        break;
    }
}

/**
 * @brief Loads the primary abilities for stealth
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadStealthPrimaryAbility(ability)
{
    debugPrint("in _abilities::loadStealthPrimaryAbility()", "fn", level.nonVerbose);

    switch (ability) {
        case "AB1": // Assasination
            self.canAssasinate = true;
            //self giveweapon("knife_mp");
        break;
        case "AB2": // Fake Death
            self loadSpecialAbility("fake_death");
        break;
        case "AB3": // Quick Escape
            self thread quickEscape();
        break;
    }
}

/**
 * @brief Loads the passive abilities for stealth
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadStealthPassiveAbility(ability)
{
    debugPrint("in _abilities::loadStealthPassiveAbility()", "fn", level.nonVerbose);

    switch (ability) {
        case "AB1": // Way of the Assasin
            self.weaponMod += "assasin";
        break;
        case "AB2": // Silent Kill
            self.weaponNoiseMP = .75;
        break;
        case "AB3": // Hitman
            self.weaponMod += "hitman";
        break;
        case "AB4": // Shadow Refuge
            self thread stealthMovement();
        break;
    }
}

/**
 * @brief Loads the primary abilities for medics
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadMedicPrimaryAbility(ability)
{
    debugPrint("in _abilities::loadMedicPrimaryAbility()", "fn", level.lowVerbosity);

    switch (ability) {
        case "AB1": // Medkit
            self giveWeapon( "helicopter_mp" );
            self giveMaxAmmo( "helicopter_mp" );
            self setActionSlot( 4, "weapon", "helicopter_mp" );
            self.medkitTime = 12;
            self.medkitHealing = 25;
            self thread watchMedkits();
        break;
        case "AB2": // Healing Aura
            self loadSpecialAbility("aura");
        break;
        case "AB3": // Health Transfusion
            self.transfusion = true;
        break;
    }
}

/**
 * @brief Loads the passive abilities for medics
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadMedicPassiveAbility(ability)
{
    debugPrint("in _abilities::loadMedicPassiveAbility()", "fn", level.nonVerbose);

    switch (ability) {
        case "AB1": // Paramedic
            self.revivetime -= 1.5;
            self.canCure = true;
        break;
        case "AB2": // Field Operative
            self.speed += 0.05;
        break;
        case "AB3": // Medicine
            self.hasMedicine = true;
            self.medkitHealing = Int(self.medkitHealing * 1.1);
        break;
        case "AB4": // Poisionous Bullets
            self.bulletMod = "poison";
        break;
    }
}

/**
 * @brief Loads the primary abilities for armored
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadArmoredPrimaryAbility(ability)
{
    debugPrint("in _abilities::loadArmoredPrimaryAbility()", "fn", level.nonVerbose);

    switch (ability) {
        case "AB1": // Melee Warrior
            self giveWeapon( "m60e4_reflex_mp" );
            self giveMaxAmmo( "m60e4_reflex_mp" );
            self setActionSlot( 4, "weapon", "m60e4_reflex_mp" );
        break;
        case "AB2": // Invincibility
            self loadSpecialAbility("invincible");
        break;
        case "AB3": // Heavily Armored
            self.heavyArmor = true;
            //self giveweapon("knife_mp");
        break;
    }
}

/**
 * @brief Loads the passive abilities for armored
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadArmoredPassiveAbility(ability)
{
    debugPrint("in _abilities::loadArmoredPassiveAbility()", "fn", level.nonVerbose);

    switch (ability) {
        case "AB1": // Heavy Gunner
            self.weaponMod += "armored";
        break;
        case "AB2": // Extreme Strength
            self.weaponMod += "strength";
            self setperk("specialty_bulletaccuracy");
        break;
        case "AB3": // Machine Gunner
            self.weaponMod += "lmg";
            self.specialtyReload = true;
        break;
        case "AB4": // Resistant Skin
            self.damageDoneMP = .9;
            self.infectionMP = .65;
        break;
    }
}

/**
 * @brief Loads the primary abilities for engineers
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadEngineerPrimaryAbility(ability)
{
    debugPrint("in _abilities::loadEngineerPrimaryAbility()", "fn", level.nonVerbose);

    switch (ability) {
        case "AB1": // Ammo Box
            self giveWeapon( "m14_reflex_mp" );
            self giveMaxAmmo( "m14_reflex_mp" );
            self setActionSlot( 4, "weapon", "m14_reflex_mp" );
            self.ammoboxTime = 15;
            self.ammoboxRestoration = 25;
            self thread watchAmmobox();
            //self giveweapon("knife_mp");
        break;
        case "AB2": // Supplies
            self loadSpecialAbility("ammo");
        break;
        case "AB3": // Last Man Standing
            self.canSearchBodies = true; /// @todo not in UI.  unused?
            self.hasLastManStanding = true;
        break;
    }
}

/**
 * @brief Loads the passive abilities for engineers
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadEngineerPassiveAbility(ability)
{
    debugPrint("in _abilities::loadEngineerPassiveAbility()", "fn", level.nonVerbose);

    switch (ability) {
        case "AB1": // Engineering
            self.weaponMod += "engineer";
        break;
        case "AB2": // Explosive Expertise
            self.explosiveExpert = true;
        break;
        case "AB3": // Repair Tools
            /// @todo in UI, but not implemented
        break;
        case "AB4": // Incendiary Ammunition
            self.bulletMod = "incendary";
        break;
    }
}

/**
 * @brief Loads the primary abilities for scouts
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadScoutPrimaryAbility(ability)
{
    debugPrint("in _abilities::loadScoutPrimaryAbility()", "fn", level.lowVerbosity);

    switch (ability) {
        case "AB1": // Quick Escape
            self loadSpecialAbility("escape");
        break;
        case "AB2": // Scope Zoom
            self setperk("specialty_holdbreath");
            self.canZoom = true;
        break;
        case "AB3": // Last Man Standing
            self.hasLastManStanding = true;
        break;
    }
}

/**
 * @brief Loads the passive abilities for scouts
 *
 * @param ability string The ability to load
 *
 * @returns nothing
 */
loadScoutPassiveAbility(ability)
{
    debugPrint("in _abilities::loadScoutPassiveAbility()", "fn", level.lowVerbosity);

    switch (ability) {
        case "AB1": // Scouting
            self.weaponMod += "scout";
        break;
        case "AB2": // Head Hunter
            self.headshotMP = 1.5;
        break;
        case "AB3": // Hitman
            /// @todo in UI, but not implemented
        break;
        case "AB4": // Scouting Drone
            self setClientDvar("g_compassShowEnemies", 1);
        break;
    }
}

/**
 * @brief Recharges a player's special, and marks when it is available again
 *
 * @param delta integer The amount to recharge the special by
 *
 * @returns nothing
 */
rechargeSpecial(delta)
{
    debugPrint("in _abilities::rechargeSpecial()", "fn", level.medVerbosity);

    if(!isDefined(self)) {return;}

    // Bail if the special is already available
    if ((self.special["ability"] == "none") || (self.canUseSpecial)) {return;}

    // recharge special, ensuring it never exceeds 100%
    self.specialRecharge += delta;
    if (self.specialRecharge > 100.0) {self.specialRecharge = 100.0;}

    // The special is now available
    if (self.specialRecharge == 100.0) {
        self.canUseSpecial = true;
        self setclientdvars("ui_specialtext", "@ROTUUI_SPECIAL_AVAILABLE");
    }

    // Update the special recharge HUD bar graph. (Cast to float)
    self setclientdvar("ui_specialrecharge", self.specialRecharge/100.0);
}

/**
 * @brief Main logic for throwing and restoring medkits
 *
 * @returns nothing
 */
watchMedkits()
{
    debugPrint("in _abilities::watchMedkits()", "fn", level.lowVerbosity);

    self endon("reset_abilities");
    self endon("downed");
    self endon("death");
    self endon("disconnect");

    while (1) {
        self waittill ( "grenade_fire", kit, weaponName );
        if (weaponName == "helicopter_mp") {
            kit.master = self;
            kit thread beMedkit(self);
            kit thread kitFX();
            self thread restoreKit(60);
            //self thread watchMedkits();
        }
    }
}

/**
 * @brief Main logic for throwing and restoring ammo boxes
 *
 * @returns nothing
 */
watchAmmobox()
{
    debugPrint("in _abilities::watchAmmobox()", "fn", level.nonVerbose);

    self endon("reset_abilities");
    self endon("downed");
    self endon("death");
    self endon("disconnect");

    while (1) {
        self waittill ( "grenade_fire", kit, weaponName );
        if (weaponName == "m14_reflex_mp") {
            kit.master = self;
            kit thread beAmmobox(self.ammoboxTime);
            self thread restoreAmmobox(self.ammoBoxRestoreTime); // was hardcoded as 45 sec
        }
    }
}

/**
 * @brief Plays the medkit effect while the medkit exists
 *
 * @returns nothing
 */
kitFX()
{
    debugPrint("in _abilities::kitFX()", "fn", level.lowVerbosity);

    wait 1;
    if (isDefined(self)) {
        playfxontag(level.medkitFX, self, "tag_origin");
    }
}

/**
 * @brief Restores a medic's ability to re-throw the medkit after a recharge delay
 *
 * @param time integer The time, in seconds, for the medkit to recharge
 *
 * @returns nothing
 */
restoreKit(time)
{
    debugPrint("in _abilities::restoreKit()", "fn", level.lowVerbosity);

    self endon("reset_abilities");
    self endon("downed");
    self endon("death");
    self endon("disconnect");

    self addTimer(&"ROTUSCRIPT_MEDKIT_IN", "", time);
    wait time;
    self setWeaponAmmoClip("helicopter_mp", self getweaponammoclip("helicopter_mp") + 1);
}

/**
 * @brief Restores an engineer's ability to re-throw an ammo box after a recharge delay
 *
 * @param time integer The time, in seconds, for the ammo box to recharge
 *
 * @returns nothing
 */
restoreAmmobox(time)
{
    debugPrint("in _abilities::restoreAmmobox()", "fn", level.nonVerbose);

    self endon("reset_abilities");
    self endon("downed");
    self endon("death");
    self endon("disconnect");

    self addTimer(&"ROTUSCRIPT_AMMOBOX_IN", "", time);
    wait time;
    self setWeaponAmmoClip("m14_reflex_mp", self getweaponammoclip("m14_reflex_mp") + 1);
}

/**
 * @brief Main logic for an ammo box
 *
 * @param time integer The time, in seconds, for the ammo box to exist
 *
 * @returns nothing
 */
beAmmobox(time)
{
    debugPrint("in _abilities::beAmmobox()", "fn", level.nonVerbose);

    wait 2;
    for (i=0; i<time; i++) {
        for (j=0; j<level.players.size; j++) {
            player = level.players[j];
            if (!isDefined(player)) {continue;}
            if (i==0) {player.tntLocked = 0;}
            if (distance(self.origin, player.origin) < 120) {
                if (!player.isDown) {
                    weapon = player getcurrentweapon();
                    if ((weapon == "tnt_mp") && (player.tntLocked)) {
                        // do nothing - we don't want players to get too much free TNT
                    } else {
                        self.master thread restoreAmmoMagazine(player);
                        if (weapon == "tnt_mp") {player.tntLocked = 1;}
                    }
                }
            }
        }
        wait 1;
    }
    self delete();
}

/**
 * @brief Main logic for a medkit
 *
 * @param medic The medic (player) that threw the medkit
 *
 * @returns nothing
 */
beMedkit(medic)
{
    debugPrint("in _abilities::beMedkit()", "fn", level.lowVerbosity);

    time = medic.medkitTime;
    wait 2;
    for (i=0; i<time; i++) {
        if (!isDefined(medic)) {
            // remove medkits when a medic leaves the game
            self delete();
            return;
        }
        for (j=0; j<level.players.size; j++) {
            player = level.players[j];
            if (!isDefined(medic)) {
                // remove medkits when a medic leaves the game
                self delete();
                return;
            }
            if (!isDefined(player)) {continue;}
            if (!isDefined(self)) {return;}
            if (distance(self.origin, player.origin) < 120) {
                if (player.health < player.maxhealth && !player.isDown) {
                    self.master thread healPlayer(player, medic.medkitHealing);
                }
                // If medic has the Medicine passive ability, cure the player's infection
                if (!isDefined(player.infected)) {continue;}
                if ((medic.hasMedicine) && (player.infected) && (!player.isDown)) {
                    player thread medkitMedicine(medic);
                }
            }
        }
        wait 1;
    }
    self delete();
}

/**
 * @brief Medkit cures a player's infection if the medic has the Medicine passive ability
 *
 * @param medic The medic that threw the medkit
 *
 * @returns nothing
 */
medkitMedicine(medic)
{
    debugPrint("in _abilities::medkitMedicine()", "fn", level.lowVerbosity);

    iprintln(&"ROTUSCRIPT_CURED_BY", self.name, medic.name);
    self scripts\players\_infection::cureInfection();
    medic scripts\players\_players::incUpgradePoints(20*level.dvar["game_rewardscale"]);
}

/**
 * @brief Begins a Stealth Movement trance
 *
 * @returns nothing
 */
stealthMovement()
{
    debugPrint("in _abilities::stealthMovement()", "fn", level.nonVerbose);

    self endon("reset_abilities");
    self endon("downed");
    self endon("death");
    self endon("disconnect");

    while (1) {
        // Shadow Refuge
        stance = self getStance();
        if ((stance == "crouch") || (stance == "prone")) {
            self tranceStealthMovement();
            // Wait 10 seconds after a trance ends before the next one can begin
            wait level.special_stealthmove_intermission;
        }
        wait 0.5;
    }
}

/**
 * @brief Begin stealth movement
 *
 * @returns nothing
 */
tranceStealthMovement()
{
    debugPrint("in _abilities::tranceStealthMovement()", "fn", level.nonVerbose);

    // Do nothing while already in stealth mode
    while (self.inTrance) {
        wait .5;
    }

    self endon("end_trance");

    self.trance = "stealthmove";
    self.inTrance = true;
    self.visible = false;
    self playerFilmTweaks(1, 0, .75, ".25 1 .5",  ".25 1 .7", .20, 1.4, 1);

    self thread endTranceStealthMovement();
    self thread watchEndTranceStealthMovement();

    self waittill("end_trance");
}

/**
 * @brief Ends stealth movement when the "end_trance" signal is received
 *
 * @returns nothing
 */
endTranceStealthMovement()
{
    debugPrint("in _abilities::endTranceStealthMovement()", "fn", level.nonVerbose);

    self waittill("end_trance");

    if (!isDefined(self)) {return;}
    self.inTrance = false;
    self.trance = "";
    self playerFilmTweaksOff();
    self.visible = true;
}

/**
 * @brief Watches for events that will end the Stealth Movement trance
 *
 * @returns nothing
 */
watchEndTranceStealthMovement()
{
    debugPrint("in _abilities::watchEndTranceStealthMovement()", "fn", level.nonVerbose);

    self endon("end_trance");

    self thread watchUse();
    self thread watchKnife();
    self thread watchExplosives();
    self thread watchTurrets();

    while (1) {
        self waittill ("begin_firing");
        weaponName = self getCurrentWeapon();
        // We handle explosives emplacement/use in watchExplosives(), so ignore them here
        if ((weaponName == "claymore") || (weaponName == "claymore_mp") ||
            (weaponName == "c4") || (weaponName == "c4_mp"))
        {continue;}
        break;
    }
    self notify("end_trance");
}

/**
 * @brief Ends the trance when a explosives are detonated
 *
 * @returns nothing
 */
watchExplosives()
{
    debugPrint("in _abilities::watchExplosives()", "fn", level.nonVerbose);

    self endon("end_trance");

    // We don't end the trance on claymore emplacement or detonation, or on c4
    // emplacement
    while (1) {
        self waittill( "detonate" );
        weaponName = self getCurrentWeapon();
        // End the trance on c4 detonation
        if ((weaponName == "c4") || (weaponName == "c4_mp") || (weaponName == "tnt_mp")) {break;}
    }
    self notify("end_trance");
}


/**
 * @brief Ends the trance when a turret is fired
 *
 * @returns nothing
 */
watchTurrets()
{
    debugPrint("in _abilities::watchTurrets()", "fn", level.nonVerbose);

    self endon("end_trance");

    // We don't end the trance when a turret is manned, just when it is fired
    while (1) {
        self waittill("is_firing_turret");
        break;
    }
    self notify("end_trance");
}

/**
 * @brief Ends the trance when a zombie is knifed
 *
 * @returns nothing
 */
watchKnife()
{
    debugPrint("in _abilities::watchKnife()", "fn", level.nonVerbose);

    self endon("end_trance");

    // When a zombie is knifed, allow for a 7-second spree, then end the stealth
    // trance
    while (1) {
        self waittill ("damaged_bot", bot, sMeansOfDeath); // sMeansOfDeath == MOD_MELEE
        if (sMeansOfDeath == "MOD_MELEE") {break;}
    }
    wait 7;
    if ((self.inTrance) && (self.trance == "stealthmove")) {
        self notify("end_trance");
    }
}

/**
 * @brief Ends the trance when a usable is used, such as a weapon upgrade, shop purchase, or revive
 *
 * @returns nothing
 */
watchUse()
{
    debugPrint("in _abilities::watchUse()", "fn", level.nonVerbose);

    self endon("end_trance");

    // Ends the trance when a usable is used, i.e. weapon upgrade, shop purchase, revive
    self waittill("used_usable");
    self notify("end_trance");
}

/**
 * @brief Watches health and does a quick escape when it is less than 25%
 *
 * @returns nothing
 */
quickEscape()
{
    debugPrint("in _abilities::quickEscape()", "fn", level.nonVerbose);

    self endon("reset_abilities");
    self endon("death");
    self endon("disconnect");
    self endon("downed");

    while (1) {
        self waittill("damage", idamage);
        if (idamage != 0) {
            if (self.health <= self.maxhealth / 4){
                self tranceQuickEscape();
                wait level.special_quickescape_intermission;
            }
        }
    }
}

/**
 * @brief Make a player faster, and not visible to zombies for a small time
 *
 * @returns nothing
 */
tranceQuickEscape()
{
    debugPrint("in _abilities::tranceQuickEscape()", "fn", level.nonVerbose);

    // Override any existing trance
    if (self.inTrance) {
        self notify("end_trance");
    }

    self endon("end_trance");

    self.trance = "quick_escape";
    self.inTrance = true;

    self SetMoveSpeedScale(self.speed+.2);
    self.visible = false;
    self playerFilmTweaks(1, 0, .75, ".25 1 .5",  ".25 1 .7", .20, 1.4, 1.25);

    self thread endTranceQuickEscape();

    wait level.special_quickescape_duration;

    self notify("end_trance");
}

/**
 * @brief Ends the quick escape trance
 *
 * @returns nothing
 */
endTranceQuickEscape()
{
    debugPrint("in _abilities::endTranceQuickEscape()", "fn", level.nonVerbose);

    self waittill("end_trance");
    self endon("disconnect");

    if (isDefined(self)) {
        self.inTrance = false;
        self.trance = "";
        self playerFilmTweaksOff();
        self.visible = true;
        self SetMoveSpeedScale(self.speed);
    }
}

/**
 * @brief Regenerates a player's health
 *
 * @param health integer The amount to increase the health by each \c interval
 * @param interval integer The time in seconds to wait between each increase in health
 * @param limit integer If defined, how many times to increase the players health
 *
 * @returns nothing
 */
regenerate(health, interval, limit)
{
    debugPrint("in _abilities::regenerate()", "fn", level.nonVerbose);

    self endon("reset_abilities");
    self endon("death");
    self endon("disconnect");
    self endon("downed");

    if (!isdefined(limit)) {
        while (1) {
            if (self.health < self.maxhealth) {
                self heal(health);
            }
            wait interval;
        }
    } else {
        for (i=0; i<limit; i++) {
            if (self.health < self.maxhealth) {
                self heal(health);
            }
            wait interval;
        }
    }
}

/**
 * @brief Increase a player's health
 *
 * @param amount integer The amount to increase the player's health by
 *
 * @returns nothing
 */
heal(amount)
{
    debugPrint("in _abilities::heal()", "fn", level.absurdVerbosity);

    self.health += amount;
    if (self.health > self.maxhealth) {self.health = self.maxhealth;}

    self updateHealthHud(self.health/self.maxhealth);
}

/**
 * @brief Watches for an 'F' key press
 *
 * @returns nothing
 */
watchSpecialAbility()
{
    debugPrint("in _abilities::watchSpecialAbility()", "fn", level.nonVerbose);

    self endon("disconnect");
    self endon("killed_player");
    self endon("spawned");      // end this instance before a respawn

    wait 1;

    // Bail if the player doesn't have a special ability
    if (!isdefined(self.special["ability"]) || self.special["ability"] == "none") {
        return;
    }

    hasPressedF = false;
    while (1) {
        // Can't use special when down, so don't monitor the 'F' key as frequently
        if (self.isDown) {
            wait 1;
            continue;
        }

        if (self useButtonPressed()) {
            if (!hasPressedF) {
                // set flag, then check for double tap
                hasPressedF = true;
                checkForDoubleTapF();
            }
        } else {
            // reset flag to false
            if (hasPressedF) {hasPressedF = false;}
        }
        wait .05;
    }
}

/**
 * @brief Runs the special when a second 'F' key press is detected
 *
 * @returns nothing
 */
checkForDoubleTapF()
{
    debugPrint("in _abilities::checkForDoubleTapF()", "fn", level.medVerbosity);

    self endon("disconnect");
    self endon("killed_player");

    i = 0;
    hasPressedF = true;

    while (i <= 10) {
        if (self useButtonPressed()) {
            if (!hasPressedF) {
                // double tap detected, so do special ability
                //wait .1; Why wait here?
                self thread onSpecialAbility();
                break;
            }
        } else {
            if (hasPressedF) {hasPressedF = false;}
        }
        i++;
        wait .05;
    }
}

/**
 * @brief When a player double-taps F, runs the proper special
 *
 * @returns nothing
 */
onSpecialAbility()
{
    debugPrint("in _abilities::onSpecialAbility()", "fn", level.nonVerbose);

    self endon("disconnect");

    // Bail if the special isn't available
    if (!self.canUseSpecial) {return;}

    self notify("special_ability");

    self.canUseSpecial = false; // Make spamming "F" do nothing.
    
    if (self.special["ability"] != "ammo")
        self thread decreaseSpecialAbilityOnUsage(self.special["duration"]);

    isSpecialActivated = true;
    switch (self.special["ability"]) {
        case "aura": // Medic
            self thread healingAura(self.special["duration"]);
        break;
        case "rampage": // Soldier
            self doRampage(self.special["duration"]);
        break;
        case "invincible": // Armored
            self doInvincible(self.special["duration"]);
        break;
        case "ammo": // aka supplies. Engineer
            if (!self doAmmoSpecial()) { isSpecialActivated = false; }
        break;
        case "escape": // Scout
            self doEscape(self.special["duration"]);
        break;
        case "fake_death":
            self doFakeDeath(self.special["duration"]);
        break;
    }
    if (isSpecialActivated)
        self resetSpecial();
}

/**
 * @brief Slowly decrease special value during action.
 *
 * @returns nothing
 */
decreaseSpecialAbilityOnUsage(time)
{
    debugPrint("in _abilities::decreaseSpecialAbilityOnUsage()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");

    // 5 times per second is enough?
    // 1 second == 5 iterations == 20 pts per iteration.
    // 2 seconds == 10 iterations == 10 pts per iteration.
    dec = 100 * 0.2 / time;
    for (i = 0.0; i < time; i += 0.2)
    {
        self.specialRecharge -= dec;
        if (self.specialRecharge < 0.0)
        {
            self.specialRecharge = 0.0;
            self setClientDvar("ui_specialrecharge", 0.0);
            break;
        }
            
        self setClientDvar("ui_specialrecharge", self.specialRecharge / 100.0);
        wait 0.2;
    }
}

/**
 * @brief Sets a special as used
 *
 * @returns nothing
 */
resetSpecial()
{
    debugPrint("in _abilities::resetSpecial()", "fn", level.nonVerbose);

    self endon("disconnect");

    self.canUseSpecial = false;
    self.specialRecharge = 0.0;
    self setclientdvars("ui_specialtext", "@ROTUUI_SPECIAL_RECHARGING", "ui_specialrecharge", 0);
}

/**
 * @brief Implementation of the Healing Aura Special
 *
 * @param time integer The time in seconds that the Healing Aura will last
 *
 * @returns nothing
 */
healingAura(time)
{
    debugPrint("in _abilities::healingAura()", "fn", level.lowVerbosity);

    self endon("disconnect");
    self endon("killed_player");

    origin = self.origin;
    trace = bulletTrace(self.origin + (0,0,50), self.origin + (0,0,-200), false, self);

    if(trace["fraction"] < 1 ) {
        origin = trace["position"];
    }

    healObject = spawnHealFX(origin, level.healingEffect);
    healObject.healing = self.auraHealing;
    healObject.master = self;
    healObject thread beHealingAura(time);
}

/**
 * @brief Spawns a healing effect
 *
 * @param groundPoint vector The location to spawn the effect at
 * @param fx entity The effect to spawn
 *
 * @returns the effect
 */
spawnHealFX(groundPoint, fx)
{
    debugPrint("in _abilities::spawnHealFX()", "fn", level.nonVerbose);

    effect = spawnFx(fx, groundPoint, (0,0,1), (1,0,0));
    triggerFx(effect);

    return effect;
}

/**
 * @brief Main logic for player healing for the Healing Aura
 *
 * @param time integer Time, in seconds, the healing aura should last
 *
 * @returns nothing
 */
beHealingAura(time)
{
    debugPrint("in _abilities::beHealingAura()", "fn", level.nonVerbose);

    wait 2;
    timePassed = 0;
    while (timePassed < time) {
        for (i=0; i<=level.players.size; i++) {
            player = level.players[i];
            if (isdefined(player)) {
                if (player.isAlive) {
                    if (distance(self.origin, player.origin) <= 240) {
                        if (player.health < player.maxhealth) {
                            self thread doHealingAura(player);
                        }
                    }
                }
            }
        }
        timePassed += 2;
        wait 2;
    }
    self delete();
}

/**
 * @brief Launches the glow ball, then waits until it catches the player
 *
 * @param player The player to chase
 *
 * @returns nothing
 */
doHealingAura(player)
{
    debugPrint("in _abilities::doHealingAura()", "fn", level.nonVerbose);

    master = self.master;

    // Chase the player with a glowball
    self thread glowBall(player);
    player waittill("glow_ball_reached");

    if (!isDefined(self)) {return;}
    // Heal the player when the glow ball catches them
    if (isDefined(self.healing)){
        debugPrint("self.healing: " + self.healing, "val");
    } else {
        debugPrint("self.healing is undefined; should be 50. Hacking around bug.", "val");
        self.healing = 50;
    }
    master thread healPlayer(player, self.healing);
}

/**
 * @brief Spawns a healing glowing ball that chases the player
 *
 * @param player The player to chase, then heal
 *
 * @returns nothing
 */
glowBall(player)
{
    debugPrint("in _abilities::glowBall()", "fn", level.nonVerbose);

    // Spawn a moving glow ball
    offset = (0,0,40);
    glowBall = spawn("script_model", self.origin + offset);
    glowBall setModel("tag_origin");

    while(1) {
        wait 0.05;
        locationOfPlayerHead = player getTagOrigin("j_head");
        separation = distance(glowBall.origin, locationOfPlayerHead);

        if(separation > 30) {
            // Glow ball is chasing the player

            // Set speed and pulsations for when glow ball is far from player
            translationSpeed = 1.1;
            numberOfPulsations = 10;

            // Set speed and pulsations for when glow ball is close to player
            if (separation < 64) {
                translationSpeed = 0.55;
                numberOfPulsations = 5;
            }

            // Move ball towards the player's head
            glowBall moveTo(locationOfPlayerHead, translationSpeed);

            // Play the glow ball pulsation effects
            for(pulsationCount = 0; pulsationCount < numberOfPulsations; pulsationCount++) {
                playFXOnTag(level.heal_glow_effect, glowBall, "tag_origin");
                wait 0.1;
            }
        } else {
            // Glow ball has caught the player
            player thread playGlowBallHeadEffect();
            player notify("glow_ball_reached");
            glowBall delete();
            break;
        }
    }
}

/**
 * @brief Plays an effect when a glow ball reaches a player's head
 *
 * @returns nothing
 */
playGlowBallHeadEffect()
{
    debugPrint("in _abilities::playGlowBallHeadEffect()", "fn", level.nonVerbose);

    tag = "j_head";
    playFXOnTag(level.heal_glow_body, self, tag);
}

/**
 * @brief Gives a player some health
 *
 * @param player The player to heal
 * @param amount The amount to heal the player by
 *
 * @returns The actual amount the player was healed by
 */
healPlayer(player, amount)
{
    debugPrint("in _abilities::healPlayer()", "fn", level.nonVerbose);

    if (player.health == player.maxhealth) {return 0;}

    player.health += amount;
    actualHealedAmount = amount;
    // We can't actually heal them more than their maxHealth
    if (player.health > player.maxhealth) {
        actualHealedAmount -= player.health - player.maxhealth;
        player.health = player.maxhealth;
    }
    player thread screenFlash((0,.65,0), .5, .6);
    player updateHealthHud(player.health/player.maxhealth);

    if (player != self) {
        // Give medic upgrade points for healing another player
        reward = rewardForHealing(actualHealedAmount) * level.dvar["game_rewardscale"];
        self scripts\players\_players::incUpgradePoints(reward);
    }
    if (self.curClass=="medic") {
        // Recharge medic's special for healing others
        self scripts\players\_abilities::rechargeSpecial(actualHealedAmount / 4);
    }
    return actualHealedAmount;
}

/**
 * @brief Calculate the reward for healing a player
 *
 * @param amount integer The amount of healing done to the player
 *
 * @returns integer The reward for healing the player
 */
rewardForHealing(amount)
{
    debugPrint("in _abilities::rewardForHealing()", "fn", level.lowVerbosity);

    if (amount > 0) {return int((amount+10)/10);}
    else {return 0;}
}

/**
 * @brief Restores a magazine of ammunition to a player
 *
 * @param player The player to give the magazine to
 *
 * @returns nothing
 */
restoreAmmoMagazine(player)
{
    debugPrint("in _abilities::restoreAmmoMagazine()", "fn", level.lowVerbosity);

    weapon = player getcurrentweapon();

    // Bail if restoring ammo for this weapon is prohibited
    if (!scripts\players\_weapons::canRestoreAmmoByAmmoBoxes(weapon)) {return;}

    stockAmmo = player GetWeaponAmmoStock(weapon);
    stockMax = WeaponMaxAmmo(weapon);

    // Don't let players exceed max amount of explosives
    switch (weapon) {
        case "claymore_mp":
            if ((isDefined(player.emplacedClaymores)) &&
                (player.emplacedClaymores.size + stockAmmo >= level.maxClaymoresPerPlayer))
            {
                return;
            }
            break;
        case "c4_mp":
            if ((isDefined(player.emplacedC4)) &&
                (player.emplacedC4.size + stockAmmo >= level.maxC4PerPlayer))
            {
                return;
            }
            break;
        case "tnt_mp":
            if ((isDefined(player.emplacedTnt)) &&
                (player.emplacedTnt.size + stockAmmo >= level.maxTntPerPlayer))
            {
                return;
            }
            break;
    }

    // Rather than use each weapon's actual magazine capacity, we just define
    // it to be 10% of the weapon's maximum ammunition supply
    magazineCapacity = int(stockMax/10);

    // If it is a special weapon, give even less ammo per magazine
    if (scripts\players\_weapons::isSpecialWeap(weapon)) {
        magazineCapacity = int(0.016667 * stockMax);
    }
    // Engineers get 25% as much ammo from ammo boxes as other players
    if (player.curClass == "engineer") {magazineCapacity = int(0.25 * magazineCapacity);}
    if (magazineCapacity < 1) {magazineCapacity = 1;}

    magazineFullnessPercentage = (stockMax - stockAmmo) / magazineCapacity;
    if (magazineFullnessPercentage > 1) {
        // We are giving the player a full magazine
        magazineFullnessPercentage = 1;
    }

    if (stockAmmo < stockMax) {
        stockAmmo += magazineCapacity;
        // Don't give the player more ammo than their maximum ammo supply
        if (stockAmmo > stockMax) {
            stockAmmo = stockMax;
        }

        player setWeaponAmmoStock(weapon, stockAmmo);
        player thread screenFlash((0,0,0.65), .5, .6);
        player playlocalsound("weap_pickup");

        if (player != self) {
            // When an engineer gives ammo to other players, reward them with upgrade points
            reward = int(4 * magazineFullnessPercentage) * level.dvar["game_rewardscale"];
            self scripts\players\_players::incUpgradePoints(reward);
        }
        if ((isDefined(self)) && (self.curClass == "engineer")) {
            // Initialize self.ammoSupplyRatio to 2.5
            if (!isDefined(self.magazinesGiven)) {self.magazinesGiven = 20;}
            if (!isDefined(self.magazinesTaken)) {self.magazinesTaken = 8;}
            if (player != self) {
                if (player.curClass == "engineer") {
                    // When an engineer gives ammo to other engineers, recharge their special
                    // by 2% for each full magazine given
                    self scripts\players\_abilities::rechargeSpecial(2 * magazineFullnessPercentage);
                } else {
                    // When an engineer gives ammo to other players, recharge their special
                    // by 6% for each full magazine given
                    self scripts\players\_abilities::rechargeSpecial(6 * magazineFullnessPercentage);
                }

                self.magazinesGiven++;
            } else {
                if (level.activePlayers == 1) {
                    // When an engineer gives ammo to themselves, and they are the only active player,
                    // recharge their special by 3% for each full magazine given
                    self scripts\players\_abilities::rechargeSpecial(3 * magazineFullnessPercentage);
                    // If they are the only player, pretend they gave two magazines
                    // to other players so they still get a reasonable ammo box restore time
                    self.magazinesGiven = self.magazinesGiven + 2;
                }
                // track magazines given to themselves
                self.magazinesTaken++;
            }
            // Adjust the engineer's ammo box restore time depending on how good they
            // are at giving ammo to teammates
            if (self.magazinesTaken == 0) {self.ammoSupplyRatio = 0;} // divide by zero guard
            else {
                self.ammoSupplyRatio = self.magazinesGiven / self.magazinesTaken;
            }
            if (self.ammoSupplyRatio >= 3) {self.ammoBoxRestoreTime = 30;}
            else if ((self.ammoSupplyRatio >= 2) && (self.ammoSupplyRatio < 3)) {self.ammoBoxRestoreTime = 50;}
            else if ((self.ammoSupplyRatio >= 1) && (self.ammoSupplyRatio < 2)) {self.ammoBoxRestoreTime = 70;}
            else if ((self.ammoSupplyRatio >= 0.5) && (self.ammoSupplyRatio < 1)) {self.ammoBoxRestoreTime = 90;}
            else {self.ammoBoxRestoreTime = 110;}
        }
    }
}


/**
 * @brief Implementation of the Rampage Special
 *
 * @param time integer The time in seconds that the player will be rampaging
 *
 * @returns nothing
 */
doRampage(time)
{
    debugPrint("in _abilities::doRampage()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");

    self setclientdvar("ui_specialtext", "@ROTUUI_SPECIAL_ACTIVATED");
    self setPerk("specialty_rof");
    self setPerk("specialty_fastreload");
    self playLocalSound("zom_heartbeat");
    self thread screenFlash((.65, .1, .1), .5, .6);
    self playerFilmTweaks(1, 0, .8, "0.9 0.4 0.3",  "1 0.5 0.5", .25, 1.4, 1.2);
    self thread regenerate(2, time/40, 40);

    wait time;
    self playerFilmTweaksOff();
    self stopLocalSound("zom_heartbeat");
    self thread screenFlash((.65, .1, .1), .5, .6);

    self unSetPerk("specialty_rof");
    if (!self.hasFastReload) {
        self unSetPerk("specialty_fastreload");
    }
}

/**
 * @brief Implementation of the Fake Death Special
 *
 * @param time integer The time in seconds that the player will be faking death
 *
 * @returns nothing
 */
doFakeDeath(time)
{
    debugPrint("in _abilities::doFakeDeath()", "fn", level.nonVerbose);

    self endon("disconnect");

    // Override any existing trance
    if (self.inTrance) {
        self notify("end_trance");
    }
    wait 0.1;

    self endon("end_trance");

    self.trance = "fake_death";
    self.inTrance = true;
    self.visible = false;
    self.isTargetable = false;
    self.isGod = true;
    self.god = true;
    debugPrint("Fake Death set.", "val");

    self setclientdvar("ui_specialtext", "@ROTUUI_SPECIAL_ACTIVATED");
    self thread screenFlash((.65, .1, .1), .5, .6);
    self playerFilmTweaks(1, 0, .75, ".25 1 .5",  ".25 1 .7", .20, 1.4, 1.25);

    wait time;

    self.visible = true;
    self.isTargetable = true;
    self.isGod = false;
    self.god = false;
    self.inTrance = false;
    self.trance = "";

    self playerFilmTweaksOff();
    self thread screenFlash((.65, .1, .1), .5, .6);
    debugPrint("Fake Death unset.", "val");
    self notify("end_trance");
}

/**
 * @brief Implementation of the Invincibility Special
 *
 * @param time integer The time in seconds that the player will be invincible
 *
 * @returns nothing
 */
doInvincible(time)
{
    debugPrint("in _abilities::doInvincible()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");

    self setclientdvar("ui_specialtext", "@ROTUUI_SPECIAL_ACTIVATED");
    self.canUseSpecial = false;
    self.god = true;
    self thread screenFlash((.1, .1, .65), .5, .6);
    self playerFilmTweaks(1, 0, .4, "0.4 0.4 0.8",  "0.5 0.5 1", .25, 1.4, 1);

    wait time;

    self.god = false;
    self playerFilmTweaksOff();
    self thread screenFlash((.1, .1, .65), .5, .6);
}

/**
 * @brief Implementation of the Ammo Special
 *
 * @returns 1 if player's current weapon is their primary or secondary weapon, 0 otherwise
 */
doAmmoSpecial()
{
    debugPrint("in _abilities::doAmmoSpecial()", "fn", level.nonVerbose);

    weapon = self GetCurrentWeapon();
    if ((weapon == self.primary) || (weapon == self.secondary)) {
        self playlocalsound("weap_pickup");
        self GiveMaxAmmo(self.primary);
        self GiveMaxAmmo(self.secondary);
        return 1;
    }
    self iprintln(&"ROTUSCRIPT_INVALID_WEAPON");
    return 0;
}

/**
 * @brief Implementation of the Escape Special
 *
 * @param time integer The length of time, in seconds, for the special to last
 *
 * @returns nothing
 */
doEscape(time)
{
    debugPrint("in _abilities::doEscape()", "fn", level.lowVerbosity);

    // Override any existing trance
    if (self.inTrance) {
        self notify("end_trance");
    }

    self endon("end_trance");

    self.canUseSpecial = false;
    self.trance = "quick_escape";
    self.inTrance = true;

    self SetMoveSpeedScale(self.speed+.25);
    self.visible = true;
    self playerFilmTweaks(1, 0, .75, ".25 .5 1",  ".25 .7 1", .20, 1.4, 1.25);

    self thread endTranceQuickEscape();

    wait time;

    self notify("end_trance");
}
