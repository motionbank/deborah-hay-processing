
String getEventData( String attr, String rawJson )
{
    try {
        org.json.JSONObject json = new org.json.JSONObject( rawJson );
        return json.get(attr).toString();
    } catch ( Exception e ) {
    }
    return null;
}
