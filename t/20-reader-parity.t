use v6.d;

use Test;
use experimental :rakuast;

use App::RakuDocToPDF::Reader;
use App::RakuDocToPDF::RakuASTReader;

my $file = $*TMPDIR.add(
    "rakudoc2pdf-reader-parity-$*PID.rakumod"
);

LEAVE {
    $file.unlink if $file.e;
}

$file.spurt: q:to/END/;
=begin pod

=head1 NAME

Reader Parity Test

=head2 DESCRIPTION

This is a paragraph under a second-level heading.

=item First item

=item Second item

=begin code
if $ready {
    say "ready";
    if $more {
        say "more";
    }
}
=end code

=page-break

=head1 SECOND PAGE

Final paragraph.

=end pod
END

my @old-blocks = read-rakudoc($file);

my $ast = read-rakuast($file);
my @new-blocks = linearize-rakudoc($ast);

is @new-blocks.elems, @old-blocks.elems,
    'old and RakuAST readers produce the same number of blocks';

is-deeply @new-blocks, @old-blocks,
    'RakuAST reader produces the same linear blocks as the old reader';

done-testing;
