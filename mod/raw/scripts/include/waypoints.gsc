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

// WAYPOINTS AND PATHFINDING
#include scripts\include\data;
#include scripts\include\utility;

loadWaypoints()
{
    debugPrint("in waypoints::loadWaypoints()", "fn", level.nonVerbose);

    precacheString(&"ROTUSCRIPT_UNLINKED_WAYPOINT");

    if ((isDefined(level.Wp)) && (level.Wp.size > 0)) {
        // waypoints were already loaded externally, so don't look for internal
        //waypoints
        return;
    }

    level.Wp = [];
    level.WpCount = 0;

    fileName =  "waypoints/"+ tolower(getdvar("mapname")) + "_wp.csv";
    level.WpCount = int(TableLookup(fileName, 0, 0, 1));
    for (i=0; i<level.WpCount; i++) {
        waypoint = spawnstruct();
        level.Wp[i] = waypoint;
        strOrg = TableLookup(fileName, 0, i+1, 1);
        tokens = strtok(strOrg, " ");

        waypoint.origin = (atof(tokens[0]), atof(tokens[1]), atof(tokens[2]));
        waypoint.isLinking = false;
        waypoint.ID = i;
    }
    for (iii=0; iii<level.WpCount; iii++) {
        waypoint = level.Wp[iii];
        strLnk = TableLookup(fileName, 0, iii+1, 2);
        tokens = strtok(strLnk, " ");
        waypoint.linkedCount = tokens.size;
        for (ii=0; ii<tokens.size; ii++) {
            waypoint.linked[ii] = level.Wp[atoi(tokens[ii])];
        }

        // Error catching
        if (!isdefined(waypoint.linked)) {
            iprintlnbold(&"ROTUSCRIPT_UNLINKED_WAYPOINT", waypoint.ID, waypoint.origin);
        }
    }
}

getNearestWp(origin)
{
    // 10th most-called function (2% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    nearestWp = -1;
    nearestDistance = 9999999999;
    for(i = 0; i < level.WpCount; i++) {
        distance = distancesquared(origin, level.Wp[i].origin);

        if(distance < nearestDistance) {
            nearestDistance = distance;
            nearestWp = i;
        }
    }
    return nearestWp;
}

// ASTAR PATHFINDING ALGORITHM: CREDITS GO TO PEZBOTS!
AStarSearch(startWp, goalWp)
{
    // 20th most-called function (0.4% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    pQOpen = [];
    pQSize = 0;
    closedList = [];
    listSize = 0;
    s = spawnstruct();
    s.g = 0; //start node
    s.h = distance(level.Wp[startWp].origin, level.Wp[goalWp].origin);
    s.f = s.g + s.h;
    s.wpIdx = startWp;
    s.parent = spawnstruct();
    s.parent.wpIdx = -1;

    //push s on Open
    pQOpen[pQSize] = spawnstruct();
    pQOpen[pQSize] = s; //push s on Open
    pQSize++;

    //while Open is not empty
    while (!PQIsEmpty(pQOpen, pQSize))
    {
        //pop node n from Open  // n has the lowest f
        n = pQOpen[0];
        highestPriority = 9999999999;
        bestNode = -1;
        for (i=0; i<pQSize; i++) {
            if (pQOpen[i].f < highestPriority) {
                bestNode = i;
                highestPriority = pQOpen[i].f;
            }
        }

        if (bestNode != -1) {
            n = pQOpen[bestNode];
            //remove node from queue
            for (i=bestNode; i<pQSize-1; i++) {
                pQOpen[i] = pQOpen[i+1];
            }
            pQSize--;
        } else {
            return -1;
        }

        //if n is a goal node; construct path, return success
        if (n.wpIdx == goalWp) {
            x = n;
            for (z = 0; z < 1000; z++) {
                parent = x.parent;
                if(parent.parent.wpIdx == -1) {return x.wpIdx;}
//                 line(level.Wp[x.wpIdx].origin, level.Wp[parent.wpIdx].origin, (0,1,0));
                x = parent;
            }
            return -1;
        }

        //for each successor nc of n
        for (i=0; i<level.Wp[n.wpIdx].linkedCount; i++) {
            //newg = n.g + cost(n,nc)
            newg = n.g + distance(level.Wp[n.wpIdx].origin, level.Wp[level.Wp[n.wpIdx].linked[i].ID].origin);

            //if nc is in Open or Closed, and nc.g <= newg then skip
            if (PQExists(pQOpen, level.Wp[n.wpIdx].linked[i].ID, pQSize)) {
                //find nc in open
                nc = spawnstruct();
                for(p = 0; p < pQSize; p++) {
                    if (pQOpen[p].wpIdx == level.Wp[n.wpIdx].linked[i].ID) {
                        nc = pQOpen[p];
                        break;
                    }
                }
                if (nc.g <= newg) {continue;}
            } else {
                if (ListExists(closedList, level.Wp[n.wpIdx].linked[i].ID, listSize)) {
                    //find nc in closed list
                    nc = spawnstruct();
                    for (p=0; p<listSize; p++) {
                        if (closedList[p].wpIdx == level.Wp[n.wpIdx].linked[i].ID) {
                            nc = closedList[p];
                            break;
                        }
                    }

                    if(nc.g <= newg) {continue;}
                }
            }
//             nc.parent = n
//             nc.g = newg
//             nc.h = GoalDistEstimate( nc )
//             nc.f = nc.g + nc.h

            nc = spawnstruct();
            nc.parent = spawnstruct();
            nc.parent = n;
            nc.g = newg;
            nc.h = distance(level.Wp[level.Wp[n.wpIdx].linked[i].ID].origin, level.Wp[goalWp].origin);
            nc.f = nc.g + nc.h;
            nc.wpIdx = level.Wp[n.wpIdx].linked[i].ID;

            //if nc is in Closed,
            if (ListExists(closedList, nc.wpIdx, listSize)) {
                //remove it from Closed
                deleted = false;
                for (p=0; p<listSize; p++) {
                    if(closedList[p].wpIdx == nc.wpIdx) {
                        for(x = p; x < listSize-1; x++) {
                            closedList[x] = closedList[x+1];
                        }
                        deleted = true;
                        break;
                    }
                    if (deleted) {break;}
                }
                listSize--;
            }

            //if nc is not yet in Open,
            if (!PQExists(pQOpen, nc.wpIdx, pQSize)) {
                //push nc on Open
                pQOpen[pQSize] = spawnstruct();
                pQOpen[pQSize] = nc;
                pQSize++;
            }
        }

        //Done with children, push n onto Closed
        if (!ListExists(closedList, n.wpIdx, listSize)) {
            closedList[listSize] = spawnstruct();
            closedList[listSize] = n;
            listSize++;
        }
    }
}



////////////////////////////////////////////////////////////
// PQIsEmpty, returns true if empty
////////////////////////////////////////////////////////////
PQIsEmpty(Q, QSize)
{
    // 5th most-called function (5% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    if (QSize <= 0) {return true;}

    return false;
}


////////////////////////////////////////////////////////////
// returns true if n exists in the pQ
////////////////////////////////////////////////////////////
PQExists(Q, n, QSize)
{
    // 2nd most-called function (22% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    for (i=0; i<QSize; i++) {
        if(Q[i].wpIdx == n) {return true;}
    }

    return false;
}

////////////////////////////////////////////////////////////
// returns true if n exists in the list
////////////////////////////////////////////////////////////
ListExists(list, n, listSize)
{
    // 1st most-called function (26% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    for (i=0; i<listSize; i++) {
        if (list[i].wpIdx == n) {return true;}
    }

    return false;
}

