/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Add plurals to a parts file of singulars
 *
 *    fjenett 20130108
 */

import org.jvnet.inflector.*;

void setup ()
{
    size( 200, 200 );

    String[] lines = loadStrings("body-parts.txt");
    String[] linesExt = new String[lines.length];
    for ( int i = 0; i < lines.length; i++ ) {
        linesExt[i] = lines[i] + "," + Noun.pluralOf(lines[i]);
    }
    saveStrings( "body-parts-ext.txt", linesExt );

    exit();
}

