/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Using OpenCV to fix some silhouette issues:
 *    - edges
 *    - holes
 *
 *    Processing 2.0
 *    fjenett 20130208
 */
 
import de.bezier.data.argbencoder.*;

import java.nio.ByteBuffer;

// getting this installed and working is tricky:
// http://code.google.com/p/javacv/
import static com.googlecode.javacv.cpp.opencv_core.*;
import static com.googlecode.javacv.cpp.opencv_imgproc.*;
import static com.googlecode.javacv.cpp.opencv_highgui.*;

import java.util.*;

static String silBase = "/Volumes/Verytim/2011_FIGD_April_Results/Ros_D01T02_withBackgroundAdjustment_Corrected/Images_BackgroundSubstracted/";
static String camAngle = "CamCenter";
int currentPng = 65514, totalPngs = -1;
boolean playing = true;

CvMemStorage mem;

void setup () 
{
    size( 600, 200 );

    totalPngs = new File( silBase + camAngle ).list().length;

    frameRate( 20 );
}

void draw ()
{
    background( 120 );

    IplImage imgIn = cvLoadImage( silBase + camAngle + "/" + "CamCenter_BackgroundSubstracted" + nf(currentPng, 6) + ".png" );

    // IplImage pixel data is obtained and set through its byte buffer ...

    IplImage maskImg = cvCreateImage( cvGetSize( imgIn ), imgIn.depth(), 1 );
    ByteBuffer pointerOut = maskImg.getByteBuffer();
    ByteBuffer pointerIn  = imgIn.getByteBuffer();

    int imgW = imgIn.width();
    int imgH = imgIn.height();
    int widthStepOut = maskImg.widthStep(), widthStepIn = imgIn.widthStep();
    int nChannels = imgIn.nChannels();
    int rowIndexOut, rowIndexIn;
    boolean isMatteColor = false;

    for (int row = 0; row < imgH; row++) 
    {
        rowIndexIn = row * widthStepIn;
        rowIndexOut = row * widthStepOut;
        byte r, g, b;
        for (int col = 0, i1 = 0, i2 = 0; col < imgW; col++) 
        {
            i1 = rowIndexIn + (col * nChannels);
            b = pointerIn.get( i1 );
            g = pointerIn.get( i1+1 );
            r = pointerIn.get( i1+2 );

            isMatteColor = r == 0 && g == (byte)(255) && b == (byte)(255);

            i2 = rowIndexOut + col;

            if ( isMatteColor )
            {
                pointerOut.put( i2, (byte)0 );

                pointerIn.put( i1, (byte)(127) );
                pointerIn.put( i1+1, (byte)(127) );
                pointerIn.put( i1+2, (byte)(127) );
            }
            else
            {
                pointerOut.put( i2, (byte)(255) );
            }
        }
    }

    //image( iplImageToPImage(maskImg), 0, 0 );

    IplImage maskImg2 = cvCloneImage( maskImg );

    cvErode( maskImg, maskImg, null, 1 );
    cvSmooth( maskImg, maskImg, CV_MEDIAN, 3 );
    cvDilate( maskImg, maskImg, null, 1 );

    PImage pMaskImg = iplImageToPImage(maskImg);
    //image( pMaskImg, maskImg.width(), 0 );

    //    cvDilate( maskImg2, maskImg2, null, 2 );
    //    cvErode( maskImg2, maskImg2, null, 1 );
    //    
    //    image( iplImageToPImage(maskImg2), 2*maskImg.width(), 0 );

    /**/
    PImage img = iplImageToPImage(imgIn);
    img.format = ARGB;

    PImage tImg = createImage( 316, 316, RGB );
    int bCol = ARGBEncoder.argbToRgb( 0, 127, 127, 127 );

    int a, r, g, b;
    for ( int i = 0; i < img.pixels.length; i++ )
    {
        r = img.pixels[i] >> 16 & 0xFF;
        g = img.pixels[i] >> 8  & 0xFF;
        b = img.pixels[i]       & 0xFF;

        a = pMaskImg.pixels[i]  & 0xFF;

        img.pixels[i] = ARGBEncoder.argbToRgb( a, r, g, b );
    }

    Arrays.fill( tImg.pixels, bCol );
    for ( int iy = 0; iy < img.height; iy++ )
    {
        System.arraycopy( img.pixels, iy * img.width, tImg.pixels, iy * tImg.width, img.width );
    }
    //tImg.save( silBase + camAngle + "Encoded2" + "/" + nf(currentPng, 6) + ".png" );
    /**/

    //cvSaveImage( silBase + camAngle + "Encoded2" + "/" + nf(currentPng, 6) + ".png", maskImg );

    if ( playing ) currentPng++;
    if ( currentPng == totalPngs ) exit();

    fill( 0 ); 
    noStroke();
    rect( 0, 0, map(currentPng, 0, totalPngs, 0, width), height );
    
    /**/
    mem = cvCreateMemStorage(0);
    CvSeq contour = new CvContour();
    cvFindContours( maskImg, mem, contour, Loader.sizeof(CvContour.class), CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0) );

    int contourPointsSize;
    CvPoint contourPoints = null;
    java.nio.IntBuffer contourPointsBuffer = null;
    
    while ( contour != null && !contour.isNull () ) 
    {
        contourPointsSize = contour.total();
        if (contourPoints == null || contourPoints.capacity() < contourPointsSize) 
        {
            contourPoints = new CvPoint(contourPointsSize);
            contourPointsBuffer = contourPoints.asByteBuffer().asIntBuffer();
        }
        cvCvtSeqToArray(contour, contourPoints.position(0));
        
        noStroke();
        fill( 255 );
        beginShape();
        for (int i = 0; i < contourPointsSize; i++) {
            int x = contourPointsBuffer.get(2*i    ),
                y = contourPointsBuffer.get(2*i + 1);
            vertex( x, y );
        }
        endShape();
        
        contour = contour.h_next();
    }
    /**/
}

void mouseDragged ()
{
    currentPng = (int)map( mouseX, 0, width, 0, totalPngs );
}

void keyPressed () 
{
    if ( key == ' ' ) playing = !playing;
}

PImage iplImageToPImage ( IplImage iplImg ) 
{
    return bufferedImageToPImage( iplImg.getBufferedImage() );
}

PImage bufferedImageToPImage ( java.awt.image.BufferedImage bImg )
{
    PImage img = new PImage( bImg.getWidth(), bImg.getHeight(), ARGB );
    bImg.getRGB( 0, 0, img.width, img.height, img.pixels, 0, img.width );
    img.updatePixels();
    return img;
}

