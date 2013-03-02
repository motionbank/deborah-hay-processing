void setup ()
{
    size( 256, 256 );
    
    double radius = 256 / 2.0;
    
    int levels = 2;
    int segments = 4 + 8;
    
    double area = Math.PI * (radius * radius);
    double areaSegment = area / segments;
    
    double areaLevel1 = areaSegment * 4;
    double radiusLevel1 = Math.sqrt(areaLevel1 / Math.PI);
    
    double areaLevel2 = areaLevel1 + (areaSegment * 8);
    double radiusLevel2 = Math.sqrt(areaLevel2 / Math.PI);
    
    ellipse( width/2, height/2, (float)radiusLevel2 * 2, (float)radiusLevel2 * 2 );
    ellipse( width/2, height/2, (float)radiusLevel1 * 2, (float)radiusLevel1 * 2 );
}
