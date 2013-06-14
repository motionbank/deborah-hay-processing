
void keyPressed ()
{
    if ( loading ) return;
    
    if ( key == CODED )
    {
        int ito, ifrom;
        switch ( keyCode )
        {
            case RIGHT:
                nextPerformance();
                break;
            case LEFT:
                currClusterIndex--;
                if ( currClusterIndex < 0 ) currClusterIndex = clusters.size()-1;
                break;
            case UP:
                ifrom = sceneNames.indexOf( sceneFrom );
                if ( ifrom > 0 ) ifrom--;
                ito = sceneNames.indexOf( sceneTo );
                if ( ito > ifrom+1 ) ito--;
                sceneFrom = sceneNames.get( ifrom );
                list1.select( sceneFrom );
                sceneTo = sceneNames.get( ito );
                list2.select( sceneTo );
                break;
            case DOWN:
                nextScene();
                break;
        }
        
        currCluster = clusters.get(currClusterIndex);
    }
    else
    {
        switch ( key )
        {
            case 's':
                showAll = !showAll;
                break;
            case 'p':
                savePDF = true;
                break;
            case 'e':
                exportAll();
                break;
            case 'h':
                withHighlight = !withHighlight;
                break;
            case 'c':
                asConvexHull = !asConvexHull;
                break;
            case ' ':
                showInterface = !showInterface;
                if ( !showInterface ) {
                    Interactive.setActive(false);
                }
                break;
        }
    }
}
