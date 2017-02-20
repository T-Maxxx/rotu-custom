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
/**
 * @file _umiEditor.gsc This file runs the development menu and contains the UMI editing features
 */

#include scripts\include\array;
#include scripts\include\data;
#include scripts\include\entities;
#include scripts\include\hud;
#include scripts\include\matrix;
#include scripts\include\utility;

init()
{
    // Used as default weapon/shop models when running UMI maps
    precacheModel("ad_sodamachine");
    precacheModel("com_plasticcase_green_big");
    precacheModel("prop_flag_american"); // used for linked waypoints
    precacheModel("prop_flag_russian");  // used for unlinked waypoints
    precacheModel("prop_flag_brit");     // used for linking waypoints

    precacheString(&"ROTUSCRIPT_PRESS_TO_BUY_UPGRADES");
    precacheString(&"ROTUSCRIPT_HOLD_TO_RESTOCK_AMMO");
    precacheString(&"ROTUSCRIPT_PRESS_TO_UPGRADE_WEAPS");
    precacheString(&"ROTUSCRIPT_PRESS_FOR_A_WEAPON");
    precacheString(&"ROTUSCRIPT_PRESS_TO_PICK_UP_WEAPON");
    precacheString(&"ROTUSCRIPT_PRESS_TO_PICKUP_WP");
    precacheString(&"ROTUSCRIPT_PRESS_TO_PICKUP_EQUIPSHOP");
    precacheString(&"ROTUSCRIPT_PRESS_TO_PICKUP_WEAPSHOP");
    precacheString(&"ROTUSCRIPT_ERROR_DEV_MODE_REQUIRED_SEE_LOG");
    precacheString(&"ROTUSCRIPT_WP_LINKS_ARE_DRAWN_ABOVE");
    precacheString(&"ROTUSCRIPT_DROP_FLAG_NEAR_LINK_TO_COMPLETE");
    precacheString(&"ROTUSCRIPT_CANNOT_LINK_TO_ITSELF");
    precacheString(&"ROTUSCRIPT_AUTOLINKING_TOOK_MS");
    precacheString(&"ROTUSCRIPT_AUTOSAVING_WPS");
    precacheString(&"ROTUSCRIPT_NO_MORE_UNLINKED_WP_AVAILABLE");
    precacheString(&"ROTUSCRIPT_LINK_SOME_WPS_TO_RECYCLE");
    precacheString(&"ROTUSCRIPT_WAYPOINT_SHORTCUTS");
    precacheString(&"ROTUSCRIPT_WAYPOINT_ID");
    precacheString(&"ROTUSCRIPT_WAYPOINT_TYPE");
    precacheString(&"ROTUSCRIPT_PLAYER_X");
    precacheString(&"ROTUSCRIPT_PLAYER_Y");
    precacheString(&"ROTUSCRIPT_PLAYER_Z");
    precacheString(&"ROTUSCRIPT_YOU_MUST_HAVE_EQUAL_EQUI_WEAP_SHOPS");
    precacheString(&"ROTUSCRIPT_TRADESPAWN_DATA_WRITTEN");
    precacheString(&"ROTUSCRIPT_WPS_DATA_WRITTEN");


    if ((getDvarInt("developer_script") == 1) &&
        (getDvarInt("developer") == 1) &&
        (getDvarInt("dedicated") == 0))     // Listen server
    {
        level.developerMode = true;
    } else {
        level.developerMode = false;
        noticePrint("Map: Developer mode is off, UMI Map Editor is unavailable");
        noticePrint("Map: To enable developer mode, playMod.bat/host.bat requires '+set developer 1 +set developer_script 1'");
        noticePrint("Map: Also, the server must be a Listen server.");
    }
}

/**
 * @brief Initializes this use of the development menu
 *
 * @returns nothing
 */
onOpenDevMenu()
{
    debugPrint("in _umiEditor::onOpenDevMenu()", "fn", level.nonVerbose);

    if (scripts\server\_adminInterface::isAdmin(self)) {
        // Do nothing
    } else {
        // Do nothing
    }
}

/**
 * @brief Opens the in-game development menu if the player is recognized as an admin
 *
 * @returns nothing
 */
onOpenDevMenuRequest()
{
    debugPrint("in _umiEditor::onOpenDevMenuRequest()", "fn", level.nonVerbose);

    if ((level.developerMode) && (scripts\server\_adminInterface::isAdmin(self))) {
        self onOpenDevMenu();
        self openMenu(game["menu_development"]);
    }
}

/**
 * @brief Watches the development menu for commands, then processes them
 *
 * @returns nothing
 */
watchDevelopmentMenuResponses()
{
    debugPrint("in _umiEditor::watchDevelopmentMenuResponses()", "fn", level.nonVerbose);

    self endon("disconnect");
    // threaded on each admin player

    while (!(isDefined(level.developerMode))) {wait 1;} // wait until developerMode is defined
    if (!(level.developerMode)) {return;} // don't listen for commands if developerMode is off

    while (1) {
        self waittill("menuresponse", menu, response);

        // menu "-1" is the main in-game popup menu bound to the 'b' key
        if ((menu == "-1") && (response == "dev_menu_open_request")) {
            self onOpenDevMenuRequest();
            continue;
        }

        // If menu isn't an admin menu, then bail
        if ((menu != "development") && (menu != "clientcmd")) {
            //debugPrint("Menu is not the development menu.", "val");
            continue;
        }

        switch(response)
        {
        /** Development */
        case "dev_give_equipment_shop":
            devGiveEquipmentShop();
            break;
        case "dev_give_weapon_shop":
            devGiveWeaponsShop();
            break;
        case "dev_delete_closest_tradespawn":
            devDeleteClosestShop();
            break;
        case "dev_save_tradespawns":
            devSaveTradespawns();
            break;
        case "dev_toggle_waypoints_mode":
            devToggleGiveWaypointsMode();
            break;
        case "dev_autolink_waypoints":
            devAutoLinkWaypoints();
            break;
        case "dev_link_waypoint":
            devLinkWaypoint();
            break;
        case "dev_delete_waypoint":
            devUiDeleteWaypoint();
            break;
        case "dev_delete_link":
            devDeleteLink();
            break;
        case "dev_cycle_waypoint_type":
            devCycleWaypointType();
            break;
        case "dev_save_waypoints":
            devSaveWaypoints();
            break;
        default:
            // Do nothing
            break;
        } // end switch(response)
    } // End while(1)
}

/**
 * @brief Inializes the UMI Map Editor
 *
 * @returns nothing
 */
initMapEditor()
{
    debugPrint("in _umiEditor::initMapEditor()", "fn", level.nonVerbose);

    // wait until someone is in the game to see the waypoints before we draw them
    while (level.activePlayers == 0) {
        wait 0.5;
    }

    if (!level.developerMode) {
        noticePrint("Map: Developer mode is off, UMI Map Editor is unavailable");
        noticePrint("Map: To enable developer mode, playMod.bat requires '+set developer 1 +set developer_script 1'");
        iPrintLnBold(&"ROTUSCRIPT_ERROR_DEV_MODE_REQUIRED_SEE_LOG");
        return;
    }

    // the admin player that will be doing the editing
    level.devPlayer = scripts\include\adminCommon::getPlayerByShortGuid(getDvar("admin_forced_guid"));

    // Prevent massive runtime errors from hanging the hosting computer
    if (!(isDefined(level.devPlayer))) {
        errorPrint("level.devPlayer is not defined, which may mean the admin player wasn't recognized.");
        errorPrint("Aborting initialization of UMI Map Editor.");
        return;
    }

    // load UMI Editor shortcuts
    level.devPlayer scripts\players\_players::execClientCommand( "exec maps/mp/_umi_shortcuts.cfg" );

    level.giveWaypointMode = false;
    level.linkingInProgress = false;
    level.waypointModeTurnedOff = false;
    // holds 2 levels of linked waypoints, plus 20 closest unlinked waypoints
    level.localWaypoints = [];
    level.currentWaypoint = 0;
    level.currentWaypointLink = 0;

    devInitWaypointFlags();
    devInitializeUnlinkedWaypoints();
    iPrintLnBold(&"ROTUSCRIPT_WP_LINKS_ARE_DRAWN_ABOVE");
    thread devInitWaypointHud();
    thread devWatchPlayer();
    wait 0.05;
    level thread devDrawWaypointLinks();
}

/**
 * @brief Toggles 'Give Waypoint' mode
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devToggleGiveWaypointsMode()
{
    debugPrint("in _umiEditor::devToggleGiveWaypointsMode()", "fn", level.nonVerbose);

    // don't start or stop waypoint mode while in the process of linking a waypoint
    if (level.linkingInProgress) {return;}

    // intialize
    if (!isDefined(level.giveWaypointMode)) {
        level.waypointModeTurnedOff = false;
        level.giveWaypointMode = true;
        devGiveWaypoint();
        return;
    }

    // start or stop give waypoints mode
    if (level.giveWaypointMode) {
        level.giveWaypointMode = false;
        level.waypointModeTurnedOff = true;
        // stop giving new waypoints, and take away any waypoint the player is carrying
    } else {
        level.giveWaypointMode = true;
        devGiveWaypoint();
    }
}

/**
 * @brief Changes the waypoint type to the next possible type
 *
 * @returns nothing
 */
devCycleWaypointType()
{
    debugPrint("in _umiEditor::devCycleWaypointType()", "fn", level.nonVerbose);

    if (isDefined(level.Wp[level.currentWaypoint].type)) {
        currentType = level.Wp[level.currentWaypoint].type;
    } else {currentType = "undefined";}

    newType = "";
    switch(currentType) {
        case "undefined":
            newType = "stand";
            break;
        case "stand":
            newType = "jump";
            break;
        case "jump":
            newType = "mantle";
            break;
        case "mantle":
            newType = "climb";
            break;
        case "climb":
            newType = "undefined";
            break;
        default:
            // Do nothing
            break;
    } // end switch(currentType)

    level.Wp[level.currentWaypoint].type = newType;
    level.waypointTypeHud setText(newType);
    level.devPlayer setClientDvar("dev_waypoint_type", newType);
}

/**
 * @brief Begins to link the current waypoint to another waypoint
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devLinkWaypoint()
{
    debugPrint("in _umiEditor::devLinkWaypoint()", "fn", level.nonVerbose);

    // don't start a waypoint link while in waypoint mode
    if (level.giveWaypointMode) {return;}

    level.linkingFlag.waypointId = level.currentWaypoint;
    level.linkingInProgress = true;

    level.linkingFlag show();
    self.carryObj = level.linkingFlag;
    self.carryObj.origin = self.origin + AnglesToForward(self.angles)*40;

    self.carryObj.master = self;
    self.carryObj linkto(self);
    self.carryObj setcontents(2);

    iPrintLnBold(&"ROTUSCRIPT_DROP_FLAG_NEAR_LINK_TO_COMPLETE");
    self.canUse = false;
    self disableweapons();
    self thread devFinishLink();
}

/**
 * @brief Finishes linking two waypoints
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devFinishLink()
{
    debugPrint("in _umiEditor::devFinishLink()", "fn", level.nonVerbose);

    from = level.Wp[self.carryObj.waypointId].origin + (0,0,10);
    color = decimalRgbToColor(255,0,0);

    while (1) {
        if (self attackbuttonpressed()) {
            if (self.carryObj.waypointId == level.currentWaypoint) {
                iPrintLnBold(&"ROTUSCRIPT_CANNOT_LINK_TO_ITSELF");
                wait 0.1;
                continue;
            }

            // create a link between  self.carryObj.waypointId and level.currentWaypoint
            waypointA = self.carryObj.waypointId;
            waypointB = level.currentWaypoint;
            devLinkTwoWaypoints(waypointA, waypointB);

            self.carryObj unlink();
            wait .05;

            // recycle the flag
            level.linkingFlag hide();
            level.linkingFlag.origin = (0,0,-9999);
            level.linkingFlag.waypointId = -1;

            self.canUse = true;
            self enableweapons();
            level.linkingInProgress = false;

            return;
        }
        // draw rubber band link between first waypoint and the flag
        a = self.carryObj.origin;
        result = bulletTrace(a + (0,0,50), a - (0,0,50), false, self.carryObj);
        to = result["position"] + (0,0,10);
        line(from, to, color, false, 25);
        wait 0.1;
    }
}

/**
 * @brief Creates a link between two waypoints in memory
 *
 * @param waypointA integer The index of the first waypoint
 * @param waypointB integer The index of the second waypoint
 * @param deferUpdates boolean Whether to redraw links or defer the updates
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devLinkTwoWaypoints(waypointA, waypointB, deferUpdates)
{
    debugPrint("in _umiEditor::devLinkTwoWaypoints()", "fn", level.nonVerbose);

    if (!isDefined(deferUpdates)) {deferUpdates = false;}

    // link waypointA to waypointB
    if (!isDefined(level.Wp[waypointA].linked)) {
        // this is an unlinked waypoint
        devUnflagWaypoint(waypointA);
        // remove the waypoint from the unlinkedWaypoints array
        for (i=0; i<level.unlinkedWaypoints.size; i++) {
            if (level.unlinkedWaypoints[i] == waypointA) {
                level.unlinkedWaypoints[i] = level.unlinkedWaypoints[level.unlinkedWaypoints.size - 1];
                level.unlinkedWaypoints[level.unlinkedWaypoints.size - 1] = undefined;
                break;
            }
        }
        // add the new link
        level.Wp[waypointA].linked[0] = level.Wp[waypointB];
        level.waypointBoolean[waypointA] = 0;
    } else {
        // do an ordered insert
        i = level.Wp[waypointA].linked.size;
        while ((i > 0) && (waypointB < level.Wp[waypointA].linked[i-1].ID)) {
            level.Wp[waypointA].linked[i] = level.Wp[waypointA].linked[i-1];
            i--;
        }
        level.Wp[waypointA].linked[i] = level.Wp[waypointB];
    }
    level.Wp[waypointA].linkedCount = level.Wp[waypointA].linked.size;

    // link waypointB to waypointA
    if (!isDefined(level.Wp[waypointB].linked)) {
        // this is an unlinked waypoint
        devUnflagWaypoint(waypointB);
        // remove the waypoint from the unlinkedWaypoints array
        for (i=0; i<level.unlinkedWaypoints.size; i++) {
            if (level.unlinkedWaypoints[i] == waypointB) {
                level.unlinkedWaypoints[i] = level.unlinkedWaypoints[level.unlinkedWaypoints.size - 1];
                level.unlinkedWaypoints[level.unlinkedWaypoints.size - 1] = undefined;
                break;
            }
        }
        // add the new link
        level.Wp[waypointB].linked[0] = level.Wp[waypointA];
        level.waypointBoolean[waypointB] = 0;
    } else {
        // do an ordered insert
        i = level.Wp[waypointB].linked.size;
        while ((i > 0) && (waypointA < level.Wp[waypointB].linked[i-1].ID)) {
            level.Wp[waypointB].linked[i] = level.Wp[waypointB].linked[i-1];
            i--;
        }
        level.Wp[waypointB].linked[i] = level.Wp[waypointA];
    }
    level.Wp[waypointB].linkedCount = level.Wp[waypointB].linked.size;

    if (!deferUpdates) {
        // refresh the waypoint links
        level notify("waypoint_links_dirty");
        wait 0.05;
        level thread devDrawWaypointLinks();

        devUpdateLocalWaypoints(level.currentWaypoint);
    }
}

/**
 * @brief Auto-links unlinked waypoints
 * The links it creates are correct about 75% of the time.  On an Intel i7 @ 3.9 GHz,
 * auto-linking a file of 20 waypoints (all unlinked), took 50ms. In a file with
 * 489 linked waypoints and 20 unlinked waypoints, auto-linking took 50ms.
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devAutoLinkWaypoints()
{
    debugPrint("in _umiEditor::devAutoLinkWaypoints()", "fn", level.nonVerbose);

    begin = gettime();
    n = level.unlinkedWaypoints.size;
    sum = 0;
    for (i=1; i<=n; i++) {
        sum = sum + (i-1);
    }
    //iPrintLnBold(sum+" unique waypoint links possible");

    masterLinks = [];
    for (i=0; i<level.unlinkedWaypoints.size; i++) {
        origin = level.Wp[level.unlinkedWaypoints[i]].origin + (0,0,20);
        waypoints = [];
        for (j=0; j<level.Wp.size; j++) {
            if (j == level.unlinkedWaypoints[i]) {continue;} // don't consider linking to yourself
            end = level.Wp[j].origin + (0,0,20);
            result = bulletTrace(origin, end, false, undefined);
            if (result["position"] == end) {
                // we didn't hit any obstructions
                waypoints[waypoints.size] = j;
                level.Wp[j].distance = distanceSquared(origin, end);
            }
        }
        // of the line-of-sight waypoints, find the 10 closest
        closest = devFindClosestWaypoints(waypoints, origin, 3);
        links = [];
        for (k=0; k<closest.size; k++) {
            link = spawnstruct();
            link.originWp = level.unlinkedWaypoints[i];
            link.waypoint = closest[k];
            link.ordinal = k; // 0th closest, 5th closest, zero-based
            link.distanceProxy = level.Wp[link.waypoint].distance;
            links[links.size] = link;
        }
        masterLinks[i] = links;
    }

    for (i=0; i<masterLinks.size; i++) {
        for (j=0; j<masterLinks[i].size; j++) {
            fromWp = masterLinks[i][j].originWp;
            toWp = masterLinks[i][j].waypoint;
            alreadyLinked = false;
            for (k=0; k<level.Wp[fromWp].linkedCount; k++) {
                if (level.Wp[fromWp].linked[k].ID == toWp) {alreadyLinked = true;}
            }
            if (!alreadyLinked) {
                devLinkTwoWaypoints(fromWp, toWp, true); // defer updates
                debugPrint(fromWp+":"+toWp, "val");
            }
        }
    }

    // since we deferred refreshing the waypoint links, do it now
    level notify("waypoint_links_dirty");
    wait 0.05;
    level thread devDrawWaypointLinks();

    devUpdateLocalWaypoints(level.currentWaypoint);

    iPrintLnBold(&"ROTUSCRIPT_AUTOLINKING_TOOK_MS", gettime() - begin);

    iPrintLnBold(&"ROTUSCRIPT_AUTOSAVING_WPS");
    noticePrint("The following waypoint file was auto-saved after waypoints were autolinked.");
    devSaveWaypoints();
}

/**
 * @brief Gives waypoints until give waypoints mode is toggled off
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devGiveWaypoint()
{
    debugPrint("in _umiEditor::devGiveWaypoint()", "fn", level.nonVerbose);

    flag = devGetAvailableUnlinkedWaypointFlag();
    if (!isDefined(flag)) {
        iPrintLnBold(&"ROTUSCRIPT_NO_MORE_UNLINKED_WP_AVAILABLE");
        iPrintLnBold(&"ROTUSCRIPT_LINK_SOME_WPS_TO_RECYCLE");
        level.giveWaypointMode = false;
        return;
    }

    // spawn and init a new waypoint
    waypoint = spawnstruct();
    waypoint.origin = (0,0,0);
    waypoint.isLinking = false;
    waypointId = level.Wp.size;
    waypoint.linkedCount = 0;
    waypoint.ID = waypointId;
    // stand, jump, mantle
    waypoint.type = "stand";        // RotU doesn't use this, at least not yet

    // append the new waypoint to the level.Wp array
    level.Wp[waypointId] = waypoint;

    // append the new waypoint to the level.unlinkedWaypoints array
    level.unlinkedWaypoints[level.unlinkedWaypoints.size] = waypointId;

    // mark the current waypoint as having a literal flag
    level.waypointBoolean[waypointId] = 2;

    // update waypoint count
    level.WpCount = level.Wp.size;

    // link the flag with the new waypoint
    flag.waypointId = waypointId;

    flag show();
    self.carryObj = flag;
    self.carryObj.origin = self.origin + AnglesToForward(self.angles)*40;

    self.carryObj.master = self;
    self.carryObj linkto(self);
    self.carryObj setcontents(2);

    level scripts\players\_usables::addUsable(flag, "waypoint", &"ROTUSCRIPT_PRESS_TO_PICKUP_WP", 70);
    self.canUse = false;
    self disableweapons();
    self thread devEmplaceWaypoint();
}

/**
 * @brief Gets an available flag from the collection of unlinked waypoint flags
 *
 * @returns struct A struct representing the flag, or undefined if no flags are available
 * @since RotU 2.2.2
 */
devGetAvailableUnlinkedWaypointFlag()
{
    debugPrint("in _umiEditor::devGetAvailableUnlinkedWaypointFlag()", "fn", level.nonVerbose);

    for (i=0; i<level.unlinkedWaypointFlags.size; i++) {
        if (level.unlinkedWaypointFlags[i].waypointId == -1) {
            level.unlinkedWaypointFlags[i].waypointId = 900; ///hack
            return level.unlinkedWaypointFlags[i];
        }
    }
    // no unlinked waypoint flag is available
    return undefined;
}

/**
 * @brief Unflags, unlinks, and deletes the nearest waypoint
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devUiDeleteWaypoint()
{
    debugPrint("in _umiEditor::devUiDeleteWaypoint()", "fn", level.nonVerbose);

    // don't delete a waypoint while in waypoint mode
    if (level.giveWaypointMode) {return;}
    // don't delete a waypoint while in the process of linking a waypoint
    if (level.linkingInProgress) {return;}

    waypointId = level.currentWaypoint;
    devUnflagWaypoint(waypointId);
    devDeleteWaypoint(waypointId);
}

/**
 * @brief Unlinks and deletes the waypoint from memory
 *
 * @param waypointId integer The index of the waypoint to delete
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devDeleteWaypoint(waypointId)
{
    debugPrint("in _umiEditor::devDeleteWaypoint()", "fn", level.nonVerbose);

    // Deleting a waypoint from the middle of the array is very expensive, while
    // deleting it from the end of the array is O(1), so first we ensure the waypoint
    // to be deleted is the last waypoint in the array.
    if (waypointId != level.Wp.size - 1) {
        devSwapWaypoints(waypointId, level.Wp.size - 1, false);
    }

    // unlink and delete the last waypoint
    devUnlinkWaypoint(level.Wp.size - 1);
    level.Wp[level.Wp.size - 1] = undefined;

    // update waypoint count
    level.WpCount = level.Wp.size;

    // refresh the waypoint links
    level notify("waypoint_links_dirty");
    wait 0.05;
    level thread devDrawWaypointLinks();
}

/**
 * @brief Swaps the position of two waypoints in the waypoints array
 *
 * @param waypointA integer The index of the first waypoint
 * @param waypointB integer The index of the second waypoint
 * @param redrawWaypointLinks boolean Should we update the waypoints links array?
 * This parameter allows us to defer the expense of destroying and recreating the
 * unique waypoint links array.  If it is false, don't forget to manually update
 * the array when the current changeset is finished.  Defaults to true.
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devSwapWaypoints(waypointA, waypointB, redrawWaypointLinks)
{
    debugPrint("in _umiEditor::devSwapWaypoints()", "fn", level.nonVerbose);

    if (!isDefined(redrawWaypointLinks)) {redrawWaypointLinks = true;}

    // swap the actual waypoints and their .ID properties
    temp = level.Wp[waypointA];
    level.Wp[waypointA] = level.Wp[waypointB];
    level.Wp[waypointA].ID = waypointA;
    level.Wp[waypointB] = temp;
    level.Wp[waypointB].ID = waypointB;

    if (redrawWaypointLinks) {
        // refresh the waypoint links
        level notify("waypoint_links_dirty");
        wait 0.05;
        level thread devDrawWaypointLinks();
    }
}

/**
 * @brief Updates linked waypoints to point to this waypoint's new position
 *
 * @param newWaypointId integer The new (or future) index of the waypoint in the array
 * @param oldWaypointId integer The old (or current) index of the waypoint in the array
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devUpdateWaypointReferences(newWaypointId, oldWaypointId)
{
    debugPrint("in _umiEditor::devUpdateWaypointReferences()", "fn", level.nonVerbose);

    // for all of the waypoints linked to this one
    for (i=0; i<level.Wp[oldWaypointId].linkedCount; i++) {
        linkedWaypoint = level.Wp[oldWaypointId].linked[i];
        temp = [];
        // find the reference to this waypoint, then point it to the new waypoint
        for (j=0; j<linkedWaypoint.linked.size; j++) {
            if (linkedWaypoint.linked[j].ID == oldwaypointId) {
                linkedWaypoint.linked[j] = level.Wp[newWaypointId];
                break;
            }
        }
    }
}

/**
 * @brief Deletes the current waypoint link
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devDeleteLink()
{
    debugPrint("in _umiEditor::devDeleteLink()", "fn", level.nonVerbose);

    linkId = level.currentWaypointLink;
    waypointA = level.waypointLinks[linkId].fromId;
    waypointB = level.waypointLinks[linkId].toId;

    // remove references to waypointB from waypointA
    temp = [];
    for (i=0; i<level.Wp[waypointA].linked.size; i++) {
        if (level.Wp[waypointA].linked[i].ID != waypointB) {
            temp[temp.size] = level.Wp[waypointA].linked[i]; // keep this waypoint
        }
    }
    level.Wp[waypointA].linked = temp;
    level.Wp[waypointA].linkedCount = level.Wp[waypointA].linked.size;
    if (level.Wp[waypointA].linkedCount == 0) {level.Wp[waypointA].isLinking = false;}

    // remove references to waypointA from waypointB
    temp = [];
    for (i=0; i<level.Wp[waypointB].linked.size; i++) {
        if (level.Wp[waypointB].linked[i].ID != waypointA) {
            temp[temp.size] = level.Wp[waypointB].linked[i]; // keep this waypoint
        }
    }
    level.Wp[waypointB].linked = temp;
    level.Wp[waypointB].linkedCount = level.Wp[waypointB].linked.size;
    if (level.Wp[waypointB].linkedCount == 0) {level.Wp[waypointB].isLinking = false;}

    // refresh the waypoint links
    level notify("waypoint_links_dirty");
    wait 0.05;
    level thread devDrawWaypointLinks();

    nearestWp = devFindNearestWaypointIndex(level.devPlayer.origin);
    devUpdateLocalWaypoints(nearestWp);
}

/**
 * @brief Removes all links from a waypoint
 *
 * @param waypointId integer The index of the waypoint to unlink
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devUnlinkWaypoint(waypointId)
{
    debugPrint("in _umiEditor::devUnlinkWaypoint()", "fn", level.nonVerbose);

    // for all of the waypoints linked to this one, remove the references to this one
    for (i=0; i<level.Wp[waypointId].linkedCount; i++) {
        linkedWaypoint = level.Wp[waypointId].linked[i];
        temp = [];
        for (j=0; j<linkedWaypoint.linked.size; j++) {
            if (linkedWaypoint.linked[j].ID != waypointId) {
                temp[temp.size] = linkedWaypoint.linked[j]; // keep this waypoint
            }
        }
        linkedWaypoint.linked = temp;
        linkedWaypoint.linkedCount = linkedWaypoint.linked.size;
        if (linkedWaypoint.linkedCount == 0) {linkedWaypoint.isLinking = false;}
    }
    // now remove this waypoint's references to other waypoints
    level.Wp[waypointId].linkedCount = 0;
    level.Wp[waypointId].linked = undefined;
    level.Wp[waypointId].isLinking = false;
}

/**
 * @brief Emplaces the waypoint that a player is being carried
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devEmplaceWaypoint()
{
    debugPrint("in _umiEditor::devEmplaceWaypoint()", "fn", level.nonVerbose);

    // make them wait 1 second between planting waypoint flags to make attackbuttonpressed
    // be bounce-less
    wait 1;

    while (1) {
        if ((level.waypointModeTurnedOff) && (!isDefined(level.Wp[self.carryObj.waypointId].linked))) {
            // player turned off give waypoints mode while carrying a unlinked flag
            self.carryObj unlink();
            waypointId = self.carryObj.waypointId;
            devUnflagWaypoint(waypointId);

            // delete waypoint from the level.unlinkedWaypoints array
            level.unlinkedWaypoints[level.unlinkedWaypoints.size - 1] = undefined;

            // delete the new waypoint
            devDeleteWaypoint(waypointId);
            level.waypointModeTurnedOff = false;

            wait .05;
            self.canUse = true;
            self enableweapons();
            return;
        }
        if (self attackbuttonpressed()) {
            // ensure flagpole bottom is on the ground
            a = self.carryObj.origin;
            result = bulletTrace(a + (0,0,50), a - (0,0,50), false, self.carryObj);
            self.carryObj.origin = result["position"];

            self.carryObj unlink();
            wait .05;
            self.canUse = true;
            self enableweapons();

            // Update the waypoint's origin
            level.Wp[self.carryObj.waypointId].origin = self.carryObj.origin;
            if (!isDefined(level.Wp[self.carryObj.waypointId].linked)) {
                // unlinked waypoint, find closest waypoint that is linked to other waypoints
                index = devFindNearestWaypointWithLinksIndex(level.Wp[self.carryObj.waypointId].origin);
                level.Wp[self.carryObj.waypointId].nearestWaypointWithLinks = index;
            }

            break;
        }
        wait 0.1;
    }

    if (level.giveWaypointMode) {devGiveWaypoint();}
}

/**
 * @brief Picks up a waypoint flag so it can be moved
 *
 * @param flag struct The flag to be picked up and moved
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devMoveWaypoint(flag)
{
    debugPrint("in _umiEditor::devMoveWaypoint()", "fn", level.nonVerbose);

    self scripts\players\_usables::removeUsable(flag);

    /// @bug something seems wonky here sometimes--need to investigate
    self.carryObj = flag;
    self.carryObj.origin = self.origin + AnglesToForward(self.angles)*40;

    self.carryObj.master = self;
    self.carryObj linkto(self);
    self.carryObj setcontents(2);

    level scripts\players\_usables::addUsable(flag, "waypoint", &"ROTUSCRIPT_PRESS_TO_PICKUP_WP", 70);
    self.canUse = false;
    self disableweapons();
    self thread devEmplaceWaypoint();
}

/**
 * @brief Searches for any unlinked waypoints when the map first loads
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devInitializeUnlinkedWaypoints()
{
    debugPrint("in _umiEditor::devInitializeUnlinkedWaypoints()", "fn", level.nonVerbose);

    level.unlinkedWaypoints = [];
    for (i=0; i<level.Wp.size; i++) {
        if (!isDefined(level.Wp[i].linked)) {
            level.unlinkedWaypoints[level.unlinkedWaypoints.size] = i;
        }
    }
}

/**
 * @brief Updates the local working group of waypoints and update their literal flags
 * The local working group of waypoints will be between about 10-50 waypoints.
 * We do most of our work with this subset to avoid the expense of operating on
 * perhaps many hundreds of waypoints.
 *
 * @param nearestWp int The index of the nearest waypoint
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devUpdateLocalWaypoints(nearestWp)
{
    debugPrint("in _umiEditor::devUpdateLocalWaypoints()", "fn", level.nonVerbose);

    level.localWaypoints = [];

    // If there aren't any waypoints, do nothing
    if (level.WpCount == 0) {return;}

    // create a sparse array to hold a flag: should we include this waypoint?
    if (!isDefined(level.waypointBoolean)) { // initialize
        level.waypointBoolean = [];
        for (i=0; i<level.Wp.size; i++) {
            level.waypointBoolean[i] = 0;
        }
        level.priorWaypointBoolean = level.waypointBoolean; // fake current state
    } else {
        level.priorWaypointBoolean = level.waypointBoolean; // save current state
        level.waypointBoolean = [];
        for (i=0; i<level.Wp.size; i++) {
            level.waypointBoolean[i] = 0;
        }
    }

    // Flag a reasonable subset of unlinked waypoints to include in the working group
    if (level.unlinkedWaypoints.size <= 20) {
        // just add all the unlinked waypoints to the local group
        for (i=0; i<level.unlinkedWaypoints.size; i++) {
            level.waypointBoolean[level.unlinkedWaypoints[i]] = 2;
        }
    } else {
        // We should only get here when a map loads waypoints from file with lots
        // of unlinked waypoints.

        // compute the distance squared for all unlinked waypoints, and save that value
        // if it is less than 100,000 units
        closeWaypoints = [];
        for (i=0; i<level.unlinkedWaypoints.size; i++) {
            distanceProxy = distanceSquared(level.Wp[nearestWp].origin, level.Wp[level.unlinkedWaypoints[i]].origin);
            level.Wp[level.unlinkedWaypoints[i]].distance = distanceProxy;
            if (distanceProxy < 100000) {
                closeWaypoints[closeWaypoints.size] = level.unlinkedWaypoints[i];
            }
        }
        // if there are 20 or fewer such close unlinked waypoints, just add them all
        if (closeWaypoints.size <= 20) {
            // just add closeWaypoints to the local group
            for (i=0; i<closeWaypoints.size; i++) {
                level.waypointBoolean[closeWaypoints[i]] = 2;
            }
        } else {
            // there are more than 20 nearby unlinked waypoints, so find and add
            // the 20 closest.  We should only very rarely get here.
            closest = devFindClosestWaypoints(level.unlinkedWaypoints, level.Wp[nearestWp].origin, 20);
            for (i=0; i<closest.size; i++) {
                level.waypointBoolean[closest[i]] = 2;
            }
        }
    }

    // ensure nearestWp is a linked waypoint
    if (!isDefined(level.Wp[nearestWp].linked)) {
        // nearestWp is unlinked, so we need to find the nearest linked waypoint
        nearestUnlinkedWaypoint = nearestWp;
        nearestWp = devFindNearestWaypointWithLinksIndex(level.Wp[nearestUnlinkedWaypoint].origin);
    }
    level.nearestLinkedWaypoint = nearestWp;

    // flag nearest linked waypoint and three generations of children
    level.waypointBoolean[nearestWp] = 2;
    for (i=0; i<level.Wp[nearestWp].linkedCount; i++) {
        // add in the id for each linked waypoint
        child = level.Wp[nearestWp].linked[i].ID;
        level.waypointBoolean[child] = 2;
        for (j=0; j<level.Wp[child].linkedCount; j++) {
            // add in the id for each linked waypoint
            grandchild = level.Wp[child].linked[j].ID;
            if (level.waypointBoolean[grandchild] != 2) {level.waypointBoolean[grandchild] = 1;}
            for (k=0; k<level.Wp[grandchild].linkedCount; k++) {
                // add in the id for each linked waypoint
                greatgrandchild = level.Wp[grandchild].linked[k].ID;
                if (level.waypointBoolean[greatgrandchild] != 2) {level.waypointBoolean[greatgrandchild] = 1;}
            }
        }
    }

    // To ensure we don't run out of available flags, we pass through
    // level.waypointBoolean[] to load level.localWaypoints[]
    // and remove any literal flags as required.
    for (i=0; i<level.waypointBoolean.size; i++) {
        if (level.waypointBoolean[i] == 1) {
            // add waypoint to local group
            level.localWaypoints[level.localWaypoints.size] = i;
            if (level.priorWaypointBoolean[i] == 2) {
                // waypoint currently has a literal flag, so we need to remove it
                devUnflagWaypoint(i);
            }
        } else if (level.waypointBoolean[i] == 0) {
            // this waypoint isn't part of the new local group
            if (level.priorWaypointBoolean[i] == 2) {
                // waypoint currently has a literal flag, so we need to remove it
                devUnflagWaypoint(i);
            }
        } else if (level.waypointBoolean[i] == 2) {
            // just add waypoint to local group
            level.localWaypoints[level.localWaypoints.size] = i;
        }
    }
    // Now add any literal flags to local waypoints that need them
    for (i=0; i<level.localWaypoints.size; i++) {
        id = level.localWaypoints[i];
        if ((level.waypointBoolean[id] == 2) && (level.priorWaypointBoolean[id] != 2)) {
            // waypoint doesn't already have a literal flag, but needs one
            devFlagWaypoint(id);
        }
    }
}

/**
 * @brief Finds a collection of the n closest waypoints
 *
 * @param waypoints integer[] An array containing the indices of the waypoints to consider
 * @param origin vector The reference position
 * @param n integer The number of waypoints to return
 *
 * @returns integer array An array of n waypoint indices sorted by shortest distance
 * @since RotU 2.2.2
 */
devFindClosestWaypoints(waypoints, origin, n)
{
    debugPrint("in _umiEditor::devFindClosestWaypoints()", "fn", level.nonVerbose);

    // compute the distance proxy for each of the waypoints under consideration
    for (i=0; i<waypoints.size; i++) {
        distanceProxy = distanceSquared(level.Wp[waypoints[i]].origin, origin);
        level.Wp[waypoints[i]].distance = distanceProxy;
    }

    waypoints = devQuicksortWaypoints(waypoints, 0, waypoints.size - 1, ::getDistance);
    // waypoints is now sorted from closest to furthest, so grab the first n elements
    closest = [];
    for (i=0; i<n; i++) {
        closest[i] = waypoints[i];
    }
    return closest;
}

/**
 * @brief Sorts an array of waypoint indices based on ascending level.Wp[n].distance
 * This method is best when there are many waypoints to sort.  If you only need
 * the kth closest waypoint, @see devSelectKthClosestWaypoint()
 *
 * @param data integer[] The array of waypoint indices to sort
 * @param left integer The index of the left-most element of the data
 * @param right integer The index of the right-most element of the data
 * @param callback function The callback function that returns the value of the waypoint struct to sort by
 *
 * @returns array The sorted array
 * @recursive
 * @since RotU 2.2.2
 */
devQuicksortWaypoints(data, left, right, callback)
{
    debugPrint("in _umiEditor::devQuicksortWaypoints()", "fn", level.nonVerbose);

    // If the list has 2 or more items
    if (left < right) {
        // Choose middle index as pivot index
        pivotIndex = Int(left + (right - left) / 2);

        // Get lists of bigger and smaller items and final position of pivot
        partition = devPartition(data, left, right, pivotIndex, callback);
        pivotNewIndex = partition.storeIndex;
        data = partition.list;

        // Recursively sort elements smaller than the pivot
        data = devQuicksortWaypoints(data, left, pivotNewIndex - 1, callback);

        // Recursively sort elements at least as big as the pivot
        data = devQuicksortWaypoints(data, pivotNewIndex + 1, right, callback);
    }
    return data;
}

/**
 * @brief Finds the kth-closest waypoint
 * This method is best when you need a specfic kth waypoint.  If you many of the
 * the closest waypoints, @see devQuicksortWaypoints()
 *
 * @param list array The array of waypoint indices to sort
 * @param left integer The index of the left-most element of the data
 * @param right integer The index of the right-most element of the data
 * @param k integer Return the 1-based kth-closest waypoint
 * @param callback function The callback function that returns the value of the waypoint struct to sort by
 *
 * @returns integer The index of the kth-closest waypoint
 * @recursive
 * @since RotU 2.2.2
 */
devSelectKthClosestWaypoint(list, left, right, k, callback)
{
    debugPrint("in _umiEditor::devSelectKthClosestWaypoint()", "fn", level.nonVerbose);

    if (left == right) {
        return left;
    }

    // Choose middle index as pivot index
    pivotIndex = Int(left + (right - left) / 2);

    partition = devPartition(list, left, right, pivotIndex, callback);
    pivotNewIndex = partition.storeIndex;
    list = partition.list;

    pivotDist = pivotNewIndex - left + 1;

    // The pivot is in its final sorted position,
    // so pivotDist reflects its 1-based position if list were sorted
    if (pivotDist == k) {
        return pivotNewIndex;
    } else if (k < pivotDist) {
        return devSelectKthClosestWaypoint(list, left, pivotNewIndex - 1, k, callback);
    } else {
        return devSelectKthClosestWaypoint(list, pivotNewIndex + 1, right, k - pivotDist, callback);
    }
}

/**
 * @brief Partitions an array for quicksort and select
 *
 * @param list array The array of waypoint indices to sort
 * @param left integer The index of the left-most element of the data
 * @param right integer The index of the right-most element of the data
 * @param pivotIndex integer The index of the pivot value
 * @param callback function The callback function that returns the value of the waypoint struct to sort by
 *
 * @returns struct .storeIndex contains the final position if the pivot value
 *                 .list contains the partitioned array
 * @since RotU 2.2.2
 */
devPartition(list, left, right, pivotIndex, callback)
{
    debugPrint("in _umiEditor::devPartition()", "fn", level.nonVerbose);

    pivotValue = [[callback]](level.Wp[list[pivotIndex]]);

    // swap pivot and last element, so pivot element is at the end of the list
    temp = list[pivotIndex];
    list[pivotIndex] = list[right];
    list[right] = temp;

    storeIndex = left;
    for (i=left; i<right; i++) {
        if ([[callback]](level.Wp[list[i]]) < pivotValue) {
            temp = list[storeIndex];
            list[storeIndex] = list[i];
            list[i] = temp;
            storeIndex++;
        }
    }

    // swap pivot into its final index
    temp = list[right];
    list[right] = list[storeIndex];
    list[storeIndex] = temp;

    // storeIndex now holds the final index of the pivotValue
    partition = spawnstruct();
    partition.storeIndex = storeIndex;
    partition.list = list;
    return partition;
}

/**
 * @brief Watches a player's movement and updates data that has gone stale
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devWatchPlayer()
{
    debugPrint("in _umiEditor::devWatchPlayer()", "fn", level.nonVerbose);

    oldNearestWp = -1;
    while (1) {
        nearestWp = 0;
        nearestDistance = 9999999999;
        for (i=0; i<level.WpCount; i++) {
            distance = distancesquared(level.devPlayer.origin, level.Wp[i].origin);
            if(distance < nearestDistance) {
                nearestDistance = distance;
                nearestWp = i;
            }
        }
        if (nearestWp != oldNearestWp) {
            // we have a new nearest waypoint, so update the HUD, flags, and localWaypoints
            level.localWaypoints = [];
            level.currentWaypoint = nearestWp;
            devUpdateLocalWaypoints(nearestWp);
            level.devPlayer setClientDvar("dev_waypoint", nearestWp);
            oldNearestWp = nearestWp;
            level.waypointIdHud setValue(nearestWp);
            if (isDefined(level.Wp[nearestWp].type)) {type = level.Wp[nearestWp].type;}
            else {type = "undefined";}
            level.waypointTypeHud setText(type);
            level.devPlayer setClientDvar("dev_waypoint_type", type);
        }

        // update the player's origin on the HUD
        level.playerXHud setValue(level.devPlayer.origin[0]);
        level.playerYHud setValue(level.devPlayer.origin[1]);
        level.playerZHud setValue(level.devPlayer.origin[2]);
        wait 0.05;
    }
}

/**
 * @brief Initializes a HUD to display waypoint information
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devInitWaypointHud()
{
    debugPrint("in _umiEditor::devInitWaypointHud()", "fn", level.nonVerbose);

    // Set up HUD elements
    verticalOffset = 80;

    level.shortcutsHud = newClientHudElem(level.devPlayer);
    level.shortcutsHud.elemType = "font";
    level.shortcutsHud.font = "default";
    level.shortcutsHud.fontscale = 1.4;
    level.shortcutsHud.x = -160;
    level.shortcutsHud.y = 20;
    level.shortcutsHud.hideWhenInMenu = true;
    level.shortcutsHud.archived = false;
    level.shortcutsHud.alignX = "right";
    level.shortcutsHud.alignY = "middle";
    level.shortcutsHud.horzAlign = "center";
    level.shortcutsHud.vertAlign = "top";
    level.shortcutsHud.color = (0,1,0);
    level.shortcutsHud.alpha = 1;
    level.shortcutsHud.glowColor = (0,0,0);
    level.shortcutsHud.glowAlpha = 1;
    level.shortcutsHud.label = &"ROTUSCRIPT_WAYPOINT_SHORTCUTS";

    level.waypointIdHud = newClientHudElem(level.devPlayer);
    level.waypointIdHud.elemType = "font";
    level.waypointIdHud.font = "default";
    level.waypointIdHud.fontscale = 1.4;
    level.waypointIdHud.x = -16;
    level.waypointIdHud.y = verticalOffset;
    level.waypointIdHud.glowAlpha = 1;
    level.waypointIdHud.hideWhenInMenu = true;
    level.waypointIdHud.archived = false;
    level.waypointIdHud.alignX = "right";
    level.waypointIdHud.alignY = "middle";
    level.waypointIdHud.horzAlign = "right";
    level.waypointIdHud.vertAlign = "top";
    level.waypointIdHud.alpha = 1;
    level.waypointIdHud.glowColor = (0,0,1);
    level.waypointIdHud.label = &"ROTUSCRIPT_WAYPOINT_ID";
    level.waypointIdHud setValue(0);

    level.waypointTypeHud = newClientHudElem(level.devPlayer);
    level.waypointTypeHud.elemType = "font";
    level.waypointTypeHud.font = "default";
    level.waypointTypeHud.fontscale = 1.4;
    level.waypointTypeHud.x = -16;
    level.waypointTypeHud.y = verticalOffset + 18*1;
    level.waypointTypeHud.glowAlpha = 1;
    level.waypointTypeHud.hideWhenInMenu = true;
    level.waypointTypeHud.archived = false;
    level.waypointTypeHud.alignX = "right";
    level.waypointTypeHud.alignY = "middle";
    level.waypointTypeHud.horzAlign = "right";
    level.waypointTypeHud.vertAlign = "top";
    level.waypointTypeHud.alpha = 1;
    level.waypointTypeHud.glowColor = (0,0,1);
    level.waypointTypeHud.label = &"ROTUSCRIPT_WAYPOINT_TYPE";
    level.waypointTypeHud setText("undefined");

    level.playerXHud = newClientHudElem(level.devPlayer);
    level.playerXHud.elemType = "font";
    level.playerXHud.font = "default";
    level.playerXHud.fontscale = 1.4;
    level.playerXHud.x = -16;
    level.playerXHud.y = verticalOffset + 18*2;
    level.playerXHud.glowAlpha = 1;
    level.playerXHud.hideWhenInMenu = true;
    level.playerXHud.archived = false;
    level.playerXHud.alignX = "right";
    level.playerXHud.alignY = "middle";
    level.playerXHud.horzAlign = "right";
    level.playerXHud.vertAlign = "top";
    level.playerXHud.alpha = 1;
    level.playerXHud.glowColor = (0,0,1);
    level.playerXHud.label = &"ROTUSCRIPT_PLAYER_X";
    level.playerXHud setValue(level.devPlayer.origin[0]);

    level.playerYHud = newClientHudElem(level.devPlayer);
    level.playerYHud.elemType = "font";
    level.playerYHud.font = "default";
    level.playerYHud.fontscale = 1.4;
    level.playerYHud.x = -16;
    level.playerYHud.y = verticalOffset + 18*3;
    level.playerYHud.glowAlpha = 1;
    level.playerYHud.hideWhenInMenu = true;
    level.playerYHud.archived = false;
    level.playerYHud.alignX = "right";
    level.playerYHud.alignY = "middle";
    level.playerYHud.horzAlign = "right";
    level.playerYHud.vertAlign = "top";
    level.playerYHud.alpha = 1;
    level.playerYHud.glowColor = (0,0,1);
    level.playerYHud.label = &"ROTUSCRIPT_PLAYER_Y";
    level.playerYHud setValue(level.devPlayer.origin[1]);

    level.playerZHud = newClientHudElem(level.devPlayer);
    level.playerZHud.elemType = "font";
    level.playerZHud.font = "default";
    level.playerZHud.fontscale = 1.4;
    level.playerZHud.x = -16;
    level.playerZHud.y = verticalOffset + 18*4;
    level.playerZHud.glowAlpha = 1;
    level.playerZHud.hideWhenInMenu = true;
    level.playerZHud.archived = false;
    level.playerZHud.alignX = "right";
    level.playerZHud.alignY = "middle";
    level.playerZHud.horzAlign = "right";
    level.playerZHud.vertAlign = "top";
    level.playerZHud.alpha = 1;
    level.playerZHud.glowColor = (0,0,1);
    level.playerZHud.label = &"ROTUSCRIPT_PLAYER_Z";
    level.playerZHud setValue(level.devPlayer.origin[2]);
}

getOrigin(struct) {return struct.origin;} /// callback
getDistance(struct) {return struct.distance;} /// callback


/**
 * @brief Finds the index of the nearest waypoint out of all of the waypoints
 *
 * Since we need to compute distanceSquared anyway, this is faster than using
 * devSelectKthClosestWaypoint(), which depends on that info already existing.
 *
 * @param origin vector The position to measure distances with respect to
 *
 * @returns integer The index of the nearest waypoint
 * @since RotU 2.2.2
 */
devFindNearestWaypointIndex(origin)
{
    debugPrint("in _umiEditor::devFindNearestWaypointIndex()", "fn", level.nonVerbose);

    nearestWp = 0;
    nearestDistance = 9999999999;
    for (i=0; i<level.WpCount; i++) {
        distance = distancesquared(origin, level.Wp[i].origin);
        if(distance < nearestDistance) {
            nearestDistance = distance;
            nearestWp = i;
        }
    }
    return nearestWp;
}

/**
 * @brief Finds the index of the nearest waypoint out of all of the waypoints that have links
 *
 * Since we need to compute distanceSquared anyway, this is faster than using
 * devSelectKthClosestWaypoint(), which depends on that info already existing.
 *
 * @param origin vector The position to measure distances with respect to
 *
 * @returns integer The index of the nearest waypoint that has a link
 * @since RotU 2.2.2
 */
devFindNearestWaypointWithLinksIndex(origin)
{
    debugPrint("in _umiEditor::devFindNearestWaypointWithLinksIndex()", "fn", level.nonVerbose);

    nearestWp = 0;
    nearestDistance = 9999999999;
    for (i=0; i<level.WpCount; i++) {
        if (!isDefined(level.Wp[i].linked)) {continue;} // skip unlinked waypoints
        distance = distancesquared(origin, level.Wp[i].origin);
        if(distance < nearestDistance) {
            nearestDistance = distance;
            nearestWp = i;
        }
    }
    return nearestWp;
}

/**
 * @brief Puts a literal flag of the right type on the given waypoint
 *
 * @param waypointId integer The index of the waypoint to flag
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devFlagWaypoint(waypointId)
{
    debugPrint("in _umiEditor::devFlagWaypoint()", "fn", level.nonVerbose);

    if (!isDefined(level.Wp[waypointId].linked)) {
        for (i=0; i<level.unlinkedWaypointFlags.size; i++) {
            if (level.unlinkedWaypointFlags[i].waypointId == -1) {
                level.unlinkedWaypointFlags[i].waypointId = waypointId;
                level.unlinkedWaypointFlags[i].origin = level.Wp[waypointId].origin;
                level.unlinkedWaypointFlags[i] show();
                level scripts\players\_usables::addUsable(level.unlinkedWaypointFlags[i], "waypoint", &"ROTUSCRIPT_PRESS_TO_PICKUP_WP", 70);
                return;
            }
        }
    } else {
        for (i=0; i<level.linkedWaypointFlags.size; i++) {
            flag = level.linkedWaypointFlags[i];
            if (flag.waypointId == -1) {
                flag.waypointId = waypointId;
                flag.origin = level.Wp[waypointId].origin;
                flag show();
                level scripts\players\_usables::addUsable(flag, "waypoint", &"ROTUSCRIPT_PRESS_TO_PICKUP_WP", 70);
                return;
            }
        }
    }
}

/**
 * @brief Removes a literal flag of the right type on the given waypoint
 *
 * @param waypointId integer The index of the waypoint to unflag
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devUnflagWaypoint(waypointId)
{
    debugPrint("in _umiEditor::devUnflagWaypoint()", "fn", level.nonVerbose);

    if (!isDefined(level.Wp[waypointId].linked)) {
        for (i=0; i<level.unlinkedWaypointFlags.size; i++) {
            if (level.unlinkedWaypointFlags[i].waypointId == waypointId) {
                level.unlinkedWaypointFlags[i].waypointId = -1;
                level.unlinkedWaypointFlags[i].origin = (0,0,-9999);
                level.unlinkedWaypointFlags[i] hide();
                self scripts\players\_usables::removeUsable(level.unlinkedWaypointFlags[i]);
                return;
            }
        }
    } else {
        for (i=0; i<level.linkedWaypointFlags.size; i++) {
            flag = level.linkedWaypointFlags[i];
            if (flag.waypointId == waypointId) {
                flag.waypointId = -1;
                flag.origin = (0,0,-9999);
                flag hide();
                self scripts\players\_usables::removeUsable(flag);
                return;
            }
        }
    }
}

/**
 * @brief Initializes array of flag entities to be used to mark waypoints
 *
 * To limit resources used, we use and recycle 10 flags for linked waypoints,
 * and 20 flags for unlinked waypoints.
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devInitWaypointFlags()
{
    debugPrint("in _umiEditor::devInitWaypointFlags()", "fn", level.nonVerbose);

    level.linkedWaypointFlags = [];
    for (i=0; i<10; i++) {
        flag = spawn("script_model", (0,0,-9999));
        flag.waypointId = -1;
        flag setModel("prop_flag_american");
        flag hide();
        level.linkedWaypointFlags[i] = flag;
    }

    level.unlinkedWaypointFlags = [];
    for (i=0; i<20; i++) {
        flag = spawn("script_model", (0,0,-9999));
        flag.waypointId = -1;
        flag setModel("prop_flag_russian");
        flag hide();
        level.unlinkedWaypointFlags[i] = flag;
    }

    level.linkingFlag = spawn("script_model", (0,0,-9999));
    level.linkingFlag.waypointId = -1;
    level.linkingFlag setModel("prop_flag_brit");
    level.linkingFlag hide();
}

/**
 * @brief Draws and updates the lines representing the links between linked waypoints
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devDrawWaypointLinks()
{
    debugPrint("in _umiEditor::devDrawWaypointLinks()", "fn", level.nonVerbose);

    level endon("waypoint_links_dirty");

    // There aren't enough usable colors to ensure that every connected link is
    // a different color, so we just cycle through the colors--this seems to work
    // better than picking colors pseudo-randomly

    currentLinkColor = decimalRgbToColor(128,255,0);    // bright green -- used for current waypoint link
    // decimalRgbToColor(255,0,0);                      // red -- reserved for links currently being drawn

    colors = [];
    colors[0] = decimalRgbToColor(255,128,0);       // orange
    colors[1] = decimalRgbToColor(128,0,255);       // purple
    colors[2] = decimalRgbToColor(255,255,0);       // yellow
    colors[3] = decimalRgbToColor(0,102,0);         // forest green
    colors[4] = decimalRgbToColor(0,255,255);       // cyan
    colors[5] = decimalRgbToColor(0,0,255);         // blue
    colors[6] = decimalRgbToColor(255,0,255);       // fuschia
    colors[7] = decimalRgbToColor(255,0,128);       // hot pink
    colors[8] = decimalRgbToColor(128,128,128);     // grey
    colors[9] = decimalRgbToColor(102,51,0);        // brown
    colors[10] = decimalRgbToColor(255,255,255);    // white
    colors[11] = decimalRgbToColor(0,0,0);          // black
    colors[12] = decimalRgbToColor(229,255,204);    // pale green
    colors[13] = decimalRgbToColor(0,255,128);      // aquamarine

    // Waypoints are doubly-linked; we only need to draw each link once, so build
    // an array of unique links
    level.waypointLinks = [];
    linkIndex = 0;
    for (i=0; i<level.WpCount; i++) {
        for (j=0; j<level.Wp[i].linkedCount; j++) {
            if (level.Wp[i].linked[j].ID > i) {
                // we need to link this waypoint
                link = spawnstruct();
                level.waypointLinks[linkIndex] = link;
                link.fromId = level.Wp[i].ID;
                link.toId = level.Wp[i].linked[j].ID;
                // debugPrint("linkIndex: "+linkIndex+" .fromId: "+link.fromId+" .toId: "+link.toId, "val");
                link.color = colors[linkIndex % colors.size];
                linkIndex++;
            }
        }
    }

    level thread devWatchNearestWaypointLink();

    // if too many waypoint links, only draw those closer than this to the devPlayer
    drawSubsetDistance = 2500;

    while (1) {
        if (level.waypointLinks.size > 1975) {onlyDrawSubset = true;}
        else {onlyDrawSubset = false;}

        for (i=level.waypointLinks.size - 1; i>0; i--) { // reverse iteration
            from = level.Wp[level.waypointLinks[i].fromId].origin + (0,0,10);
            // On my box, the line() function is limited to drawing about 2000
            // lines, so if there are more links to be drawn than that, we only
            // draw the links that are relatively 'close' to the devPlayer.
            if (onlyDrawSubset) {
                waypointDistance = distance(from, level.devPlayer.origin);
                if (waypointDistance > drawSubsetDistance) {
                    continue; // don't draw this link
                }
            }
            to = level.Wp[level.waypointLinks[i].toId].origin + (0,0,10);
            if (i == level.currentWaypointLink) {color = currentLinkColor;}
            else {color = level.waypointLinks[i].color;}
            // Line( <start>, <end>, <color>, <depthTest>, <duration> )
            line(from, to, color, false, 25);
        }
        wait 0.05;
    }
}

/**
 * @brief Tracks the nearest waypoint link to the player and updates the menu
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devWatchNearestWaypointLink()
{
    debugPrint("in _umiEditor::devWatchNearestWaypointLink()", "fn", level.nonVerbose);

    level endon("waypoint_links_dirty");

    while (1) {
        if (level.waypointLinks.size == 0) {
            wait 0.5;
            continue;
        }
        linkIndex = devFindNearestWaypointLink();
        level.currentWaypointLink = linkIndex;
        linkText = level.waypointLinks[linkIndex].fromId+":"+level.waypointLinks[linkIndex].toId;
        level.devPlayer setClientDvar("dev_waypoint_link", linkText);
        wait 0.2;
    }
}

/**
 * @brief Finds the waypoint link with the smallest angular distance wrt the player
 *
 * @returns integer The index of the waypoint link in the level.waypointLinks array
 * @since RotU 2.2.2
 */
devFindNearestWaypointLink()
{
    debugPrint("in _umiEditor::devFindNearestWaypointLink()", "fn", level.nonVerbose);

    if (level.waypointLinks.size == 1) {return 0;}

    // Since there are times when nearest linear distance to a waypoint link is mathematically
    // undefined, we use the smallest angular distance, which is always defined.
    if (!isDefined(level.nearestLinkedWaypoint)) {
        nearestWp = devFindNearestWaypointWithLinksIndex(level.devPlayer.origin);
    } else {
        nearestWp = level.nearestLinkedWaypoint;
    }
    origin = level.devPlayer.origin + (0,0,10);
    smallestTheta = 360;

    linked = -1;
    from = level.Wp[nearestWp].origin + (0,0,10);
    for (i=0; i<level.Wp[nearestWp].linkedCount; i++) { // about 2-5 waypoints
        to = level.Wp[nearestWp].linked[i].origin + (0,0,10);
        theta = scripts\players\_turrets::angleBetweenTwoVectors(to - from, origin - from);
        if (theta < smallestTheta) {
            smallestTheta = theta;
            linked = i;
        }
    }

    linkedWp = level.Wp[nearestWp].linked[linked].ID;
    linkIndex = devFindWaypointLinkIndex(nearestWp, linkedWp);
    return linkIndex;
}

/**
 * @brief Finds the index for the link between two waypoints using a modified binary search
 *
 * @param fromWp integer The index of the first waypoint in the link
 * @param toWp integer The index of the second waypoint in the link
 *
 * @returns integer The index of the waypoint link, or -1 if it wasn't found, which shouldn't happen.
 * @since RotU 2.2.2
 */
devFindWaypointLinkIndex(fromWp, toWp)
{
    debugPrint("in _umiEditor::devFindWaypointLinkIndex()", "fn", level.nonVerbose);

    // In the level.waypointLinks[] array, .fromId is always in acsending order,
    // so we can do a binary search.  Also, .toId is always > .fromId, so we can
    // determine which one of the bidirectional links we are actually using, and
    // hence to search for.

//     iPrintLnBold(fromWp+":"+toWp);
//     debugPrint(fromWp+":"+toWp, "val");

    leftBound = 0;
    rightBound = level.waypointLinks.size - 1;
    index = -1;

    // Ensure we are searching for the bidirectionl link we have actually stored,
    // not the reverse link
    if (toWp > fromWp) { /// @bug sometimes toWp is undefined
        fromValue = fromWp;
        toValue = toWp;
    } else {
        fromValue = toWp;
        toValue = fromWp;
    }

    while (leftBound <= rightBound) {
        //calculate the midpoint
        midpoint = Int((leftBound + rightBound) / 2);

        // determine which subarray to search
        if (level.waypointLinks[midpoint].fromId < fromValue) {
            // change leftBound to search upper subarray
            leftBound = midpoint + 1;
        } else if (level.waypointLinks[midpoint].fromId > fromValue ) {
            // change rightBound to search lower subarray
            rightBound = midpoint - 1;
        } else {
            // value found at midpoint
            index = midpoint;
            break;
        }
    }

    if (index == -1) {
        // ex.: it was looking for 'undefined' and 370, but no 370 in waypointLinks array
        errorPrint("Failed to find index!"); /// @bug we sometimes fail to find the index
        errorPrint("toWp: " + toWp + " fromWp: " + fromWp);
        errorPrint("toValue: " + toValue + " fromValue: " + fromValue);
        devDumpWaypointLinks();
        // We are going to be in an infinite loop here, so wait a bit to give us
        // time to kill the game before server_mp.log gets too bloated.
        wait 7;
    } else {
        //debugPrint("Value found at index: "+index, "val");
    }

    // there are possibly several matches in the array, so peek at the value in
    // the previous index
    while ((index > 0) && (level.waypointLinks[index-1].fromId == fromValue)) {
        // the previous index also matches fromValue, so decrement index
        index--;
    }
    // index now points to the first matching fromValue in the array

    // Now iterate through the array until we find the link we are looking for
    while (level.waypointLinks[index].fromId == fromValue) {
        if (level.waypointLinks[index].toId == toValue) {
            // this is the link we are looking for
            return index;
        } else {
            index++;
        }
    }
    // error, we couldn't find the link
    errorPrint("Error: Couldn't find waypoint link index!");
    return -1;
}

/**
 * @brief write waypoint links to server log for debugging purposes
 *
 * @returns nothing
 */
devDumpWaypointLinks()
{
    debugPrint("in _umiEditor::devDumpWaypointLinks()", "fn", level.nonVerbose);

    for (i=0; i<level.waypointLinks.size; i++) {
        from = level.waypointLinks[i].fromId;
        to = level.waypointLinks[i].toId;
        errorPrint("Wayoint Link index: " + i + " from: " + from + " to: " + to);
    }
}

/**
 * @brief UMI gives a player a weapons shop that they can emplace
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devGiveEquipmentShop()
{
    debugPrint("in _umiEditor::devGiveEquipmentShop()", "fn", level.nonVerbose);

    if (!isDefined(level.devEquipmentShops)) {level.devEquipmentShops = [];}

    shop = spawn("script_model", (0,0,0));
    shop setModel("ad_sodamachine");
    level.devEquipmentShops[level.devEquipmentShops.size] = shop;

    self.carryObj = shop;
    // we intentionally pick it up off-center so the player can see where they
    // are going
    self.carryObj.origin = self.origin + AnglesToForward(self.angles)*80;

    self.carryObj.angles = self.angles + (0,-90,0);
    self.carryObj.master = self;
    self.carryObj linkto(self);
    self.carryObj setcontents(2);

    level scripts\players\_usables::addUsable(shop, "equipmentShop", &"ROTUSCRIPT_PRESS_TO_PICKUP_EQUIPSHOP", 80);
    self.canUse = false;
    self disableweapons();
    self thread devEmplaceEquipmentShop();
}

/**
 * @brief UMI emplaces an equipment shop a player is carrying
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devEmplaceEquipmentShop()
{
    debugPrint("in _umiEditor::devEmplaceEquipmentShop()", "fn", level.nonVerbose);

    while (1) {
        if (self attackbuttonpressed()) {
            // self.carryObj.origin is the origin of xmodel's coord system, which
            // is the left rear base corner of the soda machine, which is about
            // 40.4 units wide and 31.6 units deep.

            // a, b, and c lie in the base plane of the model, b and c the front
            // left and right corners, respectively, and a bisects the rear face
            a = zeros(2,1);
            setValue(a,1,1,20.2);  // x
            setValue(a,2,1,0);     // y
            b = zeros(2,1);
            setValue(b,1,1,0);     // x
            setValue(b,2,1,-31.6); // y
            c = zeros(2,1);
            setValue(c,1,1,40.4);  // x
            setValue(c,2,1,-31.6); // y

            // d, e, and f are a, b, and c, repspectively, translated into world coordinates
            phi = self.carryObj.angles[1]; // phi is the angle the xmodel is rotated through

            R = eye(2);
            setValue(R,1,1,cos(phi));
            setValue(R,1,2,-1*sin(phi));
            setValue(R,2,1,sin(phi));
            setValue(R,2,2,cos(phi));

            // apply the rotation matrix
            dM = matrixMultiply(R, a);
            eM = matrixMultiply(R, b);
            fM = matrixMultiply(R, c);
            d = self.carryObj.origin + (value(dM,1,1),value(dM,2,1),0);
            e = self.carryObj.origin + (value(eM,1,1),value(eM,2,1),0);
            f = self.carryObj.origin + (value(fM,1,1),value(fM,2,1),0);

            // we trace 50 units above to 50 units below d, e, and f, and the trace
            // position will give us the points, g,h, and l above/below d,e, and f
            // that intersect the world surface
            result = bulletTrace(d + (0,0,100), d - (0,0,100), false, self.carryObj);
            g = result["position"];
            result = bulletTrace(e + (0,0,100), e - (0,0,100), false, self.carryObj);
            h = result["position"];
            result = bulletTrace(f + (0,0,100), f - (0,0,100), false, self.carryObj);
            l = result["position"];

            // now g, h, and l define a plane that approximates the local world surface,
            // so we find the surface normal
            hg = h - g; // h relative to g
            lg = l - g; // l relative to g

            s = zeros(3,1);
            setValue(s,1,1,hg[0]);  // x
            setValue(s,2,1,hg[1]);  // y
            setValue(s,3,1,hg[2]);  // z
            t = zeros(3,1);
            setValue(t,1,1,lg[0]);  // x
            setValue(t,2,1,lg[1]);  // y
            setValue(t,3,1,lg[2]);  // z
            normalM = matrixCross(s, t);

            // standard basis vectors in world coordinate system
            i = (1,0,0);
            j = (0,1,0);
            k = (0,0,1);

            // [i|j|k]Prime are the basis vectors for the rotated coordinate system
            kPrime = vectorNormalize((value(normalM,1,1), value(normalM,2,1), value(normalM,3,1)));
            iPrime = vectorNormalize(l-h);
            u = zeros(3,1);
            setValue(u,1,1,iPrime[0]);  // x
            setValue(u,2,1,iPrime[1]);  // y
            setValue(u,3,1,iPrime[2]);  // z
            jPrimeM = matrixCross(u, normalM);
            jPrime = vectorNormalize((value(jPrimeM,1,1), value(jPrimeM,2,1), value(jPrimeM,3,1)));

            // calculate the new origin (the left-rear corner of the re-positioned soda machine)
            newOrigin = h + (jPrime*-31.6);
            self.carryObj.origin = newOrigin;

            // align the soda machine's x-axis with the computed x-axis
            phi = scripts\players\_turrets::angleBetweenTwoVectors(k, kPrime*(0,1,1));
            self.carryObj.angles = vectorToAngles(iPrime);

            // now align the crate's y-axis with the computed y-axis
            z = anglesToUp(self.carryObj.angles);
            phi = scripts\players\_turrets::angleBetweenTwoVectors(z, kPrime);
            self.carryObj.angles = self.carryObj.angles + (0,0,phi); // phi rotates about x-axis

            // ensure we rotated the crate properly to align the y-axis
            y = anglesToRight(self.carryObj.angles);
            beta = scripts\players\_turrets::angleBetweenTwoVectors(y, jPrime);
            if (beta > phi) {
                // phi should have been negated!
                self.carryObj.angles = self.carryObj.angles + (0,0,-2*phi); // phi rotates about x-axis
            }

            self.carryObj unlink();
            wait .05;
            self.canUse = true;
            self enableweapons();
            return;
        }
        wait 0.1;
    }
}

/**
 * @brief UMI draws a colored laser  at the location and direction specified
 *
 * @param color string The color of the laser: red, green, blue, white, yellow, magenta, cyan
 * @param origin vector The location to place the laser
 * @param direction vector the direction to shine the laser
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devDrawLaser(color, origin, direction)
{
    debugPrint("in _umiEditor::devDrawLaser()", "fn", level.lowVerbosity);

    if (color == "red") {
        playFx(level.redLaserSight, origin, direction);
    } else if (color == "green") {
        playFx(level.greenLaserSight, origin, direction);
    } else if (color == "blue") {
        playFx(level.blueLaserSight, origin, direction);
    } else if (color == "white") {
        playFx(level.redLaserSight, origin, direction);
        playFx(level.greenLaserSight, origin, direction);
        playFx(level.blueLaserSight, origin, direction);
    } else if (color == "yellow") {
        playFx(level.redLaserSight, origin, direction);
        playFx(level.greenLaserSight, origin, direction);
    } else if (color == "magenta") {
        playFx(level.redLaserSight, origin, direction);
        playFx(level.blueLaserSight, origin, direction);
    } else if (color == "cyan") {
        playFx(level.greenLaserSight, origin, direction);
        playFx(level.blueLaserSight, origin, direction);
    }
}

/**
 * @brief UMI emplaces a weapon shop a player is carrying
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devEmplaceWeaponShop()
{
    debugPrint("in _umiEditor::devEmplaceWeaponShop()", "fn", level.nonVerbose);

    while (1) {
        if (self attackbuttonpressed()) {
            // a, b, and c lie in the base plane of the model, b and c the front
            // left and right corners, respectively, and a bisects the rear face
            a = zeros(2,1);
            setValue(a,1,1,0);   // x
            setValue(a,2,1,16);  // y
            b = zeros(2,1);
            setValue(b,1,1,-20); // x
            setValue(b,2,1,-16); // y
            c = zeros(2,1);
            setValue(c,1,1,20);  // x
            setValue(c,2,1,-16); // y

            // d, e, and f are a, b, and c, repspectively, translated into world coordinates
            phi = self.carryObj.angles[1]; // phi is the angle the xmodel is rotated through

            R = eye(2);
            setValue(R,1,1,cos(phi));
            setValue(R,1,2,-1*sin(phi));
            setValue(R,2,1,sin(phi));
            setValue(R,2,2,cos(phi));

            // apply the rotation matrix
            dM = matrixMultiply(R, a);
            eM = matrixMultiply(R, b);
            fM = matrixMultiply(R, c);
            d = self.carryObj.origin + (value(dM,1,1),value(dM,2,1),0);
            e = self.carryObj.origin + (value(eM,1,1),value(eM,2,1),0);
            f = self.carryObj.origin + (value(fM,1,1),value(fM,2,1),0);

            // we trace 50 units above to 100 units below d, e, and f, and the trace
            // position will give us the points, g, h, and l above/below d, e, and f
            // that intersect the world surface
            result = bulletTrace(d + (0,0,50), d - (0,0,100), false, self.carryObj);
            g = result["position"];
            result = bulletTrace(e + (0,0,50), e - (0,0,100), false, self.carryObj);
            h = result["position"];
            result = bulletTrace(f + (0,0,50), f - (0,0,100), false, self.carryObj);
            l = result["position"];

            // now g, h, and l define a plane that approximates the local world surface,
            // so we find the surface normal
            hg = h - g; // h relative to g
            lg = l - g; // l relative to g

            s = zeros(3,1);
            setValue(s,1,1,hg[0]);  // x
            setValue(s,2,1,hg[1]);  // y
            setValue(s,3,1,hg[2]);  // z
            t = zeros(3,1);
            setValue(t,1,1,lg[0]);  // x
            setValue(t,2,1,lg[1]);  // y
            setValue(t,3,1,lg[2]);  // z
            normalM = matrixCross(s, t);

            // standard basis vectors in world coordinate system
            i = (1,0,0);
            j = (0,1,0);
            k = (0,0,1);

            // [i|j|k]Prime are the basis vectors for the rotated coordinate system
            kPrime = vectorNormalize((value(normalM,1,1), value(normalM,2,1), value(normalM,3,1)));
            iPrime = vectorNormalize(l-h);
            u = zeros(3,1);
            setValue(u,1,1,iPrime[0]);  // x
            setValue(u,2,1,iPrime[1]);  // y
            setValue(u,3,1,iPrime[2]);  // z
            jPrimeM = matrixCross(u, normalM);
            jPrime = vectorNormalize((value(jPrimeM,1,1), value(jPrimeM,2,1), value(jPrimeM,3,1)));

            // calculate the new origin (the center of the re-positioned crate)
            newOrigin = h + (jPrime*-31.6);
            midpoint = h + ((l-h) * 0.5);
            newOrigin = midpoint + ((g-midpoint) * 0.5);
            self.carryObj.origin = newOrigin;

            // align the crate's x-axis with the computed x-axis
            phi = scripts\players\_turrets::angleBetweenTwoVectors(k, kPrime*(0,1,1));
            self.carryObj.angles = vectorToAngles(iPrime);

            // now align the crate's y-axis with the computed y-axis
            z = anglesToUp(self.carryObj.angles);
            phi = scripts\players\_turrets::angleBetweenTwoVectors(z, kPrime);
            self.carryObj.angles = self.carryObj.angles + (0,0,phi); // phi rotates about x-axis

            // ensure we rotated the crate properly to align the y-axis
            y = anglesToRight(self.carryObj.angles);
            beta = scripts\players\_turrets::angleBetweenTwoVectors(y, jPrime);
            if (beta > phi) {
                // phi should have been negated!
                self.carryObj.angles = self.carryObj.angles + (0,0,-2*phi); // phi rotates about x-axis
            }

            self.carryObj unlink();
            wait .05;
            self.canUse = true;
            self enableweapons();
            return;
        }
        wait 0.1;
    }
}

/**
 * @brief Initializes weapon shops so they can be edited
 *
 * @param weaponShops string The name of the entities' targetname attribute,
 * e.g. @code buildWeaponShopsByTargetname("ammostock"); @endcode
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
initWeaponShopEditor(weaponShops)
{
    debugPrint("in _umiEditor::initWeaponShopEditor()", "fn", level.nonVerbose);

    weapons = strTok(weaponShops, " ");
    if (!isDefined(level.tradespawns[int(weapons[0])])) {
        errorPrint("Map: No weapon shop tradespawns defined, or tradespawns haven't been loaded().");
        return;
    }
    if (!isDefined(level.devWeaponShops)) {level.devWeaponShops = [];}

    for (i=0; i<weapons.size; i++) {
        tradespawn = level.tradespawns[int(weapons[i])];
        shop = spawn("script_model", tradespawn.origin);
        if (isDefined(shop)) {
            shop.angles = tradespawn.angles;
            shop setModel("com_plasticcase_green_big");
            level.devWeaponShops[level.devWeaponShops.size] = shop;

            level scripts\players\_usables::addUsable(shop, "weaponsShop", &"ROTUSCRIPT_PRESS_TO_PICKUP_WEAPSHOP", 80);
        }
    }
}

/**
 * @brief Initializes equipment shops so they can be edited
 *
 * @param equipmentShops string Space-separated list of tradespawn array indices,
 * e.g. @code buildShopsByTradespawns("1 3 5 7"); @endcode
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
initEquipmentShopEditor(equipmentShops)
{
    debugPrint("in _umiEditor::initEquipmentShopEditor()", "fn", level.nonVerbose);

    shops = strTok(equipmentShops, " ");
    if (!isDefined(level.tradespawns[int(shops[0])])) {
        errorPrint("Map: No equipment shop tradespawns defined, or tradespawns haven't been loaded().");
        return;
    }
    if (!isDefined(level.devEquipmentShops)) {level.devEquipmentShops = [];}

    for (i=0; i<shops.size; i++) {
        tradespawn = level.tradespawns[int(shops[i])];
        shop = spawn("script_model", tradespawn.origin);
        if (isDefined(shop)) {
            shop.angles = tradespawn.angles;
            shop setModel("ad_sodamachine");
            level.devEquipmentShops[level.devEquipmentShops.size] = shop;

            level scripts\players\_usables::addUsable(shop, "equipmentShop", &"ROTUSCRIPT_PRESS_TO_PICKUP_EQUIPSHOP", 80);
        }
    }
}

/**
 * @brief UMI permits a player pick up and move am equipment shop
 *
 * @param shop entity The shop to pick up
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devMoveEquipmentShop(shop)
{
    debugPrint("in _umiEditor::devMoveEquipmentShop()", "fn", level.nonVerbose);

    self scripts\players\_usables::removeUsable(shop);

    self.carryObj = shop;
    self.carryObj.origin = self.origin + AnglesToForward(self.angles)*80;
    self.carryObj.angles = self.angles + (0,-90,0);
    self.carryObj.master = self;
    self.carryObj linkto(self);
    self.carryObj setcontents(2);

    level scripts\players\_usables::addUsable(shop, "equipmentShop", &"ROTUSCRIPT_PRESS_TO_PICKUP_EQUIPSHOP", 80);
    self.canUse = false;
    self disableweapons();
    self thread devEmplaceEquipmentShop();
}

/**
 * @brief UMI permits a player pick up and move a weapon shop
 *
 * @param shop entity The shop to pick up
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devMoveWeaponShop(shop)
{
    debugPrint("in _umiEditor::devMoveWeaponShop()", "fn", level.nonVerbose);

    self scripts\players\_usables::removeUsable(shop);

    self.carryObj = shop;
    self.carryObj.origin = self.origin + AnglesToForward(self.angles)*80;
    self.carryObj.angles = self.angles + (0,-90,0);
    self.carryObj.master = self;
    self.carryObj linkto(self);
    self.carryObj setcontents(2);

    level scripts\players\_usables::addUsable(shop, "weaponsShop", &"ROTUSCRIPT_PRESS_TO_PICKUP_WEAPSHOP", 80);
    self.canUse = false;
    self disableweapons();
    self thread devEmplaceWeaponShop();
}

/**
 * @brief UMI gives a player a weapons shop that they can emplace
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devGiveWeaponsShop()
{
    debugPrint("in _umiEditor::devGiveWeaponsShop()", "fn", level.nonVerbose);

    if (!isDefined(level.devWeaponShops)) {level.devWeaponShops = [];}

    shop = spawn("script_model", (0,0,0));
    shop setModel("com_plasticcase_green_big");
    level.devWeaponShops[level.devWeaponShops.size] = shop;

    self.carryObj = shop;
    self.carryObj.origin = self.origin + AnglesToForward(self.angles)*80;

    self.carryObj.angles = self.angles + (0,-90,0);
    self.carryObj.master = self;
    self.carryObj linkto(self);
    self.carryObj setcontents(2);

    level scripts\players\_usables::addUsable(shop, "weaponsShop", &"ROTUSCRIPT_PRESS_TO_PICKUP_WEAPSHOP", 80);
    self.canUse = false;
    self disableweapons();
    self thread devEmplaceWeaponShop();
}

/**
 * @brief UMI deletes the shop closest to the player
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devDeleteClosestShop()
{
    debugPrint("in _umiEditor::devDeleteClosestShop()", "fn", level.nonVerbose);

    // Find closest equipment shop
    closestEquipmentDistance = 999999;
    closestEquipmentShopIndex = -1;
    if (isDefined(level.devEquipmentShops)) {
        noticePrint("Pre level.devEquipmentShops.size: " + level.devEquipmentShops.size);
        for (i=0; i<level.devEquipmentShops.size; i++) {
            distanceProxy = distanceSquared(self.origin, level.devEquipmentShops[i].origin);
            if (distanceProxy < closestEquipmentDistance) {
                closestEquipmentDistance = distanceProxy;
                closestEquipmentShopIndex = i;
            }
        }
    }

    // Find closest weapon shop
    closestWeaponDistance = 999999;
    closestWeaponShopIndex = -1;
    if (isDefined(level.devWeaponShops)) {
        noticePrint("Pre level.devWeaponShops.size: " + level.devWeaponShops.size);
        for (i=0; i<level.devWeaponShops.size; i++) {
            distanceProxy = distanceSquared(self.origin, level.devWeaponShops[i].origin);
            if (distanceProxy < closestWeaponDistance) {
                closestWeaponDistance = distanceProxy;
                closestWeaponShopIndex = i;
            }
        }
    }

    // Delete the closest shop
    if (closestEquipmentDistance < closestWeaponDistance) {
        // delete equipment shop
        level scripts\players\_usables::removeUsable(level.devEquipmentShops[closestEquipmentShopIndex]);
        level.devEquipmentShops[closestEquipmentShopIndex] delete();
        level.devEquipmentShops = removeElementByIndex(level.devEquipmentShops, closestEquipmentShopIndex);
        noticePrint("Post level.devEquipmentShops.size: " + level.devEquipmentShops.size);
    } else {
        // delete weapon shop
        level scripts\players\_usables::removeUsable(level.devWeaponShops[closestWeaponShopIndex]);
        level.devWeaponShops[closestWeaponShopIndex] delete();
        level.devWeaponShops = removeElementByIndex(level.devWeaponShops, closestWeaponShopIndex);
        noticePrint("Post level.devWeaponShops.size: " + level.devWeaponShops.size);
    }

}

/**
 * @brief UMI writes a tradespawn file to the server log
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devSaveTradespawns()
{
    debugPrint("in _umiEditor::devSaveTradespawns()", "fn", level.nonVerbose);

    if (level.devWeaponShops.size != level.devEquipmentShops.size) {
        errorPrint("Map: You must have an equal number of weapon and equipment shops!");
        iPrintLnBold(&"ROTUSCRIPT_YOU_MUST_HAVE_EQUAL_EQUI_WEAP_SHOPS");
        return;
    }

    mapName =  tolower(getdvar("mapname"));
    logPrint("// =============================================================================\n");
    logPrint("// File Name = '"+mapname+"_tradespawns.gsc'\n");
    logPrint("// Map Name = '"+mapname+"'\n");
    logPrint("// =============================================================================\n");
    logPrint("//\n");
    logPrint("// This file was generated by the RotU admin development command 'Save Tradespawns'\n");
    logPrint("//\n");
    logPrint("// =============================================================================\n");
    logPrint("//\n");
    logPrint("// This file contains the tradespawns (equipment & weapon shop locations) for\n");
    logPrint("// the map '" + mapName + "'\n");
    logPrint("//\n");
    logPrint("// N.B. You will need to delete the timecodes at the beginning of these lines!\n");
    logPrint("//\n");

    logPrint("load_tradespawns()\n");
    logPrint("{\n");
    logPrint("    level.tradespawns = [];\n");
    logPrint("    \n");

    count = level.devWeaponShops.size + level.devEquipmentShops.size;
    shop = "";
    type = "";
    for (i=0; i<count; i++) {
        modulo = i % 2;
        if (modulo == 0) {
            // even-numbered index, traditionally used for weapon shops
            shop = level.devWeaponShops[int(i / 2)];
            type = "weapon";
        } else {
            // odd-numbered index, traditionally used for equipment shops
            shop = level.devEquipmentShops[int((i - 1) / 2)];
            type = "equipment";
        }

        x = devExponentialGuard(shop.origin[0]);
        y = devExponentialGuard(shop.origin[1]);
        z = devExponentialGuard(shop.origin[2]);
        rho = devExponentialGuard(shop.angles[0]);
        phi = devExponentialGuard(shop.angles[1]);

        logPrint("    level.tradespawns["+i+"] = spawnstruct();  // spec'd for "+type+" shop\n");
        logPrint("    level.tradespawns["+i+"].origin = ("+x+","+y+","+z+");\n");
        logPrint("    level.tradespawns["+i+"].angles = ("+rho+","+phi+",0);\n");
    }

    logPrint("    \n");
    logPrint("    level.tradeSpawnCount = level.tradespawns.size;\n");
    logPrint("}\n");

    iPrintLnBold(&"ROTUSCRIPT_TRADESPAWN_DATA_WRITTEN");
}

/**
 * @brief Change numbers as required to ensure they aren't written in exponential notation
 *
 * @param number integer/float The number to check or change
 *
 * @returns a number
 * @since RotU 2.2.2
 */
devExponentialGuard(number)
{
    debugPrint("in _umiEditor::devExponentialGuard()", "fn", level.nonVerbose);

    tolerance = 0.001;
    integer = int(number);
    remainder = number - integer;
    if (remainder < 0) {remainder = -1 * remainder;} // use positive value for comparison
    if (remainder < tolerance) {
        // the decimal portion of the number is within +/- tolerance, so round to nearest thou
        if (number < 0) {
            return integer - tolerance;
        } else if (number > 0){
            return integer + tolerance;
        } else {return number;} // number is zero!
    } else {return number;} // number doesn't have unneeded precision, so just return it
}

/**
 * @brief UMI writes a waypoint file to the server log
 *
 * @returns nothing
 * @since RotU 2.2.2
 */
devSaveWaypoints()
{
    debugPrint("in _umiEditor::devSaveWaypoints()", "fn", level.nonVerbose);

    mapName =  tolower(getdvar("mapname"));
    logPrint("// =============================================================================\n");
    logPrint("// File Name = '"+mapname+"_waypoints.gsc'\n");
    logPrint("// Map Name = '"+mapname+"'\n");
    logPrint("// =============================================================================\n");
    logPrint("//\n");
    logPrint("// This file was generated by the RotU admin development command 'Save Waypoints'\n");
    logPrint("//\n");
    logPrint("// =============================================================================\n");
    logPrint("//\n");
    logPrint("// This file contains the waypoints for the map '" + mapName + "'\n");
    logPrint("//\n");
    logPrint("// N.B. You will need to delete the timecodes at the beginning of these lines!\n");
    logPrint("//\n");

    logPrint("load_waypoints()\n");
    logPrint("{\n");
    logPrint("    level.waypoints = [];\n");
    logPrint("    \n");

    for (i=0; i<level.Wp.size; i++) {
        x = devExponentialGuard(level.Wp[i].origin[0]);
        y = devExponentialGuard(level.Wp[i].origin[1]);
        z = devExponentialGuard(level.Wp[i].origin[2]);

        logPrint("    level.waypoints["+i+"] = spawnstruct();\n");
        logPrint("    level.waypoints["+i+"].origin = ("+x+","+y+","+z+");\n");

        // .type isn't used by RotU, but we will endeavor to preserve that info
        if (isDefined(level.Wp[i].type)) {
            logPrint("    level.waypoints["+i+"].type = \""+level.Wp[i].type+"\";\n");
        }

        if (level.Wp[i].linkedCount == 0) {
            comment = "                /// @bug This waypoint is unlinked!";
        } else {comment = "";}
        logPrint("    level.waypoints["+i+"].childCount = "+level.Wp[i].linkedCount+";"+comment+"\n");

        for (j=0; j<level.Wp[i].linkedCount; j++) {
            logPrint("    level.waypoints["+i+"].children["+j+"] = "+level.Wp[i].linked[j].ID+";\n");
        }

        // .angles isn't used by RotU, but we will endeavor to preserve that info
        if (isDefined(level.Wp[i].angles)) {
            rho = devExponentialGuard(level.Wp[i].angles[0]);
            phi = devExponentialGuard(level.Wp[i].angles[1]);

            logPrint("    level.waypoints["+i+"].angles = ("+rho+","+phi+",0);\n");
        }

        // .use isn't used by RotU, but we will endeavor to preserve that info
        if (isDefined(level.Wp[i].use)) {
            if (level.Wp[i].use) {value = "true";}
            else {value = "false";}
            logPrint("    level.waypoints["+i+"].use = "+value+";\n");
        }
    }

    logPrint("    \n");
    logPrint("    level.waypointCount = level.waypoints.size;\n");
    logPrint("}\n");

    iPrintLnBold(&"ROTUSCRIPT_WPS_DATA_WRITTEN");
}


/**
 * @brief UMI writes entities with defined classname and/or targetname properties to the server log
 *
 * @returns nothing
 * @since RotU 2.2.1
 */
devDumpEntities()
{
    debugPrint("in _umiEditor::devDumpEntities()", "fn", level.nonVerbose);

    ents = getentarray();
    for (i=0; i<ents.size; i++) {
        classname = "";
        targetname = "";
        origin = "";
        script_noteworthy = "";
        if (isDefined(ents[i].classname)) {classname = ents[i].classname;}
        if (isDefined(ents[i].targetname)) {targetname = ents[i].targetname;}
        if (isDefined(ents[i].origin)) {origin = ents[i].origin;}
        if (isDefined(ents[i].script_noteworthy)) {script_noteworthy = ents[i].script_noteworthy;}
        noticePrint("Entity: "+i+" classname: "+classname+" targetname: "+targetname+" origin: "+origin+" script_noteworthy: "+script_noteworthy);
    }
}
