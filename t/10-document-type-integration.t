use v6.d;
use Test;

use App::RakuDocToPDF;

my IO::Path $good = $*TMPDIR.add("rakudoc2pdf-type-good-$*PID.rakudoc");
my IO::Path $bad = $*TMPDIR.add("rakudoc2pdf-type-bad-$*PID.rakudoc");
my IO::Path $output = $*TMPDIR.add("rakudoc2pdf-type-good-$*PID.pdf");

LEAVE $good.unlink if $good.e;
LEAVE $bad.unlink if $bad.e;
LEAVE $output.unlink if $output.e;

$good.spurt: q:to/END/;
=begin pod
=TITLE App::Example
=SUBTITLE Example documentation
=head1 NAME
App::Example
=end pod
END

$bad.spurt: q:to/END/;
=begin pod
=head1 DESCRIPTION
This module README has no NAME section.
=end pod
END

my IO::Path $result = rakudoc-to-pdf(
    $good,
    :$output,
    :type<module-readme>,
);

is $result.Str, $output.Str, 'module-readme type generates a PDF when valid';
ok $output.e, 'valid module-readme PDF exists';

dies-ok {
    rakudoc-to-pdf(
        $bad,
        :type<module-readme>,
    );
}, 'invalid module-readme is rejected';

dies-ok {
    rakudoc-to-pdf(
        $good,
        :type<unknown>,
    );
}, 'unknown document type is rejected';

done-testing;
