use v6.d;

unit module App::RakuDocToPDF::Layout;

sub wrap-text(
    Str $text,
    $font,
    Numeric $font-size,
    Numeric $width,
    --> Array
) is export {
    return [''] unless $text.chars;

    my @words = $text.words;
    my @lines;
    my Str $line = '';

    for @words -> $word {
        my $candidate = $line.chars ?? "$line $word" !! $word;

        if $font.stringwidth($candidate, $font-size) <= $width {
            $line = $candidate;
            next;
        }

        if $line.chars {
            @lines.push: $line;
            $line = '';
        }

        # A single unusually long token may be wider than the page.
        # Split it at character boundaries so it cannot escape the margin.
        if $font.stringwidth($word, $font-size) > $width {
            my Str $part = '';
            for $word.comb -> $char {
                my $next = $part ~ $char;
                if $part.chars
                    and $font.stringwidth($next, $font-size) > $width {
                    @lines.push: $part;
                    $part = $char;
                }
                else {
                    $part = $next;
                }
            }
            $line = $part;
        }
        else {
            $line = $word;
        }
    }

    @lines.push: $line if $line.chars;
    return @lines.Array;
}

sub layout-pages(
    @blocks,
    %fonts,
    Numeric :$page-width!,
    Numeric :$page-height!,
    Numeric :$margin-left = 45,
    Numeric :$margin-right = 36,
    Numeric :$margin-top = 36,
    Numeric :$body-bottom = 54,
    --> Array
) is export {
    my Numeric $body-width = $page-width - $margin-left - $margin-right;
    my @pages = [[]];
    my Int $page-number = 0;
    my Numeric $y = $page-height - $margin-top;

    sub start-new-page() {
        @pages.push: [];
        $page-number++;
        $y = $page-height - $margin-top;
    }

    sub place-line(
        Str $text,
        Str $font-key,
        Numeric $font-size,
        Numeric $leading,
        Numeric $x = $margin-left,
    ) {
        start-new-page() if $y - $leading < $body-bottom;

        @pages[$page-number].push: {
            text => $text,
            font => $font-key,
            size => $font-size,
            x    => $x,
            y    => $y,
        };
        $y -= $leading;
    }

    for @blocks -> %block {
        given %block<type> {
            when 'page-break' {
                # An explicit page break should never create an empty first
                # page, but after content it always begins a fresh page.
                if @pages[$page-number].elems {
                    start-new-page();
                }
            }

            when 'heading' {
                my Int $level = (%block<level> // 1).Int;
                my Numeric $size = $level == 1 ?? 18
                    !! $level == 2 ?? 15
                    !! $level == 3 ?? 13
                    !! 12;
                my Numeric $leading = $size + 5;
                my Numeric $space-before = $level == 1 ?? 10 !! 7;

                $y -= $space-before if $y < $page-height - $margin-top;
                start-new-page() if $y - $leading < $body-bottom;

                my @lines = wrap-text(
                    %block<text>.Str,
                    %fonts<heading>,
                    $size,
                    $body-width,
                );
                for @lines -> $line {
                    place-line($line, 'heading', $size, $leading);
                }
                $y -= 4;
            }

            when 'code' {
                my Numeric $size = 9;
                my Numeric $leading = 11;
                my Numeric $indent = 18;
                my Numeric $code-width = $body-width - $indent;

                for %block<text>.Str.split("\n", :skip-empty(False)) -> $source-line {
                    if $source-line.chars == 0 {
                        place-line('', 'code', $size, $leading, $margin-left + $indent);
                        next;
                    }

                    my @lines = wrap-text(
                        $source-line,
                        %fonts<code>,
                        $size,
                        $code-width,
                    );
                    for @lines -> $line {
                        place-line(
                            $line,
                            'code',
                            $size,
                            $leading,
                            $margin-left + $indent,
                        );
                    }
                }
                $y -= 6;
            }

            when 'item' {
                my Numeric $size = 11;
                my Numeric $leading = 14;
                my Numeric $indent = 18;
                my $text = '- ' ~ %block<text>.Str;
                my @lines = wrap-text(
                    $text,
                    %fonts<body>,
                    $size,
                    $body-width - $indent,
                );
                for @lines -> $line {
                    place-line(
                        $line,
                        'body',
                        $size,
                        $leading,
                        $margin-left + $indent,
                    );
                }
                $y -= 4;
            }

            default {
                my Numeric $size = 11;
                my Numeric $leading = 14;
                my @lines = wrap-text(
                    %block<text>.Str,
                    %fonts<body>,
                    $size,
                    $body-width,
                );
                for @lines -> $line {
                    place-line($line, 'body', $size, $leading);
                }
                $y -= 7;
            }
        }
    }

    return @pages.Array;
}
