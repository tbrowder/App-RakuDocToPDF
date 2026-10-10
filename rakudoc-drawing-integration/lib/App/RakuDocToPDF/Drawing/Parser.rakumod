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

    my @fixed-row-heights;
    my $repeat-row-height;
    my $fill = False;

    for $source.lines -> $raw-line {
        my $line = $raw-line.trim;

        next unless $line.chars;
        next if $line.starts-with('#');

        my @parts = $line.words;
        my $command = @parts.shift;

        given $command {
            when 'page' {
                my %options = get-options(@parts);

                $media =
                    %options<media>
                        if %options<media>:exists;

                $orientation =
                    %options<orientation>
                        if %options<orientation>:exists;

                $margin =
                    points(%options<margin>)
                        if %options<margin>:exists;
            }

            when 'grid' {
                my %options = get-options(@parts);

                $columns =
                    %options<columns>.Int
                        if %options<columns>:exists;

                $line-width =
                    points(%options<line-width>)
                        if %options<line-width>:exists;
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

            default {
                die "Unknown drawing command '$command'";
            }
        }
    }

    die 'A grid must specify columns'
        unless $columns.defined;

    my $page = PageSpec.new(
        :$media,
        :$orientation,
        :$margin,
    );

    my $grid = GridSpec.new(
        :$columns,
        :$line-width,
        :@fixed-row-heights,
        :$repeat-row-height,
        :$fill,
    );

    return DrawingSpec.new(
        :$page,
        :$grid,
    );
}
