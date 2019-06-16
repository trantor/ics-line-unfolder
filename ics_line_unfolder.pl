#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: ics_line_unfolder.pl
#
#        USAGE: ./ics_line_unfolder.pl FOLDED.ICS > UNFOLDED.ICS
#               ./ics_line_unfolder.pl < FOLDED.ICS > UNFOLDED.ICS
#
#  DESCRIPTION: Code which prints iCalendar files with their content lines
#               unfolded. Lines starting with either a SPACE or HTAB character
#               have that character removed and are concatenated to the
#               preceding line.
#               NOTICE: the lines in the output are terminated by CRLF sequences,
#               as dictated by the iCalendar specifications.
#
#       AUTHOR: Fulvio Scapin
#      VERSION: 1.0.0
#      CREATED: 2019-06-14
#===============================================================================

# Compact one-liner which should be roughly equivalent to running this script
#
# PERLIO=:crlf perl -C -wnE 'state$a;$a//($a=$_,next);s///,substr($a,(length$a)-1)=$_,(eof(ARGV)and print$a),next if /^[\t ]/;print $a;$a=$_;$a=undef,print if eof(ARGV);'
# 

use strict;
use warnings;
use utf8;

# Decode INPUT / encode OUTPUT with a CRLF line ending as per iCalendar SPECS
use open qw/:std :encoding(utf8)/, IO => ":mmap :crlf";

binmode STDIN, ":mmap :crlf";
binmode STDOUT, ":crlf";

# Variable holding the previous line
my $hold;

while (<>) {

    # First line of a file
    if (not defined $hold ) {
        $hold = $_;
        next;
    }

    # On a continuation line
    if ( m/^[\t ]/ ) {
        s/^[\t ]//;
        substr( $hold, ( length $hold ) - 1 ) = $_;
        print $hold if eof(ARGV);
        next;
    }

    print $hold;
    $hold = $_;

    # Last line of a file
    if ( eof(ARGV) ) {
        $hold = undef;
        print;
        next;
    }

}
