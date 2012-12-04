package com.whitemagicsoftware.wordsplit;

import java.util.List;
import java.util.Map;

/**
 * Stores the details about a possible solution to a concatenated phrase.
 * These details allow the TextSegmenter class to determine whether or not
 * the solution is the most likely.
 */
@SuppressWarnings("unchecked")
public class SegmentAnalysis {
  private int wordsUsed;
  private List<Map.Entry> words;
  private String remaining;

  public SegmentAnalysis( List<Map.Entry> words ) {
    setWords( words );
  }

  /**
   * Splits the given word (concatenated text) into multiple words, with
   * spaces to separate each word.
   *
   * @param concat - The words to split.
   * @return The given parameter with spaces in between each word.
   */
  public StringBuilder apply( String concat ) {
    for( Map.Entry entry : getWords() ) {
      String word = (String)(entry.getKey());
      concat = concat.replaceFirst( word, " " + word + " " );
    }

    return new StringBuilder( normalise( concat ) );
  }

  public boolean matchedAllWords() {
    return getWordCount() == getWordsUsed();
  }

  public int length() {
    return getRemaining().length();
  }

  /**
   * Removes multiple spaces from inside a string, as well as trimming white
   * space from both ends of the string.
   *
   * @return The value of s with its whitespace normalised.
   */
  private String normalise( String s ) {
    return s.replaceAll( "\\b\\s{2,}\\b", " " ).trim();
  }

  public void setRemaining( String remaining ) {
    this.remaining = normalise( remaining );
  }

  private String getRemaining() {
    return this.remaining;
  }

  private double getWordCount() {
    return getWords().size();
  }

  public void setWordsUsed( int wordsUsed ) {
    this.wordsUsed = wordsUsed;
  }

  private double getWordsUsed() {
    return this.wordsUsed;
  }

  /**
   * Returns the product of the probability of each word in this potential
   * solution.
   *
   * @return A number between 0 and 1.
   */
  public double getProbability() {
    double probability = 1;

    for( Map.Entry entry : getWords() ) {
      probability *= ((Double)(entry.getValue())).doubleValue();
    }

    return probability * (getWordsUsed() / getWordCount());
  }

  private void setWords( List<Map.Entry> words ) {
    this.words = words;
  }

  private List<Map.Entry> getWords() {
    return this.words;
  }
}
