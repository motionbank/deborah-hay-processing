void keyPressed ()
{
    if ( loaded )
    {
        if ( key == CODED && keyCode == RIGHT )
        {
            currentHeatMap++;
            if ( currentHeatMap >= groups[currentGroup].heatMaps.length )
            {
                currentGroup++;
                if ( currentGroup >= groups.length )
                {
                    currentGroup = 0;
                }
                currentHeatMap = 0;
            }
        }
        else if ( key == CODED && keyCode == LEFT )
        {
            currentHeatMap--;
            if ( currentHeatMap < 0 )
            {
                currentGroup--;
                if ( currentGroup < 0 )
                {
                    currentGroup = groups.length-1;
                }
                currentHeatMap = groups[currentGroup].heatMaps.length-1;
            }
        }
    }
}
