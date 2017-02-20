/******************************************************************************
 *    Reign of the Undead, v2.x
 *
 *    Copyright (c) 2010-2013 Reign of the Undead Team.
 *    See AUTHORS.txt for a listing.
 *
 *    Permission is hereby granted, free of charge, to any person obtaining a copy
 *    of this software and associated documentation files (the "Software"), to
 *    deal in the Software without restriction, including without limitation the
 *    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *    sell copies of the Software, and to permit persons to whom the Software is
 *    furnished to do so, subject to the following conditions:
 *
 *    The above copyright notice and this permission notice shall be included in
 *    all copies or substantial portions of the Software.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *    SOFTWARE.
 *
 *    The contents of the end-game credits must be kept, and no modification of its
 *    appearance may have the effect of failing to give credit to the Reign of the
 *    Undead creators.
 *
 *    Some assets in this mod are owned by Activision/Infinity Ward, so any use of
 *    Reign of the Undead must also comply with Activision/Infinity Ward's modtools
 *    EULA.
 ******************************************************************************/
/** @file _unified_mapping_interface.gsc An unified interface specification for
 * maps into CoD4 zombie mods.  Each mod should copy this interface as
 * @code maps\mp\_umi.gsc @endcode and then implement the specified interface in
 * @code _umi.gsc @endcode as required for their mod.
 *
 * Attention Mappers: Include @code maps\mp\_umi.gsc @endcode in your main map file--
 *                    not @code maps\mp\_unified_mapping_interface.gsc @endcode
 */

/**
 * @brief Returns the lower-cased name of the mod that is trying to load the map
 *
 * @returns string The name of the mod, e.g. "rotu", "rozo", etc
 */
modName()
{
    if (isDefined(level.modName)) {return level.modName;}
    else {
        level.modName = privateGuessModName();
        return level.modName;
    }
}

/**
 * @brief Returns the native type of the map being loaded
 *
 * @returns string The native type of the map, e.g. "rotu", "rozo", etc.
 */
nativeMapType()
{
    return "";
}

/**
 * @brief Sets the native type of the map being loaded
 *
 * @param nativeMapType string The native type of the map, e.g. "rotu", "rozo", etc.
 *
 * @returns nothing
 */
setNativeMapType(nativeMapType)
{
    level.nativeMapType = nativeMapType;
}

/**
 * @brief Is this map using the unified mapping interface?
 *
 * @returns boolean true if the map uses UMI, false otherwise
 */
isUmiMap()
{
    if (isDefined(level.isUmiMap)) {return level.isUmiMap;}
    else {
        return false;
    }
}

/**
 * @brief Attempts to determine the name of the mod loading the map
 * @private
 *
 * @returns string The name of the mod, or an empty string if undetermined
 */
privateGuessModName()
{
    /// @todo implement me
    return "";
}

/// umi for building stores
buildShops()
{}

/// umi for weapons shop/upgrade
buildWeaponShopsByTargetname()
{}

/// umi for weapons shop/upgrade
buildWeaponShopsByTradespawns()
{}

/// rotu legacy equipment shop
buildAmmoStock(targetname)
{}

/// rotu legacy weapon upgrade
buildWeaponUpgrade(targetname)
{}

/// rozo legacy for placing shops and weapons upgrades
placeShops()
{}

buildSurvSpawn()
{}





