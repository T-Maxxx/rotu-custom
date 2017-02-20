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

/**
 * This file processes responses from the main in-game pop-up menu.  It is used
 * to provide a hook when a player tries to open the admin menu.
 *
 * Related files:
 *      rotu21\ui_mp\wm_quickmessage.menu               The menu definition
 *      rotu21\scripts\server\_server.gsc               Threads the init() function
 *
 *      rotu21\ui_mp\scriptmenus\admin.menu             The menu definition for admin menu
 *      rotu21\scripts\server\_adminmenu.gsc            Code to handle admin actions
 
 TODO: check of all this code can be moved to main menuresponse routine.
 */

init()
{
    debugPrint("in _main_popup::init()", "fn", level.nonVerbose);

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    debugPrint("in _main_popup::onPlayerConnect()", "fn", level.nonVerbose);

    while(true) {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    debugPrint("in _main_popup::onPlayerSpawned()", "fn", level.nonVerbose);

    self endon("disconnect");

    while(true) {
        self waittill("spawned_player");
        self thread onMenuResponse();
    }
}

onMenuResponse()
{
    debugPrint("in _main_popup::onMenuResponse()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");

    while(true) {
        self waittill("menuresponse", menu, response);

        // Call the onOpenAdminMenu function
        if (response == "admin_menu_on_open") {
            scripts\server\_adminInterface::onOpenAdminMenu(self.player);
        }
    }
}
