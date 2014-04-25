<%@page contentType="text/javascript" %>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="java.io.*" %>
<%@ include file="getVars.jsp" %>
<%@ include file="methods.jsp" %>
/* 
=======================
Scrolling widget script
=======================
This script is designed to allow the insertion of a scrolling list of RSS items using one line of HTML code similar to:
<div id="mySiteWidget"></div><script type="text/javascript" src="http://localhost:8080/widget/widget.js"></script>
(The exact format of this line depends on the variables below)

The script reads a specially formatted external RSS document, parses it and then inserts the contents into an element in
the host document as HTML, specified by the ID specified in the variables below.

The data will be inserted in pure HTML format. This script can then insert a stylesheet into the document, again specified
by the variables below, which should contain style information for the inserted HTML.

The "scroll" function is then run on the items list, which will set the items automatically scrolling upwards, provided:
- The height of the items list is specified and is too small to fit all the elements.
- The property "overflow: hidden" is set on the items list
*/

/*
Important linking variables
---------------------------
*/
var siteURL = "<%=channelInfo.get("siteURL")%>"; // The url of your site including the trailing "/". E.g.: http://www.server.com/
var rssURL = "<%=channelInfo.get("rssURL")%>"; // The url of your site including the trailing "/". E.g.: http://www.server.com/
var styleSheetURL = "<%=channelInfo.get("styleSheetURL")%>"; // The url of the CSS stylesheet to be loaded into the page - MUST be a full URL (http://<server>/<location>.css)
var imagesWidth = <%=channelInfo.get("imagesWidth")%>;
var imagesHeight = <%=channelInfo.get("imagesHeight")%>;
var divID = "<%=channelInfo.get("divID")%>"; // The ID that the element will have in the user's page - all other IDs and classes will be computed from this value too

/*
Scroll config variables
------------------------
*/
var startDelay = 1000; // Time after page loads before the scroll starts, in milliseconds.
var pauseBetweenItems = 1000; // Time after page loads before the scroll starts, in milliseconds.
var speedDelay = 60; // milliseconds between scroll jumps. Lower = faster

/*
Start doing stuff
*/
window.oldOnload = window.onload; // Store any previous onload functions
window.onload = function(event) {
    if(!event) event = window.event;
    // Do old onload stuff
    if(window.oldOnload) window.oldOnload(event);
    
    // Change options if specified
    if(typeof(scrollWidgetOptions) == 'object' && typeof(scrollWidgetOptions['scroll']) == 'object') {
        if(typeof(scrollWidgetOptions['scroll']['speedDelay']) == 'number') speedDelay = scrollWidgetOptions['scroll']['speedDelay'];
        if(typeof(scrollWidgetOptions['scroll']['pauseBetweenItems']) == 'number') pauseBetweenItems = scrollWidgetOptions['scroll']['pauseBetweenItems'];
        if(typeof(scrollWidgetOptions['scroll']['startDelay']) == 'number') startDelay = scrollWidgetOptions['scroll']['startDelay'];
    }
    
    // First check that the element for adding everything to exists
    if(document.getElementById && document.getElementById(divID)) {
        addStyleSheet(styleSheetURL,styleSheetResults); // Load the stylesheet if we've been given one
        writeHTML(); // Write the HTML to the document
        changeStylesToOptions(); // Read the options specified on the user's page and style the HTML accordingly
        window.setTimeout(function(){scroll(document.getElementById(divID + 'Items'),speedDelay,true)},startDelay); // Start scrolling (after an optional delay)
    }
}

// Handle stylesheet results
function styleSheetResults(success,styleSheet) {if(!success) alert("Failed to load stylesheet from '"+styleSheetURL+"'");}

// Change the style sheet according to in an associative array
function changeStylesToOptions() {
    // Get the elements
    var mainContainer = document.getElementById(divID);
    var itemsContiner = document.getElementById(divID+"Items");
    var headerElem = document.getElementById(divID+"Header");
    // If we have been passed options for the widget and we retrieved all the elements okay
    if(typeof(scrollWidgetOptions) == 'object' && typeof(scrollWidgetOptions['css']) == 'object' && typeof(mainContainer) == 'object' && typeof(itemsContiner) == 'object' && typeof(headerElem) == 'object') {
        // Change width
        if(typeof(scrollWidgetOptions['css']['width']) == 'number') mainContainer.style.width = scrollWidgetOptions['css']['width']+"px";
        // Change height
        if(typeof(scrollWidgetOptions['css']['height']) == 'number') itemsContiner.style.height = scrollWidgetOptions['css']['height']+"px";
        // Change border color
        if(typeof(scrollWidgetOptions['css']['borderColor']) == 'string') mainContainer.style.borderColor = scrollWidgetOptions['css']['borderColor'];
        // Change background color
        if(typeof(scrollWidgetOptions['css']['backgroundColor']) == 'string') mainContainer.style.backgroundColor = scrollWidgetOptions['css']['backgroundColor'];
        // Change headline font size
        if(typeof(scrollWidgetOptions['css']['fontSizeHeadline']) == 'number') headerElem.style.fontSize = scrollWidgetOptions['css']['fontSizeHeadline']+"pt";
    } else return false;
}

// Add a stylesheet to the document - GET THIS TO WORK SO THAT IT LOADS AT THE BEGINNING OF THE LIST
function addStyleSheet(styleSheetURL,resultFunction) {
    var initialStyleSheets = document.styleSheets.length;
    if(document.createStyleSheet) document.createStyleSheet(styleSheetURL,0);
    else {
        // Create new stylesheet link
        var newCSS = document.createElement('link');
        newCSS.setAttribute('rel','stylesheet');
        newCSS.setAttribute('type','text/css');
        newCSS.href= styleSheetURL;
        //newCSS.href='data:text/css,'+escape("@import url(' " + styleSheetURL + " ');");
        // Add new stylesheet link to beginning of <head>
        var theHead = document.getElementsByTagName('head')[0];
        if(theHead.hasChildNodes()) theHead.insertBefore(newCSS,theHead.childNodes[0]);
        else theHead.appendChild(newCSS);
    }
    // Get waiting for the style sheet to load
    var styleSheetFail = window.setTimeout(
        function() {
            if(typeof(styleSheetResults) == 'function') styleSheetResults(false);
            window.clearInterval(waitingForStyleSheet);
        },5000
    );
    var waitingForStyleSheet = window.setInterval(
        function() {
            if(document.styleSheets.length == initialStyleSheets + 1) {
                window.clearTimeout(styleSheetFail);
                window.clearInterval(waitingForStyleSheet);
                if(typeof(resultFunction) == 'function') resultFunction(true,document.styleSheets[document.styleSheets.length - 1]);
            }
        },30
    );
    return true;
}


// Parse the XML data from an RSS feed into HTML
function writeHTML() {
    var channel = new Object();
    channel.header = new Object();
    channel.items = new Array(<%=ads.size()%>);
    // Header info
    channel.header.title = "<%=toJSString(channelInfo.get("headerText"))%>";
    channel.header.url = rssURL;
    channel.header.footer = "<%=toJSString(channelInfo.get("footerText"))%>";
    // Items info
    <%for(int i = 0; i < ads.size(); i++) {%>
    channel.items[<%=i%>] = {
        id: "<%=(String)ads.get(i).get("id")%>",
        title: "<%=toJSString((String)ads.get(i).get("heading"))%>",
        url: "http://<%=ads.get(i).get("url")%>",
        by: "<%=toJSString((String)ads.get(i).get("by"))%>"<%if(ads.get(i).containsKey("picture")) {%>,
        picture: "<%=ads.get(i).get("picture")%>"<%}%>
    };
    <%}%>
    
    // Add the items to the page
    var theDiv = document.getElementById(divID);
    
    // Set up header
    var header = document.createElement('h1');
    header.id = divID + 'Header';
    var headerLink = document.createElement('a');
    headerLink.href = channel.header.url;
    headerLink.alt = channel.header.title;
    headerLink.appendChild(document.createTextNode(channel.header.title)); // Add text to link
    header.appendChild(headerLink); // Add link to header div
    theDiv.appendChild(header); // Add to theDiv
    
    // Set up scroll box
    var itemsList = document.createElement('ul');
    itemsList.id = divID + 'Items';
    
    // Set up all items
    for(var itemC = 0; itemC < channel.items.length; itemC++) {
        var thisItem = channel.items[itemC];
        // Create item
        var listItem = document.createElement('li');
        listItem.id = divID + 'Item' + thisItem.id;
        listItem.className = divID + 'Item';
        // Add a picture if applicable
        if(typeof(thisItem.picture) != 'undefined') {
            var pictureLink = document.createElement('a');
            pictureLink.href = thisItem.url;
            var itemPicture = document.createElement('img');
            itemPicture.src = thisItem.picture;
            itemPicture.width = imagesWidth;
            itemPicture.height = imagesHeight;
            itemPicture.className = divID + 'ItemPicture';
            itemPicture.alt = thisItem.title;
            pictureLink.appendChild(itemPicture);
            listItem.appendChild(pictureLink); // Add picture div to item div
        }
        // item header
        var itemHeader = document.createElement('h2');
        itemHeader.className = divID + 'ItemHeader';
        // Create header link
        var itemHeaderLink = document.createElement('a');
        itemHeaderLink.href = thisItem.url;
        itemHeaderLink.appendChild(document.createTextNode(thisItem.title));
        itemHeader.appendChild(itemHeaderLink);
        listItem.appendChild(itemHeader); // Add header to item div
        // Create byline
        itemByLine = document.createElement('p');
        itemByLine.className = divID + 'ItemByLine';
        itemByLine.appendChild(document.createTextNode(thisItem.by));
        listItem.appendChild(itemByLine); // Add by line to item div
        // Add item div to scroll box
        itemsList.appendChild(listItem);
    }
    
    // Add item div to the div
    theDiv.appendChild(itemsList);
    
    // Set up footer
    var footer = document.createElement('p');
    footer.id = divID + 'Footer';
    footer.appendChild(document.createTextNode(channel.header.footer));
    theDiv.appendChild(footer); // Add to theDiv
    
    return true;
}

/* The scroller. Scrolls all elements within a "scroll box".
Arguments:
 - container - the element to be the "scroll box"
 - milliseconds - number of milliseconds wait between movements. I find 60 is a good number.
 - stopOnMouse - self explanatory: will stop scrolling onmouseover and start again onmouseout
 note: will only scroll if the scroll height is greater than the height of the container element
 note: expects the container element to have "overflow: hidden" (although also sort of works with "overflow: auto")
*/ 
// The variable for looping on...
var myInterval;
var running = false;
var mouseOver = false;
function scroll(container,milliseconds,stopOnMouse) {
    if(typeof(container) == 'object' && typeof(container.nodeType) == 'number' && typeof(container.scrollHeight) == 'number' && typeof(container.clientHeight) == 'number'
      && container.nodeType == 1 && container.hasChildNodes() && container.scrollHeight > container.clientHeight) {
        // set default value of milliseconds if not specified
        if(typeof(milliseconds) != "number") milliseconds = 100;
        
        // Make the container "overflow: hidden"
        container.style.overflow = "hidden";
        
        // If we want to stop on mouse over..
        if(stopOnMouse) {
            container.onmouseover = function() {
                stopRunning();
                mouseOver = true;
            }
            container.onmouseout = function(event) {
                if(!event) event = window.event;
                mouseOver = false;
                if(checkMouseOut(container,event) && !running) scroll(container,milliseconds,stopOnMouse);
            }
        }
        
        var children = container.childNodes;
        // Remove anything that's not an element, for efficiency.
        for(var i=0; i<children.length; i++) if(children[i].nodeType != 1) container.removeChild(children[i]);
        
        myInterval = window.setInterval(
            function() {
                running = true;
                
                // Scroll
                container.scrollTop = container.scrollTop + 2;
                // Deal with the top element
                var top = container.firstChild;
                // if it's so big that it'll never get off the screen, we have to add an empty element
                var topHeight = getComputedDimensions(top).height;
                if(topHeight > container.scrollHeight - container.clientHeight) {
                    // Calculate how much extra space we need on the bottom for this element to be able to loop...
                    var extra = topHeight - (container.scrollHeight - container.clientHeight) + 1;
                    // Create a new div to fill the space
                    var fillerDiv = document.createElement('div');
                    fillerDiv.appendChild(document.createTextNode(" "));
                    // Make sure it's invisible
                    fillerDiv.style.display = 'block';
                    fillerDiv.style.position = 'static';
                    fillerDiv.style.padding = '0';
                    fillerDiv.style.margin = '0';
                    fillerDiv.style.background = 'transparent none';
                    fillerDiv.style.border = '0px none';
                    // give it width and height to fill in the container
                    fillerDiv.style.width = (container.clientWidth - 20) + "px";
                    fillerDiv.style.height = extra + "px";
                    // Add it to the container
                    container.appendChild(fillerDiv);
                }
                // if it's off the screen then move it to the bottom again
                var thisScrollTop = container.scrollTop;
                if(thisScrollTop > top.clientHeight) { // If we are scrolled more than height of top element
                    // Try removing the element
                    container.scrollTop = thisScrollTop + 1;
                    container.removeChild(top);
                    if(container.scrollTop > 0) { // If we were indeed out of the scroll area, then add the element to the end
                        container.scrollTop = 0;
                        container.appendChild(top);
                        // And do the pause
                        stopRunning();
                        window.setTimeout(function(){if(!running && !mouseOver) scroll(container,milliseconds,stopOnMouse);},pauseBetweenItems);
                    } else { // Otherwise, put it back
                        container.insertBefore(top,container.firstChild);
                        container.scrollTop = thisScrollTop;
                    }
                }
            },milliseconds
        );
    } else return false;
}

function stopRunning() {
    window.clearInterval(myInterval);
    running = false;
    return;
}

/*
Helper functions for "scoll()"
*/
// Check whether the mouse has really left the element
function checkMouseOut(elem,evt) {
    var boundaries = getBoundaries(elem);
    if(evt.clientX <= boundaries.left || evt.clientX >= boundaries.right || evt.clientY <= boundaries.top || evt.clientY >= boundaries.bottom) return true;
    else return false;
}

// Returns an object containing four properties - top, right, bottom, left - containing the co-ordinates of the four corners of the element
function getBoundaries(elem) {
    var boundaries = getRealOffsets(elem);
    boundaries.right = boundaries.left + elem.clientWidth;
    boundaries.bottom = boundaries.top + elem.clientHeight;
    return boundaries;
}

// Gets the absolute offsets of an element
function getRealOffsets(elem) {
    var offsets = new Object();
    offsets.left = elem.offsetLeft;
    offsets.top = elem.offsetTop;
    var parent = elem.offsetParent;
    while(parent != document.body) {
        offsets.left += parent.offsetLeft;
        offsets.top += parent.offsetTop;
        parent = parent.offsetParent;
    }
    
    return offsets;
}

// Get height and width including 
function getComputedDimensions(elem) {
    var dimensions = new Object();
    var padding = new Object;
    var margin = new Object;
    if(window.getComputedStyle) {
        margin.top = window.getComputedStyle(elem,"").marginTop.match(/\d+/);
        margin.bottom = window.getComputedStyle(elem,"").marginBottom.match(/\d+/);
        margin.left = window.getComputedStyle(elem,"").marginLeft.match(/\d+/);
        margin.right = window.getComputedStyle(elem,"").marginRight.match(/\d+/);
        padding.top = window.getComputedStyle(elem,"").paddingTop.match(/\d+/);
        padding.bottom = window.getComputedStyle(elem,"").paddingBottom.match(/\d+/);
        padding.left = window.getComputedStyle(elem,"").paddingLeft.match(/\d+/);
        padding.right = window.getComputedStyle(elem,"").paddingRight.match(/\d+/);
    } else if(elem.currentStyle) {
        // Give elem "layout" in IE so we can get it's dimensions properly
        if(typeof(elem.currentStyle.hasLayout) == 'boolean' && !elem.currentStyle.hasLayout) elem.style.zoom = 1;
        
        margin.top = elem.currentStyle.marginTop.match(/\d+/);
        margin.bottom = elem.currentStyle.marginBottom.match(/\d+/);
        margin.left = elem.currentStyle.marginLeft.match(/\d+/);
        margin.right = elem.currentStyle.marginRight.match(/\d+/);
        padding.top = elem.currentStyle.paddingTop.match(/\d+/);
        padding.bottom = elem.currentStyle.paddingBottom.match(/\d+/);
        padding.left = elem.currentStyle.paddingLeft.match(/\d+/);
        padding.right = elem.currentStyle.paddingRight.match(/\d+/);
    }
        
    // If we are unable to get margin or padding, because it hasn't been set, assume it's 20 on all sides
    for(var j in margin) {
        if(!margin[j]) margin[j] = 20;
        margin[j] = Number(margin[j]);
    }
    for(var k in padding) {
        if(!padding[k]) padding[k] = 20;
        padding[k] = Number(padding[k]);
    }
    
    
    // Set dimensions
    dimensions.height = elem.clientHeight + margin.top + margin.bottom + padding.top + padding.bottom;
    dimensions.width = elem.clientWidth + margin.left + margin.right + padding.left + padding.right;
    
    return dimensions;
}
