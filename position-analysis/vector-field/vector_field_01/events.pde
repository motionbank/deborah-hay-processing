
void keyPressed ()
{
    if ( key == ' ' ) showField = !showField;
    if ( key == 'b' ) showBackground = !showBackground;
    if ( key == 'm' ) movers = new ArrayList();
    if ( key == 'v' ) addMoverGrid();
 }

void mousePressed ()
{
    Mover m = new Mover(mouseX, mouseY);
    movers.add( m );
}
