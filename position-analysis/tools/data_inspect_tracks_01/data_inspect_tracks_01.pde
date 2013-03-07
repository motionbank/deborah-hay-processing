/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Write tool to inspect data on 3 tracks X, Y, Z.
 *
 *    Processing 2.0b
 *    changed: fjenett 20130307 
 */

 import processing.opengl.*;

 import de.bezier.guido.*;
 import org.piecemaker.api.*;
 
 MultiSlider mSlider;
 
 float[][] trackData;
 float[] trackSpeed;
 int trackStart = 0, trackEnd = 0;
 float[] trackMin, trackMax;
 float trackSpeedMean, trackSpeedHigh, trackSpeedLow, trackSpeedThresh;
 int trackPlayhead = 0;
 
 int centerFold;
 
 PGraphics scene3D;
 InvisibleInteractiveArea scene3DController;
 ArcBall scene3DSpinner;
 float scene3DScale = 0;
 
 InvisibleInteractiveArea selectionController;
 
 int col1 = 0xFFF3F3F3;
 
 void setup ()
 {
     size( 1200, 700, P3D );
     
     new App( this );
     
     Interactive.make(this);
     
     mSlider = new MultiSlider( 10, height-20, width-20, 10 );
     
     Interactive.setActive( mSlider, false );
     
     Interactive.on( mSlider, "leftValueChanged",  this, "leftChanged" );
     Interactive.on( mSlider, "rightValueChanged", this, "rightChanged" );
     
     centerFold = width/2;
     
     scene3D = createGraphics( width - centerFold - 10, height-40, P3D );
     scene3DSpinner = new ArcBall( scene3D );
     
     scene3DController = new InvisibleInteractiveArea( centerFold, 10, width-centerFold-10, height-40 );
     Interactive.on( scene3DController, "clickedArea", scene3DSpinner, "mousePressed" );
     Interactive.on( scene3DController, "draggedArea", scene3DSpinner, "mouseDragged" );
     Interactive.on( scene3DController, "scrolledArea", this, "scaleScene3D" );
     
     selectionController = new InvisibleInteractiveArea( 20, 20, centerFold-40, height-50 );
     Interactive.on( selectionController, "draggedArea", this, "movePlayhead" );
 }
 
 void draw ()
 {
     background( 255 );
     
     if ( trackData == null )
     {
         fill( 0 );
         text( "Loading", width/2, height/2 );
     }
     else
     {
         fill( col1 );
         noStroke();
         
         float h = (height-40-20)/3;
         rect( 10, 10,       centerFold-20, h );
         rect( 10, 20+h,     centerFold-20, h );
         rect( 10, 30+h+h,   centerFold-20, h );
         
         fill( 200 );
         text( "X", 20, 30 );
         text( "Y", 20, 30 + h + 10 );
         text( "Z", 20, 30 + 2*h + 20 );
         
         noFill();
         stroke( 255 );
         
         int iStep = 1;
         if ( (trackEnd - trackStart) > centerFold-40 )
         {
             iStep = int( round( (trackEnd - trackStart) / (centerFold-40) ) );
         }

         boolean isOutlier = false, wasOutlier = false;
         int c1 = color(255, 80, 80), c2 = color(80, 130, 200);
         
         for ( int d = 0; d < 3; d++ )
         {
             float vx = 20 + map( trackPlayhead, trackStart, trackEnd, 0, centerFold-40 );
             float vy = 0;
             
             stroke( 220 );
             strokeWeight( 1 );
             line( vx, 20 + (d*h) + (d*10), vx, (d*h) + (d*10) + h );
             
             beginShape();
             stroke( c2 );
             for ( int i = trackStart; i < trackEnd; i+=iStep )
             {
                 vx = 20 + map( i, trackStart, trackEnd, 0, centerFold-40 );
                 vy = 20 + (d*h) + (d*10) + map( trackData[i][d], trackMin[d], trackMax[d], h-20, 0 );
                 
                 isOutlier = trackSpeed[i] > trackSpeedThresh;
                 
                 if ( isOutlier != wasOutlier ) {
                     vertex( vx, vy );
                     endShape();
                     stroke( isOutlier ? c1 : c2 );
                     strokeWeight( isOutlier ? 2 : 1 );
                     beginShape();
                     wasOutlier = isOutlier;
                 }
                 
                 vertex( vx, vy );
             }
             endShape();
         }

         scene3D.beginDraw();
         scene3D.pushMatrix();
         scene3D.background( col1 );
         scene3DSpinner.apply();
         float vx, vy, vz;
         float s = scene3D.width / 12.0 + scene3DScale;
         vx = trackData[trackPlayhead][0] - 6; 
         vy = -trackData[trackPlayhead][1] + 6;
         vz = trackData[trackPlayhead][2];
         scene3D.translate( scene3D.width/2 - vx*s, scene3D.height/2 - vy*s, -scene3D.height/2 - vz*s );
         scene3D.scale( s );
         
         scene3D.pushMatrix();
         scene3D.stroke( 0 );
         scene3D.strokeWeight( 1 );
         scene3D.translate( vx, vy, vz );
         scene3D.beginShape();
         scene3D.vertex( 0, 0, 0 );
         scene3D.vertex( 0.1, 0, 0 );
         scene3D.endShape();
         scene3D.beginShape();
         scene3D.vertex( 0, 0, 0 );
         scene3D.vertex( 0, 0.1, 0 );
         scene3D.endShape();
         scene3D.beginShape();
         scene3D.vertex( 0, 0, 0 );
         scene3D.vertex( 0, 0, 0.1 );
         scene3D.endShape();
         scene3D.popMatrix();
         
         scene3D.noFill();
         scene3D.stroke( 190 );
         scene3D.strokeWeight( 1 );
         scene3D.rect( -6, -6, 12, 12 );
         scene3D.rect( -6.05, 5.95, 0.1, 0.1 );
         
         scene3D.noFill();
         scene3D.beginShape();
         isOutlier = false;
         wasOutlier = false;
         scene3D.stroke( c2 );
         for ( int i = trackStart; i < trackEnd; i++ )
         {
             vx = trackData[i][0] - 6; 
             vy = -trackData[i][1] + 6;
             vz = trackData[i][2];
             isOutlier = trackSpeed[i] > trackSpeedThresh;
             if ( isOutlier != wasOutlier ) {
                 scene3D.vertex( vx, vy, vz );
                 scene3D.endShape();
                 scene3D.stroke( isOutlier ? c1 : c2 );
                 scene3D.strokeWeight( isOutlier ? 2 : 1 );
                 scene3D.beginShape();
                 wasOutlier = isOutlier;
             }
             scene3D.vertex( vx, vy, vz );
         }
         scene3D.endShape();
             
         scene3D.popMatrix();
         scene3D.endDraw();
         image( scene3D, centerFold, 10 );
     }
 }
 
 void setData ( float[][] d )
 {
     trackData = fixZeroPoints( d );
     trackSpeedMean = 0;
     trackSpeedHigh = -10000;
     trackSpeedLow = 10000;
     trackSpeed = new float[trackData.length];
     trackMin = new float[]{ 10000, 10000, 10000};
     trackMax = new float[]{-10000,-10000,-10000};
     for ( int i = 0, k = trackData.length-1; i < k; i++ ) 
     {
         trackMin[0] = min(trackMin[0], trackData[i][0]);
         trackMax[0] = max(trackMax[0], trackData[i][0]);
         trackMin[1] = min(trackMin[1], trackData[i][1]);
         trackMax[1] = max(trackMax[1], trackData[i][1]);
         trackMin[2] = min(trackMin[2], trackData[i][2]);
         trackMax[2] = max(trackMax[2], trackData[i][2]);
     
         trackSpeed[i] = dist( trackData[i][0],   trackData[i][1],   trackData[i][2],
                               trackData[i+1][0], trackData[i+1][1], trackData[i+1][2] );
            
         trackSpeedMean += trackSpeed[i];
         trackSpeedHigh = max( trackSpeedHigh, trackSpeed[i] );
         trackSpeedLow = min( trackSpeedLow,  trackSpeed[i] );
     }
     trackSpeedMean = trackSpeedMean / trackData.length;
     trackSpeedThresh = 6 * trackSpeedMean;
     
     //console.log( trackSpeedLow, trackSpeedMean, trackSpeedHigh );
     
     Interactive.setActive( mSlider, true );
     mSlider.set(0,0.1);
 }
 
 void scaleScene3D ( float v )
 {
     scene3DScale += v;
     if ( scene3DScale < 0 ) scene3DScale = 0;
 }
 
 void leftChanged ( float v )
 {
     trackStart = int(( map( v, 0, 1, 0, trackData.length ) ) / 2) * 2;
 }
 
 void rightChanged ( float v )
 {
     trackEnd = int(( map( v, 0, 1, 0, trackData.length ) ) / 2) * 2;
 }
 
 void movePlayhead ( float v )
 {
     v = constrain( v, 0, centerFold-40 );
     trackPlayhead = int( map( v, 0, centerFold-40, trackStart, trackEnd ) / 2 ) * 2;
 }
 
float[][] fixZeroPoints ( float[][] points )
{
    // trying to remove any 0,0,0 points by linear interpolation
    
    float[][] tmp = new float[points.length][3];
    float[] pl = null;
    for ( int i = 0, n = 0; i < points.length; i++ )
    {
        n = i+1;
        float[] p = points[i];
        float[] pn = null;
        if ( p[0] == 0 && p[1] == 0 && p[2] == 0 )
        {
            for ( int k = n; k < points.length; k++ )
            {
                pn = points[k];
                if ( !( pn[0] == 0 && pn[1] == 0 && pn[2] == 0 ) )
                {
                    n = k;
                    break;
                }
            }
        }
        if ( pn != null )
        {
            if ( pl == null ) pl = pn;
            for ( int i2 = i; i2 <= n; i2++ )
            {
                tmp[i2][0] = map( i2, i, n, pl[0], pn[0] );
                tmp[i2][1] = map( i2, i, n, pl[1], pn[1] );
                tmp[i2][2] = map( i2, i, n, pl[2], pn[2] );
            }
            //println( "Fixed " + (n-i) );
            i = n;
            continue;
        }
        tmp[i] = p;
        pl = p;
    }
    return tmp;
}
