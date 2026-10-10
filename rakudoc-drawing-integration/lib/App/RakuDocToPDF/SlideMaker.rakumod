use v6.d;

unit module App::RakuDocToPDF::SlideMaker;

sub make-slides(
    @blocks,
    --> Hash
) is export {
    my @slides;
    my %presentation;
    my $slide;
    my Bool $in-slide = False;
    my Int $number = 0;

    for @blocks -> $block {
        my Str $type = $block<type> // '';

        if $type eq 'title' {
            %presentation<title> = $block<text> // '';
            next;
        }

        if $type eq 'subtitle' {
            %presentation<subtitle> = $block<text> // '';
            next;
        }

        if $type eq 'slide' {
            if $in-slide {
                @slides.push: $slide;
            }

            ++$number;

            $slide = {
                number => $number,
                blocks => [],
            };

            $in-slide = True;
            next;
        }

        # Content before the first =slide is presentation-level
        # material and is not part of a slide.
        next unless $in-slide;

        # page-break has no meaning in a slide presentation.
        next if $type eq 'page-break';

        $slide<blocks>.push: $block;
    }

    if $in-slide {
        @slides.push: $slide;
    }

    return {
        presentation => %presentation,
        slides       => @slides.Array,
    };
}
