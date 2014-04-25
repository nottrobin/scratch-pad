#!/usr/bin/perl
use warnings;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;

print "Content-type: text/html\n\n";
my @array;
push(@array,split("\n",`ls -al`));
die Dumper @array;
exit;
