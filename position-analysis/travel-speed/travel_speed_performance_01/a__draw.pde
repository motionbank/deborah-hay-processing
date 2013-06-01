void __draw () {    
    
    float maxW = 0;
    for (int i=0; i<videos.length();i++) {
        VideoObject vid = videos.get(i);
        maxW = max(vid.data.speeds.length(), maxW);
    }

    background(colorBg);

    pushMatrix();
    translate(mainX,mainY);

    PerformerVideos vids = performers.get(performerIndex);
    
    colorLight = moBaColorsHigh.get(vids.name);
    colorDark = moBaColorsLow.get(vids.name);
    
    float absMax = 0;

        float off = (mainH + distY) / 2;

        VideoObject vid = vids.get(idx);

        SpeedData speeds = vid.data.speeds;

        int currentWidth = floor(mainW*(vid.data.speeds.length()/maxW));

        float[] speeds2 = new float[currentWidth];

        float sx = currentWidth / (float)speeds.length();
        float sy = mainH / (maxSpeed - minSpeed);
        for ( int x = 0; x < speeds.length(); x++ )
        {
            float ll = (speeds.get(x) - minSpeed)*sy;
            speeds2[(int)(x*sx)] += ll;
        }

        for ( int x = 0; x < speeds2.length; x++ )
        {
            speeds2[x] = (speeds2[x]/speeds.length()) * 10;
        }
        
        for ( int t = 0; t < 5; t++ )
            speeds2 = convolve1D( speeds2, gaussKernel );

        //###################################################### graph bg
        
        noStroke();
        fill( colorStage );
        
        rect(0, off, mainW, -(mainH-6*distY)/7);
        
        //###################################################### base line
        
        strokeWeight( strokeWeight );
        stroke( 0 );
        line( 0, off + strokeWeight/2, mainW, off + strokeWeight/2 );
        
        //###################################################### middle
        
        float[] speeds3 = new float[speeds2.length];
        arrayCopy(speeds2,speeds3);
        
        speeds3 = sort(speeds3);

        float yy = speeds3[floor(speeds3.length/2)] * scale;
        
        stroke( colorLight );
        line( 0, off-yy, mainW, off-yy );
        
        float tMax = max(speeds2);
        absMax = max(tMax, absMax);

        //###################################################### max lines

        stroke( colorLight );
        line( 0, off-absMax*scale, mainW, off-absMax*scale );
        
        //###################################################### scene highlight

        VideoSegment seg = vid.segments.get(segIdx);
        
        int st = floor(seg.start*speeds2.length);
        int end = st + floor(seg.duration*speeds2.length);
        
        fill( 0, 10 );
        noStroke();
        rect( st, off, end-st, -(mainH-6*distY)/7 );

        fill( colorLight, colorLightOpacity );
        noStroke();
        
        beginShape();
        
        vertex(st, off);
        
        for ( int x = st; x < end; x++ )
        {
            vertex( x, off - speeds2[x]* scale);
        }
        
        vertex(end, off);
        
        endShape(CLOSE);
        
        //###################################################### main graph
        
        beginShape();

        stroke( colorDark );
        strokeWeight( strokeWeight * 2 );
        noFill();

        for ( int x = 0; x < speeds2.length; x++ )
        {
            vertex( x, off - speeds2[x]* scale );
        }

        endShape();

    popMatrix();
}

