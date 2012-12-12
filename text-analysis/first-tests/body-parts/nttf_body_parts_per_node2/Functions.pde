
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


String[] porterStemWordList ( String[] _words ) {
  
  String[] tmp = new String[_words.length];
  
  for (int i=0; i<tmp.length; i++) {
    tmp[i] = porterStemWord(_words[i]);
  }
  
  return tmp;
}



String porterStemWord ( String word )
{
    char[] w = new char[501];
    StringReader in = new StringReader( word );
    try 
    {
        int ch = in.read();
        Stemmer s = new Stemmer();

        if (Character.isLetter((char) ch))
        {
            int j = 0;
            while (true)
            {  
                ch = Character.toLowerCase((char) ch);
                w[j] = (char) ch;
                if (j < 500) j++;
                ch = in.read();
                if (!Character.isLetter((char) ch))
                {
                    for (int c = 0; c < j; c++) s.add(w[c]);

                    s.stem();
                    String u;

                    u = s.toString();
                    return u;
                }
            }
        }
        if (ch < 0) {
            return null;
        }
        //System.out.print((char)ch);
    } 
    catch ( Exception e ) {
        e.printStackTrace();
    }
    return null;
}

