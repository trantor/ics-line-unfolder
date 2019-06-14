# ics-line-unfolder
## Description
For iCalendar files RFC 5545 advises at [section 3.1](https://tools.ietf.org/html/rfc5545#section-3.1):
> The iCalendar object is organized into individual lines of text, called content lines. Content lines are delimited by a line break, which is a CRLF sequence (CR character followed by LF character).
> 
>Lines of text SHOULD NOT be longer than 75 octets, excluding the line break. Long content lines SHOULD be split into a multiple line representations using a line "folding" technique. That is, a long line can be split between any two characters by inserting a CRLF immediately followed by a single linear white-space character (i.e., SPACE or HTAB). Any sequence of CRLF followed immediately by a single linear white-space character is ignored (i.e., removed) when processing the content type.

Therefore iCalendar files usually fold content lines containing text whose encoded form is longer than 75 octets.
That makes them quite inconvenient to process using line-oriented tools/code, for instance to replace portions of those lines using `sed` or to match patterns against those lines using `grep` or similar tools.

The purpose of this code is to process iCalendar files creating files with identical content lines, this time unfolded.
As a corollary lines _could_ be longer than 75 octets + linebreak. In deference to the section of the RFC quoted above, the output lines are terminated by a CRLF 2-character sequence (CarriageReturn LineBreak, or \r\n for anyone familiar with this notation).
## Details and usage
The code is written in Perl 5, using a substitution with code embedded in the regex to perform the actual line unfolding.
See the comments in the programme for further details.
### Usage
```
perl ics_line_unfolder.pl SOURCE.ics > OUTPUT.ics

or

< SOURCE.ics perl ics_line_unfolder.pl > OUTPUT.ics
if you wish to read the source ics file from the standard input
```
### Alternative one-liner
A very concise one-liner which should perform exactly as programme in the file follows. Useful for a quick copy-and-paste in a shell pipeline. In order to maximise its compactness it will likely appear quite cryptic.
```
PERLIO=:crlf perl -0777 -C -pe 'my$g;s/^(?{local$v;})([^\t ][^\n]*+)(?:\n[\t ]([^\n]*)(?{substr($v,length$v)=$^N}))*+(?{$g=$v})/$1$g/mg'
#
# or for Perl 5.12+ ( \N equivalent to [^\n] )
#
PERLIO=:crlf perl -0777 -C -pe 'my$g;s/^(?{local$v;})([^\t ]\N*+)(?:\n[\t ](\N*)(?{substr($v,length$v)=$^N}))*+(?{$g=$v})/$1$g/mg'

# e.g.
$ cat SOURCE.ics |
PERLIO=:crlf perl -0777 -C -pe 'my$g;s/^(?{local$v;})([^\t ][^\n]*+)(?:\n[\t ]([^\n]*)(?{substr($v,length$v)=$^N}))*+(?{$g=$v})/$1$g/mg' |
sed '/ORGANIZER/ s/mailto:address1@dom.tld/mailto:subst_address@dom.tld/' > CONVERTED.ics
```
