use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;
use App::RakuDocToPDF::SlideMaker;

my IO::Path $input = $*TMPDIR.add(
    "rakudoc2pdf-slidemaker-$*PID.rakudoc"
);

LEAVE {
    $input.unlink if $input.e;
}

$input.spurt: q:to/END/;
=begin pod

=TITLE App::RakuDocToPDF

=SUBTITLE Creating PDFs and Slides from RakuDoc

=slide

=head1 RakuAST

RakuDoc is parsed using RakuAST.

=item Structured parsing

=begin code
say "explicit";
if True {
    say "nested";
}
=end code

=slide

=head1 PDF Generation

The same linear representation feeds the PDF renderer.

    say "implicit";

=end pod
END

my @blocks = read-rakudoc-rakuast($input);

ok @blocks.elems,
    'RakuAST reader produces linear blocks';

my $deck = make-slides(@blocks);

is $deck<presentation><title>,
    'App::RakuDocToPDF',
    'presentation title comes through RakuAST';

is $deck<presentation><subtitle>,
    'Creating PDFs and Slides from RakuDoc',
    'presentation subtitle comes through RakuAST';

is $deck<slides>.elems,
    2,
    'two slides are produced';

my $slide1 = $deck<slides>[0];
my $slide2 = $deck<slides>[1];

is $slide1<number>,
    1,
    'first slide is numbered 1';

is $slide2<number>,
    2,
    'second slide is numbered 2';

is $slide1<blocks>.elems,
    4,
    'first slide contains four content blocks';

is-deeply $slide1<blocks>.map(*<type>).Array,
    [
        'heading',
        'paragraph',
        'item',
        'code',
    ],
    'first slide has expected block types';

is $slide1<blocks>[0]<text>,
    'RakuAST',
    'first slide heading is preserved';

is $slide1<blocks>[1]<text>,
    'RakuDoc is parsed using RakuAST.',
    'first slide paragraph is preserved';

is $slide1<blocks>[2]<text>,
    'Structured parsing',
    'first slide item is preserved';

my Str $explicit-code = q:to/CODE/.chomp;
say "explicit";
if True {
    say "nested";
}
CODE

is $slide1<blocks>[3]<text>,
    $explicit-code,
    'explicit code and relative indentation are preserved';

is $slide2<blocks>.elems,
    3,
    'second slide contains three content blocks';

is-deeply $slide2<blocks>.map(*<type>).Array,
    [
        'heading',
        'paragraph',
        'code',
    ],
    'second slide has expected block types';

is $slide2<blocks>[0]<text>,
    'PDF Generation',
    'second slide heading is preserved';

is $slide2<blocks>[1]<text>,
    'The same linear representation feeds the PDF renderer.',
    'second slide paragraph is preserved';

is $slide2<blocks>[2]<text>,
    'say "implicit";',
    'implicit code is preserved and normalized as code';

done-testing;
