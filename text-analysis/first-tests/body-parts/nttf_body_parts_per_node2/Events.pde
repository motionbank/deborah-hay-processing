void keyPressed() {
  
  if ( key == 's' ) saveFrame( timestamp() + "body_parts_node.png" );

}
 
 String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}
