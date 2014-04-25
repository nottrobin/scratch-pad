#!/usr/bin/perl

# Load packages
###############

# Best practice
use warnings;
use strict;

# Essential standard objects
use CGI; # The CGI object, for generating the HTML header and retrieving CGI variables
use CGI::Carp qw(fatalsToBrowser); # Prints CGI errors to the browser, for debugging

use Data::Compare;

print "Content-type: text/html\n\nhello world!\n";

exit;
