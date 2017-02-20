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
#include scripts\include\utility;

init()
{
    debugPrint("in _damagefeedback::init()", "fn", level.nonVerbose);

    precacheShader("damage_feedback");
    precacheShader("damage_feedback_j");

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    debugPrint("in _damagefeedback::onPlayerConnect()", "fn", level.nonVerbose);

    for(;;) {
        level waittill("connected", player);

        player.hud_damagefeedback = newClientHudElem(player);
        player.hud_damagefeedback.horzAlign = "center";
        player.hud_damagefeedback.vertAlign = "middle";
        player.hud_damagefeedback.x = -12;
        player.hud_damagefeedback.y = -12;
        player.hud_damagefeedback.alpha = 0;
        player.hud_damagefeedback.archived = true;
        player.hud_damagefeedback setShader("damage_feedback", 24, 48);
    }
}

updateDamageFeedbackSound()
{
    debugPrint("in _damagefeedback::updateDamageFeedbackSound()", "fn", level.lowVerbosity);

    if (!isPlayer(self)) {return;}

    self playlocalsound("MP_hit_alert");
}

updateDamageFeedback(hitBodyArmor)
{
    debugPrint("in _damagefeedback::updateDamageFeedback()", "fn", level.fullVerbosity);

    if (!isPlayer(self)) {return;}

    if (hitBodyArmor) {
        self.hud_damagefeedback setShader("damage_feedback_j", 24, 48);
        self playlocalsound("MP_hit_alert"); // TODO: change sound?
    } else {
        self.hud_damagefeedback setShader("damage_feedback", 24, 48);
        self playlocalsound("MP_hit_alert");
    }

    self.hud_damagefeedback.alpha = 1;
    self.hud_damagefeedback fadeOverTime(1);
    self.hud_damagefeedback.alpha = 0;
}
