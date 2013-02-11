
// see center of mass sketch for explanation
int[] centerOfMass ( PImage img )
{
     int xc = 0;
     int yc = 0;
     
     int[] xVals = new int[img.width];
     int[] yVals = new int[img.height];
     int xSum = 0, ySum = 0;
     
     for ( int n = 0, k = img.pixels.length, x = 0, y = 0, xv = 0, yv = 0; n < k; n++ )
     {
         x = n % img.width;
         y = n / img.width;
         
         xv = 255 - (img.pixels[n] & 0xFF);
         xVals[x] += xv;
         xSum += xv;
         yv = 255 - (img.pixels[n] & 0xFF);
         yVals[y] += yv;
         ySum += yv;
     }
     
     xSum /= img.width + img.height;
     ySum /= img.width + img.height;
     
     for ( int i = 0, v = 0; i < img.width; i++ )
     {
         xVals[i] /= img.height;
         v += xVals[i];
         if ( v > xSum )
         {
             xc = i;
             break;
         }
     }
     
     for ( int i = 0, v = 0; i < img.height; i++ )
     {
         yVals[i] /= img.width;
         v += yVals[i];
         if ( v > ySum )
         {
             yc = i;
             break;
         }
     }
     
     return new int[]{xc, yc};
}

int[] boundingBox ( PImage img )
{
     int xmin = Integer.MAX_VALUE;
     int xmax = Integer.MIN_VALUE;
     int ymin = Integer.MAX_VALUE;
     int ymax = Integer.MIN_VALUE;
     
     for ( int n = 0, k = img.pixels.length, x = 0, y = 0; n < k; n++ )
     {
         if ( img.pixels[n] != 0xFFFFFFFF )
         {
             x = n % img.width;
             y = n / img.width;
             xmin = x < xmin ? x : xmin;
             xmax = x > xmax ? x : xmax;
             ymin = y < ymin ? y : ymin;
             ymax = y > ymax ? y : ymax;
         }
     }
     
     return new int[]{ xmin, ymin, 
                       xmin + (xmax-xmin)/2, ymin + (ymax-ymin)/2, 
                       xmax, ymax, 
                       xmax-xmin, ymax-ymin };
}
