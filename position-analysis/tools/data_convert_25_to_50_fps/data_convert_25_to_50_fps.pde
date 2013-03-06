
void setup ()
{
    size( 200, 200 );
    
    String[] files = new String[]{
        // add files here
        "/Users/fjenett/Desktop/Tracked2DPos_CamLeft.txt",
        "/Users/fjenett/Desktop/Tracked2DPos_CamRight.txt",
    };
    
    for ( String f : files )
    {
        String[] lines = loadStrings( f );
        String[] linesOut = new String[lines.length*2];
       
        float[] xyz = new float[3], xyzLast = new float[3];
        
        linesOut[0] = lines[0];
        for ( int l = 1, k = 2; l < lines.length; l++, k+=2 )
        {
            String ll = lines[l];
            
            linesOut[k] = "";
            linesOut[k-1] = "";
            
            String[] pieces = ll.split(" ");
            for ( int p = 0; p < pieces.length; p++ )
            {
                if ( pieces[p] == null || pieces[p].equals("") ) continue;
                
                xyz[p] = Float.parseFloat( pieces[p] );
                
                if ( k > 0 )
                    linesOut[k-1] += ( p > 0 ? " " : "" ) + int(xyzLast[p] + (xyz[p] - xyzLast[p])/2.0);
                
                linesOut[k] += ( p > 0 ? " " : "" ) + int(xyz[p]);
                
                xyzLast[p] = xyz[p];
            }
        }
        
        saveStrings( f.replace(".txt","_50fps.txt"), linesOut );
    }
}
