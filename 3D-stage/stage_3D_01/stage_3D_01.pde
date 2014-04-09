/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Old sketch testing a 3D stage to perform on ..
 *
 *    Processing 2.0
 *    created: fjenett, 2011, 2014
 */

import de.bezier.guido.*;
import processing.opengl.*;
import javax.media.opengl.*;

// http://code.google.com/p/proscene/
import peasy.*; // http://mrfeinberg.com/peasycam/

String posLoc = "/Volumes/Elements/2011_FIGD_April_Results/";
String posBase = posLoc + "Ros_D01T03_withBackgroundAdjustment_Corrected/";
String silBase = posBase + "Images_BackgroundSubstracted/CamCenter/CamCenter_BackgroundSubstracted";
float[][] ps3D;
float[][] ps2DC;
float[][] bx2DC;

PeasyCam cam;
Slider slider;

PJOGL pgl;
GL2 gl;

PImage silh;
PImage tex = null;
PImage floorTex, stageTex;

int stageWidth = 12, stageDepth = 12;
int tailLength = 500;
int currentFrame = 0;

void setup()
{
    size( 1000, 800, P3D);
    
    floorTex = loadImage("wood5.png");
    stageTex = loadImage("warm.png");
    
    cam = new PeasyCam(this, 500);
    cam.setMinimumDistance(50);
    cam.setMaximumDistance(5000);
    
    String[] lns = loadStrings( posBase + "/" + "Tracked3DPosition.txt" );
    int i = 0;
    ps3D = new float[3][lns.length];
    for ( String l : lns )
    {
        if ( l.trim().equals("") ) continue;
        float[] p = float( l.split(" ") );
        ps3D[0][i] = p[0];
        ps3D[1][i] = p[1];
        ps3D[2][i] = p[2];
        i++;
    }
    
    lns = loadStrings( posBase + "/" + "Tracked2DPos_CamCenter.txt" );
    String[] lns2 = loadStrings( posBase + "/" + "BoundingBox_CamCenter.txt" );
    ps2DC = new float[lns.length][2];
    bx2DC = new float[lns.length][2];
    for ( int l = 0; l < lns.length; l++ )
    {
        float[] pos2D = float( lns[l].split(" ") );
        float[] box2D = float( lns2[l].split(" ") );
        bx2DC[l] = box2D;
        ps2DC[l] = new float[]{
            pos2D[0]-box2D[0],
            pos2D[1]-box2D[1]
        };
    }
    
    frameRate( 50 );
    //println(PFont.list());
    textFont( createFont( "LucidaGrande", 10 ) );
    
    Interactive.make( this );
    slider = new Slider( 5,5, width-10,20 );

    //tex = new PImage( 1920, 1080, ARGB );
    tex = loadImage(silBase + nf(0, 6) + ".png");
    if ( tex == null )
    {
        System.err.println( "Texture not found." );
        exit();
        return;
    }
    tex.mask( new int[tex.pixels.length] );
    tex.resize(1920, 1080);
    tex.loadPixels();
}

void mouseMoved ()
{
    cam.setActive( mouseY > 50 );
}

void draw() 
{
    background( 0 );
    
    int i = currentFrame % ps3D[0].length;
    currentFrame += (int)max(1, 50.0/frameRate);
    slider.setValue( (float)currentFrame / ps3D[0].length );

    //java.util.Arrays.fill( tex.pixels, 0, tex.pixels.length, 0x00FFFFFF );
    silh = loadImage( silBase + nf(i, 6) + ".png" );
    int l = tex.width * (int)bx2DC[i][1] + (int)bx2DC[i][0];
    int px = -1;
    for ( int k = 0; k < silh.height; k++ )
    {
        for ( int kk = 0; kk < silh.width; kk++ )
        {
            px = silh.pixels[k * silh.width + kk];
            if ( px == 0xFF00FFFF )
            {
                silh.pixels[k * silh.width + kk] = 0x00FFFFFF;
                tex.pixels[l + k*tex.width + kk] = 0x00FFFFFF;
            }
            else
            {
                tex.pixels[l + k*tex.width + kk] = silh.pixels[k * silh.width + kk];
            }
        }
    }

    tex.updatePixels();
    silh.updatePixels();
    
    pushMatrix();
    
    scale(100);
    
    rotateZ( PI );
    rotateY( PI );
    rotateX( -HALF_PI/4 );
    translate( -stageWidth/2, 0, -stageDepth/2 );
    
    // wooden floor
    pushMatrix();
    fill( 0 );
    translate( 6, 0, 5 );
    float flw = 19.8;
    beginShape();
        texture( floorTex );
        vertex( -flw, -0.1, -flw, 0, 0 );
        vertex(  flw, -0.1, -flw, floorTex.width, 0 );
        vertex(  flw, -0.1,  flw, floorTex.width, floorTex.height );
        vertex( -flw, -0.1,  flw, 0, floorTex.height );
    endShape(CLOSE);
    popMatrix();
    
    // spring floor
    pushMatrix();
    fill( 97, 100, 90 );
    translate( stageWidth/2, -0.1, stageDepth/2 );
    scale( stageWidth, 0.18, stageDepth );
    box(1);
    popMatrix();
    
    // stage pvc floor
    fill( 248, 248, 245 );
    beginShape();
        texture( stageTex );
        vertex( 0, 0, 0,                   0, 0 );
        vertex( stageWidth, 0, 0,          stageTex.width, 0 );
        vertex( stageWidth, 0, stageDepth, stageTex.width, stageTex.height );
        vertex( 0, 0, stageDepth,          0, stageTex.height );
    endShape(CLOSE);
    
    pushMatrix();
    
    int h = tailLength, ii = 0, k = 0;
    
    if ( false ) {
        noStroke();
        fill( 0,10 );
        beginShape(TRIANGLE_STRIP);
            ii = i > h ? i-h : 0;
            k = i+h < ps3D[0].length ? i+h : ps3D[0].length;
            for ( ; ii < k; ii++ )
            {
                vertex( ps3D[0][ii], ps3D[2][ii], ps3D[1][ii] );
                vertex( ps3D[0][ii], 0, ps3D[1][ii] );
            }
        endShape();
    }
    
    noFill();
    strokeWeight(0.01);
    beginShape();
        ii = i > h ? i-h : 0;
        k = i+h < ps3D[0].length ? i+h : ps3D[0].length;
        for ( ; ii < k; ii++ )
        {
            stroke( ii < i ? 255 : 0xFFFFFF00 );
            vertex( ps3D[0][ii], ps3D[2][ii], ps3D[1][ii] );
        }
    endShape();
    stroke(100);
    beginShape();
        ii = i > h ? i-h : 0;
        for ( ; ii < k; ii++ )
        {
            vertex( ps3D[0][ii], 0.01, ps3D[1][ii] );
        }
    endShape();
    
    translate( ps3D[0][i], ps3D[2][i], ps3D[1][i] );
    
    noStroke();
    fill( 255, 0, 0 );
    box(0.025);
    
    rotateX( PI );
    //rotateY( PI );
    // calc silhouette scale
    float s = (silh.height-ps2DC[i][1])/ps3D[2][i];
    float tx = bx2DC[i][0];
    float ty = bx2DC[i][1];
    float sx = ps2DC[i][0]/-s;
    float sy = ps2DC[i][1]/-s;
    float sw = silh.width/s;
    float sh = silh.height/s;
    
    fill(0,0);
    noStroke();
    
    pgl = (PJOGL)beginPGL();
    gl = pgl.gl.getGL2();  

    gl.glDisable(GL.GL_DEPTH_TEST);
    gl.glEnable(GL.GL_BLEND);
    
    pushMatrix();
    rotateX( HALF_PI );
    translate( 0, -sh/8, -sh+0.01 );
    fill( 90 );
    
    ////gl.gl2x.glBlendColor( 1f,0f,0f,0.5f );
    ////gl.glBlendEquation( GL.GL_FUNC_REVERSE_SUBTRACT );
    
    gl.glBlendFunc( GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA  );
    
    beginShape();
        texture( tex );
        vertex(sx,sy,         tx, ty);
        vertex(sx+sw,sy,      tx+silh.width, ty);
        vertex(sx+sw,sy+sh/4, tx+silh.width, ty+silh.height);
        vertex(sx,sy+sh/4,    tx, ty+silh.height);
    endShape(CLOSE);
    popMatrix();
    
    gl.glBlendEquation( GL.GL_FUNC_ADD );
    gl.glBlendFunc( GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA );
    
    beginShape();
        texture( tex );
        vertex(sx,sy,       tx, ty);
        vertex(sx+sw,sy,    tx+silh.width, ty);
        vertex(sx+sw,sy+sh, tx+silh.width, ty+silh.height);
        vertex(sx,sy+sh,    tx, ty+silh.height);
    endShape(CLOSE);

    endPGL();
    
    popMatrix();
    
    rotateX(-HALF_PI);
    scale( 0.02 );
    fill( 200 );
    textAlign( LEFT );
    textMode( MODEL );
    text( "FRONT", 0, 10, 0 );
    
    popMatrix();
    
    cam.beginHUD();
    //image( silh, 100, 0, 50, 50 );
    textAlign( LEFT );
    text( currentFrame + " @ " + frameRate , 10, height-10 );
    
    //for ( GuiItem item : gui ) item.draw( true );
    slider.drawSlider();
    
    cam.endHUD();
}
