import de.bezier.guido.*;
import java.io.*;

String posenTxt3D = "/Users/fjenett/Desktop/MOBA/ETHZ_D06T04_Janine Folder/ETHZSkeleton_3D.txt";

Pose3D[] poses;
int cPose = 0;
Slider slider, slider2;
boolean deepMode = true;

PVector center;

void setup ()
{
    size( 800, 800, OPENGL );
    
    if ( !new File(posenTxt3D).exists() )
    {
        System.err.println( "Pose file not found at\n" + posenTxt3D );
        exit();
        return;
    }
    
    Interactive.make(this);
    slider = new Slider( 5,height-15, width-10, 10 );
    slider2 = new Slider( 5,height-25, width-10, 10 );
    
    String[] lines = loadStrings( posenTxt3D );
    poses = new Pose3D[lines.length];
    
    for ( int i = 0; i < lines.length; i++ )
    {
        String l = lines[i];
        poses[i] = new Pose3D(l);
    }
    
    frameRate( 20 );
    colorMode( HSB );
    center = new PVector(0,0,0);
}

void draw ()
{
    background( 0 );
    
    pushMatrix();
    translate( width/2, height/2, -5 );
    rotateX( HALF_PI );
    rotateZ( slider2.value * TWO_PI );
    
    Pose3D currentPose = poses[cPose];
    if ( currentPose.valid && deepMode )
    {
        center.add( PVector.div( PVector.sub( currentPose.center, center ), 5 ) );
        
        translate( -center.x, -center.y, -center.z );
        for ( int l = 0; l < 20-1; l+=2 )
        {
            fill( l/20.0 * 255, 200, 255 );
            beginShape( QUAD_STRIP );
            for ( int i = -10; i < 10 && (cPose+i) >= 0 && (cPose+i) < poses.length; i++ )
            {
                Pose3D p = poses[cPose+i];
                if ( p.valid )
                {
                    vertex( p.x[l],   p.y[l],   p.z[l] );
                    vertex( p.x[l+1], p.y[l+1], p.z[l+1] );
                }
            }
            endShape();
        }
    }
    else
    {
        if ( currentPose.valid )
        {
            currentPose.drawCentered();
        }
    }
    
    popMatrix();
    
    cPose++;
    cPose %= poses.length;
    
    slider.setValue(cPose / (float)poses.length);
}

void sliderDragging ( Slider s )
{
    if ( s == slider )
    {
        cPose = (int)(slider.value * poses.length) % poses.length;
    }
}
