/* Not needed localizations. */
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
 * @brief Sorts an array using the quicksort algorithm
 *
 * @param data int[] The unsorted array
 * @param first integer The index of the first element of the array segment to be sorted
 * @param n integer The size of the array segment to be sorted
 *
 * The average case for quicksort is O(n log n), and the worst case is O(n^2). It
 * is good for sorting an unsorted array, and bad for sorting a array that is already
 * nearly sorted.
 *
 * This implementation is recursive.  The pivot is chosen as the average of three
 * random integers in the range.  For any segment smaller than 15 elements,
 * insertionsort is used to avoid the performance hit for the recursive calls.
 *
 * Ex.: To sort an entire array:
 *      \code data = quicksort(data, 0, data.size); \endcode
 *
 * @returns the sorted array segment
 */
quicksort(data, first, n)
{
    debugPrint("in array::quicksort()", "fn", level.lowVerbosity);

    /// Life would be so much easier if we could pass function parameters by reference
    if (n < 15) {
        // insertionsort is faster for 'small' arrays
        data = insertionsort(data, first, n);
    } else if (n > 1) {
        // Choose a prudent pivot so we get good performance
        pivot = Int((randomInt(n) + randomInt(n) + randomInt(n)) / 2);
        // Partition the array
        pivot = data[first];
        tooBigIndex = first + 1;
        tooSmallIndex = first + n - 1;

        while (tooBigIndex <= tooSmallIndex) {
            while ((tooBigIndex < n) && (data[tooBigIndex] <= pivot)) {
                tooBigIndex++;
            }
            while (data[tooSmallIndex] > pivot) {
                tooSmallIndex--;
            }
            if (tooBigIndex < tooSmallIndex) {
                temp = data[tooBigIndex];
                debugPrint("swapping data", "val");
                data[tooBigIndex] = data[tooSmallIndex];
                data[tooSmallIndex] = temp;
            }
        }

        data[first] = data[tooSmallIndex];
        data[tooSmallIndex] = pivot;
        pivotIndex = tooSmallIndex;

        // compute the size of the two pieces
        numberLeft = pivotIndex - first;
        numberRight = n - numberLeft - 1;

        // recurse to sort the two segments of the array
        data = quicksort(data, first, numberLeft);
        data = quicksort(data, pivotIndex + 1, numberRight);
    }
    return data;
}



/**
 * @brief Sorts an array using the insertionsort algorithm
 *
 * @param data int[] The unsorted array
 * @param first integer The index of the first element of the array segment to be sorted
 * @param n integer The size of the array segment to be sorted
 *
 * The average case for insertionsort is O(n^2), the worst case is O(n^2), and the best
 * case is O(n) comparisons and O(1) swaps.  Due to the recursion overhead of
 * quicksort, insertionsort is better for 'small' arrays of about 15 elements or less.
 * It is ideal for sorting arrays that are already nearly sorted.
 *
 * Ex.: To sort an entire array:
 *      \code data = insertionsort(data, 0, data.size); \endcode
 *
 * @returns the sorted array segment
 */
insertionsort(data, first, n)
{
    debugPrint("in array::insertionsort()", "fn", level.lowVerbosity);

    for (i=first + 1; i<n; i++) {
        // data[i] is added in the sorted sequence data[0, .. i-1]

        // copy data[i] so we can overwrite the data at ptr
        item = data[i];
        ptr = i;

        // keep moving the pointer to next smaller index until data[ptr - 1] is <= item
        while ((ptr > 0) && (data[ptr - 1] > item)) {
            // move hole to next smaller index
            data[ptr] = data[ptr - 1];
            ptr = ptr - 1;
        }
        // put the item copied item in the pointer's location
        data[ptr] = item;
    }
    return data;
}


/**
 * @brief Inserts a new value into the proper location in an already sorted array
 *
 * @param data int[] The unsorted array
 * @param first integer The index of the first element of the array segment to be sorted
 * @param newValue integer The value to insert into the sorted array
 *
 * If \c data isn't already sorted, the results will be unpredictable.
 *
 * Ex.: To insert a value into a sorted array:
 *      \code data = orderedInsert(data, 0, newValue); \endcode
 *
 * @returns the array with newValue inserted in the proper location
 */
orderedInsert(data, first, newValue)
{
    debugPrint("in array::orderedInsert()", "fn", level.veryLowVerbosity);

    i = data.size;
    // Starting at the right end of the array, shift elements larger than
    // newValue to the right until we are where newValue belongs, then put newValue
    // there.
    while ((i > first) && (newValue < data[i-1]))
    {
        data[i] = data[i-1];
        i--;
    }
    data[i] = newValue;
    return data;
}


/**
 * @brief Removes a value from an already sorted array
 *
 * @param data int[] The sorted array
 * @param first integer The index of the first element of the array
 * @param value integer The value to remove from the sorted array
 *
 * If \c data isn't already sorted, the results will be unpredictable.
 *
 * Ex.: To remove a value from a sorted array:
 *      \code data = orderedRemove(data, 0, value); \endcode
 *
 * @returns the array with \c value removed
 */
orderedRemove(data, first, value)
{
    debugPrint("in array::orderedRemove()", "fn", level.nonVerbose);

    index = binarySearch(data, first, data.size - 1, value);
    if (index == -1) {
        // value isn't in data, so nothing to do
        return data;
    }
    i = index;
    // Starting at the value's index, shift elements at greater indices left one spot
    while (i < data.size)
    {
        data[i] = data[i+1];
        i++;
    }
    return data;
}


/**
 * @brief Remove the element at the given index and returns the new array
 *
 * @param data The array to remove the element from
 * @param index The index of the element to remove
 *
 * @returns The new array
 */
removeElementByIndex(data, index)
{
    debugPrint("in array::removeElementByIndex()", "fn", level.nonVerbose);

    // If index is out of range high or low, do nothing
    if (index > data.size - 1) {return data;}
    else if (index < 0) {return data;}

    i = index;
    // Starting at the value's index, shift elements at greater indices left one spot
    while (i < data.size)
    {
        data[i] = data[i+1];
        i++;
    }
    return data;
}



/**
 * @brief Finds the index of a given value in a sorted array
 *
 * @param data int[] The array to search
 * @param leftBound integer The index of left bound of the arry segment to search in
 * @param rightBound integer The index of right bound of the arry segment to search in
 * @param value integer The value to search for
 *
 * If \c data isn't already sorted, the results will be unpredictable.
 *
 * Ex.: To search for a value in a sorted array:
 *      \code index = binarySearch(data, 0, data.size - 1, value); \endcode
 *
 * @returns the index of the value, if found, otherwise -1
 */
binarySearch(data, leftBound, rightBound, value)
{
    debugPrint("in array::binarySearch()", "fn", level.nonVerbose);

    // continue searching while range [leftBound,rightBound] is not empty
    while (leftBound <= rightBound)
    {
        //calculate the midpoint
        midpoint = Int((leftBound + rightBound) / 2);

        // determine which subarray to search
        if (data[midpoint] < value) {
            // change leftBound to search upper subarray
            leftBound = midpoint + 1;
        } else if (data[midpoint] > value ) {
            // change rightBound to search lower subarray
            rightBound = midpoint - 1;
        } else {
            // value found at midpoint
            return midpoint;
        }
    }
    // value not found
    noticePrint("Value " + value + " was not found in the array.");
    return -1;
}


/**
 * @brief Determines whether \c value is an element of \c data
 *
 * @param data string[] The array to search
 * @param value string The value to search for
 *
 * @returns boolean whether value is an element of data for not
 */
inArray(data, value)
{
    debugPrint("in array::inArray()", "fn", level.medVerbosity);

    for (i=0; i<data.size; i++) {
        found = true;
        if (data[i].size != value.size) {
            found = false;
            continue;
        }
        for (j=0; j<value.size; j++) {
            // compare each character of the strings
            if (data[i][j] != value[j]) {
                // this data element does not match value; try next data element
                found = false;
                break;
            }
        }
        // return on first match
        if(found) {return true;}
    }
    // value not found
//     noticePrint("Value " + value + " was not found in the array.");
    return false;
}

/**
 * @brief Determines whether \c value is an element of \c data
 *
 * @param data int[] The array to search
 * @param value integer The value to search for
 *
 * @returns boolean whether value is an element of data for not
 */
inIntArray(data, value)
{
    debugPrint("in array::inIntArray()", "fn", level.nonVerbose);

    for (i=0; i<data.size; i++) {
        if (data[i] == value) {
            // this data element does not match value; try next data element
            return true;
        }
    }
    // value not found
//     noticePrint("Value " + value + " was not found in the array.");
    return false;
}
