/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Testing the cue.lang library by Jonathan Feinberg
 *
 *    Note: uses old 2010 version of NTTF text
 *
 *    P-2.0b6
 *    created: fjenett - 2011-01
 *    updated: fjenett 20121116
 */


// using Wordle spinoff by Jonathan Feinberg:
// https://github.com/jdf/cue.language
import cue.lang.*;
import java.util.Map.Entry;

String nttf;

void setup ()
{
    size( 640, 480 );
 
    nttf = join( loadStrings("NTTF.txt"), "\n" ).toLowerCase();
    
    println( "Most common NGrams:" );
    printMostCommonNGrams( nttf, 20 );
    println();
    
    printCountWord( nttf, "body" );
    
    exit();
}

void printMostCommonNGrams( String txt, int many )
{
    // find the most common 3-grams of the Baskervilles 
    Counter<String> ngrams = new Counter<String>();
    
    for ( String ngram : new NGramIterator( 3, txt, Locale.ENGLISH, StopWords.English ) )
    {
        ngrams.note(ngram.toLowerCase(Locale.ENGLISH));
    }
    
    for ( Entry<String, Integer> e : ngrams.getAllByFrequency().subList(0, many) )
    {
        println(e.getKey() + ": " + e.getValue());
    }
}

void printCountWord ( String txt, String word )
{
    // count "Baskerville"
    Counter<String> words = new Counter<String>();
    
    for ( String w : new WordIterator(txt) )
    {
        words.note(w);
    }
    
    println( "Words by frequency:" );
    println( word+": " + words.getCount(word) );
    
    for ( Entry<String, Integer> e : words.getAllByFrequency().subList(0, 10) )
    {
        println(e.getKey() + ": " + e.getValue());
    }
    
    println();
    
    println( "Most common words:" );
    // print most common used words that are not stop words
    for ( String e : words.getMostFrequent( 50 ) )
    {
        if ( !StopWords.English.isStopWord(e) )
            println(e);
    }
    
    println();
    
    // print count words in text
    println( "total words: " + words.getTotalItemCount() );
}
