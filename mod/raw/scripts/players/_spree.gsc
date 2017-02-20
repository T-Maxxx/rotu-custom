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

onPlayerSpawn()
{
    debugPrint("in _spree::onPlayerSpawn()", "fn", level.nonVerbose);

    self.spree = 0;
    if (!isdefined(self.hud_streak)) {streakHud();}
}

/* Called from scripts\players\_players::precache() */
precache()
{
    precacheString(&"ROTUSCRIPT_EMPTY");
    precacheString(&"ROTUSCRIPT_TRIPLE_KILL");
    precacheString(&"ROTUSCRIPT_MULTI_KILL");
    precacheString(&"ROTUSCRIPT_KILLING_SPREE");
    precacheString(&"ROTUSCRIPT_ULTRA_KILL");
    precacheString(&"ROTUSCRIPT_MEGA_KILL");
    precacheString(&"ROTUSCRIPT_LUDICROUS_KILL");
    precacheString(&"ROTUSCRIPT_HOLY_SHIT");
    precacheString(&"ROTUSCRIPT_WICKED_SICK");
    precacheString(&"ROTUSCRIPT_KILLED_IN_A_SPREE");
}

/**
 * @brief Gives rank points for killing sprees, and recharges soldiers' special ability
 *
 * Rank points are governed by the linear function points = integer((20/3)*spree - (25/3))
 *
 * @returns nothing
 */
checkSpree()
{
    debugPrint("in _spree::checkSpree()", "fn", level.highVerbosity);

    self endon( "disconnect" );
    self endon( "death" );
    self endon( "downed" );

    self.spree++;
    if (self.spree>1)
    {
        if (self.hud_streak.alpha==0)
            self.hud_streak.alpha = 1;

        self.hud_streak setvalue(self.spree);
        self.hud_streak fontPulse(self);
        switch (self.spree) {
            case 2:
                self playlocalsound("double_kill");
                self scripts\players\_rank::giveRankXP("spree", 5);
                if (self.curClass=="soldier") {
                    self scripts\players\_abilities::rechargeSpecial(5);
                }
            break;
            case 3:
                self stoplocalsound("double_kill");
                self playlocalsound("triple_kill");
                self scripts\players\_rank::giveRankXP("spree", 11);
                self.laststreak = &"ROTUSCRIPT_TRIPLE_KILL";
                self.showstreak = 1;
                if (self.curClass=="soldier") {
                    self scripts\players\_abilities::rechargeSpecial(10);
                }
            break;
            case 5:
                self stoplocalsound("triple_kill");
                self playlocalsound("multikill");
                self scripts\players\_rank::giveRankXP("spree", 25);
                self.laststreak = &"ROTUSCRIPT_MULTI_KILL";
                self.showstreak = 1;
                if (self.curClass=="soldier") {
                    self scripts\players\_abilities::rechargeSpecial(15);
                }
            break;
            case 7:
                self stoplocalsound("multikill");
                self playlocalsound("killing_spree");
                self scripts\players\_rank::giveRankXP("spree", 38);
                self.laststreak = &"ROTUSCRIPT_KILLING_SPREE";
                self.showstreak = 1;
                if (self.curClass=="soldier") {
                    self scripts\players\_abilities::rechargeSpecial(20);
                }
            break;
            case 9:
                self stoplocalsound("killing_spree");
                self playlocalsound("ultrakill");
                self scripts\players\_rank::giveRankXP("spree", 51);
                self.laststreak = &"ROTUSCRIPT_ULTRA_KILL";
                self.showstreak = 1;
                if (self.curClass=="soldier") {
                    self scripts\players\_abilities::rechargeSpecial(25);
                }
            break;
            case 11:
                self stoplocalsound("ultrakill");
                self playlocalsound("megakill");
                self scripts\players\_rank::giveRankXP("spree", 65);
                self.laststreak = &"ROTUSCRIPT_MEGA_KILL";
                self.showstreak = 1;
                if (self.curClass=="soldier") {
                    self scripts\players\_abilities::rechargeSpecial(30);
                }
            break;
            case 13:
                self stoplocalsound("megakill");
                self playlocalsound("ludicrouskill");
                self scripts\players\_rank::giveRankXP("spree", 78);
                self.laststreak = &"ROTUSCRIPT_LUDICROUS_KILL";
                self.showstreak = 1;
                if (self.curClass=="soldier") {
                    self scripts\players\_abilities::rechargeSpecial(35);
                }
            break;
            case 15:
                self stoplocalsound("ludicrouskill");
                self playlocalsound("holyshit");
                self scripts\players\_rank::giveRankXP("spree", 91);
                self.laststreak = &"ROTUSCRIPT_HOLY_SHIT";
                self.showstreak = 1;
                if (self.curClass=="soldier") {
                    self scripts\players\_abilities::rechargeSpecial(40);
                }
            break;
            case 20:
                self stoplocalsound("holyshit");
                self playlocalsound("wickedsick");
                self scripts\players\_rank::giveRankXP("spree", 125);
                self.laststreak = &"ROTUSCRIPT_WICKED_SICK";
                self.showstreak = 1;
                if (self.curClass=="soldier") {
                    self scripts\players\_abilities::rechargeSpecial(100);
                }
            break;
        }
    } 
    else
    {
        self.laststreak = &"ROTUSCRIPT_EMPTY";
        self.showstreak = 0;
    }
    self notify("end_spree");
    self endon("end_spree");
    wait 1.25;
    if (self.showstreak)
        iprintln(&"ROTUSCRIPT_KILLED_IN_A_SPREE", self.laststreak, self.name, self.spree);

    self.spree = 0;
    self.laststreak = &"ROTUSCRIPT_EMPTY";
    self.showstreak = 0;
    self.hud_streak fadeovertime(.5);
    self.hud_streak.alpha = 0;
}
