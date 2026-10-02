use v6.d;

use App::RakuDocToPDF;

my IO::Path $here = $?FILE.IO.parent;

rakudoc-to-pdf(
    $here.add('why-linux.rakudoc'),
    :output($here.add('why-linux.pdf')),
    :style<slides>,
);
