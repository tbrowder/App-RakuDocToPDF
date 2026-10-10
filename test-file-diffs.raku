#!/usr/bin/env raku

# two lists of files
my $fpdf = "t.pdf";
my $fra  = "t.rakudoc";

my @files;
my @words;
for $fpdf.IO.lines -> $line {
    say "Working text chunk: '$line'";
    my @words = $line.words;
    for @words -> $word {
        say "Working text chunk: '$word'";
        if $word.IO.e {
            say "    text '$word' is a file"; #Working text chunk: '$word'";
        }
    }
}

=finish
n
if $file.IO {
        say "Chunk '$file' is a file.";
        $is-file = True;
        say "Working PDF file: '$file'";
    }
    else {
        say "Working a line of text...";
        say "    chunks:";
        my @words = $file.words;
        for @words -> $word {
            if $word.IO {
#               $is-file = True;
                say "Working PDF file: '$word'";
            }
            else {
                say "Working chunk: '$word'";
            }
        }
    }

    for $file.IO.words -> $word {
        if $word ~~ /2024/ {
            say "  word: '$word'";   
        }
    }
}

for $fra.IO.lines -> $file {
}



