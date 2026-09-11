use v6.d;

use Test;
use experimental :rakuast;

use App::RakuDocToPDF::RakuASTReader;

my $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-item-linear-$*PID.rakumod"
);

LEAVE {
    $file.unlink if $file.e;
}

$file.spurt: q:to/END/;
use v6.d;

unit module RakuASTItemTest;

=begin pod

=head1 ITEMS

=item First item

=item Second item

=head2 NESTED

=item Nested item

=end pod
END

my $ast = read-rakuast($file);
my @blocks = linearize-rakudoc($ast);

is @blocks.elems, 5,
    'five linear blocks are produced';

is-deeply @blocks[0], {
    seq   => 1,
    depth => 0,
    type  => 'heading',
    text  => 'ITEMS',
    level => 1,
}, 'head1 is linearized';

is-deeply @blocks[1], {
    seq   => 2,
    depth => 1,
    type  => 'item',
    text  => 'First item',
}, 'first item under head1 has depth one';

is-deeply @blocks[2], {
    seq   => 3,
    depth => 1,
    type  => 'item',
    text  => 'Second item',
}, 'second item under head1 has depth one';

is-deeply @blocks[3], {
    seq   => 4,
    depth => 1,
    type  => 'heading',
    text  => 'NESTED',
    level => 2,
}, 'head2 has depth one';

is-deeply @blocks[4], {
    seq   => 5,
    depth => 2,
    type  => 'item',
    text  => 'Nested item',
}, 'item under head2 has depth two';

done-testing;
