use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-linear-$*PID.rakumod"
);

LEAVE {
    $file.unlink if $file.e;
}

$file.spurt: q:to/END/;
use v6.d;

unit module RakuASTTest;

=begin pod

=head1 NAME

RakuAST Test

=head1 DESCRIPTION

This is a test paragraph.

=begin code
if $ready {
    say "ready";
    if $more {
        say "more";
    }
}
=end code

=end pod
END

my $ast = read-rakuast($file);
my @blocks = linearize-rakudoc($ast);

is @blocks.elems, 5,
    'five linear blocks are produced';

is-deeply @blocks[0], {
    seq   => 1,
    depth => 0,
    type  => 'heading',
    text  => 'NAME',
    level => 1,
}, 'NAME heading is linearized';

is-deeply @blocks[1], {
    seq   => 2,
    depth => 0,
    type  => 'paragraph',
    text  => 'RakuAST Test',
}, 'NAME paragraph is linearized';

is-deeply @blocks[2], {
    seq   => 3,
    depth => 0,
    type  => 'heading',
    text  => 'DESCRIPTION',
    level => 1,
}, 'DESCRIPTION heading is linearized';

is-deeply @blocks[3], {
    seq   => 4,
    depth => 0,
    type  => 'paragraph',
    text  => 'This is a test paragraph.',
}, 'DESCRIPTION paragraph is linearized';

my Str $expected-code = (
    'if $ready {',
    '    say "ready";',
    '    if $more {',
    '        say "more";',
    '    }',
    '}',
).join("\n");

is-deeply @blocks[4], {
    seq   => 5,
    depth => 0,
    type  => 'code',
    text  => $expected-code,
}, 'code block is linearized with indentation preserved';

done-testing;
