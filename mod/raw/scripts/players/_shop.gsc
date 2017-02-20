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

playerSetupShop()
{
    debugPrint("in _shop::playerSetupShop()", "fn", level.nonVerbose);

    //self.points = level.dvar["game_startpoints"];
    self.support_level = 0;
    self.upgrade_damMod = 1;
    self setclientdvars("ui_points", self.points, "ui_upgrade", 0, "ui_upgradepoints", self.points, "ui_supupgrade", 0);
    for (i=0; i<6; i++) {
        if (!isDefined(self)) {return;}
        self setclientdvar("ui_costs"+i, level.dvar["shop_item"+(i+1)+"_costs"]);
        wait .05;
    }
    for (i=0; i<8; i++) {
        if (!isDefined(self)) {return;}
        self setclientdvar("ui_itemcosts"+i, level.dvar["shop_defensive"+(i+1)+"_costs"]);
        wait .05;
    }
    /*for (i=0; i<5; i++) {
        if (!isDefined(self)) {return;}
        self setclientdvar("ui_supportcosts"+i, level.dvar["shop_support"+(i+1)+"_costs"]);
        wait .05;
    }*/
}

/* Called from scripts\players\_players::precache() */
precache()
{
    precacheString(&"ROTUSCRIPT_NO_LONGER_INFECTED");
    precacheString(&"ROTUSCRIPT_SORRY_MAX_C4");
    precacheString(&"ROTUSCRIPT_SORRY_MAX_BARRELS");
    precacheString(&"ROTUSCRIPT_SORRY_MAX_CLAYMORES");
    precacheString(&"ROTUSCRIPT_OOPS_TOO_MANY_CLAYMORES");
    precacheString(&"ROTUSCRIPT_SORRY_MAX_TURRETS");
    precacheString(&"ROTUSCRIPT_GRENADE_TURRET_UNLOCKED_AT");
    precacheString(&"ROTUSCRIPT_SORRY_MAX_GRENADE_TURRETS");
    precacheString(&"ROTUSCRIPT_SORRY_MAX_MG_BARRELS");
    precacheString(&"ROTUSCRIPT_MINIGUN_TURRET_UNLOCKED_AT");
    precacheString(&"ROTUSCRIPT_SORRY_MAX_MINIGUN_TURRETS");
    precacheString(&"ROTUSCRIPT_SORRY_MAX_PORTALS");
    precacheString(&"ROTUSCRIPT_SORRY_YOU_MUST_PLACE_TNT");
    precacheString(&"ROTUSCRIPT_SORRY_MAX_TNT");
    precacheString(&"ROTUSCRIPT_OOPS_TOO_MANY_TNT");
}

processResponse(response)
{
    debugPrint("in _shop::processResponse()", "fn", level.nonVerbose);

    // Always hold back enough points so the player can buy an infection cure
    cureHoldback = level.dvar["shop_item3_costs"];

    switch (response)
    {
        case "item0": // Health
            if (self.points >= level.dvar["shop_item1_costs"] + cureHoldback)
            {
                self thread scripts\players\_players::fullHeal(3);
                self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item1_costs"]);
            }
        break;
        case "item1": // Ammo
            if (self.points >= level.dvar["shop_item2_costs"] + cureHoldback)
            {
                self scripts\players\_players::restoreAmmo();
                self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item2_costs"]);
            }
        break;
        case "item2": // Cure
        if (self.points >= level.dvar["shop_item3_costs"]) // no cureHoldback for the cure itself
        {
            self scripts\players\_infection::cureInfection();
            self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item3_costs"]);
            iprintln(&"ROTUSCRIPT_NO_LONGER_INFECTED", self.name);
        }
        break;
        case "item3": // Grenades
        if (self.points >= level.dvar["shop_item4_costs"] + cureHoldback)
        {
            self scripts\players\_weapons::swapWeapons("grenade", "frag_grenade_mp");
            self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item4_costs"]);
        }
        break;
        case "item4":  // C4
            if (self.points >= level.dvar["shop_item5_costs"] + cureHoldback)
            {
                // extra check to make sure race conditions haven't made the emplaced array inaccurate
                self scripts\players\_weapons::rebuildPlayersEmplacedExplosives();
                if (level.maxC4PerPlayer - self.emplacedC4.size == 0) {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_C4", level.maxC4PerPlayer);
                    return;
                }
                self giveweapon("c4_mp");
                self switchtoweapon("c4_mp");
                self setweaponammostock ("c4_mp", level.maxC4PerPlayer - self.emplacedC4.size);
                self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item5_costs"]);
            }
            break;

        case "item5": // raygun
            if (self.points >= level.dvar["shop_item6_costs"] + cureHoldback)
            {
                if (self.unlock["extra"]==0) {
                    self.extra = getdvar("surv_extra_unlock1");

                    self.unlock["extra"] ++;
                    self.persData.unlock["extra"] ++;

                    self giveweapon(self.extra);
                    self givemaxammo(self.extra);
                    self switchtoweapon(self.extra);
                    self setclientdvar("ui_raygun", 0);
                    self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item6_costs"]);
                }
            }
        break;

        case "item10": // Barrel
            if (self.points >= level.dvar["shop_defensive1_costs"] + cureHoldback)
            {
                if (level.barrels[0] + level.barrels[2] < level.dvar["game_max_barrels"])
                {
                    self scripts\players\_barricades::giveBarrel();
                    self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive1_costs"]);
                }
                else
                {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_BARRELS", level.dvar["game_max_barrels"]);
                }
            }
        break;

        case "item11": // Claymore
            if (self.points >= level.dvar["shop_defensive2_costs"] + cureHoldback)
            {
                // extra check to make sure race conditions haven't made the emplaced array inaccurate
                self scripts\players\_weapons::rebuildPlayersEmplacedExplosives();
                amount = level.maxClaymoresPerPlayer - self.emplacedClaymores.size;
                if (amount == 0) {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_CLAYMORES", level.maxClaymoresPerPlayer);
                    return;
                } else if (amount < 0) {
                    errorPrint(self.name + " Claymore purchase amount is negative: " + amount + " deployed claymores: " + self.emplacedClaymores.size);
                    self iprintlnbold(&"ROTUSCRIPT_OOPS_TOO_MANY_CLAYMORES");
                    return;
                }
                self giveweapon("claymore_mp");
                self switchtoweapon("claymore_mp");
                // Up to 8 claymores, but max set at 4 in claymore_mp
                self setweaponammostock ("claymore_mp", level.maxClaymoresPerPlayer - self.emplacedClaymores.size);
                self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive2_costs"]);
            }
        break;

        case "item12": // Exploding Barrel
            if (self.points >= level.dvar["shop_defensive3_costs"] + cureHoldback)
            {
                if (level.barrels[0] + level.barrels[2] < level.dvar["game_max_barrels"])
                {
                    self scripts\players\_barricades::giveBarrel(2);
                    self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive3_costs"]);
                }
                else
                {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_BARRELS", level.dvar["game_max_barrels"]);
                }
            }
        break;

        case "item13": // Grenade Turret
            if (self.points >= level.dvar["shop_defensive4_costs"] + cureHoldback)
            {
                if (self scripts\players\_persistence::statGet("plevel") < level.grenadeTurretPrestigeUnlock) {
                    self iprintlnbold(&"ROTUSCRIPT_GRENADE_TURRET_UNLOCKED_AT", level.grenadeTurretPrestigeUnlock);
                    return;
                }
                if (self.ownsTurret) {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_TURRETS");
                    return;
                }
//                 if (level.grenadeTurretCount < level.maxGrenadeTurrets) {
                turret = scripts\players\_turrets::deployableTurret("gl");
                if (isDefined(turret)) {
                    self scripts\players\_turrets::giveGrenadeTurret(turret); // Mk 19
                    self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive4_costs"]);
                } else {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_GRENADE_TURRETS", level.maxGrenadeTurrets);
                }
            }
            break;

        case "item14":  // MG+Barrel

            if (self.points >= level.dvar["shop_defensive5_costs"] + cureHoldback) {
                if (level.barrels[1] < level.dvar["game_max_mg_barrels"]) {
                    self scripts\players\_barricades::giveMgBarrel();
                    self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive5_costs"]);
                } else {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_MG_BARRELS", level.dvar["game_max_mg_barrels"]);
                }
            }
        break;
        case "item15": // Minigun turret
            if (self.points >= level.dvar["shop_defensive6_costs"] + cureHoldback) {
                if (self scripts\players\_persistence::statGet("plevel") < level.minigunTurretPrestigeUnlock) {
                    self iprintlnbold(&"ROTUSCRIPT_MINIGUN_TURRET_UNLOCKED_AT", level.minigunTurretPrestigeUnlock);
                    return;
                }
                if (self.ownsTurret) {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_TURRETS");
                    return;
                }
//                 if (level.minigunTurretCount < level.maxMinigunTurrets) {
                turret = scripts\players\_turrets::deployableTurret("minigun");
                if (isDefined(turret)) {
                    self scripts\players\_turrets::giveMinigunTurret(turret); // minigun
                    self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive6_costs"]);
                } else {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_MINIGUN_TURRETS", level.maxMinigunTurrets);
                }
            }
        break;
        case "item16": // Portal
            if (self.points >= level.dvar["shop_defensive7_costs"] + cureHoldback) {
                if (level.teles < level.dvar["game_max_portals"]) {
                    self scripts\players\_teleporter::giveTeleporter();
                    self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive7_costs"]);
                } else {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_PORTALS", level.dvar["game_max_portals"]);
                }
            }
        break;

        case "item17":  // TNT
            if (self.points >= level.dvar["shop_defensive8_costs"] + cureHoldback)
            {
                // extra check to make sure race conditions haven't made the emplaced array inaccurate
                self scripts\players\_weapons::rebuildPlayersEmplacedExplosives();
                weapon = self getcurrentweapon();
                stockAmmo = self GetWeaponAmmoStock(weapon);
                if ((weapon == "tnt_mp") && (stockAmmo >= 1)) {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_YOU_MUST_PLACE_TNT");
                    return;
                }
                amount = level.maxTntPerPlayer - self.emplacedTnt.size;
                if (amount == 0) {
                    self iprintlnbold(&"ROTUSCRIPT_SORRY_MAX_TNT", level.maxTntPerPlayer);
                    return;
                } else if (amount < 0) {
                    errorPrint(self.name + " TNT purchase amount is negative: " + amount + " deployed TNT: " + self.emplacedTnt.size);
                    self iprintlnbold(&"ROTUSCRIPT_OOPS_TOO_MANY_TNT");
                    return;
                }
                self giveweapon("tnt_mp");
                self switchtoweapon("tnt_mp");
                self setweaponammostock ("tnt_mp", amount);
                self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive8_costs"]);
            }
            break;


/*        case "item20":
            if (self.points >= level.dvar["shop_support1_costs"] + cureHoldback && self.support_level == 0)
            {
                self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_support1_costs"]);
                self.support_level++;
                self setclientdvar("ui_supupgrade", self.support_level);
                self setActionSlot( 1, "nightvision" );
                self.nighvision = true;
            }
        break;*/

    }
}
