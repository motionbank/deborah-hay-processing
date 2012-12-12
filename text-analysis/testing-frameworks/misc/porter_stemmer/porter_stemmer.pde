/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Example showing the use of at porter word stemmer.
 *
 *    P2.0b7
 *    created: fjenett - 2012-12
 */

import java.io.*;

String porterStemWord ( String word )
{
    char[] w = new char[501];
    StringReader in = new StringReader( word );
    try 
    {
        int ch = in.read();
        Stemmer s = new Stemmer();

        if (Character.isLetter((char) ch))
        {
            int j = 0;
            while (true)
            {  
                ch = Character.toLowerCase((char) ch);
                w[j] = (char) ch;
                if (j < 500) j++;
                ch = in.read();
                if (!Character.isLetter((char) ch))
                {
                    for (int c = 0; c < j; c++) s.add(w[c]);

                    s.stem();
                    String u;

                    u = s.toString();
                    return u;
                }
            }
        }
        if (ch < 0) {
            return null;
        }
        //System.out.print((char)ch);
    } 
    catch ( Exception e ) {
        e.printStackTrace();
    }
    return null;
}

void setup ()
{
    size( 200, 200 );

    for ( String word : "nose noses mouth mouths hand hands body bodies".split(" ") )
    {
        String wordStem = porterStemWord( word );
        println( wordStem );
    }
}

