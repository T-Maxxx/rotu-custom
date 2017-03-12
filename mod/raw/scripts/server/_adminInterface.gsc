/* Partly LOCALIZED. */
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
 * @file _adminInterface.gsc This file sets up the in-game admin interface to the admin commands
 */

#include scripts\include\utility;
#include scripts\include\adminCommon;

init()
{
    precacheString(&"ROTUSCRIPT_REASON_ADMIN_DECISION");
}

/**
 * @brief is the player an admin?
 *
 * @param player The player to check if they are an admin
 *
 * @returns true if admin, otherwise false
 */
isAdmin(player)
{
    debugPrint("in _adminInterface::isAdmin()", "fn", level.fullVerbosity);

    if (isDefined(player.admin) && player.admin.isAdmin) { return true;}
    return false;
}

/**
 * @brief Opens the in-game admin menu if the player is recognized as an admin
 *
 * @returns nothing
 */
onOpenAdminMenuRequest()
{
    debugPrint("in _adminInterface::onOpenAdminMenuRequest()", "fn", level.nonVerbose);

    if (isAdmin(self)) {
        self onOpenAdminMenu();
        self openMenu(game["menu_admin"]);
    }
}

/**
 * @brief Opens the admin menu on 'use' key if the admin is spectating
 *
 * @returns nothing
 */
watchForAdminSpectatorOpenMenuRequests()
{
    debugPrint("in _adminInterface::watchForAdminSpectatorOpenMenuRequests()", "fn", level.lowVerbosity);

    self endon("disconnect");

    while (1) {
        wait 0.1;
        if ((self.isSpectating) && (self useButtonPressed())) {
            onOpenAdminMenuRequest();
        }
    }
}

/**
 * @brief Initializes this use of the admin menu
 *
 * @returns nothing
 */
onOpenAdminMenu()
{
    debugPrint("in _adminInterface::onOpenAdminMenu()", "fn", level.nonVerbose);

    if (isAdmin(self)) {
        self.admin.adminMenuOpen = true;
        debugPrint("Enabling god mode for admin: " + self.admin.playerName, "val");
        self.isGod = true;
        self.god = true;
        self.isTargetable = false;
        showPlayerInfo();
    } else {
        self closeMenu();
        self closeInGameMenu();
        warnPrint(self.name + " opened the admin menu, but we forced it closed.");
        self thread ACPNotify("@ROTUUI_NO_ACCESS_TO_MENU", 3 );
        return;
    }
}

/**
 * @brief Ensures that only valid players are shown in the admin menu
 *
 * @returns nothing
 */
watchAdminMenuData()
{
    debugPrint("in _adminInterface::watchAdminMenuData()", "fn", level.nonVerbose);

    self endon("disconnect");

    while (1) {
        if (!isDefined(level.players)){continue;}
        if (self.admin.adminMenuOpen && self.admin.isAdminMenuDirty) {
            // self.selectedPlayerIndex may not point to the player it was pointing
            // to when it was last set, because players joined or left the game
            if(!self validateSelectedPlayer()) {
                selectNextPlayer();
                self.admin.isAdminMenuDirty = false;
                displayAdminCommandFeedback("@ROTUUI_PLR_INVALID_SELECT_NEXT");
                debugPrint("Admin menu's displayed player info is no longer valid, selecting next player.", "val");
            }
        }
        wait 1;
    }
}

/**
 * @brief Tests whether the curretnly shown player is valid or not
 *
 * @returns boolean True if the player is valid, false otherwise
 */
validateSelectedPlayer()
{
    debugPrint("in _adminInterface::validateSelectedPlayer()", "fn", level.lowVerbosity);

    if (!isDefined(self.selectedPlayerEntityNumber)) {return false;}

    livePlayer = getPlayerByEntityNumber(self.selectedPlayerEntityNumber);

    if ((!isDefined(livePlayer)) || (!isDefined(livePlayer.shortGuid)) || (!isDefined(livePlayer.name))) {
        // The selected entity number isn't in the game anymore, so the UI selected
        // player data is incorrect
        return false;
    }
    if ((livePlayer.shortGuid != self.selectedPlayerShortGuid) ||
        (livePlayer.name != self.selectedPlayerName)) {
           // the selected entity number has been reassigned, so the UI selected
           // player data is incorrect
           return false;
    }
    if (getPlayerIndexByNum(self.selectedPlayerEntityNumber) != self.selectedPlayerIndex) {
        // The player's position in the player's array has changed.  This will affect
        // next/prev, but shouldn't affect out ability to execute admin commands on the player
        return true;
    }
    // Nothing has changed with repsect to this player
    return true;
}

//   5:00 Debug: name                   index playerNumber    guid                    active alive down bot
//   5:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   1   0   0
//   5:00 Debug:               player  1   25 f0b4f8b9b276eeda57312b9e8d4f9328     0   0   0   0
//   5:00 Debug:       |PZA| SPC Taff  2   21 92785c30e612c0ed2912a872dcf4d9e5     0   0   0   0
//   5:00 Debug:           (GER)Futzy  3   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   0   1   0
//   5:00 Debug:       {BCT}Fuzzynuts  5   19 d4df0e8da021286a95f8f8e764476671     1   0   1   0
//   5:00 Debug:      raul schuurmans  4   27 36ffaef045f0875c8b3c3a9b2d8aba8a     1   0   1   0
//   5:00 Debug:           Millennium  6   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   0   1   0
//   5:00 Debug:             DoKdudek  7   24 d5d1a6812ceacf3c408b6bf0a7adece8     1   0   1   0
//   5:00 Debug:                kusba  8   30 60fad2f83f576f3ed3470c2af5b4dd40     1   0   1   0
//   5:00 Debug:         heroinBianca  9   26 9a0a0aef196900d57442659bfbdd6ffc     0   0   0   0
//   5:00 Debug: alive: 1 active: 7 down: 6
//
//  10:00 Debug: name                   index playerNumber    guid                    active alive down bot
//  10:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   1   0   0
//  10:00 Debug:               player  1   25 f0b4f8b9b276eeda57312b9e8d4f9328     1   0   1   0
//  10:00 Debug:       |PZA| SPC Taff  2   21 92785c30e612c0ed2912a872dcf4d9e5     1   1   0   0
//  10:00 Debug:           (GER)Futzy  3   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   1   0   0
//  10:00 Debug:      raul schuurmans  4   27 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  10:00 Debug:       {BCT}Fuzzynuts  5   19 d4df0e8da021286a95f8f8e764476671     1   0   1   0
//  10:00 Debug:           Millennium  6   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  10:00 Debug:             DoKdudek  7   24 d5d1a6812ceacf3c408b6bf0a7adece8     1   1   0   0
//  10:00 Debug:                kusba  8   30 60fad2f83f576f3ed3470c2af5b4dd40     1   1   0   0
//  10:00 Debug:         heroinBianca  9   26 9a0a0aef196900d57442659bfbdd6ffc     1   1   0   0
//  10:00 Debug: alive: 8 active: 10 down: 2
//
//
//  15:00 Debug: name                   index playerNumber    guid                    active alive down bot
//  15:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   1   0   0
//  15:00 Debug:               player  1   25 f0b4f8b9b276eeda57312b9e8d4f9328     1   0   1   0
//  15:00 Debug:       |PZA| SPC Taff  2   21 92785c30e612c0ed2912a872dcf4d9e5     1   0   1   0
//  15:00 Debug:           (GER)Futzy  3   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   1   0   0
//  15:00 Debug:      raul schuurmans  4   27 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  15:00 Debug:           Millennium  5   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  15:00 Debug:             DoKdudek  6   24 d5d1a6812ceacf3c408b6bf0a7adece8     1   0   1   0
//  15:00 Debug:                kusba  7   30 60fad2f83f576f3ed3470c2af5b4dd40     1   1   0   0
//  15:00 Debug:         heroinBianca  8   26 9a0a0aef196900d57442659bfbdd6ffc     1   1   0   0
//  15:00 Debug: alive: 6 active: 9 down: 3
//
//  20:00 Debug: name                   index playerNumber    guid                    active alive down bot
//  20:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   1   0   0
//  20:00 Debug:               player  1   25 f0b4f8b9b276eeda57312b9e8d4f9328     1   0   1   0
//  20:00 Debug:       |PZA| SPC Taff  2   21 92785c30e612c0ed2912a872dcf4d9e5     1   0   1   0
//  20:00 Debug:           (GER)Futzy  3   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   1   0   0
//  20:00 Debug:      raul schuurmans  4   27 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  20:00 Debug:           Millennium  5   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  20:00 Debug:                kusba  6   30 60fad2f83f576f3ed3470c2af5b4dd40     1   1   0   0
//  20:00 Debug:         heroinBianca  7   26 9a0a0aef196900d57442659bfbdd6ffc     1   0   1   0
//  20:00 Debug:            WTFKiller  8   24 7e4e1be0025118b132daf6704c1a2a96     1   1   0   0
//  20:00 Debug:            Mr. Agent  9   29 f0b4f8b9b276eeda57312b9e8d4f9328     1   1   0   0
//  20:00 Debug: alive: 7 active: 10 down: 3
//
//  25:00 Debug: name                   index playerNumber    guid                    active alive down bot
//  25:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   1   0   0
//  25:00 Debug:               player  1   25 f0b4f8b9b276eeda57312b9e8d4f9328     1   1   0   0
//  25:00 Debug:       |PZA| SPC Taff  2   21 92785c30e612c0ed2912a872dcf4d9e5     1   1   0   0
//  25:00 Debug:           (GER)Futzy  3   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   1   0   0
//  25:00 Debug:           Millennium  4   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  25:00 Debug:                kusba  5   30 60fad2f83f576f3ed3470c2af5b4dd40     1   1   0   0
//  25:00 Debug:         heroinBianca  6   26 9a0a0aef196900d57442659bfbdd6ffc     1   1   0   0
//  25:00 Debug:            WTFKiller  7   24 7e4e1be0025118b132daf6704c1a2a96     1   1   0   0
//  25:00 Debug:            Mr. Agent  8   29 f0b4f8b9b276eeda57312b9e8d4f9328     1   1   0   0
//  25:00 Debug:        zombie killer  9   19 16a565290047e2c9ea758fa0ea93b9d4     1   1   0   0
//  25:00 Debug:                Hazar  10  31 ca533355492b75bd82580995cf2fffa1     1   1   0   0
//  25:00 Debug: alive: 11 active: 11 down: 0
//
//  30:00 Debug: name                   index playerNumber    guid                    active alive down bot
//  30:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   0   1   0
//  30:00 Debug:               player  1   25 f0b4f8b9b276eeda57312b9e8d4f9328     1   0   1   0
//  30:00 Debug:       |PZA| SPC Taff  2   21 92785c30e612c0ed2912a872dcf4d9e5     1   1   0   0
//  30:00 Debug:           (GER)Futzy  3   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   0   1   0
//  30:00 Debug:           Millennium  4   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  30:00 Debug:                kusba  5   30 60fad2f83f576f3ed3470c2af5b4dd40     1   0   1   0
//  30:00 Debug:         heroinBianca  6   26 9a0a0aef196900d57442659bfbdd6ffc     1   0   1   0
//  30:00 Debug:            WTFKiller  7   24 7e4e1be0025118b132daf6704c1a2a96     1   0   1   0
//  30:00 Debug:            Mr. Agent  8   29 f0b4f8b9b276eeda57312b9e8d4f9328     1   0   1   0
//  30:00 Debug:        zombie killer  9   19 16a565290047e2c9ea758fa0ea93b9d4     1   0   1   0
//  30:00 Debug:              tommort  10  27 0b616a077c28a2568931bffd8045bd1f     1   0   1   0
//  30:00 Debug:           zlatan psg  11  32 c6bd49da05e61713cdff8b5e2910e763     1   1   0   0
//  30:00 Debug:      {BullS} Pusher#  12  31 36ffaef045f0875c8b3c3a9b2d8aba8a     1   0   1   0
//  30:00 Debug: alive: 3 active: 13 down: 10
//
//  35:00 Debug: name                   index playerNumber    guid                    active alive down bot
//  35:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   1   0   0
//  35:00 Debug:               player  1   25 f0b4f8b9b276eeda57312b9e8d4f9328     1   0   1   0
//  35:00 Debug:       |PZA| SPC Taff  2   21 92785c30e612c0ed2912a872dcf4d9e5     1   1   0   0
//  35:00 Debug:           (GER)Futzy  3   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   0   1   0
//  35:00 Debug:           Millennium  4   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  35:00 Debug:                kusba  5   30 60fad2f83f576f3ed3470c2af5b4dd40     1   0   1   0
//  35:00 Debug:         heroinBianca  6   26 9a0a0aef196900d57442659bfbdd6ffc     1   0   1   0
//  35:00 Debug:            WTFKiller  7   24 7e4e1be0025118b132daf6704c1a2a96     1   1   0   0
//  35:00 Debug:            Mr. Agent  8   29 f0b4f8b9b276eeda57312b9e8d4f9328     1   0   1   0
//  35:00 Debug:        zombie killer  9   19 16a565290047e2c9ea758fa0ea93b9d4     1   1   0   0
//  35:00 Debug:              tommort  10  27 0b616a077c28a2568931bffd8045bd1f     1   0   1   0
//  35:00 Debug:           zlatan psg  11  32 c6bd49da05e61713cdff8b5e2910e763     1   1   0   0
//  35:00 Debug:      {BullS} Pusher#  12  31 36ffaef045f0875c8b3c3a9b2d8aba8a     1   0   1   0
//  35:00 Debug: alive: 6 active: 13 down: 7
//
//  40:00 Debug: name                   index playerNumber    guid                    active alive down bot
//  40:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   0   1   0
//  40:00 Debug:               player  1   25 f0b4f8b9b276eeda57312b9e8d4f9328     1   0   1   0
//  40:00 Debug:       |PZA| SPC Taff  2   21 92785c30e612c0ed2912a872dcf4d9e5     1   0   1   0
//  40:00 Debug:           (GER)Futzy  3   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   0   1   0
//  40:00 Debug:           Millennium  4   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  40:00 Debug:                kusba  5   30 60fad2f83f576f3ed3470c2af5b4dd40     1   0   1   0
//  40:00 Debug:         heroinBianca  6   26 9a0a0aef196900d57442659bfbdd6ffc     1   0   1   0
//  40:00 Debug:            WTFKiller  7   24 7e4e1be0025118b132daf6704c1a2a96     1   0   1   0
//  40:00 Debug:            Mr. Agent  8   29 f0b4f8b9b276eeda57312b9e8d4f9328     1   0   1   0
//  40:00 Debug:        zombie killer  9   19 16a565290047e2c9ea758fa0ea93b9d4     1   0   1   0
//  40:00 Debug:              tommort  10  27 0b616a077c28a2568931bffd8045bd1f     1   0   1   0
//  40:00 Debug:      {BullS} Pusher#  11  31 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  40:00 Debug:      |2PFY|BuddiePro  12  33 c1498bf25d817e59ab8a9c40a2119014     1   0   1   0
//  40:00 Debug:                PPMAN  13  35 ef792af84945df4c815163a1ca0bc400     0   0   0   0
//  40:00 Debug:        Chimera123rix  14  34 6c37e128b47f3a9505564e041bc9a1f6     0   0   0   0
//  40:00 Debug: alive: 2 active: 13 down: 11
//
//  45:00 Debug: name                   index playerNumber    guid                    active alive down bot
//  45:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   1   0   0
//  45:00 Debug:       |PZA| SPC Taff  1   21 92785c30e612c0ed2912a872dcf4d9e5     1   1   0   0
//  45:00 Debug:           (GER)Futzy  2   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   1   0   0
//  45:00 Debug:           Millennium  3   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  45:00 Debug:                kusba  4   30 60fad2f83f576f3ed3470c2af5b4dd40     1   1   0   0
//  45:00 Debug:         heroinBianca  5   26 9a0a0aef196900d57442659bfbdd6ffc     1   1   0   0
//  45:00 Debug:            WTFKiller  6   24 7e4e1be0025118b132daf6704c1a2a96     1   1   0   0
//  45:00 Debug:            Mr. Agent  7   29 f0b4f8b9b276eeda57312b9e8d4f9328     1   1   0   0
//  45:00 Debug:        zombie killer  8   19 16a565290047e2c9ea758fa0ea93b9d4     1   1   0   0
//  45:00 Debug:              tommort  9   27 0b616a077c28a2568931bffd8045bd1f     1   1   0   0
//  45:00 Debug:      |2PFY|BuddiePro  10  33 c1498bf25d817e59ab8a9c40a2119014     1   1   0   0
//  45:00 Debug:                PPMAN  11  35 ef792af84945df4c815163a1ca0bc400     1   1   0   0
//  45:00 Debug:        Chimera123rix  12  34 6c37e128b47f3a9505564e041bc9a1f6     1   1   0   0
//  45:00 Debug: alive: 13 active: 13 down: 0
//
//   50:00 Debug: name                   index playerNumber    guid                    active alive down bot
//  50:00 Debug:         |PZA| Pulsar  0   20 91668de969960da261a12934105882d0     1   1   0   0
//  50:00 Debug:       |PZA| SPC Taff  1   21 92785c30e612c0ed2912a872dcf4d9e5     1   1   0   0
//  50:00 Debug:           (GER)Futzy  2   23 0eb2a4a9490dbfa8bbbfff1f8369bd4f     1   0   1   0
//  50:00 Debug:           Millennium  3   28 36ffaef045f0875c8b3c3a9b2d8aba8a     1   1   0   0
//  50:00 Debug:                kusba  4   30 60fad2f83f576f3ed3470c2af5b4dd40     1   1   0   0
//  50:00 Debug:         heroinBianca  5   26 9a0a0aef196900d57442659bfbdd6ffc     1   1   0   0
//  50:00 Debug:            WTFKiller  6   24 7e4e1be0025118b132daf6704c1a2a96     1   1   0   0
//  50:00 Debug:        zombie killer  7   19 16a565290047e2c9ea758fa0ea93b9d4     1   1   0   0
//  50:00 Debug:              tommort  8   27 0b616a077c28a2568931bffd8045bd1f     1   1   0   0
//  50:00 Debug:      |2PFY|BuddiePro  9   33 c1498bf25d817e59ab8a9c40a2119014     1   0   1   0
//  50:00 Debug:                PPMAN  10  35 ef792af84945df4c815163a1ca0bc400     1   1   0   0
//  50:00 Debug:        Chimera123rix  11  34 6c37e128b47f3a9505564e041bc9a1f6     1   1   0   0
//  50:00 Debug:       =F|A= Guardian  12  25 0fa30dee0cfc080f8865683a63e8e277     1   1   0   0
//  50:00 Debug:                Hazar  13  32 ca533355492b75bd82580995cf2fffa1     1   1   0   0
//  50:00 Debug:            Mr. Agent  14  29 f0b4f8b9b276eeda57312b9e8d4f9328     1   1   0   0
//  50:00 Debug:                ZQhis  15  36 189d5c828df312f035fe2132f005c49d     1   1   0   0
//  50:00 Debug: alive: 14 active: 16 down: 2
//
//
// player indexes change as players are removed fromt he players array.  player
// entity numbers are fairly constant, but *may* change when a player leaves and
// rejoins then game.  Seems the game assigns the lowest available entity number
// to a joining player, which may have previously belonged to them, or to another
// player.

/**
 * @brief Removes admin's god mode two seconds after they close the admin menu
 *
 * @returns nothing
 */
onCloseAdminMenu()
{
    debugPrint("in _adminInterface::onCloseAdminMenu()", "fn", level.nonVerbose);

    self.admin.adminMenuOpen = false;

    wait level.adminMenuGodModeTimeout;
    if (self.admin.adminMenuOpen) {
        // Do nothing if admin menu was reopend in the last 2 seconds
        debugPrint("Disabling god mode canceled because menu re-opened within timeout for admin: " + self.admin.playerName, "val");
    } else {
        self.isGod = false;
        self.god = false;
        self.isTargetable = true;
        debugPrint("Disabling god mode for admin: " + self.admin.playerName, "val");
    }
}


/**
 * @brief Informs the admin they do not have permission to use a given command
 *
 * @returns nothing
 */
onNoPermissions()
{
    debugPrint("in _adminInterface::onNoPermissions()", "fn", level.lowVerbosity);

    self thread ACPNotify("@ROTUUI_NO_ACCESS_TO_USE_CMD", 3 );
}


/**
 * @brief Watches the admin menu for commands, then processes them
 * 
 * @returns nothing
 * @TODO Check if you need to ignore responses from non-admins.
 */
watchAdminMenuResponses()
{
    debugPrint("in _adminInterface::watchAdminMenuResponses()", "fn", level.nonVerbose);

    self endon( "disconnect" );
    // threaded on each admin player

    while (1) {
        self waittill( "menuresponse", menu, response );
//         debugPrint("menu: " + menu + " response: " + response, "val");

        // menu "-1" is the main in-game popup menu bound to the 'b' key
        if ((menu == "-1") && (response == "admin_menu_open_request")) {
            self onOpenAdminMenuRequest();
            continue;
        }

        // If menu isn't an admin menu, then bail
        if ((menu != "admin") &&
            (menu != "admin_kick") &&
            (menu != "admin_ban") &&
            (menu != "admin_temp_ban") &&
            (menu != "admin_changemap") &&
            (menu != "admin_warn"))
        {
            debugPrint("Menu is not an admin menu.", "val"); // <debug />
            continue;
        }

        // Cancel the command if the UI player data is incorrect
        if(!self validateSelectedPlayer()) {
            selectNextPlayer();
            displayAdminCommandFeedback("@ROTUUI_PLR_INVALID_CMD_CANCEL_SELECT_NEXT");
            debugPrint("Player invalid, admin command canceled, selecting next player.", "val");
            continue;
        }

        // detect keypresses for the change map command's filter
        if ((menu == "admin_changemap") && isSubStr(response, "filter:")) {
            tokens = StrTok(response, ":");
            character = tokens[1];
//             debugPrint("Detected filter character: " + character, "val");
            switch(character) {
                case "space": character = " "; break;
                case "[":     character = "("; break;
                case "]":     character = "]"; break;
                case ".":     character = "_"; break;
                default: // do nothing
                    break;
            }
            changeMapUpdateFilter(character);
        }

//         debugPrint("menu repsonse is: " + response, "val");
        switch(response)
        {
        case "admin_next":
            selectNextPlayer();
            break;
        case "admin_prev":
            selectPreviousPlayer();
            break;
        case "admin_menu_close":
            thread onCloseAdminMenu();
            break;

        /** Punishment */
        case "admin_down":
            downPlayer(self.selectedPlayerEntityNumber);
            break;
        case "admin_boom":
            explodePlayer(self.selectedPlayerEntityNumber);
            break;
        case "admin_drop":
            dropPlayerWeapon(self.selectedPlayerEntityNumber);
            break;
        case "admin_disarm":
            disarmPlayer(self.selectedPlayerEntityNumber);
            break;
        case "admin_take_current_weapon":
            takePlayersCurrentWeapon(self.selectedPlayerEntityNumber);
            break;
        case "admin_demote":
            demotePlayer(self.selectedPlayerEntityNumber);
            break;

        /** Reward */
        case "admin_promote":
            promotePlayer(self.selectedPlayerEntityNumber);
            break;
        case "admin_restore_primary_weapon":
            restorePlayersPrimaryWeapon(self.selectedPlayerEntityNumber);
            break;
        case "admin_restore_sidearm":
            restorePlayersSidearm(self.selectedPlayerEntityNumber);
            break;
        case "admin_give_upgrade_points":
            givePlayerUpgradePoints(self.selectedPlayerEntityNumber);
            break;

        /** Banning */
        case "admin_warn_general":
            /// if session is visible, reason will become "[Admin's Name] decision."
            warnPlayer(self.selectedPlayerEntityNumber, "admin_name");
            break;
        case "admin_warn_language":
            warnPlayer(self.selectedPlayerEntityNumber, "Bad Language");
            break;
        case "admin_warn_silent":
            warnPlayer(self.selectedPlayerEntityNumber, "silent");
            break;
        case "admin_remove_one_warning":
            removeOneWarning(self.selectedPlayerEntityNumber);
            break;
        case "admin_remove_one_language_warning":
            removeOneLanguageWarning(self.selectedPlayerEntityNumber);
            break;
        case "admin_remove_all_warnings":
            removeAllWarnings(self.selectedPlayerEntityNumber);
            break;

        case "admin_temp_ban_general":
            /// if session is visible, reason will become "[Admin's Name] decision."
            temporarilyBanPlayer(self.selectedPlayerEntityNumber, "admin_name");
            break;
        case "admin_temp_ban_glitching":
            temporarilyBanPlayer(self.selectedPlayerEntityNumber, "Glitching");
            break;
        case "admin_temp_ban_cheating":
            temporarilyBanPlayer(self.selectedPlayerEntityNumber, "Cheating");
            break;
        case "admin_temp_ban_language":
            temporarilyBanPlayer(self.selectedPlayerEntityNumber, "Bad Language");
            break;
        case "admin_temp_ban_silent":
            temporarilyBanPlayer(self.selectedPlayerEntityNumber, "silent");
            break;

        case "admin_kick_general":
            /// if session is visible, reason will become "[Admin's Name] decision."
            kickPlayer(self.selectedPlayerEntityNumber, "admin_name");
            break;
        case "admin_kick_glitching":
            kickPlayer(self.selectedPlayerEntityNumber, "Glitching");
            break;
        case "admin_kick_cheating":
            kickPlayer(self.selectedPlayerEntityNumber, "Cheating");
            break;
        case "admin_kick_language":
            kickPlayer(self.selectedPlayerEntityNumber, "Bad Language");
            break;
        case "admin_kick_silent":
            kickPlayer(self.selectedPlayerEntityNumber, "silent");
            break;
        case "admin_ban_general":
            /// if session is visible, reason will become "[Admin's Name] decision."
            banPlayer(self.selectedPlayerEntityNumber, "admin_name");
            break;
        case "admin_ban_glitching":
            banPlayer(self.selectedPlayerEntityNumber, "Glitching");
            break;
        case "admin_ban_cheating":
            banPlayer(self.selectedPlayerEntityNumber, "Cheating");
            break;
        case "admin_ban_language":
            banPlayer(self.selectedPlayerEntityNumber, "Bad Language");
            break;
        case "admin_ban_silent":
            banPlayer(self.selectedPlayerEntityNumber, "silent");
            break;


        /** Miscellaneous */
        case "admin_bounce":
            bouncePlayer(self.selectedPlayerEntityNumber);
            break;
        case "admin_teleport_to_spawn":
            teleportPlayerToSpawn(self.selectedPlayerEntityNumber);
            break;
        case "admin_teleport_to_admin":
            teleportPlayerToAdmin(self.selectedPlayerEntityNumber);
            break;
        case "admin_teleport_forward":
            teleportPlayerForward(self.selectedPlayerEntityNumber);
            break;
        case "admin_session_visibility":
            toggleAdminSessionVisibility();
            break;
        case "admin_kill_zombies":
            killZombies();
            break;

        /** Assist Players */
        case "admin_spawn":
            spawnPlayer(self.selectedPlayerEntityNumber);
            break;
        case "admin_cure":
            curePlayer(self.selectedPlayerEntityNumber);
            break;
        case "admin_heal":
            healPlayer(self.selectedPlayerEntityNumber);
            break;
        case "admin_revive":
            revivePlayer(self.selectedPlayerEntityNumber);
            break;
        case "admin_ammo":
            ammoBox(self.selectedPlayerEntityNumber);
            break;
        case "admin_aura":
            healingAura(self.selectedPlayerEntityNumber);
            break;

        /** Game */
        case "admin_restart_wave":
            restartWave();
            break;
        case "admin_restart_map":
            restartMap();
            break;
        case "admin_finish_wave":
            finishWave();
            break;
        case "admin_finish_map":
            finishMap();
            break;
        case "admin_changemap_accept":
            changeMap();
            break;
        case "admin_changemap_cancel":
            onCancelChangeMap();
            break;
        case "admin_changemap_apply_filter":
//             debugPrint("Filter: " + filter, "val");
            applyMapFilter();
            break;
        case "admin_open_changemap":
            onOpenChangeMap();
            break;
        case "admin_changemap_backspace":
            changeMapFilterBackspace();
            break;
        default:
            // Do nothing
            break;
        } // end switch(response)

    } // End while(1)
}

/**
 * @brief Converts a player number from a string to an integer
 *
 * @param stringPlayerNumber string The player number as a string
 *
 * @returns integer The player number cast as an integer
 */
intPlayerNumber(stringPlayerNumber)
{
    debugPrint("in _adminInterface::intPlayerNumber()", "fn", level.lowVerbosity);

    debugPrint("stringPlayerNumber: " + stringPlayerNumber, "val");
    if (!isDefined(level.players)) {
        debugPrint("level.players is undefined.", "val");
    }
    return int(level.players[stringPlayerNumber] getEntityNumber());
}

/**
 * @brief Displays a message next to the admin menu
 *
 * @param text string The text to display
 * @param time string The amount of time to display the text
 *
 * @returns nothing
 */
ACPNotify(text, time)
{
    debugPrint("in _adminInterface::ACPNotify()", "fn", level.nonVerbose);

    self notify("acp_notify");
    self endon("acp_notify");
    self endon("disconnect");

    self setClientDvar("admin_txt", text);
    wait time;
    self setClientDvar("admin_txt", "");
}


/**
 * @brief Selects the next player
 *
 * @returns nothing
 */
selectNextPlayer()
{
    debugPrint("in _adminInterface::selectNextPlayer()", "fn", level.nonVerbose);
    players = level.players;

    self.selectedPlayerIndex++;

    // wrap around the array bounds
    if( self.selectedPlayerIndex >= players.size ) {
        self.selectedPlayerIndex = 0;
    }
    self.selectedPlayerName = players[self.selectedPlayerIndex].name;
    self.selectedPlayerShortGuid = players[self.selectedPlayerIndex].shortGuid;
    self.selectedPlayerEntityNumber = players[self.selectedPlayerIndex] getEntityNumber();
    showPlayerInfo();
}


/**
 * @brief Selects the previous player
 *
 * @returns nothing
 */
selectPreviousPlayer()
{
    debugPrint("in _adminInterface::selectPreviousPlayer()", "fn", level.nonVerbose);
    players = level.players;
    self.selectedPlayerIndex--;

    // wrap around the array bounds
    if( self.selectedPlayerIndex <= -1 ) {
        self.selectedPlayerIndex = players.size-1;
    }
    self.selectedPlayerName = players[self.selectedPlayerIndex].name;
    self.selectedPlayerShortGuid = players[self.selectedPlayerIndex].shortGuid;
    self.selectedPlayerEntityNumber = players[self.selectedPlayerIndex] getEntityNumber();
    showPlayerInfo();
}



/**
 * @brief Updates the selected player's info in the admin menu
 *
 * @returns nothing
 */
showPlayerInfo()
{
    debugPrint("in _adminInterface::showPlayerInfo()", "fn", level.nonVerbose);

    if (!isDefined(self.selectedPlayerIndex)) {
        debugPrint("for " + self.name + " self.selectedPlayerIndex is undefined; cannot show player info.", "val");
        return;
    }
    player = level.players[self.selectedPlayerIndex];
    if(!isDefined(player)) {return;}

    if (!isDefined(self.selectedPlayerName)) {self.selectedPlayerName = player.name;}
    if (!isDefined(self.selectedPlayerShortGuid)) {self.selectedPlayerShortGuid = player.shortGuid;}
    if (!isDefined(self.selectedPlayerEntityNumber)) {self.selectedPlayerEntityNumber = player getEntityNumber();}

    self.spectatorclient = player getEntityNumber();
    // This info only gets updated when an admin uses the next/previous player menu options,
    // as it doesn't change frequently
    self setClientDvars( "admin_p_n", player.name,
                         "admin_p_t", getTeamName(player),
                         "admin_p_rpd", getRankPresitgeDemerits(player),
                         "admin_p_g", player.guid);
    // Thread updates to the perishable player info
    self thread updatePerishablePlayerInfo(player, self.selectedPlayerIndex);
}

/**
 * @brief Updates frequently changed player info
 *
 * @param player The player whose data we should update
 * @param selectedPlayer The player that was selected in the menu when this function was called
 *
 * @returns nothing
 */
updatePerishablePlayerInfo(player, selectedPlayer)
{
    debugPrint("in _adminInterface::updatePerishablePlayerInfo()", "fn", level.nonVerbose);

    self endon("disconnect");

    while (self.admin.adminMenuOpen && isDefined(player)) {
        // Bail if originally selected player has changed
        if (selectedPlayer != self.selectedPlayerIndex) {return;}

        self setClientDvars("admin_p_h", (player.health + "/" + player.maxhealth),
                            "admin_p_w", getPlayersWarnings(player),
                            "admin_p_s", getPlayerStatus(player),
                            "admin_p_skd", (player.score + "-" + player.kills + "-" + player.deaths));
        wait 3; // update every three seconds
    }
}


/**
 * @brief Gets the player's warnings
 *
 * @param player The player to get warning counts for
 *
 * @returns string player's warnings
 */
getPlayersWarnings(player)
{
    debugPrint("in _adminInterface::getPlayersWarnings()", "fn", level.nonVerbose);

    if (player.pers["badLanguageWarnings"] == level.badLanguageWarningTempBanThreshold - 1) {
        nextLanguage = "TempBan";
    } else if (player.pers["badLanguageWarnings"] == level.badLanguageWarningBanThreshold - 1) {
        nextLanguage = "Ban";
    } else {nextLanguage = "Warn";}

    if (player.pers["generalWarnings"] == level.generalWarningTempBanThreshold - 1) {
        nextGeneral = "TempBan";
    } else if (player.pers["generalWarnings"] == level.generalWarningBanThreshold - 1) {
        nextGeneral = "Ban";
    } else {nextGeneral = "Warn";}

    result = player.pers["badLanguageWarnings"] + "(" + nextLanguage + ")/" + player.pers["generalWarnings"] + "(" + nextGeneral + ")";

    return result;
}

/**
 * @brief Gets the player's rank, prestige, and demerits
 *
 * @param player The player to get information for
 *
 * @returns string player's rank, prestige, and demerits
 */
getRankPresitgeDemerits(player)
{
    debugPrint("in _adminInterface::getRankPresitgeDemerits()", "fn", level.nonVerbose);

    prestige = player scripts\players\_rank::getPrestigeLevel();
    rank = player scripts\players\_rank::getRank() + 1;

    result = rank + "/" + prestige + "/" + player.pers["demerits"];

    return result;
}

/**
 * @brief Gets the name of the players team
 *
 * @param player The player to get the team name for
 *
 * @returns string the name of the player's team, one of [Zombies|Survivors|Spectator]
 */
getTeamName(player)
{
    debugPrint("in _adminInterface::getTeamName()", "fn", level.nonVerbose);

    if (!isDefined(player.team)) {return "Undefined";}
    if(player.team=="allies") {
        if (player.isZombie) {return "Zombies";}
        else {return "Survivors";}
    }
    else {return "Spectator";}
}


/**
 * @brief Gets the player's status
 *
 * @param player The player to check the status of
 *
 * @returns string the player's status, one of [Playing|Down|Dead|Spectating]
 */
getPlayerStatus(player)
{
    debugPrint("in _adminInterface::getPlayerStatus()", "fn", level.nonVerbose);

    if ((isDefined(player.isDown)) && (player.isDown)) {return "Down";}
    else if( player.sessionstate == "playing" )        {return "Playing";}
    else if( player.sessionstate == "dead" )    {return "Dead";}
    else                                        {return "Spectating";}
}


/**
 * @brief Is the player locked by a pending admin command?
 * If the player isn't locked, it locks the player so an admin command can be issued
 *
 * @param player The player to be checked/locked
 * @param adminName The name of the admin requesting the lock
 * @param commandName The name of the command requesting the lock
 *
 * @returns boolean True if the player was already locked, false if we just locked them.
 * In any event, the player will be locked when this function returns.
 */
isLocked(player, adminName, commandName)
{
    debugPrint("in _adminInterface::isLocked()", "fn", level.nonVerbose);

    // Ensure only one pending admin action on a player at a time
    if(player.isLocked) {
        displayAdminCommandFeedback("@ROTUUI_PLAYER_LOCKED");
        return true;
    } else {
        player.isLocked = true;
        player.lockedBy = self.admin.playerName;
        player.lockTime = getTime();
        player.lockingCommand = commandName;
    }
    return false;
}


/**
 * @brief Warns a player
 *
 * @param playerEntityNumber integer The player's entity number
 * @param reason string The reason the player is being warned
 *
 * @returns nothing
 */
warnPlayer(playerEntityNumber, reason)
{
    debugPrint("in _adminInterface::warnPlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canWarnPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_WARN");
        return;
    }

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "warn"))) {

        // Do we show admins name?
        if ((self.admin.isStealthSession) && (reason == "admin_name")) {
            reason = "Admin decision";
        } else if (reason == "admin_name") {
            reason = self.admin.playerName + "'s decision";
        }

        player thread scripts\server\_adminCommands::warnPlayer(self, reason);
        displayAdminCommandFeedback("@ROTUUI_PLR_WARNED");
    }
}



/**
 * @brief Permenantly bans a player from this server
 *
 * @param playerEntityNumber integer The player's entity number
 * @param reason string The reason the player is being banned
 *
 * @returns nothing
 */
banPlayer(playerEntityNumber, reason)
{
    debugPrint("in _adminInterface::banPlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canBanPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_BAN");
        return;
    }

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "ban"))) {

        // Do we show admins name?
        if ((self.admin.isStealthSession) && (reason == "admin_name")) {
            reason = "Admin decision";
        } else if (reason == "admin_name") {
            reason = self.admin.playerName + "'s decision";
        }

        player thread scripts\server\_adminCommands::banPlayer(self, reason);
        displayAdminCommandFeedback("@ROTUUI_PLR_BEING_BANNED");
    }
}


/**
 * @brief Remove one general warning for a player
 * @threaded on the admin player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
removeOneWarning(playerEntityNumber)
{
    debugPrint("in _adminInterface::removeOneWarning()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canRemovePlayerWarnings) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_REMOVE_WARNS");
        return;
    }

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "remove one warning"))) {
        player thread scripts\server\_adminCommands::removeOneWarning(self);
        displayAdminCommandFeedback("@ROTUUI_ONE_WARN_REMOVED");
    }
}


/**
 * @brief Remove one language warning for a player
 * @threaded on the admin player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
removeOneLanguageWarning(playerEntityNumber)
{
    debugPrint("in _adminInterface::removeOneLanguageWarning()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canRemovePlayerWarnings) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_REMOVE_WARNS");
        return;
    }

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "remove one language warning"))) {
        player thread scripts\server\_adminCommands::removeOneLanguageWarning(self);
        displayAdminCommandFeedback("@ROTUUI_ONE_LANG_WARN_REMOVED");
    }
}



/**
 * @brief Remove all warnings for a player
 * @threaded on the admin player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
removeAllWarnings(playerEntityNumber)
{
    debugPrint("in _adminInterface::removeAllWarnings()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canRemovePlayerWarnings) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_REMOVE_WARNS");
        return;
    }

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "remove all warnings"))) {
        player thread scripts\server\_adminCommands::removeAllWarnings(self);
        displayAdminCommandFeedback("@ROTUUI_ALL_WARNS_REMOVED");
    }
}


/**
 * @brief Demotes a player one rank, or 500 rank points, whichever is less
 * @threaded on the admin player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
demotePlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::demotePlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canRank) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_DEMOTE");
        return;
    }

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "demote player"))) {
        displayAdminCommandFeedback(player scripts\server\_adminCommands::demotePlayer(self));
    }
}


/**
 * @brief Promotes a player one rank, or 500 rank points, whichever is less
 * @threaded on the admin player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
promotePlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::promotePlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canRank) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_PROMOTE");
        return;
    }

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "promote player"))) {
        displayAdminCommandFeedback(player scripts\server\_adminCommands::promotePlayer(self));
    }
}


/**
 * @brief Restores a player's initial primary weapon
 * @threaded on the admin player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
restorePlayersPrimaryWeapon(playerEntityNumber)
{
    debugPrint("in _adminInterface::restorePlayersPrimaryWeapon()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canRestoreWeapons) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_RESTOREPRIMARY");
        return;
    }

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "restore primary weapon"))) {
        player thread scripts\server\_adminCommands::restorePlayersPrimaryWeapon(self);
        displayAdminCommandFeedback("@ROTUUI_RESTORED_PRIMARY_WEAPON");
    }
}


/**
 * @brief Restores a player's initial sidearm
 * @threaded on the admin player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
restorePlayersSidearm(playerEntityNumber)
{
    debugPrint("in _adminInterface::restorePlayersSidearm()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canRestoreWeapons) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_RESTORESIDEARM");
        return;
    }

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "restore sidearm"))) {
        player thread scripts\server\_adminCommands::restorePlayersSidearm(self);
        displayAdminCommandFeedback("@ROTUUI_RESTORED_SIDE_ARM");
    }
}


/**
 * @brief Gives a player upgrade points
 * @threaded on the admin player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
givePlayerUpgradePoints(playerEntityNumber)
{
    debugPrint("in _adminInterface::givePlayerUpgradePoints()", "fn", level.nonVerbose);

    // Bail if admin doesn't have this power
    if (!self.admin.canGiveUpgradePoints) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "give upgrade points"))) {
        player thread scripts\server\_adminCommands::givePlayerUpgradePoints(self);
        displayAdminCommandFeedback("@ROTUUI_GAVE_PLR_2K_UP");
    }
}


/**
 * @brief Kicks a player from this server
 * @threaded on the admin player
 *
 * @param playerEntityNumber integer The player's entity number
 * @param reason string The reason the player is being kicked
 *
 * @returns nothing
 */
kickPlayer(playerEntityNumber, reason)
{
    debugPrint("in _adminInterface::kickPlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canKickPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "kick"))) {

        // Do we show admins name?
        if ((self.admin.isStealthSession) && (reason == "admin_name")) {
            reason = "Admin decision";
        } else if (reason == "admin_name") {
            reason = self.admin.playerName + "'s decision";
        }

        player thread scripts\server\_adminCommands::kickPlayer(self, reason);
        displayAdminCommandFeedback("@ROTUUI_PLR_BEING_KICKED");
    }
}

/**
 * @brief Temporarily bans a player from this server
 *
 * @param playerEntityNumber integer The player's entity number
 * @param reason string The reason the player is being temp-banned
 *
 * @returns nothing
 */
temporarilyBanPlayer(playerEntityNumber, reason)
{
    debugPrint("in _adminInterface::temporarilyBanPlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canBanPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if ((isDefined(player)) && (!isLocked(player, self.admin.playerName, "temporary ban"))) {

        // Do we show admins name?
        if ((self.admin.isStealthSession) && (reason == "admin_name")) {
            reason = "Admin decision";
        } else if (reason == "admin_name") {
            reason = self.admin.playerName + "'s decision";
        }

        player thread scripts\server\_adminCommands::temporarilyBanPlayer(self, reason);
        displayAdminCommandFeedback("@ROTUUI_PLR_BEING_TEMPBANNED");
    }
}



/**
 * @brief Kills all zombies currently in the game
 *
 * @returns nothing
 */
killZombies()
{
    debugPrint("in _adminInterface::killZombies()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canKillZombies) {onNoPermissions(); return;}

    thread scripts\server\_adminCommands::killZombies(self);

    displayAdminCommandFeedback("@ROTUUI_ZOMBIES_KILLED");
}



/**
 * @brief Restarts the current game wave
 *
 * @returns nothing
 */
restartWave()
{
    debugPrint("in _adminInterface::restartWave()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canRestart) {onNoPermissions(); return;}

    thread scripts\server\_adminCommands::restartWave(self);

    displayAdminCommandFeedback("@ROTUSCRIPT_WAVE_RESTARTING"); // DO NOT CHANGE TO ROTUUI AS SAME STRING AND ALREADY PRECACHED.
}



/**
 * @brief Restarts the current map
 *
 * @returns nothing
 */
restartMap()
{
    debugPrint("in _adminInterface::restartMap()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canRestart) {onNoPermissions(); return;}

    adminActionConsoleMessage(self, "@ROTUUI_MAP_RESTARTING_IN3");
    displayAdminCommandFeedback("@ROTUUI_MAP_RESTARTING");
    wait 1.5;
    displayAdminCommandFeedback("@ROTUUI_EMPTY");  // clear feedback before actually restarting map

    thread scripts\server\_adminCommands::restartMap(self);
}



/**
 * @brief Finishes the current game wave
 *
 * @returns nothing
 */
finishWave()
{
    debugPrint("in _adminInterface::finishWave()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canFinish) {onNoPermissions(); return;}

    thread scripts\server\_adminCommands::finishWave(self);

    displayAdminCommandFeedback("@ROTUUI_WAVE_FINISHED");
}



/**
 * @brief Finishes the current map
 *
 * @returns nothing
 */
finishMap()
{
    debugPrint("in _adminInterface::finishMap()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canFinish) {onNoPermissions(); return;}

    thread scripts\server\_adminCommands::finishMap(self);
    displayAdminCommandFeedback("@ROTUUI_MAP_FINISHED");
}



/**
 * @brief Changes to the specified map
 *
 * @param string the full name of the map to change to
 *
 * @returns nothing
 */
changeMap()
{
    debugPrint("in _adminInterface::changeMap()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canChangeMap) {onNoPermissions(); return;}

    displayAdminCommandFeedback("@ROTUUI_MAP_BEING_CHANGED");
    wait 2;
    // clear the properties and unlock the command, just in case map chnaging fails
    onCancelChangeMap();
    displayAdminCommandFeedback("@ROTUSCRIPT_EMPTY"); // DO NOT CHANGE TO ROTUUI AS ALREADY PRECACHED AND IN USE.
    thread scripts\server\_adminCommands::changeMap(self, level.changeMapNewMap);
}

/**
 * @brief Filters the list of maps according to the current filter
 *
 * @returns nothing
 */
applyMapFilter()
{
    debugPrint("in _adminInterface::applyMapFilter()", "fn", level.lowVerbosity);

    if(!isDefined(level.changeMapFilter)) {level.changeMapFilter = "";}

    // update filter text on-screen
    self setClientDvar("admin_changemap_filter", level.changeMapFilter);

    // apply the filter
    filteredMaps = filterMaps(level.changeMapFilter);

    // set the new map, as appropriate
    if (filteredMaps.size == 1) {
        level.changeMapNewMap = filteredMaps[0].name;
    } else {level.changeMapNewMap = "";}

    // enable the accept map button, as appropriate
    self setClientDvar("filterResultCount", filteredMaps.size);
    self buildFilteredMapsString(filteredMaps);
}

/**
 * @brief Initializes the map filter, or aborts if another admin is already trying to change the map
 *
 * @returns nothing
 */
onOpenChangeMap()
{
    debugPrint("in _adminInterface::onOpenChangeMap()", "fn", level.lowVerbosity);

    if(!isDefined(level.changeMapLockedBy)) {level.changeMapLockedBy = "";}

    if (level.changeMapLockedBy == "") {
        // lock change map, continue
        level.changeMapLockedBy = self.name;
        applyMapFilter();
    } else {
        // change map is locked, abort
        self closeMenu();
        displayAdminCommandFeedback("@ROTUUI_CHANGE_MAP_LOCKED");
    }
}

/**
 * @brief Unlocks the change map command when the admin cancels the command
 *
 * @returns nothing
 */
onCancelChangeMap()
{
    debugPrint("in _adminInterface::onCancelChangeMap()", "fn", level.lowVerbosity);

    level.changeMapFilter = "";
    self setClientDvar("admin_changemap_filter", level.changeMapFilter);
    level.changeMapLockedBy = ""; // unlock the change map command
}

/**
 * @brief Updates the filtered maps when a new character is added to the filter
 *
 * @param character string The character that is to be added to the filter
 *
 * @returns nothing
 */
changeMapUpdateFilter(character)
{
    debugPrint("in _adminInterface::changeMapUpdateFilter()", "fn", level.lowVerbosity);

    level.changeMapFilter += character;
    applyMapFilter();
}

/**
 * @brief Removes the last character added to the filter, the updates the filter results
 *
 * @returns nothing
 */
changeMapFilterBackspace()
{
    debugPrint("in _adminInterface::changeMapFilterBackspace()", "fn", level.lowVerbosity);

    newFilter = "";
    for (i=0; i<level.changeMapFilter.size - 1; i++) {
        newFilter += level.changeMapFilter[i];
    }
    level.changeMapFilter = newFilter;
    applyMapFilter();
}

/**
 * @brief Builds and displays the filtered maps to the admin
 * We have limited room on the screen, so we allow for the matching maps to be
 * truncated.  Also, there is a character limit for a single hud element, so we
 * use three hud elements, and split the matching maps into these three elements.
 *
 * @param maps struct A struct containing the information on the matching maps
 *
 * @returns nothing
 */
buildFilteredMapsString(maps)
{
    debugPrint("in _adminInterface::buildFilteredMapsString()", "fn", level.lowVerbosity);

    tokens = [];
    for (i=0; i<maps.size; i++) {
        tokens[i] = maps[i].filterString;
    }

    results = [];
    resultsIndex = 0;
    lines = 0;
    results[resultsIndex] = tokens[0];
    lines++;
    if (tokens.size > 1) {
        for (i=1; i<tokens.size; i++) {
            if ((resultsIndex == 2) && (results[resultsIndex].size + 2 + tokens[i].size > 160)) {
                // truncate results, since we can't display them all
                results[resultsIndex] += "\n^1--RESULTS TRUNCATED--";
                break;
            } else if ((results[resultsIndex].size + 2 + tokens[i].size > 260) || (lines == 9)){
                // adding this token will overflow the string for the current dvar
                resultsIndex++;
                results[resultsIndex] = tokens[i];
                lines = 1;
            } else {
                results[resultsIndex] += "\n" + tokens[i];
                lines++;
            }
        }
    }

    // clear the old filter results
    self setClientDvar("admin_matching_maps1", "");
    self setClientDvar("admin_matching_maps2", "");
    self setClientDvar("admin_matching_maps3", "");

    // set the new results as required
    if (results.size >= 1) {self setClientDvar("admin_matching_maps1", results[0]);}
    if (results.size >= 2) {self setClientDvar("admin_matching_maps2", results[1]);}
    if (results.size >= 3) {self setClientDvar("admin_matching_maps3", results[2]);}
}

/**
 * @brief Filters the available maps that don't match \c filter
 *
 * @param filter string The substring to search for
 *
 * @returns the maps that were matched
 */
filterMaps(filter)
{
    debugPrint("in _adminInterface::filterMaps()", "fn", level.lowVerbosity);

    debugPrint("Filtering maps for " + filter, "val");
    filteredMaps = [];
    index = 0;
    for (i=0; i<level.mapList.size; i++) {
        search = level.mapList[i].lcFilterString;
        if (issubstr(search, filter)) {
            filteredMaps[index] = level.mapList[i];
            index++;
        }
    }
    return filteredMaps;
}


/**
 * @brief Forces a player to drop their current weapon
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
dropPlayerWeapon(playerEntityNumber)
{
    debugPrint("in _adminInterface::dropPlayerWeapon()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canDropPlayerWeapon) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_DROP");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_DROP");
        return;
    }

    if ((isDefined(player)) &&
        (player.isAlive) &&
        (!isLocked(player, self.admin.playerName, "drop weapon")))
    {
        if (player thread scripts\server\_adminCommands::dropPlayerWeapon(self)) {
            displayAdminCommandFeedback("@ROTUUI_WEAPON_DROPPED");
        } else {
            displayAdminCommandFeedback("@ROTUUI_WEAPON_NOT_DROPPED_NO_AMMO");
        }
    }
}


/**
 * @brief Toggles showing/hiding admin status this admin session
 *
 * @returns nothing
 */
toggleAdminSessionVisibility()
{
    debugPrint("in _adminInterface::toggleAdminSessionVisibility()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.isAdmin) {onNoPermissions(); return;}

    if (self.admin.isStealthSession) {showAdminSession();}
    else {hideAdminSession();}
}


/**
 * @brief Shows admin status this admin session
 *
 * @returns nothing
 */
showAdminSession()
{
    debugPrint("in _adminInterface::showAdminSession()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.isAdmin) {onNoPermissions(); return;}

    self.admin.isStealthSession = 0;
    self.admin.informPlayerOfAdminActions = 1;
    self.admin.showActionConsoleMessages = 1;
    self.admin.visibilityState = "@ROTUUI_VISIBLE"; // green text

    // Set admin head icon, but do not override infected and low hit points head icons
    if ((self.headicon != "icon_infected") &&
        (self.headicon != "hud_icon_lowhp") &&
        (self.headicon != "headicon_medhp"))
    {
        self.headicon = "headicon_admin";
    }

    if ((self.sessionstate == "playing") || (self.sessionstate == "dead")) {
        self.statusicon = "icon_admin";
    } else if (self.isDown){self.statusicon = "icon_down";} // down
    else {self.statusicon = "icon_spec";}                   // spectating

    self setClientDvar("admin_visibility", self.admin.visibilityState);

    displayAdminCommandFeedback("@ROTUUI_SESSION_VISIBLE");
}



/**
 * @brief Hides admin status this admin session
 *
 * @returns nothing
 */
hideAdminSession()
{
    debugPrint("in _adminInterface::hideAdminSession()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.isAdmin) {onNoPermissions(); return;}

    self.admin.isStealthSession = 1;
    self.admin.informPlayerOfAdminActions = 0;
    self.admin.showActionConsoleMessages = 0;
    self.admin.visibilityState = "@ROTUSCRIPT_VISIBILITY_HIDDEN"; // red text, DO NOT CHANGE TO ROTUUI AS ALREADY IN USE SOMEWHERE AND PRECACHED.
    self setClientDvar("admin_visibility", self.admin.visibilityState);

    // remove icons as required
    self scripts\players\_players::defaultHeadicon();

    if ((self.sessionstate == "playing") || (self.sessionstate == "dead")) {
        self.statusicon = "";
    } else if (self.isDown){self.statusicon = "icon_down";} // down
    else {self.statusicon = "icon_spec";}                   // spectating

    displayAdminCommandFeedback("@ROTUUI_SESSION_HIDDEN");
}


/**
 * @brief Drops an ammo can near the player
 *
 * @param playerEntityNumber The number of the player
 *
 * @returns nothing
 */
ammoBox(playerEntityNumber)
{
    debugPrint("in _adminInterface::ammoBox()", "fn", level.nonVerbose);

    // Bail if admin doesn't have this power
    if (!self.admin.canAmmoBox) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_AMMOBOX");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_AMMOBOX");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "ammo box")))
    {
        player thread scripts\server\_adminCommands::ammoBox(self);
        displayAdminCommandFeedback("@ROTUUI_AMMOBOX_DROPPED");
    }
}


/**
 * @brief Starts a healing aura at the player's position
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
healingAura(playerEntityNumber)
{
    debugPrint("in _adminInterface::healingAura()", "fn", level.nonVerbose);

    // Bail if admin doesn't have this power
    if (!self.admin.canHealingAura) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_HEALINGAURA");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_HEALINGAURA");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "healing aura")))
    {
        player thread scripts\server\_adminCommands::healingAura(self);
        displayAdminCommandFeedback("@ROTUUI_HEALING_AURA_PLACED");
    }
}


/**
 * @brief Gives admin private feedback that they executed a command
 *
 * @param message The message to display.
 *
 * @returns nothing
 */
displayAdminCommandFeedback(message)
{
    debugPrint("in _adminInterface::displayAdminCommandFeedback()", "fn", level.nonVerbose);

    msg = "^5" + message; // cyan text
    self thread ACPNotify(msg, 3);
}



/**
 * @brief Takes all of a player's weapons
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
disarmPlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::disarmPlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canDisarmPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_DISARM");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_DISARM");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "disarm")))
    {
        player thread scripts\server\_adminCommands::disarmPlayer(self);
        displayAdminCommandFeedback("@ROTUUI_PLR_DISARMED");
    }
}



/**
 * @brief Takes a player's current weapon
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
takePlayersCurrentWeapon(playerEntityNumber)
{
    debugPrint("in _adminInterface::takePlayersCurrentWeapon()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canTakePlayerWeapon) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_TAKEWEAP");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_TAKEWEAP");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "take current weapon")))
    {
        player thread scripts\server\_adminCommands::takePlayersCurrentWeapon(self);
        displayAdminCommandFeedback("@ROTUUI_WEAP_TAKEN");
    }
}


/**
 * @brief Restores a player's health
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
healPlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::healPlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canHealPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_HEAL");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_HEAL");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "heal")))
    {
        player thread scripts\server\_adminCommands::healPlayer(self);
        displayAdminCommandFeedback("@ROTUUI_PLR_HEALED");
    }
}



/**
 * @brief Cures a player's infection
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
curePlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::curePlayer()", "fn", level.nonVerbose);

    // Bail if admin doesn't have this power
    if (!self.admin.canCurePlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_CURE");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_CURE");
        return;
    } else if (!player.infected) {
        displayAdminCommandFeedback("@ROTUUI_PLR_CURED_CANT_CURE");
        return;
    }

    // Player locking should be the *last* boolean test, so we don't lock a player
    // and then wind bailing on the function!
    if ((isDefined(player)) &&
        (player.isAlive) &&
        (player.infected) &&
        (!isLocked(player, self.admin.playerName, "cure")))
    {
        player thread scripts\server\_adminCommands::curePlayer(self);
        displayAdminCommandFeedback("@ROTUUI_PLR_CURED");
    }
}


/**
 * @brief Spawns a player if they are a spectator
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
spawnPlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::spawnPlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canSpawnPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_SPAWN");
        return;
    } else if (player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_ALIVE_CANT_SPAWN");
        return;
    }

    if((isDefined(player)) &&
       (!player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "spawn")))
    {
        if (player thread scripts\server\_adminCommands::spawnPlayer(self)) {
            displayAdminCommandFeedback("@ROTUUI_PLR_SPAWNED");
        } else {
            displayAdminCommandFeedback("@ROTUUI_PLR_NOT_SPAWNED");
        }
    }
}

/**
 * @brief Bounces a player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
bouncePlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::bouncePlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canBouncePlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_BOUNCE");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_BOUNCE");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "bounce")))
    {
        player thread scripts\server\_adminCommands::bouncePlayer(self);
        displayAdminCommandFeedback("@ROTUUI_PLR_BOUNCED");
    }
}

/**
 * @brief Teleports a player to the spawn point
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
teleportPlayerToSpawn(playerEntityNumber)
{
    debugPrint("in _adminInterface::teleportPlayerToSpawn()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canTeleportPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_TELEPORT");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_TELEPORT");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "teleport to spawn")))
    {
        player thread scripts\server\_adminCommands::teleportPlayerToSpawn(self);
        displayAdminCommandFeedback("@ROTUUI_PLR_TELEPORTED");
    }
}

/**
 * @brief Teleports a player to the admin's location
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
teleportPlayerToAdmin(playerEntityNumber)
{
    debugPrint("in _adminInterface::teleportPlayerToAdmin()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canTeleportPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_TELEPORT");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_TELEPORT");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "teleport to admin")))
    {
        player thread scripts\server\_adminCommands::teleportPlayerToAdmin(self.origin, self);
        displayAdminCommandFeedback("@ROTUUI_PLR_TELEPORTED");
    }
}

/**
 * @brief Teleports a player forward about 3 feet
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
teleportPlayerForward(playerEntityNumber)
{
    debugPrint("in _adminInterface::teleportPlayerForward()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canTeleportPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_TELEPORT");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_TELEPORT");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "teleport forward")))
    {
        player thread scripts\server\_adminCommands::teleportPlayerForward(self);
        displayAdminCommandFeedback("@ROTUUI_PLR_TELEPORTED");
    }
}

/**
 * @brief Downs a player, but they can still be revived
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 * @TODO DONT DOWN DOWNED PLAYER
 */
downPlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::downPlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canDownPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_DOWN");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_DOWN");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "down")))
    {
        player thread scripts\server\_adminCommands::downPlayer(self);
        displayAdminCommandFeedback("@ROTUUI_PLR_DOWNED");
    }
}

/**
 * @brief Revives a player
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
revivePlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::revivePlayer()", "fn", level.nonVerbose);

    // Bail if admin doesn't have this power
    if (!self.admin.canRevivePlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_REVIVE");
        return;
    } else if (player.isZombie) {
        displayAdminCommandFeedback("@ROTUUI_PLR_ZOM_CANT_REVIVE");
        return;
    } else if (player.isDown && player.infected) {
        displayAdminCommandFeedback("@ROTUUI_PLR_INFECTED_CANT_REVIVE");
        return;
    } else if (!player.isDown) {
        displayAdminCommandFeedback("@ROTUUI_PLR_ALIVE_CANT_REVIVE");
        return;
    }

    if ((isDefined(player)) &&
        (player.isDown) &&
        (!player.infected) &&
        (!player.isZombie) &&
        (!isLocked(player, self.admin.playerName, "revive")))
    {
            player thread scripts\server\_adminCommands::revivePlayer(self);
            displayAdminCommandFeedback("@ROTUUI_PLR_REVIVED");
    }
}

/**
 * @brief Kills a player, and they cannot be revived
 *
 * @param playerEntityNumber integer The player's entity number
 *
 * @returns nothing
 */
explodePlayer(playerEntityNumber)
{
    debugPrint("in _adminInterface::explodePlayer()", "fn", level.lowVerbosity);

    // Bail if admin doesn't have this power
    if (!self.admin.canBoomPlayer) {onNoPermissions(); return;}

    player = getPlayerByEntityNumber(playerEntityNumber);

    if (!isDefined(player)) {
        displayAdminCommandFeedback("@ROTUUI_PLR_UNDEFINED_CANT_EXPLODE");
        return;
    } else if (!player.isAlive) {
        displayAdminCommandFeedback("@ROTUUI_PLR_DEAD_CANT_EXPLODE");
        return;
    }

    if((isDefined(player)) &&
       (player.isAlive) &&
       (!isLocked(player, self.admin.playerName, "explode")))
    {
        player thread scripts\server\_adminCommands::explodePlayer(self);
        displayAdminCommandFeedback("@ROTUUI_PLR_EXPLODED");
    }
}
