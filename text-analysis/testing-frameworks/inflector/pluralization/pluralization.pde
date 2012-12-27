/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Testing the inflector framework.
 *
 *    mathbaer 2012-12
 *    fjenett 20121221
 */

import org.jvnet.inflector.*;

void setup() 
{
    println( Noun.pluralOf("hand") );
    println( Noun.pluralOf("leg") );
    println( Noun.pluralOf("chair") );

    noLoop();
}

