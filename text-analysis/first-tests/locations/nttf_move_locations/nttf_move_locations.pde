/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Looking into the instructions given for movements / poses and
 *    locations.
 *
 *    The xml is handcrafted .. not optimal.
 *
 *    Note: uses 2010 version of NTTF
 *
 *    P-2.0b6
 *    created: fjenett - 2011-01
 *    updated: fjenett 20121116
 */
 
 void setup ()
 {
     size( 200, 200 );
     
     XML nttf = null;
     try {
         nttf = new XML( this, "NTTF_sentences.xml" );
     } catch ( Exception e ) {
         e.printStackTrace();
     }
     
     for ( XML child : nttf.getChildren( "s/m" ) )
     {
         //println( getContent( child ) );
     }
     
     println( "- - - - - - - -" );
     
     for ( XML child : nttf.getChildren( "s/l" ) )
     {
         println( getContent( child ) );
     }
     
     exit();
 }
 
 String getContent ( XML element )
 {
     String o = element.getContent();
     
     if ( o == null )
     {
         o = "";
         
         for ( XML child : element.getChildren() )
         {
             o += getContent( child );
         }
     }
     
     return o;
 }
