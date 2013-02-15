
void keyPressed ()
{
    switch ( keyCode )
    {
        case RIGHT:
            currentSequenceIndex++;
            currentSequenceIndex %= sequences.size();
            currentSequence = sequences.get( currentSequenceIndex );
            redraw();
            break;
        case LEFT:
            currentSequenceIndex--;
            if ( currentSequenceIndex < 0 ) currentSequenceIndex = sequences.size()-1;
            currentSequence = sequences.get( currentSequenceIndex );
            redraw();
            break;
    }
    
    switch ( key )
    {
        case 'r':
            initAll();
            break;
        case 's':
            Interactive.setActive( slider2, true );
            break;
    }
}
