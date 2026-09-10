use v6.d;

unit module App::RakuDocToPDF::DocumentType;

our constant @DOCUMENT-TYPES is export = <generic module-readme>;

sub normalize-document-type(
    $type is copy,
    --> Str
) is export {
    $type .= Str;
    $type .= lc;

    for @DOCUMENT-TYPES -> $known-type {
        return $known-type if $type eq $known-type;
    }

    die "Unknown document type '$type'. Expected one of: {@DOCUMENT-TYPES.join(', ')}.";
}

sub validate-document(
    @blocks,
    :$type = 'generic',
    --> Array
) is export {
    my Str $document-type = normalize-document-type($type);

    return [] if $document-type eq 'generic';

    my @issues;
    my Int $title-count = 0;
    my Int $subtitle-count = 0;
    my Bool $title-seen = False;
    my Bool $name-seen = False;

    for @blocks -> %block {
        given %block<type> {
            when 'title' {
                ++$title-count;
                $title-seen = True;
            }
            when 'subtitle' {
                ++$subtitle-count;
                unless $title-seen {
                    @issues.push: '=SUBTITLE occurs before =TITLE';
                }
            }
            when 'heading' {
                if %block<level> == 1 and %block<text>.uc eq 'NAME' {
                    $name-seen = True;
                }
            }
        }
    }

    if $title-count > 1 {
        @issues.push: 'duplicate =TITLE';
    }

    if $subtitle-count > 1 {
        @issues.push: 'duplicate =SUBTITLE';
    }

    unless $name-seen {
        @issues.push: 'module-readme document has no =head1 NAME section';
    }

    return @issues.Array;
}
