use v6.d;

use Test;

use App::RakuDocToPDF;

my IO::Path $source = $*TMPDIR.add(
    "rakudoc-slide-repro-$*PID.rakudoc"
);
my IO::Path $first = $*TMPDIR.add(
    "rakudoc-slide-repro-first-$*PID.pdf"
);
my IO::Path $second = $*TMPDIR.add(
    "rakudoc-slide-repro-second-$*PID.pdf"
);

LEAVE {
    $source.unlink if $source.e;
    $first.unlink if $first.e;
    $second.unlink if $second.e;
}

$source.spurt: q:to/END/;
=begin pod

=slide

=head1 Reproducible Slide

Identical slide input should produce identical PDF bytes.

=end pod
END

rakudoc-to-pdf(
    $source,
    :output($first),
    :style<slides>,
);

rakudoc-to-pdf(
    $source,
    :output($second),
    :style<slides>,
);

plan 3;

ok $first.e,
    'first slide PDF created';
ok $second.e,
    'second slide PDF created';
is-deeply $first.slurp(:bin), $second.slurp(:bin),
    'identical slide input produces identical PDF bytes';
