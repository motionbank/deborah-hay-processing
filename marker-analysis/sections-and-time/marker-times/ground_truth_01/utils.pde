public String esq ( Object s )
{
    return "\"" + s.toString() + "\"";
}

public void println ( Object ... args )
{
    println( join( str( args ), ", " ) );
}

public String[] str ( Object[] objs )
{
    String[] s = new String[objs.length];
    for ( int i = 0; i < s.length; i++ ) s[i] = objs[i] + "";
    return s;
}

public String[] str ( ArrayList lst )
{
    String[] s = new String[lst.size()];
    for ( int i = 0, l = lst.size(); i < l; i++ ) s[i] = lst.get(i) + "";
    return s;
}
