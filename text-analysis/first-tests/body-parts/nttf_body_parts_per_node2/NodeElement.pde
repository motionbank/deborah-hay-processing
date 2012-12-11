class NodeElementList {

    NodeElementList() {
    }
}

class NodeElement {

    String text = "";
    String marker = "";
    int startIndex = 0;
    int endIndex = 0;
    int length = 0;
    int numBodyParts = 0;
    float numBodyPartsRel = 0.0f;

    Counter<String> words;
    BodyPartCount[] partList;


    NodeElement( String _marker, String _text, int _si) {

        this.marker = _marker;
        this.text = _text;
        this.startIndex = _si;
        this.length = _text.length();
        this.endIndex = _si + this.length;

        // count body parts
        this.words = new Counter<String>();

        for ( String w : new WordIterator(this.text) ) {
            this.words.note(w);
        }
        
        
        this.partList = countBodyParts( this.text );

        for ( BodyPartCount b : this.partList ) {
            println( b );
            numBodyParts += b.count;
        }

        numBodyPartsRel = numBodyParts / float(text.length());
        
        //Arrays.sort( partList );
    }
}

