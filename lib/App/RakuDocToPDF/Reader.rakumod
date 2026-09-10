use v6.d;

unit module App::RakuDocToPDF::Reader;

sub plain-text(
    Str $input,
    --> Str
) is export {
    my $text = $input;

    # Keep the visible portion of a labeled link.
    $text ~~ s:g/ 'L<' ( <-[|>]>+ ) '|' <-[>]>+ '>' /$0/;

    # Preserve the visible contents of common inline formatting codes.
    # Styled inline runs can be added later without changing the block model.
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
    my Int $heading-depth = 0;
    my Int $sequence = 0;

    sub add-block(
        Str $type,
        Str :$text = '',
        Int :$depth = $heading-depth,
        Int :$level = 0,
    ) {
        my %block = (
            seq   => ++$sequence,
            depth => $depth,
            type  => $type,
            text  => $text,
        );

        %block<level> = $level if $level;
        @blocks.push: %block;
    }

    sub flush-paragraph() {
        return unless @paragraph;

        add-block(
            'paragraph',
            :text(plain-text(@paragraph.join(' '))),
        );
        @paragraph = ();
    }

    for $source.lines -> $line {
        if $in-code {
            if $line ~~ /^ '=end' \s+ 'code' \s* $/ {
                add-block('code', :text(@code.join("\n")));
                @code = ();
                $in-code = False;
            }
            else {
                @code.push: $line;
            }
            next;
        }

        if $line ~~ /^ '=begin' \s+ 'code' / {
            flush-paragraph();
            $in-code = True;
            next;
        }

        if $line ~~ /^ '=code' \s* (.*) $/ {
            flush-paragraph();
            add-block('code', :text(~$0));
            next;
        }

        if $line ~~ /^ '=head' (\d+) \s+ (.*) $/ {
            flush-paragraph();

            my Int $level = +$0;
            $heading-depth = $level - 1;
            add-block(
                'heading',
                :$level,
                :depth($heading-depth),
                :text(plain-text(~$1)),
            );
            next;
        }

        if $line ~~ /^ '=item' \s* (.*) $/ {
            flush-paragraph();
            add-block(
                'item',
                :depth($heading-depth + 1),
                :text(plain-text(~$0)),
            );
            next;
        }

        if $line ~~ /^ '=page-break' \s* $/ {
            flush-paragraph();
            add-block('page-break');
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
            flush-paragraph();
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

    flush-paragraph();
    return @blocks.Array;
}
