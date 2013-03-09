import processing.opengl.*;
import peasy.*; // http://mrfeinberg.com/peasycam/

String ps3DFile = "/Volumes/Express/RosWarbyDVD2/RosWarby_Sequence01/Positions/Tracked3DPosition.txt";
float[][] ps3D;

PeasyCam cam;

void setup()
{
    size(800,600,OPENGL);
    cam = new PeasyCam(this, 100);
    cam.setMinimumDistance(50);
    cam.setMaximumDistance(500);
    
    String[] lns = loadStrings( ps3DFile );
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
    println( min(ps3D[0]) + " " + max(ps3D[0]) );
    println( min(ps3D[1]) + " " + max(ps3D[1]) );
    println( min(ps3D[2]) + " " + max(ps3D[2]) );
    
    frameRate( 50 );
    textFont( createFont( "Verdana", 10 ) );
}

void draw() 
{
    background(255);
    
    pushMatrix();
    
    scale(10);
    
    rotateZ( PI );
    rotateX( -HALF_PI/2 );
    translate( -6, -6, 0 );
    
    pushMatrix();
    fill( 255, 250, 245 );
    beginShape();
        vertex( 0, 0 );
        vertex( 0, 12 );
        vertex( 12, 12 );
        vertex( 12, 0 );
    endShape(CLOSE);
    popMatrix();
    
    pushMatrix();
    int i = frameCount%ps3D[0].length;
    
    stroke( 0 );
    beginShape(LINES);
        int h = 2000;
        int ii = i > h ? i-h : 0;
        int k = i+500 < ps3D[0].length ? i+500 : ps3D[0].length;
        for ( ; ii < k; ii++ )
        {
            vertex( ps3D[0][ii], ps3D[1][ii], ps3D[2][ii] );
        }
    endShape();
    
    fill( 255,0,0 );
    translate( ps3D[0][i], ps3D[1][i], ps3D[2][i] );
    box(0.1);
    popMatrix();
    
    scale( 0.1 );
    rotateZ(-PI);
    fill( 200 );
    textAlign( CENTER );
    text( "FRONT", -60, 20 );
    
    popMatrix();
    
    cam.beginHUD();
    text( frameCount, 20, 20 );
    cam.endHUD();
}
