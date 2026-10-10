use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-realistic-document-$*PID.raku"
);

LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
use v6.d;

my $before = 1;

=begin pod

=TITLE App::Example

=SUBTITLE Example RakuDoc document

=head1 NAME

App::Example

=head1 DESCRIPTION

This is the first description paragraph.

=item First item

=begin code
say "explicit";
if True {
    say "nested";
}
=end code

=head2 DETAILS

This paragraph is under DETAILS.

    say "implicit";

=page-break

=head1 SECOND PAGE

Content after the page break.

=slide

=head1 FINAL

Final paragraph.

=end pod

my $after = 2;
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 17,
    'realistic embedded RakuDoc produces seventeen supported blocks';

my @types = @blocks.map(*<type>).Array;

is-deeply(
    @types,
    [
        'title',
        'subtitle',
        'heading',
        'paragraph',
        'heading',
        'paragraph',
        'item',
        'code',
        'heading',
        'paragraph',
        'code',
        'page-break',
        'heading',
        'paragraph',
        'slide',
        'heading',
        'paragraph',
    ],
    'supported blocks are produced in document order'
);

is @blocks[0]<text>, 'App::Example',
    'title text is preserved';

is @blocks[1]<text>, 'Example RakuDoc document',
    'subtitle text is preserved';

is @blocks[2]<text>, 'NAME',
    'NAME heading is preserved';

is @blocks[3]<text>, 'App::Example',
    'NAME paragraph is preserved';

is @blocks[4]<text>, 'DESCRIPTION',
    'DESCRIPTION heading is preserved';

is @blocks[5]<text>, 'This is the first description paragraph.',
    'description paragraph is preserved';

is @blocks[6]<type>, 'item',
    'item is preserved';

is @blocks[6]<text>, 'First item',
    'item text is preserved';

is @blocks[6]<depth>, 1,
    'item depth is one greater than head1 depth';

my Str $explicit-code = q:to/CODE/.chomp;
say "explicit";
if True {
    say "nested";
}
CODE

is @blocks[7]<text>, $explicit-code,
    'explicit code preserves relative indentation';

is @blocks[8]<level>, 2,
    'DETAILS heading is level 2';

is @blocks[8]<depth>, 1,
    'DETAILS heading depth is one';

is @blocks[9]<depth>, 1,
    'paragraph under DETAILS inherits depth one';

is @blocks[10]<type>, 'code',
    'implicit code is normalized to code';

is @blocks[10]<text>, 'say "implicit";',
    'implicit code text is preserved';

is @blocks[10]<depth>, 1,
    'implicit code inherits current heading depth';

is @blocks[11]<type>, 'page-break',
    'page-break directive is preserved';

is @blocks[12]<text>, 'SECOND PAGE',
    'heading after page break is preserved';

is @blocks[12]<depth>, 0,
    'head1 after page break resets depth to zero';

is @blocks[13]<text>, 'Content after the page break.',
    'paragraph after page break is preserved';

is @blocks[14]<type>, 'slide',
    'slide directive is preserved';

is @blocks[15]<text>, 'FINAL',
'final heading is preserved';

is @blocks[16]<text>, 'Final paragraph.',
    'final paragraph is preserved';

is @blocks[16]<depth>, 0,
    'final paragraph inherits final head1 depth';

is-deeply(
    @blocks.map(*<seq>).Array,
    [1 .. @blocks.elems],
    'sequence numbers are contiguous'
);

done-testing;
