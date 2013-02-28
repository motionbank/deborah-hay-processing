
 void initDb ()
 {
     db = new SQLite( this, "../db/" + dbName );
     
     if ( !db.connect() )
     {
         System.err.println( "Unable to connect to database " + dbName );
         exit();
         return;
     }
     
     addSQLiteDistanceFunctions();
 }
 
 void addSQLiteDistanceFunctions ()
{
    try {
    org.sqlite.Function.create( db.getConnection(), "hex_dist", new org.sqlite.Function() {
        protected void xFunc() {
            try {
                
                String val0 = value_text(0);
                String val1 = value_text(1);
                
                int dist = 0;
                
                if ( val0.equals( val1 ) ) 
                {
                    dist = 0;
                }
                else
                {
                    for ( int i = 0, k = val0.length(); i < k; i += 2 )
                    {
                        int iVal0 = Integer.parseInt( val0.substring(i,i+2), 16 );
                        int iVal1 = Integer.parseInt( val1.substring(i,i+2), 16 );
                        int d = iVal0 - iVal1;
                        dist += d > 0 ? d : -d;
                    }
                }
                
                result( dist );
                
            } catch ( Exception e ) {
                e.printStackTrace();
            }
        }
    });
    } catch ( Exception e ) {
        e.printStackTrace();
    }
}
