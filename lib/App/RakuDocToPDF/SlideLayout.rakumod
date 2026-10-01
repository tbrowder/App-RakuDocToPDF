use v6.d;

unit module App::RakuDocToPDF::SlideLayout;

use PDF::API6;
use PDF::Content::FontObj;
use PDF::Page;

constant $SLIDE-WIDTH  = 792;
constant $SLIDE-HEIGHT = 612;

sub layout-slide(
    $slide,
    Numeric :$slide-height = $SLIDE-HEIGHT,
    Numeric :$margin-left = 54,
    Numeric :$margin-top = 54,
    --> Array
) is export {
    my @lines;
    my Numeric $y = $slide-height - $margin-top;

    my Int $num-blocks = $slide<blocks>.elems;

    for 0 ..^ $num-blocks -> Int $i {
        my $block = $slide<blocks>[$i];

        my Str $type = $block<type> // '';
        my Str $text = $block<text> // '';

        if $type eq 'heading' {
            @lines.push: {
                text => $text,
                font => 'heading',
                size => 28,
                x    => $margin-left,
                y    => $y,
            };

            $y -= 48;
        }
        elsif $type eq 'paragraph' {
            @lines.push: {
                text => $text,
                font => 'body',
                size => 18,
                x    => $margin-left,
                y    => $y,
            };

            $y -= 30;
        }
        elsif $type eq 'item' {
            @lines.push: {
                text => '- ' ~ $text,
                font => 'body',
                size => 18,
                x    => $margin-left + 24,
                y    => $y,
            };

            $y -= 30;
        }
        elsif $type eq 'code' {
            @lines.push: {
                text => $text,
                font => 'code',
                size => 14,
                x    => $margin-left + 24,
                y    => $y,
            };

            $y -= 24;
        }
    }

    return @lines.Array;
}

sub render-slides(
    $deck,
    IO::Path $output,
    Str :$pdf-id,
    --> IO::Path
) is export {
    my PDF::API6 $pdf .= new;
    $pdf.id = $pdf-id if $pdf-id.defined;

    my PDF::Content::FontObj $heading-font = $pdf.core-font(
        'Helvetica-Bold'
    );
    my PDF::Content::FontObj $body-font = $pdf.core-font(
        'Times-Roman'
    );
    my PDF::Content::FontObj $code-font = $pdf.core-font(
        'Courier'
    );

    my %fonts = (
        heading => $heading-font,
        body    => $body-font,
        code    => $code-font,
    );

    my Int $num-slides = $deck<slides>.elems;

    for 0 ..^ $num-slides -> Int $i {
        my $slide = $deck<slides>[$i];
        my PDF::Page $page = $pdf.add-page;

        $page.media-box = [
            0,
            0,
            $SLIDE-WIDTH,
            $SLIDE-HEIGHT,
        ];

        my @lines = layout-slide($slide);

        $page.text: {
            for @lines -> %line {
                .font = %fonts{%line<font>}, %line<size>;
                .text-position = %line<x>, %line<y>;
                .say: %line<text>;
            }
        }
    }

    $pdf.save-as: $output.Str, :!info;

    return $output;
}
