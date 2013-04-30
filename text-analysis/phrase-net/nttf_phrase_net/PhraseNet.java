import java.util.HashMap;
import java.util.Vector;
import java.util.Arrays;

public class PhraseNet
{
     // some common regex patterns
     final static String DIGIT         = "\\d+";
     final static String WORD          = "\\w{2,}";
     final static String WORD2         = "a[\\s]+\\w{2,}|an[\\s]+\\w{2,}|the[\\s]+\\w{2,}|"+
                                         "my[\\s]+\\w{2,}|his[\\s]+\\w{2,}|its[\\s]+\\w{2,}"+
                                         "her[\\s]+\\w{2,}|their[\\s]+\\w{2,}|"+
                                         WORD;
     final static String WHITESPACE    = "\\s+";
     
     // TODO: better tokenizer ..
     // someone's boat  -> someone, 's, boat
     // perceived speed -> perceive, ed, speed
         
     final static String ABOUT         = "[\\s]+about[\\s]+";
     final static String AND           = "[\\s]+and[\\s]+";
     final static String AT            = "[\\s]+at[\\s]+";
     final static String A             = "[\\s]+a[\\s]+";
     final static String ACROSS        = "[\\s]+across[\\s]+";
     final static String BY            = "[\\s]+by[\\s]+";
     final static String COMMA         = "[\\s]+,[\\s]+";
     final static String DOT           = "[\\s]+\\.[\\s]+";
     final static String ED            = "['e]d[\\s]+";
     final static String IN            = "[\\s]+in[\\s]+";
     final static String IS            = "[\\s]+is[\\s]+";
     final static String GENITIVE_CASE = "'s[\\s]+";
     final static String OR            = "[\\s]+or[\\s]+";
     final static String OF            = "[\\s]+of[\\s]+";
     final static String ON            = "[\\s]+on[\\s]+";
     final static String ONTO          = "[\\s]+onto[\\s]+";
     final static String OVER          = "[\\s]+over[\\s]+";
     final static String SPACE         = "[ ]+";
     final static String SLASH         = "[\\s]*/[\\s]*";
     final static String THE           = "[\\s]+the[\\s]+";
     final static String TO            = "[\\s]+to[\\s]+";
     final static String THAN          = "[\\s]+than[\\s]+";
     
     HashMap<String, PhraseItem> items;
     HashMap<String, Vector<PhraseConnection>> connections;
     
     boolean isDirectional = true;
     
     PhraseNet ()
     {
         items = new HashMap<String, PhraseItem>();
         connections = new HashMap<String, Vector<PhraseConnection>>();
     }
     
     void setIsDirectional ( boolean onOff )
     {
         isDirectional = onOff;
     }
     
     void add ( String from, String glue, String to )
     {
         if ( from == null || glue == null || to == null ) return;
         
         Vector<PhraseConnection> cons = connections.get( glue );
         
         if ( cons == null )
         {
             cons = new Vector<PhraseConnection>();
             connections.put( glue, cons );
         }
         
         PhraseItem piFrom = items.get( from );
         PhraseItem piTo   = items.get( to );
         
         if ( piFrom == null )
         {
             piFrom = new PhraseItem( from );
             items.put( from, piFrom );
         }
         
         if ( piTo == null )
         {
             piTo = new PhraseItem( to );
             items.put( to, piTo );
         }
         
         PhraseConnection con = null;
         for ( PhraseConnection c : cons )
         {
             if ( isDirectional )
             {
                 if ( c.equals( piFrom, piTo ) )
                 {
                     con = c;
                     con.count++;
                     break;
                 }
             }
             else
             {
                 if ( c.connects( piFrom ) && c.connects( piTo ) )
                 {
                     con = c;
                     con.count++;
                     break;
                 }
             }
         }
         
         if ( con == null )
         {
             con = new PhraseConnection( glue, piFrom, piTo );
             cons.add( con );
         }
     }
     
     public String toString ()
     {
         String r = "";
         
         if ( isDirectional )
         {
             for ( Vector<PhraseConnection> vec : connections.values() )
             {
                 PhraseConnection[] many = vec.toArray( new PhraseConnection[0] );
                 Arrays.sort( many );
                 
                 for ( PhraseConnection connection : many )
                 {
                     r += connection.from.item  + "\t-> ";
                     r += connection.connection + "\t-> ";
                     r += connection.to.item + "\t";
                     r += connection.count + "\n";
                 }
                 r += "\n";
             }
         }
         else
         {
             for ( PhraseItem item : items.values() )
             {
                 r += item;
             }
         }
         
         return r;
     }
}
