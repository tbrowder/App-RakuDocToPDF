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

sub vertical-rules(
    DrawingSpec:D $spec
    --> Array
) is export {
    my ($page-width, $page-height) =
        page-size($spec.page);

    my $left = $spec.page.margin;
    my $right = $page-width - $spec.page.margin;

    my $width = $right - $left;

    my $column-width =
        $width / $spec.grid.columns;

    my @rules;

    for 1 ..^ $spec.grid.columns -> $column {
        @rules.push(
            $left + $column * $column-width
        );
    }

    return @rules;
}

sub horizontal-rules(
    DrawingSpec:D $spec
    --> Array
) is export {
    my ($page-width, $page-height) =
        page-size($spec.page);

    my $top =
        $page-height - $spec.page.margin;

    my $bottom =
        $spec.page.margin;

    my $y = $top;
    my @rules;

    for $spec.grid.fixed-row-heights -> $height {
        $y -= $height;

        @rules.push($y)
            if $y > $bottom;
    }

    if $spec.grid.repeat-row-height.defined
        and $spec.grid.fill
    {
        loop {
            my $next =
                $y - $spec.grid.repeat-row-height;

            last if $next <= $bottom;

            @rules.push($next);

            $y = $next;
        }
    }

    return @rules;
}
