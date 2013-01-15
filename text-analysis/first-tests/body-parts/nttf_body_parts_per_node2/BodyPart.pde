class BodyPartList {
  
  BodyPart[] parts;
  
  BodyPartList(String[] _st) {
    
    this.parts = new BodyPart[_st.length];
    
    for (int i=0; i<_st.length; i++ ) {
      String part = _st[i];
      println("\t"+part);
      String[] sa = new String[0];
      String s = "";
      String p = "";
      
      if (part.indexOf(",") != -1) {
        sa = split(part, ",");
        s = sa[0];
        p = sa[1];
      }
      else {
        s = part;
        p = part;
      }
      //parts[i] = new BodyPart(porterStemWord(s),porterStemWord(p));
      parts[i] = new BodyPart(s,p);
    }
  }
  
  BodyPart get (int _i) {
    return parts[_i];
  }
  
  int length() {
    return parts.length;
  }
}


class BodyPart {
  
  String singular = "";
  String plural = "";
  
  BodyPart(String _s, String _p) {
    singular = _s;
    plural = _p;
  }
  
  boolean isPart ( String s ) {
    return s.equals(singular) || s.equals(plural);
   }
}
