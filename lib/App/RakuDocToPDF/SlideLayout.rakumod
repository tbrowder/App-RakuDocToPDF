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
    Bool :$title-slide = False,
    Numeric :$slide-height = $SLIDE-HEIGHT,
    Numeric :$margin-left = 54,
    Numeric :$margin-top  = 54,
    --> Array
) is export {
    my @lines;

    my Numeric $y = $title-slide
        ?? 300
        !! $slide-height - $margin-top;

    my Int $num-blocks = $slide<blocks>.elems;

    my Bool $first-paragraph = True;

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
            if $title-slide and $first-paragraph {
                @lines.push: {
                    text => $text,
                    font => 'subtitle',
                    size => 20,
                };

                $first-paragraph = False;
                next;
            }

            $first-paragraph = False;

            my Numeric $font-size = 18;

            my Str $subtitle = '';

            for @lines -> $line {
                if ($line<font> // '') eq 'subtitle' {
                    $subtitle = $line<text> // '';
                    last;
                }
            }
            my Numeric $max-width =
            $SLIDE-WIDTH - (2 * $margin-left);

            my @wrapped = wrap-text(
                $text,
                $body-font,
                $font-size,
                $max-width,
            );

            for @wrapped -> Str $line {
                my Numeric $x = $margin-left;

                if $title-slide {
                    my Numeric $width = $body-font.stringwidth(
                        $line,
                        $font-size,
                    );

                    $x = ($SLIDE-WIDTH - $width) / 2;
                }

                @lines.push: {
                    text => $line,
                    font => 'body',
                    size => $font-size,
                    x    => $x,
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

        my Bool $title-slide = $i == 0;

        $page.media-box = [
            0,
            0,
            $SLIDE-WIDTH,
            $SLIDE-HEIGHT,
        ];

        my Numeric $header-height = 54;

        my Numeric $header-bottom = $title-slide
            ?? 360
            !! $SLIDE-HEIGHT - $header-height;

        # blue bar graphics
        $page.graphics: {

            .FillColor = :DeviceRGB[0.267, 0.447, 0.769];

            .Rectangle(
                0,
                $header-bottom,
                $SLIDE-WIDTH,
                $header-height,
            );

            .Fill;
        }


        my @lines = layout-slide(
            $slide,
            :$body-font,
            :$title-slide,
        );

        my Str $heading  = '';
        my Str $subtitle = '';

        for @lines -> $line {
            if ($line<font> // '') eq 'heading' {
                $heading = $line<text> // '';
                last;
            }
        }
        for @lines -> $line {
            if ($line<font> // '') eq 'subtitle' {
                $subtitle = $line<text> // '';
                last;
            }
        }

        if $heading.chars {
            my Numeric $heading-size = $title-slide
            ?? 40
            !! 28;

            my Numeric $heading-width = $heading-font.stringwidth(
                $heading,
                $heading-size,
            );

            my Numeric $heading-x =
            ($SLIDE-WIDTH - $heading-width) / 2;

            my Numeric $heading-y = $title-slide
            ?? $header-bottom + 91
            !! $header-bottom + 16;

            $page.graphics: {
                .text: {
                    .font = $heading-font, $heading-size;
                    .FillColor = :DeviceRGB[1, 1, 1];
                    .text-position = $heading-x, $heading-y;
                    .say: $heading;
                }
            }
        }

        if $title-slide and $subtitle.chars {
            my Numeric $subtitle-size = 20;

            my Numeric $subtitle-width = $heading-font.stringwidth(
                $subtitle,
                $subtitle-size,
            );

            my Numeric $subtitle-x =
            ($SLIDE-WIDTH - $subtitle-width) / 2;

            my Numeric $subtitle-y =
            $heading-y - 34;

            $page.graphics: {
                .text: {
                    .font = $heading-font, $subtitle-size;
                    .FillColor = :DeviceRGB[1, 1, 1];
                    .text-position = $subtitle-x, $subtitle-y;
                    .say: $subtitle;
                }
            }
        }

        $page.text: {
            for @lines -> %line {
                next if (%line<type> // '') eq 'image';
                next if (%line<font> // '') eq 'heading';
                next if (%line<font> // '') eq 'subtitle';

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

                my Numeric $width  = %line<max-width>;
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
