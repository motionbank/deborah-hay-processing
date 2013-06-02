
void scrollEvent ( int scroll )
{
    globalScale += scroll;
    if ( globalScale < 0.1 ) globalScale = 0.1;
}

void mousePressed ()
{
    arcController.mousePressed( mouseX, mouseY );
}

void mouseDragged ()
{
    if ( !mode1 )
        arcController.mouseDragged( mouseX, mouseY );
    else
        playhead = constrain( mouseX, 20, width-20 ) - 20;
}

void keyPressed ()
{
    if ( key == ' ' )
    {
        playing = !playing;
    }
    else if ( key == '1' )
    {
        mode1 = !mode1;
    }
    else if ( key == 's' )
    {
        savePngs = true;
        currentTitleCluster = titleClusters.values().toArray()[0];
    }
}
