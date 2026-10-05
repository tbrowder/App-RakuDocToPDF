unit module App::RakuDocToPDF::Drawing::Layout;

use App::RakuDocToPDF::Drawing::Model;

sub page-size(
    PageSpec:D $page
    --> List
) is export {
    my ($width, $height);

    given $page.media.lc {
        when 'letter' {
            $width  = 612;
            $height = 792;
        }

        when 'a4' {
            $width  = 595.276;
            $height = 841.890;
        }

        default {
            die "Unknown media '{$page.media}'";
        }
    }

    if $page.orientation.lc eq 'landscape' {
        ($width, $height) = ($height, $width);
    }

    return ($width, $height);
}

sub column-widths(
    DrawingSpec:D $spec
    --> Array
) is export {
    my ($page-width, $page-height) =
        page-size($spec.page);

    my Numeric $usable-width =
        $page-width - 2 * $spec.page.margin;

    if $spec.grid.column-widths.elems {
        my @widths =
            $spec.grid.column-widths.Array;

        my Numeric $total-width = 0;

        for @widths -> $width {
            $total-width += $width;
        }

        my Numeric $difference =
            abs($total-width - $usable-width);

        die "Column widths total {$total-width.fmt('%.2f')} pt but usable page width is {$usable-width.fmt('%.2f')} pt"
            if $difference > 0.01;

        return @widths;
    }

    my Numeric $column-width =
        $usable-width / $spec.grid.columns;

    my @widths;

    for ^$spec.grid.columns {
        @widths.push($column-width);
    }

    return @widths;
}

sub row-bands(
    DrawingSpec:D $spec
    --> Array
) is export {
    my ($page-width, $page-height) =
        page-size($spec.page);

    my Numeric $top =
        $page-height - $spec.page.margin;

    my Numeric $bottom =
        $spec.page.margin;

    my Numeric $y = $top;
    my @bands;

    for $spec.grid.fixed-row-heights -> $height {
        my Numeric $next = $y - $height;

        if $next < $bottom {
            $next = $bottom;
        }

        @bands.push({
            top    => $y,
            bottom => $next,
        });

        $y = $next;

        last if $y <= $bottom;
    }

    if $spec.grid.repeat-row-height.defined
        and $spec.grid.fill
    {
        while $y > $bottom {
            my Numeric $next =
                $y - $spec.grid.repeat-row-height;

            if $next < $bottom {
                $next = $bottom;
            }

            @bands.push({
                top    => $y,
                bottom => $next,
            });

            $y = $next;
        }
    }

    return @bands;
}

sub cells-for-row(
    DrawingSpec:D $spec,
    Int:D $row
    --> Array
) is export {
    my @bands = row-bands($spec);

    die "Row $row is out of range"
        if $row < 1
        or $row > @bands.elems;

    my %band = @bands[$row - 1];
    my @widths = column-widths($spec);

    my Numeric $x =
        $spec.page.margin;

    my @cells;

    for @widths -> $width {
        my Numeric $cell-left = $x;
        my Numeric $cell-right = $x + $width;

        @cells.push({
            left   => $cell-left,
            right  => $cell-right,
            top    => %band<top>,
            bottom => %band<bottom>,
        });

        $x = $cell-right;
    }

    return @cells;
}

sub vertical-rules(
    DrawingSpec:D $spec
    --> Array
) is export {
    my Numeric $x =
        $spec.page.margin;

    my @widths =
        column-widths($spec);

    my @rules;

    for 0 ..^ (@widths.elems - 1) -> $index {
        $x += @widths[$index];
        @rules.push($x);
    }

    return @rules;
}

sub horizontal-rules(
    DrawingSpec:D $spec
    --> Array
) is export {
    my @bands = row-bands($spec);
    my @rules;

    for @bands -> %band {
        @rules.push(
            %band<bottom>
        );
    }

    @rules.pop if @rules.elems;

    return @rules;
}
