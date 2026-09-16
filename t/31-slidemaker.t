use v6.d;

use Test;

use App::RakuDocToPDF::SlideMaker;

my @blocks = (
    {
        seq   => 1,
        depth => 0,
        type  => 'title',
        text  => 'App::RakuDocToPDF',
    },
    {
        seq   => 2,
        depth => 0,
        type  => 'subtitle',
        text  => 'Creating PDFs and Slides from RakuDoc',
    },
    {
        seq   => 3,
        depth => 0,
        type  => 'slide',
        text  => '',
    },
    {
        seq   => 4,
        depth => 0,
        type  => 'heading',
        level => 1,
        text  => 'RakuAST',
    },
    {
        seq   => 5,
        depth => 0,
        type  => 'paragraph',
        text  => 'RakuDoc is parsed using RakuAST.',
    },
    {
        seq   => 6,
        depth => 1,
        type  => 'item',
        text  => 'Structured parsing',
    },
    {
        seq   => 7,
        depth => 0,
        type  => 'slide',
        text  => '',
    },
    {
        seq   => 8,
        depth => 0,
        type  => 'heading',
        level => 1,
        text  => 'PDF Generation',
    },
    {
        seq   => 9,
        depth => 0,
        type  => 'paragraph',
        text  => 'The same linear representation feeds the PDF renderer.',
    },
);

my $deck = make-slides(@blocks);

is $deck<presentation><title>,
    'App::RakuDocToPDF',
    'presentation title is preserved';

is $deck<presentation><subtitle>,
    'Creating PDFs and Slides from RakuDoc',
    'presentation subtitle is preserved';

is $deck<slides>.elems,
    2,
    'two slides are produced';

is $deck<slides>[0]<number>,
    1,
    'first slide is numbered 1';

is $deck<slides>[1]<number>,
    2,
    'second slide is numbered 2';

is $deck<slides>[0]<blocks>.elems,
    3,
    'first slide contains three blocks';

is $deck<slides>[0]<blocks>[0]<type>,
    'heading',
    'first slide starts with heading';

is $deck<slides>[0]<blocks>[0]<text>,
    'RakuAST',
    'first slide heading text is preserved';

is $deck<slides>[0]<blocks>[1]<type>,
    'paragraph',
    'paragraph belongs to first slide';

is $deck<slides>[0]<blocks>[2]<type>,
    'item',
    'item belongs to first slide';

is $deck<slides>[1]<blocks>.elems,
    2,
    'second slide contains two blocks';

is $deck<slides>[1]<blocks>[0]<text>,
    'PDF Generation',
    'second slide heading is preserved';

is $deck<slides>[1]<blocks>[1]<text>,
    'The same linear representation feeds the PDF renderer.',
    'second slide paragraph is preserved';

done-testing;
