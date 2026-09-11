use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-abbreviated-$*PID.raku"
);

LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
use v6.d;

my $before = 1;

=begin pod

=head3
Heading level 3

=end pod

my $after = 2;
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 1,
    'abbreviated heading produces one block';

is @blocks[0]<type>, 'heading',
    'block is a heading';

is @blocks[0]<level>, 3,
    'heading level is preserved';

is @blocks[0]<depth>, 2,
    'heading depth is level minus one';

is @blocks[0]<text>, 'Heading level 3',
    'heading text is preserved';

done-testing;
