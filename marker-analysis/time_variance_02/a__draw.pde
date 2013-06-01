void __draw () {   
    
    float gap = 2.0;
    float scaleW = 0.5;
    float minSegW = 3.0;
    
    float maxW = 0;
    for (int i=0; i<videos.length();i++) {
        VideoObject vid = videos.get(i);
        maxW = max(vid.data.duration, maxW);
    }

    background(colorBg);

    pushMatrix();
    translate(mainX,mainY);

    PerformerVideos vids = performers.get(performerIndex);
    
    colorLight = moBaColorsHigh.get(vids.name);
    colorDark = moBaColorsLow.get(vids.name);
    
    float absMax = 0;
    
    float x = 0.0;
    float y = gap;
    // height of each row
    float h0 = floor(mainH/vids.length()) - gap - (gap/vids.length());
    float off = 0.0;

    for (int i=0; i<vids.length(); i++) {
        
        
        int vidIdx = i;
        VideoObject vid = vids.get(vidIdx);
        
        // x position of active segment
        float ax = mainW/2.0 - map( (float)vid.segments.get(segIdx).start * vid.data.duration, 0, maxW, 0, mainW * scaleW );
        
        pushMatrix();
        
        translate(ax-segIdx*gap,0);
        
        for (int j=0; j<vid.segments.length()-1; j++) {

            VideoSegment vSeg = vid.segments.get(j);

            noStroke();
            fill(colorStage);
            if (idx == i) fill(colorLight);
            if (j==segIdx ) fill(colorLight,colorLightOpacity);
            if (j==segIdx && idx == i) fill(colorDark);
            
            float ww = map( (float)vSeg.duration * vid.data.duration, 0, maxW, 0, mainW * scaleW );
            if( ww<minSegW ) ww = minSegW;

            rect(x+gap, y, ww, h0);

            x += ww+gap;
            off += gap;
        }
        
        popMatrix();

        x = 0;
        y += h0 + gap;
        off = 0;
    }



    popMatrix();
}

