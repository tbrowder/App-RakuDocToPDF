use v6.d;

use Test;

my $debug = 0;

use App::RakuDocToPDF;

my IO::Path $source = $*TMPDIR.add(
    "rakudoc-slide-integration-$*PID.rakudoc"
);
my IO::Path $output = $*TMPDIR.add(
    "rakudoc-slide-integration-$*PID.pdf"
);

LEAVE {
    $source.unlink if $source.e;
    $output.unlink if $output.e;
}

$source.spurt: q:to/END/;
=begin pod

=TITLE Integration Test

=slide

=head1 First Slide

This is the first slide.

=item First item

=slide

=head1 Second Slide

This is the second slide.

=end pod
END

my IO::Path $result = rakudoc-to-pdf(
    $source,
    :$output,
    :style<slides>,
);

plan 5;

is $result.Str, $output.Str,
    'slide style returns requested output path';
ok $output.e,
    'slide-style PDF was created';
ok $output.s > 100,
    'slide-style PDF is not empty';
is $output.slurp(:bin).subbuf(0, 5).decode, '%PDF-',
    'slide-style output has PDF signature';
throws-like {
    rakudoc-to-pdf(
        $source,
        :output($output),
        :style<unknown>,
    );
}, X::AdHoc,
    message => / "Unknown PDF style 'unknown'" /,
    'unknown style is rejected';
