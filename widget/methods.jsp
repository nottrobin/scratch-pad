<%!
// Remove all XML escapable characters from code
String toXMLString(String theString) {
    theString = theString.replace("&","&amp;");
    theString = theString.replace("<","&lt;");
    theString = theString.replace(">","&gt;");
    theString = theString.replace("'","&apos;");
    theString = theString.replace("\"","&quot;");
    return theString;
}
// Remove all XML escapable characters from code
String toJSString(String theString) {
    theString = theString.replace("\n","\\n");
    theString = theString.replace("\"","\\\"");
    return theString;
}
%>