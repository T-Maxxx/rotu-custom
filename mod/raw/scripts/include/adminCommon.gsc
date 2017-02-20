/* Localized. Partly? */
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

precache()
{
    debugPrint("in adminCommon::precache()", "fn", level.nonVerbose);

    // Precache effects for medkits & healing aura
    level.heal_glow_body        = loadfx( "misc/heal_glow_body");
    level.heal_glow_effect      = loadfx( "misc/heal_glow");
    level.healingEffect         = loadfx( "misc/healing" );

    level.fx["bombexplosion"] = loadfx( "explosions/tanker_explosion" );

    // Used for Boom
    level.fx["boom"] = loadfx("explosions/pyromaniac");

    precacheMenu("admin");
    precacheMenu("admin_kick");
    precacheMenu("admin_ban");
    precacheMenu("admin_temp_ban");
    precacheMenu("admin_warn");
    precacheMenu("admin_changemap");

    precacheString(&"ROTUSCRIPT_VISIBILITY_HIDDEN");
    precacheString(&"ROTUSCRIPT_ADMINACTIONCONSOLEMSG");
    precacheString(&"ROTUSCRIPT_INFORM_ALL_FORMAT");
    precacheString(&"ROTUSCRIPT_INFORM_PLR_FORMAT");

    precacheString(&"ROTUSCRIPT_GOT_WARNED_ON_THIS_SERVER");
    precacheString(&"ROTUSCRIPT_ONE_WARNING_WAS_REMOVED");
    precacheString(&"ROTUSCRIPT_ADMIN_REMOVED_WARNING");
    precacheString(&"ROTUSCRIPT_ADMIN_REMOVED_ONE_LANGUAGE_WARN_FROM_YOU");
    precacheString(&"ROTUSCRIPT_ONE_LANG_WARNING_WAS_REMOVED");
    precacheString(&"ROTUSCRIPT_ADMIN_REMOVED_ALL_WARNS_FROM_YOU");
    precacheString(&"ROTUSCRIPT_ALL_WARNS_WAS_REMOVED");
    precacheString(&"ROTUSCRIPT_ADMIN_TOOK_750_RANKPTS_FROM_YOU");
    precacheString(&"ROTUSCRIPT_DEMOTED");
    precacheString(&"ROTUSCRIPT_750_RANKPTS_WAS_TAKEN");
    precacheString(&"ROTUSCRIPT_ADMIN_PROMOTED_YOU");
    precacheString(&"ROTUSCRIPT_PROMOTED");
    precacheString(&"ROTUSCRIPT_ADMIN_GAVE_750RANKPTS_TO_YOU");
    precacheString(&"ROTUSCRIPT_ADMIN_GAVE_750RANKPTS");
    precacheString(&"ROTUSCRIPT_ADMIN_RESTORED_YOUR_DEF_PRIM_WEAP");
    precacheString(&"ROTUSCRIPT_RESTORED_PRIM_WEAP");
    precacheString(&"ROTUSCRIPT_ADMIN_RESTORED_YOUR_DEF_SIDEARM");
    precacheString(&"ROTUSCRIPT_RESTORED_SIDEARM");
    precacheString(&"ROTUSCRIPT_ADMIN_GAVE_YOU_2K_UP");
    precacheString(&"ROTUSCRIPT_ADMIN_GAVE_2K_UP");
    precacheString(&"ROTUSCRIPT_GOT_BANNED");
    precacheString(&"ROTUSCRIPT_GOT_KICKED");
    precacheString(&"ROTUSCRIPT_GOT_TEMPBANNED");
    precacheString(&"ROTUSCRIPT_ADMIN_KILLED_ZOMBIES");
    precacheString(&"ROTUSCRIPT_WAVE_RESTARTING");
    precacheString(&"ROTUSCRIPT_ADMIN_MADE_YOU_DROP_WEAPON");
    precacheString(&"ROTUSCRIPT_DROPPED_THEIR_WEAPON");
    precacheString(&"ROTUSCRIPT_ADMIN_PLACED_AMMOBOX_NEAR");
    precacheString(&"ROTUSCRIPT_AMMOBOX_HAS_BEEN_PLACED_NEAR");
    precacheString(&"ROTUSCRIPT_ADMIN_PLACED_HEALING_AURA_NEAR");
    precacheString(&"ROTUSCRIPT_HEALING_AURA_PLACED_NEAR");
    precacheString(&"ROTUSCRIPT_YOU_WERE_DISARMED");
    precacheString(&"ROTUSCRIPT_DISARMED");
    precacheString(&"ROTUSCRIPT_ADMIN_TOOK_YOUR_WEAPON");
    precacheString(&"ROTUSCRIPT_WEAPON_TAKEN");
    precacheString(&"ROTUSCRIPT_HEALTH_RESTORED_BY_ADMIN");
    precacheString(&"ROTUSCRIPT_HEALTH_RESTORED");
    precacheString(&"ROTUSCRIPT_INFECTION_CURED_BY_ADMIN");
    precacheString(&"ROTUSCRIPT_CURED");
    precacheString(&"ROTUSCRIPT_YOU_SPAWNED_BY_ADMIN");
    precacheString(&"ROTUSCRIPT_SPAWNED");
    precacheString(&"ROTUSCRIPT_CANT_SPAWN_NONSPECTATOR");
    precacheString(&"ROTUSCRIPT_YOU_BOUNCED_BY_ADMIN");
    precacheString(&"ROTUSCRIPT_BOUNCED");
    precacheString(&"ROTUSCRIPT_YOU_TELEPORTED_BY_ADMIN");
    precacheString(&"ROTUSCRIPT_WAS_TELEPORTED_TO_SPAWNPOINT");
    precacheString(&"ROTUSCRIPT_WAS_TELEPORTED_TO_ADMIN");
    precacheString(&"ROTUSCRIPT_WAS_TELEPORTED_FORWARD");
    precacheString(&"ROTUSCRIPT_YOU_DOWNED_BY_ADMIN");
    precacheString(&"ROTUSCRIPT_DOWNED");
    precacheString(&"ROTUSCRIPT_YOU_REVIVED_BY_ADMIN");
    precacheString(&"ROTUSCRIPT_REVIVED");
    precacheString(&"ROTUSCRIPT_YOU_EXPLODED_BY_ADMIN");
    precacheString(&"ROTUSCRIPT_EXPLODED");
}

/**
 * @brief Parses the admin data from admin.cfg into admin data structures
 *
 * @returns nothing
 */
buildAdminData()
{
    debugPrint("in adminCommon::buildAdminData()", "fn", level.nonVerbose);

    // Build data structures for known admins
    i = 0;
    level.admins = [];
    while (1) {
        admin = getDvar("admin_guid_admin" + (i+1));
        if (admin == "") {break;}
        level.admins[i] = newAdmin(i+1);
        i++;
    }
    level.rconAdmin = rconAdmin();
    level.admins[level.admins.size] = level.rconAdmin;

    level.adminMenuGodModeTimeout = getDvarInt("admin_menu_god_mode_timeout");
    if ((!isDefined(level.adminMenuGodModeTimeout)) ||
        (level.adminMenuGodModeTimeout < 1) ||
        (level.adminMenuGodModeTimeout > 300))
    {level.adminMenuGodModeTimeout = 2;}

    level.badLanguageWarningTempBanThreshold = getDvarInt("admin_bad_language_warning_temp_ban_threshold");
    level.badLanguageWarningBanThreshold = getDvarInt("admin_bad_language_warning_ban_threshold");
    level.generalWarningTempBanThreshold = getDvarInt("admin_general_warning_temp_ban_threshold");
    level.generalWarningBanThreshold = getDvarInt("admin_general_warning_ban_threshold");
}

/**
 * @brief Creates an admin data structure for rcon
 *
 * @returns struct The admin struct for this admin
 */
rconAdmin()
{
    debugPrint("in adminCommon::rconAdmin()", "fn", level.nonVerbose);

    // Declare and initialize a new admin struct
    admin = spawnStruct();
    admin.canBoomPlayer = 1;
    admin.canFinish = 1;
    admin.canRestart = 1;
    admin.canKillZombies = 1;
    admin.canChangeMap = 1;

    admin.informPlayerOfAdminActions = 1;
    admin.showActionConsoleMessages = 1;

    admin.name = "RCON Admin";
    admin.guid = "ahydelwu"; // fake guid for rcon admin
    admin.isAdmin = true;

    return admin;
}

/**
 * @brief Creates an admin data structure for this admin
 *
 * @param adminConfigId integer The ID of the admin in the admin.cfg file
 *
 * @returns struct The admin struct for this admin
 */
newAdmin(adminConfigId)
{
    debugPrint("in adminCommon::newAdmin()", "fn", level.nonVerbose);

    // Declare and initialize a new admin struct
    admin = spawnStruct();
    admin.guid = getDvar("admin_guid_admin" + adminConfigId);

    // N.B. superAdmin isn't a real power, just a convenient way of setting powers
    admin.superAdmin = getDvarInt("admin_superAdmin_admin" + adminConfigId);

    // First: if superAdmin, initially give all powers, else initially give no powers
    if (admin.superAdmin){
        admin.canConnectToRcon = 1;
        admin.canDownPlayer = 1;
        admin.canBoomPlayer = 1;
        admin.canSpawnPlayer = 1;
        admin.canWarnPlayer = 1;
        admin.canKickPlayer = 1;
        admin.canBanPlayer = 1;
        admin.canBouncePlayer = 1;
        admin.canRemovePlayerWarnings = 1;
        admin.canHealPlayer = 1;
        admin.canCurePlayer = 1;
        admin.canHealingAura = 1;
        admin.canRevivePlayer = 1;
        admin.canTeleportPlayer = 1;
        admin.canDropPlayerWeapon = 1;
        admin.canTakePlayerWeapon = 1;
        admin.canDisarmPlayer = 1;
        admin.canFinish = 1;
        admin.canRestart = 1;
        admin.canKillZombies = 1;
        admin.canChangeMap = 1;
        admin.canAmmoBox = 1;
        admin.canRank = 1;
        admin.canRestoreWeapons = 1;
        admin.canGiveUpgradePoints = 1;
    } else {
//         debugPrint("is not superAdmin", "val");
        admin.canConnectToRcon = 0;
        admin.canDownPlayer = 0;
        admin.canBoomPlayer = 0;
        admin.canSpawnPlayer = 0;
        admin.canWarnPlayer = 0;
        admin.canKickPlayer = 0;
        admin.canBanPlayer = 0;
        admin.canBouncePlayer = 0;
        admin.canRemovePlayerWarnings = 0;
        admin.canHealPlayer = 0;
        admin.canCurePlayer = 0;
        admin.canHealingAura = 0;
        admin.canRevivePlayer = 0;
        admin.canTeleportPlayer = 0;
        admin.canDropPlayerWeapon = 0;
        admin.canTakePlayerWeapon = 0;
        admin.canDisarmPlayer = 0;
        admin.canFinish = 0;
        admin.canRestart = 0;
        admin.canKillZombies = 0;
        admin.canChangeMap = 0;
        admin.canAmmoBox = 0;
        admin.canRank = 0;
        admin.canRestoreWeapons = 0;
        admin.canGiveUpgradePoints = 0;
    }

    // Second: Now apply any individual power grants/revocations from the server config
    if (getDvar("admin_canConnectToRcon_admin" + adminConfigId) != "") {
        admin.canConnectToRcon = getDvarInt("admin_canConnectToRcon_admin" + adminConfigId);
    }
    if (getDvar("admin_canDownPlayer_admin" + adminConfigId) != "") {
        admin.canDownPlayer = getDvarInt("admin_canDownPlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canBoomPlayer_admin" + adminConfigId) != "") {
        admin.canBoomPlayer = getDvarInt("admin_canBoomPlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canSpawnPlayer_admin" + adminConfigId) != "") {
        admin.canSpawnPlayer = getDvarInt("admin_canSpawnPlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canWarnPlayer_admin" + adminConfigId) != "") {
        admin.canWarnPlayer = getDvarInt("admin_canWarnPlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canKickPlayer_admin" + adminConfigId) != "") {
        admin.canKickPlayer = getDvarInt("admin_canKickPlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canBanPlayer_admin" + adminConfigId) != "") {
        admin.canBanPlayer = getDvarInt("admin_canBanPlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canBouncePlayer_admin" + adminConfigId) != "") {
        admin.canBouncePlayer = getDvarInt("admin_canBouncePlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canRemovePlayerWarnings_admin" + adminConfigId) != "") {
        admin.canRemovePlayerWarnings = getDvarInt("admin_canRemovePlayerWarnings_admin" + adminConfigId);
    }
    if (getDvar("admin_canHealPlayer_admin" + adminConfigId) != "") {
        admin.canHealPlayer = getDvarInt("admin_canHealPlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canCurePlayer_admin" + adminConfigId) != "") {
        admin.canCurePlayer = getDvarInt("admin_canCurePlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canHealingAura_admin" + adminConfigId) != "") {
        admin.canHealingAura = getDvarInt("admin_canHealingAura_admin" + adminConfigId);
    }
    if (getDvar("admin_canRevivePlayer_admin" + adminConfigId) != "") {
        admin.canRevivePlayer = getDvarInt("admin_canRevivePlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canTeleportPlayer_admin" + adminConfigId) != "") {
        admin.canTeleportPlayer = getDvarInt("admin_canTeleportPlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canDropPlayerWeapon_admin" + adminConfigId) != "") {
        admin.canDropPlayerWeapon = getDvarInt("admin_canDropPlayerWeapon_admin" + adminConfigId);
    }
    if (getDvar("admin_canTakePlayerWeapon_admin" + adminConfigId) != "") {
        admin.canTakePlayerWeapon = getDvarInt("admin_canTakePlayerWeapon_admin" + adminConfigId);
    }
    if (getDvar("admin_canDisarmPlayer_admin" + adminConfigId) != "") {
        admin.canDisarmPlayer = getDvarInt("admin_canDisarmPlayer_admin" + adminConfigId);
    }
    if (getDvar("admin_canFinish_admin" + adminConfigId) != "") {
        admin.canFinish = getDvarInt("admin_canFinish_admin" + adminConfigId);
    }
    if (getDvar("admin_canRestart_admin" + adminConfigId) != "") {
        admin.canRestart = getDvarInt("admin_canRestart_admin" + adminConfigId);
    }
    if (getDvar("admin_canKillZombies_admin" + adminConfigId) != "") {
        admin.canKillZombies = getDvarInt("admin_canKillZombies_admin" + adminConfigId);
    }
    if (getDvar("admin_canChangeMap_admin" + adminConfigId) != "") {
        admin.canChangeMap = getDvarInt("admin_canChangeMap_admin" + adminConfigId);
    }
    if (getDvar("admin_canAmmoBox_admin" + adminConfigId) != "") {
        admin.canAmmoBox = getDvarInt("admin_canAmmoBox_admin" + adminConfigId);
    }
    if (getDvar("admin_canRank_admin" + adminConfigId) != "") {
        admin.canRank = getDvarInt("admin_canRank_admin" + adminConfigId);
    }
    if (getDvar("admin_canRestoreWeapons_admin" + adminConfigId) != "") {
        admin.canRestoreWeapons = getDvarInt("admin_canRestoreWeapons_admin" + adminConfigId);
    }
    if (getDvar("admin_canGiveUpgradePoints_admin" + adminConfigId) != "") {
        admin.canGiveUpgradePoints = getDvarInt("admin_canGiveUpgradePoints_admin" + adminConfigId);
    }

    // Default to stealth admin sessions
    admin.isStealthSession = 1;
    admin.informPlayerOfAdminActions = 0;
    admin.showActionConsoleMessages = 0;
    admin.visibilityState = &"ROTUSCRIPT_VISIBILITY_HIDDEN";
    admin.isAdminMenuDirty = false;


    // Build ui permissions string
    text = "";
    hasPermissionColor = "^2"; // green
    noPermissionColor = "^1";  // red

    if (admin.canConnectToRcon)         {color = hasPermissionColor;} else {color = noPermissionColor;}
    text  = color + "RCON;";
    if (admin.canDownPlayer)            {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Down;";
    if (admin.canBoomPlayer)            {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Boom;";
    if (admin.canSpawnPlayer)           {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Spawn;";
    if (admin.canWarnPlayer)            {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Warn;";
    if (admin.canKickPlayer)            {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Kick;";
    if (admin.canBanPlayer)             {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Ban;";
    if (admin.canBouncePlayer)          {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Bounce;";
    if (admin.canRemovePlayerWarnings)  {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Remove Warnings;";
    if (admin.canHealPlayer)            {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Heal;";
    if (admin.canCurePlayer)            {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Cure;";
    if (admin.canHealingAura)           {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Healing Aura;";
    if (admin.canRevivePlayer)          {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Revive;";
    if (admin.canTeleportPlayer)        {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Teleport;";
    if (admin.canDropPlayerWeapon)      {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Drop Weapon;";
    if (admin.canTakePlayerWeapon)      {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Take Weapon;";
    if (admin.canDisarmPlayer)          {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Disarm;";
    if (admin.canFinish)                {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Finish;";
    if (admin.canRestart)               {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Restart;";
    if (admin.canKillZombies)           {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Kill Zombies;";
    if (admin.canChangeMap)             {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Change Map;";
    if (admin.canAmmoBox)               {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Ammo Box;";
    if (admin.canRank)                  {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Promote & Demote;";
    if (admin.canRestoreWeapons)        {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Restore Weapons;";
    if (admin.canGiveUpgradePoints)     {color = hasPermissionColor;} else {color = noPermissionColor;}
    text += color + "Upgrade Points;";

    /**
     * Since we don't have access to font metrics, we cannot wrap by character
     * length since the characters have varying widths.  The only solution is to
     * hard-code the wrapping, which creates a dependency of the order the
     * permissions are added to the @c text string above.  So, if the order of
     * the @c text string is changed, we will need to adjust this wrapping code.
     */
    tokens = StrTok(text, ";");
    text = "";
    line = "";

    // The token indexes to wrap after: change this block to change wrapping
    wrapToken1 = 7;
    wrapToken2 = 13;//11;
    wrapToken3 = 18;//16;
    wrapToken4 = 22;

    separator = ", ";
    lineCount = 0;

    for(i=0; i<tokens.size;i++) {

        // middle of a line
        if ((i < wrapToken1) ||
            ((i > wrapToken1) && (i < wrapToken2)) ||
            ((i > wrapToken2) && (i < wrapToken3)) ||
            ((i > wrapToken3) && (i < wrapToken4)) ||
            ((i > wrapToken4) && (i < tokens.size - 1)))
        {
            line += tokens[i] + separator;
        }
        // end of a line
        else if ((i == wrapToken1) ||
                 (i == wrapToken2) ||
                 (i == wrapToken3) ||
                 (i == wrapToken4))
        {
            line += tokens[i] + "\n";
            text += line;
            lineCount++;
            if (lineCount == 3) {
                admin.permissionsText = text;
                text = "";
            }
            line = "";
        }
        // last token
        else if (i == tokens.size - 1)
        {
            line += tokens[i];
            text += line;
            line = "";
        }
    }
    admin.permissionsText1 = text;

    return admin;
} // End function newAdmin()


/**
 * @brief Checks to see if a player is an admin when they connect
 *
 * @returns nothing
 */
onPlayerConnect()
{
    debugPrint("in adminCommon::onPlayerConnect()", "fn", level.nonVerbose);

    while (1) {
        level waittill( "connected", player );

        player.isAdmin = false;

        guid = getSubStr(player getGuid(), 24, 32);
        debugPrint("connecting guid: " + guid, "val");
        debugPrint("dedicated: " + getDvar("dedicated"), "val");

        // force admin guid if required
        if (level.dedicated == "listen server") {
            // getGuid() returns garbage if a listen server, so force admin
            guid = getDvar("admin_forced_guid");
            debugPrint("Listen server: Host player's guid forced to " + guid, "val");
        } else if (level.dedicated == "dedicated LAN server") {
            // Do nothing
        } else if (level.dedicated == "dedicated internet server") {
            // Do nothing
        }

        player.shortGuid = guid;

        /// @todo just for testing new prestige levels
//         if (player.shortGuid == "") {
//             player scripts\players\_rank::setPrestige(55);
//         }

        // Is the connecting player an admin?
        for (i=0; i< self.admins.size; i++) {
            admin = self.admins[i];
            if (admin.guid == guid) {
                player thread onAdminConnect(admin);
            }
        }
    }
}

/**
 * @brief Connects an admin player with the admin structure that specifies their powers
 *
 * @param admin The admin struct associated with this admin player
 *
 * @returns nothing
 */
onAdminConnect(admin)
{
    debugPrint("in adminCommon::onAdminConnect()", "fn", level.nonVerbose);

    admin.playerName = self.name;
    admin.playerNumber = self getEntityNumber();
    admin.playerNumberInt = Int(admin.playerNumber);
    admin.isAdmin = true;
    noticePrint(admin.playerName + " recognized as an admin.");

    self.admin = admin;
    self.admin.adminMenuOpen = false;
    self.admin.isAdminMenuDirty = false;

    // this is the player the admin has selected in the menu
    debugPrint("level.players.size: " + level.players.size + ", self.admin.playerNumberInt: " + self.admin.playerNumberInt, "val");
    self.selectedPlayerIndex = getPlayerIndexByNum(self.admin.playerNumberInt);
    debugPrint("self.selectedPlayerIndex: " + self.selectedPlayerIndex, "val");
    self.selectedPlayersName = self.admin.playerName;

    // Show admin name and permissions in admin menu
    self setClientDvars( "admin_name", self.admin.playerName,
                         "admin_perm", self.admin.permissionsText,
                         "admin_perm1", self.admin.permissionsText1,
                         "admin_visibility", self.admin.visibilityState);

    wait 1;
    self thread scripts\server\_adminInterface::watchAdminMenuData();
    self thread scripts\server\_adminInterface::watchAdminMenuResponses();
    self thread maps\mp\_umiEditor::watchDevelopmentMenuResponses();
    self thread scripts\server\_adminInterface::watchForAdminSpectatorOpenMenuRequests();
}

getPlayer(playerEntityNumber, pickingType)
{
    debugPrint("in adminCommon::getPlayer()", "fn", level.lowVerbosity);

    if (pickingType == "number") {
        return getPlayerByEntityNumber(playerEntityNumber);
    }
}


/**
 * @brief Get a player object by their entity number
 *
 * @param playerEntityNumber integer The entity number of the player
 *
 * @returns the player
 */
getPlayerByEntityNumber(playerEntityNumber)
{
    debugPrint("in adminCommon::getPlayerByEntityNumber()", "fn", level.lowVerbosity);

    players = level.players;
    for (i = 0; i < players.size; i++) {
        if (players[i] getEntityNumber() == playerEntityNumber)
            return players[i];
    }
}

/**
 * @brief Get a player object by their short GUID
 *
 * @param shortGuid string The least significant 8 characters of the player's GUID
 *
 * @returns the player
 */
getPlayerByShortGuid(shortGuid)
{
    debugPrint("in adminCommon::getPlayerByShortGuid()", "fn", level.lowVerbosity);

    players = level.players;
    for (i = 0; i < players.size; i++) {
        if (players[i].shortGuid == shortGuid)
            return players[i];
    }
}

/**
 * @brief Get a player's entity number by their short GUID
 *
 * @param shortGuid string The least significant 8 characters of the player's GUID
 *
 * @returns the player's entity number
 */
getPlayerNumberByShortGuid(shortGuid)
{
    debugPrint("in adminCommon::getPlayerNumberByShortGuid()", "fn", level.lowVerbosity);

    players = level.players;
    for (i = 0; i < players.size; i++) {
        if (players[i].shortGuid == shortGuid)
            return players[i] getEntityNumber();
    }
}

/**
 * @brief Get a player index by their player number
 *
 * @param playerEntityNumber integer The entity number of the player
 *
 * @returns the index of the player in the level.players array
 */
getPlayerIndexByNum(playerEntityNumber)
{
    debugPrint("in adminCommon::getPlayerIndexByNum()", "fn", level.lowVerbosity);

    players = level.players;
    for (i = 0; i < players.size; i++) {
        if (players[i] getEntityNumber() == playerEntityNumber)
            return i;
    }
}



/**
 * @brief Informs all players of an admin's action for/against a single player
 *
 * @param player The player struct for the player acted for/against.
 * @param color string Determines the message color.  One of [positive|negative|nuetral].
 * @param message The localized message with placeholders to display.
 * @param reason A reason for the inform message.
 *
 * @returns nothing
 */
informAllPlayersOfAdminAction(player, color, message, reason)
{
    debugPrint("in adminCommon::informAllPlayersOfAdminAction()", "fn", level.lowVerbosity);

    if (color == "positive")
        color = "^2";
    else if (color == "negative")
        color = "^1";
    else
        color = "^7";

    if (!isDefined(reason))
        reason = &"ROTUSCRIPT_REASON_ADMIN_DECISION";

    if (self.admin.informPlayerOfAdminActions)
    {
        /*players = level.players;
        for ( i = 0; i < players.size; i++ )
            players[i] iPrintlnBold(message);*/
        iPrintLnBold(&"ROTUSCRIPT_INFORM_ALL_FORMAT", color, player.name, color, message, reason);
    }
}

/**
 * @brief Informs a player of an admin's action for/against them
 *
 * @param player The player struct for the player to inform.
 * @param color string Determines the message color.  One of [positive|negative|nuetral].
 * @param message The message to display.
 * @param reason The reason for message to display.
 *
 * @returns nothing
 * @todo informPlayerOfAdminAction calls args
 */
informPlayerOfAdminAction(player, color, message, reason)
{
    debugPrint("in adminCommon::informPlayerOfAdminAction()", "fn", level.nonVerbose);

    if (color == "positive")
        color = "^2";
    else if (color == "negative")
        color = "^1";
    else
        color = "^7";

    if (!isDefined(reason))
        reason = &"ROTUSCRIPT_REASON_ADMIN_DECISION";

    if (self.admin.informPlayerOfAdminActions) {
        player iPrintlnBold(&"ROTUSCRIPT_INFORM_PLR_FORMAT", color, message, reason);
    }
}


/**
 * @brief Shows a console message when an admin performs an action
 *
 * @param player The player was afflicted by admin action.
 * @param message The message to display.
 * @param reason The reason for action to display.
 *
 * The function prepends the passed message with "^3[admin]: ".
 *
 * @returns nothing
 */
adminActionConsoleMessage(player, message, reason)
{
    debugPrint("in adminCommon::adminActionConsoleMessage()", "fn", level.nonVerbose);

    if (!isDefined(player))
        player = "";
    
    if (!isDefined(reason))
        reason = &"ROTUSCRIPT_REASON_ADMIN_DECISION";

    if (self.admin.showActionConsoleMessages)
    {
        iPrintln(&"ROTUSCRIPT_ADMINACTIONCONSOLEMSG", player, message, reason);
    }
}


