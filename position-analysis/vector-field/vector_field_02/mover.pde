class Mover
{
    final static int MAX_POSITIONS = 5000;
    PVector pos;
    PVector vel;
    
    int fillColor = 0;

    int updates = 0;
    int naned = 0;
    boolean isDone = false;

    PVector[] positions;

    Mover ( float x, float y )
    {
        pos = new PVector( x, y );
        vel = new PVector( 0, 0 );

        positions = new PVector[MAX_POSITIONS];
    }

    void update ()
    {
        if ( isDone ) return;
        
        updates++;
        if ( updates > MAX_POSITIONS )
        {
//            PVector nPos = pos.get();
//            for ( int i = 0; i < 2; i++ )
//                nPos.add( vel );
//                
//            Mover t = new Mover( nPos.x, nPos.y );
//            t.vel = vel.get();
//            t.fillColor = fillColor + 25;
//            t.update();
//            movers.add( t );
            
            isDone = true;
            return;
        }

        pos.add( vel );

        if ( pos.x < 0 ) 
        {
            isDone = true;
            pos.x = 0;
        }
        if ( pos.y < 0 ) 
        {
            isDone = true;
            pos.y = 0;
        }
        if ( pos.x >= width ) 
        {
            isDone = true;
            pos.x = width;
        }
        if ( pos.y >= height ) 
        {
            isDone = true;
            pos.y = height;
        }

        updatePositions();
    }

    void updatePositions()
    {
        for ( int i = MAX_POSITIONS-1; i >= 1; i-- )
        {
            positions[i] = positions[i-1];
        }
        positions[0] = pos.get();
    }

    void applyField ( PVector[] field, int fieldWidth, int fieldHeight )
    {
        int fieldX = (int)((pos.x / width) * (fieldWidth-1));
        int fieldY = (int)((pos.y / height) * (fieldHeight-1));
        int fieldI = fieldX + fieldY*fieldWidth;

        if ( field[fieldI].x == Float.NaN && field[fieldI].y == Float.NaN ) 
        {
            naned++;
            if ( naned > 10 ) movers.remove( this );
            return;
        }

        naned = 0;

        PVector p = field[fieldI].get();
        p.normalize();
        
        vel.add( p );
        vel.mult( 0.9 );
    }
    
    void draw ()
    {
        for ( int i = MAX_POSITIONS-1; i >= 1; i-- )
        {
            draw( i );
        }
    }

    void draw ( int i )
    {
        PVector l = positions[i-1];
        PVector p = positions[i];
        
        if ( l == null || p == null ) return;
        
        PVector s = PVector.sub(p,l);
        
        colorMode( HSB );
        float v = map( i, 0, updates, 1, 0.25 );
        stroke( map( s.heading(), -PI, PI, 0, 255 ), v*v*220, v*200 );
        colorMode( RGB );
        
        //strokeWeight( map( i, 0, updates, 0.1, 3 ) );
        float sMag = s.mag();
        strokeWeight( map( sMag*sMag, 0, 10, 0.2, 3 ) );
        
        line( l.x, height-l.y, p.x, height-p.y );
        
        strokeWeight( 1 );
    }
}

