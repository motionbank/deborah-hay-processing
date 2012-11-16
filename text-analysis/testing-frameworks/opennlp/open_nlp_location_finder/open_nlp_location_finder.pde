/**
 *    Motion Bank research, http://motionbank.org
 *
 *    OpenNLP test, see
 *    http://incubator.apache.org/opennlp/
 *
 *    Note: uses 2010 version of NTTF text
 *
 *    P-2.0b6
 *    updated: fjenett 20121116
 */
 
// Models
// http://opennlp.sourceforge.net/models-1.5/
import opennlp.tools.sentdetect.*;

void setup () {

    size( 200, 200 );
    
    //println( opennlp.tools.parser.Parse.class.getDeclaredMethods() );

    String nttf = join( loadStrings("NTTF_sequenced.txt"), "\n" );
    String[] sentences = openNLP_getSentences(nttf);
    for ( String sentence : sentences )
    {
        //openNLP_parser( sentence );
        
        String[] tokens = openNLP_getTokens( sentence );
        openNLP_getNames( tokens );
        openNLP_getLocations( tokens );
    }
    
    exit();
}

ParserModel parserModel = null;
void openNLP_parser ( String sentence )
{
    if ( parserModel == null )
    {
        InputStream modelIn = createInput("en-parser-chunking.bin");
        try {
            parserModel = new ParserModel(modelIn);
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        
        finally {
            if (modelIn != null) {
                try {
                    modelIn.close();
                }
                catch (IOException e) {
                }
            }
        }
    }
    
    opennlp.tools.parser.chunking.Parser parser = 
        (opennlp.tools.parser.chunking.Parser) ParserFactory.create( parserModel );

    opennlp.tools.parser.Parse topParses[] = ParserTool.parseLine( sentence, parser, 1 );
    for ( opennlp.tools.parser.Parse parse : topParses )
    {
        parse.show();
        /*println( parse.getChildCount() );
        for ( opennlp.tools.parser.Parse childParse : parse.getChildren() )
        {
            println( childParse.getChildCount() );
        }*/
    }
}

TokenNameFinderModel nameModel = null;
void openNLP_getNames ( String[] words )
{
    if ( nameModel == null )
    {
        InputStream modelIn = createInput("en-ner-person.bin");
        
        try {
            nameModel = new TokenNameFinderModel( modelIn );
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        finally {
            if (modelIn != null) {
                try {
                    modelIn.close();
                }
                catch (IOException e) {
                }
            }
        }
    }
    
    NameFinderME nameFinder = new NameFinderME( nameModel );
    Span nameSpans[] = nameFinder.find( words );
    
    if ( nameSpans != null )
    {
        for ( Span s : nameSpans )
        {
            for ( int i = s.getStart(); i < s.getEnd(); i++ )
                println( words[i] );
        }
    }
    
    nameFinder.clearAdaptiveData();
}

TokenNameFinderModel nameModel2 = null;
void openNLP_getLocations ( String[] words )
{
    if ( nameModel2 == null )
    {
        InputStream modelIn = createInput("en-ner-location.bin");
        
        try {
            nameModel2 = new TokenNameFinderModel( modelIn );
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        finally {
            if (modelIn != null) {
                try {
                    modelIn.close();
                }
                catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    NameFinderME nameFinder = new NameFinderME( nameModel2 );
    Span nameSpans[] = nameFinder.find( words );
    
    if ( nameSpans != null )
    {
        for ( Span s : nameSpans )
        {
            for ( int i = s.getStart(); i < s.getEnd(); i++ )
                println( words[i] );
        }
    }
    
    nameFinder.clearAdaptiveData();
}

TokenizerModel tokenModel = null;
String[] openNLP_getTokens ( String txt )
{
    if ( tokenModel == null )
    {
        InputStream modelIn = createInput("en-token.bin");
        try {
            tokenModel = new TokenizerModel(modelIn);
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        
        finally {
            if (modelIn != null) {
                try {
                    modelIn.close();
                }
                catch (IOException e) {
                }
            }
        }
    }

    TokenizerME tokenizer = new TokenizerME( tokenModel );
    String tokens[] = tokenizer.tokenize( txt );

    // Span tokenSpans[] = tokenizer.tokenizePos("An input sample sentence.");

    //double tokenProbs[] = tokenizer.getTokenProbabilities();
    //println( tokenProbs );

    return tokens;
}

String[] openNLP_getSentences ( String txt ) 
{
    InputStream modelIn = createInput("en-sent.bin");
    SentenceModel model = null;

    try {
        model = new SentenceModel(modelIn);
    } 
    catch (IOException e) {
        e.printStackTrace();
    } 
    finally {
        if (modelIn != null) 
        {
            try {
                modelIn.close();
            } 
            catch ( IOException e ) {
            }
        }
    }

    SentenceDetectorME sentenceDetector = new SentenceDetectorME(model);

    String sentences[] = sentenceDetector.sentDetect( txt );
    return sentences;
}

