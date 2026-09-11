use Test;

use App::RakuDocToPDF::Reader;

my $file = $*TMPDIR.add("rakudoc2pdf-code-whitespace-$*PID.rakudoc");
LEAVE $file.unlink if $file.e;

my @source = (
    '=begin pod',
    '',
    '=begin code',
    'if $ready {',
    '    say "ready";',
    '    if $more {',
    '        say "more";',
    '    }',
    '}',
    '=end code',
    '',
    '=end pod',
    '',
);

$file.spurt: @source.join("\n");

my @blocks = read-rakudoc($file);

is @blocks.elems, 1, 'one code block is read';
is @blocks[0]<type>, 'code', 'block type is code';
is @blocks[0]<text>, q:to/END/.chomp,
if $ready {
    say "ready";
    if $more {
        say "more";
    }
}
END
    'relative leading whitespace in code is preserved';

my @lines = @blocks[0]<text>.lines;
is @lines[1], '    say "ready";', 'four-space indentation is preserved';
is @lines[3], '        say "more";', 'eight-space indentation is preserved';

done-testing;
