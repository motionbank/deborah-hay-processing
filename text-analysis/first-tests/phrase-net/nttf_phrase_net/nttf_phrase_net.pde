/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Phrase Net test, see the Many Eyes.
 *    http://www-958.ibm.com/software/data/cognos/manyeyes/page/Phrase_Net.html
 *
 *    Note: uses 2010 version of NTTF
 *    
 *    P-2.0b6
 *    created: fjenett - 2011-01
 *    updated: fjenett 20121116
 */
 
 // TODO: check for multiple connections on different terms: 
 // move to stage, move on stage
 
 // TODO: resolve connection crossings, improve  auto-layout
 
 // BoxWrap2D
 // http://jbox2d.nfshost.com/processing/
 import org.jbox2d.p5.*;
 // JBox2D, comes with BoxWrap2D library ..?
 // http://www.jbox2d.org/
 import org.jbox2d.common.*;
 import org.jbox2d.collision.*;
 import org.jbox2d.dynamics.*;
 import org.jbox2d.dynamics.joints.*;
 import org.jbox2d.dynamics.contacts.*;
 
 Physics physics;
 PhraseNet net;
 
static String textFile = "NTTF_sequenced.txt";
 
 int maxConnections = -1; // set in phraseNetPhysics(), highest count found in all connections 
 int maxTreeWeight = -1; // set in phraseNetPhysics(), highest tree weight counted
 
 int treeWeightThresholdLow = 1;
 int treeWeightThresholdHigh = 1000; // set to maxTreeWeight later
 
 HashMap<String, Float> circleRadii;
 
 void setup ()
 {
     size( 1100, 800 );
     
     smooth();
     
     //println( PFont.list() );
     textFont( createFont( "Helvetica", 11 ) );
     
     // init phrase net
     net = new PhraseNet();
     
     buildPhraseNets();
     
     // init physics
     physics = new Physics(this, width, height);
     physics.setCustomRenderingMethod(this, "renderScene");
     physics.setDensity(0.1);
     physics.getWorld().setGravity(new Vec2(0,0));
     
     phraseNetPhysics();
 }
 
 void draw ()
 {
    //background( 255 );
     physics.getWorld().setGravity(new Vec2(cos(frameCount/120)*0.3,sin(frameCount/120)*0.3));
 }
 
 void renderScene ( World world )
 {
    background( 255 );
    
    Joint joint = world.getJointList();
    do {
        
        PhraseConnection connection = (PhraseConnection)joint.getUserData();
        if ( connection != null )
        {
            if ( connection.from.getTreeWeight() < treeWeightThresholdLow || connection.from.getTreeWeight() > treeWeightThresholdHigh  )
                 continue;
                 
            strokeWeight( 3 * connection.count );
        }
        
        Vec2 v1 = physics.worldToScreen( joint.getAnchor1() ), 
        v2 = physics.worldToScreen( joint.getAnchor2() );
        
        stroke( 0 );
        line( v1.x, v1.y, v2.x, v2.y );
        
        if ( joint.getClass() == DistanceJoint.class ) // the ones connecting nodes
        {
            float tWidth = textWidth( connection.connection );
            Vec2 c = v1.add( v2.sub( v1 ).mul( 0.5 ) );
            
            /*rectMode( CENTER );
            fill( 255 );
            noStroke();
            rect( c.x, c.y, tWidth+4, 14 );
            
            fill( 0 );
            text( connection.connection, c.x, c.y+4 );*/
            
            drawLabel( connection.connection, c.x, c.y, 255 );
            
            DistanceJoint dJoint = (DistanceJoint)joint;
            if ( dJoint.m_length < 7 )
            {
                dJoint.m_length += 0.01;
            }
        }
        
    } while ( (joint = joint.getNext()) != null ); // joints
    
    Body body = world.getBodyList();
    do // loop thru bodies
    {
        body.setXForm( body.getPosition(), 0 );
    
        PhraseItem item = (PhraseItem)body.getUserData();
        Shape shape = body.getShapeList();
        
        if ( shape != null  )
        {
            if ( item != null ) // a node
            {
                int itemWeight = item.getConnectionCount();
                int itemColor = int( map( itemWeight, 0, maxConnections, 240, 100 ) );
                
                Vec2 center = null;
                
                if ( shape.getType() == ShapeType.CIRCLE_SHAPE )
                {
                    CircleShape circle = (CircleShape) shape;
                
                    if ( item.getTreeWeight() < treeWeightThresholdLow || item.getTreeWeight() > treeWeightThresholdHigh ) {
                        circle.m_radius = 0.001;
                        continue;
                    }
                    
                    if ( circle.m_radius < circleRadii.get(item.item) )
                    {
                        circle.m_radius += 0.01;
                    }
                    
                    center = physics.worldToScreen( body.getWorldPoint( circle.getLocalPosition() ) );
                    
                    noFill();
                    stroke( 0 );
                    strokeWeight( 1 );
                    //ellipse( center.x, center.y, physics.worldToScreen( circle.m_radius*2 ), physics.worldToScreen( circle.m_radius*2 ) );
                }
                else
                {
                    if ( item.getTreeWeight() < treeWeightThresholdLow || item.getTreeWeight() > treeWeightThresholdHigh ) continue;
                    
                    PolygonShape poly = (PolygonShape)shape;
                    center = physics.worldToScreen( body.getWorldPoint( poly.m_centroid ) );
                    
                    noFill();
                    stroke( 0 );
                    strokeWeight( 1 );
                    /*beginShape();
                    for ( Vec2 p : poly.getVertices()  )
                    {
                        p = physics.worldToScreen( body.getWorldPoint( p ) );
                        vertex( p.x, p.y );
                    }
                    endShape( CLOSE );*/
                }
                
                drawLabel( item.item, center.x, center.y, itemColor );
            }
        }
        
    } while ( (body = body.getNext()) != null ); // bodies ..
 }
