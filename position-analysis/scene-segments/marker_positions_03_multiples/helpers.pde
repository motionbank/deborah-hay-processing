
static void loadSettings ( String basePath )
{
    // load file ..
    File settingsFile = new File( basePath + "/material/settings.json" );
    if ( settingsFile.exists() ) 
    {
        String settingsContents = null;
        java.io.BufferedReader br = null;
        try {
            br = new java.io.BufferedReader( new java.io.FileReader( settingsFile ) );
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();
            while (line != null) {
                sb.append(line);
                sb.append("\n");
                line = br.readLine();
            }
            settingsContents = sb.toString();
            br.close();
        } catch ( Exception e ) {
            e.printStackTrace();
        }
        org.json.JSONObject settingsJson = null;
        try {
            settingsJson = new org.json.JSONObject( settingsContents );
        } catch ( Exception e ) {
            e.printStackTrace();
        }
    } else {
        System.err.println( "Unable to load settings .. exiting." );
        System.exit(0);
    }
}

String getEventData( String attr, String rawJson )
{
    try {
        org.json.JSONObject json = new org.json.JSONObject( rawJson );
        return json.get(attr).toString();
    } catch ( Exception e ) {
    }
    return null;
}
