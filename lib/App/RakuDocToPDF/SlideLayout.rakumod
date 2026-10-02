use v6.d;

unit module App::RakuDocToPDF::SlideLayout;

use PDF::API6;
use PDF::Content::FontObj;
use PDF::Page;
use PDF::XObject::Image;

constant $SLIDE-WIDTH  = 792;
constant $SLIDE-HEIGHT = 612;

sub wrap-text(
    Str $text,
    PDF::Content::FontObj $font,
    Numeric $font-size,
    Numeric $max-width,
    --> Array
) {
    my @lines;
    my Str $line = '';

    for $text.words -> Str $word {
        my Str $candidate = $line.chars
            ?? "$line $word"
            !! $word;

        my Numeric $width = $font.stringwidth(
            $candidate,
            $font-size,
        );

        if $width <= $max-width {
            $line = $candidate;
        }
        else {
            @lines.push: $line if $line.chars;
            $line = $word;
        }
    }

    @lines.push: $line if $line.chars;

    return @lines.Array;
}

sub layout-slide(
    $slide,
    PDF::Content::FontObj :$body-font!,
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
            my Numeric $font-size = 18;
            my Numeric $max-width =
            $SLIDE-WIDTH - (2 * $margin-left);

            my @wrapped = wrap-text(
                $text,
                $body-font,
                $font-size,
                $max-width,
            );

            for @wrapped -> Str $line {
                @lines.push: {
                    text => $line,
                    font => 'body',
                    size => $font-size,
                    x    => $margin-left,
                    y    => $y,
                };

                $y -= 24;
            }

            $y -= 6;
        }
        elsif $type eq 'item' {

            my Numeric $font-size = 18;
            my Numeric $item-x = $margin-left + 24;
            my Numeric $max-width =
            $SLIDE-WIDTH - $item-x - $margin-left;

            my @wrapped = wrap-text(
                $text,
                $body-font,
                $font-size,
                $max-width - 18,
            );

            my Bool $first = True;

            for @wrapped -> Str $line {
                my Str $output = $first
                ?? '- ' ~ $line
                !! $line;

                @lines.push: {
                    text => $output,
                    font => 'body',
                    size => $font-size,
                    x    => $first
                         ?? $item-x
                         !! $item-x + 18,
                    y    => $y,
                };

                $first = False;
                $y -= 24;
            }

            $y -= 6;
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
        elsif $type eq 'image' {
            @lines.push: {
                type       => 'image',
                path       => $text,
                x          => $margin-left,
                top        => $y,
                max-width  => $SLIDE-WIDTH - (2 * $margin-left),
                max-height => $y - $margin-top,
            };

            $y = $margin-top;
        }
    }

    return @lines.Array;
}

sub render-slides(
    $deck,
    IO::Path $output,
    Str :$pdf-id,
    IO::Path :$base-dir = '.'.IO,
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

        my @lines = layout-slide(
            $slide,
            :$body-font,
        );

        $page.text: {
            for @lines -> %line {
                next if (%line<type> // '') eq 'image';

                .font = %fonts{%line<font>}, %line<size>;
                .text-position = %line<x>, %line<y>;
                .say: %line<text>;
            }
        }

        for @lines -> %line {
            next unless (%line<type> // '') eq 'image';

            my IO::Path $image-path = %line<path>.IO;
            unless $image-path.is-absolute {
                $image-path = $base-dir.add($image-path);
            }

            die "Slide image '$image-path' does not exist."
                unless $image-path.e;

            $page.graphics: {
                my PDF::XObject::Image $image = .load-image(
                    $image-path.Str
                );

                my Numeric $width = %line<max-width>;
                my Numeric $height = $width * $image.height / $image.width;

                if $height > %line<max-height> {
                    $height = %line<max-height>;
                    $width = $height * $image.width / $image.height;
                }

                my Numeric $y = %line<top> - $height;

                .do: $image,
                    :position[%line<x>, $y],
                    :$width,
                    :$height;
            }
        }
    }

    $pdf.save-as: $output.Str, :!info;

    return $output;
}
