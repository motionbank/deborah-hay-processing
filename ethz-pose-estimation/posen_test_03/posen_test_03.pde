import de.bezier.guido.*;

String posenTxt3D = "/Users/fjenett/Downloads/ETHZ_D06T04_Janine Folder/ETHZSkeleton_3D.txt";

Pose3D[] poses;
int cPose = 0;
Slider slider, slider2;
boolean deepMode = true;

void setup ()
{
    size( 800, 800, OPENGL );
    
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
}

void draw ()
{
    background( 0 );
    
    pushMatrix();
    translate( width/2, height/2, -2000 );
    rotateX( HALF_PI );
    rotateZ( slider2.value * TWO_PI );
    
    Pose3D currentPose = poses[cPose];
    if ( deepMode )
    {
        for ( int i = -10; i < 10 && (cPose+i) >= 0 && (cPose+i) < poses.length; i++ )
        {
            Pose3D p = poses[cPose+i];
            if ( p.valid )
            {
                p.draw();
            }
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
    slider.value = cPose / (float)poses.length;
}

void sliderDragging ( Slider s )
{
    if ( s == slider )
    {
        cPose = (int)(slider.value * poses.length) % poses.length;
    }
}
