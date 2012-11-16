/**
 *    Motion Bank research, http://motionbank.org
 *    
 *    Find all UPPERCASED phrases in the NTTF text which denote something alike "scenes".
 *
 *    Note: uses 2010 version of NTTF text
 *
 *    P-2.0b6
 *    created: fjenett - 2011-01
 *    updated: fjenett 20121116
 */
 
 void setup ()
 {
     size( 200, 200 );
     
     String nttf = join( loadStrings( "NTTF_sequenced.txt" ), "\n" );
     
     findCountUpperCased(nttf);
     
     exit();
 }
 
 void findCountUpperCased ( String txt )
 {
     HashMap<String, Integer> hits = new HashMap<String, Integer>();
     String[][] matchSets = matchAll(txt, "([0-9A-Z]{2,}[-0-9A-Z ]*[A-Z]{2,})+");
     
     for ( String[] matchSet : matchSets )
     {
         Integer c = hits.get( matchSet[1] );
         int cc = c == null ? 1 : ++c;
         hits.put( matchSet[1], cc );
     }
     
     println( hits );
 }
