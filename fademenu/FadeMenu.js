var FadeMenu = new Class({
    initialize: function fadeMenu(elem,options) {
        // Retrieve the element properly
        this.parentElem = $(elem);
        if($type(this.parentElem) != 'element') {throw new Error('invalid element or id passed as first argument');}
        // Add the options
        this.options = new Abstract({ // Defaults
            fadeRecursive: true,
            fadeInSpeed: 150,
            fadeOutSpeed: 100,
            fadeOutDelay: 300,
            ignoreClass: false
        });
        if($type(options) == 'object') {this.options.extend(options);}
        // Retrieve the child items
        this.menuItems = this.parentElem.getChildren().filterByTag('li');
        // Setup all sub menus
        for(var i=0; i<this.menuItems.length; i++) {
            // Find this item's sub menu
            var subMenu = this.menuItems[i].getElement('ul');
            // If we have a sub menu, set it up
            if(
                $type(subMenu) == 'element' // Make sure it's an element
                && !($defined(this.ignoreClass) && subMenu.className != this.ignoreClass) // And that it doesn't have the "ignoreClass"
            ) {
                this.menuItems[i].subMenu = subMenu;
                this.setupSubMenu(subMenu);
                subMenu.create(this.options);
            }
        }
    },
    setupSubMenu: function(subMenu) {
        if($type(subMenu) == 'element') {
            new Abstract(subMenu).extend({
                create: function(options) {
                    // Get options
                    this.options = options;
                    // Retrieve elements
                    this.parentElem = this.getParent();
                    // Make sure the element and all it's items are hidden
                    this.menuItems().setOpacity(0);
                    this.setOpacity(0);
                    // Create new events for fadein and fadeout
                    this.addEvent('fadein',this.showMenu);
                    this.addEvent('fadeout',this.hideMenu);
                    // Add mouseenter and mouseleave events to the sub menu
                    var thisMenu = this;
                    this.parentElem.addEvent('mouseenter',function(evt) {thisMenu.latestEvent = 'mouseenter'; thisMenu.fireEvent('fadein',evt)});
                    this.parentElem.addEvent('mouseleave',function(evt) {thisMenu.latestEvent = 'mouseleave'; thisMenu.fireEvent('fadeout',evt,thisMenu.options.fadeOutDelay)});
                    
                    // If recursive, run fadeMenu on this list
                    if(this.options.fadeRecursive) {new FadeMenu(this,this.options)};
                },
                showMenu: function(evt) {
                    if(this.latestEvent == 'mouseleave') {return false;}
                    // Show each item
                    this.fadeInQueue = this.menuItems(); // get our menu items
                    this.setOpacity(1); // Make sure the list is visible
                    this.fadeInItems();
                },
                hideMenu: function(evt) {
                    if(this.latestEvent == 'mouseenter') {return false;}
                    // Hide all items
                    this.fadeOutQueue = this.menuItems(); // get out menu items
                    this.fadeOutItems();
                },
                fadeInItems: function() {
                    // Get the list element
                    var thisMenu;
                    if(this.element) {thisMenu = this.element.getParent();}
                    else {thisMenu = this;}
                    // If there are still menu items left, and we're still fading in, fade in the first one
                    if(thisMenu.fadeInQueue.length > 0 && thisMenu.latestEvent == 'mouseenter') {
                        thisItem = thisMenu.fadeInQueue.shift();
                        // Stop any fade outs going on
                        if($defined(thisItem.fadeout)) {thisItem.fadeout.stop();}
                        // Check it needs fading in - otherwise move onto the next item
                        if(thisItem.getStyle('opacity') < 1) {
                            // Fade this item, then chain on to the next
                            thisItem.fadein = new Fx.Style(thisItem, 'opacity', {duration: thisMenu.options.fadeInSpeed}).start(thisItem.getStyle('opacity'),0.9999).chain(thisMenu.fadeInItems);
                        } else {thisMenu.fadeInItems();}
                    } else {return false;}
                },
                fadeOutItems: function() {
                    // Get the list element
                    var thisMenu;
                    if(this.element) {thisMenu = this.element.getParent();}
                    else {thisMenu = this;}
                    // If there are still menu items left, fade out the last one
                    if(thisMenu.fadeOutQueue.length > 0) {
                        // If we are still fading out...
                        if(thisMenu.latestEvent == 'mouseleave') {
                            thisItem = thisMenu.fadeOutQueue.pop();
                            // Stop any fade ins going on
                            if($defined(thisItem.fadein)) {thisItem.fadein.stop();}
                            // Check it needs fading out - otherwise move on
                            if(thisItem.getStyle('opacity') > 0) {
                                // Fade this item, then chain on to the next
                                thisItem.fadeout = new Fx.Style(thisItem, 'opacity', {duration: thisMenu.options.fadeOutSpeed}).start(thisItem.getStyle('opacity'),0).chain(thisMenu.fadeOutItems);
                            } else {thisMenu.fadeOutItems();}
                        } else {return false;}
                    } else {
                        if(thisMenu.latestEvent == 'mouseleave') {thisMenu.setOpacity(0);}
                    }
                },
                menuItems: function() {return this.getChildren().filterByTag('li')}
            });
        }
    }
});