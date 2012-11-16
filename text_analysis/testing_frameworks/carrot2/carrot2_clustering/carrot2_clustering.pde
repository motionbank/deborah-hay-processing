/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Clustering test using Carrot2 Java API.
 *    http://project.carrot2.org/
 *
 *    This uses a fake Carrot2 Processing library that should be included in the sketch folder.
 *
 *    P-2.0b6
 *    created: fjenett - 2011-01
 *    updated: fjenett 20121116
 */
 
import org.carrot2.clustering.lingo.LingoClusteringAlgorithm;
import org.carrot2.clustering.synthetic.ByUrlClusteringAlgorithm;
import org.carrot2.core.*;

void setup ()
{
    size( 200, 200 );
    
    performClusteringExample(); // included example from "carrot2-java-api-3.4.2.zip" download
    
    exit();
}

void performClusteringExample ()
{
    /* A few example documents, normally you would need at least 20 for reasonable clusters. */
    final String [][] data = new String [] []
    {
        {
        "http://en.wikipedia.org/wiki/Data_mining",
        "Data mining - Wikipedia, the free encyclopedia",
        "Article about knowledge-discovery in databases (KDD), the practice of automatically searching large stores of data for patterns."
        },
        
        {
        "http://www.ccsu.edu/datamining/resources.html",
        "CCSU - Data Mining",
        "A collection of Data Mining links edited by the Central Connecticut State University ... Graduate Certificate Program. Data Mining Resources. Resources. Groups ..."
        },
        
        {
        "http://www.kdnuggets.com/",
        "KDnuggets: Data Mining, Web Mining, and Knowledge Discovery",
        "Newsletter on the data mining and knowledge industries, offering information on data mining, knowledge discovery, text mining, and web mining software, courses, jobs, publications, and meetings."
        },
        
        {
        "http://en.wikipedia.org/wiki/Data-mining",
        "Data mining - Wikipedia, the free encyclopedia",
        "Data mining is considered a subfield within the Computer Science field of knowledge discovery. ... claim to perform \"data mining\" by automating the creation ..."
        },
        
        {
        "http://www.anderson.ucla.edu/faculty/jason.frand/teacher/technologies/palace/datamining.htm",
        "Data Mining: What is Data Mining?",
        "Outlines what knowledge discovery, the process of analyzing data from different perspectives and summarizing it into useful information, can do and how it works."
        },
    };
    
    /* Prepare Carrot2 documents */
    final ArrayList<Document> documents = new ArrayList<Document>();
    for (String [] row : data)
    {
        documents.add( new Document(row[1], row[2], row[0]) );
    }
    
    /* A controller to manage the processing pipeline. */
    final Controller controller = ControllerFactory.createSimple();
    
    /*
     * Perform clustering by topic using the Lingo algorithm. Lingo can 
     * take advantage of the original query, so we provide it along with the documents.
     */
    final ProcessingResult byTopicClusters = controller.process( documents, "data mining", LingoClusteringAlgorithm.class );
    final List<Cluster> clustersByTopic = byTopicClusters.getClusters();
    
    /* Perform clustering by domain. In this case query is not useful, hence it is null. */
    final ProcessingResult byDomainClusters = controller.process( documents, null, ByUrlClusteringAlgorithm.class );
    final List<Cluster> clustersByDomain = byDomainClusters.getClusters();
    
    //ConsoleFormatter.displayClusters(clustersByTopic);
    //ConsoleFormatter.displayClusters(clustersByDomain);
    
    for ( Cluster c : clustersByTopic )
    {
        println( c.getLabel() );
    }
    
    for ( Cluster c : clustersByDomain )
    {
        println( c.getLabel() );
    }
}
