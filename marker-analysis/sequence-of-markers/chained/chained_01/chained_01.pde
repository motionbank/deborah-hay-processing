/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Builds a graph view of the sequence of "scene" markers to
 *    give a sequential view on the performances.
 *
 *    Discussion:
 *    http://ws.motionbank.org/project/marker-chains
 *
 *    P2.0
 *    updated: fjenett 20130208
 */
 
import de.bezier.video.*;
import de.bezier.guido.*;
import de.bezier.data.sql.*; 
import org.piecemaker.models.*;
import de.bezier.guido.*;

import java.util.*;

ArrayList<Chain> chains;
HashMap<String,ChainNode> nodes;
ArrayList<ChainLink> links;
HashMap<Integer, ArrayList> ranks;

MySQL db;
ArrayList<Piece> pieces;
ArrayList<org.piecemaker.models.Event> events;

final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker";

void setup () {

    size( 1000, 1000 );
    
    Interactive.make(this);
    
    textFont( createFont( "Late-Regular", 8 ) );
    
    initDatabase();
    loadData();
    buildChains();
    
    println( chains.size() );
}

void draw ()
{
    background( 255 );
    
    strokeWeight( 1 );
    stroke( 220 );
    for ( Chain c : chains )
    {
        ChainNode cn = c.nodes.get(0);
        line( cn.x, 10, cn.x, cn.y );
        
        ChainNode cl = c.nodes.get(c.nodes.size()-1);
        line( cl.x, cl.y, cl.x, height-10 );
    }
    
    stroke( 0 );
    for ( ChainLink l : links )
    {
        l.draw();
    }
    
    for ( ChainNode n : nodes.values() )
    {
        n.draw();
    }
}

void mouseDragged ()
{
   float d = pmouseY - mouseY;
   for ( ChainNode n : nodes.values() ) 
   {
       if ( n.pressed ) return;
   }
   for ( ChainNode n : nodes.values() ) 
   {
       if ( n.y > mouseY )
       {
           n.y += d;
       }
   }
}
