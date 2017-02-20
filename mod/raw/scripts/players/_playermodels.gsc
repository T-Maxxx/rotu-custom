/* Localization not required. */
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
/* @todo: move to stringtable for easier management. */
init()
{
    debugPrint("in _playermodels::init()", "fn", level.nonVerbose);

    precache();
}

precache()
{
    debugPrint("in _playermodels::precache()", "fn", level.nonVerbose);

    precachemodel("body_mp_usmc_grenadier");

    precachemodel("body_mp_usmc_rifleman");
    precachemodel("body_mp_usmc_support");
    precachemodel("body_mp_usmc_woodland_sniper");
    precachemodel("body_mp_opforce_support");
    precachemodel("body_mp_usmc_woodland_support");
    precachemodel("body_mp_usmc_woodland_recon");
    precachemodel("body_mp_usmc_woodland_specops");
    precachemodel("body_mp_usmc_woodland_assault");
    precachemodel("body_mp_usmc_sniper");

    precachemodel("head_sp_usmc_zach_zach_body_goggles");
    precachemodel("head_sp_usmc_sami_goggles_zach_body");
    precachemodel("head_mp_usmc_ghillie");
    precachemodel("head_sp_opforce_derik_body_f");
    precachemodel("head_sp_sas_woodland_mac");
    precachemodel("head_sp_opforce_geoff_headset_body_c");
    precachemodel("head_sp_sas_woodland_peter");
    precachemodel("head_sp_sas_woodland_todd");
    precachemodel("head_sp_sas_woodland_hugh");
    precachemodel("head_sp_spetsnaz_collins_vladbody");
}

setPlayerClassModel(class)
{
    debugPrint("in _playermodels::setPlayerClassModel()", "fn", level.nonVerbose);

    self detachAll();
    self.myBody = "";
    self.myHead = "";

    // Models for class
    switch (class) {
        case "soldier":
            rI = randomint(2);
            switch (rI)
            {
                case 0:
                    self.myBody = "body_mp_usmc_rifleman";
                break;
                case 1:
                    self.myBody = "body_mp_usmc_support";
                    rII = randomint(2);
                    if (rII == 0)
                        self.myHead = "head_sp_usmc_zach_zach_body_goggles";
                    else
                        self.myHead = "head_sp_usmc_sami_goggles_zach_body";
                break;
            }
        break;
        case "stealth":
            self.myBody = "body_mp_usmc_woodland_sniper";
            self.myHead = "head_mp_usmc_ghillie";
        break;
        case "armored":
            rI = randomint(2);
            switch (rI)
                {
                    case 0:
                        self.myBody = "body_mp_usmc_woodland_support";
                        self.myHead = "head_sp_sas_woodland_mac";
                        break;
                    case 1:
                        self.myBody = "body_mp_usmc_woodland_support";
                        self.myHead = "head_sp_opforce_derik_body_f";
                        break;
                }
        break;
        case "engineer":
            self.myBody = "body_mp_usmc_woodland_assault";
            self.myHead = "head_sp_spetsnaz_collins_vladbody";
        break;
        case "scout":
            rI = randomint(2);
            switch (rI)
            {
                case 0:
                    self.myBody = "body_mp_usmc_woodland_recon";
                break;
                case 1:
                    self.myBody = "body_mp_usmc_woodland_recon";
                break;
            }

            rI = randomint(3);
            switch (rI)
            {
                case 0:
                    self.myHead = "head_sp_opforce_geoff_headset_body_c";
                break;
                case 1:
                    self.myHead = "head_sp_sas_woodland_peter";
                break;
                case 2:
                    self.myHead = "head_sp_sas_woodland_todd";
                break;
            }


        break;
        case "medic":
                self.myBody = "body_mp_usmc_sniper";

                rI = randomint(2);
                switch (rI)
                {
                    case 0:
                        self.myHead = "head_sp_sas_woodland_hugh";
                    break;
                    case 1:
                        self.myHead = "head_sp_spetsnaz_collins_vladbody";
                    break;

                }
        break;
    }
    // Setting the models
    if (self.myBody != "") {self setmodel(self.myBody);}
    if (self.myHead != "") {self attach(self.myHead);}
}
