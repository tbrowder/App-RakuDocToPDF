use v6.d;
use Test;

use PDF::API6;
use PDF::Content::FontObj;

use App::RakuDocToPDF::Layout;
use App::RakuDocToPDF::Reader;

my $file = $*TMPDIR.add("rakudoc2pdf-page-break-$*PID.rakudoc");
LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
=begin pod

=head1 FIRST

This paragraph belongs on the first page.

=page-break

=head1 SECOND

This paragraph belongs on the second page.

=end pod
END

my @blocks = read-rakudoc($file);
is @blocks[2]<type>, 'page-break', '=page-break is retained in linear form';

my PDF::API6 $pdf .= new;
my %fonts = (
    body    => $pdf.core-font('Times-Roman'),
    heading => $pdf.core-font: :family<Helvetica>, :weight<bold>,
    code    => $pdf.core-font('Courier'),
    footer  => $pdf.core-font('Helvetica'),
);

my @pages = layout-pages(
    @blocks,
    %fonts,
    :page-width(612),
    :page-height(792),
);

my $found-before = False;
my $found-after  = False;

for @pages.kv -> $page-number, @page {
    for @page -> %line {
        if %line<text> eq 'Before the break.' {
            $found-before = $page-number == 0;
        }

        if %line<text> eq 'After the break.' {
            $found-after = $page-number == 1;
        }
    }
}

ok $found-before,
    'text before page break is on first page';

ok $found-after,
'text after page break is on second page';


done-testing;
=finish

my Bool $first-found = False;
my Bool $second-found = False;

for @pages[0] -> %line {
    if %line<text> eq 'FIRST' {
        $first-found = True;
        last;
    }
}

for @pages[1] -> %line {
    if %line<text> eq 'SECOND' {
        $second-found = True;
        last;
    }
}

is @pages.elems, 2, '=page-break starts a new page';
ok $first-found, 'first heading is on page one';
ok $second-found, 'second heading is on page two';

done-testing;
