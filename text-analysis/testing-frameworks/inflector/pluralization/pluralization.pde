/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Testing the inflector framework.
 *
 *    mathbaer 2012-12
 *    fjenett 20121221
 */

import static org.jvnet.inflector.Noun.pluralOf; // static functions can be imported in newer Java versions

void setup() 
{
    println( pluralOf("hand") );
    println( pluralOf("leg") );
    println( pluralOf("chair") );

    noLoop();
}

