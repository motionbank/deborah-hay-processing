
PImage loadPrepareBinaryImage ( String png )
{
    silImage = loadImage( png );
    silImage.loadPixels();
    
    removeTurquoise( silImage );

    silImage.filter( GRAY );
    silImage.filter( BLUR );
    silImage.filter( THRESHOLD, 0.7 );
    
    return silImage;
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
