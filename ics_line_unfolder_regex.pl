#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: ics_line_unfolder_regex.pl
#
#        USAGE: ./ics_line_unfolder_regex.pl FOLDED.ICS > UNFOLDED.ICS
#               ./ics_line_unfolder_regex.pl < FOLDED.ICS > UNFOLDED.ICS
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
# PERLIO=:crlf perl -0777 -C -pe 'my$g;s/^(?{local$v;})([^\t ][^\n]*+)(?:\n[\t ]([^\n]*)(?{substr($v,length$v)=$^N}))*+(?{$g=$v})/$1$g/mg'
#
# or for Perl 5.12+ ( \N equivalent to [^\n] )
#
# PERLIO=:crlf perl -0777 -C -pe 'my$g;s/^(?{local$v;})([^\t ]\N*+)(?:\n[\t ](\N*)(?{substr($v,length$v)=$^N}))*+(?{$g=$v})/$1$g/mg'
#

use strict;
use warnings;
use utf8;

# Decode INPUT / encode OUTPUT with a CRLF line ending as per iCalendar SPECS
use open qw/:std :encoding(utf8)/, IO => ":mmap :crlf";

binmode STDIN, ":mmap :crlf";
binmode STDOUT, ":crlf";

# Slurp the entire input in one go
local $/;

my $continuation_lines;
our $cumulative_continuation_lines;

while (<>) {
    # Locate lines delimited by LF and substitute sequences of a starting line plus
    # one or more continuation lines with their concatenation.
    #
    # Matching globally ( /g ) in multiline mode ( /m ) with a free-form ( /x ) regex.
    s{
        ^                 # Start of a line (at the very beginning of the string or
                          # after a LF character)

        (?{               # Embedded code block initialising a holding variable
            local $cumulative_continuation_lines = "";
        })
        (                 # Capture holding the first line of a new content line

            [^\t ]        # Line NOT starting with a SPACE or HTAB
            [^\n]*+       # and matching up until the first subsequent LF character
                          # avoiding backtracking with a possessive match

        )
        (?:               # Group wrapping the trailing LF of the previous line and
                          # the continuation line up until the next LF character

            \n            # LF character
            [\t ]         # Leading SPACE or HTAB signaling the start of a continuation line

            (             # Capture holding the rest of the continuation line up to the next LF
                [^\n]*
            )
            (?{           # Embedded code block appeding to the holding variable the contents
                          # of the capture with the contents of the continuation line save for
                          # the leading SPACE or HTAB
                substr( $cumulative_continuation_lines, length $cumulative_continuation_lines ) = $^N;
            })
        )++               # Group match repeating for 1+ possible continuation lines avoiding backtracking
                          # through a possessive quantifier, therefore concatenating the contents of each
                          # continuation line to the holding variable

        (?{               # Embedded code block saving the contents of the holding variable to the final
                          # variable holding the continuation lines unfolded, code block executed after all
                          # continuation lines have matched
            $continuation_lines = $cumulative_continuation_lines;
        })
    }{$1$continuation_lines}mgx;
    print;
}
