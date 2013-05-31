class IntListObject {
  
  ArrayList<Integer> value   = new ArrayList<Integer>();
  float total   = 0;
  
  IntListObject() {
    
  }
  
  void add( int _v ) {
    this.value.add(_v);
    this.total  += _v;
  }
  
  int get( int _i ) {
    return this.value.get(_i);
  }
  
  int length() {
    return value.size();
  }
  
  float average() {
    return this.total/float(this.value.size());
  }
}


class ConfigObject {
  
  boolean value = true;
  
  ConfigObject(boolean _v) {
    this.value = _v;
  }
  
  boolean isTrue() {
    return value;
  }
  
  void toggle() {
    this.value = !this.value;
  }
}
