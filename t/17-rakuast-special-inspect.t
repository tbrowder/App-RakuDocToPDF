use v6.d;

use Test;
use experimental :rakuast;

use App::RakuDocToPDF::RakuASTReader;

my $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-special-$*PID.rakumod"
);

LEAVE {
    $file.unlink if $file.e;
}

$file.spurt: q:to/END/;
use v6.d;

unit module RakuASTSpecialTest;

=begin pod

=TITLE Example Document

=SUBTITLE Example Subtitle

=head1 NAME

Example Document

=page-break

=head1 SECOND PAGE

Second page text.

=slide

=head1 SLIDE TITLE

Slide text.

=end pod
END

my $ast = read-rakuast($file);

isa-ok $ast,
    RakuAST::StatementList,
    'special-directive source produces a RakuAST::StatementList';

ok $ast.defined,
    'RakuAST tree is defined';

diag "\n--- special-directive RakuAST tree ---";
diag $ast.raku;
diag "--- end special-directive RakuAST tree ---\n";

ok $ast.raku.contains('RakuAST::Doc'),
    'RakuAST tree contains documentation nodes';

done-testing;
