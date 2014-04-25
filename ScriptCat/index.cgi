#!/usr/bin/perl

=head1 NAME

ScriptCat - A CGI program to serve multiple script files together using a single URI

=head2 USAGE

This program is designed to be called by a web browser.

It takes the names of Script files to load as CGI parameters.

Note: scripts must be of a language that understands /* */ style block comments

Example:
The URL: http://mydomain.com/js/?file1.js;file2.js

=cut

# Required modules
#-
# Best practice
use warnings;
use strict;
# Main perl modules
use CGI;
use JavaScript::Minifier::XS; # Minify JavaScript files
use CSS::Minifier::XS; # Minify CSS files

# Debugging
use Data::Dumper; # Used for printing out data structures
use CGI::Carp qw(fatalsToBrowser); # Prints errors to the browser - only use on development server

# Options
# Minify JavaScript?
my $minify = 1;

main();
exit;

=head2 SUBROUTINES

=head3 main

The "initialiser" - reads in the files list, calls and returns output from join_files()

=cut

sub main {
    # Gateway interface
    my $cgi = CGI->new();
    
    # Get a list of parameter names
    my @paths = $cgi->param();
    
    # A hack because CGI.pm is stupid
    if(@paths == 1 && $paths[0] eq 'keywords') {@paths = $cgi->keywords();}
    
    # If we have been passed no files, print usage instructions
    if(@paths == 0) {
        print $cgi->header(-type=>'text/plain');
        print "No files selected.\n";
        print "Usage: ScriptCat takes script file names as parameters\n";
        print "E.g.: /[path_to_script]?file1.js&file2.js\n";
        exit;
    }
    
    # Get the concatenated contents of the Script files
    my $all_contents = join_file_contents(\@paths);
    
    # Now print the concatenated scripts' contents
    print $cgi->header(-type=>select_mime_header(\@paths));
    print $all_contents;
}

=head3 join_file_contents

Returns the joined contents of a list of files

=cut

sub join_file_contents {
    my $paths = shift;
    
    # Add each path's contents to $joined_contents
    my $joined_contents = '';
    foreach my $path (@$paths) {
        $joined_contents .= get_contents($path) . "\n";
    }
    
    return $joined_contents;
}

=head3 get_contents

Simply returns the contents of a file

=cut

sub get_contents {
    my $path = shift;
    
    # Open the file
    open(FILE,"./$path") or return "/** ERROR: Can't find file '$path' */";
    # Read file contents
    my $contents = "";
    while(my $line = <FILE>) {
        $contents .= $line;
    }
    # Close file
    close(FILE);
    
    # Minify?
    if($minify && $path =~ /\.js$/) {$contents = JavaScript::Minifier::XS::minify($contents);}
    if($minify && $path =~ /\.css$/) {$contents = CSS::Minifier::XS::minify($contents);}
    
    return "/** File '$path' contents */\n" . $contents . "\n";
}

=head3 select_mime_header

Choose a sensible mime type based on the extensions of the files in path

=cut

sub select_mime_header {
    my $path = shift;
    
    if ( all_match($path,'\.js$')) {
        return 'application/x-javascript';
    } elsif ( all_match($path,'\.css$') ) {
        return 'text/css';
    } else {
        return 'text/plain';
    }
}

=head3 all_match

Checks if every item in an array matches a regular expression

=cut

sub all_match {
    my $list = shift;
    my $regex = shift;
    
    foreach my $item ( @$list ) {
        if( $item !~ /$regex/ ) {
            return 0;
        }
    }
    
    return 1;
}

exit;
