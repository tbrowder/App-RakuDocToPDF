use v6.d;

unit module App::RakuDocToPDF::RakuASTReader;

use experimental :rakuast;

sub read-rakuast(
    IO::Path $input,
    --> RakuAST::StatementList
) is export {
    die "RakuDoc input file does not exist: $input"
        unless $input.e;

    my Str $source = $input.slurp;

    return $source.AST;
}

sub linearize-rakudoc(
    RakuAST::StatementList $ast,
    --> Array
) is export {
    my @blocks;
    my Int $sequence = 0;
    my Int $heading-depth = 0;

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

    sub clean-text(
        $text,
        --> Str
    ) {
        my Str $result = $text.Str;

        $result ~~ s/\n+$//;

        return $result;
    }

    sub walk-doc(
        $node
    ) {
        if $node ~~ RakuAST::Doc::Block {
            my Str $type = $node.type.Str;

            if $type eq 'pod' {
                for $node.paragraphs -> $paragraph {
                    walk-doc($paragraph);
                }
            }
            elsif $type eq 'head' {
                my Int $level = $node.level.Int;
                $heading-depth = $level - 1;

                my Str $text = '';

                for $node.paragraphs -> $paragraph {
                    $text ~= $paragraph.Str;
                }

                add-block(
                    'heading',
                    :$level,
                    :depth($heading-depth),
                    :text(clean-text($text)),
                );
            }

            # new code
            elsif $type eq 'item' {
                my Str $text = '';

                for $node.paragraphs -> $paragraph {
                    $text ~= $paragraph.Str;
                }

                add-block(
                    'item',
                    :depth($heading-depth + 1),
                    :text(clean-text($text)),
                );
            }
            # end new code

            elsif $type eq 'code' {
                my Str $text = '';

                for $node.paragraphs -> $paragraph {
                    $text ~= $paragraph.Str;
                }

                add-block(
                    'code',
                    :text(clean-text($text)),
                );
            }

            return;
        }

        if $node ~~ Str {
            my Str $text = clean-text($node);

            if $text.chars {
                add-block(
                    'paragraph',
                    :$text,
                );
            }
        }
    }

    sub find-doc(
        $node
    ) {
        if $node ~~ RakuAST::Doc::Block {
            walk-doc($node);
            return;
        }

        if $node.^can('visit-children') {
           $node.visit-children: -> $child {
               find-doc($child);
           }
        }
    }

    find-doc($ast);

    return @blocks.Array;

}
