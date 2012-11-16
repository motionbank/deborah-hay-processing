/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Testing Balie, "baseline information extraction".
 *    http://balie.sourceforge.net/
 *
 *    Uses old 2010 NTTF text and markers!!
 *
 *    P-2.0b6
 *    created fjenett - 2011-01
 *    updated fjenett 20121116
 */

import ca.uottawa.balie.*;

String tmpPath = null;
String nttf = null;

/*
 *    This example will only print stuff to the console below and exit ...
 */
    
void setup ()
{
    size( 100, 100 );
    
    nttf = join( loadStrings( "NTTF_sequenced.txt" ), "\n" );
    
    // find the path to the temporary folder that this sketch is running from
    try {
        tmpPath = WekaPersistance.class.getClassLoader().getResource("").toURI().getPath();
    } catch ( Exception e ) {
        e.printStackTrace();
    }
    
    // "*.sig" files are expected to be at the level of this class, need to copy them
    copyDirectory( new File( sketchPath( "sigs" ) ), new File( tmpPath ) );
    // same for language files ..
    copyDirectory( new File( sketchPath( "lexicon" ) ), new File( tmpPath + File.separator + "lexicon" ) );
    copyDirectory( new File( sketchPath( "rulesystem" ) ), new File( tmpPath + File.separator + "rulesystem" ) );
    
    //testWekaLearner();
    
    /*
     +    LANGUAGE DETECTION
     +
     L + + + + + + + + + + + + + + + + + + + + + + + + */
    LanguageIdentification li = new LanguageIdentification();
    String strLanguage = li.DetectLanguage( nttf );
    
    println( "Detected language:" );
    println( strLanguage );
    println();
    
    /*
     +    TOKENIZING
     +
     L + + + + + + + + + + + + + + + + + + + + + + + + */
    Tokenizer tokenizer = new Tokenizer(strLanguage, true);
    tokenizer.Tokenize( nttf );
    TokenList alTokenList = tokenizer.GetTokenList();
    
    println( "Tokens:" );
    println( alTokenList.WordList() );
    println();
    
    /*
     +    SENTENCES
     +
     L + + + + + + + + + + + + + + + + + + + + + + + + */
     
    println( "Sentences:" );
    for ( int i = 0; i < alTokenList.getSentenceCount(); i++ )
    {
        println( alTokenList.SentenceText( i, true, true ) );
    }
    println();
    
    /*
     +    NAMED ENTITIES
     +
     L + + + + + + + + + + + + + + + + + + + + + + + + */
    LexiconOnDiskI lexicon = new LexiconOnDisk(LexiconOnDisk.Lexicon.OPEN_SOURCE_LEXICON);
    DisambiguationRulesNerf disambiguationRules = DisambiguationRulesNerf.Load();
            
    tokenizer.Tokenize( nttf );
    TokenList alTokenList2 = tokenizer.GetTokenList();
    
    boolean debuggingInfo = false;
    NamedEntityRecognitionNerf ner = 
        new NamedEntityRecognitionNerf(
            alTokenList2, 
            lexicon, 
            disambiguationRules,
            new PriorCorrectionNerf(),
            NamedEntityTypeEnumMappingNerf.values(),
            debuggingInfo
        );
            
    ner.RecognizeEntities();
    
    TokenList alTokenList3 = ner.GetTokenList();
    Hashtable<String, Double> termFreqTable = alTokenList3.TermFrequencyTable();
    
    println( "Named entities:" );
    TokenListIterator iter = alTokenList3.Iterator();
    while ( iter.HasNext() )
    {
        Token t = iter.Next();
        NamedEntityType neType = t.EntityType();
        if ( neType.TypeCount() > 0 )
        {
            ArrayList neLabels = neType.GetAllLabels( NamedEntityTypeEnumMappingNerf.values() );
                        
            if ( neLabels.size() == 1 && neLabels.contains( "nothing" ) )
                continue;
            
            print( t.Canon() );
            println( " [" + termFreqTable.get(t.Canon()) + "]" );
            
            println( neType.GetInfo() );
            println( neLabels );
            
            println( t.Features() );
        }
    }
    println();
    
    println( alTokenList3.HashAccess() );
    println( alTokenList3.WordList() );
    println( alTokenList3.TermFrequencyTable() );
    
    exit();
}
