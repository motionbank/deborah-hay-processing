void keyPressed ()
{
    if ( loaded )
    {
        if ( key == CODED && keyCode == RIGHT )
        {
            nextHeatMap();
        } else if ( key == CODED && keyCode == LEFT )
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
        else if ( key != CODED )
        {
            if ( key == 'b' )
            {
                doAverage = !doAverage;
            } 
            else if ( key == '1' )
            {
                colorMode = colorMode == 1 ? 0 : 1;
            } 
            else if ( key == 'e' )
            {
                currentGroup = 0;
                currentHeatMap = 0;
                exportAll = true;
            }
            else if ( key == 'a' )
            {
                showAll = !showAll;
            }
            else if ( key == 'g' )
            {
                showGrouped = !showGrouped;
            }
        }
    }
}

void nextHeatMap () {
    currentHeatMap++;
    if ( showAll && showGrouped ) currentHeatMap = groups[currentGroup].heatMaps.length;
    if ( currentHeatMap >= groups[currentGroup].heatMaps.length )
    {
        currentGroup++;
        if ( currentGroup >= groups.length )
        {
            currentGroup = 0;
            if ( exportAll ) {
                exportAll = false;
            }
        }
        currentHeatMap = 0;
        if ( showAll && !showGrouped && exportAll ) {
            exportAll = false;
        }
    }
}

