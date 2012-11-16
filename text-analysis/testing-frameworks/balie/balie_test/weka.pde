void testWekaLearner ()
{
    println("************************************************************");    
    println("* Weka Learner testing.                                    *");    
    println("* - test machine learning capabilities                     *");    
    println("************************************************************");
    WekaAttribute[] wekaAttr = new WekaAttribute[]{
            new WekaAttribute("Double1"),
            new WekaAttribute("Double2"),
            new WekaAttribute("Double3"),
            new WekaAttribute("Double4")
    };
    String[] strClass = new String[]{
        "Positive",
        "Negative"        
    };

    WekaLearner wl = new WekaLearner(wekaAttr, strClass);
    
    wl.AddTrainInstance(new Double[]{new Double(0.0),new Double(1.2),new Double(2.2),new Double(4.4)}, "Positive");
    wl.AddTrainInstance(new Double[]{new Double(1.0),new Double(1.0),new Double(7.7),new Double(1.9)}, "Negative");
    wl.AddTrainInstance(new Double[]{new Double(0.1),new Double(0.0),new Double(0.0),new Double(0.0)}, "Positive");
    wl.AddTrainInstance(new Double[]{new Double(1.1),new Double(1.1),new Double(1.1),new Double(1.1)}, "Positive");
    wl.AddTrainInstance(new Double[]{new Double(3.4),new Double(9.9),new Double(0.2),new Double(1.0)}, "Positive");
    wl.AddTrainInstance(new Double[]{new Double(1.5),new Double(0.1),new Double(7.0),new Double(0.0)}, "Negative");
    
    wl.CreateModel( new weka.classifiers.bayes.NaiveBayes() );

    wl.AddTestInstance(new Double[]{new Double(1.5),new Double(0.1),new Double(7.0),new Double(0.0)}, "Negative");
    wl.AddTestInstance(new Double[]{new Double(1.1),new Double(1.1),new Double(1.1),new Double(1.1)}, "Positive");
    
    println(wl.TestModel());
    
    double x = wl.Classify(new Double[]{new Double(3.4),new Double(1.0),new Double(9.9),new Double(0.0)});
    println(String.valueOf(x));
    
    WekaPersistance.Save(wl, "./WekaLearnerTest.sig");
    wl = WekaPersistance.Load("./WekaLearnerTest.sig");
    
    x = wl.Classify(new Double[]{new Double(3.4),new Double(1.0),new Double(9.9),new Double(0.0)});
    println(String.valueOf(x));

    println("[Success]");
}
