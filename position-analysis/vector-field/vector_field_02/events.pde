
void keyPressed ()
{
    if ( key == ' ' ) drawMode = MOVERS;
    if ( key == '1' ) drawMode = FIELD_LINES;
    if ( key == '2' ) drawMode = FIELD_COLORED;
    if ( key == '3' ) drawMode = PATHS;
    
    if ( key == '4' ) drawMode = INFORMATION;
    
    if ( key == 'm' ) movers = new ArrayList();
    if ( key == 'v' ) addMoverGrid();
    
    if ( key == 'p' ) safePDF = true;
 }

void mousePressed ()
{
    for ( int i = 0; i < 5; i++ )
    {
        float r = random( TWO_PI );
        float d = random( 1, fieldGrid );
        Mover m = new Mover( mouseX + sin(r)*d, height - (mouseY + cos(r)*d) );
        m.update();
        movers.add( m );
    }
}
