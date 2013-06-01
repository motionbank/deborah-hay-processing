void __draw () {    

    float maxW = 0;
    for (int i=0; i<videos.length();i++) {
        VideoObject vid = videos.get(i);
        maxW = max(vid.data.speeds.length(), maxW);
    }

    background(colorBg);

    pushMatrix();
    translate(mainX, mainY);

    for (int k=0; k<performers.length(); k++) {

        pushMatrix();

        translate((graphWidth+distX)*k, 0);

        PerformerVideos vids = performers.get(k);

        colorLight = moBaColorsHigh.get(vids.name);
        colorDark = moBaColorsLow.get(vids.name);

        float absMax = 0;

        for (int i=0; i<vids.length(); i++) 
        {
            int vidIdx = i;

            float off = ( (mainH - 6*distY) /float(vids.length())) * (i+1) + i*distY;

            VideoObject vid = vids.get(vidIdx);

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
            
            for ( int t = 0; t < 5; t++ ) speeds2 = convolve1D( speeds2, gaussKernel );

            //###################################################### graph bg

            noStroke();
            fill(colorStage);

            rect(0, off, graphWidth, -(mainH-6*distY)/7);
            
            //###################################################### base line
            
            strokeWeight( strokeWeight );
            stroke( 0 );
            line( 0, off + strokeWeight/2, graphWidth, off + strokeWeight/2 );

            //###################################################### middle
            
            float[] speeds3 = new float[speeds2.length];
            arrayCopy(speeds2, speeds3);

            speeds3 = sort(speeds3);

            float yy = speeds3[floor(speeds3.length/2)] * scale;

            stroke( colorLight, colorLightOpacity );
            
            if ( idx == vidIdx && performerIndex == k ) 
            {
                stroke( colorLight );
            }
            
            line( 0, off-yy, graphWidth, off-yy );


            //###################################################### scene highlight

            VideoSegment seg = vid.segments.get(segIdx);
            
            if ( idx == vidIdx && performerIndex == k ) 
            {
                fill( colorDark, colorLightOpacity );
            }

            int st = floor(seg.start*speeds2.length);
            int end = st + floor(seg.duration*speeds2.length);
            
            fill( 0, 5 );
            if ( idx == vidIdx && performerIndex == k ) 
            {
                fill( 0, 10 );
            }
            
            noStroke();
            rect( 0, off, end-st, -(mainH-6*distY)/7 );

            fill( colorLight, colorLightOpacity );
            noStroke();

            beginShape();
            
            vertex( 0, off );

            for ( int x = 0; x < end-st; x++ )
            {
                vertex( x, off - speeds2[x+st]* scale);
            }
            
            vertex( end-st, off );
            
            endShape(CLOSE);


            //###################################################### main graph
            
            beginShape();

            stroke( colorLight ); // colorLightOpacity
            strokeWeight( strokeWeight );
            noFill();

            if (idx == vidIdx && performerIndex == k) 
            {
                stroke(colorDark);
                strokeWeight( strokeWeight * 2 );
            }

            for ( int x = 0; x < end-st; x++ )
            {
                vertex( x, off - speeds2[x+st]* scale);
            }

            endShape();

            // keep for max line below

            float tMax = max(speeds2);
            absMax = max(tMax, absMax);
        }

        //###################################################### max lines
        
        for ( int i=0; i < vids.length(); i++ ) {

            float off = ( (mainH - 6*distY) /float(vids.length())) * (i+1) + i*distY;
            
            strokeWeight( strokeWeight );
            stroke(colorLight, colorLightOpacity);
            
            if ( idx == i && performerIndex == k ) 
            {
                stroke( colorLight );
            }
            
            line( 0, off-absMax*scale, graphWidth, off-absMax*scale );
        }

        popMatrix();
    }

    popMatrix();
}

