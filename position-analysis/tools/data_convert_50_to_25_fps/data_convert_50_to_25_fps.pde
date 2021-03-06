/**
 *    Motion Bank, http://motionbank.org/
 *
 *    Converting 50 fps data into 25 fps data for the netz
 *
 *    P2.0
 *    fjenett 20130212
 */
 
 String[] files;
 
 String rootFolder = "/Library/WebServer/Documents/motionbank.org/lab/dhay/data/";
 
 String statusMessage = "Scanning root directory";
 boolean doneAndQuit = false;
 
 void setup ()
 {
     size( 200, 200 );
     
     new Thread(){
         public void run ()
         {
             findFiles();
             convertFiles();
         }
     }.start();
 }
 
 void draw ()
 {
     background( 255 );
     
     fill( 0 );
     textAlign( CENTER );
     text( statusMessage, width/2, height/2+7 );
     
     if ( doneAndQuit ) exit();
 }
 
 void findFiles ()
 {
     ArrayList<String> collector = new ArrayList();
     
     File rootDir = new File( rootFolder );
     if ( !rootDir.exists() || !rootDir.isDirectory() ) die( "Root directory troubles" );
     
     for ( String folder : rootDir.list() )
     {
         if ( folder.indexOf(".") == 0 ) continue;
         File folderFile = new File( rootDir.getPath() + File.separator + folder);
         if ( !folderFile.isDirectory() ) continue;
         
         for ( String file : folderFile.list() )
         {
             if ( file.indexOf(".txt") != file.length()-4 ) continue;
             if ( file.indexOf("_25fps.txt") != -1 ) continue;
             
             collector.add( rootDir.getPath() + File.separator + folder + File.separator + file );
         }
     }
     
     files = collector.toArray(new String[0]);
 }
 
 void convertFiles ()
 {
     statusMessage = "Converting " + files.length + " files";
     
     int converted = 0;
     int line = 0;
     
     for ( String file : files )
     {
         line = 0;
         
         String[] lines = loadStrings( file );
         int dimension = lines[0].split(" ").length;
         
         println( file + " " + dimension );
         
         float[][] lessLines = new float[lines.length/2][dimension];
         
         for ( int i = 0; i < lessLines.length; i++ )
         {
             String[] point3D = split(lines[i*2], " ");
             lessLines[i] = new float[dimension];
             
             for ( int ii = 0; ii < dimension; ii++ )
             {
                 lessLines[i][ii] = float( point3D[ii] );
             }
         }
         
         if ( dimension == 2 )
             lessLines = fixZeroPoints2D( lessLines );
         else 
             lessLines = fixZeroPoints3D( lessLines );
         
         String[] lessLinesStr = new String[lessLines.length];
         
         for ( int i = 0; i < lessLines.length; i++ )
         {
             for ( int ii = 0; ii < dimension; ii++ )
             {
                 if ( ii > 0 ) lessLinesStr[i] += " ";
                 if ( lessLinesStr[i] == null ) lessLinesStr[i] = "";
                 lessLinesStr[i] += lessLines[i][ii];
             }
         }
         
         saveStrings( file.replace(".txt","_25fps.txt"), lessLinesStr );
         
         converted++;
         statusMessage = "Converted " + nf((float(converted)/files.length) * 100, 2, 0) + "% of " + files.length;
     }
     
     doneAndQuit = true;
 }
 
 void die ( String msg )
 {
     System.err.println( msg );
     exit();
 }
