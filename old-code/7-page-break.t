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

is @pages.elems, 2, '=page-break starts a new page';
is @pages[0][0]<text>, 'FIRST', 'first heading is on page one';
is @pages[1][0]<text>, 'SECOND', 'second heading is on page two';

done-testing;
