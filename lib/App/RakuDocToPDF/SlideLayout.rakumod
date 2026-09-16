use v6.d;

unit module App::RakuDocToPDF::SlideLayout;

use PDF::API6;

constant $SLIDE-WIDTH  = 792;
constant $SLIDE-HEIGHT = 612;

sub render-slides(
    $deck,
    IO::Path $output,
    --> IO::Path
) is export {

    my PDF::API6 $pdf .= new;

    my Int $num-slides = $deck<slides>.elems;

    for 0 ..^ $num-slides -> Int $i {
        my $slide = $deck<slides>[$i];

        my $page = $pdf.add-page;

        $page.MediaBox = [
            0,
            0,
            $SLIDE-WIDTH,
            $SLIDE-HEIGHT,
        ];

        my $content = $page.gfx;

        my $heading-font = $pdf.core-font(
            'Helvetica-Bold'
        );

        my $body-font = $pdf.core-font(
            'Times-Roman'
        );

        my $code-font = $pdf.core-font(
            'Courier'
        );

        #===========================
        # The blocks loop
        #===========================
        my Numeric $x = 54;
        my Numeric $y = $SLIDE-HEIGHT - 54;

        my Int $num-blocks = $slide<blocks>.elems;

        for 0 ..^ $num-blocks -> Int $j {
            my $block = $slide<blocks>[$j];

            my Str $type = $block<type> // '';
            my Str $text = $block<text> // '';

            if $type eq 'heading' {
                $content.text: {
                    .font = $heading-font, 28;
                    .text-position = $x, $y;
                    .say: $text;
                }

                $y -= 48;
            }
            elsif $type eq 'paragraph' {
                $content.text: {
                    .font = $body-font, 18;
                    .text-position = $x, $y;
                    .say: $text;
                }

                $y -= 30;
            }
            elsif $type eq 'item' {
                $content.text: {
                    .font = $body-font, 18;
                    .text-position = $x + 24, $y;
                    .say: '- ' ~ $text;
                }

                $y -= 30;
            }
            elsif $type eq 'code' {
                $content.text: {
                    .font = $code-font, 14;
                    .text-position = $x + 24, $y;
                    .say: $text;
                }

                $y -= 24;
            }

        }
    }

    $pdf.save-as($output.Str);

    return $output;

    =begin comment
    # old code
    for $deck<slides> -> $slide {
        my $page = $pdf.add-page;

        $page.MediaBox = [
            0,
            0,
            $SLIDE-WIDTH,
            $SLIDE-HEIGHT,
        ];

        my $content = $page.gfx;

        my $heading-font = $pdf.core-font(
            'Helvetica-Bold'
        );

        my $body-font = $pdf.core-font(
            'Times-Roman'
        );

        my $x = 54;
        my $y = $SLIDE-HEIGHT - 54;

        note "slide = ", $slide.^name;
        note "blocks = ", $slide<blocks>.^name;

        for $slide<blocks> -> $block {
            note "block = ", $block.^name;

            my Str $type = $block<type> // '';
            my Str $text = $block<text> // '';


            if $type eq 'heading' {
                $content.text: {
                    .font = $heading-font, 28;
                    .text-position = $x, $y;
                    .say($text);
                }

                $y -= 48;
            }
            elsif $type eq 'paragraph' {
                $content.text: {
                    .font = $body-font, 18;
                    .text-position = $x, $y;
                    .say($text);
                }

                $y -= 30;
            }
        }
    }
    # end old code
    =end comment
}
