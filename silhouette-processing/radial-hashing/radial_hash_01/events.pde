void mousePressed ()
{
    currentSil += 2;
    currentSil %= pngs.length;
    
    isNewHash = true;
}

void keyPressed ()
{
    if ( key == CODED )
    {
        if ( keyCode == LEFT )
        {
            currentSil -= 2;
            if ( currentSil < 0 ) currentSil = pngs.length-1;
            isNewHash = true;
        }
        else if ( keyCode == RIGHT )
        {
            currentSil += 2;
            currentSil %= pngs.length;
            isNewHash = true;
        }
    }
}
