unit module App::RakuDocToPDF::Drawing::Units;

sub points(
    $value
    --> Numeric
) is export {
    my $text = $value.Str.trim;

    if $text ~~ /^
        (<[\d.]>+)
        'pt'
        $/
    {
        return +$0;
    }

    if $text ~~ /^
        (<[\d.]>+)
        'in'
        $/
    {
        return +$0 * 72;
    }

    if $text ~~ /^
        (<[\d.]>+)
        'mm'
        $/
    {
        return +$0 * 72 / 25.4;
    }

    die "Unknown drawing unit '$text'";
}
