class Mover
{
    int maxPositions = 250;
    PVector pos;
    PVector vel;

    int updates = 0;
    int naned = 0;

    PVector[] positions;

    Mover ( float x, float y )
    {
        pos = new PVector( x, y );
        vel = new PVector( 0, 0 );

        positions = new PVector[50];
    }

    void update ()
    {
        updates++;
        if ( updates > 50 ) return;

        pos.add( vel );

        if ( pos.x < 0 ) 
        {
            pos.x = width;
            positions = new PVector[maxPositions];
        }
        if ( pos.y < 0 ) 
        {
            pos.y = height;
            positions = new PVector[maxPositions];
        }
        if ( pos.x > width ) 
        {
            pos.x = 0;
            positions = new PVector[maxPositions];
        }
        if ( pos.y > height ) 
        {
            pos.y = 0;
            positions = new PVector[maxPositions];
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

        vel.add( field[fieldI] );
        vel.mult( 0.9 );
    }

    void draw ()
    {
        fill( 0 );
        noStroke();
        ellipse( pos.x, pos.y, 2, 2 );

        noFill();
        stroke( 0 );
        PVector l = positions[0];
        for ( int i = 1; i < positions.length; i++ )
        {
            PVector p = positions[i];
            if ( p == null ) continue;
            //stroke( map( i, 0, positions.length, 0, 255 ) );
            strokeWeight( map( i, 0, positions.length, 1, 0.1 ) );
            line( l.x, l.y, p.x, p.y );
            l = p;
        }
        strokeWeight( 1 );
    }
}

