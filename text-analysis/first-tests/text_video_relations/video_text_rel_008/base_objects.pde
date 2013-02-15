class IntListObject {
  
  int[] value   = new int[0];
  float total   = 0;
  
  IntListObject() {
    
  }
  
  void add( int _v ) {
    this.value   = (int[]) append( this.value, _v );
    this.total  += _v;
  }
  
  int get( int _i ) {
    return (int) this.value[_i];
  }
  
  int length() {
    return value.length;
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
