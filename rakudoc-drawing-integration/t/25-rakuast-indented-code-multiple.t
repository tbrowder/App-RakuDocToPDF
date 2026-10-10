use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-indented-code-multiple-$*PID.raku"
);

LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
use v6.d;

my $before = 1;

=begin pod

Fun comes

    This is code
  Ha, what now?

 one more block of code
 just to make sure it works
  or better: maybe it'll break!

=end pod

my $after = 2;
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 4,
    'paragraph and three differently indented code blocks are produced';

is @blocks[0]<type>, 'paragraph',
    'first block is a paragraph';

is @blocks[0]<text>, 'Fun comes',
    'paragraph text is preserved';

is @blocks[1]<type>, 'code',
    'first indented block is code';

is @blocks[1]<text>, 'This is code',
    'first code block text is preserved';

is @blocks[2]<type>, 'code',
    'second indented block is code';

is @blocks[2]<text>, 'Ha, what now?',
    'second code block text is preserved';

is @blocks[3]<type>, 'code',
    'third indented block is code';

my Str $expected-code =
    "one more block of code\n"
    ~ "just to make sure it works\n"
    ~ " or better: maybe it'll break!";

is @blocks[3]<text>, $expected-code,
    'third code block preserves relative indentation';

done-testing;
