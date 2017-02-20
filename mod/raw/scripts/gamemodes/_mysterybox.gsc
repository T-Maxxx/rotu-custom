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
    debugPrint("in _mysterybox::init()", "fn", level.nonVerbose);

    level.mys_wep = [];
    addMysWep("weapon_ak47", "ak47_mp", "primary");
    addMysWep("weapon_m4gre_sp_silencer_reflex", "m4_acog_mp", "primary");
    addMysWep("weapon_m40a3", "m40a3_mp", "primary");
    addMysWep("weapon_benelli_super_90", "m1014_grip_mp", "primary");
    addMysWep("weapon_m14_scout_mp", "m14_mp", "primary");
    addMysWep("weapon_ak74u", "ak74u_mp", "primary");
    addMysWep("weapon_g36", "g36c_acog_mp", "primary");
    addMysWep("weapon_m16_mp", "m16_mp", "primary");
    addMysWep("weapon_m60", "m60e4_mp", "primary");
    addMysWep("weapon_p90", "p90_acog_mp", "primary");

    addMysWep("weapon_usp", "usp_mp", "secondary");
    addMysWep("weapon_beretta" , "beretta_mp", "secondary");
    addMysWep("weapon_colt1911_silencer" , "colt45_silencer_mp", "secondary");
    addMysWep("weapon_crossbow_1" , "crossbow_mp", "secondary");
    addMysWep("weapon_desert_eagle_gold", "deserteaglegold_mp", "secondary");
    addMysWep("weapon_mini_uzi", "uzi_mp", "secondary");
    addMysWep("weapon_desert_eagle_gold", "deserteaglegold_mp", "secondary");

    addMysWep("weapon_mw2_f2000_wm", "m14_acog_mp", "primary");
    addMysWep("weapon_spas12", "m1014_reflex_mp", "primary");
    addMysWep("weapon_aug", "rpd_acog_mp", "primary");
    addMysWep("mw2_aa12_worldmodel", "m60e4_acog_mp", "primary");
    addMysWep("worldmodel_bo_minigun", "saw_acog_mp", "primary");
    addMysWep("weapon_tesla", "ak74u_acog_mp", "primary");

    addMysWep("mw2_mp5k_worldmodel", "mp5_acog_mp", "secondary");

    addMysWep("weapon_raygun", "barret_acog_mp", "primary");
    addMysWep("weapon_flamethrower", "skorpion_acog_mp", "primary");
    addMysWep("mw2_intervention_wm", "deserteagle_mp", "primary");
}


addMysWep(model, weaponName, slot)
{
    debugPrint("in _mysterybox::addMysWep()", "fn", level.nonVerbose);

    precachemodel(model);
    struct = spawnstruct();
    struct.model = model;
    struct.weaponName = weaponName;
    struct.slot = slot;
    level.mys_wep[level.mys_wep.size] = struct;
}

mystery_box(box)
{
    debugPrint("in _mysterybox::mystery_box()", "fn", level.lowVerbosity);

    weapon = spawn( "script_model", box.origin + (0,0,20) );
    weapon.angles = (0,(box.angles[1] + 90),0);
    weapon.done = false;
    weapon hide();
    weapon showtoplayer(self);
    weapon moveZ( 32, 2.4 );
    lastnum = weapon createRandomItem(self);
    self.box_weapon = weapon;
    self playlocalsound("zom_mystery");
    for( i = 0; i < 14; i++ )
    {
        wait 0.2;
        lastnum = weapon createRandomItem(self, lastnum);
    }
    wait 0.05;
    weapon.done = true;
    weapon thread deleteOverTime(7);

}

createRandomItem(player, lastNum)
{
    debugPrint("in _mysterybox::createRandomItem()", "fn", level.lowVerbosity);

    if (isdefined(lastNum))
    {
        num = randomInt( level.mys_wep.size-3 );
        if (num >= lastNum)
        num++;
    }
    else
    {
        num = randomInt( level.mys_wep.size-2 );
        lastNum = -2;
    }

    for (i=0; i<level.mys_wep.size; i++)
    {
        wep = level.mys_wep[i];
        if (wep.weaponName == player.primary || wep.weaponName == player.secondary || i == lastNum)
        {
            num++;
            continue;
        }
        if (i == num)
        {
            self setmodel(wep.model);
            self.weaponName = wep.weaponName;
            self.slot = wep.slot;
        }

    }
}

deleteOverTime(time)
{
    debugPrint("in _mysterybox::deleteOverTime()", "fn", level.lowVerbosity);

    self endon("death");
    wait time;
    self delete();
}
