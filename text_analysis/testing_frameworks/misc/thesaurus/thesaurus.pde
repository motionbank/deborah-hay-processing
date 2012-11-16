/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Needs a new API key ... old one has expired.
 *
 *    P-2.0b6
 *    updated: fjenett 20121116
 */

// http://words.bighugelabs.com/
//
String query = "piece";
String apikey = "ab77cfe15b499ed46910af6cf46efdff";
String xmlSrc = join( loadStrings("http://words.bighugelabs.com/api/2/"+apikey+"/"+query+"/xml"), "\n" );
XML response = new XML( xmlSrc );
println( response );

