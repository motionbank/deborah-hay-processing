//===================================================================

// a quick cpp to java port of this code:
// http://www.geometryalgorithms.com/Archive/algorithm_0110/algorithm_0110.htm
// http://www.softsurfer.com/Archive/algorithm_0110/algorithm_0110.htm
// "A Fast Approximate 2D Convex Hull Algorithm"

//===================================================================

// Copyright 2001, softSurfer (www.softsurfer.com)
// This code may be freely used and modified for any purpose
// providing that this copyright notice is included with it.
// SoftSurfer makes no warranty for this code, and cannot be held
// liable for any real or imagined damage resulting from its use.
// Users of this code must verify correctness for their application.
// Assume that classes are already given for the objects:
//    Point with coordinates {float x, y;}

int NONE = -1;

class Point2D
{
    float x, y;
    
    Point2D ( float _x, float _y )
    {
        x = _x; y = _y;
    }
}

class Bin
{
    int min;
    int max;
}

// isLeft(): tests if a point is Left|On|Right of an infinite line.
//    Input:  three points P0, P1, and P2
//    Return: >0 for P2 left of the line through P0 and P1
//            =0 for P2 on the line
//            <0 for P2 right of the line
float isLeft ( Point2D p0, Point2D p1, Point2D p2 )
{
    return (p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y);
}

// nearHull_2D(): the BFP fast approximate 2D convex hull algorithm
//     Input:  P[] = an (unsorted) array of 2D points
//              n = the number of points in P[]
//              k = the approximation accuracy (large k = more accurate)
//     Output: H[] = an array of the convex hull vertices (max is n)
//     Return: the number of points in H[]
int nearHull2D ( Point2D[] pnts, Point2D[] hull )
{
    int n = pnts.length;
    int k = n;

    int minmin = 0, minmax = 0;
    int maxmin = 0, maxmax = 0;

    float xmin = pnts[0].x, xmax = pnts[0].x;

    Point2D cp;
    int bot = 0, top = NONE;

    // Get the points with (1) min-max x-coord, and (2) min-max y-coord
    for (int i=1; i<n; i++) {
        cp = pnts[i];
        if (cp.x <= xmin) {
            if (cp.x < xmin) {        // new xmin
                xmin = cp.x;
                minmin = minmax = i;
            }
            else {                      // another xmin
                if (cp.y < pnts[minmin].y)
                    minmin = i;
                else if (cp.y > pnts[minmax].y)
                    minmax = i;
            }
        }
        if (cp.x >= xmax) {
            if (cp.x > xmax) {        // new xmax
                xmax = cp.x;
                maxmin = maxmax = i;
            }
            else {                      // another xmax
                if (cp.y < pnts[maxmin].y)
                    maxmin = i;
                else if (cp.y > pnts[maxmax].y)
                    maxmax = i;
            }
        }
    }
    if (xmin == xmax) {      // degenerate case: all x-coords == xmin
        hull[++top] = pnts[minmin];           // a point, or
        if (minmax != minmin)           // a nontrivial segment
            hull[++top] = pnts[minmax];
        return top+1;                   // one or two points
    }

    // Next, get the max and min points in the k range bins
    Bin[] bin = new Bin[k+2];   // first allocate the bins
    for ( int i = 0; i < bin.length; i++ )
        bin[i] = new Bin();
    bin[0].min = minmin;
    bin[0].max = minmax;        // set bin 0
    bin[k+1].min = maxmin;       
    bin[k+1].max = maxmax;      // set bin k+1
    for (int b=1; b<=k; b++) { // initially nothing is in the other bins
        bin[b].min = bin[b].max = NONE;
    }
    for (int b, i=0; i<n; i++) {
        cp = pnts[i];
        if (cp.x == xmin || cp.x == xmax) // already have bins 0 and k+1 
            continue;
        // check if a lower or upper point
        if (isLeft( pnts[minmin], pnts[maxmin], cp) < 0) {  // below lower line
            b = (int)( k * (cp.x - xmin) / (xmax - xmin) ) + 1;  // bin #
            if (bin[b].min == NONE)       // no min point in this range
                bin[b].min = i;           // first min
            else if (cp.y < pnts[bin[b].min].y)
                bin[b].min = i;           // new min
            continue;
        }
        if (isLeft( pnts[minmax], pnts[maxmax], cp) > 0) {  // above upper line
            b = (int)( k * (cp.x - xmin) / (xmax - xmin) ) + 1;  // bin #
            if (bin[b].max == NONE)       // no max point in this range
                bin[b].max = i;           // first max
            else if (cp.y > pnts[bin[b].max].y)
                bin[b].max = i;           // new max
            continue;
        }
    }

    // Now, use the chain algorithm to get the lower and upper hulls
    // the output array hull[] will be used as the stack
    // First, compute the lower hull on the stack hull
    for (int i=0; i <= k+1; ++i)
    {
        if (bin[i].min == NONE)  // no min point in this range
            continue;
        cp = pnts[ bin[i].min ];   // select the current min point

        while (top > 0)        // there are at least 2 points on the stack
        {
            // test if current point is left of the line at the stack top
            if (isLeft( hull[top-1], hull[top],cp) > 0)
                break;         // cp is a new hull vertex
            else
                top--;         // pop top point off stack
        }
        hull[++top] = cp;        // push current point onto stack
    }

    // Next, compute the upper hull on the stack hull above the bottom hull
    if (maxmax != maxmin)      // if distinct xmax points
        hull[++top] = pnts[maxmax];  // push maxmax point onto stack
    bot = top;                 // the bottom point of the upper hull stack
    for (int i=k; i >= 0; --i)
    {
        if (bin[i].max == NONE)  // no max point in this range
            continue;
        cp = pnts[ bin[i].max ];   // select the current max point

        while (top > bot)      // at least 2 points on the upper stack
        {
            // test if current point is left of the line at the stack top
            if (isLeft( hull[top-1], hull[top], cp) > 0)
                break;         // current point is a new hull vertex
            else
                top--;         // pop top point off stack
        }
        hull[++top] = cp;        // push current point onto stack
    }
    if (minmax != minmin)
        hull[++top] = pnts[minmin];  // push joining endpoint onto stack

    return top+1;              // # of points on the stack
}
