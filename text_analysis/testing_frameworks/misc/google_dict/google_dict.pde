/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Query Google dictionary test
 *
 *    P-2.0b6
 *    updated: fjenett 20121116
 */

// http://googlesystem.blogspot.com/2009/12/on-googles-unofficial-dictionary-api.html
// http://www.google.com/dictionary/json?callback=dict_api.callbacks.id100 & q=test & sl=en & tl=en & restrict=pr%2Cde & client=te

import java.util.Map.Entry;
import org.json.*;

void setup ()
{
    size( 200, 200 );
    
    GoogleDictRequest r = new GoogleDictRequest();
    r.put( "q", "arm" );
    
    String jsonString = join(loadStrings( r.toURL() ), "\n");
    jsonString = jsonString.substring( jsonString.indexOf("{"), jsonString.lastIndexOf("}")+1 );
    jsonString = jsonString.replaceAll( "\\\\x", "\\\\u00" );
    
    JSONObject jsonObject = null;
    try {
        jsonObject = new JSONObject( jsonString );
    } catch ( JSONException je ) {
        je.printStackTrace();
    }
    
    try {
        JSONArray primaries = jsonObject.getJSONArray( "primaries" );
        for ( int i = 0, l = primaries.length(); i < l; i++ )
        {
            println( primaries.get(0) );
        }
    } catch ( JSONException je ) {
        je.printStackTrace();
    }
}
