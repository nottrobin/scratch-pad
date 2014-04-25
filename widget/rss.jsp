<?xml version="1.0" encoding="utf-8"?>
<%@page contentType="text/xml" %>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="java.io.*" %>
<%@ include file="getVars.jsp" %>
<%@ include file="methods.jsp" %>
<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:image="http://purl.org/rss/1.0/modules/image/">
  <!-- header information -->
  <channel rdf:about="http://<%=request.getServerName()%>:<%=request.getLocalPort()%><%=request.getRequestURI()%>">
    <title><%=toXMLString(channelInfo.get("headerText"))%></title>
    <link>http://<%=request.getServerName()%>:<%=request.getLocalPort()%><%=request.getRequestURI()%></link>
    <description><%=toXMLString(channelInfo.get("footerText"))%></description>

    <items>
      <rdf:Seq>
        <%for(int i = 0; i < ads.size(); i++) {%>
        <rdf:li resource="http://<%=toXMLString((String)ads.get(i).get("url"))%>" />
        <%} // end for loop%>
      </rdf:Seq>
    </items>
  </channel>
  
  <!-- the advertisment items -->
  <%for(int i = 0; i < ads.size(); i++) {%>
  <item rdf:about="http://<%=toXMLString((String)ads.get(i).get("url"))%>">
    <title><%=toXMLString((String)ads.get(i).get("heading"))%></title>
    <link>http://<%=toXMLString((String)ads.get(i).get("url"))%></link>
    <description><%=toXMLString((String)ads.get(i).get("by"))%></description>
    <%if(ads.get(i).containsKey("picture")) {%>
    <image:item rdf:about="<%=toXMLString((String)ads.get(i).get("picture"))%>">
      <dc:title><%=toXMLString((String)ads.get(i).get("heading"))%></dc:title>
      <image:width>60</image:width>
      <image:height>60</image:height>
    </image:item>
    <%}%>
  </item>
  <%} // end for loop%>
</rdf:RDF>
