use Test;

use App::RakuDocToPDF::Drawing::Layout;
use App::RakuDocToPDF::Drawing::Parser;

my $source = q:to/END/;
page media=Letter orientation=landscape margin=0.5in
grid columns=11 line-width=0.75pt
rows 1in 1in repeat=0.375in fill
END

my $spec = parse-drawing($source);

my ($width, $height) =
    page-size($spec.page);

is $width, 792,
    'Letter landscape width';

is $height, 612,
    'Letter landscape height';

is $spec.page.margin, 36,
    'half-inch margin';

is $spec.grid.columns, 11,
    'eleven columns';

is $spec.grid.line-width, 0.75,
    '0.75 point line width';

my @vertical =
    vertical-rules($spec);

is @vertical.elems, 10,
    'eleven columns require ten internal rules';

my @horizontal =
    horizontal-rules($spec);

is @horizontal[0], 504,
    'first one-inch row';

is @horizontal[1], 432,
    'second one-inch row';

is @horizontal[2], 405,
    'subsequent rules are 3/8 inch apart';

is @horizontal[3], 378,
    'second repeated rule is correct';

done-testing;
