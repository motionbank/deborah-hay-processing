/**
 * Filters data using Ramer-Douglas-Peucker algorithm with specified tolerance
 * 
 * @author Rzeźnik
 * @see <a href="http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm">Ramer-Douglas-Peucker algorithm</a>
 */
// http://code.google.com/p/savitzky-golay-filter/source/browse/trunk/src/mr/go/sgfilter/RamerDouglasPeuckerFilter.java?r=15
public class RamerDouglasPeuckerFilter {

    private double epsilon;

/**
  * @param epsilon
  *            epsilon in Ramer-Douglas-Peucker algorithm (maximum distance
  *            of a point in data between original curve and simplified
  *            curve)
  * @throws IllegalArgumentException
  *             when {@code epsilon <= 0}
  */
    public RamerDouglasPeuckerFilter(double epsilon) 
    {
        setEpsilon( epsilon );
    }

    public PVector[] filter( PVector[] data ) 
    {
        return ramerDouglasPeuckerFunction( data, 0, data.length - 1 );
    }

    protected PVector[] ramerDouglasPeuckerFunction( PVector[] points, int startIndex, int endIndex ) 
    {
        double dmax = 0;
        int idx = 0;

        PVector b = PVector.sub( points[endIndex], points[startIndex] );

        for (int i = startIndex + 1; i < endIndex; i++) 
        {
            PVector a = PVector.sub( points[i], points[startIndex] );

            b.normalize();
            float dotProduct = a.dot(b);

            b.mult( dotProduct );

            PVector normalPoint = PVector.add( points[startIndex], b );

            double distance = dist( normalPoint.x, normalPoint.y, points[i].x, points[i].y );
            if (distance > dmax) 
            {
                idx = i;
                dmax = distance;
            }
        }
        if (dmax >= epsilon) {
            PVector[] recursiveResult1 = ramerDouglasPeuckerFunction( points, startIndex, idx);
            PVector[] recursiveResult2 = ramerDouglasPeuckerFunction( points, idx, endIndex);
            PVector[] result = new PVector[(recursiveResult1.length - 1) + recursiveResult2.length];
            System.arraycopy(recursiveResult1, 0, result, 0, recursiveResult1.length - 1);
            System.arraycopy(recursiveResult2, 0, result, recursiveResult1.length - 1, recursiveResult2.length);
            return result;
        } 
        else {
            return new PVector[] { 
                points[startIndex], points[endIndex]
            };
        }
    }

    /**
      * 
      * @param epsilon
      *            maximum distance of a point in data between original curve and
      *            simplified curve
      */
    public void setEpsilon(double epsilon) {
        if (epsilon <= 0) {
            throw new IllegalArgumentException("Epsilon nust be > 0");
        }
        this.epsilon = epsilon;
    }

    /**
      * 
      * @return {@code epsilon}
      */
    public double getEpsilon() {
        return epsilon;
    }
}

