/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Trying to ...
 *    Calculate the center of mass of a all "interesting pixels" (non-white) of an image.
 *
 *    P-2.0b
 *    fjenett 20121216
 */
 
 String silBase = "/Users/fjenett/Desktop/silhouettes";
 String[] pngs;
 int curPng = 0;
 PImage img;
 
 int xmin, xmax, ymin, ymax;
 int xc, yc;
 
 // Processing S'n'D
 // -------------------------------------
 
 void setup ()
 {
     size( 500, 500 );
     
     initPngs();
     loadPng();
     calcImgBBox();
     calcImgCenterOfMass();
 }
 
 void draw ()
 {
     background( 255 );
     
     image( img, 0, 0 );
     
     // bounding box
     
     stroke(255,0,0);
     noFill();
     rect( xmin, ymin, xmax-xmin, ymax-ymin );
     
     // histograms
     
     stroke( 0, 200, 200 );
     beginShape();
     for ( int i = 0; i < xVals.length; i++ )
     {
         vertex( i, height/2 + xVals[i] );
     }
     endShape();
     line( xc, height/2, xc, height/2+255 );
     
     beginShape();
     for ( int i = 0; i < yVals.length; i++ )
     {
         vertex( width/2 + yVals[i], i );
     }
     endShape();
     line( width/2, yc, width/2+255, yc );
     
     // bbox center
     
     noStroke();
     fill( 255,0,0 );
     ellipse( xmin + (xmax-xmin)/2, ymin + (ymax-ymin)/2, 7, 7 );
     
     // center of mass
     
     fill( 0, 200, 200 );
     ellipse( xc, yc, 7, 7 );
 }
 
 // Processing events
 // -------------------------------------
 
 void mousePressed ()
 {
     curPng++;
     curPng %= pngs.length;
     loadPng();
     calcImgBBox();
     calcImgCenterOfMass();
 }
 
 // Initializers
 // -------------------------------------
 
 void initPngs ()
 {
    File silDir = new File( silBase );
    java.io.FilenameFilter f = new java.io.FilenameFilter() {
        public boolean accept(File f, String n) { 
            return n.endsWith(".png");
        }
    };
    pngs = silDir.list( f );
 }
 
 void loadPng ()
 {
     PImage i = loadImage( silBase + "/" + pngs[curPng] );
     i.loadPixels();
     for ( int n = 0, k = i.pixels.length; n < k; n++ )
     {
         if ( i.pixels[n] == 0xFF00FFFF ) // filter out mask-turquoise
         {
             i.pixels[n] = 0xFFFFFFFF;
         }
//         else
//         {
//             i.pixels[n] = 0xFF000000;
//         }
     }
     i.updatePixels();
     
     i.filter( GRAY );
     i.filter( BLUR, 1 );
     i.filter( THRESHOLD, 0.7 );
     
     img = i;
 }
 
 // Image functions
 // -------------------------------------
 
 /* calculate the bounding box around non-white pixels */
 void calcImgBBox ()
 {
     xmin = Integer.MAX_VALUE;
     xmax = Integer.MIN_VALUE;
     ymin = Integer.MAX_VALUE;
     ymax = Integer.MIN_VALUE;
     
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
 }
 
 /**
  *    Calculate the center of mass of non-white pixels.
  *
  *    First calcs a grey histogram for x and y axes plus a sum of values for each.
  *    Center of mass is assumed at the point where both x and y axis are in balance,
  *    or in other words half of the values are before, the other are after it.
  */
 int[] xVals, yVals;
 void calcImgCenterOfMass ()
 {
     xc = -1;
     yc = -1;
     
     xVals = new int[img.width];
     yVals = new int[img.height];
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
         if ( xc == -1 && v > xSum )  // stop, half the "weight" has passed
         {
             xc = i;
         }
     }
     for ( int i = 0, v = 0; i < img.height; i++ )
     {
         yVals[i] /= img.width;
         v += yVals[i];
         if ( yc == -1 && v > ySum ) // stop, half the "weight" has passed
         {
             yc = i;
         }
     }
 }
