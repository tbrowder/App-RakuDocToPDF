use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-unsupported-blocks-$*PID.raku"
);

LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
use v6.d;

=begin pod

=head1 NAME

Before unsupported block.

=begin note
This block type is valid RakuDoc but is not supported
by App::RakuDocToPDF Release 2.
=end note

After unsupported block.

=head1 END

Final paragraph.

=end pod
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 5,
    'unsupported block is ignored without disturbing supported content';

is @blocks[0]<type>, 'heading',
    'first block is a heading';

is @blocks[0]<text>, 'NAME',
    'first heading text is preserved';

is @blocks[1]<type>, 'paragraph',
    'paragraph before unsupported block is preserved';

is @blocks[1]<text>, 'Before unsupported block.',
    'text before unsupported block is preserved';

is @blocks[2]<type>, 'paragraph',
    'paragraph after unsupported block is preserved';

is @blocks[2]<text>, 'After unsupported block.',
    'text after unsupported block is preserved';

is @blocks[3]<type>, 'heading',
    'heading after unsupported block is preserved';

is @blocks[3]<text>, 'END',
    'second heading text is preserved';

is @blocks[4]<type>, 'paragraph',
    'final paragraph is preserved';

is @blocks[4]<text>, 'Final paragraph.',
    'final paragraph text is preserved';

is-deeply(
    @blocks.map(*<seq>).Array,
    [1, 2, 3, 4, 5],
    'sequence numbers remain contiguous'
);

done-testing;
