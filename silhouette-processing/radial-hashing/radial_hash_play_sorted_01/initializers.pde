
 void initDb ()
 {
     db = new SQLite( this, "../db/" + dbName );
     
     if ( !db.connect() )
     {
         System.err.println( "Unable to connect to database " + dbName );
         exit();
         return;
     }
 }
