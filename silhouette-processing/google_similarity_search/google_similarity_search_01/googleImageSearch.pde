
void googleImageSearchByUrl ( String imgUrl )
{
    // https://www.google.com/searchbyimage?
    // image_url=http%3A%2F%2Fflorianjenett.de%2Ffiles%2Fgimgs%2F12_dsc0051ret.jpg
    // &btnG=Suche
    // &image_content=
    // &filename=
    // &hl=de
    // &tbo=d
    // &bih=595
    // &biw=1627

    HttpClient client = getClient();

    GetMethod method = new GetMethod( "https://www.google.com/searchbyimage" );
    NameValuePair[] data = new NameValuePair[] {
        new NameValuePair("image_url", imgUrl), 
        //new NameValuePair("btnG", "Suche"),
        //new NameValuePair("image_content", ""),
        //new NameValuePair("filename", ""),
        //new NameValuePair("hl", "de"),
        new NameValuePair("tbo", "d"), 
        new NameValuePair("bih", "595"), 
        new NameValuePair("biw", "1627")
        };
        method.setQueryString( data );

    execAndHandle( client, method );
}

void googleImageSearchByImage ( File imgFile )
{
    HttpClient client = getClient();

    PostMethod method = new PostMethod( "https://www.google.de/searchbyimage/upload" );
    Part[] parts = null;
    try {
        parts = new Part[] {
            new FilePart( "encoded_image", imgFile, "image/png", null ), 
            new StringPart( "bih", "597" ), 
            new StringPart( "biw", "1627" )
            };
        } 
        catch ( Exception e ) {
        }
    method.setRequestEntity( new MultipartRequestEntity( parts, method.getParams() ) );

    execAndHandle( client, method );
}

HttpClient getClient ()
{
    HttpClient client = new HttpClient();
    client.getParams().setParameter(
    HttpMethodParams.USER_AGENT, 
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.95 Safari/537.11"
        );
    return client;
}

void execAndHandle ( HttpClient client, HttpMethodBase method )
{
    String response = null;
    //method.setFollowRedirects( true );
    try 
    {
        int status = client.executeMethod( method );
        switch ( status )
        {
        case HttpStatus.SC_OK:
            response = method.getResponseBodyAsString();
            break;
        case HttpStatus.SC_MOVED_PERMANENTLY:
        case HttpStatus.SC_MOVED_TEMPORARILY:
        case HttpStatus.SC_SEE_OTHER:
        case HttpStatus.SC_TEMPORARY_REDIRECT:
            Header locHeader = method.getResponseHeader("location");
            String locUrl = locHeader.getValue();
            HttpClient c = getClient();
            GetMethod m = new GetMethod( locUrl );
            execAndHandle( c, m );
            return;
        default:
            println("Method failed: " + method.getStatusLine());
        }
    } 
    catch ( IOException ioe ) 
    {
        ioe.printStackTrace();
    }
    finally
    {
        method.releaseConnection();
    }

    if ( response != null ) 
    {
        saveStrings("result.html", new String[] {
            response
        }
        );
        // imagebox_bigimages
        Document doc = Jsoup.parse( response );
        Elements anchorImgResults = doc.select("#imagebox_bigimages li a");
        //println( anchorImgResults );
        String[] resultsUrls = new String[0];
        for ( Element e : anchorImgResults )
        {
            String linkUrl = e.attr("href");
            String thumbUrl = e.child(0).attr("src"); // http://en.wikipedia.org/wiki/Data_URI_scheme
            String imgUrl = getUrlQueryParameter(linkUrl, "imgurl");
            resultsUrls = append( resultsUrls, imgUrl );
        }
        googleImageSearchResults = resultsUrls;
    }
}

String getUrlQueryParameter ( String url, String partName )
{
    String query = null;
    
    try {
        java.net.URI uri = new java.net.URI(url);
        query = uri.getQuery();
    } catch ( Exception e ) {
        e.printStackTrace();
    }
    String[] parts = split( query, "&" );
    for ( String p : parts )
    {
        String[] pair = split( p, "=" );
        if ( pair[0].equals( partName ) ) return pair[1];
    }
    return null;
}
