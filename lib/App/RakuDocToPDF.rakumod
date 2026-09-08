use v6.d;

unit module App::RakuDocToPDF;

use PDF::API6;
use PDF::Content::FontObj;
use PDF::Page;

use App::RakuDocToPDF::Layout;
use App::RakuDocToPDF::Media;
use App::RakuDocToPDF::Reader;

sub rakudoc-to-pdf(
    $input,
    :$output,
    :$media = 'Letter',
    --> IO::Path
) is export {
    my IO::Path $source = $input.IO;
    die "RakuDoc file '$source' does not exist." unless $source.e;

    my IO::Path $destination;
    if $output.defined {
        $destination = $output.IO;
    }
    else {
        my Str $basename = $source.basename;
        if $basename.ends-with('.rakudoc') {
            $basename = $basename.substr(0, $basename.chars - 8);
        }
        $destination = $source.parent.add("$basename.pdf");
    }

    my @box = media-box($media);
    my Numeric $width = media-width($media);
    my Numeric $height = media-height($media);

    my PDF::API6 $pdf .= new;
    my PDF::Content::FontObj $body-font = $pdf.core-font('Times-Roman');
    my PDF::Content::FontObj $heading-font = $pdf.core-font: :family<Helvetica>, :weight<bold>;
    my PDF::Content::FontObj $code-font = $pdf.core-font('Courier');
    my PDF::Content::FontObj $footer-font = $pdf.core-font('Helvetica');

    my %fonts = (
        body    => $body-font,
        heading => $heading-font,
        code    => $code-font,
        footer  => $footer-font,
    );

    my @blocks = read-rakudoc($source);
    my @pages = layout-pages(
        @blocks,
        %fonts,
        :page-width($width),
        :page-height($height),
    );

    my Int $total-pages = @pages.elems;
    my Int $number = 0;

    for @pages -> @lines {
        $number++;
        my PDF::Page $page = $pdf.add-page;
        $page.media-box = @box;

        $page.text: {
            for @lines -> %line {
                .font = %fonts{%line<font>}, %line<size>;
                .text-position = %line<x>, %line<y>;
                .say: %line<text>;
            }

            my Str $footer = "Page $number of $total-pages";
            my Numeric $footer-size = 9;
            my Numeric $footer-width = $footer-font.stringwidth(
                $footer,
                $footer-size,
            );
            my Numeric $footer-x = ($width - $footer-width) / 2;

            .font = $footer-font, $footer-size;
            .text-position = $footer-x, 24;
            .say: $footer;
        }
    }

    $pdf.save-as: $destination.Str;
    return $destination;
}

