package com.whitemagicsoftware.wordsplit;

import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.IOException;

/**
 * Splits concatenated text into a sentence.
 */
@SuppressWarnings("unchecked")
public class Main {
  /**
   * Default constructor.
   */
  public Main() {
  }

	private static void out( String s ) {
		System.out.println( s );
	}

  /**
   * Main application. Takes a lexicon (with probabilities) and list of
   * concatenated strings. Writes the split strings to standard output.
   */
  public static void main( String args[] )
    throws IOException {
    TextSegmenter ts = new TextSegmenter();

    if( args.length == 2 ) {
      try {
        ts.split( new File( args[0] ), new File( args[1] ) );
      }
      catch( Exception e ) {
        System.err.println( "Error: " + e.getMessage() );
        e.printStackTrace();
      }
    }
    else {
      out( "com.whitemagicsoftware.wordsplit.Main <lexicon> <conjoined>" );
      out( "<lexicon>   - CSV file: word,probability" );
      out( "<conjoined> - Text file" );
    }
  }
}

