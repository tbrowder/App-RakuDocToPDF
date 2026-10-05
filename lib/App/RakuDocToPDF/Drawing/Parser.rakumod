unit module App::RakuDocToPDF::Drawing::Parser;

use App::RakuDocToPDF::Drawing::Model;
use App::RakuDocToPDF::Drawing::Units;

sub get-options(
    @parts
    --> Hash
) {
    my %options;

    for @parts -> $part {
        next unless $part.contains('=');

        my ($name, $value) = $part.split('=', 2);

        %options{$name} = $value;
    }

    return %options;
}

sub parse-drawing(
    Str:D $source
    --> DrawingSpec
) is export {
    my $media = 'Letter';
    my $orientation = 'portrait';
    my $margin = points('0.5in');

    my $columns;
    my $line-width = points('0.75pt');

    my @column-widths;
    my @fixed-row-heights;
    my $repeat-row-height;
    my $fill = False;

    my @row-labels;

    my @lines = $source.lines;
    my Int $index = 0;

    while $index < @lines.elems {
        my Str $line = @lines[$index].trim;

        ++$index;

        next unless $line.chars;
        next if $line.starts-with('#');

        my @parts = $line.words;
        my $command = @parts.shift;

        given $command {
            when 'page' {
                my %options = get-options(@parts);

                if %options<media>:exists {
                    $media = %options<media>;
                }

                if %options<orientation>:exists {
                    $orientation = %options<orientation>;
                }

                if %options<margin>:exists {
                    $margin = points(%options<margin>);
                }
            }

            when 'grid' {
                my %options = get-options(@parts);

                if %options<columns>:exists {
                    $columns = %options<columns>.Int;
                }

                if %options<line-width>:exists {
                    $line-width = points(%options<line-width>);
                }

                if %options<widths>:exists {
                    @column-widths = ();

                    for %options<widths>.split(',') -> $width {
                        @column-widths.push(
                            points($width.trim)
                        );
                    }

                    $columns = @column-widths.elems;
                }
            }

            when 'rows' {
                for @parts -> $part {
                    if $part eq 'fill' {
                        $fill = True;
                        next;
                    }

                    if $part.starts-with('repeat=') {
                        my $value = $part.substr(
                            'repeat='.chars
                        );

                        $repeat-row-height = points($value);
                        next;
                    }

                    @fixed-row-heights.push(
                        points($part)
                    );
                }
            }

            when 'row-labels' {
                die "row-labels requires a row number"
                    unless @parts.elems;

                my Int $row = @parts[0].Int;

                die "row number must be greater than zero"
                    unless $row > 0;

                my @labels;
                my Bool $closed = False;

                while $index < @lines.elems {
                    my Str $label-line =
                        @lines[$index].trim;

                    ++$index;

                    next unless $label-line.chars;
                    next if $label-line.starts-with('#');

                    if $label-line eq 'end-row-labels' {
                        $closed = True;
                        last;
                    }

                    @labels.push($label-line);
                }

                die "row-labels block for row $row is missing end-row-labels"
                    unless $closed;

                @row-labels.push(
                    RowLabelsSpec.new(
                        :$row,
                        labels => @labels,
                    )
                );
            }

            default {
                die "Unknown drawing command '$command'";
            }
        }
    }

    die 'A grid must specify columns or widths'
        unless $columns.defined;

    die 'A grid must contain at least one column'
        unless $columns > 0;

    for @row-labels -> $row-label-spec {
        my Int $count =
            $row-label-spec.labels.elems;

        die "row-labels for row {$row-label-spec.row} has $count labels but grid has $columns columns"
            unless $count == $columns;
    }

    my $page = PageSpec.new(
        :$media,
        :$orientation,
        :$margin,
    );

    my $grid = GridSpec.new(
        :$columns,
        :$line-width,
        :@column-widths,
        :@fixed-row-heights,
        :$repeat-row-height,
        :$fill,
        :@row-labels,
    );

    return DrawingSpec.new(
        :$page,
        :$grid,
    );
}
