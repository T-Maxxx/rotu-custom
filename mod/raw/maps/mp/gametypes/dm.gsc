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

#include maps\mp\_debug;
#include scripts\include\utility;

main()
{
    // source the settings the debug system depends on
    initializeDebugSystem();
    debugPrint("in dm::main()", "fn", level.lowVerbosity);

    if (getDvar("mapname") == "mp_background") {return;} // this isn't required...

    maps\mp\gametypes\_callbacksetup::SetupCallbacks();
    level.callbackStartGameType = ::Callback_StartGameType;

    level.script = toLower(getDvar("mapname"));
}

Callback_StartGameType()
{
    debugPrint("in dm::Callback_StartGameType()", "fn", level.lowVerbosity);

    thread scripts\server\_server::init();
    thread precacheDefault();
}

precacheDefault()
{
    debugPrint("in dm::precacheDefault()", "fn", level.nonVerbose);

    precachemodel("tag_origin");
    preCacheShader("white");
    preCacheShader("black");
}
