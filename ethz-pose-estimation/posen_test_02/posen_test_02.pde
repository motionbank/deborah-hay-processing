import de.bezier.guido.*;

String posenTxt3D = "/Users/fjenett/Downloads/ETHZ_D06T04_Janine Folder/ETHZSkeleton_3D.txt";

Pose3D[] poses;
int cPose = 0;
Slider slider;

void setup ()
{
    size( 800, 800, OPENGL );
    
    Interactive.make(this);
    slider = new Slider( 5,height-15, width-10, 10 );
    
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
    translate( width/2, height/2, -20 );
    rotateX( HALF_PI * 0.8 );
    
    Pose3D currentPose = poses[cPose];
    if ( currentPose.valid )
    {
        currentPose.drawCentered();
    }
    
    popMatrix();
    
    cPose++;
    cPose %= poses.length;
}
