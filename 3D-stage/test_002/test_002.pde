import de.bezier.gui.*;
import processing.opengl.*;
import peasy.*; // http://mrfeinberg.com/peasycam/

String posBase = "/Volumes/Express/RosWarbyDVD2/RosWarby_Sequence01/Positions";
String silBase = "/Volumes/Express/RosWarbyDVD2/RosWarby_Sequence01/"+
                  "Images_backgroundSubstracted/CamCenter/"+
                  "CamCenter_BackgroundSubstracted";
float[][] ps3D;
float[][] ps2DC;
float[][] bx2DC;

PeasyCam cam;
ArrayList<GuiItem> gui;
GuiSlider slider;

PImage silh;
PImage tex = null;

int currentFrame = 0;

void setup()
{
    size(800,600,OPENGL);
    cam = new PeasyCam(this, 150);
    cam.setMinimumDistance(5);
    cam.setMaximumDistance(500);
    
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
    String[] lns2 = loadStrings( posBase + "/" + "BoundingBox_CamCenter_iMin_jMin_iMax_jMax.txt" );
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
    
    gui = new ArrayList<GuiItem>();

//    GuiButton button = new GuiButton(this);
//    button.set(new Object(){
//        PVector position = new PVector(20,20);
//        PVector size = new PVector(20,20);
//        boolean autoRender = false;
//    });
//    button.addListener( new GuiListener () {
//        public void bang ( GuiEvent evt ) {
//            println( "bang" );
//        }
//    });
//    gui.add( button );

    slider = new GuiSlider(this).setValue(0);
    slider.set(
        "position", new PVector(5,5),
        "size", new PVector(width-10, 20)
    );
    slider.setAutoRender(false);
    slider.setMinMax(0,ps2DC.length);
    slider.addListener(new GuiListener(){
        public void changed ( GuiEvent evt )
        {
            int nextFrame = (int)((GuiSlider)evt.item).value();
            currentFrame = nextFrame;
        }
    });
    gui.add( slider );

    //tex = new PImage( 1920, 1080, ARGB );
    tex = loadImage(silBase + nf(0, 5) + ".png");
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
    background(255);
    
    int i = currentFrame % ps3D[0].length; currentFrame++;
    slider.setValue( currentFrame );

        //java.util.Arrays.fill( tex.pixels, 0, tex.pixels.length, 0x00FFFFFF );
        silh = loadImage( silBase + nf(i, 5) + ".png" );
        int l = tex.width * (int)bx2DC[i][1] + (int)bx2DC[i][0];
        int px = -1;
        for ( int k = 0; k < silh.height; k++ )
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

        tex.updatePixels();
        silh.updatePixels();
    
    pushMatrix();
    
    scale(10);
    
    rotateZ( PI );
    rotateY( PI );
    rotateX( -HALF_PI/4 );
    translate( -6, 0, -6 );
    
    pushMatrix();
    fill( 248, 248, 245 );
    beginShape();
        vertex( 0, 0 );
        vertex( 0, 0, 12 );
        vertex( 12, 0, 12 );
        vertex( 12, 0, 0 );
    endShape(CLOSE);
    popMatrix();
    
    pushMatrix();
    
    //stroke( 0 );
    int h = 2000, ii = 0, k = 0;
//    noStroke();
//    fill( 0,10 );
//    beginShape(TRIANGLE_STRIP);
//        ii = i > h ? i-h : 0;
//        k = i+500 < ps3D[0].length ? i+500 : ps3D[0].length;
//        for ( ; ii < k; ii++ )
//        {
//            vertex( ps3D[0][ii], ps3D[2][ii], ps3D[1][ii] );
//            vertex( ps3D[0][ii], 0, ps3D[1][ii] );
//        }
//    endShape();
    
    beginShape(LINES);
        ii = i > h ? i-h : 0;
        k = i+500 < ps3D[0].length ? i+500 : ps3D[0].length;
        for ( ; ii < k; ii++ )
        {
            stroke( ii < i ? 0 : 0xFFFF0000 );
            vertex( ps3D[0][ii], ps3D[2][ii], ps3D[1][ii] );
        }
    endShape();
    stroke(220);
    beginShape(LINES);
        ii = i > h ? i-h : 0;
        for ( ; ii < k; ii++ )
        {
            vertex( ps3D[0][ii], 0.1, ps3D[1][ii] );
        }
    endShape();
    
    translate( ps3D[0][i], ps3D[2][i], ps3D[1][i] );
    
    noStroke();
    fill( 255, 0,0 );
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
    
    beginShape();
        texture( tex );
        vertex(sx,sy,       tx, ty);
        vertex(sx+sw,sy,    tx+silh.width, ty);
        vertex(sx+sw,sy+sh, tx+silh.width, ty+silh.height);
        vertex(sx,sy+sh,    tx, ty+silh.height);
    endShape(CLOSE);
    
//    beginShape();
//        texture( silh );
//        vertex(sx,sy,       0,0);
//        vertex(sx+sw,sy,    silh.width, 0);
//        vertex(sx+sw,sy+sh, silh.width, silh.height);
//        vertex(sx,sy+sh,    0, silh.height);
//    endShape(CLOSE);
    
    popMatrix();
    
    rotateX(-HALF_PI);
    scale( 0.1 );
    fill( 200 );
    textAlign( CENTER );
    textMode( MODEL );
    text( "FRONT", 60, 20 );
    
    popMatrix();
    
    cam.beginHUD();
    //image( silh, 100, 0, 50, 50 );
    textAlign( LEFT );
    text( currentFrame + " @ " + frameRate , 10, height-10 );
    for ( GuiItem item : gui ) item.draw( true );
    cam.endHUD();
}
