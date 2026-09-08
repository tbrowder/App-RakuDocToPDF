use v6.d;

unit module App::RakuDocToPDF::Reader;

sub plain-text(
    Str $input,
    --> Str
) is export {
    my $text = $input;

    # Keep the visible portion of a labeled link.
    $text ~~ s:g/ 'L<' ( <-[|>]>+ ) '|' <-[>]>+ '>' /$0/;

    # For the initial renderer, preserve the contents of the common
    # inline formatting codes but do not attempt styled inline runs yet.
    loop {
        my $before = $text;
        $text ~~ s:g/ <[BIC]> '<' ( <-[>]>+ ) '>' /$0/;
        last if $text eq $before;
    }

    return $text;
}

sub read-rakudoc(
    IO::Path $source,
    --> Array
) is export {
    die "RakuDoc file '$source' does not exist." unless $source.e;

    my @blocks;
    my @paragraph;
    my @code;
    my Bool $in-code = False;

    for $source.lines -> $line {
        if $in-code {
            if $line ~~ /^ '=end' \s+ 'code' \s* $/ {
                @blocks.push: {
                    type => 'code',
                    text => @code.join("\n"),
                };
                @code = ();
                $in-code = False;
            }
            else {
                @code.push: $line;
            }
            next;
        }

        if $line ~~ /^ '=begin' \s+ 'code' / {
            if @paragraph {
                @blocks.push: {
                    type => 'paragraph',
                    text => plain-text(@paragraph.join(' ')),
                };
                @paragraph = ();
            }
            $in-code = True;
            next;
        }

        if $line ~~ /^ '=code' \s* (.*) $/ {
            if @paragraph {
                @blocks.push: {
                    type => 'paragraph',
                    text => plain-text(@paragraph.join(' ')),
                };
                @paragraph = ();
            }
            @blocks.push: {
                type => 'code',
                text => ~$0,
            };
            next;
        }

        if $line ~~ /^ '=head' (\d+) \s+ (.*) $/ {
            if @paragraph {
                @blocks.push: {
                    type => 'paragraph',
                    text => plain-text(@paragraph.join(' ')),
                };
                @paragraph = ();
            }
            @blocks.push: {
                type  => 'heading',
                level => +$0,
                text  => plain-text(~$1),
            };
            next;
        }

        if $line ~~ /^ '=item' \s* (.*) $/ {
            if @paragraph {
                @blocks.push: {
                    type => 'paragraph',
                    text => plain-text(@paragraph.join(' ')),
                };
                @paragraph = ();
            }
            @blocks.push: {
                type => 'item',
                text => plain-text(~$0),
            };
            next;
        }

        if $line ~~ /^ '=begin' \s+ 'pod' \s* $/
            or $line ~~ /^ '=end' \s+ 'pod' \s* $/ {
            next;
        }

        if $line ~~ /^ '=comment' / {
            next;
        }

        if $line.trim.chars == 0 {
            if @paragraph {
                @blocks.push: {
                    type => 'paragraph',
                    text => plain-text(@paragraph.join(' ')),
                };
                @paragraph = ();
            }
            next;
        }

        # Ignore unsupported block directives for now. Their body text will
        # still be seen on following ordinary lines where appropriate.
        if $line.starts-with('=') {
            next;
        }

        @paragraph.push: $line.trim;
    }

    if $in-code {
        die "Unterminated '=begin code' block in '$source'.";
    }

    if @paragraph {
        @blocks.push: {
            type => 'paragraph',
            text => plain-text(@paragraph.join(' ')),
        };
    }

    return @blocks.Array;
}
