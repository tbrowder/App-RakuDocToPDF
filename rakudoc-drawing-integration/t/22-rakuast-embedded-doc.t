use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-embedded-$*PID.raku"
);

LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
use v6.d;

my $before = 42;

=begin pod

=head1 NAME

Embedded RakuDoc Test

=head1 DESCRIPTION

This documentation is embedded in ordinary Raku source.

someone accidentally left a space

between these two paragraphs

=end pod

my $after = 24;
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 6,
    'embedded RakuDoc produces six blocks';

is @blocks[0]<type>, 'heading',
    'first block is NAME heading';

is @blocks[0]<text>, 'NAME',
    'NAME heading text is preserved';

is @blocks[1]<text>, 'Embedded RakuDoc Test',
    'NAME paragraph is preserved';

is @blocks[2]<type>, 'heading',
    'DESCRIPTION is a heading';

is @blocks[2]<text>, 'DESCRIPTION',
    'DESCRIPTION heading text is preserved';

is @blocks[3]<text>,
    'This documentation is embedded in ordinary Raku source.',
    'DESCRIPTION paragraph is preserved';

is @blocks[4]<text>,
    'someone accidentally left a space',
    'first paragraph around whitespace-only separator is preserved';

is @blocks[5]<text>,
    'between these two paragraphs',
    'second paragraph around whitespace-only separator is preserved';

done-testing;
