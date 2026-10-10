use v6.d;

use Test;
use experimental :rakuast;

use App::RakuDocToPDF::RakuASTReader;

my $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-item-$*PID.rakumod"
);

LEAVE {
    $file.unlink if $file.e;
}

$file.spurt: q:to/END/;
use v6.d;

unit module RakuASTItemTest;

=begin pod

=head1 ITEMS

=item First item

=item Second item

=head2 NESTED

=item Nested item

=end pod
END

my $ast = read-rakuast($file);

isa-ok $ast,
    RakuAST::StatementList,
    'item test source produces a RakuAST::StatementList';

ok $ast.defined,
    'RakuAST tree is defined';

diag "\n--- item RakuAST tree ---";
diag $ast.raku;
diag "--- end item RakuAST tree ---\n";

ok $ast.raku.contains('RakuAST::Doc'),
    'RakuAST tree contains documentation nodes';

done-testing;
