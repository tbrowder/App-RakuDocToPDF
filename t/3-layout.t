use v6.d;
use Test;

use App::RakuDocToPDF::Layout;

class TestFont {
    method stringwidth(Str $text, Numeric $size --> Numeric) {
        return $text.chars * $size * 0.5;
    }
}

my $font = TestFont.new;
my @wrapped = wrap-text(
    'one two three four five',
    $font,
    10,
    45,
);

my %fonts = (
    body    => $font,
    heading => $font,
    code    => $font,
);

my @blocks;
for ^80 -> $n {
    @blocks.push: {
        type => 'paragraph',
        text => "Paragraph $n has enough words to consume vertical space.",
    };
}

my @pages = layout-pages(
    @blocks,
    %fonts,
    :page-width(612),
    :page-height(792),
);

plan 6;

ok @wrapped.elems > 1, 'text wraps to multiple lines';
ok @wrapped[0].chars, 'first wrapped line is nonempty';
ok @pages.elems > 1, 'content paginates to more than one page';
ok @pages[0].elems, 'first page contains render lines';
ok @pages[*-1].elems, 'last page contains render lines';
ok @pages[0][0]<y> <= 756, 'first line is inside top margin';
