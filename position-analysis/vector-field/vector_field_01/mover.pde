class Mover
{
    int maxPositions = 250;
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

        positions = new PVector[50];
    }

    void update ()
    {
        if ( isDone ) return;
        
        updates++;
        if ( updates > 20 )
        {
            PVector nPos = pos.get();
            for ( int i = 0; i < 2; i++ )
                nPos.add( vel );
                
            Mover t = new Mover( nPos.x, nPos.y );
            t.vel = vel.get();
            t.fillColor = fillColor + 25;
            t.update();
            movers.add( t );
            
            isDone = true;
            
            return;
        }

        pos.add( vel );

        if ( pos.x < 0 ) 
        {
            Mover t = new Mover( width, pos.y );
            t.vel = vel.get();
            t.fillColor = fillColor + 25;
            t.update();
            movers.add( t );
            
            isDone = true;
            pos.x = 0;
        }
        if ( pos.y < 0 ) 
        {
            Mover t = new Mover( pos.x, height );
            t.vel = vel.get();
            t.fillColor = fillColor + 25;
            t.update();
            movers.add( t );
            
            isDone = true;
            pos.y = 0;
        }
        if ( pos.x >= width ) 
        {
            Mover t = new Mover( 0, pos.y );
            t.vel = vel.get();
            t.fillColor = fillColor + 25;
            t.update();
            movers.add( t );
            
            isDone = true;
            pos.x = width;
        }
        if ( pos.y >= height ) 
        {
            Mover t = new Mover( pos.x, 0 );
            t.vel = vel.get();
            t.fillColor = fillColor + 25;
            t.update();
            movers.add( t );
            
            isDone = true;
            pos.y = height;
        }

        updatePositions();
    }

    void updatePositions()
    {
        for ( int i = positions.length-1; i >= 1; i-- )
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
        fill( fillColor );
        noStroke();
        ellipse( pos.x, pos.y, 2, 2 );

        noFill();
        stroke( fillColor );
        PVector l = positions[0];
        for ( int i = 1; i < positions.length; i++ )
        {
            PVector p = positions[i];
            if ( p == null ) continue;
            //stroke( map( i, 0, positions.length, 0, 255 ) );
            strokeWeight( map( i, 0, positions.length, 1.25, 0.1 ) );
            line( l.x, l.y, p.x, p.y );
            l = p;
        }
        strokeWeight( 1 );
    }
}

