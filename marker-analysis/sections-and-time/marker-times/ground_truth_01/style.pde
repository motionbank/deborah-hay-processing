class Style
{
    PApplet papplet;
    String[] sysFontsCached;
    
    HashMap<String,Integer> values;
    HashMap<String,PFont> fonts;
    HashMap<String,PxStyle> styles;
    
    Style ( PApplet papplet )
    {
        this.papplet = papplet;
        defaults();
    }
    
    void defaults ()
    {
        values = new HashMap<String,Integer>();
        
        setColor( "background", 0x332211 );
        
        fonts = new HashMap<String,PFont>();
        
        styles = new HashMap<String,PxStyle>();
        store("default");
    }
    
    /* + + + + + + + + + + + + + + + + + + + + + +
     +
     +    specific getter / setters
     +
     + + + + + + + + + + + + + + + + + + + + + + */
     
    int getBackColor ()
    {
        return getColor( "background" );
    }
    
    int setColor( String k, int c )
    {
        values.put( "color."+k, c );
        return c;
    }
    
    int getColor ( String k )
    {
        return values.get( "color."+k );
    }
    
    PFont storeFont ( String k, PFont f )
    {
        fonts.put( k, f );
        return f;
    }
    
    PFont getFont ( String k )
    {
        return fonts.get( k );
    }
    
    PFont setFont ( String k )
    {
        PFont f = fonts.get( k );
        papplet.textFont( f );
        return f;
    }
    
    PFont setFont ( String k, String s )
    {
        PFont f = fonts.get( k );
        papplet.textFont( f );
        papplet.textSize( values.get( "typography.size."+s ) );
        return f;
    }
     
     String[] fontsLike ( String p )
     {
         java.util.regex.Pattern patt = Pattern.compile( ".*" + p.replaceAll("%",".*").toLowerCase() + ".*" );
         if ( sysFontsCached == null ) sysFontsCached = PFont.list();
         ArrayList<String> fontitates = new ArrayList<String>();
         for ( String s : sysFontsCached ) {
             if ( patt.matcher( s.toLowerCase() ).matches() ) {
                 fontitates.add( s );
             }
         }
         return (String[])( fontitates.toArray(new String[0]) );
     }
     
     void storeFontFamily ( String family, int s ) {
         storeFontFamily( family, new int[]{ s } );
     }
     
     void storeFontFamily ( String family, int[] sizes )
     {
         String[] cuts = fontsLike( family );
         for ( String c : cuts ) {
             for ( int s : sizes ) {
                 PFont f = papplet.createFont( c, s );
                 storeFont( c.replaceAll(" ","-") + "-" + s, f );
             }
         }
     }
     
     String[] storedFontNames () {
         return fonts.keySet().toArray(new String[0]);
     }
    
    /* + + + + + + + + + + + + + + + + + + + + + +
     +
     +    style swatches
     +
     + + + + + + + + + + + + + + + + + + + + + + */
     
     PStyle store ( String k )
     {
         PxStyle s = new PxStyle( papplet.g.getStyle() );
         styles.put( k, s );
         return s;
     }
     
     PStyle load ( String k )
     {
         PxStyle s = styles.get( k );
         if ( s == null ) {
             System.err.println(String.format( "Can't find saved style named \"%s\" ", k ));
         }
         else
         {
             papplet.g.style( s );
         }
         return s;
     }
     
     String[] storedStyleNames ()
     {
         return styles.keySet().toArray(new String[0]);
     }
    
    /* + + + + + + + + + + + + + + + + + + + + + + + + +
     +
     +    class PxStyle, a wrapper for PStyle
     +
     + + + + + + + + + + + + + + + + + + + + + + + + + */
    
    class PxStyle extends PStyle
    {
        PxStyle ( PStyle s )
        {
            Field[] fields = s.getClass().getDeclaredFields();
            for ( Field f : fields )
            {
                try {
                    f.set( this, f.get( s ) );
                } catch ( Exception e ) {
                    e.printStackTrace();
                }
            }
        }
        
        public String toString ()
        {
            String s = "PStyle <";
            Field[] fields = PStyle.class.getDeclaredFields();
            int i = 0;
            for ( Field f : fields )
            {
                try {
                    s += (i > 0 ? ", " : "") + f.getName() + ":" + f.get( this );
                } catch ( Exception e ) {
                    e.printStackTrace();
                }
                i++;
            }
            return s + ">";
        }
    }
}
