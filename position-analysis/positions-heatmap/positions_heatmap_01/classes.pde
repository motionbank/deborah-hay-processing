class VideoEventGroup
{
    Video video;
    org.piecemaker.models.Event[] events;
    SceneHeatMap[] heatMaps;
    SceneHeatMap groupHeatMap;
    
    VideoEventGroup ( Video v, org.piecemaker.models.Event[] es )
    {
        video = v;
        events = es;
        heatMaps = new SceneHeatMap[0];
    }
    
    void addHeatMap ( SceneHeatMap map )
    {
        heatMaps = (SceneHeatMap[])append( heatMaps, map );
    }
    
    void sortEvents ()
    {
        java.util.Arrays.sort(events, new java.util.Comparator(){
            public int compare ( Object a, Object b ) 
            {
                return ((org.piecemaker.models.Event)a).getHappenedAt().compareTo( ((org.piecemaker.models.Event)a).getHappenedAt() );
            }
        });
    }
    
    void generateGroupHeatMap () 
    {
        groupHeatMap = new SceneHeatMap( heatMapGrid, null );
        groupHeatMap.valueMax = -1;
        for ( SceneHeatMap h : heatMaps )
        {
           for ( int i = 0; i < h.values.length; i++ )
           {
               float v = h.values[i] / heatMaps.length;
               groupHeatMap.values[i] += v;
               groupHeatMap.valueMax = max(groupHeatMap.valueMax, v);
           } 
        }
    }
}

class SceneHeatMap
{
    int resolution = 14;
    
    float[] values;
    int originalValuesTotal = -1;
    float valueMax = -1;
    int valueMaxX = -1, valueMaxY = -1;
    
    org.piecemaker.models.Event scene;
    
    SceneHeatMap ( int res, org.piecemaker.models.Event s )
    {
        resolution = res;
        scene = s;
        values = new float[resolution*resolution];
    }
    
    void generate ( float[][] points )
    {
        // find extremata
        
        float[] pMins = new float[points[0].length];
        float[] pMaxs = new float[pMins.length];
        
        for ( int i = 0; i < pMins.length; i++ )
        {
            pMins[i] = Float.MAX_VALUE;
            pMaxs[i] = Float.MIN_VALUE;
        }
        
        for ( int i = 0; i < points.length; i++ )
        {
            for ( int ii = 0; ii < pMins.length; ii++ )
            {
                pMins[ii] = min( pMins[ii], points[i][ii] );
                pMaxs[ii] = max( pMaxs[ii], points[i][ii] );
            }
        }
        
        generate( points, pMins, pMaxs );
    }
    
    void generate ( float[][] points, float[] pMins, float[] pMaxs )
    {
        // count hits per cell
        int[] cells = new int[resolution*resolution];
        
        for ( int i = 0; i < points.length; i++ )
        {
            int xi = (int)map( points[i][0], pMins[0], pMaxs[0], 0, resolution-1 );
            int yi = (int)map( points[i][1], pMins[1], pMaxs[1], 0, resolution-1 );
            cells[xi + yi*resolution]++;
        }
        
        for ( int i = 0, l = points.length; i < cells.length; i++ )
        {
            values[i] = cells[i] / (float)l;
            if ( valueMax < values[i] )
            {
                valueMaxX = i % resolution;
                valueMaxY = i / resolution;
                valueMax = values[i];
            }
        }
        
        originalValuesTotal = points.length;
    }
    
    void draw ( int xx, int yy, int ww, int hh )
    {
        drawHeatMap( values, valueMax, resolution, xx, yy, ww, hh );
    }
}
