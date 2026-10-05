use v6.d;

use Test;

use App::RakuDocToPDF::Drawing::Parser;

my $source = q:to/END/;
page media=Letter orientation=landscape margin=0.5in
grid columns=11 line-width=0.75pt
rows 1in 1in repeat=0.375in fill

row-labels 2
Date
How I Feel
Sleep Score
Time Asleep
Time Awake
REM Time
Core Time
Deep Sleep
Score
Usage
Events
end-row-labels
END

my $spec = parse-drawing($source);

plan 6;

is $spec.grid.row-labels.elems, 1,
    'one row-labels block parsed';

is $spec.grid.row-labels[0].row, 2,
    'row-labels target row 2';

is $spec.grid.row-labels[0].labels.elems, 11,
    'eleven labels parsed';

is $spec.grid.row-labels[0].labels[0], 'Date',
    'first label parsed';

is $spec.grid.row-labels[0].labels[1], 'How I Feel',
    'second label parsed';

is $spec.grid.row-labels[0].labels[*-1], 'Events',
    'last label parsed';
