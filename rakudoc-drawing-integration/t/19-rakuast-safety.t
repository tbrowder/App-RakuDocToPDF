use v6.d;

use Test;
use experimental :rakuast;

use App::RakuDocToPDF::RakuASTReader;

my $source-file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-safety-$*PID.rakumod"
);

my $sentinel-file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-sentinel-$*PID.txt"
);

LEAVE {
    $source-file.unlink if $source-file.e;
    $sentinel-file.unlink if $sentinel-file.e;
}

$sentinel-file.unlink if $sentinel-file.e;

my Str $source = q:to/END/;
use v6.d;

unit module RakuASTSafetyTest;

BEGIN {
    '__SENTINEL__'.IO.spurt("BEGIN executed\n");
}

=begin pod

=head1 NAME

RakuAST Safety Test

=head1 DESCRIPTION

This documentation should be available without executing the module.

=end pod
END

$source = $source.subst(
    '__SENTINEL__',
    $sentinel-file.Str,
);

$source-file.spurt($source);

ok !$sentinel-file.e,
    'sentinel does not exist before RakuAST parsing';

my $ast;

lives-ok {
    $ast = read-rakuast($source-file);
}, 'RakuAST parsing completes';

ok $ast.defined,
    'RakuAST tree is defined';

ok $sentinel-file.e,
    'BEGIN block executes while obtaining RakuAST';

done-testing;
