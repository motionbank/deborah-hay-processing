class GoogleDictRequest
{
    String server = "http://www.google.com/dictionary/json";
    HashMap<String, String> parameters;
    
    GoogleDictRequest()
    {
        parameters = new HashMap<String, String>();
        parameters.put( "callback", "_" );
        parameters.put( "sl", "en" );
        parameters.put( "tl", "en" );
        parameters.put( "restrict", "pr,de" );
        parameters.put( "client", "te" );
    }
    
    void put ( String name, String value )
    {
        parameters.put( name, value );
    }
    
    String get ( String name )
    {
        return parameters.get( name );
    }
    
    String toURL ()
    {
        String query = server + "?";
        boolean first = true;
        for ( Entry<String, String> m : parameters.entrySet() )
        {
            if ( !first ) query += "&";
            first = false;
            query += URLEncoder.encode(m.getKey()) + "=" + URLEncoder.encode(m.getValue());
        }
        return query;
    }
}
