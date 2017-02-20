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

/**
 * @file _debug.gsc This file contains the settings for the debug system
 *
 * The implementation of the debug system is in scripts/include/utility.gsc
 *
 * The debug system consists of the debugPrint(), warnPrint(), noticePrint(), and
 * errorPrint() functions, as well as the settings here.  The build system, makeMod.pl,
 * creates debug and non-debug versions of the rotu server scripts.  For the non-debug
 * version, it removes certain lines from the source code, while preserving the
 * new line characters so error messages in console_mp.log still refer to the correct
 * lines.  The three types of code the script removes are, in precedence order are:
 *
 * 1)   Any lines containing and between <debug></debug> tags following a C++ style
 *      comment, e.g.
 *      \code
 *      // <debug>
 *      for (i=0; i<level.players.size; i++) {
 *          level.players[i].headicon = "myTestHeadicon";
 *      }
 *      // </debug>
 *      \endcode
 *      N.B. the entire line containing a <debug> or </debug> tag is removed!
 *
 * 2)   Any single line containing a self-closing <debug /> tag inside of a C++ style
 *      comment.  This is useful for denoting that a function call should only be
 *      made when in debug mode, e.g. \code printPlayersInGame(); // <debug />\endcode
 *
 * 3)   Almost all lines containing debugPrint() function calls, e.g.
 *      \code debugPrint("in adminInterface::doAwesomeThing()", "fn", level.nonVerbose); \endcode
 *      or
 *      \code debugPrint("The player's name is: " + self.name, "val"); \endcode
 *      N.B. warnPrint(), errorPrint(), and noticePrint() statements are never removed
 *      (unless they happen to be in a debug block!).  Also, 'debugPrint(' must
 *      be the first non-whitespace string on the line, e.g. the line
 *      \code if (test) {debugPrint("my test", "val");} \endcode will not be removed.
 */

/**
 * @brief Load the settings we need for the debug system
 *
 * @returns nothing
 */
initializeDebugSystem()
{
    level.printFunctionEntryMessages = getDvarInt("debug_print_function_entry_messages");
    level.printValueMessages = getDvarInt("debug_print_value_messages");
    level.printSignalMessages = getDvarInt("debug_print_signal_messages");
    level.printWarningMessages = getDvarInt("debug_print_warning_messages");

    // Function entrance debug statements are only printed if their
    // verbosity is <= level.debugVerbosity
    level.debugVerbosity = getDvarInt("debug_verbosity");


    /**
     * In a 15-wave game with about seven players, there is on the order of five
     * million function calls.
     *
     * The 21 most-called functions account for about 95% of all function calls.
     * We do not place function entrance debugging statements on those functions
     * (and we place a comment there to remind us not to do so).
     *
     * The remaining 225,000 or so calls are broken up to represent a roughly
     * geometric series, where each debug verbosity level will print about half
     * as many function calls as the level above it (or each higher level prints
     * about twice as many statements as all the lower levels combined, whatever
     * makes the most sense to you).
     *
     * In the comments below, otof means 'on the order of'.
     */
    level.fullVerbosity     = 7;    /// prints otof 109,000 additional function calls
    level.absurdVerbosity   = 6;    /// prints otof  54,400 additional function calls
    level.veryHighVerbosity = 5;    /// prints otof  27,200 additional function calls
    level.highVerbosity     = 4;    /// prints otof  13,600 additional function calls
    level.medVerbosity      = 3;    /// prints otof   6,800 additional function calls
    level.lowVerbosity      = 2;    /// prints otof   3,400 additional function calls
    level.veryLowVerbosity  = 1;    /// prints otof   1,700 additional function calls
    level.nonVerbose        = 0;    /// prints otof     850 function calls
}
