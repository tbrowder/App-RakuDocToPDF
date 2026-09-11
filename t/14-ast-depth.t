use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-depth-$*PID.rakumod"
);

LEAVE {
    $file.unlink if $file.e;
}

$file.spurt: q:to/END/;
use v6.d;

unit module RakuASTDepthTest;

=begin pod

=head1 NAME

RakuAST Depth Test

=head2 SECOND LEVEL

Second-level paragraph.

=head3 THIRD LEVEL

Third-level paragraph.

=head2 ANOTHER SECOND LEVEL

Another second-level paragraph.

=end pod
END

my $ast = read-rakuast($file);
my @blocks = linearize-rakudoc($ast);

is @blocks.elems, 8,
    'eight linear blocks are produced';

is-deeply @blocks[0], {
    seq   => 1,
    depth => 0,
    type  => 'heading',
    text  => 'NAME',
    level => 1,
}, 'head1 has depth zero';

is-deeply @blocks[1], {
    seq   => 2,
    depth => 0,
    type  => 'paragraph',
    text  => 'RakuAST Depth Test',
}, 'paragraph under head1 has depth zero';

is-deeply @blocks[2], {
    seq   => 3,
    depth => 1,
    type  => 'heading',
    text  => 'SECOND LEVEL',
    level => 2,
}, 'head2 has depth one';

is-deeply @blocks[3], {
    seq   => 4,
    depth => 1,
    type  => 'paragraph',
    text  => 'Second-level paragraph.',
}, 'paragraph under head2 has depth one';

is-deeply @blocks[4], {
    seq   => 5,
    depth => 2,
    type  => 'heading',
    text  => 'THIRD LEVEL',
    level => 3,
}, 'head3 has depth two';

is-deeply @blocks[5], {
    seq   => 6,
    depth => 2,
    type  => 'paragraph',
    text  => 'Third-level paragraph.',
}, 'paragraph under head3 has depth two';

is-deeply @blocks[6], {
    seq   => 7,
    depth => 1,
    type  => 'heading',
    text  => 'ANOTHER SECOND LEVEL',
    level => 2,
}, 'returning to head2 restores depth one';

is-deeply @blocks[7], {
    seq   => 8,
    depth => 1,
    type  => 'paragraph',
    text  => 'Another second-level paragraph.',
}, 'following paragraph uses restored head2 depth';

done-testing;
