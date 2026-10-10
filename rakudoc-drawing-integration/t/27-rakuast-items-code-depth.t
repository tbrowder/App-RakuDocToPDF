use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-items-code-depth-$*PID.raku"
);

LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
use v6.d;

=begin pod

=head1 OPTIONS

=item First option

    say "first";

=head2 DETAILS

=item Second option

    say "second";

=head1 END

=item Final option

=end pod
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 8,
    'headings, items, and code produce eight blocks';

is @blocks[0]<type>, 'heading',
    'first block is a heading';

is @blocks[0]<level>, 1,
    'first heading is level 1';

is @blocks[0]<depth>, 0,
    'first heading depth is zero';

is @blocks[1]<type>, 'item',
    'first item follows first heading';

is @blocks[1]<text>, 'First option',
    'first item text is preserved';

is @blocks[1]<depth>, 1,
    'item depth is one greater than heading depth';

is @blocks[2]<type>, 'code',
    'code follows first item';

is @blocks[2]<text>, 'say "first";',
    'first code text is preserved';

is @blocks[2]<depth>, 0,
    'code inherits current heading depth';

is @blocks[3]<type>, 'heading',
    'second heading follows code';

is @blocks[3]<level>, 2,
    'second heading is level 2';

is @blocks[3]<depth>, 1,
    'second heading depth is one';

is @blocks[4]<type>, 'item',
    'second item follows second heading';

is @blocks[4]<text>, 'Second option',
    'second item text is preserved';

is @blocks[4]<depth>, 2,
    'second item depth is one greater than heading depth';

is @blocks[5]<type>, 'code',
    'second code follows second item';

is @blocks[5]<text>, 'say "second";',
    'second code text is preserved';

is @blocks[5]<depth>, 1,
    'second code inherits current heading depth';

is @blocks[6]<type>, 'heading',
    'final heading returns to level 1';

is @blocks[6]<level>, 1,
    'final heading level is one';

is @blocks[6]<depth>, 0,
    'final heading resets depth to zero';

is @blocks[7]<type>, 'item',
    'final item follows final heading';

is @blocks[7]<text>, 'Final option',
    'final item text is preserved';

is @blocks[7]<depth>, 1,
    'final item depth follows reset heading depth';

done-testing;
