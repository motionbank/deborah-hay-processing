package com.whitemagicsoftware.wordsplit;

import java.util.List;
import java.util.Map;

/**
 * Called by the Combinations class when a new combination of words has been
 * defined (recursively). This class gathers statistics about the list of
 * words that are a possible contender for being the solution.
 */
@SuppressWarnings("unchecked")
public class SegmentVisitor implements Visitor {
  private String concat;
  private SegmentAnalysis analysis;

  /**
   * @param concat - The concatenated string that was analysed.
   */
  public SegmentVisitor( String concat ) {
    setConcatenated( concat );
  }

  /**
   * Determines the following statistics with respect to the list.
   * <ul>
   * <li>The number of words used in the list versus in the string.</li>
   * <li>The popularity of proposed solution words.</li>
   * <li>The number of remaining characters (and words) after removing the
   * word list from the concatenated string.</li>
   * </ul>
   *
   * @param list - The list of words to examine.
   */
  public SegmentAnalysis visit( List list ) {
    String result = getConcatenated().toString();
    int wordsUsed = 0;

    for( Object o : list ) {
      String word = (String)(((Map.Entry)o).getKey());

      if( result.indexOf( word ) >= 0 ) {
        wordsUsed++;
        result = result.replaceFirst( word, " " );
      }
    }

    SegmentAnalysis analysis = new SegmentAnalysis( list );

    analysis.setWordsUsed( wordsUsed );
    analysis.setRemaining( result );

    return analysis;
  }

  private void setConcatenated( String concat ) {
    this.concat = concat;
  }

  private String getConcatenated() {
    return this.concat;
  }
}

