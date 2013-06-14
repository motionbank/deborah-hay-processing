class Bubble
{
    PVector center;
    PVector target;
    float radius;
    
    PVector[] positions;
    float[] diameters;
    
    Bubble ( float r )
    {
        radius = r;
        center = new PVector( random(-5,5), random(-5,5) );
        target = new PVector( 0, 0 );
        
        positions = new PVector[0];
        diameters = new float[0];
    }
    
    void update ( TitleCluster others )
    {
        // move to center ..
        PVector d = PVector.sub( target, center );
        d.normalize();
        d.mult( 2 );
        PVector next = d.get();
        
        // repel from others
        for ( TitleCluster tc : others )
        {
            Bubble b = tc.bubble;
            
            if ( b == this ) continue;
            d = PVector.sub( center, b.center );
            float l = d.mag();
            if ( l < (radius+b.radius) )
            {
                if ( l < radius )
                    d.mult( 5 );
                next.add( d );
            }
        }
        
        next.normalize();
        //next.mult( 0.25 );
        center.add( next );
    }
    
    void record ( int i )
    {
        positions[i] = center.get();
        diameters[i] = radius * 2;
    }
    
    void draw ()
    {
        noFill();
        ellipse( center.x, center.y, radius*2, radius*2 );
    }
}

class TitleCluster
{
    float[] normalized, normalizedKDE;
    float normalizedYMax, normalizedXMax, normalizedMean;
    
    int[] absolute;
    float absoluteMean;
    
    String title;
    Object[] events;
    
    Bubble bubble;
    int col;
    
    String performer;
    
    TitleCluster ( String t )
    {
        title = t;
        
        bubble = new Bubble(1);
        
        colorMode( HSB );
        col = color( (titleClusters.size() * 20) % 255, 200, 170 );
        colorMode( RGB );
    }
    
    void add ( Object e, int a, float n )
    {
        if ( normalized == null ) normalized = new float[0];
        normalized.push( n );
        normalizedMean = 0;
        for ( float nn : normalized ) normalizedMean += nn;
        normalizedMean /= normalized.length;
        
        if ( absolute == null ) absolute = new int[0];
        absolute.push( a );
        absoluteMean = 0;
        for ( float aa : absolute ) absoluteMean += aa;
        absoluteMean /= absolute.length;
        
        if ( events == null ) events = new Object[0];
        events.push( e );
    }
    
    void drawMean ()
    {
        float xx = map( normalizedMean, normalizedMin, 1, 10, width-10 );
        pushMatrix();
        translate( xx, height/2 );
        noStroke();
        fill( 0 );
        ellipse( 0, 0, 5, 5 );
        rotate( -PI/4 );
        stroke( 0 );
        line( 0, 0, 8, 0 );
        text( title, 10, 0 );
        popMatrix();
    }
    
    // kernel density estimate of normalized with label at mean
    void updateNormalizedKDE ( float ww )
    {
        normalizedKDE = new float[ww];
        
        float bandWidth = 0.02;
        float bandWidth1 = 1 / bandWidth;
        float pisq = 1.0 / sqrt(TWO_PI);
        float zero = bandWidth1 * ( pisq * exp( 0 ) );
        
        normalizedYMax = -10000;
        normalizedXMax = 0;
    
        for ( int i = 0; i < ww; i++ )
        {
            float yi = 0;
            float v = 0;
            float xi = map( i, 0, ww, normalizedMin, 1 );
            for ( int n = 0, l = normalized.length; n < l; n++ )
            {
                v = (xi - normalized[n]) / bandWidth;
                v = v*v;
                yi += bandWidth1 * ( pisq * exp( -0.5 * v ) );
            }
            
//            if ( yi <= 1.001*zero )
//                yi = 0;
                
            normalizedKDE[i] = yi;
            
            if ( yi > normalizedYMax )
            {
                normalizedYMax = yi;
                normalizedXMax = i;
            }
            
            if ( yi > normalizedKDEMax ) normalizedKDEMax = yi;
        }
    }
    
    void drawNormalizedKDE ( float xx, float yy, float ww, float hh, boolean isCurrent )
    {
        float hh2 = hh - 7.5;
        
        strokeWeight( moBaStrokeWeight );
        fill( 0, 7 );
        int c = moBaColors.get( currentPerformer );
        
        if ( isCurrent )
        {
            strokeWeight( 2 * moBaStrokeWeight );
            fill( 0, 15 );
            c = moBaColorsLow.get( currentPerformer );
        }
        
        stroke( c );
        
        boolean isFirst = true;
        float xl = 0, yl = 0, thresh = 0.01;
        
        beginShape();
        float yFirst = 0, yi = 0;
        for ( int kxi = 0; kxi < ww; kxi++ )
        {
            yi = map( normalizedKDE[kxi], 0, normalizedKDEMax, 0, 1 );
            
            if ( isFirst )
            {
                yFirst = yi;
            }
            if ( yi > thresh )
            {
                if ( isFirst ) {
                    vertex( xx + kxi, yy + hh - (thresh * hh2) );
                    isFirst = false;
                }
                xl = xx + kxi;
                yl = yy + hh - (yi * hh2);
                vertex( xl, yl );
            }
        }
        if ( yFirst < yi ) vertex( xl, yy + hh - (yFirst * hh2) );
        endShape();
        
        pushMatrix();
        
        yi = map( normalizedYMax, 0, normalizedKDEMax, 0, 1 );

        translate( xx + normalizedXMax, yy + hh - (yi * hh2) );
        
        strokeWeight( moBaStrokeWeight );
        line( 0, -7.5, 0, 7.5 );
        
//        translate( 0, -15 );
//        rotate( -PI/4 );
//        fill( c );
//        text( title, 0, 0 );
        
        popMatrix();
    }
}


class InvisiController
{
    InvisiController () {
        Interactive.add( this );
    }
    
    void mouseScrolled ( int step )
    {
        Interactive.send( this, "scrolled", step );
    }
    
    void isInside ( int mx, int my )
    {
        return true;
    }
}
