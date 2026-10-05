use v6.d;

use Test;

use App::RakuDocToPDF;

my IO::Path $source = $*TMPDIR.add(
    "rakudoc-drawing-integration-$*PID.rakudoc"
);

my IO::Path $output = $*TMPDIR.add(
    "rakudoc-drawing-integration-$*PID.pdf"
);

LEAVE {
    $source.unlink if $source.e;
    $output.unlink if $output.e;
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

my IO::Path $result = rakudoc-to-pdf(
    $source,
    :$output,
    :style<drawing>,
);

plan 4;

is $result.Str, $output.Str,
    'drawing style returns requested output path';

ok $output.e,
    'drawing-style PDF was created';

ok $output.s > 100,
    'drawing-style PDF is not empty';

is $output.slurp(:bin).subbuf(0, 5).decode,
    '%PDF-',
    'drawing-style output has PDF signature';
