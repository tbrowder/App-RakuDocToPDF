use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-code-heading-depth-$*PID.raku"
);

LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
use v6.d;

=begin pod

=head1 FIRST

First paragraph.

    say "first";

=head2 SECOND

Second paragraph.

    say "second";

=head1 THIRD

Third paragraph.

=end pod
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 8,
    'headings, paragraphs, and code produce eight blocks';

is @blocks[0]<type>, 'heading',
    'first block is a heading';

is @blocks[0]<level>, 1,
    'first heading is level 1';

is @blocks[0]<depth>, 0,
    'first heading depth is zero';

is @blocks[1]<type>, 'paragraph',
    'paragraph follows first heading';

is @blocks[1]<depth>, 0,
    'paragraph inherits first heading depth';

is @blocks[2]<type>, 'code',
    'code follows first paragraph';

is @blocks[2]<depth>, 0,
    'code inherits first heading depth';

is @blocks[2]<text>, 'say "first";',
    'first code text is preserved';

is @blocks[3]<type>, 'heading',
    'second heading follows code';

is @blocks[3]<level>, 2,
    'second heading is level 2';

is @blocks[3]<depth>, 1,
    'second heading depth is one';

is @blocks[4]<type>, 'paragraph',
    'paragraph follows second heading';

is @blocks[4]<depth>, 1,
    'paragraph inherits second heading depth';

is @blocks[5]<type>, 'code',
    'code follows second paragraph';

is @blocks[5]<depth>, 1,
    'code inherits second heading depth';

is @blocks[5]<text>, 'say "second";',
    'second code text is preserved';

is @blocks[6]<type>, 'heading',
    'third heading follows second code block';

is @blocks[6]<level>, 1,
    'third heading returns to level 1';

is @blocks[6]<depth>, 0,
    'third heading resets depth to zero';

is @blocks[7]<type>, 'paragraph',
    'final paragraph follows third heading';

is @blocks[7]<depth>, 0,
    'final paragraph inherits reset heading depth';

done-testing;
