use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $source = $*TMPDIR.add(
    "rakudoc-drawing-reader-$*PID.rakudoc"
);

LEAVE {
    $source.unlink if $source.e;
}

$source.spurt: q:to/END/;
=begin pod

=begin drawing

page media=Letter orientation=landscape margin=0.5in
grid columns=11 line-width=0.75pt
rows 1in 1in repeat=0.375in fill

=end drawing

=end pod
END

my @blocks = read-rakudoc-rakuast($source);

my %drawing;

for @blocks -> %block {
    if %block<type> eq 'drawing' {
        %drawing = %block;
        last;
    }
}

plan 4;

ok %drawing.elems,
    'drawing block was found';

is %drawing<type>, 'drawing',
    'drawing block has drawing type';

like %drawing<text>,
    / 'page media=Letter' /,
    'drawing block contains page command';

like %drawing<text>,
    / 'rows 1in 1in repeat=0.375in fill' /,
    'drawing block contains rows command';
