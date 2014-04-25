// Find and select all text in the document that matches the "value" of the element passed
// If no element if passed, it will attempt to use the value of "this"
// Only works in a browser that supports the "window.getSelection" method, as other selection methods don't support multiple selectionsz
function performMultiSearch(elem,searchElem) {
    // set up variables
    var searchString; // Will hold the text to search for
    var theSelection; // Will hold the document's selection object
    var textNodes; // Will hold all the text nodes in the document
    
    // Set it to search the entire document if we haven't been given an element to search
    if(!searchElem || typeof(searchElem) == 'undefined') searchElem = document.body;
    
    // Get the string to search for
    if(elem && elem.value) searchString = elem.value;
    else if(this && this.value) searchString = this.value;
    
    // Get all the text nodes in the document
    textNodes = findTypeNodes(searchElem,3);
    
    // Get the selection object
    if(window.getSelection) theSelection = window.getSelection(); // firefox
    else { // some other browser - doesn't support multiple selections at once
        alert("sorry this searching method isn't supported by your browser");
        return;
    }
    
    // Empty the selection
    theSelection.removeAllRanges(); // We want to empty the selection regardless of whether we're selecting anything
    
    if(searchString.length > 0) { // make sure the string isn't empty, or it'll crash.
        // Search all text nodes
        for(var i = 0; i < textNodes.length; i++) {
            // Create a regular expression object to do the searching
            var reSearch = new RegExp(searchString,'gmi'); // Set it to 'g' - global (finds all instances), 'm' - multiline (searches more than one line), 'i' - case insensitive
            var stringToSearch = textNodes[i].textContent;
            while(reSearch(stringToSearch)) { // While there are occurrences of the searchString
                // Add the new selection range
                var thisRange = document.createRange();
                thisRange.setStart(textNodes[i],reSearch.lastIndex - searchString.length); // Start node and index of the selection range
                thisRange.setEnd(textNodes[i],reSearch.lastIndex); //  End node and index of the selection
                theSelection.addRange(thisRange); // Add the node to the document's current selection
            }
        }
    }
    
    return;
}

// Will find and select the first instance of the value of the passed element, then when called again will moves on to the next instance
// If no element passed it will try to get the value from "this"
function performSingleSearch(elem,searchElem) {
    // set up variables
    var searchString; // Will hold the text to search for
    var theSelection; // Will hold the document's selection object
    var textNodes; // Will hold all the text nodes in the document
    
    // Set it to search the entire document if we haven't been given an element to search
    if(!searchElem || typeof(searchElem) == 'undefined') searchElem = document.body;
    
    // Get the string to search for
    if(elem && elem.value) searchString = elem.value;
    else if(this && this.value) searchString = this.value;
    
    if(searchString && searchString.length > 0) { // make sure the string isn't empty, or it'll crash.
        if(window.getSelection) { // Firefox
            // Get the selection
            theSelection = window.getSelection();
    
            // Get all the text nodes in the document
            textNodes = findTypeNodes(searchElem,3);
            
            // If there's already a selection, and it's the string we're searching for
            var searchMatch = new RegExp(searchString,'i');
            if(theSelection.rangeCount == 1 && searchMatch(theSelection.getRangeAt(0).toString())) {
                var currentRange = theSelection.getRangeAt(0);
                theSelection.removeAllRanges();
                
                var newRange = null;
                
                // Move on to the next occurrence of it by iterating through text nodes...:
                for(var i = 0; i < textNodes.length; i++) {
                    // If this text node is before the currentRange, ignore it and carry on to the next one
                    if(currentRange.comparePoint(textNodes[i],0) == -1 && currentRange.startContainer != textNodes[i]) continue;
                    // If this text node is the same as the currentRange, find the point in the currentRange
                    else if((currentRange.comparePoint(textNodes[i],0) == -1 && currentRange.startContainer == textNodes[i]) || (currentRange.comparePoint(textNodes[i],0) == 0)) {
                        // Create a regular expression object to do the searching
                        var reSearch = new RegExp(searchString,'gmi'); // Set it to 'g' - global (finds all instances), 'm' - multiline (searches more than one line), 'i' - case insensitive
                        var stringToSearch = textNodes[i].textContent;
                        while(reSearch(stringToSearch)) { // While there are occurrences of the searchString
                            // Test if the index is after the currentRange's position
                            if(reSearch.lastIndex - searchString.length > currentRange.startOffset) {
                                // This is the new search position - empty the old selection and add the new selection range
                                theSelection.removeAllRanges();
                                newRange = document.createRange();
                                newRange.setStart(textNodes[i],reSearch.lastIndex - searchString.length); // Start node and index of the selection range
                                newRange.setEnd(textNodes[i],reSearch.lastIndex); //  End node and index of the selection
                                break; // We're not interested in the other results, so break out of this while loop.
                            }
                        }
                        if(newRange) break; // If we found a new range, break out of this for loop, cos there's nothing more to do.
                        else continue; // Otherwise continue
                    } 
                    // If this text node is after the current one, search to see if it has any occurrences of the searchString
                    else if(currentRange.comparePoint(textNodes[i],0) == 1) {
                        // Create a regular expression object to do the searching
                        var reSearch = new RegExp(searchString,'gmi'); // Set it to 'g' - global (finds all instances), 'm' - multiline (searches more than one line), 'i' - case insensitive
                        var stringToSearch = textNodes[i].textContent;
                        // If we had a find, use it
                        if(reSearch(stringToSearch)) {
                            // This is the new search position - empty the old selection and add the new selection range
                            theSelection.removeAllRanges();
                            newRange = document.createRange();
                            newRange.setStart(textNodes[i],reSearch.lastIndex - searchString.length); // Start node and index of the selection range
                            newRange.setEnd(textNodes[i],reSearch.lastIndex); //  End node and index of the selection
                            break; // We're not interested in the other results, so break out of this while loop.
                        } else continue;
                    }
                }
                
                if(newRange) {
                    theSelection.addRange(newRange); // Add the node to the document's current selection
                    // Make the new range visible
                    newRange.startContainer.parentNode.scrollIntoView(false);
                    return;
                } else performSingleSearch(elem,searchElem);
            }
            
            // If we don't already have a selection, just find the first instance
            else {
                // Search all text nodes
                for(var i = 0; i < textNodes.length; i++) {
                    // Create a regular expression object to do the searching
                    var reSearch = new RegExp(searchString,'gmi'); // Set it to 'g' - global (finds all instances), 'm' - multiline (searches more than one line), 'i' - case insensitive
                    var stringToSearch = textNodes[i].textContent;
                    if(reSearch(stringToSearch)) { // If there are occurrences of the searchString
                        // This is the new search position - empty the old selection and add the new selection range
                        theSelection.removeAllRanges();
                        // Add the new selection range
                        var thisRange = document.createRange();
                        thisRange.setStart(textNodes[i],reSearch.lastIndex - searchString.length); // Start node and index of the selection range
                        thisRange.setEnd(textNodes[i],reSearch.lastIndex); //  End node and index of the selection
                        theSelection.addRange(thisRange); // Add the node to the document's current selection
                        thisRange.startContainer.parentNode.scrollIntoView(false);
                        break; // We're done
                    }
                }
            }
        }
        else if(document.selection) { // Internet Explorer
            theSelection = document.selection;
            var currentRange = theSelection.createRange();
            
            // Create text range to cover the whole of the searchElem
            var searchRange = document.body.createTextRange();
            searchRange.moveToElementText(searchElem);
            
            // Empty the current selection
            theSelection.empty();
            // If this text is already selected, find the next selection
            if(currentRange && currentRange.text && currentRange.text.match(eval('/'+searchString+'/i'))) {
                // Move start position of range past this word
                currentRange.moveStart('character');
                // Move end position to end of the search element
                currentRange.setEndPoint('EndToEnd',searchRange);
                // Search again
                if(currentRange.findText(searchString)) {
                    // We have found another instance
                    currentRange.select();
                    // Set the key press event, keeping the functionality of the old one as well
                    // This is so that IE will cycle on to the next search result when you press enter, something that Firefox did already
                    var currentkeypress = document.body.onkeypress;
                    window.setTimeout(function() {
                        document.body.onkeypress = function(evt) {
                            if(!evt) evt = window.event; // for internet explorer
                            
                            // If the selection is still what we thought it was
                            var nowRange = document.selection.createRange();
                            if(nowRange.htmlText == currentRange.htmlText) {
                                if(evt.keyCode == 13) { // If enter key pressed
                                    // Set the onkeypress back to what it was
                                    document.body.onkeypress = currentkeypress;
                                    // Perform the search
                                    performSingleSearch(elem,searchElem);
                                }
                            } else {
                                // If the selection isn't what we though, set the onkeypress back to what it was
                                document.body.onkeypress = currentkeypress;
                            }
                            // Either way, perform old onkeypress event as well
                            if(currentkeypress) currentkeypress(evt);
                        }
                    },30);
                    return true;
                } else performSingleSearch(elem,searchElem);
            } else {
                // Find the first occurrence of the searchString
                if(searchRange.findText(searchString)) {
                    // If we've found something, select it
                    searchRange.select();
                    // Set the key press event, keeping the functionality of the old one as well
                    // This is so that IE will cycle on to the next search result when you press enter, something that Firefox did already
                    var currentkeypress = document.body.onkeypress;
                    window.setTimeout(function() {
                        document.body.onkeypress = function(evt) {
                            if(!evt) evt = window.event; // for internet explorer
                            
                            // If the selection is still what we thought it was
                            var nowRange = document.selection.createRange();
                            if(nowRange.htmlText == searchRange.htmlText) {
                                if(evt.keyCode == 13) { // If enter key pressed
                                    // Set the onkeypress back to what it was
                                    document.body.onkeypress = currentkeypress;
                                    // Perform the search
                                    performSingleSearch(elem,searchElem);
                                }
                            } else {
                                // If the selection isn't what we though, set the onkeypress back to what it was
                                document.body.onkeypress = currentkeypress;
                            }
                            // Either way, perform old onkeypress event as well
                            if(currentkeypress) currentkeypress(evt);
                        }
                    },30);
                    
                    return true;
                } else {
                    return false;
                }
            }
        } else alert("Sorry your browser doesn't support a supported selection object"); 
    }
}

// Recursively find all text nodes within an element
function findTypeNodes(elem,type) {
    // Remove superfluous text nodes and merge adjacent text nodes
    elem.normalize();
    
    var typeNodes = new Array();
    // Search all children of this element to see which ones are the right type of node
    for(var nodeI = 0; nodeI < elem.childNodes.length; nodeI++) {
        if(elem.childNodes[nodeI].nodeType == type) typeNodes.push(elem.childNodes[nodeI]); // If it is a the right type of node, add it to the array
        else {
            // If not a the right type of node, search it in turn
            typeNodes = typeNodes.concat(findTypeNodes(elem.childNodes[nodeI],type));
        }
    }
    return typeNodes; // return the array
}
