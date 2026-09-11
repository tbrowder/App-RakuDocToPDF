use v6.d;

use Test;
use experimental :rakuast;

use App::RakuDocToPDF::RakuASTReader;

my $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-api-$*PID.rakudoc"
);

LEAVE {
    $file.unlink if $file.e;
}

$file.spurt: q:to/END/;
=begin pod

=head1 NAME

Reader API Test

=head1 DESCRIPTION

This exercises the complete RakuAST reader API.

=item One item

=page-break

=head1 NEXT

Final paragraph.

=end pod
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 8,
    'complete RakuAST reader API produces eight blocks';

is @blocks[0]<type>, 'heading',
    'first block is a heading';

is @blocks[1]<type>, 'paragraph',
    'second block is a paragraph';

is @blocks[2]<type>, 'heading',
    'DESCRIPTION block is a heading';

is @blocks[2]<text>, 'DESCRIPTION',
    'DESCRIPTION heading text is preserved';

is @blocks[3]<type>, 'paragraph',
    'DESCRIPTION text is a paragraph';

is @blocks[3]<text>,
    'This exercises the complete RakuAST reader API.',
    'DESCRIPTION paragraph text is preserved';

is @blocks[4]<type>, 'item',
    'item is preserved';

is @blocks[5]<type>, 'page-break',
    'page break is preserved';

is @blocks[6]<type>, 'heading',
    'NEXT block is a heading';

is @blocks[6]<text>, 'NEXT',
'NEXT heading text is preserved';

is @blocks[7]<type>, 'paragraph',
    'final block is a paragraph';

is @blocks[7]<text>, 'Final paragraph.',
    'final paragraph is preserved';

done-testing;
