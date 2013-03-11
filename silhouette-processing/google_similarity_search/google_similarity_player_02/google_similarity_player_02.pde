/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Use Google image similarity search to find similar images to the silhouettes.
 *    Create a "Solo commissioning project" instance from these: 
 *    http://www.deborahhay.com/about.html
 *
 *    fjenett 20121212
 */

int startAtIndex = 9000;  // file num 000000.png
int fileIndexStep = 2;    // 1 = all, 2 = every 2nd, ...

String[] files;
int currentFile = startAtIndex;
int imgSize = 250;

void setup ()
{
    size( 6*imgSize, 4*imgSize );

    files = loadStrings( "files.txt" );
}

void draw ()
{
    if ( currentFile == files.length )
    {
        exit();
        return;
    }
    
    background( 255 );
    int i = currentFile;
    
    PImage img = loadImage( files[i] );
    image( img, 0, 0, imgSize, imgSize );
    removeCache( img );
    
    int ax = imgSize, ay = 0;
    String[] altImgs = loadStrings( files[i].replace("/CamCenter/","/CamCenterGoogleBW/").replace(".png",".txt") );
    if ( altImgs != null )
    {
        for ( String ai : altImgs )
        {
            img = loadImageCustom( ai );
            if ( img != null )
            {
                image( img, ax%width, ay, imgSize, imgSize );
                removeCache( img );
            
                ax += imgSize;
                ay = (ax / width) * imgSize;
            }
        }
        
        saveFrame( "saves/"+nf(i,6)+".png" );
    }
    
    currentFile += fileIndexStep;
}

PImage loadImageCustom ( String url )
{
    PImage img = null;
    
    if ( url.toLowerCase().matches("(gif|png|jpg|jpeg|bmp)$") )
    {
        img = loadImage( url );
    }
    else
    {
        img = loadImage( url, "jpg" );
    }
    
    return img;
}
