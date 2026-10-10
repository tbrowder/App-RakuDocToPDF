use Test;
use App::RakuDocToPDF::Drawing::Parser;
use App::RakuDocToPDF::Drawing::Renderer;

my $source = q:to/END/;
page media=Letter orientation=landscape margin=0.5in
grid columns=11 line-width=0.75pt
rows 1in 1in repeat=0.375in fill
END

my $spec = parse-drawing($source);

my $file = 'tmp-cpap-grid.pdf';

#LEAVE unlink $file if $file.IO.e;

render-drawing(
    $spec,
    :output($file),
);

ok $file.IO.e, 'PDF file created';
ok $file.IO.s > 0, 'PDF file is not empty';

say "See new pdf: '$file'";

done-testing;
