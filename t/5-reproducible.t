use v6.d;
use Test;

use App::RakuDocToPDF;

my IO::Path $source = $*TMPDIR.add("rakudoc-repro-{$*PID}.rakudoc");
my IO::Path $first = $*TMPDIR.add("rakudoc-repro-first-{$*PID}.pdf");
my IO::Path $second = $*TMPDIR.add("rakudoc-repro-second-{$*PID}.pdf");
my IO::Path $changed = $*TMPDIR.add("rakudoc-repro-changed-{$*PID}.pdf");

LEAVE unlink $source if $source.e;
LEAVE unlink $first if $first.e;
LEAVE unlink $second if $second.e;
LEAVE unlink $changed if $changed.e;

spurt $source, q:to/END/;
=begin pod

=head1 REPRODUCIBLE PDF

Identical input should produce identical PDF bytes.

=end pod
END

rakudoc-to-pdf(
    $source,
    :output($first),
    :media<Letter>,
);

rakudoc-to-pdf(
    $source,
    :output($second),
    :media<Letter>,
);

spurt $source, q:to/END/;
=begin pod

=head1 REPRODUCIBLE PDF

This text has changed.

=end pod
END

rakudoc-to-pdf(
    $source,
    :output($changed),
    :media<Letter>,
);

plan 5;

ok $first.e, 'first PDF created';
ok $second.e, 'second PDF created';
is-deeply $first.slurp(:bin), $second.slurp(:bin),
    'identical input produces identical PDF bytes';
ok $changed.e, 'changed-input PDF created';
isnt-deeply $first.slurp(:bin), $changed.slurp(:bin),
    'changed input produces different PDF bytes';
