unit module PDF::Subs;

use PDF::Content;
use PDF::Lite;
use Text::Utils :strip-comment, :normalize-string;

class Config is export {
    has @.pdfs;

    has $.simple    = False;
    has $.zip       = 150;              # undefined or "150" or "300"

    has $.numbers   = False;
    has $.two-sided = False;
    has $.back      = False;

    has $.margins   = 1 * 72;
    has $.paper     = "Letter";

    has $.outfile;
    has @.title;
    has @.preface;
    has @.afterword;

    has $.title-font;
    has $.title-font-size;
    has $.subtitle-font;
    has $.subtitle-font-size;

    # paper and other info
    method set-option($opt, $val) {
        if not $val.defined {
            die "FATAL: Unexpected undefined value for option '$opt";
        }
        sub return-bool($val --> Bool) {
            my $res;
            if $val ~~ Bool {
                $res = $val
            }
            elsif $val ~~ Str {
                $res = $val ~~ /:i true / ?? True !! False
            }
            $res
        }
        with $opt {
            when /:i numbers / {
                $!numbers = return-bool $val
            }
            when /:i 'two-sided' / {
                $!two-sided = return-bool $val
            }
            when /:i back / {
                $!back = return-bool $val
            }
            when /:i margins / {
                $!margins = $val
            }
            when /:i paper / {
                $!paper = $val
            }
            when /:i outfile / {
                $!outfile = $val
            }
            when /:i simple / {
                $!simple = True
            }
            =begin comment
            when /^ :i '=' zip / {

                if not $val.defined {
                    $!zip = 150;
                }
                else {
                    $val .= Int;
                    if $val  < 150 {
                        $!zip = 150;
                    }
                    else {
                        unless $val == 150 or $val == 300 {
                            die "FATAL: zip value must be 150 or 300, val is '$val'";
                        }
                        $!zip = $val;
                    }
                    $!zip = 150;
                }
                else {
                    $!zip = 0;
                }

            }
            =end comment
            =begin comment
            when /:i zip ['=' (\d+)]? $/ {
                if $0.defined {
                    $val = +$0;
                    unless $val ~~ /150|300/ {
                        die "FATAL: zip value must be 150 or 300, val is '$val'";
                    }
                    $!zip = $val
                }
                elsif $val !~~ /150|300/ {
                    die "FATAL: zip value must be 150 or 300, val is '$val'";
                }
                else {
                    $!zip = $val
                }
            }
            =end comment
            default {
                die "FATAL: Unrecognized option '$opt'";
            }

        }
    }
    method add-file($f) {
        @!pdfs.push: $f
    }
    method add-title-line($s) {
        @!title.push: $s
    }
    method add-preface-line($s) {
        @!preface.push: $s
    }
}

sub simple-combine(
    @pdfs!,
    $outfile!,
    :$debug,
) is export {
    say "In routine 'simple-combine'";
}

# add a cover for the collection
sub make-cover-page(PDF::Lite::Page $page,
             Config :$config,
                    :$font,
                    :$font2,
                    :$centerx,
                    :$debug
                   ) is export {
    $page.text: -> $txt {      # $txt is a child of the $page
        my ($text, $baseline);

        $baseline = 7*72;
        $txt.font = $font, 16;
        $text = $config.title.head; # $new-title;

        $txt.text-position = 0, $baseline; # baseline height is determined here
        # output aligned text
        $txt.say: $text, :align<center>, :position[$centerx];

        $txt.font = $font2, 14;
        #$baseline -= 60;
        #$txt.text-position = 0, $baseline; # baseline height is determined here
        #$txt.say: "by", :align<center>, :position[$centerx];

        $baseline -= 30;
        my @text = $config.title[1..*]; # "Tony O'Dell", "2022-09-23",
                                        # "[https://deathbykeystroke.com]";
        for @text -> $text {
            $baseline -= 20;
            $txt.text-position = 0, $baseline; # baseline height is determined here
            $txt.say: $text, :align<center>, :position[$centerx];
        }
    }
}

sub select-font() {
}

sub read-config-file($fnam, :$debug --> Config) is export {
    my $c = Config.new;

    my $dir = $fnam.IO.parent;
    my $in-title    = False;
    my $in-preface = False;

    LINE: for $fnam.IO.lines -> $line is copy {
        $line = strip-comment $line;
        next if not ($in-title or $in-preface) and $line !~~ /\S/;

        if $line ~~ /\h* '='(\S+) \h* $/ {
            # a naked option
            my $opt = ~$0.lc;
            my $val = True;
            $c.set-option: $opt, $val;
            note "DEBUG: naked \$opt = '$opt'" if $debug;
        }
        elsif $line ~~ /\h* '='(\S+) \h+ (\N+) / {
            # =option value
            # =begin title | preface
            # =end   title | preface
            my $opt = ~$0.lc;
            my $val = normalize-string ~$1;

            if $opt ~~ /:i (begin|end) / {
                my $select = ~$0.lc;
                with $val {
                    when /:i title/ {
                        $in-title = $select eq "begin" ?? True !! False;
                    }
                    when /:i preface/ {
                        $in-preface = $select eq "begin" ?? True !! False;
                    }
                    default {
                        die "FATAL: Unexpected \$opt value '$_'";
                    }
                }
                next LINE
            }

            $c.set-option: $opt, $val;
            if $debug and $opt ~~ /'two-sided'/ {
                note "DEBUG: found two-sided";
                note "DEBUG: \$val = '$val'"
            }
        }
        else {
            # file name or title line (which may be blank)
            my $val = normalize-string $line;
            note "DEBUG: \$val = '$val'" if $debug;
            if $in-title  {
                $c.add-title-line: $val;
                next LINE;
            }
            elsif $in-preface {
                $c.add-preface-line: $val;
                next LINE;
            }

            my $f = $val.words.head;
            note "DEBUG: \$f = '$f'" if $debug;
            my $path = "$dir/$f";
            note "DEBUG: \$path = '$path'" if $debug;
            unless $path.IO.f {
                note "WARNING: File '$path' not found. Ignoring it.";
                next LINE;
            }
            $c.add-file: $path;
        }
    }

    # sanity check
    unless $c.pdfs.elems {
        note "FATAL: No pdf files found in project directory '$dir'";
        exit;
    }

    $c
} # sub read-config-file($fnam, :$debug --> Config) is export {

sub report-status(Config $c, |c) is export {
} # sub report-status(Config $c, |c) is export {
