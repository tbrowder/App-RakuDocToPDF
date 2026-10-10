use v6.d;

use Test;

use App::RakuDocToPDF;
use App::RakuDocToPDF::RakuASTReader;

my IO::Path $source = 'examples/why-linux/why-linux.rakudoc'.IO;
my IO::Path $output = $*TMPDIR.add(
    "rakudoc2pdf-why-linux-$*PID.pdf"
);

LEAVE {
    $output.unlink if $output.e;
}

ok $source.e,
    'why-linux RakuDoc example exists';

my @blocks = read-rakudoc-rakuast($source);
my @images;

for @blocks -> $block {
    if ($block<type> // '') eq 'image' {
        @images.push: $block;
    }
}

is @images.elems,
    2,
    'why-linux example contains two image blocks';

is @images[0]<text>,
    'media/linux-command-line.png',
    'first image path is preserved';

is @images[1]<text>,
    'media/linux-windowed-programs.png',
    'second image path is preserved';

my IO::Path $result = rakudoc-to-pdf(
    $source,
    :output($output),
    :style<slides>,
);

ok $result.e,
    'why-linux slide PDF was created';

ok $result.s > 0,
    'why-linux slide PDF is not empty';

done-testing;
