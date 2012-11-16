/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Testing RiTa framework ...
 *    http://www.rednoise.org/rita/
 *
 *    Note: uses 2010 version of NTTF text
 *
 *    P-2.0b6
 *    updated: fjenett 20121116
 */

import rita.*;

int MAX_LINE_LENGTH = 60;

RiText rts[];
RiMarkov markov;

void setup()
{    
  size(380, 450);
  
  RiText.setDefaultAlignment(LEFT);

  // create a new markov model w' n=3
  markov = new RiMarkov( null, 3);  

  // load 2 files into the model
  markov.loadFile( dataPath("NTTF_sequenced.txt") );
}

void draw()
{
  background( 255 );
  fill( 0 );
  textAlign( CENTER );
  text( "Click and watch console", width/2, height/2 );
}

// generate on mouse click
void mouseClicked() 
{   
  RiText.deleteAll(); // clean-up old data

  String[] lines = markov.generateSentences(10);

  // Only works with Processing 1.5
  // lay out the return text starting at x=20 y=50)
  //rts = RiText.createLines( this, lines, 20, 50, MAX_LINE_LENGTH );
  
  println( lines );
}

