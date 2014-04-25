#!/usr/bin/perl
use warnings;
use strict;

opendir(IMAGEFOLDER, ".");
my @files = grep(/\.jpg|\.jpeg|\.gif|\.png|\.bmp|\.tif$/i,readdir(IMAGEFOLDER));
closedir(IMAGEFOLDER);

print "Content-type: text/xml\n\n";
print "<images>";
foreach my $file (@files) {
   print "<file>$file</file>";
}
print "</images>\n";
exit;
