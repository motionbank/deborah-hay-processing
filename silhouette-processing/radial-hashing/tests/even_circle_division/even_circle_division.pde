/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Testing even distribution of segments at multiple levels in a circle.
 *
 *    Processing 2.0
 *    created: fjenett 20130302
 */

void setup ()
{
    size( 256, 256 );
    
    double radius = 256 / 2.0;
    
    int levels = 6;
    int segments = (int)(Math.pow(2,(levels+2))-4);
    println( segments );
    
    double area = Math.PI * (radius * radius);
    double areaSegment = area / segments;
    
    double areaLevelPrevious = 0, areaLevel = 0;
    double[] radiusLevel = new double[levels];
    
    for ( int i = 0, segmentsLevel = 0; i < levels; i++ )
    {
        segmentsLevel = (int)(Math.pow(2,(i+1+2))-4) - (int)(Math.pow(2,(i+2))-4);
        areaLevel = areaLevelPrevious + areaSegment * segmentsLevel;
        radiusLevel[i] = Math.sqrt(areaLevel / Math.PI);
        areaLevelPrevious = areaLevel;
    }
    
    // drawing
    
    for ( int i = radiusLevel.length-1; i >= 0; i-- )
    {
        double r = radiusLevel[i];
        int segmentsLevel = (int)(Math.pow(2,(i+1+2))-4) - (int)(Math.pow(2,(i+2))-4);
        
        ellipse( width/2, height/2, (float)r * 2, (float)r * 2 );
        for ( int s = 0; s < segmentsLevel; s++ )
        {
            double a = (Math.PI * 2) * (s / (double)segmentsLevel);
            double aCos = Math.cos(a);
            double aSin = Math.sin(a);
            line( width/2, height/2, (float)(width/2 + r*aCos), (float)(height/2 + r*aSin) );
        }
    }
}
