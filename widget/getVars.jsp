<%@ include file="connection.jsp" %>
<%
// Retrieve all information about the widget
// Config
String siteURL = "http://localhost:8080/"; // The url of your site including the trailing "/". E.g.: http://www.server.com/
String rssURL = siteURL + "widget/rss.jsp"; // The url of your site including the trailing "/". E.g.: http://www.server.com/
String styleSheetURL = siteURL + "widget/widget.css"; // The url of the CSS stylesheet to be loaded into the page - MUST be a full URL (http://<server>/<location>.css)
String imagesURL = siteURL + "widget/images/ad#.jpg"; // The generic format for all images URLs, # will be replaced by the ID of the item
                                  // E.g.: 'http://myurl/images/img#.jgp' will generate 'http://myurl/images/img1.jgp', 'http://myurl/images/img2.jgp'.. etc.
String imagesWidth = "60"; // The width of all the images
String imagesHeight = "60"; // height of all the images
String divID = "scrollWidget"; // The ID that the element will have in the user's page - all other IDs and classes will be computed from this value too

// Variables to store information
List<Map> ads = new ArrayList<Map>();
Map<String, String> channelInfo = new HashMap<String, String>();
try {
  // Get the header and footer info from database table "headfoot"
  ResultSet headfootRS = con.createStatement().executeQuery("select headerId,footer,header FROM headfoot");
  if(headfootRS.next()) {
      channelInfo.put("headerText",headfootRS.getString("header"));
      channelInfo.put("footerText",headfootRS.getString("footer"));
      channelInfo.put("siteURL",siteURL);
      channelInfo.put("rssURL",rssURL);
      channelInfo.put("styleSheetURL",styleSheetURL);
      channelInfo.put("imagesWidth",imagesWidth);
      channelInfo.put("imagesHeight",imagesHeight);
      channelInfo.put("divID",divID);
  }
  
  // Get all rows of advertisments' information from database table "headline"
  ResultSet headlineRS = con.createStatement().executeQuery("select headlineId,headLine,byLine,picture,urlHeadLine FROM headline where status=1");
  
  // Add data to an array
  // Add data for each row
  while(headlineRS.next()) {
      Map<String, String> ad = new HashMap<String, String>();
      ad.put("id",headlineRS.getString("headlineId"));
      ad.put("heading",headlineRS.getString("headLine"));
      ad.put("by",headlineRS.getString("byLine"));
      if(headlineRS.getString("picture").compareTo("1") == 0) {ad.put("picture",imagesURL.replace("#",ad.get("id")));}
      ad.put("url",headlineRS.getString("urlHeadLine"));
      ads.add(ad);
  }
  con.close();
} catch(Exception e) {
  System.out.println(e);
}
%>
