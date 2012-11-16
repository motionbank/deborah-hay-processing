/*import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import opennlp.model.MaxentModel;
import opennlp.tools.sentdetect.SentenceModel;
import opennlp.tools.namefind.NameFinderME;
import opennlp.maxent.io.BinaryGISModelReader;
import opennlp.tools.sentdetect.SentenceDetectorME;
import opennlp.tools.tokenize.SimpleTokenizer;
import opennlp.tools.util.Span;

public class NamedEntityExtractor
{
    public static String[] NAME_TYPES = { "person", "organization", "location" 
        // , "date", "time", "percentage", "money"
    };
    public static NamedEntityType[] ENTITY_TYPES = { NamedEntityType.PERSON, NamedEntityType.ORGANIZATION, NamedEntityType.LOCATION,
        //NamedEntityType.DATE, NamedEntityType.TIME, NamedEntityType.PERCENTAGE, NamedEntityType.MONEY
    };

    NameFinderME[] finders = null;
    SentenceDetectorME englishSentenceDetector;

    public NamedEntityExtractor() throws IOException 
    {
        englishSentenceDetector = new SentenceDetectorME( (SentenceModel)loadTrainnedModel("EnglishSD.bin.gz") );
        finders = new NameFinderME[NAME_TYPES.length];
        for (int i = 0; i < finders.length; i++) {
            finders[i] = new NameFinderME( (MaxentModel)loadTrainnedModel( String.format( "%s.bin.gz", NAME_TYPES[i] ) ) );
        }
    }

    protected void findNamesInSentence ( List<NamedEntity> entities, String[] tokens, NameFinderME finder, NamedEntityType type)
    {
        Span[] nameSpans = finder.find(tokens);
        if (nameSpans == null || nameSpans.length == 0)
        return;
        for (Span span : nameSpans) {
            StringBuilder buf = new StringBuilder();
            for (int i = span.getStart(); i < span.getEnd(); i++) {
                buf.append(tokens[i]);
                if(i<span.getEnd()-1) buf.append(" ");
            }
            NamedEntity ne = new NamedEntity();
            ne.setType(type);
            ne.setEntityValue(buf.toString());
            entities.add(ne);
        }
    }

    public List<NamedEntity> findNamedEntities(String text) {
        List<NamedEntity> entities = new ArrayList<NamedEntity>();
        String[] sentences = englishSentenceDetector.sentDetect(text);
        opennlp.tools.tokenize.Tokenizer tokenizer = new SimpleTokenizer();
        for (String sentence : sentences) {
            String[] tokens = tokenizer.tokenize(sentence);
            for (int i=0; i<finders.length; i++) {
                findNamesInSentence(entities, tokens, finders[i], ENTITY_TYPES[i]);
            }
        }
        return entities;
    }

    protected Object loadTrainnedModel(String name) throws IOException
    {
        MaxentModel model = new BinaryGISModelReader(
            new File( getClass().getResource( String.format("/%s", name) ).getFile() ) 
        ).getModel();
        return model;
    }
}*/
