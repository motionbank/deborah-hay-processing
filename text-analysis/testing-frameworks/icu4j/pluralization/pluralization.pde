import com.ibm.icu.text.MessageFormat;

import java.util.Locale;
import java.util.ResourceBundle;

int[] NUMBERS = new int[] {
  0, 1, 2, 5, 11, 22, 39
};

void setup() {
  noLoop();
  printLocalisedMessages("plural", Locale.ENGLISH, new Locale("pl"));

}


void draw() {
}

void printLocalisedMessages(String key, Locale... locales) {
  for (Locale locale : locales) {
    System.out.println(locale.getDisplayLanguage() + ":");
    printLocalisedMessage(key, locale);
  }
}


void printLocalisedMessage(String key, Locale locale) {
  ResourceBundle bundle = ResourceBundle.getBundle("icu", locale);
  String pattern = bundle.getString(key);
  MessageFormat msgFormat = new MessageFormat(pattern, locale);

  for (int i : NUMBERS) {
    System.out.println(msgFormat.format(new Object[] {
      i
    }
    ));
  }

  System.out.println();
}



