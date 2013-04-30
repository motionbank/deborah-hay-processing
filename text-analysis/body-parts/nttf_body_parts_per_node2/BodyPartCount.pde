class BodyPartCount
implements Comparable
{
    int count;
    float countRel;
    String part;
    int[] positions;

    BodyPartCount ( String p, int c )
    {
        part = p;
        count = c;
    }

    BodyPartCount ( String p, int c, int[] ps )
    {
        part = p;
        count = c;
        positions = ps;
        // countRel = c/float(parentTextLength);
    }

    // sort by earliest
    int compareTo ( Object o )
    {
        if ( o.getClass() != getClass() ) return 0;
        BodyPartCount other = (BodyPartCount)o;

        return other.positions[0] - positions[0];
    }

    // compare by count
    int compareToOff ( Object o )
    {
        if ( o.getClass() != getClass() ) return 0;
        BodyPartCount other = (BodyPartCount)o;

        return other.count - count;
    }

    // compare by similarity?
    int compareToOffToo ( Object o )
    {
        if ( o.getClass() != getClass() ) return 0;
        BodyPartCount other = (BodyPartCount)o;
        int d = 0;

        for ( int p : positions )
        {
            int opos = -1;
            int sd = 1000000000;
            for ( int pp : other.positions )
            {
                if ( abs(pp - p) < sd )
                {
                    sd = abs(pp - p);
                    opos = pp;
                }
            }
            d += opos - p;
        }

        return d;
    }
    
    public String toString ()
    {
        return "BodyPartCount { part: "+part+", count: "+count+" }";
    }
}

