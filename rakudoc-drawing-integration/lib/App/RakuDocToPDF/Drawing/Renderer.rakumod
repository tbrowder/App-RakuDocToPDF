unit module App::RakuDocToPDF::Drawing::Renderer;

use PDF::API6;
use PDF::Page;

use App::RakuDocToPDF::Drawing::Layout;
use App::RakuDocToPDF::Drawing::Model;

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

    $pdf.save-as($output);

    return;
}
