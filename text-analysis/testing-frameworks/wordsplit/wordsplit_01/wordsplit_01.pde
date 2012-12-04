/**
 *    http://www.whitemagicsoftware.com/software/java/wordsplit/
 */

import com.whitemagicsoftware.wordsplit.*;

import java.io.*;

void setup ()
{
    size( 200, 200 );

    TextSegmenter ts = new TextSegmenter();
    try {
        ts.split( new File( dataPath("lexicon.csv") ), new File( dataPath("conjoined.txt") ) );
    } catch ( Exception e ) {
        e.printStackTrace();
    }
}

