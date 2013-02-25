class Connection
{
    String performance;
    int performanceIndex;
    int frame;
    String file;
    PImage image;
    float x, y;
    float hemmingDistance = 0;
    
    Connection ( String p, int pi, int f, String ff, float d )
    {
        performance = p;
        performanceIndex = pi;
        frame = f;
        
        file = ff;
        image = loadImage( silhouettesBase + "/" + file );
        removeTurquoise( image );
        
         int perfs = performances.size();
         float h = (height/perfs);
         x = map( frame, 0, performancesLengths.get( performanceIndex ), 10, width-20 );
         y = performanceIndex * h;
         y += h/2;
         
         hemmingDistance = d;
    }
}

void removeTurquoise ( PImage img )
{
    for ( int i = 0, k = img.pixels.length; i < k; i++ )
    {
        if ( img.pixels[i] == 0xFF00FFFF )
        {
            img.pixels[i] = 0xFFFFFFFF;
        }
    }
}
