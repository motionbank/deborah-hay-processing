/**
 *    Motion Bank research, http://motionbank.org
 *
 *    OpenNLP test, see:
 *    http://incubator.apache.org/opennlp/
 *
 *    NOT WORKING!
 *
 *    P-2.0b6
 *    updated: fjenett 20121116
 */

/**
 *    This is not working at all at the moment!
 *
 */

// http://www.asksunny.com/drupal/?q=node/4
// http://jgre.org/2009/08/31/identifying-names-with-opennlp-and-jruby/

import opennlp.tools.namefind.NameFinderME;
import opennlp.tools.tokenize.SimpleTokenizer;
import opennlp.maxent.io.BinaryGISModelReader;
import opennlp.tools.sentdetect.SentenceDetectorME;
import opennlp.tools.util.Span;

void setup ()
{
    size(200, 200 );
    
    /*SimpleTokenizer tokenizer = new SimpleTokenizer();
    SentenceDetectorME detector = null;
    try {
       detector = new SentenceDetectorME( new SentenceModel( createInput("models/EnglishSD.bin.gz") ) );
    } catch ( IOException ioe ) { ioe.printStackTrace(); }*/
}
