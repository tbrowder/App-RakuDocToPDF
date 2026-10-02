use v6.d;

use App::RakuDocToPDF;

my IO::Path $here = $?FILE.IO.parent;
my IO::Path $top  = $here.parent.parent;

my IO::Path $input = $here.add('why-linux.rakudoc');
my IO::Path $output = $top.add('why-linux.pdf');

rakudoc-to-pdf(
    $input,
    :$output,
    :style<slides>,
);

say "Created: $output";

=finish

my IO::Path $here = $?FILE.IO.parent;

rakudoc-to-pdf(
    $here.add('why-linux.rakudoc'),
    :output($here.add('why-linux.pdf')),
    :style<slides>,
);
