/* Not required localizations. */
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
 * @file matrix.gsc A numerical linear algebra libaray
 */

#include scripts\include\utility;
#include scripts\include\strings;

/**
 * @brief Creates a n by n identity matrix
 *
 * @param n integer the dimension of the identity matrix
 *
 * @returns matrix The identity matrix
 */
eye(n)
{
    debugPrint("in matrix::eye()", "fn", level.lowVerbosity);

    identity = zeros(n, n);
    for (i=0; i<n; i++) {
        identity.data[i][i] = 1;
    }
    return identity;
}

/**
 * @brief Returns the value at the given address
 *
 * @param matrix The matrix containing the value to return
 * @param row integer The row containing the value to return
 * @param column integer The column containing the value to return
 *
 * @returns numeric The value at the given address
 */
value(matrix, row, column)
{
    debugPrint("in matrix::value()", "fn", level.lowVerbosity);

    // translate the row, column to array indices
    rowAddress = row - 1;
    columnAddress = column - 1;

    if ((row > matrix.rowCount) || (column > matrix.columnCount) ||
        (row == 0) || (column == 0)) {
        errorPrint("Address (" + row + ", " + column + ") exceeds the dimensions of the matrix.");
        printMatrix(matrix);
        return undefined;
    }
    data = matrix.data[rowAddress][columnAddress];
    return data;
}

/**
 * @brief Sets the value at the given address
 *
 * @param matrix The matrix  to put the data in
 * @param row integer The row to put the data in
 * @param column integer The column to put the data in
 * @param data numeric The data to put at the given address
 *
 * Can also set directly, ex.: \code matrix.data[row-1][column-1] = data; \endcode
 *
 * @returns boolean True on success, false otherwise
 */
setValue(matrix, row, column, data)
{
    debugPrint("in matrix::setValue()", "fn", level.lowVerbosity);

    // translate the row, column to array indices
    rowAddress = row - 1;
    columnAddress = column - 1;

    if ((row > matrix.rowCount) || (column > matrix.columnCount) ||
        (row == 0) || (column == 0)) {
        errorPrint("Address (" + row + ", " + column + ") exceeds the dimensions of the matrix.");
        printMatrix(matrix);
        return false;
    }
    matrix.data[rowAddress][columnAddress] = data;
    return true;
}

/**
 * @brief Creates a row vector
 *
 * @param data[] array The values to use to populate the row vector
 *
 * @returns matrix The row vector
 */
rowVector(data)
{
    debugPrint("in matrix::rowVector()", "fn", level.lowVerbosity);

    matrix = spawnStruct();
    matrix.rowCount = 1;
    matrix.columnCount = data.size;
    matrix.data = [];
    for (i=0; i<matrix.rowCount; i++) {
        for (j=0; j<matrix.columnCount; j++) {
            matrix.data[i][j] = data[j];
        }
    }
    matrix.isRowVector = true;
    matrix.isColumnVector = false;
    return matrix;
}

/**
 * @brief Creates a column vector
 *
 * @param data[] array The values to use to populate the column vector
 *
 * @returns matrix The column vector
 */
columnVector(data)
{
    debugPrint("in matrix::columnVector()", "fn", level.lowVerbosity);

    matrix = spawnStruct();
    matrix.rowCount = data.size;
    matrix.columnCount = 1;
    matrix.data = [];
    for (i=0; i<matrix.rowCount; i++) {
        for (j=0; j<matrix.columnCount; j++) {
            matrix.data[i][j] = data[i];
        }
    }
    matrix.isRowVector = false;
    matrix.isColumnVector = true;
    return matrix;
}

/**
 * @brief Creates an m x n sparse matrix (zeros at every address)
 *
 * @param m integer The number of rows in the matrix
 * @param n integer The number of columns in the matrix
 *
 * @returns matrix The created matrix
 */
zeros(m, n)
{
    debugPrint("in matrix::zeros()", "fn", level.lowVerbosity);

    matrix = spawnStruct();
    matrix.rowCount = m;
    matrix.columnCount = n;
    matrix.data = [];

    for (i=0; i<matrix.rowCount; i++) {
        for (j=0; j<matrix.columnCount; j++) {
            matrix.data[i][j] = 0;
        }
    }
    matrix.isRowVector = false;
    matrix.isColumnVector = false;
    if (matrix.columnCount == 1) {matrix.isColumVector = true;}
    if (matrix.rowCount == 1) {matrix.isRowVector = true;}
    return matrix;
}

/**
 * @brief Creates an m x n matrix (ones at every address)
 *
 * @param m integer The number of rows in the matrix
 * @param n integer The number of columns in the matrix
 *
 * @returns matrix The created matrix
 */
ones(m, n)
{
    debugPrint("in matrix::ones()", "fn", level.lowVerbosity);

    matrix = spawnStruct();
    matrix.rowCount = m;
    matrix.columnCount = n;
    matrix.data = [];
    for (i=0; i<matrix.rowCount; i++) {
        for (j=0; j<matrix.columnCount; j++) {
            matrix.data[i][j] = 1;
        }
    }
    matrix.isRowVector = false;
    matrix.isColumnVector = false;
    if (matrix.columnCount == 1) {matrix.isColumVector = true;}
    if (matrix.rowCount == 1) {matrix.isRowVector = true;}
    return matrix;
}

/**
 * @brief Creates the transpose of the given matrix
 *
 * @param matrix The matrix to transpose
 *
 * @returns matrix The transposed matrix
 */
transpose(matrix)
{
    debugPrint("in matrix::transpose()", "fn", level.lowVerbosity);

    // set up a matrix to hold the transposition
    transposedMatrix = spawnStruct();
    transposedMatrix.rowCount = matrix.columnCount;
    transposedMatrix.columnCount = matrix.rowCount;
    transposedMatrix.data = [];
    transposedMatrix.isRowVector = false;
    transposedMatrix.isColumnVector = false;
    if (transposedMatrix.columnCount == 1) {transposedMatrix.isColumVector = true;}
    if (transposedMatrix.rowCount == 1) {transposedMatrix.isRowVector = true;}

    row = 0;
    col = 0;
    for (i=0; i<transposedMatrix.rowCount; i++) {
        for (j=0; j<transposedMatrix.columnCount; j++) {
            transposedMatrix.data[i][j] = matrix.data[row][col];
            row++;
        }
        row = 0;
        col++;
    }

    return transposedMatrix;
}

/**
 * @brief Augments a matrix
 *
 * @param matrix The matrix to augment
 * @param augment The column vector to augment the matrix with. If undefined, augments with the zero vector
 *
 * @returns matrix The augmented matrix, or undefined if \c augment was defined but the dimensions mismatch
 */
augment(matrix, augment)
{
    debugPrint("in matrix::augment()", "fn", level.lowVerbosity);

    if (!isDefined(augment)) {augment = zeros(matrix.rowCount, 1);}

    if (matrix.rowCount != augment.rowCount) {
        errorPrint("The augment matrix must have the same number of rows as the original matrix.");
        return undefined;
    }

    newColumnCount = matrix.columnCount + augment.columnCount;
    col = 0;
    for (i=0; i<matrix.rowCount; i++) {
        for (j=matrix.columnCount; j<newColumnCount; j++) {
            matrix.data[i][j] = augment.data[i][col];
            col++;
        }
        col = 0;
    }

    matrix.columnCount = newColumnCount;
    return matrix;
}

/**
 * @brief Appends a matrix below another matrix
 *
 * @param A The top matrix
 * @param B The matrix to append below matrix \c A
 *
 * @returns matrix The new matrix, or undefined if the dimensions mismatch
 */
appendMatrix(A, B)
{
    debugPrint("in matrix::appendMatrix()", "fn", level.lowVerbosity);

    if (A.columnCount != B.columnCount) {
        errorPrint("Matrices to be appended must have the same number of columns.");
        return undefined;
    }

    AB = spawnStruct();
    AB.rowCount = A.rowCount + B.rowCount;
    AB.columnCount = A.columnCount;
    AB.data = [];

    // copy A's data into AB
    for (i=0; i<A.rowCount; i++) {
        for (j=0; j<A.columnCount; j++) {
            AB.data[i][j] = A.data[i][j];
        }
    }

    // copy B's data into AB
    bRow = 0;
    for (i=A.rowCount; i<AB.rowCount; i++) {
        for (j=0; j<A.columnCount; j++) {
            AB.data[i][j] = B.data[bRow][j];
        }
        bRow++;
    }

    AB.isRowVector = false;
    AB.isColumnVector = false;
    if (AB.columnCount == 1) {AB.isColumVector = true;}

    return AB;
}

/**
 * @brief Multiplies a matrix by a scalar
 *
 * @param matrix The matrix
 * @param scalar The scalar to multiply the matrix by
 *
 * @returns matrix The scaled matrix
 */
scalarMultiplication(matrix, scalar)
{
    debugPrint("in matrix::scalarMultiplication()", "fn", level.lowVerbosity);

    for (i=0; i<matrix.rowCount; i++) {
        for (j=0; j<matrix.columnCount; j++) {
            matrix.data[i][j] = matrix.data[i][j] * scalar;
        }
    }

    return matrix;
}

/**
 * @brief Adds two matrices
 *
 * @param A The first matrix
 * @param B The second matrix
 *
 * @returns matrix The new matrix, or undefined if the dimensions mismatch
 */
addMatrices(A, B)
{
    debugPrint("in matrix::addMatrices()", "fn", level.lowVerbosity);

    if ((A.rowCount != B.rowCount) || (A.columnCount != B.columnCount)) {
        errorPrint("You cannot add matrices of different sizes.");
        return undefined;
    }

    for (i=0; i<A.rowCount; i++) {
        for (j=0; j<A.columnCount; j++) {
            A.data[i][j] = A.data[i][j] + B.data[i][j];
        }
    }

    return A;
}

/**
 * @brief Multiplies two matrices
 *
 * @param A The left matrix
 * @param B The right matrix
 *
 * @returns matrix The new matrix, or undefined if the dimensions mismatch
 */
matrixMultiply(A, B)
{
    debugPrint("in matrix::matrixMultiply()", "fn", level.lowVerbosity);

    if (A.columnCount != B.rowCount) {
        errorPrint("Dimension mis-match.  The number of columns of A must match the number of rows of B.");
        return undefined;
    }

    AB = spawnStruct();
    AB.rowCount = A.rowCount;
    AB.columnCount = B.columnCount;
    AB.data = [];

    for (i=0; i<AB.rowCount; i++) {
        for (j=0; j<AB.columnCount; j++) {
            // for each position in AB
            result = 0;
            for (n=0; n<A.rowCount; n++) {
                result += A.data[i][n] * B.data[n][j];
            }
            AB.data[i][j] = result;
            result = 0;
        }
    }

    AB.isRowVector = false;
    AB.isColumnVector = false;
    if (AB.columnCount == 1) {AB.isColumVector = true;}
    if (AB.rowCount == 1) {AB.isRowVector = true;}

    return AB;
}

/**
 * @brief Raises a matrix to a power
 *
 * @param A The matrix
 * @param k The power to raise the matrix to
 *
 * @returns matrix The new matrix, or undefined if the matrix isn't square
 */
matrixPower(A, k)
{
    debugPrint("in matrix::matrixPower()", "fn", level.lowVerbosity);

    if (A.rowCount != A.columnCount) {
        errorPrint("Matrix isn't square.");
        return undefined;
    }

    /// @todo test me
    matrix = spawnStruct();
    matrix.rowCount = A.rowCount;
    matrix.columnCount = A.columnCount;
    matrix.data = [];

    matrix = A;
    for (i=0; i<k - 1; i++) {
        matrix = matrixMultiply(matrix, A);
    }

    matrix.isRowVector = false;
    matrix.isColumnVector = false;
    if (matrix.columnCount == 1) {matrix.isColumVector = true;}
    if (matrix.rowCount == 1) {matrix.isRowVector = true;}

    return matrix;
}

/**
 * @brief Calculates the determinant of a matrix
 *
 * @param A The matrix to calculate the determinant of
 *
 * @returns numeric The determinant of \c A, or undefined if the matrix isn't square
 */
determinant(A)
{
    debugPrint("in matrix::determinant()", "fn", level.lowVerbosity);

    if (A.rowCount != A.columnCount) {
        errorPrint("Matrix isn't square.");
        return undefined;
    }

    if (A.rowCount == 2) {
        // simple 2 x 2 determinant
        detA = A.data[0][0] * A.data[1][1] - A.data[0][1] * A.data[1][0];
        return detA;
    } else {
        // Co-factor expansion is far too slow for large matrices.  Instead, we
        // reduce A to upper triangluar form.  Then, if there is a pivot in every
        // row, the determinant is (-1)^r * (product of the pivots), where r is
        // the number of row swaps required to put A in upper triangular form.
        // Otherwise, the determinant is zero.  Lay, Linear Algebra, 4th ed., pg. 171

        B = spawnStruct();
        B.rowCount = A.rowCount;
        B.columnCount = A.columnCount;
        B.data = [];

        // copy A's data into B
        for (i=0; i<A.rowCount; i++) {
            for (j=0; j<A.columnCount; j++) {
                B.data[i][j] = A.data[i][j];
            }
        }
        printMatrix(B);

        pivotRow = 0;
        pivotColumn = 0;
        r = 0;

        while (pivotColumn < B.columnCount) {
            foundPivot = findForwardPivot(B, pivotRow, pivotColumn);

            if (isDefined(foundPivot)) {
                if (foundPivot[0] != pivotRow) {
                    // swap rows to put pivot row in pivot position
                    B = swapRows(B, foundPivot[0], pivotRow);
                    r++;
//                     printMatrix(B);
                }

                // create zeroes in all entries below the pivot
                for (j=pivotRow + 1; j<B.rowCount; j++) {
                    if (B.data[j][pivotColumn] != 0) {
                        // found a row with a non-zero entry, so make the entry a zero
                        pivotValue = B.data[pivotRow][pivotColumn];
                        scalar = -1 * (B.data[j][pivotColumn] / pivotValue);
//                         debugPrint("pivotValue: " + pivotValue + " scalar: " + scalar + " j: " + j, "val");
                        B = scaleAddRow(B, scalar, pivotRow, j);
//                         printMatrix(B);
                    }
                }
                // we are done with this column
            } else {
                // this matrix has no more pivots, so we are in upper triangular form
                break;
            }
            // Begin searching for next pivot position one row down and one column right
            pivotRow++;
            pivotColumn++;
        }
        // There are no more columns to process, so we are in upper triangular form
        printMatrix(B);

        n = countPivots(B);
        if (n == B.rowCount) {
            // B is invertible, so calculate determinant
            // calculate the product of the pivots
            pivotProduct = 0;
            for (i=0; i<B.rowCount; i++) {
                if (i == 0) {pivotProduct = B.data[i][i];}
                else {
                    pivotProduct = pivotProduct * B.data[i][i];
                }
            }
            // is r is odd, negate the pivot product
            if (r % 2 == 1) {pivotProduct = -1 * pivotProduct;}
            return pivotProduct;
        } else {
            // the determinant is zero
            return 0;
        }
    }
}

/**
 * @brief Determines if a matrix is invertible
 *
 * @param A The matrix to test for invertibility
 *
 * @returns boolean True if the matrix is invertible, false otherwise
 */
isInvertible(A)
{
    debugPrint("in matrix::isInvertible()", "fn", level.lowVerbosity);

    if (A.rowCount != A.columnCount) {
        return false;
    }

    if (A.rowCount == 2) {
        // simple 2 x 2 determinant
        detA = determinant(A);
        if (detA == 0) {return false;}
        else {return true;}
    } else {
        B = spawnStruct();
        B.rowCount = A.rowCount;
        B.columnCount = A.columnCount;
        B.data = A.data;
        B = ref(B);
//         printMatrix(B);
        // By I.M.T. part c, Linear Algebra, Lay 4th Ed. pg 112
        n = countPivots(B);
//         debugPrint("n: " + n, "val");
        if (n == A.rowCount) {return true;}
        else {return false;}
    }
}

/**
 * @brief Counts the pivots in a matrix
 *
 * @param matrix The matrix to count the pivots of
 *
 * @returns integer The number of pivots in \c matrix
 */
countPivots(matrix)
{
    debugPrint("in matrix::countPivots()", "fn", level.lowVerbosity);

    /// @internal, so indices are zero-indexed
    pivotCount = 0;
    for (i=0; i<matrix.rowCount; i++) {
        for (j=0; j<matrix.columnCount; j++) {
            if (matrix.data[i][j] != 0) {
                // this is a pivot
                pivotCount++;
                break;
            }
        }
    }
    return pivotCount;
}


/**
 * @brief Calculates the inverse of a matrix
 *
 * @param A The matrix to find the inverse of
 *
 * @returns matrix The inverted matrix, or undefined if the matrix isn't invertible
 */
inverseMatrix(A)
{
    debugPrint("in matrix::inverseMatrix()", "fn", level.lowVerbosity);

    if(!isInvertible(A)) {return undefined;}

    if (A.rowCount == 2) {
        // the isInvertible() check above ensures we are invertible
        detA = determinant(A);
        B = spawnStruct();
        B.rowCount = 2;
        B.columnCount = 2;
        B.data = [];

        // for matrix [a,b;c,d]
        // swap a and d
        B.data[0][0] = A.data[1][1];
        B.data[1][1] = A.data[0][0];
        // negate b and c
        B.data[1][0] = -1 * A.data[1][0];
        B.data[0][1] = -1 * A.data[0][1];
        aInverse = scalarMultiplication(B, (1 / detA));
        return aInverse;
    } else {
        B = spawnStruct();
        B.rowCount = A.rowCount;
        B.columnCount = 2 * B.rowCount;
        B.data = [];
        B = augment(A, eye(A.rowCount));
        B = rref(B);
        C = partition(B, ":", ((B.columnCount / 2) + 1) + ":" + B.columnCount);
        return C;

    }
}

/**
 * @brief Returns part of a matrix
 *
 * @param matrix The matrix original matrix
 * @param rows The rows of \c matrix to include in the new matrix
 * @param columns The columns of \c matrix to include in the new matrix
 *
 * @returns matrix The new matrix
 */
partition(matrix, rows, columns)
{
    debugPrint("in matrix::partition()", "fn", level.lowVerbosity);

    if (rows == ":") {
        // want all rows
        beginRow = 0;
        endRow = matrix.rowCount - 1;
        numberOfRows = matrix.rowCount;
    } else if (rows.size == 1) {
        // just want a single row
        rows = int(rows);
        beginRow = rows - 1;
        endRow = rows - 1;
        numberOfRows = 1;
    } else {
        beginRow = int(rows[0]) - 1;
        endRow = int(rows[2]) - 1;
        numberOfRows = endRow - beginRow + 1;
    }

    if (columns == ":") {
        // want all columns
        beginColumn = 0;
        endColumn = matrix.columnCount - 1;
        numberOfColumns = matrix.columnCount;
    } else if (columns.size == 1) {
        // just want a single column
        columns = int(columns);
        beginColumn = columns - 1;
        endColumn = columns - 1;
        numberOfColumns = 1;
    } else {
        beginColumn = int(columns[0]) - 1;
        endColumn = int(columns[2]) - 1;
        numberOfColumns = endColumn - beginColumn + 1;
    }

    /// @todo make sure requested partition doesn't exceed range of \c matrix
    partition = spawnStruct();
    partition.rowCount = endRow - beginRow + 1;
    partition.columnCount = endColumn - beginColumn + 1;
    partition.data = [];

    row = 0;
    col = 0;
    for (i=beginRow; i<beginRow + numberOfRows; i++) {
        for (j=beginColumn; j<beginColumn + numberOfColumns; j++) {
            partition.data[row][col] = matrix.data[i][j];
            debugPrint("matrix.data[i][j]: " + matrix.data[i][j], "val");
            debugPrint("partition.data[row][col]: " + partition.data[row][col], "val");
            col++;
        }
        col = 0;
        row++;
    }

    partition.isRowVector = false;
    partition.isColumnVector = false;
    if (partition.columnCount == 1) {partition.isColumVector = true;}
    if (partition.rowCount == 1) {partition.isRowVector = true;}

    return partition;
}


/**
 * @brief Formats and prints a matrix to the debug log
 *
 * @param matrix The matrix to print
 *
 * @returns nothing
 */
printMatrix(matrix)
{
    debugPrint("in matrix::printMatrix()", "fn", level.lowVerbosity);

    line = "";
    lines = "Matrix (" + matrix.rowCount + " x " + matrix.columnCount + "):\n";
    for (i=0; i<matrix.data.size; i++) {
        for (j=0; j<matrix.data[0].size; j++) {
            line += "\t" + matrix.data[i][j];
        }
        lines += line + "\n";
        line = "";
    }
    debugPrint("Matrix size (by property) (" + matrix.rowCount + " x " + matrix.columnCount + ")", "val");
    debugPrint("Actual matrix size (" + matrix.data.size + " x " + matrix.data[0].size + ")", "val");

    logPrint(lines);
}

/**
 * @brief Creates a matrix from a Matlab-like matrix specification
 * Example: \code L = stringToMatrix("[1 2 3 4;5 6 7 8;9 4 3 2]"); \endcode
 * N.B. There is currently no way for to cast a string to a float, so we are
 * limited to integers
 *
 * @param string string The Matlab-like matrix specification
 *
 * @returns matrix The created matrix
 */
stringToIntegerMatrix(string)
{
    debugPrint("in matrix::stringToIntegerMatrix()", "fn", level.lowVerbosity);

    matrix = spawnStruct();
    matrix.data = [];

    // strip off brackets
    string = collapse(string);
    string = getSubStr(string, 1, string.size - 1);

    rows = split(string, ";");
    matrix.rowCount = rows.size;
    for (i=0; i<rows.size; i++) {
        if(isSubStr(rows[i], ",")) {
            // split by commas
            columns = split(trim(rows[i]), ",");
            for (j=0; j<columns.size; j++) {
                matrix.data[i][j] = int(trim(columns[j]));
            }
        } else {
            // split by whitespace
            columns = split(trim(rows[i]), " ");
            matrix.columnCount = columns.size;
            for (j=0; j<columns.size; j++) {
                matrix.data[i][j] = int(trim(columns[j]));
            }
        }
    }
    matrix.isRowVector = false;
    matrix.isColumnVector = false;
    if (matrix.columnCount == 1) {matrix.isColumVector = true;}
    if (matrix.rowCount == 1) {matrix.isRowVector = true;}

    return matrix;
}

/**
 * @brief Performs the elemntary row operation: scaling a row
 *
 * @param matrix The matrix to operate on
 * @param scalar The scalar to multiply \c row by
 * @param row The row to muliply by \c scalar
 *
 * @returns matrix The new matrix
 */
scaleRow(matrix, scalar, row)
{
    debugPrint("in matrix::scaleRow()", "fn", level.lowVerbosity);

    /// @internal, so row is zero-indexed
    for (j=0; j<matrix.columnCount; j++) {
        matrix.data[row][j] = matrix.data[row][j] * scalar;
    }
    return matrix;
}

/**
 * @brief Performs the elemntary row operation: scaling and adding to row
 *
 * @param matrix The matrix to operate on
 * @param scalar The scalar to multiply row \c k by
 * @param k The row to be scaled \c scalar
 * @param n The row to add the scaled row \c k to
 *
 * @returns matrix The new matrix
 */
scaleAddRow(matrix, scalar, k, n)
{
    debugPrint("in matrix::scaleAddRow()", "fn", level.lowVerbosity);

    /// @internal, so row is zero-indexed
    for (j=0; j<matrix.columnCount; j++) {
        matrix.data[n][j] = matrix.data[k][j] * scalar + matrix.data[n][j];
    }
    return matrix;
}

/**
 * @brief Performs the elemntary row operation: swapping rows
 *
 * @param matrix The matrix to operate on
 * @param k The first row
 * @param n The second row
 *
 * @returns matrix The new matrix with the rows swapped
 */
swapRows(matrix, k, n)
{
    debugPrint("in matrix::swapRows()", "fn", level.lowVerbosity);

    /// @internal, so row is zero-indexed
    for (j=0; j<matrix.columnCount; j++) {
        temp = matrix.data[k][j];
        matrix.data[k][j] = matrix.data[n][j];
        matrix.data[n][j] = temp;
    }
    return matrix;
}

/**
 * @brief Puts a matrix in row echelon format
 *
 * @param matrix The matrix to reduce
 *
 * @returns matrix The reduced matrix
 */
ref(matrix)
{
    debugPrint("in matrix::ref()", "fn", level.lowVerbosity);

    pivotRow = 0;
    pivotColumn = 0;

    while (pivotColumn < matrix.columnCount) {
        foundPivot = findForwardPivot(matrix, pivotRow, pivotColumn);

        if (isDefined(foundPivot)) {
            if (foundPivot[0] != pivotRow) {
                // swap rows to put pivot row in pivot position
                matrix = swapRows(matrix, foundPivot[0], pivotRow);
            }
            // make the pivot a one
            matrix = scaleRow(matrix, 1 / matrix.data[pivotRow][pivotColumn], pivotRow);

            // create zeroes in all entries below the pivot
            for (j=pivotRow + 1; j<matrix.rowCount; j++) {
                if (matrix.data[j][pivotColumn] != 0) {
                    // found a row with a non-zero entry, so make the entry a zero
                    matrix = scaleAddRow(matrix, matrix.data[j][pivotColumn] * -1, pivotRow, j);
                }
            }
            // we are done with this column
        } else {
            // this matrix has no more pivots, so we are in row echelon form
            return matrix;
        }
        // Begin searching for next pivot position one row down and one column right
        pivotRow++;
        pivotColumn++;
    }
    // There are no more columns to process, so we are in row echelon form
    return matrix;
}

/**
 * @brief Puts a matrix in reduced-row echelon format
 *
 * @param matrix The matrix to reduce
 *
 * @returns matrix The row-reduced matrix
 */
rref(matrix)
{
    debugPrint("in matrix::rref()", "fn", level.lowVerbosity);

    pivotRow = matrix.rowCount - 1;
    pivotColumn = 0;

    // reduce matrix to row echelon form
    matrix = ref(matrix);

    while (pivotColumn < matrix.columnCount) {
        foundPivot = findBackwardPivot(matrix, pivotRow);

        if (isDefined(foundPivot)) {
            pivotRow = foundPivot[0];
            pivotColumn = foundPivot[1];
            debugPrint("pivotRow: " + pivotRow + " pivotColumn: " + pivotColumn, "val");

            // the ref() call ensures the pivot is already a one

            // create zeroes in all entries above the pivot
            for (j=pivotRow - 1; j>=0; j--) {
                if (matrix.data[j][pivotColumn] != 0) {
                    // found a row with a non-zero entry, so make the entry a zero
                    matrix = scaleAddRow(matrix, matrix.data[j][pivotColumn] * -1, pivotRow, j);
                }
            }
            // we are done with this column
        } else {
            // this matrix has no more pivots, so we are in reduced row echelon form
            return matrix;
        }
        // Begin searching for next pivot position one row up
        pivotRow--;
    }
    // There are no more rows to process, so we are in row echelon form
    return matrix;
}

/**
 * @brief Finds the next pivot position for backward phase
 *
 * @param matrix the matrix to use
 * @param row the zero-indexed row to begin looking in
 *
 * @returns the next pivot position
 */
findBackwardPivot(matrix, row)
{
    debugPrint("in matrix::findBackwardPivot()", "fn", level.lowVerbosity);

    /// @internal, so indices are zero-indexed

    address = [];
    pivotRow = row;
    pivotColumn = 0;
    for (i=row; i>=0; i--) {
        for (j=0; j<matrix.columnCount; j++) {
            if (matrix.data[i][j] != 0) {
                // this is the pivot position
                address[0] = i;
                address[1] = j;
                return address;
            }
        }
    }
    // no pivot found!
    return undefined;
}

/**
 * @brief Solves a matrix equation Ax = b
 * N.B. Not fully implemented yet
 *
 * @param A matrix The matrix
 * @param b matrix The column vector to augment \c A. If undefined, augments with the zero vector
 *
 * @returns the next pivot position
 */
solve(A, b)
{
    debugPrint("in matrix::solve()", "fn", level.lowVerbosity);

    matrix = augment(A, b);

    matrix = rref(matrix);

    /// @todo should return x, but for now, return the row-reduced matrix
    return matrix;
}

/**
 * @brief Finds the next pivot position for forward phase
 *
 * @param matrix the matrix to use
 * @param row the zero-indexed row to begin looking in
 * @param column the zero-indexed column to begin with
 *
 * @returns the next pivot position
 */
findForwardPivot(matrix, row, column)
{
    debugPrint("in matrix::findForwardPivot()", "fn", level.lowVerbosity);

    /// @internal, so indices are zero-indexed

    /// Our pivot will the the largest absolute value in the pivot column to help
    /// limit round-off errors
    address = [];
    partialPivotValue = 0;
    partialPivotRow = row;
    partialPivotColumn = column;
    isNonZeroColumn = false;
    for (i=column; i<matrix.columnCount; i++) {
        for (j=row; j<matrix.rowCount; j++) {
            if (matrix.data[j][i] != 0) {
                isNonZeroColumn = true;
            }
            if (abs(matrix.data[j][i]) > partialPivotValue) {
                // we have a new partial pivot
                partialPivotValue = abs(matrix.data[j][i]);
                partialPivotRow = j;
                partialPivotColumn = i;
            }
        }
        if (isNonZeroColumn) {
            address[0] = partialPivotRow;
            address[1] = partialPivotColumn;
            return address;
        }
    }
    // no pivot found!
    return undefined;
}

/**
 * @brief Returns the maximum of two numeric values
 *
 * @param a numeric The first value
 * @param b numeric The second value
 *
 * @returns numeric The maximum of the two values
 */
max(a, b)
{
    debugPrint("in matrix::max()", "fn", level.lowVerbosity);

    if (a > b) {return a;}
    else {return b;}
}

/**
 * @brief Computes the cross product of two column vectors
 *
 * @param A matrix The first column vector
 * @param B matrix The second column vector
 *
 * @returns matrix A column vector representing A cross B
 * @since RotU 2.2.1
 */
matrixCross(A, B)
{
    debugPrint("in matrix::matrixCross()", "fn", level.lowVerbosity);

    /// @internal, so indices are zero-indexed

    // S is a skew-symmetric matrix of A
    S = zeros(3,3);
    setValue(S,2,3, -1*A.data[0][0]);
    setValue(S,3,2,  A.data[0][0]);
    setValue(S,3,1, -1*A.data[1][0]);
    setValue(S,1,3,  A.data[1][0]);
    setValue(S,1,2, -1*A.data[2][0]);
    setValue(S,2,1,  A.data[2][0]);
    return matrixMultiply(S, B);
}


/// @todo get column of inverted matrix by Ax = e_1, Ax = e_2, etc.  page 108, bottom para



