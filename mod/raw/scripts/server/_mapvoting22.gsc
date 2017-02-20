/* TODO: Logic needs to be rewritten to be able to localize */
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
#include scripts\include\strings;
#include scripts\include\array;

init()
{
    debugPrint("in _mapvoting22::init()", "fn", level.nonVerbose);

    precacheshader("white");
    level.mapvote = 0;
    level.onChangeMap = ::startMapVote;
    level.votingTime = getdvarInt("game_mapvote_time");
    level.numberOfMaps = getdvarInt("game_mapvote_count");
    level.notaOptionUsed = false; // flag; has the nota vote option won the voting?
    level.mapnameHudElements = 0;
    level.mapVotesHudElements = 0;
    level.voteFeedbackText = []; // holds all the possible player vote indicator strings
    level.voteTotalsDirty = true;
    level.blacklistedMaps = [];     // certain maps are known to prevent the server from starting
    level.reducedFrequencyMaps = [];
    level.greatlyReducedFrequencyMaps = [];

    // set column alignments
    level.voteFeedbackPositionX = 200; //90;
    level.mapnamePositionX = level.voteFeedbackPositionX + 10;
    level.votingResultsPositionX = level.mapnamePositionX + 190;

    // set vertical position for voting ballot
    level.ballotPositionY = 100;

    thread blacklistedMaps();
    thread reducedFrequencyMaps();

    // All the maps available for playing
    level.mapList = mapRotation();

    level.numberOfMaps = getdvarInt("game_mapvote_count");
}

reducedFrequencyMaps()
{
    debugPrint("in _mapvoting22::reducedFrequencyMaps()", "fn", level.nonVerbose);

    level.reducedFrequencyMaps = strtok(getdvar("sv_reduced_frequency_maps"), " ");
    level.greatlyReducedFrequencyMaps = strtok(getdvar("sv_greatly_reduced_frequency_maps"), " ");
}

/**
 * @brief These maps are known to prevent the server from starting
 *
 * When trying to load these maps, the server hangs.  The behavior is similar
 * to when there is a compile error in a *.gsc script.  These maps did work, at
 * least sometimes, in 2.1.  When the server hangs, we get no debug information
 * in console_mp.log or the game log files that might help to understand and fix
 * this bug.  We also don't have access to the source code for these maps, which
 * further complicates finding a solution.
 *
 * Until we can fix this issue, we blacklist the maps in the interest of server
 * stability.
 *
 * @returns nothing;
 */
blacklistedMaps()
{
    debugPrint("in _mapvoting22::blacklistedMaps()", "fn", level.nonVerbose);

    level.blacklistedMaps[0] = "mp_surv_ffc_parkorman"; // barricade errors
    level.blacklistedMaps[1] = "mp_mrx_castle"; // barricade errors
    level.blacklistedMaps[2] = "mp_evil_house"; // com_bottle precache errors, and more
    level.blacklistedMaps[3] = "mp_fnrp_futurama_v3"; // crashes iw3.exe
    level.blacklistedMaps[4] = "mp_surv_aftermath"; // prevents server from starting
    level.blacklistedMaps[5] = "mp_surv_bjelovar"; // prevents server from starting
    level.blacklistedMaps[6] = "mp_surv_RE4village"; // prevents server from starting
    level.blacklistedMaps[7] = "mp_surv_winter_bo"; // prevents server from starting
    level.blacklistedMaps[8] = "mp_surv_moon"; // prevents server from starting
    level.blacklistedMaps[9] = "mp_surv_matmata"; // prevents server from starting
    level.blacklistedMaps[10] = "mp_surv_ddv_army"; // prevents server from starting
    level.blacklistedMaps[11] = "mp_surv_fregata"; // fatal error: xmodel for ak47 doesn't load
    level.blacklistedMaps[12] = "mp_surv_sir2"; // fatal error: xmodel for ak47 doesn't load
}

/**
 * @brief If 'None of the Above' won the voting, resets the voting with a new map selection
 *
 * @returns nothing
 */
noneOfTheAboveWon()
{
    debugPrint("in _mapvoting22::noneOfTheAboveWon()", "fn", level.lowVerbosity);

    level notify("none_of_the_above_won");

    level.notaOptionUsed = true;
    startMapVote();
}

/**
 * @brief Prepares data structures for voting and top-level voting logic
 *
 * @returns nothing
 */
startMapVote()
{
    debugPrint("in _mapvoting22::startMapVote()", "fn", level.nonVerbose);

    level notify("pre_mapvote");
    lastMapPlayed = getdvar("mapname");

    level.votingMaps = randomMapSelection(level.mapList, level.numberOfMaps, lastMapPlayed); //size can be 0!

    // Set to actual number of maps, in case fewer maps were selectable than requested
    level.numberOfMaps = level.votingMaps.size;

    // If they lost the game, give them the option to replay the map, unless nota has won the voting
    if (level.gameWasLost && !level.notaOptionUsed) {
        level.votingMaps[level.votingMaps.size] = newMapItem(lastMapPlayed, "SURV");
        level.numberOfMaps++;
    }

    // Add a none of the above option.  If this option wins, a new map selection
    // is done and voting restarts.  Limited to once per map
    noneOfTheAbove = true;
    if ((noneOfTheAbove) && (!level.notaOptionUsed)) {
        level.votingMaps[level.votingMaps.size] = newMapItem("nota", "SURV");
        level.numberOfMaps++;
    }

    level.mapvote = 1;
    level notify("mapvote");

    buildVoteFeedbackArray();

    beginVoting(level.votingTime);
    level notify("post_mapvote");
    wait 1;
    deleteVisuals();
    wait 3;

    // If nota won, restart map voting
    if (winningMap().name=="nota") {noneOfTheAboveWon();}

    scripts\server\_maps::changeMap(winningMap().name);
}

/**
 * @brief Build the text string that tells the player which map they are currently voting for
 *
 * @returns nothing
 */
buildVoteFeedbackArray()
{
    debugPrint("in _mapvoting22::buildVoteFeedbackArray()", "fn", level.nonVerbose);

    feedbackText = "";
    padding = "";
    newlineCount = 0;
    for (i=0; i < level.votingMaps.size; i++) {
        while (newlineCount < i) {
            padding += "\n";
            newlineCount++;
        }
        feedbackText = padding + ">";
        level.voteFeedbackText[i] = feedbackText;
        newlineCount = 0;
        padding = "";
        feedbackText = "";
    }
}

/**
 * @brief Chooses a random selection of maps from those returned by \c mapRotation()
 *
 * @param mapList array of mapItem structs created by \c mapRotation()
 * @param numberOfMaps integer The number of maps to choose
 * @param illegal The code name of a map to prevent from being choosen
 *
 * @returns An array of \c mapList indices to use for the voting
 */
randomMapSelection(mapList, numberOfMaps, illegal)
{
    debugPrint("in _mapvoting22::randomMapSelection()", "fn", level.nonVerbose);

    availableMaps = mapList;
    selectedMaps = []; // maps in selection

    index = 0;
    while (index < numberOfMaps) {
        // break out of loop if we run out of available maps before we have the
        // requested number of maps selected
        if (availableMaps.size == 0) {break;}

        randomIndex = randomInt(availableMaps.size);
        if ((isdefined(illegal)) && (!isLegal(availableMaps[randomIndex].name, illegal))) {
            // map is illegal, remove it from consideration, then continue
            availableMaps = removeElementByIndex(availableMaps, randomIndex);
            continue;
        }

        // Map is legal, is it a reduced frequency map
        if (inArray(level.reducedFrequencyMaps, availableMaps[randomIndex].name)) {
            chance = randomInt(100);
            if (chance <= 50) {
                // use this map, remove it from future consideration, then continue
                selectedMaps[index] = availableMaps[randomIndex];
                index++;
                debugPrint("Reduced frequency map " + availableMaps[randomIndex].name + " being used.", "val");
                availableMaps = removeElementByIndex(availableMaps, randomIndex);
                continue;
            } else {
                // do not use this map, remove it from future consideration, then continue
                debugPrint("Reduced frequency map " + availableMaps[randomIndex].name + " NOT being used.", "val");
                availableMaps = removeElementByIndex(availableMaps, randomIndex);
                continue;
            }
        }

        // Map is legal, is it a greatly reduced frequency map
        if (inArray(level.greatlyReducedFrequencyMaps, availableMaps[randomIndex].name)) {
            chance = randomInt(100);
            if (chance <= 20) {
                // use this map, remove it from future consideration, then continue
                selectedMaps[index] = availableMaps[randomIndex];
                index++;
                debugPrint("Greatly reduced frequency map " + availableMaps[randomIndex].name + " being used.", "val");
                availableMaps = removeElementByIndex(availableMaps, randomIndex);
                continue;
            } else {
                // do not use this map, remove it from future consideration, then continue
                debugPrint("Greatly reduced frequency map " + availableMaps[randomIndex].name + " NOT being used.", "val");
                availableMaps = removeElementByIndex(availableMaps, randomIndex);
                continue;
            }
        }

        // Map is a valid choice, use this map, remove it from future consideration
        selectedMaps[index] = availableMaps[randomIndex];
        index++;
        availableMaps = removeElementByIndex(availableMaps, randomIndex);
    }
    return selectedMaps;
}


/**
 * @brief Check is the given map is illegal
 *
 * @param name The code name of the map
 * @param illegal string or string[] of illegal map code names
 *      The illegal string[] option is unused in this voting implementation
 *
 * @returns boolean Whether the map is illegal or not
 */
isLegal(name, illegal)
{
    debugPrint("in _mapvoting22::isLegal()", "fn", level.nonVerbose);

    /// illegal struct is not implemented
    if (!isString(illegal)) {
        for (i=0; i<illegal.size; i++) {
            if (illegal[i].name == name) {return false;}
        }
    }
    else if (name == illegal) {return false;}

    return true;
}


/**
 * @brief Gets the map structs based on maps listed in the sv_mapvotinf[n] dvars
 * @internal
 *
 * @returns array Map structs based on maps listed in the sv_maprotation dvar
 */
mapRotation()
{
    debugPrint("in _mapvoting22::mapRotation()", "fn", level.nonVerbose);

    maprotation = [];
    index = 0;

    // Load all the sv_mapvoting[n] dvars from server.cfg
    mapDvars = [];
    for (i=0; i<11; i++) {
        get = getdvar("sv_mapvoting"+(i+1));
        if(get == "") {break;}
        mapDvars[i]=get;
    }

    for (j=0; j<mapDvars.size; j++) {
        tokens = strtok(mapDvars[j], " ");

        isGametypeKeyword = 0;
        isMapKeyword = 0;
        gametype = "";
        for (i=0; i<tokens.size; i++) {
            if (!isMapKeyword) {
                if (tokens[i] == "map") {
                    isMapKeyword = 1;
                    continue;
                }
                if (tokens[i] == "gametype") {
                    isGametypeKeyword = 1;
                    continue;
                }
                if (isGametypeKeyword) {
                    isGametypeKeyword = 0;
                    gametype = tokens[i];
                    continue;
                }
            } else {
                // If the map isn't blacklisted, add it to the possible votable maps
                if (!inArray(level.blacklistedMaps, tokens[i])) {
                    maprotation[index] = newMapItem(tokens[i], gametype);
                    index++;
                }
                isMapKeyword = 0;
            }
        }
    }
    debugPrint(index + " voting maps found.", "val");
    return maprotation;
}


/**
 * @brief Creates and populates a new map item struct
 * @internal
 *
 * @param mapname string The code name of the map
 * @param gametype string The type of game
 *
 * @returns struct The new map struct
 */
newMapItem(mapname, gametype)
{
    debugPrint("in _mapvoting22::newMapItem()", "fn", level.lowVerbosity);

    map = spawnstruct();

    // Bail if we are trying to add a nameless map
    if (mapname=="") {return;}

    if ((!isdefined(gametype)) || (gametype=="")) {
        gametype = getdvar("g_gametype");
    }

    // Populate the map struct
    map.name = mapname;                                 // internal name of the map
    map.textName = mapTextName(mapname);                // English name of the map
    map.filterString = mapname + " " + map.textName;    // text used for type-ahead-find display in UI
    map.lcFilterString = toLower(map.filterString);     // text used for type-ahead-find
    map.gametype = gametype;                            // gametype
    map.votes = 0;                                      // number of votes for this map
    map.voters = [];                                    // array of players' numbers that voted for ths map
    map.votersText = "";                                // names of player that voted for this map

    // Prepend 'replay' to map name.  Only happens if players lost the current map
    if (mapname == getdvar("mapname")) {
        map.textName = "Replay " + map.textName;
    }

    // Allow for 'none of the above' option
    if (mapname=="nota") {
        map.name = "nota";
        map.textName = "None of the Above";
    }

    return map;
}


/**
 * @brief Gets the English name of the map
 * @internal
 *
 * @param mapname string The code name of the map
 *
 * @returns string The English name of the map, if it exists, otherwise mapname
 */
mapTextName(mapname)
{
    debugPrint("in _mapvoting22::mapTextName()", "fn", level.lowVerbosity);

    dvarName = "name_"+mapname;
    textName = getdvar(dvarname);

    // Use the mapname if there is no English name for the map
    if ((textName == "") && (mapname != "nota")) {
        message = dvarname + " not set in configuration files for map " + mapname +".\n";
        message += "\t" + dvarName + " should contain the English name of the map.";
        warnPrint(message);
        return mapname;
    }
    return textName;
}


/**
 * @brief Begins the actual voting procedure
 *
 * @param votingTime The time, in seconds, to keep voting open
 *
 * @returns nothing
 */
beginVoting(votingTime)
{
    debugPrint("in _mapvoting22::beginVoting()", "fn", level.nonVerbose);

    level.alphaintensity = .5;

    // Bounceless voting. After a button press, disable voting buttons for this
    // time to ensure each button press is interpreted as *only* one press
    level.bouncelessVotingDelay = .3;

    createVisuals();
    level thread updateVotingResults();
    level.votingPlayers = level.players;

    for (i=0; i<level.votingPlayers.size; i++) {
        level.votingPlayers[i] thread playerVote();
    }

    level thread updateWinningMap();

    wait votingTime;
}

/**
 * @brief Monitors player input for voting requests, then casts a vote as requested
 *
 * @returns nothing
 */
playerVote()
{
    debugPrint("in _mapvoting22::playerVote()", "fn", level.nonVerbose);

    level endon("post_mapvote");
    self endon("disconnect");

    self.mapVote = -1;
    self.changingVote = false;

    self playerVisuals();
    self playerStartVoting();

    // Init flags
    attackBtnPressed = false;
    aimDownSightBtnPressed = false;

    while(1) {
        // If the aim down sight button has just been pressed, change the state of the flag
        // so on the next iteration we can process the vote change
        if (!aimDownSightBtnPressed) {
            if (self adsbuttonpressed()) {
                aimDownSightBtnPressed = true;
            }
        } else {
            self.changingVote = true;
            self voteForPreviousMap();
            wait level.bouncelessVotingDelay;
            self.changingVote = false;
            // reset flag as required
            if (!self adsbuttonpressed()) {
                aimDownSightBtnPressed = false;
            }

        }
        // If the attack button has just been pressed, change the state of the flag
        // so on the next iteration we can process the vote change
        if (!attackBtnPressed) {
            if (self attackbuttonpressed()) {
                attackBtnPressed = true;
            }
        } else {
            // Process the vote change
            self.changingVote = true;
            self voteForNextMap();
            wait level.bouncelessVotingDelay;
            self.changingVote = false;
            // reset flag as required
            if (!self attackbuttonpressed()) {
                attackBtnPressed = false;
            }
        }
        wait 0.05; // one server frame
    }
}

/**
 * @brief starts the voting procedure for a player
 *
 * @returns nothing
 */
playerStartVoting()
{
    debugPrint("in _mapvoting22::playerStartVoting()", "fn", level.nonVerbose);

    level endon("post_mapvote");
    self endon("disconnect");

    // wait until the attack button is pressed
    while(!self attackbuttonpressed()) {
        wait 0.05;
    }

//     self.mapVote = 0;
    level.voteTotalsDirty = true;

    self thread removeVotingInstructions();
}

/**
 * @brief Removes the voting instructions after a delay
 *
 * @returns nothing
 */
removeVotingInstructions()
{
    debugPrint("in _mapvoting22::removeVotingInstructions()", "fn", level.nonVerbose);

    self endon("disconnect");

    // The instruction will be printed to the screen.  After the attack button is
    // pressed, they will remain for another ten seconds, then fade away.
    wait 10;
    if (isDefined(self) && isDefined(self.voteInstructions)) {
        self.voteInstructions FadeOverTime(1);
        self.voteInstructions.alpha = 0;
    }
    wait 1;

    if (isDefined(self) && isDefined(self.voteInstructions)) {self.voteInstructions destroy();}
}


/**
 * @brief Counts down the on-screen voting timer
 *
 * @returns nothing
 */
countdown()
{
    debugPrint("in _mapvoting22::countdown()", "fn", level.nonVerbose);

    self endon("disconnect");
    time = level.votingTime;
    while (time > 0) {
        time -= 1;
        level.timer setText(time);
        wait 1;
    }
}


/**
 * @brief Create the client-side HUD elements
 *
 * @returns nothing
 */
playerVisuals()
{
    debugPrint("in _mapvoting22::playerVisuals()", "fn", level.nonVerbose);

    self setclientdvar("ui_hud_hardcore", 1);

    self allowSpectateTeam( "allies", false );
    self allowSpectateTeam( "axis", false );
    self allowSpectateTeam( "freelook", false );
    self allowSpectateTeam( "none", true );

    self scripts\players\_players::joinSpectator();

    // Hud element for instructions
    self.voteInstructions = newClientHudElem(self);
    self.voteInstructions.x = 0;
    self.voteInstructions.y = -55; // -80
    self.voteInstructions.elemType = "font";
    self.voteInstructions.alignX = "center"; // bounding box
    self.voteInstructions.alignY = "middle";
    self.voteInstructions.horzAlign = "center"; // origin
    self.voteInstructions.vertAlign = "bottom";
    self.voteInstructions.color = (1, 1, 1);
    self.voteInstructions.glowcolor = decimalRgbToColor(255, 0, 0); // bright red
    self.voteInstructions.glowalpha = .7;
    self.voteInstructions.alpha = 1;
    self.voteInstructions.sort = -10; //0;
    self.voteInstructions.font = "objective";
    self.voteInstructions.fontScale = 2;
    self.voteInstructions.foreground = true;
    self.voteInstructions.label = &"MAPVOTE_INSTRUCTIONS22";
    self.voteInstructions.hideWhenInMenu = true;

    self.playerVoteFeedbackIconHud = newClientHudElem(self);
    self.playerVoteFeedbackIconHud.x = level.voteFeedbackPositionX;
    self.playerVoteFeedbackIconHud.y = level.ballotPositionY - 1; // set one pixel higher
    self.playerVoteFeedbackIconHud.elemType = "font";
    self.playerVoteFeedbackIconHud.alignX = "left";  // bounding box
    self.playerVoteFeedbackIconHud.alignY = "middle";
    self.playerVoteFeedbackIconHud.horzAlign = "left";  // origin
    self.playerVoteFeedbackIconHud.vertAlign = "top";
    self.playerVoteFeedbackIconHud.color = decimalRgbToColor(255, 255, 0);   // bright yellow
    self.playerVoteFeedbackIconHud.alpha = 1;
    self.playerVoteFeedbackIconHud.glowcolor = decimalRgbToColor(255, 255, 0);   // bright yellow
    self.playerVoteFeedbackIconHud.glowalpha = .7;
    self.playerVoteFeedbackIconHud.sort = -10; //0;
    self.playerVoteFeedbackIconHud.font = "default";
    self.playerVoteFeedbackIconHud.fontScale = 1.6;
    self.playerVoteFeedbackIconHud.foreground = true;
    self.playerVoteFeedbackIconHud setText(""); // init
    self.playerVoteFeedbackIconHud.parent = self;
    self.playerVoteFeedbackIconHud.hideWhenInMenu = true;

}


/**
 * @brief Destroys the player's map voting HUD elements
 *
 * @returns nothing
 */
playerDeleteVisuals()
{
    debugPrint("in _mapvoting22::playerDeleteVisuals()", "fn", level.nonVerbose);

    self endon("disconnect");

    self.playerVoteFeedbackIconHud FadeOverTime(1);
    self.playerVoteFeedbackIconHud.alpha = 0;

    wait 1;
    self.playerVoteFeedbackIconHud Destroy();
    if (isdefined(self.voteInstructions)) {
        self.voteInstructions destroy();
    }
}


/**
 * @brief Updates the voting results
 * @threaded
 *
 * @returns nothing
 */
updateVotingResults()
{
    debugPrint("in _mapvoting22::updateVotingResults()", "fn", level.nonVerbose);

    level endon("none_of_the_above_won");

    while(1) {
        if (level.voteTotalsDirty) {
            level.voteTotalsDirty = false;
            winningMapIndex = winningMapIndex();

            // for each map, update the voting results
            votingResultsText = "";
            for (i=0; i<level.votingMaps.size; i++ ) {
                mapVoteTotal = level.votingMaps[i].votes;
                if (i==winningMapIndex) {
                    color = "^2"; // green
                } else if (level.votingMaps[i].votes > 0) {
                    color = "^1"; // red
                } else {
                    color = "^7"; // white
                }
                votingResultsText += sprintf("$1$2 $3\n", color, mapVoteTotal, level.votingMaps[i].votersText);
            }
//             level.votingResultsHud setText(votingResultsText);
            updateVotingResultsHUD(votingResultsText);

        } else {
            // Do nothing if the vote totals aren't dirty
        }
        /// @bug Temp make this 0.2 instaed of 0.1 to limit max number of strings created
        wait 0.2;
    }
}

updateVotingResultsHUD(votingResultsText)
{
    debugPrint("in _mapvoting22::updateVotingResultsHUD()", "fn", level.nonVerbose);

    if (isDefined(level.votingResultsHud)) {level.votingResultsHud destroy();}
//     wait 0.05;

    // Hud for voting results (# of votes & voters' names)
    level.votingResultsHud = newHudElem(self);
    level.votingResultsHud.x = level.votingResultsPositionX;
    level.votingResultsHud.y = level.ballotPositionY;
    level.votingResultsHud.elemType = "font";
    level.votingResultsHud.alignX = "left";  // bounding box
    level.votingResultsHud.alignY = "middle";
    level.votingResultsHud.horzAlign = "left";  // origin
    level.votingResultsHud.vertAlign = "top";
    level.votingResultsHud.alpha = 1;
    level.votingResultsHud.sort = -10; //0;
    level.votingResultsHud.font = "default";
    level.votingResultsHud.fontScale = 1.6;
    level.votingResultsHud.foreground = true;
    level.votingResultsHud setText(votingResultsText);
    level.votingResultsHud.parent = self;
    level.votingResultsHud.hideWhenInMenu = true;
}

/**
 * @brief Changes a players vote to the next map in the list
 *
 * @returns nothing
 */
voteForNextMap()
{
    debugPrint("in _mapvoting22::voteForNextMap()", "fn", level.nonVerbose);

    // Remove the player's current vote
    changePlayerVote(self.mapVote, -1);

    // select the next map index
    self.mapVote++;

    // wrap map index across end of the array
    if (self.mapVote>=level.votingMaps.size) {
        self.mapVote = 0;
    }

    // Vote for the new map
    changePlayerVote(self.mapVote, 1);

    // Mark the voting results as dirty so updateVotingResults() will update them
    level.voteTotalsDirty = true;
}


/**
 * @brief Changes a players vote to the previous map in the list
 *
 * @returns nothing
 */
voteForPreviousMap()
{
    debugPrint("in _mapvoting22::voteForPreviousMap()", "fn", level.nonVerbose);

    // Remove the player's current vote
    changePlayerVote(self.mapVote, -1);

    // select the previous map index
    self.mapVote -= 1;

    // wrap map index across beginning of the array
    if (self.mapVote < 0) {
        self.mapVote = level.votingMaps.size-1;
    }

    // Vote for the new map
    changePlayerVote(self.mapVote, 1);

    wait 0.05;

    // Mark the voting results as dirty so updateVotingResults() will update them
    level.voteTotalsDirty = true;
}


/**
 * @brief Changes a player's vote in the server map vote totals
 *
 * @param mapIndex integer The index of the map to change the votes for
 * @param difference signed integer The number of votes to add or remove from the map.
 *                   Typically -1 to remove a vote, 1 to add a vote.
 *
 * @returns nothing
 */
changePlayerVote(mapIndex, difference)
{
    debugPrint("in _mapvoting22::changePlayerVote()", "fn", level.lowVerbosity);

    if (mapIndex == -1) {return;}

    level.votingMaps[mapIndex].votes += difference;

    playerNumber = self getEntityNumber();
    if (difference > 0) {
        // voting for this map
        level.votingMaps[mapIndex].voters = orderedInsert(level.votingMaps[mapIndex].voters, 0, playerNumber);
        // Update yellow feedback arrow
        self.playerVoteFeedbackIconHud setText(level.voteFeedbackText[mapIndex]);
    } else {
        // removing vote for this map
        level.votingMaps[mapIndex].voters = orderedRemove(level.votingMaps[mapIndex].voters, 0, playerNumber);
    }
    level.votingMaps[mapIndex].votersText = votersText(mapIndex);
}


/**
 * @brief Builds the list of voters' names used as part of votingResultsHud
 *
 * @param mapIndex integer The index of the map if \c level.votingMaps[]
 *
 * @returns string The list of voters for the map
 */
votersText(mapIndex)
{
    debugPrint("in _mapvoting22::votersText()", "fn", level.lowVerbosity);

    players = level.players;
    votersPlayerNames = [];

    // Bail if the number of voters for this map is zero
    if (level.votingMaps[mapIndex].voters.size == 0) {return "";}

    // Build an array of the voters' names for this map
    for (i=0; i < level.votingMaps[mapIndex].voters.size; i++) {
        votingPlayersNumber = level.votingMaps[mapIndex].voters[i];
        for (j=0; j<players.size; j++ )
        {
            if (!isDefined(players[j])) {continue;}
            if (players[j] getEntityNumber() == votingPlayersNumber) {
                votersPlayerNames[i] = players[j].name;
            }
        }
    }
    if (votersPlayerNames.size == 0) {return "";}
    return join(votersPlayerNames, ", ");
}



/**
 * @brief Creates the server map voting HUD elements
 *
 * @returns nothing
 */
createVisuals()
{
    debugPrint("in _mapvoting22::createVisuals()", "fn", level.nonVerbose);

    // The large black background for the ballot
    level.blackbg = newHudElem();
    level.blackbg.x = 0;
    level.blackbg.y = level.ballotPositionY - 25;
    level.blackbg.width = 920;
    level.blackbg.height = 320;
    level.blackbg.alignX = "center";
    level.blackbg.alignY = "top";
    level.blackbg.horzAlign = "center";
    level.blackbg.vertAlign = "top";
    level.blackbg.color = decimalRgbToColor(0, 0, 0);  // black
    level.blackbg.alpha = .7;
    level.blackbg.sort = -2;
    level.blackbg.foreground = false;
    level.blackbg setShader( "white", level.blackbg.width, level.blackbg.height );
    level.blackbg.hideWhenInMenu = true;

    // The thin, dark grey top border of the ballot background
    level.blackbartop = newHudElem();
    level.blackbartop.x = 0;
    level.blackbartop.y = level.ballotPositionY - 27;
    level.blackbartop.width =  920;
    level.blackbartop.height =  2;
    level.blackbartop.alignX = "center";
    level.blackbartop.alignY = "top";
    level.blackbartop.horzAlign = "center";
    level.blackbartop.vertAlign = "top";
    level.blackbartop.color = decimalRgbToColor(25, 25, 25); // very dark gray
    level.blackbartop.alpha = 1;
    level.blackbartop.sort = -2;
    level.blackbartop.foreground = false;
    level.blackbartop setShader( "white", level.blackbartop.width, level.blackbartop.height );
    level.blackbartop.hideWhenInMenu = true;

    // The thin, dark grey bottom border of the ballot background
    level.blackbar = newHudElem();
    level.blackbar.x = 0;
    level.blackbar.y = level.ballotPositionY - 25 + level.blackbg.height;
    level.blackbar.width =  920;
    level.blackbar.height =  2;
    level.blackbar.alignX = "center";
    level.blackbar.alignY = "top";
    level.blackbar.horzAlign = "center";
    level.blackbar.vertAlign = "top";
    level.blackbar.color = decimalRgbToColor(25, 25, 25); // very dark gray
    level.blackbar.alpha = 1;
    level.blackbar.sort = -2;
    level.blackbar.foreground = false;
    level.blackbar setShader( "white", level.blackbar.width, level.blackbar.height );
    level.blackbar.hideWhenInMenu = true;

    // Build map names Hud text
    hudMapNameText = "";
    for (i=0; i < level.votingMaps.size - 1; i++) {
        hudMapNameText += level.votingMaps[i].textName + "\n";
    }
    hudMapNameText += level.votingMaps[level.votingMaps.size - 1].textName;

    // Hud for map names
    level.mapNamesHud = newHudElem(self);
    level.mapNamesHud.x = level.mapnamePositionX;
    level.mapNamesHud.y = level.ballotPositionY;
    level.mapNamesHud.elemType = "font";
    level.mapNamesHud.alignX = "left";  // bounding box
    level.mapNamesHud.alignY = "middle";
    level.mapNamesHud.horzAlign = "left";  // origin
    level.mapNamesHud.vertAlign = "top";
    level.mapNamesHud.color = decimalRgbToColor(255, 255, 255); // white
    level.mapNamesHud.alpha = 1;
    level.mapNamesHud.sort = -10; //0;
    level.mapNamesHud.font = "default";
    level.mapNamesHud.fontScale = 1.6;
    level.mapNamesHud.foreground = true;
    level.mapNamesHud setText(hudMapNameText);
    level.mapNamesHud.parent = self;
    level.mapNamesHud.hideWhenInMenu = true;

    // Build initial voting results Hud text
    votingResultsText = "";
    for (i=0; i < level.votingMaps.size - 1; i++) {
        votingResultsText += "0" + "\n";
    }
    votingResultsText += "0";
    updateVotingResultsHUD(votingResultsText);

//     // Hud for voting results (# of votes & voters' names)
//     level.votingResultsHud = newHudElem(self);
//     level.votingResultsHud.x = level.votingResultsPositionX;
//     level.votingResultsHud.y = level.ballotPositionY;
//     level.votingResultsHud.elemType = "font";
//     level.votingResultsHud.alignX = "left";  // bounding box
//     level.votingResultsHud.alignY = "middle";
//     level.votingResultsHud.horzAlign = "left";  // origin
//     level.votingResultsHud.vertAlign = "top";
//     level.votingResultsHud.alpha = 1;
//     level.votingResultsHud.sort = -10; //0;
//     level.votingResultsHud.font = "default";
//     level.votingResultsHud.fontScale = 1.6;
//     level.votingResultsHud.foreground = true;
//     level.votingResultsHud setText(votingResultsText);
//     level.votingResultsHud.parent = self;
//     level.votingResultsHud.hideWhenInMenu = true;

    // Hud element for timer
    level.timer = newHudElem(self);
    level.timer.x = 25;
    level.timer.y = 25;
    level.timer.elemType = "font";
    level.timer.alignX = "left";  // bounding box
    level.timer.alignY = "middle";
    level.timer.horzAlign = "left"; // origin
    level.timer.vertAlign = "top";
    level.timer.color = decimalRgbToColor(255, 255, 255); // white
    level.timer.alpha = 1;
    level.timer.sort = -10; //0;
    level.timer.glowcolor = decimalRgbToColor(255, 0, 0); // bright red
    level.timer.glowalpha = .7;
    level.timer.font = "objective"; //"default";
    level.timer.fontScale = 2.5;
    level.timer.foreground = true;
    level.timer setText(level.votingTime);
    // N.B. We leave the timer visible when in menu
    self thread countdown();

    // Hud element for 'Winning Map:' label
    level.winningMapText = newHudElem();
    level.winningMapText.x = 0;
    level.winningMapText.y = 15;
    level.winningMapText.elemType = "font";
    level.winningMapText.alignX = "center";
    level.winningMapText.alignY = "middle";
    level.winningMapText.horzAlign = "center";
    level.winningMapText.vertAlign = "top";
    level.winningMapText.color = decimalRgbToColor(255, 255, 255); // white
    level.winningMapText.alpha = 1;
    level.winningMapText.sort = 0;
    level.winningMapText.font = "objective";
    level.winningMapText.fontScale = 2.5;
    level.winningMapText.foreground = true;
    level.winningMapText.glowcolor = decimalRgbToColor(255, 0, 0); // bright red
    level.winningMapText.glowalpha = .7;
    level.winningMapText setText("Winning Map:");  /// @todo use string table
    level.winningMapText.hideWhenInMenu = true;

    // Hud element for winning map value
    level.winningMap = newHudElem();
    level.winningMap.x = 0;
    level.winningMap.y = 45;
    level.winningMap.elemType = "font";
    level.winningMap.alignX = "center";
    level.winningMap.alignY = "middle";
    level.winningMap.horzAlign = "center";
    level.winningMap.vertAlign = "top";
    level.winningMap.color = decimalRgbToColor(255, 255, 255); // white
    level.winningMap.alpha = 1;
    level.winningMap.sort = 0;
    level.winningMap.font = "objective";
    level.winningMap.fontScale = 2.5;
    level.winningMap.foreground = true;
    level.winningMap.glowcolor = decimalRgbToColor(255, 0, 0); // bright red
    level.winningMap.glowalpha = .6;
    level.winningMap.label = &"MAPVOTE_WAIT4VOTES";
    level.winningMap setText("");
    level.winningMap.hideWhenInMenu = true;

//     // Hud for map images
//     level.mapImagesHud = newHudElem(self);
//     level.mapImagesHud.x = 25;
//     level.mapImagesHud.y = 125;
//     level.mapImagesHud.alignX = "left";  // bounding box
//     level.mapImagesHud.alignY = "top";
//     level.mapImagesHud.horzAlign = "left";  // origin
//     level.mapImagesHud.vertAlign = "top";
//     level.mapImagesHud.color = decimalRgbToColor(255, 255, 255); // white
//     level.mapImagesHud.alpha = 1;
//     level.mapImagesHud.sort = -10; //0;
//     level.mapImagesHud.foreground = true;
//     level.mapImagesHud.hideWhenInMenu = true;
//     /// "hud_suitcase_bomb" works but devicon doesn't.  MUst be 2d materials?
//     level.mapImagesHud setshader("loadscreen_mp_bsf_backlot",75,75);

}


/**
 * @brief Destroys the server and client map voting HUD elements
 *
 * @returns nothing
 */
deleteVisuals()
{
    debugPrint("in _mapvoting22::deleteVisuals()", "fn", level.nonVerbose);

    // Destroy the player's visuals
    for (i=0; i<level.votingPlayers.size; i++) {
        if (isdefined(level.votingPlayers[i])) {
            level.votingPlayers[i] thread playerDeleteVisuals();
        }
    }

    // Destroy the server's visuals
    level.winningMap FadeOverTime(1);
    level.winningMapText FadeOverTime(1);
    level.mapNamesHud FadeOverTime(1);
    level.votingResultsHud FadeOverTime(1);
    level.timer FadeOverTime(1);
    level.blackbg FadeOverTime(1);
    level.blackbar FadeOverTime(1);
    level.blackbartop FadeOverTime(1);

    level.winningMap.alpha = 0;
    level.winningMapText.alpha = 0;
    level.mapNamesHud.alpha = 0;
    level.votingResultsHud.alpha = 0;
    level.timer.alpha = 0;
    level.blackbg.alpha = 0;
    level.blackbar.alpha = 0;
    level.blackbartop.alpha = 0;

    wait 1;

    level.winningMap destroy();
    level.winningMapText destroy();
    level.mapNamesHud destroy();
    level.votingResultsHud destroy();
    level.timer destroy();
    level.blackbg destroy();
    level.blackbar destroy();
    level.blackbartop destroy();
}


/**
 * @brief Updates the "Winning Map" display
 *
 * @returns nothing
 */
updateWinningMap()
{
    debugPrint("in _mapvoting22::updateWinningMap()", "fn", level.nonVerbose);

    level endon("post_mapvote");
    while (1) {
        index = winningMapIndex();
        if (level.votingMaps[index].votes != 0) {
            level.winningMap.label = &"";
            level.winningMap setText(level.votingMaps[index].textName);
        }

        wait 0.5;
    }
}


/**
 * @brief Returns the index of the winning map
 *
 * @returns the index of the winning map
 */
winningMapIndex()
{
    debugPrint("in _mapvoting22::winningMapIndex()", "fn", level.lowVerbosity);

    mostvotes = level.votingMaps[0].votes;
    winningMapIndex = 0;
    for (i=1; i<level.votingMaps.size; i++) {
        if (level.votingMaps[i].votes > mostvotes) {
            mostvotes = level.votingMaps[i].votes;
            winningMapIndex = i;
        }
    }
    return winningMapIndex;
}


/**
 * @brief Returns the mapItem struct for the winning map
 *
 * @returns the mapItem struct for the winning map
 */
winningMap()
{
    debugPrint("in _mapvoting22::winningMap()", "fn", level.nonVerbose);

    return level.votingMaps[winningMapIndex()];
}

