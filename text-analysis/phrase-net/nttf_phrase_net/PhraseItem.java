 import java.util.Vector;
 
 public class PhraseItem
 implements Comparable
 {
     String item;
     Vector<PhraseConnection> connections;
     int treeWeight;
     
     PhraseItem ( String item )
     {
         this.item = item;
         connections = new Vector<PhraseConnection>();
         treeWeight = -1;
     }
     
     void addConnection ( PhraseConnection c )
     {
         if ( !connections.contains( c ) )
             connections.add( c );
     }
     
     int getConnectionCount ()
     {
         int i = 0;
         
         if ( connections == null ) return 0;
         
         for ( PhraseConnection c : connections )
         {
             i += c.count;
         }
         
         return i;
     }
     
     Vector<PhraseItem> getTreeItems ()
     {
         Vector<PhraseItem> treeItems = new Vector<PhraseItem>();
         
         treeItems.add( this );
         
         for ( PhraseConnection c : connections )
         {
             PhraseItem other = c.otherItem( this );
             treeItems.add( other );
             getTreeItemsDeep( treeItems, other, this );
         }
         
         return treeItems;
     }
     
     void getTreeItemsDeep ( Vector treeItems, PhraseItem item, PhraseItem parent )
     {
         for ( PhraseConnection c : item.connections )
         {
             PhraseItem other = c.otherItem( item );
             if ( other == parent ) continue;
             treeItems.add( other );
             getTreeItemsDeep( treeItems, other, item );
         }
     }
     
     int getTreeWeight ()
     {
         if ( treeWeight != -1 ) return treeWeight;
         
         Vector<PhraseItem> processed = new Vector<PhraseItem>();
         
         int i = 0;
         for ( PhraseConnection c : connections )
         {
             PhraseItem other = c.otherItem( this );
             i += c.count;
             i += getTreeWeightDeep( other, this, processed );
         }
         
         processed = null;
         
         treeWeight = i;
         
         return i;
     }
     
     int getTreeWeightDeep ( PhraseItem item, PhraseItem parent, Vector<PhraseItem> processed )
     {
         int i = 0;
         for ( PhraseConnection c : item.connections )
         {
             PhraseItem other = c.otherItem( item );
             if ( other == parent ) continue;
             if ( processed.contains( other ) ) continue;
             i += c.count;
             processed.add( other );
             i += getTreeWeightDeep( other, item, processed );
         }
         return i;
     }
     
     public String toString ()
     {
         String r = "";
         r = item + "\n";
         
         for ( PhraseConnection c : connections )
         {
             r += "-> " + c.connection + " ->\t";
             r += c.otherItem( this ).item + "\n";
         }
         
         return r;
     }
     
     public int compareTo ( Object o )
     {
         if ( o.getClass() != getClass() ) return 0;
         
         return item.toLowerCase().compareTo( ((PhraseItem)o).item.toLowerCase() );
     }
 }
