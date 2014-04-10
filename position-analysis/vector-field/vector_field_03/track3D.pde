class Track3D
{
    VideoTimeCluster cluster;
    org.piecemaker2.models.Event event;
    
    float[][] trackData;
    
    float trackSpeedMean;
    float trackSpeedHigh;
    float trackSpeedLow;
    float[] trackSpeed;
    
    float trackSpeedThresh; // anything faster than this value will be marked as "outlier" / "jump"
    
    float[] trackMin;
    float[] trackMax;
    
    Track3D ( VideoTimeCluster c, org.piecemaker2.models.Event e )
    {
        cluster = c;
        event = e;
    }
    
    void setData ( float[][] data )
    {
        trackData = data;
        
        trackSpeedMean = 0;
        trackSpeedHigh = -10000;
        trackSpeedLow = 10000;
        trackSpeed = new float[data.length];
        
        trackMin = new float[]{ 10000, 10000, 10000};
        trackMax = new float[]{-10000,-10000,-10000};
        
        for ( int i = 0, k = trackData.length-1; i < k; i++ ) 
         {
             trackMin[0] = min(trackMin[0], trackData[i][0]);
             trackMax[0] = max(trackMax[0], trackData[i][0]);
             
             trackMin[1] = min(trackMin[1], trackData[i][1]);
             trackMax[1] = max(trackMax[1], trackData[i][1]);
             
             trackMin[2] = min(trackMin[2], trackData[i][2]);
             trackMax[2] = max(trackMax[2], trackData[i][2]);
             
             trackSpeed[i] = dist( trackData[i][0],   trackData[i][1],   trackData[i][2],
                                   trackData[i+1][0], trackData[i+1][1], trackData[i+1][2] );
                
             trackSpeedMean += trackSpeed[i];
             trackSpeedHigh = max( trackSpeedHigh, trackSpeed[i] );
             trackSpeedLow = min( trackSpeedLow,  trackSpeed[i] );
         }
         
         trackSpeedMean = trackSpeedMean / trackData.length;
         trackSpeedThresh = 6 * trackSpeedMean;
    }
    
    void applyToVectorField ( PVector[] field, int[] fieldCounts, int fieldWidth, int fieldHeight )
    {
        PVector pos = new PVector( trackData[0][0], trackData[0][1] );
        PVector next = null;
        
        for ( int j = 1, k = trackData.length; j < k; j++ )
        {
            next = new PVector( trackData[j][0], trackData[j][1] );
            
            int fieldX = (int)map( trackData[j][0], trackMin[0], trackMax[0], 0, fieldWidth-1 );
            int fieldY = (int)map( trackData[j][1], trackMin[1], trackMax[1], 0, fieldHeight-1 );
            
            int fieldI = fieldX + fieldY * fieldWidth;
            
            field[fieldI].add( PVector.sub(next, pos) );
            fieldCounts[fieldI]++;
            
            pos = next;
        }
    }
}
