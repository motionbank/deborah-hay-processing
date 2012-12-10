
BodyPartCount[] countBodyParts( String _text ) 
{
    BodyPartCount[] _partList = new BodyPartCount[0];
    

    Counter<String> _words = new Counter<String>();

    for ( String w : new WordIterator(_text) ) {
        _words.note(w);
    }
    

    for ( String part : bodyParts )
    {
        int c = _words.getCount( part );
        if ( c > 0 )
        {
            int idx = 0;
            int[] positions = new int[0];
            
            
            for (String word : new WordIterator(_text)) {
              if (part.equals(word)) {
                positions = append( positions, idx );
                println(idx);
              }
              idx += 1;
            }
            
            /*
            while ( (idx = nttf.indexOf( part, idx+1 )) != -1 )
            {
                println(idx);
                positions = append( positions, idx );
            }
            */
            _partList = (BodyPartCount[])append( _partList, new BodyPartCount(part, c, positions) );
        }
    }
    return _partList;
}

