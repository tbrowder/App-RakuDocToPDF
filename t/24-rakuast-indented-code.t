use v6.d;

use Test;

use App::RakuDocToPDF::RakuASTReader;

my IO::Path $file = $*TMPDIR.add(
    "rakudoc2pdf-rakuast-indented-code-$*PID.raku"
);

LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
use v6.d;

my $before = 1;

=begin pod

This ordinary paragraph introduces a code block:

    $this = 1 * code('block');
    $which.is_specified(:by<indenting>);

    $which.spans(:newlines);

=end pod

my $after = 2;
END

my @blocks = read-rakudoc-rakuast($file);

is @blocks.elems, 2,
    'paragraph and indented code produce two blocks';

is @blocks[0]<type>, 'paragraph',
    'first block is a paragraph';

is @blocks[0]<text>,
    'This ordinary paragraph introduces a code block:',
    'paragraph text is preserved';

is @blocks[1]<type>, 'code',
    'indented text becomes a code block';

my Str $expected-code =
    "\$this = 1 * code('block');\n"
    ~ "\$which.is_specified(:by<indenting>);\n"
    ~ "\n"
    ~ "\$which.spans(:newlines);";

is @blocks[1]<text>, $expected-code,
    'indented code contents and internal blank line are preserved';

done-testing;
