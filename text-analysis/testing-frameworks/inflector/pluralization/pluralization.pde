RuleBasedPluralizer plur;

void setup() {
  noLoop();
  plur = new RuleBasedPluralizer();
  plur.setLocale(Locale.ENGLISH);

  println(plur.pluralize("hand"));
}

void draw()  {
  
}


