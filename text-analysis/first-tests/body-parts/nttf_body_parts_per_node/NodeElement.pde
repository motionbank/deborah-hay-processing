class NodeElement {
  
  String text = "";
  String marker = "";
  int startIndex = 0;
  int endIndex = 0;
  int length = 0;
  
  NodeElement( String _marker, String _text, int _si) {
    this.marker = _marker;
    this.text = _text;
    this.startIndex = _si;
    this.length = _text.length();
    this.endIndex = _si + this.length;
  }
}
