import org.piecemaker.api.*;
import de.bezier.guido.*;

/**
 *    
 */

boolean savePngs = false;
TitleCluster currentTitleCluster;

App app;

Object[] clusters, clusterEvents;
HashMap titleClusters; // events grouped by title

float normalizedMin = 0; // lowest normalized value
float normalizedKDEMax = -10000; // highest KDE value from normalized data for display

Object dateFrom, dateTo; // first, last event
String[] performers;
String currentPerformer;

int playhead = 0;
boolean playing, mode1 = true;

float PADDING = 20;

ArcBall arcController;
float globalScale = 100;

HashMap moBaColors, moBaColorsLow;
float moBaStrokeWeight = 1.5;
float moBaOpacity = 64;

void setup ()
{
    size( 970, 600, P2D );
    
    moBaColors = new HashMap();
    moBaColorsLow = new HashMap();
    
    moBaColors.put(    "roswarby", 0xFF1E8ED4 );
    moBaColorsLow.put( "roswarby", 0xFF254966 );
    
    moBaColors.put(    "jeaninedurning", 0xFFE04646 );
    moBaColorsLow.put( "jeaninedurning", 0xFF803B3B );
    
    moBaColors.put(    "juliettemapp", 0xFF349C00 );
    moBaColorsLow.put( "juliettemapp", 0xFF2B6100 );
    
    moBaColors.put(    "background", 0xFFEDEDED );
    moBaColors.put(    "stage",  0xFFCCCCCC );
    
    moBaColors.put(    "all", 0xFF666666 );
    moBaColorsLow.put( "all",  0xFF333333 );
    
    Interactive.make( this );
    InvisiController c = new InvisiController();
    Interactive.on( c, "scrolled", this, "scrollEvent" );
    
    arcController = new ArcBall( this );
    
    textFont( createFont( "Helvetica", 10 ) );
}

void draw ()
{
    background( moBaColors.get("background") );
    
    fill( 0 );
    if ( clusters == null )
        text( "Loading", width/2, height/2 );
    else if ( clusters.length == 0 )
        text( "No clusters selected", width/2, height/2 );
    else
    {
        if ( !savePngs ) text( clusters.length + " clusters", 5, 12 );
        //text( performers.join(", "), 5, 22 );
        
//        if ( mode1 ) {
            
            //stroke( 200 );
            //line( playhead + 20, height/2-110, playhead + 20, height/2+100 );
            
            //noStroke();
            //fill( moBaColors.get("stage") );
            //rect( PADDING, height/2-110, width-2*PADDING, 120 );
            
            Object[] playheadClusters = new Object[0];
            float[] valuesAtPlayhead = new float[0];
            float totalValuePlayhead = 0;
            
            Object[] tcs = titleClusters.values().toArray();
            
            for ( TitleCluster tc : tcs )
            {
                if ( tc.title == "end" ) continue;
                
                if ( !currentTitleCluster || currentTitleCluster != tc )
                    tc.drawNormalizedKDE( PADDING + 10, height/2, width-(2*PADDING + 2*10), 100 );
                
//                if ( playhead >= 0 && 
//                     playhead < tc.normalizedKDE.length && 
//                     tc.normalizedKDE[playhead] > 0 )
//                {
//                    valuesAtPlayhead.push( tc.normalizedKDE[playhead] );
//                    playheadClusters.push( tc );
//                    
//                    totalValuePlayhead += tc.normalizedKDE[playhead];
//                }
            }
            
            if ( currentTitleCluster ) 
            {
                currentTitleCluster.drawNormalizedKDE( PADDING + 10, height/2, width-(2*PADDING + 2*10), 100, true );
            }
            
    //        for ( int i = 0, k = valuesAtPlayhead.length; i < k; i++ )
    //        {
    //            float v = valuesAtPlayhead[i];
    //            v = v / totalValuePlayhead;
    //            
    //            pushMatrix();
    //            translate( 20 + i * 25, height - 20 );
    //            rotate( -HALF_PI );
    //            rect( 0, 0, v * 100, 20 );
    //            text( playheadClusters[i].title, 5, 5 );
    //            popMatrix();
    //        }
    
//            translate( min(max(playhead+20, 100), width-100), height-100 );
//            for ( int i = 0, k = valuesAtPlayhead.length; i < k; i++ )
//            {
//                float v = valuesAtPlayhead[i];
//                v = v / totalValuePlayhead;
//                v *= 100;
//                v *= v;
//                playheadClusters[i].bubble.radius = sqrt( v / PI );
//                for ( int n = 0; n < 100; n++ )
//                    playheadClusters[i].bubble.update( playheadClusters );
//                
//                stroke( playheadClusters[i].col );
//                playheadClusters[i].bubble.draw();
//            }
//            
//            if ( playing ) playhead++;
//            playhead %= width-40;

            if ( savePngs )
            {
                String sceneName = currentTitleCluster.title.trim().toLowerCase();
                sceneName = sceneName.replaceAll("[^-a-zA-Z0-9]+","-");
                sceneName = sceneName.replaceAll("-[-]+","-");
                sceneName = sceneName.replaceAll("^[-]+|[-]+$","");
                
                sceneName = currentPerformer + "_" + sceneName;
                
                app.saveFrame( sceneName );
                currentTitleCluster = tcs[ tcs.indexOf(currentTitleCluster) + 1 ];
                if ( !currentTitleCluster ) {
                    savePngs = false;
                }
            }

        
//        } else if ( clusters.length >= 2 ) {
//            
//            float pScale = 4;
//            int rotSteps = 12, pStep = 4;
//            
////            lights();
////            spotLight( 51, 102, 126, 0, -height, 0, -1, 0, 0, PI/2, 2 );
////            directionalLight( 126, 126, 126, 0, 0, -1 );
////            ambientLight( 102, 102, 102 );
//
//            arcController.apply();
//            
//            translate( width/2, height/2, -min(width/2, height/2) );
//            scale( globalScale / 100 );
//            
//            translate( pScale * -((width-40) / 2), 0, 0);
////            translate( pScale *  ((width-40) / 2), 0, 0);
////            rotateX( map( mouseY, 0, height, -PI, PI ) );
////            rotateY( map( mouseX, 0, width, -PI, PI ) );
////            translate( pScale * -((width-40) / 2), 0, 0);
//            
//            
//            Object[] tcs = titleClusters.values();
//            for ( Object tc : tcs )
//            {
//                fill( tc.col );            
//                stroke( tc.col );
//                noStroke();
//            
//                boolean started = false;
//                float[][] lastVertices = new float[0][3];
//                float[][] vertices = new float[0][3];
//                
//                for ( int p = 0; p < width-40; p+= pStep )
//                {
//                    vertices = new float[0][3];
//                    if ( tc.bubble.positions[p] == null ) 
//                    {
//                        if ( started )
//                        {
//                            // bottom
//                            beginShape( TRIANGLES );
//                            for ( int i = 1; i < lastVertices.length; i++ )
//                            {
//                                vertex( lastVertices[i-1][0], lastVertices[i-1][1], lastVertices[i-1][2] );
//                                vertex( lastVertices[i][0], tc.bubble.positions[p-pStep].y, tc.bubble.positions[p-pStep].x );
//                                vertex( lastVertices[i][0], lastVertices[i][1], lastVertices[i][2] );
//                            }
//                            endShape();
//                            break;
//                        }
//                        continue;
//                    }
//                    if ( !started ) 
//                    {
//                        // top
//                        float[] xyzLast;
//                        beginShape( TRIANGLES );
//                        for ( int i = 0, s = rotSteps; i <= s; i++ )
//                        {
//                            float a = radians( i * (360.0 / s) );
//                            float[] xyz = new float[]{
//                                p * pScale,
//                                tc.bubble.positions[p].y + cos( a ) * tc.bubble.diameters[p],
//                                tc.bubble.positions[p].x + sin( a ) * tc.bubble.diameters[p]
//                            };
//                            vertices.push( xyz );
//                            if ( i > 0 )
//                            {
//                                vertex( xyzLast[0], xyzLast[1], xyzLast[2] );
//                                vertex( xyzLast[0], tc.bubble.positions[p].y, tc.bubble.positions[p].x );
//                                vertex( xyz[0], xyz[1], xyz[2] );
//                            }
//                            xyzLast = xyz;
//                        }
//                        endShape();
//                    }
//                    else
//                    {
//                        beginShape( QUAD_STRIP );
//                        for ( int i = 0, s = rotSteps; i <= s; i++ )
//                        {
//                            float a = radians( i * (360.0 / s) );
//                            float[] xyz = new float[]{
//                                p * pScale,
//                                tc.bubble.positions[p].y + cos( a ) * tc.bubble.diameters[p],
//                                tc.bubble.positions[p].x + sin( a ) * tc.bubble.diameters[p]
//                            };
//                            vertices[i] = xyz;
//                            vertex( vertices[i][0],     vertices[i][1],     vertices[i][2] );
//                            vertex( lastVertices[i][0], lastVertices[i][1], lastVertices[i][2] );
//                        }
//                        endShape();
//                    }
//                    started = true;
//                    lastVertices = vertices;
//                }
//            }
//        }
    }
}

void setApp ( App a )
{
    app = a;
}

void resetClusters ( Object[] c, Object[] e ) // called from JS
{
    clusters = c;
    clusterEvents = e;
    
    buildTitleClusters();
}

void buildTitleClusters ()
{
    titleClusters = new HashMap();
    normalizedMin = 0;
    
    dateFrom = new Date();
    dateTo = new Date(-3600000); // classic 1970's
    performers = new String[0];
    
    currentPerformer = null;
    
    for ( int i = 0, k = clusterEvents.length; i < k; i++ )
    {
        Object[] events = clusterEvents[i];
        Object cluster = clusters[i];
        
        Object firstEventTs = null, 
               lastEventTs = events[events.length-1].finished_at.getTime();
        
        for ( Object event : events )
        {
            if ( event.title.equals( "curved path" ) ) {
                firstEventTs = event.happened_at.getTime();
                break;
            }
        }
        
        for ( Object event : events )
        {
            int eTime = event.happened_at.getTime();
            float v = map( eTime, firstEventTs, lastEventTs, 0, 1 );
            TitleCluster tc = titleClusters.get( event.title );
            if ( tc == null ) 
            {
                tc = new TitleCluster( event.title );
                titleClusters.put( event.title, tc );
            }
            tc.add( event, eTime - firstEventTs, v );
            
            normalizedMin = min( normalizedMin, v );
            
            if ( dateFrom > event.happened_at ) dateFrom = event.happened_at;
            if ( dateTo < event.finished_at ) dateTo = event.finished_at;
            if ( event.performers ) {
                tc.performer = event.performers[0];
                for ( int n = 0, l = event.performers.length; n < l; n++ ) {
                    if ( performers.indexOf(event.performers[n]) == -1 ) {
                        performers.push(event.performers[n]);
                    }
                }
            }
            
            if ( !currentPerformer )
            {
                currentPerformer = tc.performer;
            }
            else if ( tc.performer != currentPerformer )
            {
                currentPerformer = "all";
            }
        }
    }
    
    if ( !currentPerformer ) currentPerformer = "all";
    
    for ( TitleCluster tc : titleClusters.values() )
    {
        tc.updateNormalizedKDE( width-40 );
    }
    
    preCalcBubbles();
}

void preCalcBubbles ()
{
    for ( int p = 0; p < width-40; p++ ) 
    {
        Object[] playheadClusters = new Object[0];
        float[] valuesAtPlayhead = new float[0];
        float totalValuePlayhead = 0;
        
        Object[] tcs = titleClusters.values();
        for ( Object tc : tcs )
        {
            if ( p >= 0 && 
                 p < tc.normalizedKDE.length && 
                 tc.normalizedKDE[p] >= 1 )
            {
                valuesAtPlayhead.push( tc.normalizedKDE[p] );
                playheadClusters.push( tc );
                
                totalValuePlayhead += tc.normalizedKDE[p];
            }
        }
        
        for ( int i = 0, k = valuesAtPlayhead.length; i < k; i++ )
        {
            float v = valuesAtPlayhead[i];
            v = v / totalValuePlayhead;
            v *= 100;
            v *= v;
            playheadClusters[i].bubble.radius = sqrt( v / PI );
            for ( int n = 0; n < 500; n++ )
                playheadClusters[i].bubble.update( playheadClusters );
            playheadClusters[i].bubble.record( p );
        }
    }
}

