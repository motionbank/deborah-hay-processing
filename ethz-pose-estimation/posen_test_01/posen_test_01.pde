
String posenTxt3D = "/Users/fjenett/Downloads/ETHZ_D06T04_Janine Folder/ETHZSkeleton_3D.txt";

Pose3D[] poses;
int cPose = 0;

void setup ()
{
    size( 800, 800, OPENGL );
    
    String[] lines = loadStrings( posenTxt3D );
    poses = new Pose3D[lines.length];
    
    for ( int i = 0; i < lines.length; i++ )
    {
        String l = lines[i];
        poses[i] = new Pose3D(l);
    }
    
    frameRate( 5 );
}

void draw ()
{
    background( 0 );
    
    pushMatrix();
    translate( width/2, height/2, -2000 );
    rotateX( HALF_PI * 0.8 );
    
    Pose3D currentPose = poses[cPose];
    if ( currentPose.valid )
    {
        currentPose.draw();
    }
    
    popMatrix();
    
    cPose++;
    cPose %= poses.length;
}
