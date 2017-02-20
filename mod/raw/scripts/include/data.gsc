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

/* TODO: WUT? float()? */
atof(string)
{
    debugPrint("in data::atof()", "fn", level.highVerbosity);

    setdvar("2float", string);
    return getdvarfloat("2float");
}
/* TODO: WUT? int()? */
atoi(string)
{
    debugPrint("in data::atoi()", "fn", level.highVerbosity);

    setdvar("2int", string);
    return getdvarint("2int");
}

removeFromArray(array, item)
{
    debugPrint("in data::removeFromArray()", "fn", level.lowVerbosity);

    for (i=0; i<array.size; i++) {
        if (array[i] == item) {
            for (; i<array.size - 1; i++) {
                array[i] = array[i+1];
            }
            array[array.size-1] = undefined;
            return array;
        }
    }
    return array;
}

dissect(string)
{
    debugPrint("in data::dissect()", "fn", level.lowVerbosity);

    ret = [];
    index = -1;
    skip = 1;
    for (i=0; i<string.size; i++) {
        if (string[i]==" ") {
            skip = 1;
            continue;
        } else {
            if (skip) {
                index ++;
                skip = 0;
                ret[index] = "";
            }
            ret[index] += string[i];
        }
    }
    return ret;
}
