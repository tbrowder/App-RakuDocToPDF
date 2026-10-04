unit module App::RakuDocToPDF::Drawing::Renderer;

use PDF::API6;

use App::RakuDocToPDF::Drawing::Layout;
use App::RakuDocToPDF::Drawing::Model;

sub render-drawing(
    DrawingSpec:D $spec,
    Str:D :$output!
    --> Nil
) is export {
    my ($page-width, $page-height) =
        page-size($spec.page);

    my $left =
        $spec.page.margin;

    my $right =
        $page-width - $spec.page.margin;

    my $bottom =
        $spec.page.margin;

    my $top =
        $page-height - $spec.page.margin;

    my $width =
        $right - $left;

    my $height =
        $top - $bottom;

    my PDF::API6 $pdf .= new;

    $pdf.media-box = [
        0,
        0,
        $page-width,
        $page-height,
    ];

    my $page = $pdf.add-page;

    $page.graphics: -> $gfx {
        $gfx.LineWidth =
            $spec.grid.line-width;

        # Outer border.

        $gfx.Rectangle(
            $left,
            $bottom,
            $width,
            $height,
        );

        # Vertical column rules.

        for vertical-rules($spec) -> $x {
            $gfx.MoveTo(
                $x,
                $bottom,
            );

            $gfx.LineTo(
                $x,
                $top,
            );
        }

        # Horizontal row rules.

        for horizontal-rules($spec) -> $y {
            $gfx.MoveTo(
                $left,
                $y,
            );

            $gfx.LineTo(
                $right,
                $y,
            );
        }

        $gfx.Stroke;
    }

    $pdf.save-as($output);

    return;
}
