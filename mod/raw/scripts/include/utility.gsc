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
 * @file utility.gsc General utility functions
 */

/**
 * @brief Writes debug messages to logfile specified in g_log dvar
 *
 * @param message string The message to write
 * @param type string The type of debug message ["fn"|"val"]
 * @param verbosity integer The verbosity level [0-3].  0 is low verbosity, 3 is high verbosity
 *
 * @returns nothing
 */
debugPrint(message, type, verbosity)
{
    if (!isDefined(message)) {
        errorPrint("utility::debugPrint(message, " + type + ") called with an undefined message");
        return;
    }
    if (!isDefined(type)) {
        type = "val";
    }
    if (!isDefined(verbosity)) {
        verbosity = 0;
    }

    printMessage = false;

    // Function entry messages
    if ((level.printFunctionEntryMessages) &&
        (type == "fn") &&
        (verbosity <= level.debugVerbosity)) {printMessage = true;}

    // Variable value messages
    else if ((level.printValueMessages) && (type == "val")) {printMessage = true;}

    // Signals notified or received
    else if ((level.printSignalMessages) && (type == "sig")) {printMessage = true;}

    if (printMessage) {
        message = "Debug: " + message + "\n";
        LogPrint(message);
    }
}


/**
 * @brief Writes warning messages to logfile specified in g_log dvar
 *
 * @param message string The message to write
 *
 * @returns nothing
 */
warnPrint(message)
{
    if (!isDefined(message)) {
        errorPrint("utility::warnPrint(message) called with an undefined message");
        return;
    }

    if (level.printWarningMessages) {
        message = "Warn: " + message + "\n";
        LogPrint(message);
    }
}


/**
 * @brief Always writes error messages to logfile specified in g_log dvar
 *
 * @param message string The message to write
 *
 * @returns nothing
 */
errorPrint(message)
{
    if (!isDefined(message)) {
        message = "utility::errorPrint(message) called with an undefined message";
    }

    printMessage = true; // We *always* print error messages

    if (printMessage) {
        message = "Error: " + message + "\n";
        LogPrint(message);
    }
}


/**
 * @brief Always writes a message to logfile specified in g_log dvar
 * This function is used for messages we always want to write, yet aren't
 * really error messages.
 *
 * @param message string The message to write
 *
 * @returns nothing
 */
noticePrint(message)
{
    if (!isDefined(message)) {
        errorPrint("utility::noticePrint(message) called with an undefined message");
        return;
    }

    printMessage = true; // We *always* print these message

    if (printMessage) {
        message = "Notice: " + message + "\n";
        LogPrint(message);
    }
}


/**
 * @brief Coverts a decimal RGB tuple to a cod4 color tuple
 *
 * @param red integer The red component, [0, 255]
 * @param green integer The green component, [0, 255]
 * @param blue integer The blue component, [0, 255]
 *
 * @returns a cod4 color tuple
 */
decimalRgbToColor(red, green, blue)
{
    debugPrint("in utility::decimalRgbToColor()", "fn", level.nonVerbose);

    return (red/255, green/255, blue/255);
}

