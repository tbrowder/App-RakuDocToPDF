use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-code-normalization-$*PID.raku"
);

LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
use v6.d;

=begin pod

=head1 CODE

=begin code
say "hello";
=end code

    say "hello";

=end pod
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 3,
    'heading plus explicit and implicit code produce three blocks';

is @blocks[0]<type>, 'heading',
    'first block is a heading';

is @blocks[0]<text>, 'CODE',
    'heading text is preserved';

is @blocks[1]<type>, 'code',
    'explicit code is normalized to code';

is @blocks[2]<type>, 'code',
    'implicit code is normalized to code';

is @blocks[1]<text>, 'say "hello";',
    'explicit code text is preserved';

is @blocks[2]<text>, 'say "hello";',
    'implicit code text is preserved';

is @blocks[1]<text>, @blocks[2]<text>,
    'explicit and implicit code normalize to the same text';

is @blocks[1]<depth>, 0,
    'explicit code inherits heading depth';

is @blocks[2]<depth>, 0,
    'implicit code inherits heading depth';

done-testing;
