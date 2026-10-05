unit module App::RakuDocToPDF::Drawing::Renderer;

use PDF::API6;
use PDF::Page;

use App::RakuDocToPDF::Drawing::Layout;
use App::RakuDocToPDF::Drawing::Model;

sub wrap-cell-text(
    Str:D $text,
    $font,
    Numeric:D $font-size,
    Numeric:D $max-width
    --> Array
) {
    my @words = $text.words;
    my @lines;

    return [$text] unless @words.elems;

    my Str $current = '';

    for @words -> $word {
        my Str $candidate =
            $current.chars
                ?? "$current $word"
                !! $word;

        if $font.stringwidth(
            $candidate,
            $font-size,
        ) <= $max-width {
            $current = $candidate;
        }
        else {
            if $current.chars {
                @lines.push($current);
                $current = $word;
            }
            else {
                @lines.push($word);
                $current = '';
            }
        }
    }

    @lines.push($current)
        if $current.chars;

    return @lines;
}

sub draw-row-labels(
    PDF::API6:D $pdf,
    PDF::Page:D $page,
    DrawingSpec:D $spec
    --> Nil
) {
    return unless $spec.grid.row-labels.elems;

    my $label-font =
        $pdf.core-font('Helvetica');

    my Numeric $font-size = 10;
    my Numeric $line-step = 12;
    my Numeric $padding-x = 4;

    $page.graphics: {
        for $spec.grid.row-labels -> $row-label-spec {
            my @cells = cells-for-row(
                $spec,
                $row-label-spec.row,
            );

            my Int $count =
                @cells.elems min
                $row-label-spec.labels.elems;

            for 0 ..^ $count -> $index {
                my %cell = @cells[$index];
                my Str $label =
                    $row-label-spec.labels[$index];

                my Numeric $cell-width =
                    %cell<right> - %cell<left>;

                my Numeric $cell-height =
                    %cell<top> - %cell<bottom>;

                my Numeric $max-width =
                    $cell-width - 2 * $padding-x;

                my @lines = wrap-cell-text(
                    $label,
                    $label-font,
                    $font-size,
                    $max-width,
                );

                my Numeric $text-height =
                    @lines.elems * $line-step;

                my Numeric $y =
                    %cell<top>
                    - (($cell-height - $text-height) / 2)
                    - $font-size;

                .text: {
                    .font = $label-font, $font-size;
                    .FillColor = :DeviceRGB[0, 0, 0];

                    for @lines -> $line {
                        my Numeric $line-width =
                            $label-font.stringwidth(
                                $line,
                                $font-size,
                            );

                        my Numeric $x =
                            %cell<left>
                            + (($cell-width - $line-width) / 2);

                        .text-position = $x, $y;
                        .say: $line;

                        $y -= $line-step;
                    }
                }
            }
        }
    }

    return;
}

sub render-drawing(
    DrawingSpec:D $spec,
    Str:D :$output!
    --> Nil
) is export {
    my ($page-width, $page-height) =
        page-size($spec.page);

    my Numeric $left =
        $spec.page.margin;

    my Numeric $right =
        $page-width - $spec.page.margin;

    my Numeric $bottom =
        $spec.page.margin;

    my Numeric $top =
        $page-height - $spec.page.margin;

    my Numeric $width =
        $right - $left;

    my Numeric $height =
        $top - $bottom;

    my PDF::API6 $pdf .= new;

    $pdf.media-box = [
        0,
        0,
        $page-width,
        $page-height,
    ];

    my PDF::Page $page = $pdf.add-page;

    $page.graphics: {
        .LineWidth =
            $spec.grid.line-width;

        .Rectangle(
            $left,
            $bottom,
            $width,
            $height,
        );

        for vertical-rules($spec) -> $x {
            .MoveTo(
                $x,
                $bottom,
            );

            .LineTo(
                $x,
                $top,
            );
        }

        for horizontal-rules($spec) -> $y {
            .MoveTo(
                $left,
                $y,
            );

            .LineTo(
                $right,
                $y,
            );
        }

        .Stroke;
    }

    draw-row-labels(
        $pdf,
        $page,
        $spec,
    );

    $pdf.save-as($output);

    return;
}
