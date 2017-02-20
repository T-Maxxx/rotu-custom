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

init()
{
    debugPrint("in _welcome::init()", "fn", level.nonVerbose);

    precache();

    loadSettings();
}

precache()
{
    precacheString(&"ROTUSCRIPT_ASSIST_ENDS_AT");
}

loadSettings()
{
    debugPrint("in _welcome::loadSettings()", "fn", level.nonVerbose);

    // Build array of welcome messages
    level.welcomeMessages = [];
    index = 1;
    get = getdvar("message_welcome"+index);
    while (get!="")
    {
        level.welcomeMessages[index-1] = get;
        index ++;
        get = getdvar("message_welcome"+index);
    }
}



/**
 * @brief Displays welcome messages to players when they join a game
 *
 * @returns nothing
 */
onPlayerSpawn()
{
    debugPrint("in _welcome::onPlayerSpawn()", "fn", level.nonVerbose);

    self endon("disconnect");

    /**
     * HACK: Since I can't figure out how to get an array of the survivor's
     * spawn point(s) from code (from the map???), we simply store original
     * location where they spawn as a new property in their player struct.  This
     * original spawn location is used in the implementation of the
     * scripts\server\_adminInterface::teleportPlayerToSpawn() function.
     */
    self.originalSpawnLocation = self.origin;

    if (!level.dvar["game_welcomemessages"]){return;}

    wait 2;

    if (!isdefined(self.hasBeenWelcomed))
    {
        if (!isDefined(self)) {return;}

        self.hasBeenWelcomed = true;
        for (i=0; i<level.welcomeMessages.size; i++)
        {
            msg = level.welcomeMessages[i];

            /**
             * Do not use Activision's StrTok() function here--it is screwed up
             * and not robust enough to handle this feature.  While certainly not
             * perfect, my own matches() and split() functions are certainly
             * robust enough for this feature.
             */
            // Replace tokens in messages as required
            if (IsSubStr( msg, ":NAME:" ))
            {
                tokens = scripts\include\strings::split(msg, ":NAME:");
                msg = tokens[0] + self.name + tokens[1];
            }
            if (IsSubStr( msg, ":MAX_PRESTIGE:" ))
            {
                tokens = scripts\include\strings::split(msg, ":MAX_PRESTIGE:");
                maxPrestige = level.maxPrestige;
                msg = tokens[0] + maxPrestige + tokens[1];
            }
            if (IsSubStr( msg, ":PRESTIGE:" ))
            {
                tokens = scripts\include\strings::split(msg, ":PRESTIGE:");
                prestige = self scripts\players\_persistence::statGet( "plevel" );
                msg = tokens[0] + prestige + tokens[1];
            }

            // Compute a reasonable time to display the message
            length = msg.size;
            time = 5; // init at 5 seconds, just in case

            // Assume linearity, using (seconds,length) data of (7,55) and (4,26)
            t = (3/29)*length + 1.3103;

            // Round time, with bias towards rounding up
            intT = int(t);
            remainder = t - intT;
            if (remainder > 0.3) {
                time = intT + 1;
            } else {
                time = intT;
            }
            self glowMessage(&"", msg, (1,1,1), time, 100, 1.4);
        }

        // Append welcome message for new players
        prestige = self scripts\players\_persistence::statGet( "plevel" );
        rank = self.pers["rank"];
        if ((prestige < 1) &&
            (rank < 30))
        {
            msg = &"ROTUSCRIPT_ASSIST_ENDS_AT";
            // Compute a reasonable time to display the message
            length = 37;
            time = 5; // init at 5 seconds, just in case

            // Assume linearity, using (seconds,length) data of (7,55) and (4,26)
            t = (3/29)*length + 1.3103;

            // Round time, with bias towards rounding up
            intT = int(t);
            remainder = t - intT;
            if (remainder > 0.3) {
                time = intT + 1;
            } else {
                time = intT;
            }
            self glowMessage(&"", msg, (1,1,1), time, 100, 1.4);
        }
    }
} // End function onPlayerSpawn()
