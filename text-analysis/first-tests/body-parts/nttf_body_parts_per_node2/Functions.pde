BodyPartCount[] countBodyParts( Counter<String> _words ) {
  
  BodyPartCount[] partList = new BodyPartCount[0];
  
  for ( String part : bodyParts )
    {
        int c = _words.getCount( part );
        if ( c > 0 )
        {
            int idx = -1;
            int[] positions = new int[0];
            while ( (idx = nttf.indexOf( part, idx+1 )) != -1 )
            {
                positions = append( positions, idx );
            }
            partList = (BodyPartCount[])append( partList, new BodyPartCount(part, c, positions) );
        }
    }
    return partList;
}
