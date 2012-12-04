package com.whitemagicsoftware.wordsplit;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * An almost generic class for generating all possible combinations of
 * values in a list as a list.
 */
@SuppressWarnings("unchecked")
public class Combinations {
  private Visitor visitor;
  private List<SegmentAnalysis> analysis = new ArrayList<SegmentAnalysis>();

  private final static int MAX_DEPTH = 22;

  /**
   * @param visitor - The class used to examine each possible text segment.
   */
  public Combinations( Visitor visitor ) {
    setVisitor( visitor );
  }

  /**
   * Entry point.
   *
   * @param initial - The list of possible words that could constitute the
   * solution.
   */
  public List<SegmentAnalysis> root( List initial ) {
    clearAnalysis();
    root( new ArrayList(), initial, 0 );
    return getAnalysis();
  }

  /**
   * Print all subsets of the remaining elements, with given prefix.
   */
  private void root( List prefix, List remain, int depth ) {
    if( remain.size() > 0 && depth < MAX_DEPTH ) {
      List combination = new ArrayList( prefix.size() + 1 );
      combination.addAll( prefix );
      combination.add( remain.get( 0 ) );

      addAnalysis( getVisitor().visit( combination ) );

      List r = new ArrayList( remain.size() );
      r.addAll( remain.subList( 1, remain.size() ) );

      root( combination, r, depth + 1 );
      root( prefix, r, depth + 1 );
    }
  }

  private void setVisitor( Visitor visitor ) {
    this.visitor = visitor;
  }

  private Visitor getVisitor() {
    return this.visitor;
  }

  private void clearAnalysis() {
    getAnalysis().clear();
  }

  private List<SegmentAnalysis> getAnalysis() {
    return this.analysis;
  }

  private void addAnalysis( SegmentAnalysis sa ) {
    getAnalysis().add( sa );
  }

  /**
   * Tests the class.
   */
  public static void main( String[] args ) {
    List<String> list = new ArrayList<String>();
    PrintVisitor pv = new PrintVisitor();

    list.add( "a" );
    list.add( "b" );
    list.add( "c" );
    list.add( "d" );

    Combinations combinations = new Combinations( pv );
    combinations.root( list );
  }
}
