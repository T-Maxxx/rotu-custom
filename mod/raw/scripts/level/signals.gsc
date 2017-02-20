/* Not required localization. */
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
 * @file signals.gsc Functions to debug signals emitted, and signal documentation
 */


#include scripts\include\utility;

init()
{
    debugPrint("in signals::init()", "fn", level.nonVerbose);

    self thread gameEnded();
    self thread preMapVote();
    self thread mapVote();
    self thread postMapVote();
    self thread startingCredits();
    self thread creditsFinished();
    self thread startingMapChange();
    self thread mapChangeFailed();
    self thread intermission();
}

/**
 * @brief Logs the game_ended signal
 *
 * The \c game_ended signal is emitted in _gamemodes::endMap(...) immediately after
 * the \c intermission signal is emitted.
 *
 * @returns nothing
 */
gameEnded()
{
    debugPrint("in signals::gameEnded()", "fn", level.nonVerbose);

    level endon("starting_map_change");
    while(1) {
        level waittill("game_ended");
        debugPrint("caught signal: game_ended", "sig");
    }
}

/**
 * @brief Logs the intermission signal
 *
 * The \c intermission signal is emitted.
 *
 * @returns nothing
 */
intermission()
{
    debugPrint("in signals::intermission()", "fn", level.nonVerbose);

    level endon("starting_map_change");
    while(1) {
        level waittill("intermission");
        debugPrint("caught signal: intermission", "sig");
    }
}

/**
 * @brief Logs the pre_mapvote signal
 *
 * The \c pre_mapvote signal is emitted at the beginning of _mapvoting22::startMapVote(...),
 * shortly after the \c credits_finished signal is emitted.
 *
 * @returns nothing
 */
preMapVote()
{
    debugPrint("in signals::preMapVote()", "fn", level.nonVerbose);

    level endon("starting_map_change");
    while(1) {
        level waittill("pre_mapvote");
        debugPrint("caught signal: pre_mapvote", "sig");
    }
}


/**
 * @brief Logs the mapvote signal
 *
 * The \c mapvote signal is emitted in _mapvoting22::startMapVote(...),
 * just before the visual voting elements are created and voting begins.
 *
 * @returns nothing
 */
mapVote()
{
    debugPrint("in signals::mapVote()", "fn", level.nonVerbose);

    level endon("starting_map_change");
    while(1) {
        level waittill("mapvote");
        debugPrint("caught signal: mapvote", "sig");
    }
}


/**
 * @brief Logs the post_mapvote signal
 *
 * The \c post_mapvote signal is emitted near the beginning of _mapvoting22::startMapVote(...),
 * shortly befire the visuals are destroyed.
 *
 * @returns nothing
 */
postMapVote()
{
    debugPrint("in signals::postMapVote()", "fn", level.nonVerbose);

    level endon("starting_map_change");
    while(1) {
        level waittill("post_mapvote");
        debugPrint("caught signal: post_mapvote", "sig");
    }
}


/**
 * @brief Logs the starting_credits signal
 *
 * If end of game credits are to be shown, the \c starting_credits signal is
 * emitted in _gamemodes::endMap(...) shortly after the \c game_ended signal
 * is emitted.
 *
 * @returns nothing
 */
startingCredits()
{
    debugPrint("in signals::startingCredits()", "fn", level.nonVerbose);

    level endon("starting_map_change");
    while(1) {
        level waittill("starting_credits");
        debugPrint("caught signal: starting_credits", "sig");
    }
}


/**
 * @brief Logs the credits_finished signal
 *
 * If end of game credits are to be shown, the \c credits_finished signal is
 * emitted in _gamemodes::endMap(...) after the credits are finished.
 *
 * @returns nothing
 */
creditsFinished()
{
    debugPrint("in signals::creditsFinished()", "fn", level.nonVerbose);

    level endon("starting_map_change");
    while(1) {
        level waittill("credits_finished");
        debugPrint("caught signal: credits_finished", "sig");
    }
}


/**
 * @brief Logs the starting_map_change signal
 *
 * The \c starting_map_change signal is emitted at the beginning of _maps::changeMap(...)
 * when we try to change the map.
 *
 * @returns nothing
 */
startingMapChange()
{
    debugPrint("in signals::startingMapChange()", "fn", level.nonVerbose);

    while(1) {
        level waittill("starting_map_change");
        debugPrint("caught signal: starting_map_change", "sig");
    }
}


/**
 * @brief Logs the map_change_failed signal
 *
 * If changing the map failed, the \c map_change_failed signal is
 * emitted at the end of  _maps::changeMap(...).
 *
 * @returns nothing
 */
mapChangeFailed()
{
    debugPrint("in signals::mapChangeFailed()", "fn", level.nonVerbose);

    while(1) {
        level waittill("map_change_failed");
        debugPrint("caught signal: map_change_failed", "sig");
    }
}


/**
 * @brief Logs the no_longer_a_zombie signal
 *
 * When a player that became a zombie is killed, the \c no_longer_a_zombie signal is
 * emitted.
 *
 * @returns nothing
 */
noLongerAZombie()
{
    debugPrint("in signals::noLongerAZombie()", "fn", level.nonVerbose);

    while(isDefined(self)) {
        self waittill("no_longer_a_zombie");
        debugPrint("caught signal: no_longer_a_zombie", "sig");
    }
}

/**
 * @brief Logs the death signal
 *
 * When a player dies, the \c death signal is
 * emitted.
 *
 * @returns nothing
 */
death()
{
    debugPrint("in signals::death()", "fn", level.nonVerbose);

    while(isDefined(self)) {
        self waittill("death");
        debugPrint("caught signal: death", "sig");
    }
}

/**
 * @brief Logs the disconnect signal
 *
 * When a player disconnects, the \c disconnect signal is
 * emitted.
 *
 * @returns nothing
 */
disconnect()
{
    debugPrint("in signals::disconnect()", "fn", level.nonVerbose);

    while(isDefined(self)) {
        self waittill("disconnect");
        debugPrint("caught signal: disconnect", "sig");
    }
}
