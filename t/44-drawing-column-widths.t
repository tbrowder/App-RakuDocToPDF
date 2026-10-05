use v6.d;

use Test;

use App::RakuDocToPDF::Drawing::Layout;
use App::RakuDocToPDF::Drawing::Parser;

my $source = q:to/END/;
page media=Letter orientation=landscape margin=0.5in
grid line-width=0.75pt widths=1in,1in,1in,1in,1in,1in,1in,1in,1in,0.5in,0.5in
rows 1in 1in repeat=0.375in fill
END

my $spec = parse-drawing($source);
my @widths = column-widths($spec);
my @rules = vertical-rules($spec);

plan 6;

is $spec.grid.columns, 11,
    'width list defines eleven columns';

is @widths.elems, 11,
    'eleven explicit widths retained';

is @widths[0], 72,
    'first width is one inch';

is @widths[*-1], 36,
    'last width is half inch';

is @rules.elems, 10,
    'eleven columns have ten internal rules';

is @rules[0], 108,
    'first internal rule is one inch after left margin';
