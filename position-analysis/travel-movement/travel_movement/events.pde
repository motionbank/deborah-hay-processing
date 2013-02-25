void keyPressed ()
{
    switch ( key )
    {
        case '+':
            if ( !loading )
            {
                currentCluster = clusters.get( (clusters.indexOf(currentCluster)+1) % clusters.size() );
                positions = null;
            }
            break;
        case '-':
            if ( !loading )
            {
                int i = clusters.indexOf(currentCluster)-1;
                if ( i < 0 ) i = clusters.size()-1;
                currentCluster = clusters.get( i );
                positions = null;
            }
            break;
    }
}
