
void setup ()
{
    size( 700, 700 );
 
    background( 255 );
    loadPixels();
 
    int widthHalf = width/2;
    float circleLength = 2 * PI * widthHalf;
    
    int levels = 8;
    int[] hash = new int[ (int)Math.pow(2,levels+2)-4 ];
    int[] count = new int[ hash.length ];
    
    int[] fieldsBelowLevel = new int[levels];
    double[] sliceWidthsPerLevel = new double[levels];
    for ( int i = 0, si = 0; i < levels; i++ )
    {
        fieldsBelowLevel[i] = (int)(Math.pow(2,i+2)-4);
        int sl = (int)(Math.pow(2,i+3)-4) - fieldsBelowLevel[i]; // TODO: reverse?
        sliceWidthsPerLevel[i] = (Math.PI*2) / sl;
    }
    
    int widthStep = widthHalf / levels;
    
    for ( double a = 0, as = Math.PI/circleLength; a < TWO_PI; a += as )
    {
        double aCos = Math.cos( a );
        double aSin = Math.sin( a );
        
        for ( int r = 0; r <= widthHalf; r++ )
        {
            int px = (int)(widthHalf + aCos * r);
            int py = (int)(widthHalf + aSin * r);
            
            int pk = px + py * width;
            
            int lv = r / widthStep;
            if ( lv == levels ) lv -= 1;
            int sl = (int)(a / sliceWidthsPerLevel[lv]);
            int hi = fieldsBelowLevel[lv] + sl;
            
            hash[hi] += 1;
            count[hi]++;
            
            pixels[pk] = 0xFF000000 + (int((lv/float(levels)) * 255) << 16) + ((sl % 2 == 0 ? 255 : 0) << 8) + (255-int((lv/float(levels)) * 255));
        }
    }
    
    updatePixels();
}
