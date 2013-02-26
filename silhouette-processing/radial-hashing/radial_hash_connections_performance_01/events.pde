
void mousePressed ()
{
    int perf = mouseY / (height / performances.size());
    int mx = constrain( mouseX, 10, width-20 );
    int frame = (int)map( mx, 10, width-20, 0, performancesLengths.get(perf) );
    
    updatePerformancePosition( perf, frame );
}

void updatePerformancePosition ( int perf, int frame )
{
    String perfName = performances.get(perf);
    
    int id = -1, fasthash = -1;
    String vals = "";
    String file = "";
    
    db.query( "SELECT * FROM images WHERE file LIKE \"%s\" LIMIT 1", perfName + "%" + nf(frame,6) + ".png" );
    
    if ( db.next() )
    {
        id = db.getInt( "id" );
        fasthash = db.getInt( "fasthash" );
        file = db.getString( "file" );
        
        for ( int i = 0; i < 32; i++ )
        {
            vals += (vals.length() > 0 ? " + " : "") + String.format( "abs(v%03d - %d)", i, db.getInt( String.format("v%03d", i) ) );
        }
    }
    
    origin = new Connection( perfName, perf, frame, file, 0 );
    
    // calc connections ..
    
    connections = new ArrayList();
    
    for ( String pn : performances )
    {
        if ( pn.equals( perfName ) ) continue;
        
        db.query( "SELECT id, file, %s AS dist, SUBSTR(file, 0, 11) AS perf "+
                  "FROM images "+
                  "WHERE id IS NOT %d "+
                      "AND hamming_distance_32(%d,fasthash32) < %d "+
                      "AND file LIKE \"%s\" "+
                  "ORDER BY dist ASC "+
                  "LIMIT %d", 
                  vals, 
                  id, 
                  fasthash,
                  2,
                  pn + "%",
                  1 );
        
        while ( db.next() )
        {
            String rFile = db.getString("file");
            String rPerfName = db.getString("perf");
            int rPerf = performances.indexOf( rPerfName );
            int rFrame = Integer.parseInt( rFile.substring( rFile.length()-10, rFile.length()-4 ) );
            float rDist = db.getFloat( "dist" );
            
            if ( rDist <= 200 )
                connections.add( new Connection( rPerfName, rPerf, rFrame, rFile, rDist ) );
        }
    }
}
