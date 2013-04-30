void initDatabase ()
{
    db = new MySQL( this, "localhost", "moba_silhouettes", "moba", "moba" );
    
    if ( !db.connect() )
    {
        System.err.println( "Unable to connect to database!" );
        exit();
        return;
    }
}

