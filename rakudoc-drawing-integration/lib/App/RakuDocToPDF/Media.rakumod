use v6.d;

unit module App::RakuDocToPDF::Media;

our constant %MEDIA-SIZES is export = (
    A4     => [0, 0, 595, 842],
    Letter => [0, 0, 612, 792],
);

sub media-box(
    $media is copy,
    --> List
) is export {
    $media .= Str;

    for %MEDIA-SIZES.keys -> $name {
        if $name.lc eq $media.lc {
            return %MEDIA-SIZES{$name}.List;
        }
    }

    die "Unknown media '$media'. Expected Letter or A4.";
}

sub media-width(
    $media,
    --> Numeric
) is export {
    my @box = media-box($media);
    return @box[2] - @box[0];
}

sub media-height(
    $media,
    --> Numeric
) is export {
    my @box = media-box($media);
    return @box[3] - @box[1];
}
