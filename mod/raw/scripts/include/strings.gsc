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

/**
 * @brief Build an array of printable ascii characters form dec(32) through dec(126)
 *
 * @returns the ascii array
 */
buildPrintableAscii()
{
    debugPrint("in strings::buildPrintableAscii()", "fn", level.nonVerbose);

    ascii = [];
    ascii[32] = " ";
    ascii[33] = "!";
    ascii[34] = "\"";
    ascii[35] = "#";
    ascii[36] = "$";
    ascii[37] = "%";
    ascii[38] = "&";
    ascii[39] = "'";
    ascii[40] = "(";
    ascii[41] = ")";
    ascii[42] = "*";
    ascii[43] = "+";
    ascii[44] = ",";
    ascii[45] = "-";
    ascii[46] = ".";
    ascii[47] = "/";
    ascii[48] = "0";
    ascii[49] = "1";
    ascii[50] = "2";
    ascii[51] = "3";
    ascii[52] = "4";
    ascii[53] = "5";
    ascii[54] = "6";
    ascii[55] = "7";
    ascii[56] = "8";
    ascii[57] = "9";
    ascii[58] = ":";
    ascii[59] = ";";
    ascii[60] = "<";
    ascii[61] = "=";
    ascii[62] = ">";
    ascii[63] = "?";
    ascii[64] = "@";
    ascii[65] = "A";
    ascii[66] = "B";
    ascii[67] = "C";
    ascii[68] = "D";
    ascii[69] = "E";
    ascii[70] = "F";
    ascii[71] = "G";
    ascii[72] = "H";
    ascii[73] = "I";
    ascii[74] = "J";
    ascii[75] = "K";
    ascii[76] = "L";
    ascii[77] = "M";
    ascii[78] = "N";
    ascii[79] = "O";
    ascii[80] = "P";
    ascii[81] = "Q";
    ascii[82] = "R";
    ascii[83] = "S";
    ascii[84] = "T";
    ascii[85] = "U";
    ascii[86] = "V";
    ascii[87] = "W";
    ascii[88] = "X";
    ascii[89] = "Y";
    ascii[90] = "Z";
    ascii[91] = "[";
    ascii[92] = "\\";
    ascii[93] = "]";
    ascii[94] = "^";
    ascii[95] = "_";
    ascii[96] = "`";
    ascii[97] = "a";
    ascii[98] = "b";
    ascii[99] = "c";
    ascii[100] = "d";
    ascii[101] = "e";
    ascii[102] = "f";
    ascii[103] = "g";
    ascii[104] = "h";
    ascii[105] = "i";
    ascii[106] = "j";
    ascii[107] = "k";
    ascii[108] = "l";
    ascii[109] = "m";
    ascii[110] = "n";
    ascii[111] = "o";
    ascii[112] = "p";
    ascii[113] = "q";
    ascii[114] = "r";
    ascii[115] = "s";
    ascii[116] = "t";
    ascii[117] = "u";
    ascii[118] = "v";
    ascii[119] = "w";
    ascii[120] = "x";
    ascii[121] = "y";
    ascii[122] = "z";
    ascii[123] = "{";
    ascii[124] = "|";
    ascii[125] = "}";
    ascii[126] = "~";

    return ascii;
}


/**
 * @brief Converts a printable ascii character to an integer
 *
 * @param character string The character to convert
 *
 * @returns the integer value of the character, or -1 if character isn't in range
 */
charToInt(character)
{
    debugPrint("in strings::charToInt()", "fn", level.nonVerbose);

    if (character.size > 1) {return -1;}
    for (integer = 32; integer <= 126; integer++) {
        if (character == level.ascii[integer]) {return integer;}
    }
    return -1;
}

/**
 * @brief Determines if a character is an ascii alpha character
 *
 * @param character string The character to test
 *
 * @returns true if it is an alpha character, false otherwise
 */
isAlpha(character)
{
    debugPrint("in strings::isAlpha()", "fn", level.lowVerbosity);

    if (character.size > 1) {return -1;}

    encodedInt = charToInt(character);
    if (((encodedInt >= 65) && (encodedInt <= 90)) ||
        ((encodedInt >= 97) && (encodedInt <= 122))) {return true;}

    return false;
}

/**
 * @brief Determines if a character is an ascii uppercase alpha character
 *
 * @param character string The character to test
 *
 * @returns true if it is an uppercase alpha character, false otherwise
 */
isUpper(character)
{
    debugPrint("in strings::isUpper()", "fn", level.lowVerbosity);

    if (character.size > 1) {return -1;}

    encodedInt = charToInt(character);
    if ((encodedInt >= 65) && (encodedInt <= 90)) {return true;}

    return false;
}

/**
 * @brief Determines if a character is an ascii lowercase alpha character
 *
 * @param character string The character to test
 *
 * @returns true if it is a lowercase alpha character, false otherwise
 */
isLower(character)
{
    debugPrint("in strings::isLower()", "fn", level.nonVerbose);

    if (character.size > 1) {return -1;}

    encodedInt = charToInt(character);
    if ((encodedInt >= 97) && (encodedInt <= 122)) {return true;}

    return false;
}

/**
 * @brief Determines if a character is an ascii numeric character
 *
 * @param character string The character to test
 *
 * @returns true if it is a numeric character, false otherwise
 */
isNumeric(character)
{
    debugPrint("in strings::isNumeric()", "fn", level.lowVerbosity);

    if (character.size > 1) {return -1;}

    encodedInt = charToInt(character);
    if ((encodedInt >= 48) && (encodedInt <= 57)) {return true;}

    return false;
}

/**
 * @brief Determines if a character is an ascii alphanumeric character
 *
 * @param character string The character to test
 *
 * @returns true if it is an alphanumeric character, false otherwise
 */
isAlphaNumeric(character)
{
    debugPrint("in strings::isAlphaNumeric()", "fn", level.lowVerbosity);

    if (character.size > 1) {return -1;}

    encodedInt = charToInt(character);
    if (((encodedInt >= 65) && (encodedInt <= 90)) ||
        ((encodedInt >= 97) && (encodedInt <= 122)) ||
        ((encodedInt >= 48) && (encodedInt <= 57))) {return true;}

    return false;
}


/**
 * @brief Determines if a character is an ascii symbol character
 *
 * @param character string The character to test
 *
 * @returns true if it is a symbol character, false otherwise
 */
isSymbol(character)
{
    debugPrint("in strings::isSymbol()", "fn", level.lowVerbosity);

    if (character.size > 1) {return -1;}
    return !isAlphaNumeric(character);
}

/**
 * @brief Converts an integer to a printable ascii character
 *
 * @param integer the integer to convert
 *
 * @returns the printable ascii character, or an empty string if the integer is out of range
 */
toAscii(integer)
{
    debugPrint("in strings::toAscii()", "fn", level.nonVerbose);

    if ((integer < 32) || (integer > 126)) {return "";}
    return level.ascii[integer];
}

/**
 * @brief Converts an US ASCII string to upper case
 *
 * @param string string the string to uppercase
 *
 * @returns the upper-cased string
 */
toUpper(string)
{
    debugPrint("in strings::toUpper()", "fn", level.nonVerbose);

    upperString = "";
    for (i=0; i < string.size; i++) {
        char = string[i];
        if (!isLower(char)){
            upperString += char;
            continue;
        }
        decimal = charToInt(char);
        upperDecimal = decimal - 32; // 32 is the offset is us ascii between upper and lower case characters
        charUpper = toAscii(upperDecimal);
        upperString += charUpper;
    }
//     debugPrint(string + ":" + upperString, "val");
    return upperString;
}


/**
 * @brief Joins the elements of an array together
 *
 * @param tokens string[] a reference to an array of strings to be joined
 * @param glue string the string to use to join the array elements
 *
 * @returns string The joined string
 */
join(tokens, glue) /// @todo enable joining a specific range within an array
{
    debugPrint("in strings::join()", "fn", level.veryLowVerbosity);

    // Max size of a string in *.gsc (we reserve a some chars so the string can
    // actually be used)
    maxStringLength = 1008;
    results = tokens[0];
    if (tokens.size > 1) {
        // if there are more tokens, add all of them except for the last one
        for (i=1; i<tokens.size - 1; i++) {
            if(results.size + glue.size + tokens[i].size > maxStringLength) {
                debugPrint(results, "val");
                // results will be trucated,
                // add on whatever characters we can
                temp = glue + tokens[i];
                space = maxStringLength - results.size;
                temp = getSubStr(temp, 0, space - 1);
                results += temp;
                // Add truncation notice
                notice = "--RESULTS TRUNCATED--";
                length = results.size - notice.size;
                results = getSubStr(results, 0, length - 1);
                results += notice;
                return results;
            }
            results += glue + tokens[i];
        }
        // now glue on the last token
        results += glue + tokens[tokens.size - 1];
    }

    return results;
}


/**
 * @brief Replaces a substring in a string with a replacement string
 *
 * @param haystack string the string to search through
 * @param oldText string the substring that will be replaced
 * @param newText string the replacement text
 *
 * @returns string The new string
 */
replace(haystack, oldText, newText)
{
    debugPrint("in strings::replace()", "fn", level.absurdVerbosity);

    matches = matches(haystack, oldText);
/*    for (i=0; i<matches.size; i++) {
        debugPrint("match indexes: " + matches[i], "val");
    }*/
    numberOfMatches = Int(matches.size / 2);
    if (numberOfMatches == 0) {return haystack;}
    else {
        text = "";
        ptr = 0; // pointer to keep track of where we are in haystack
        for (matchNumber=0; matchNumber < numberOfMatches; matchNumber++) {
            matchBegins = matches[Int(matchNumber * 2)];
            matchEnds =  matches[Int(matchNumber * 2) + 1];

            // grab all the characters up to where the match begins
            for (i=ptr; i<matchBegins; i++) {
                text += haystack[i];
            }
            // append the new text
            text += newText;
            // advance ptr to where the match ends
            ptr = matchEnds;
            if (ptr == haystack.size - 1) {
                // match ended at end of haystack, so we are done
                return text;
            } else {
                // increment pointer so we are ready to grab the first character
                // after this match
                ptr++;
            }

            if (matchNumber == numberOfMatches - 1) {
                // last match, so grab any remaining characters in haystack
                for (i=ptr; i<haystack.size; i++) {
                    text += haystack[i];
                }
            }
        }
        return text;
    }
}

/**
 * @brief Counts the number of times a token was matched in a string
 *
 * @param string string the string to search for the token in
 * @param token string the token to search for
 *
 * @returns integer The number of tokens found
 */
tokenMatchCount(string, token)
{
    debugPrint("in strings::tokenMatchCount()", "fn", level.nonVerbose);

    matches = matches(string, token);
    numberOfMatches = Int(matches.size / 2);
    return numberOfMatches;
}

/**
 * @brief Removes leading and trailing spaces
 *
 * @param string string the string to trim
 *
 * @returns string The trimmed string
 */
trim(string)
{
    debugPrint("in strings::trim()", "fn", level.lowVerbosity);

    // trim leading spaces
    for (i=0; i<string.size; i++) {
        if (string[i] == " ") {continue;}
        else {
            // we found first non-space character
            string = getSubStr(string, i, string.size);
            break;
        }
    }

    // trim trailing spaces
    for (i=string.size - 1; i>=0; i--) {
        if (string[i] == " ") {continue;}
        else {
            // we found first non-space character
            string = getSubStr(string, 0, i + 1);
            break;
        }
    }
    return string;
}


/**
 * @brief Removes leading and trailing spaces, and collapses internal spaces
 *
 * @param string string the string to collapse
 *
 * @returns string The collapsed string
 */
collapse(string)
{
    debugPrint("in strings::collapse()", "fn", level.lowVerbosity);

    string = trim(string);

    newString = "";
    for (i=0; i<string.size; i++) {
        if (string[i] != " ") {
            newString += string[i];
        } else {
            // current char is a space, add it, then advance to before next
            // non-space character
            newString += string[i];
            while (string[i] == " ") {
                i++;
            }
            i--;
        }
    }
//     debugPrint("newString: " + newString, "val");
    return newString;

}

/**
 * @brief Splits a string into an array of substrings
 *
 * @param string string the string to split
 * @param token string the token to split the string at
 *
 * @returns an array of containing the substrings
 */
split(string, token)
{
    debugPrint("in strings::split()", "fn", level.nonVerbose);

    results = [];
    matches = matches(string, token);
    numberOfMatches = Int(matches.size / 2);
    if (numberOfMatches == 0) {return results;}
    else {
        // for each character in original string
        matchNumber = 0;
        matchBegins = matches[0];
        matchEnds = matches[1];
        text = "";
//         debugPrint("string size: " + string.size, "val");
        for (i=0; i<string.size; i++) {
//             debugPrint("i: " + i, "val");
            if (i == matchBegins) // 0,2,4,6...
            {
                // We are at beginning of a matched token we want to skip

                // save the text we've built so far
                results[matchNumber] = text;
                text = "";

                if (matchEnds == string.size - 1) {
                    // this match ends at the end of the string, so we are done
                    return results;
                } else {
                    // advance i to the character after the end of this match
                    // so we don't iterate through uneeded characters, yet grab the
                    // correct character at the end of this iteration
                    i = matchEnds + 1;
                }

                // if there are more matches, prepare for them
                matchNumber++;
                if (matchNumber < numberOfMatches) {
                    // we have more matches, so keep going
                    matchBegins = matches[Int(matchNumber * 2)];
                    matchEnds =  matches[Int(matchNumber * 2) + 1];
                } else {
                    // Do Nothing
                    // no more matches, so just keep iterating
                    // so we can grab any remaining characters
                }
            }
            text += string[i];
//             debugPrint("text: " + text, "val");
        }
        results[matchNumber] = text;
    }
    return results;
}

/// unused, under development
newMatchTask(beginIndex, endIndex, type)
{
    debugPrint("in strings::newMatchTask()", "fn", level.lowVerbosity);

    task = spawnstruct();
    task.beginIndex = beginIndex;
    task.endIndex = endIndex;
    task.type = type; //"stringLiteral";
}

/**
 * @brief Performs non-greedy matching for a substring in a given string
 *
 * @param string string the string to search in
 * @param token string the token to search for
 *
 * @returns an array of indexes in the string where matches were found.
 * In the returned array, odd indices are the index in the original string where
 * the match begins, and the following even indices are the index in the original
 * string where the match ends.  This order is repeated for all matches.
 */
matches(string, token)
{
    debugPrint("in strings::matches()", "fn", level.absurdVerbosity);

    found = false;
    matchCount = 0;
    indices = [];
    isMatch = true;

    // trivial case where we match a single character; greediness does not apply
    if (token.size == 1) {
        for (i=0; i<string.size; i++) {
            if (string[i] == token) {
                indices[matchCount * 2] = i;        // save beginning of match location
                indices[(matchCount * 2) + 1] = i;  // Save end of match location
                matchCount++;
            }
        }
        return indices;
    } else {
        // non-greedy matching
        count = 0;
        for (i=0; i<string.size; i++) {
            // If the nth character in string matches the first character of token,
            // we have a potential match
            if (string[i] == token[0]) {
                isMatch = true;  // assume it is a match
                for (j=0; j<token.size; j++) {
                    // is this really a match?
                    if (string[i+j] != token[j]) {
                        // not a match
                        isMatch = false;
                        break; // fail early
                    }
                }
                if (isMatch) {
                    indices[matchCount * 2] = i;        // save beginning of match location
                    indices[(matchCount * 2) + 1] = i + token.size - 1;  // Save end of match location
                    matchCount++;
                    i = i + token.size - 1;
                } else {
                    // Do nothing
                }
            }
        }
        return indices;
    }

} // End matches() function


/**
 * @brief Performs sprintf-like variable interpolation
 *
 * @param formatString The string with parameter tokens
 * @param parameter1 string The first parameter to interpolate
 * @param parameter2 string The second parameter to interpolate
 * @param parameter3 string The third parameter to interpolate
 * @param parameter4 string The fourth parameter to interpolate
 * @param parameter5 string The fifth parameter to interpolate
 *
 * @returns the interpolated formatted string
 */
sprintf(formatString, parameter1, parameter2, parameter3, parameter4, parameter5)
{
    debugPrint("in strings::sprintf()", "fn", level.highVerbosity);

    // parse parameters
    count = 1;
    parameters = [];
    interpolatedString = formatString; // Init
    if (isDefined(parameter1)){
        if (isString(parameter1)) {
            parameters[count] = parameter1;
            count++;
        } else {
            // integer or float
            parameters[count] = parameter1; //numericToString(parameter0);
            count++;
        }
        interpolatedString = replace(interpolatedString, "$1", parameter1);
    }
    if (isDefined(parameter2)){
        if (isString(parameter2)) {
            parameters[count] = parameter2;
            count++;
        } else {
            // integer or float
            parameters[count] = parameter2; //numericToString(parameter0);
            count++;
        }
        interpolatedString = replace(interpolatedString, "$2", parameter2);
    }
    if (isDefined(parameter3)){
        if (isString(parameter3)) {
            parameters[count] = parameter3;
            count++;
        } else {
            // integer or float
            parameters[count] = parameter3; //numericToString(parameter0);
            count++;
        }
        interpolatedString = replace(interpolatedString, "$3", parameter3);
    }
    if (isDefined(parameter4)){
        if (isString(parameter4)) {
            parameters[count] = parameter4;
            count++;
        } else {
            // integer or float
            parameters[count] = parameter4; //numericToString(parameter0);
            count++;
        }
        interpolatedString = replace(interpolatedString, "$4", parameter4);
    }
    if (isDefined(parameter5)){
        if (isString(parameter5)) {
            parameters[count] = parameter5;
            count++;
        } else {
            // integer or float
            parameters[count] = parameter5; //numericToString(parameter0);
            count++;
        }
        interpolatedString = replace(interpolatedString, "$5", parameter5);
    }

    //start by finding matches for $
//     interpolatedString = replace(formatString, "$1", parameter1);
//     interpolatedString = replace(interpolatedString, "$2", parameter2);

    return interpolatedString;
}


/**
 * @brief Left pads a string to a specified length
 *
 * @param string The string to pad
 * @param paddingCharacter The character to use for padding
 * @param length The final length of the padded string
 *
 * @returns the padded string
 */
leftPad(string, paddingCharacter, length)
{
    debugPrint("in strings::leftPad()", "fn", level.medVerbosity);

    padding = "";
    while (string.size + padding.size < length) {
        padding += paddingCharacter;
    }
    string = padding + string;
    return string;
}


/**
 * @brief Right pads a string to a specified length
 *
 * @param string The string to pad
 * @param paddingCharacter The character to use for padding
 * @param length The final length of the padded string
 *
 * @returns the padded string
 */
rightPad(string, paddingCharacter, length)
{
    debugPrint("in strings::rightPad()", "fn", level.lowVerbosity);

    while (string.size < length) {
        string += paddingCharacter;
    }
    return string;
}

numericToString(numeric, precision)
{
    debugPrint("in strings::numericToString()", "fn", level.lowVerbosity);

    isInteger = false;
    if (Int(numeric) == numeric) {isInteger = true;}

    isNegative = false;
    if (numeric < 0) {
        isNegative = true;
        numeric = numeric * -1;
    }

    whole = Int(numeric);
    mantissa = numeric - whole;

    isFloat = false;
    if (mantissa > 0) {isFloat = true;}

    mantissaCoef = [];

    tenmillionths = 0.0000001;
    millionths = 0.000001;
    hundredthousandths = 0.00001;
    tenthousandths = 0.0001;
    thousandths = 0.001;
    hundreths = 0.01;
    tenths = 0.1;
    one = 1;
    ten = 10;
    hundred = 100;
    thousand = 1000;
    tenthousand = 10000;
    hundredthousand = 100000;
    million = 1000000;
    tenmillion = 10000000;
    hundredmillion = 100000000;

    value = whole; // copy whole
    result = "";
    asciiOffset = 48;

    if(value >= hundredmillion) {return "";} // overflow, for our purposes

    if (value >= tenmillion){
        // find and save the number of millions
        coef = Int(value / tenmillion);
        result += level.ascii[coef + asciiOffset];
        // subtract the millions from value
        value = value - coef * tenmillion;
    }
    if (value >= million){
        // find and save the number of millions
        coef = Int(value / million);
        result += level.ascii[coef + asciiOffset];
        // subtract the millions from value
        value = value - coef * million;
    }
    if (value >= hundredthousand){
        coef = Int(value / hundredthousand);
        result += level.ascii[coef + asciiOffset];
        value = value - coef * hundredthousand;
    }
    if (value >= tenthousand){
        coef = Int(value / tenthousand);
        result += level.ascii[coef + asciiOffset];
        value = value - coef * tenthousand;
    }
    if (value >= thousand){
        coef = Int(value / thousand);
        result += level.ascii[coef + asciiOffset];
        value = value - coef * thousand;
    }
    if (value >= hundred){
        coef = Int(value / hundred);
        result += level.ascii[coef + asciiOffset];
        value = value - coef * hundred;
    }
    if (value >= ten){
        coef = Int(value / ten);
        result += level.ascii[coef + asciiOffset];
        value = value - coef * ten;
    }
    if (value >= one){
        coef = Int(value / one);
        result += level.ascii[coef + asciiOffset];
        value = value - coef * one;
    }

    if (isFloat) {
        value = mantissa;

        if (value >= tenths){
            coef = Int(value / tenths);
            mantissaCoef[1] = coef;
            value = value - coef * tenths;
        }
        if (value >= hundreths){
            coef = Int(value / hundreths);
            mantissaCoef[2] = coef;
            value = value - coef * hundreths;
        }
        if (value >= thousandths){
            coef = Int(value / thousandths);
            mantissaCoef[3] = coef;
            value = value - coef * thousandths;
        }
        if (value >= tenthousandths){
            coef = Int(value / tenthousandths);
            mantissaCoef[4] = coef;
            value = value - coef * tenthousandths;
        }
        if (value >= hundredthousandths){
            coef = Int(value / hundredthousandths);
            mantissaCoef[5] = coef;
            value = value - coef * hundredthousandths;
        }
        if (value >= millionths){
            coef = Int(value / millionths);
            mantissaCoef[6] = coef;
            value = value - coef * millionths;
        }
        if (value >= tenmillionths){
            coef = Int(value / tenmillionths);
            mantissaCoef[7] = coef;
            value = value - coef * tenmillionths;
        }

        result += ".";

        // round mantissa using general rounding rules, not scientific rounding rules
        for (i=precision + 1; i>= 1;i--) {
            if (mantissaCoef[i] >= 5) {
                // need to round
                if (mantissaCoef[i - 1] <= 8) {
                    // add one and we are done
                    mantissaCoef[i - 1] += 1;
                    break;
                } else {
                    // set to 0, then iterate to round previous digit
                    mantissaCoef[i - 1] = 0;
                }
            }
        }

        // build mantissa part of string
        for (i=1; i<= precision; i++) {
            result += level.ascii[mantissaCoef[i] + asciiOffset];
        }
    }

    if (isNegative) {result = "-" + result;}

    return result;
}
