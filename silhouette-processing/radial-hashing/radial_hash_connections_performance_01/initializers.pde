
 void initDb ()
 {
     db = new SQLite( this, "../db/" + dbName );
     
     if ( !db.connect() )
     {
         System.err.println( "Unable to connect to database " + dbName );
         exit();
         return;
     }
     
     addSQLiteHammingDistances();
 }
 
 void getPerformances ()
 {
     performances = new ArrayList();
     performancesLengths = new ArrayList();
     
     db.query( "SELECT DISTINCT SUBSTR(file, 0, 11) AS performance FROM images" );
     while ( db.next() )
     {
         performances.add( db.getString("performance") );
     }
     
     for ( int i = 0, k = performances.size(); i < k; i++ )
     {
         db.query( "SELECT count(*) AS total FROM images WHERE file LIKE \"%s\"", performances.get(i)+"%" );
         if ( db.next() )
         {
             performancesLengths.add( db.getInt("total") );
         }
     }
 }
 
void addSQLiteHammingDistances ()
{
    // HAMMING DISTANCE in SQLite
    // http://en.wikipedia.org/wiki/Hamming_distance
    
    try {
    org.sqlite.Function.create( db.getConnection(), "hamming_distance_32", new org.sqlite.Function() {
        protected void xFunc() {
            try {
                
                int val0 = value_int(0);
                int val1 = value_int(1);
                
                result( FastHash.getBinaryDistance( val0, val1 ) );
                
            } catch ( Exception e ) {
                e.printStackTrace();
            }
        }
    });
    org.sqlite.Function.create( db.getConnection(), "hamming_distance_64", new org.sqlite.Function() {
        protected void xFunc() {
            try {
                
                long val0 = value_int(0);
                long val1 = value_int(1);
                
                result( FastHash.getBinaryDistance( val0, val1 ) );
                
            } catch ( Exception e ) {
                e.printStackTrace();
            }
        }
    });
    } catch ( Exception e ) {
        e.printStackTrace();
    }
}
