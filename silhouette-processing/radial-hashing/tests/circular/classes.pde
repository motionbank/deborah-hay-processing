
class HumanSilhouette
{
    PImage src;
    PImage circular;
    
    int[] boundingBox;
    float radius;
    float centerX, centerY;
    
    int xyToCircular[][][];
    int circularToXY[][][];
    
    HumanSilhouette ( PImage bitSource )
    {
        src = bitSource.get();
        
        boundingBox = getBBox( src );
        
        int xDist = boundingBox[2]-boundingBox[0];
        int yDist = boundingBox[3]-boundingBox[1];

        centerX = boundingBox[0] + xDist / 2;
        centerY = boundingBox[1] + yDist / 2;

        radius = sqrt( xDist*xDist + yDist*yDist ) / 2;
        
        PGraphics gr = createGraphics( ceil(radius*2), ceil(radius*2) );
        gr.beginDraw();
        gr.background( 0 );
        gr.copy( src, boundingBox[0],boundingBox[1],xDist,yDist, 
                      int(radius)-xDist/2,int(radius)-yDist/2,xDist,yDist );
        gr.endDraw();
        
        src = (PImage)gr;
        centerX = int(radius);
        centerY = int(radius);
    
        int rd = int(radius);
        int rs = int(2*radius*PI);
    
        circularToXY = new int[rs][rd][2];
        xyToCircular = new int[src.width][src.height][2];
        
        for ( int i = 0; i < circularToXY.length; i++ )
        {
            float a = radians( map( i, 0,circularToXY.length-1, 0,360 ) );
            float xr = centerX + cos(a)*radius;
            float yr = centerY + sin(a)*radius;
            
            float xDiff = xr - centerX;
            float yDiff = yr - centerY;
            
            float xStep = xDiff / rd;
            float yStep = yDiff / rd;
            
            float xx = centerX, yy = centerY;
            
            for ( int ii = 0; ii < rd; ii++ )
            {
                circularToXY[i][ii] = new int[]{ int(xx), int(yy) };
                xyToCircular[int(xx)][int(yy)] = new int[]{ i, ii };
            
                xx += xStep;
                yy += yStep;
            }
        }
        
        circular = new PImage( rs, rd );
        circular.loadPixels();
        for ( int i = 0; i < circularToXY.length; i++ )
        {
            for ( int ii = 0; ii < circularToXY[i].length; ii++ )
            {
                circular.pixels[i + ii*rs] = src.pixels[ circularToXY[i][ii][0] + circularToXY[i][ii][1] * src.width ];
            }
        }
        circular.updatePixels();
        circular.save( sketchPath( "circular.png" ) );

    /*noStroke();
    rectMode( CORNER );
    for ( int i = 0; i < values.length; i++ )
    {
        for ( int ii = 0; ii < values[i].length; ii++ )
        {
            fill( values[i][ii] );
            rect( map( i, 0, values.length, 0, width ), 
            map( ii, 0, values[i].length, height, 0 )-(float(height)/values[i].length), 
            float(width)/values.length, float(height)/values[i].length );
        }
    }
    
    PImage cleaned = removeSmacksFillHoles(get());
    cleaned = removeSmacksFillHoles( cleaned );
    cleaned = removeSmacksFillHoles( cleaned );
    image( cleaned, 0,0 );
    
    loadPixels();
    for ( int iy = 0; iy < height; iy++ )
    {
        int last = -1;
        int c = 20;
        for ( int ix = 0; ix < width; ix++ )
        {
            int p = (pixels[ix + iy*width] & 0xFF);
            
            //if ( p != 0 || p != 255 ) continue;
            
            if ( p > 0 )
            {
                if ( p != 255 )
                    c = pixels[ix + iy*width] & 0xFF;
                    
                pixels[ix + iy*width] = color( c );
                
                for ( int iiy = 1; iiy < (height-iy); iiy++ )
                {
                    int pp = pixels[ix + (iy+iiy)*width] & 0xFF;
                    if ( pp == 255 )
                    {
                        pixels[ix + (iy+iiy)*width] = color(c);
                    }
                    else
                        break;
                }
                
                last = 1;
            }
            else if ( p == 0 )
            {
                if ( last != -1 )
                {
                    last = -1;
                    c += 20;
                }
            }
        }
    }
    updatePixels();*/
    }
}
