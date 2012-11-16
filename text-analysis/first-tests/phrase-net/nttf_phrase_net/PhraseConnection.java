
class PhraseConnection
implements Comparable
{
    String connection;
    PhraseItem from, to;
    int count;
    
    PhraseConnection ( String glue, PhraseItem a, PhraseItem b )
    {
        connection = glue;
        from = a;
        to = b;
        
        from.addConnection( this );
        to.addConnection( this );
        
        count = 1;
    }
    
    boolean connects ( PhraseItem item )
    {
        return from == item || to == item; // equals() ?
    }
    
    boolean equals ( PhraseItem a, PhraseItem b )
    {
        return from == a && to == b;
    }
    
    PhraseItem otherItem ( PhraseItem one )
    {
        if ( !connects( one ) ) return null;
        
        if ( one == from ) return to;
        return from;
    }
    
    public int compareTo ( Object o )
    {
        if ( o.getClass() != getClass() ) return 0;
        PhraseConnection other = (PhraseConnection)o;
        
        //return other.count - count;
        if ( from.equals( other.from ) ) return to.compareTo( other.to );
        return from.compareTo( other.from );
    }
}
