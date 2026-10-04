use App::RakuDocToPDF::Drawing::Parser;
use App::RakuDocToPDF::Drawing::Renderer;

my $drawing = q:to/END/;
page media=Letter orientation=landscape margin=0.5in
grid columns=11 line-width=0.75pt
rows 1in 1in repeat=0.375in fill
END

my $spec = parse-drawing($drawing);

render-drawing(
    $spec,
    :output<cpap-event-log.pdf>,
);
