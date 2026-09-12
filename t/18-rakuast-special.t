use v6.d;

use Test;
use experimental :rakuast;

use App::RakuDocToPDF::RakuASTReader;

my $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-special-linear-$*PID.rakumod"
);

LEAVE {
    $file.unlink if $file.e;
}

$file.spurt: q:to/END/;
use v6.d;

unit module RakuASTSpecialTest;

=begin pod

=TITLE Example Document

=SUBTITLE Example Subtitle

=head1 NAME

Example Document

=page-break

=head1 SECOND PAGE

Second page text.

=slide

=head1 SLIDE TITLE

Slide text.

=end pod
END

my $ast = read-rakuast($file);
my @blocks = linearize-rakudoc($ast);

is @blocks.elems, 10,
    'eleven linear blocks are produced';

is-deeply @blocks[0], {
    seq   => 1,
    depth => 0,
    type  => 'title',
    text  => 'Example Document',
}, 'TITLE becomes a title block';

is-deeply @blocks[1], {
    seq   => 2,
    depth => 0,
    type  => 'subtitle',
    text  => 'Example Subtitle',
}, 'SUBTITLE becomes a subtitle block';

is-deeply @blocks[2], {
    seq   => 3,
    depth => 0,
    type  => 'heading',
    text  => 'NAME',
    level => 1,
}, 'NAME heading is preserved';

is-deeply @blocks[3], {
    seq   => 4,
    depth => 0,
    type  => 'paragraph',
    text  => 'Example Document',
}, 'paragraph before page break is preserved';

is-deeply @blocks[4], {
    seq   => 5,
    depth => 0,
    type  => 'page-break',
    text  => '',
}, 'page-break becomes a standalone block';

is-deeply @blocks[5], {
    seq   => 6,
    depth => 0,
    type  => 'heading',
    text  => 'SECOND PAGE',
    level => 1,
}, 'heading after page break is preserved';

is-deeply @blocks[6], {
    seq   => 7,
    depth => 0,
    type  => 'paragraph',
    text  => 'Second page text.',
}, 'paragraph after page break is preserved';

is-deeply @blocks[7], {
    seq   => 8,
    depth => 0,
    type  => 'slide',
    text  => '',
}, 'slide becomes a standalone block';

is-deeply @blocks[8], {
    seq   => 9,
    depth => 0,
    type  => 'heading',
    text  => 'SLIDE TITLE',
    level => 1,
}, 'slide heading is preserved';

is-deeply @blocks[9], {
    seq   => 10,
    depth => 0,
    type  => 'paragraph',
    text  => 'Slide text.',
}, 'slide paragraph is preserved';

done-testing;
