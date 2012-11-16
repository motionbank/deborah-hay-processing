/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Blatantly downloads all the words and frequencies from wordcount.org ...
 *
 *    P-2.0b6
 *    updated: fjenett 20121116
 */

import java.util.Map.Entry;

// http://www.wordcount.org/

// http://www.wordcount.org/dbquery.php?toFind=jump&method=SEARCH_BY_NAME
// http://www.wordcount.org/dbquery.php?toFind=1&method=SEARCH_BY_INDEX

// http://www.wordcount.org/dbquery_querycount.php?toFind=666&method=SEARCH%5FBY%5FINDEX
// http://www.wordcount.org/dbquery_querycount.php?toFind=pirate&method=SEARCH_BY_NAME

// total of 86800 words

HashMap<Integer, String> words = new HashMap<Integer, String>();
HashMap<Integer, Float> frequencies = new HashMap<Integer, Float>();

int next = 0, index = 0;
String response;
String[] tuples, keyValue;

while ( true )
{
    response = join( loadStrings( "http://www.wordcount.org/dbquery.php?toFind="+next+"&method=SEARCH_BY_INDEX" ), "\n" );

    if ( response != null && !response.equals("") )
    {
        tuples = split( response, "&" );

        if ( tuples != null && tuples.length > 0 )
        {
            for ( String tuple : tuples )
            {
                keyValue = split( tuple, "=" );

                if ( keyValue != null && keyValue.length == 2 )
                {
                    try {

                        String marker = keyValue[0].substring(0, 4);
                        index = Integer.parseInt( keyValue[0].substring(4) );

                        if ( marker.equals("word") )
                        {
                            words.put( index+next, keyValue[1] );
                        }
                        else if ( marker.equals("freq") )
                        {
                            float freq = Float.parseFloat( keyValue[1] );
                            frequencies.put( index+next, freq );
                        }
                    } 
                    catch ( NumberFormatException nfe ) {
                        // ignore
                    }
                }
            }
        }
    }

    int lIndex = next;
    next += index+1;

    if ( next >= 86800 ) break;

    println( (next / 86800.0) + " " + next );
}

try {

    PrintStream out = new PrintStream( createOutput( "bnc-freq-wordcount.txt" ), true, "UTF-8" );

    Map<Integer, String> sortedWords = new TreeMap<Integer, String>(words);
    for ( Entry<Integer, String> en : sortedWords.entrySet() )
    {
        out.println( en.getKey() + "\t" + en.getValue() + "\t" + frequencies.get( en.getKey() ) );
    }
} 
catch ( Exception e ) {
}

