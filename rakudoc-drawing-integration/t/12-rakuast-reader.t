use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

use experimental :rakuast;

plan 4;

my $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-{$*PID}.rakumod"
);

LEAVE {
    $file.unlink if $file.e;
}

# new ----------------
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
# end new ----------------

my $ast = read-rakuast($file);

isa-ok $ast, RakuAST::StatementList,
    'RakuDoc source produces a RakuAST::StatementList';

ok $ast.defined,
    'RakuAST tree is defined';

ok $ast.raku.chars,
    'RakuAST tree has a Raku representation';

say "\n--- RakuAST tree ---";
say $ast.raku;
say "--- end RakuAST tree ---\n";

ok $ast.raku.contains('RakuAST::Doc'),
    'RakuAST tree contains documentation nodes';
