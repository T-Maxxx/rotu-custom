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

#include scripts\include\utility;

init()
{
    debugPrint("in _upgradables::init()", "fn", level.nonVerbose);

    precache();
    // Set default primary and secondary weapons for the classes if none were set
    // in the config files

    if (getdvar("surv_unlock_cost_factor") == "")
    setdvar("surv_unlock_cost_factor", 10);

    // Soldier primary weapons
    if (getdvar("surv_soldier_unlockprimary0") == "") {
        setdvar("surv_soldier_unlockprimary0", "m16_mp");
    }
    if (getdvar("surv_soldier_unlockprimary1") == "") {
        setdvar("surv_soldier_unlockprimary1", "ak47_mp");
    }
    if (getdvar("surv_soldier_unlockprimary2") == "") {
        setdvar("surv_soldier_unlockprimary2", "g3_mp");
    }
    if (getdvar("surv_soldier_unlockprimary3") == "") {
        setdvar("surv_soldier_unlockprimary3", "m14_acog_mp");
    }
    if (getdvar("surv_soldier_unlockprimary4") == "") {
        setdvar("surv_soldier_unlockprimary4", "m4_acog_mp");
    }

    // Soldier secondary weapons
    if (getdvar("surv_soldier_unlocksecondary0") == "") {
        setdvar("surv_soldier_unlocksecondary0", "beretta_mp");
    }
    if (getdvar("surv_soldier_unlocksecondary1") == "") {
        setdvar("surv_soldier_unlocksecondary1", "usp_mp");
    }
    if (getdvar("surv_soldier_unlocksecondary2") == "") {
        setdvar("surv_soldier_unlocksecondary2", "colt45_mp");
    }
    if (getdvar("surv_soldier_unlocksecondary3") == "") {
        setdvar("surv_soldier_unlocksecondary3", "g36c_gl_mp");
    }

    // Assasin primary wepaons
    if (getdvar("surv_stealth_unlockprimary0") == "") {
        setdvar("surv_stealth_unlockprimary0", "skorpion_silencer_mp");
    }
    if (getdvar("surv_stealth_unlockprimary1") == "") {
        setdvar("surv_stealth_unlockprimary1", "mp5_silencer_mp");
    }
    if (getdvar("surv_stealth_unlockprimary2") == "") {
        setdvar("surv_stealth_unlockprimary2", "ak74u_silencer_mp");
    }
    if (getdvar("surv_stealth_unlockprimary3") == "") {
        setdvar("surv_stealth_unlockprimary3", "p90_silencer_mp");
    }
    if (getdvar("surv_stealth_unlockprimary4") == "") {
        setdvar("surv_stealth_unlockprimary4", "m21_acog_mp");
    }

    // Assasin secondary weapons
    if (getdvar("surv_stealth_unlocksecondary0") == "") {
        setdvar("surv_stealth_unlocksecondary0", "beretta_silencer_mp");
    }
    if (getdvar("surv_stealth_unlocksecondary1") == "") {
        setdvar("surv_stealth_unlocksecondary1", "usp_silencer_mp");
    }
    if (getdvar("surv_stealth_unlocksecondary2") == "") {
        setdvar("surv_stealth_unlocksecondary2", "colt45_silencer_mp");
    }
    if (getdvar("surv_stealth_unlocksecondary3") == "") {
        setdvar("surv_stealth_unlocksecondary3", "mp5_acog_mp");
    }

    // Armored primary weapons
    if (getdvar("surv_armored_unlockprimary0") == "") {
        setdvar("surv_armored_unlockprimary0", "g36c_acog_mp");
    }
    if (getdvar("surv_armored_unlockprimary1") == "") {
        setdvar("surv_armored_unlockprimary1", "rpd_mp");
    }
    if (getdvar("surv_armored_unlockprimary2") == "") {
        setdvar("surv_armored_unlockprimary2", "m60e4_grip_mp");
    }
    if (getdvar("surv_armored_unlockprimary3") == "") {
        setdvar("surv_armored_unlockprimary3", "saw_reflex_mp");
    }
    if (getdvar("surv_armored_unlockprimary4") == "") {
        setdvar("surv_armored_unlockprimary4", "rpd_acog_mp");
    }

    // Armored secondary weapons
    if (getdvar("surv_armored_unlocksecondary0") == "") {
        setdvar("surv_armored_unlocksecondary0", "beretta_mp");
    }
    if (getdvar("surv_armored_unlocksecondary1") == "") {
        setdvar("surv_armored_unlocksecondary1", "usp_mp");
    }
    if (getdvar("surv_armored_unlocksecondary2") == "") {
        setdvar("surv_armored_unlocksecondary2", "colt45_mp");
    }
    if (getdvar("surv_armored_unlocksecondary3") == "") {
        setdvar("surv_armored_unlocksecondary3", "winchester1200_mp");
    }

    // Engineer primary weapons
    if (getdvar("surv_engineer_unlockprimary0") == "") {
        setdvar("surv_engineer_unlockprimary0", "mp44_mp");
    }
    if (getdvar("surv_engineer_unlockprimary1") == "") {
        setdvar("surv_engineer_unlockprimary1", "winchester1200_grip_mp");
    }
    if (getdvar("surv_engineer_unlockprimary2") == "") {
        setdvar("surv_engineer_unlockprimary2", "m1014_grip_mp");
    }
    if (getdvar("surv_engineer_unlockprimary3") == "") {
        setdvar("surv_engineer_unlockprimary3", "m1014_reflex_mp");
    }
    if (getdvar("surv_engineer_unlockprimary4") == "") {
        setdvar("surv_engineer_unlockprimary4", "m60e4_acog_mp");
    }

    // Engineer secondary weapons
    if (getdvar("surv_engineer_unlocksecondary0") == "") {
        setdvar("surv_engineer_unlocksecondary0", "claymore_mp");
    }
    if (getdvar("surv_engineer_unlocksecondary1") == "") {
        setdvar("surv_engineer_unlocksecondary1", "c4_mp");
    }
    if (getdvar("surv_engineer_unlocksecondary2") == "") {
        setdvar("surv_engineer_unlocksecondary2", "rpg_mp");
    }
    if (getdvar("surv_engineer_unlocksecondary3") == "") {
        setdvar("surv_engineer_unlocksecondary3", "at4_mp");
    }

    // Scout primary weapons
    if (getdvar("surv_scout_unlockprimary0") == "") {
        setdvar("surv_scout_unlockprimary0", "m40a3_mp");
    }
    if (getdvar("surv_scout_unlockprimary1") == "") {
        setdvar("surv_scout_unlockprimary1", "dragunov_mp");
    }
    if (getdvar("surv_scout_unlockprimary2") == "") {
        setdvar("surv_scout_unlockprimary2", "remington700_mp");
    }
    if (getdvar("surv_scout_unlockprimary3") == "") {
        setdvar("surv_scout_unlockprimary3", "barrett_mp");
    }
    if (getdvar("surv_scout_unlockprimary4") == "") {
        setdvar("surv_scout_unlockprimary4", "deserteagle_mp");
    }

    // Scout secondary weapons
    if (getdvar("surv_scout_unlocksecondary0") == "") {
        setdvar("surv_scout_unlocksecondary0", "beretta_mp");
    }
    if (getdvar("surv_scout_unlocksecondary1") == "") {
        setdvar("surv_scout_unlocksecondary1", "usp_mp");
    }
    if (getdvar("surv_scout_unlocksecondary2") == "") {
        setdvar("surv_scout_unlocksecondary2", "colt45_mp");
    }
    if (getdvar("surv_scout_unlocksecondary3") == "") {
        setdvar("surv_scout_unlocksecondary3", "mp5_acog_mp");
    }

    // Medic primary weapons
    if (getdvar("surv_medic_unlockprimary0") == "") {
        setdvar("surv_medic_unlockprimary0", "skorpion_mp");
    }
    if (getdvar("surv_medic_unlockprimary1") == "") {
        setdvar("surv_medic_unlockprimary1", "uzi_mp");
    }
    if (getdvar("surv_medic_unlockprimary2") == "") {
        setdvar("surv_medic_unlockprimary2", "mp5_mp");
    }
    if (getdvar("surv_medic_unlockprimary3") == "") {
        setdvar("surv_medic_unlockprimary3", "ak74u_mp");
    }
    if (getdvar("surv_medic_unlockprimary4") == "") {
        setdvar("surv_medic_unlockprimary4", "p90_acog_mp");
    }

    // Medic secondary weapons
    if (getdvar("surv_medic_unlocksecondary0") == "") {
        setdvar("surv_medic_unlocksecondary0", "beretta_mp");
    }
    if (getdvar("surv_medic_unlocksecondary1") == "") {
        setdvar("surv_medic_unlocksecondary1", "usp_mp");
    }
    if (getdvar("surv_medic_unlocksecondary2") == "") {
        setdvar("surv_medic_unlocksecondary2", "colt45_mp");
    }
    if (getdvar("surv_medic_unlocksecondary3") == "") {
        setdvar("surv_medic_unlocksecondary3", "deserteaglegold_mp");
    }


    // Set default values for weapon upgrade base costs

    // Primary weapons
    if (getdvar("surv_unlockprimary1_points") == "") {
        setdvar("surv_unlockprimary1_points", 500);
    }
    if (getdvar("surv_unlockprimary2_points") == "") {
        setdvar("surv_unlockprimary2_points", 750);
    }
    if (getdvar("surv_unlockprimary3_points") == "") {
        setdvar("surv_unlockprimary3_points", 1250);
    }
    if (getdvar("surv_unlockprimary4_points") == "") {
        setdvar("surv_unlockprimary4_points", 2000);
    }

    // Secondary weapons
    if (getdvar("surv_unlocksecondary1_points") == "") {
        setdvar("surv_unlocksecondary1_points", 250);
    }
    if (getdvar("surv_unlocksecondary2_points") == "") {
        setdvar("surv_unlocksecondary2_points", 500);
    }
    if (getdvar("surv_unlocksecondary3_points") == "") {
        setdvar("surv_unlocksecondary3_points", 750);
    }
    if (getdvar("surv_unlocksecondary4_points") == "") {
        setdvar("surv_unlocksecondary4_points", 750);
    }


    // Set default base costs for special weapons
    if (getdvar("surv_unlockextra1_points") == "") {
        setdvar("surv_unlockextra1_points", 1000);
    }
    if (getdvar("surv_unlockextra2_points") == "") {
        setdvar("surv_unlockextra2_points", 1500);
    }
    if (getdvar("surv_unlockextra3_points") == "") {
        setdvar("surv_unlockextra3_points", 1500);
    }
    if (getdvar("surv_unlockextra4_points") == "") {
        setdvar("surv_unlockextra4_points", 1500);
    }

    // Set default special weapons
    if (getdvar("surv_extra_unlock1") == "") {
        setdvar("surv_extra_unlock1", "barrett_acog_mp");   // raygun
    }
    if (getdvar("surv_extra_unlock2") == "") {
        setdvar("surv_extra_unlock2", "skorpion_acog_mp");  // flamethrower
    }
    if (getdvar("surv_extra_unlock3") == "") {
        setdvar("surv_extra_unlock3", "ak74u_acog_mp");     // tesla
    }
    if (getdvar("surv_extra_unlock4") == "") {
        setdvar("surv_extra_unlock4", "saw_acog_mp");       // minigun
    }

    // Find special weapons (i.e. extra_unlocks)
    i = 0;
    while (1) {
        newWeapon = getdvar("surv_extra_unlock"+(i+1));
        if (newWeapon=="") {break;}
        level.specialWeps[i] = newWeapon;
//         debugPrint("Special weapon loaded: " + newWeapon, "val");
        i++;
    }
}

precache()
{
    precacheString(&"ROTUSCRIPT_MUST_BE_PRESTIGE");
    precacheString(&"ROTUSCRIPT_NOT_ENOUGH_UP");
    precacheString(&"ROTUSCRIPT_NO_MORE_UPGRADES");
}

/**
 * @brief Upgrades the players weapon
 *
 * @param weaponType string The type of weapon. One of [primary|secondary|extra]
 *
 * @returns nothing
 */
doUpgrade(weaponType)
{
    debugPrint("in _upgradables::doUpgrade()", "fn", level.nonVerbose);

    // get integer portion of the dvar name of next weapon upgrade
    upgradeIndex = self.unlock[weaponType] + 1;

    if (weaponType=="extra")
    {
        if (!self.canGetSpecialWeapons)
        {
            self iprintlnbold(&"ROTUSCRIPT_MUST_BE_PRESTIGE");
            return;
        }
        newWeapon = getdvar("surv_extra_unlock"+upgradeIndex);
        cost = getdvarint("surv_unlock"+weaponType+upgradeIndex+"_points");
    }
    else
    {
        newWeapon = getdvar("surv_"+self.curClass+"_unlock"+weaponType+upgradeIndex);
        cost = getdvarint("surv_unlock"+weaponType+upgradeIndex+"_points");
    }
    scalingFactor = getdvarint("surv_unlock_cost_factor");
    totalCost = Int(cost * scalingFactor);

    /// N.B. if the unlock points for this weapon isn't specified, the upgrade will be free
    // Always hold back enough points so the player can buy an infection cure
    cureHoldback = level.dvar["shop_item3_costs"];

    if (newWeapon != "")
    {
        if (self.points >= totalCost + cureHoldback)
        {
            // If the upgrade exists and the player can afford it, give it to them
            self scripts\players\_players::incUpgradePoints(-1*totalCost);
            self scripts\players\_weapons::swapWeapons(weaponType, newWeapon);
            self.unlock[weaponType]++;
            self.persData.unlock[weaponType] = self.unlock[weaponType];
        }
        else
        {
            self iprintlnbold(&"ROTUSCRIPT_NOT_ENOUGH_UP", totalCost, cureHoldback);
        }
    }
    else
    {
        self iprintlnbold(&"ROTUSCRIPT_NO_MORE_UPGRADES");
    }
}
