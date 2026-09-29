unit module PDF::Combiner;

use PDF::Lite;
use PDF::Font::Loader;

use PDF::Combiner::Subs;

=begin comment
my enum Paper <Letter A4>;
my $debug   = 0;
my $left    = 1 * 72; # inches => PS points
my $right   = 1 * 72; # inches => PS points
my $top     = 1 * 72; # inches => PS points
my $bottom  = 1 * 72; # inches => PS points
my $margin  = 1 * 72; # inches => PS points
my Paper $paper  = Letter;
my $page-numbers = False;

# defaults for US Letter paper
my $height = 11.0 * 72;
my $width  =  8.5 * 72;
# for A4
# $height =; # 11.7 in
# $width = ; #  8.3 in
=end comment

multi sub run-cli() is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} config=my-pdf-project.txt

    Args
        config=X - where X is the name of a configuration file listing various
                   options as well as a list of PDF documents to be combined,
                   one name or option per line, comments and blank lines are
                   ignored. See the 'example-projects' directory for examples.

    Options
        ofile=X  - where X is the desired output file name (which overrides
                   the 'outfile' setting in the configuration file).
        zip[=X]  - where X is the PDF compression level: '150' or '300' DPI.
                   Output files will get an approriate name extension of
                   '.150dpi.pdf' or '.300dpi.pdf'. [default: 150]

    'config' file options when present in the file
        =simple    Bool [explicit 'true' or 'false' OR, with no value:
                     True if present, False if not]
                     All other options are ignored except 'zip'


        =numbers   Bool [explicit 'true' or 'false' OR, with no value:
                     True if present, False if not]

                   produces page numbers on each page
                   except the cover which is number
                   'i' one but not shown; format: 'Page N of M'
                   (a title page by default gets a blank reverse page
                    which is page 'ii' but is not shown)

        =begin title # empty or no title bock: no cover page
                   title line for the cover page
                   # a retained blank line for the cover page
                   another title line for the cover page
        =end title
        =two-sided Bool [explicit 'true' or 'false' OR, with no value:
                     True if present, False if not]
        =back      Bool [explicit 'true' or 'false' OR, with no value:
                     True if present, False if not]
        =outfile   file name of the new document
        =paper     'Letter' or 'A4' [default: Letter]
        =margins   size in PostScript points [default: 72 (one inch)]
        =compress  empty OR 150 or 300 [default: empty (none)]]

    Combines the input PDFs into one document
    HERE
    exit
} # multi sub run-cli() is export {

multi sub run-cli(@args) is export {

    # run all from here while calling into PDF::Combiner::Subs
    my $debug = 0;
    my Config $c;
    my $ofile;
    my $zip;

    # default config file for debugging;
    my $IFIL  = "example-project/our-israel-trip.txt";
    my $IFIL2 = "/home/tbrowde/mydata/tbrowde-home/israel-trip-1980/our-israel-trip.txt";

    my $ifil;
    for @args {
        when /^:i d/ {
            ++$debug;
            $ifil = $IFIL;
            note "DEBUG is on";
        }
        when /^:i e/ { # e = exercise
            $ifil = $IFIL2;
        }
        when /^:i o[file]? '=' (\S+) / {
            $ofile = ~$0;
        }
        when /^:i z[ip]? '=' (\d\d\d) / {
            $zip = ~$0;
            unless $zip eq '150' or $zip eq '300' {
                say "FATAL: zip values must be 150 or 300, you entered '$zip'";
                exit;
            }
        }
        when /^config '=' (\S+) $/ {
            $ifil = ~$0;
            unless $ifil.IO.r {
                say "FATAL: Unable to open config file '$ifil'";
                exit;
            }
        }
        default {
            say "FATAL: Unknown arg '$_'"; exit;
        }
    }

    # Start with a NEW and empty PDF.
    my $parent-pdf = PDF::Lite.new;

    # collect data
    $c = read-config-file $ifil, :$debug;

    my @pdf-objs;
    if $c.simple {
        my $ofil  = $c.outfile;
        my @files = $c.pdfs;
        # combine, output to a file, and report
        simple-combine @files, :$debug;

        say "Finished a simple combine";
        say "See output file '$ofile'";
        exit
    }

    for $c.pdfs -> $pdf-in {
        my $pdf-obj = PDF::Lite.open: $pdf-in;
        @pdf-objs.push: $pdf-obj;
    }

    # do we need to specify 'media-box'?
    my ($centerx, $height, $width);
    my $pdf = PDF::Lite.new;
    if $c.paper eq "Letter" {
        $pdf.media-box = 'Letter';
        $height = 11.0 * 72;
        $width  =  8.5 * 72;
    }
    else {
        $pdf.media-box = 'A4';
        $height = 11.7 * 72;
        $width  =  8.3 * 72;
    }
    $centerx = 0.5 * $width;

    # manipulate the PDF some more
    my $tot-pages = 0;

    my PDF::Lite::Page $page;

    # do we need a cover?
    my @tlines;
    if $c.title.elems {
        for $c.title.values -> $val {
            @tlines.push($val) if $val ~~ /\S+/
        }
    }

    my $has-cover = False;
    my $two-sided = $c.two-sided;
    my $has-back  = $c.back;
    if @tlines.elems {
        $has-cover = True;
        # add a cover for the collection
        $page = $pdf.add-page;
        my $font  = $pdf.core-font(:family<Times-RomanBold>);
        my $font2 = $pdf.core-font(:family<Times-Roman>);

        make-cover-page $page, :config($c), :$centerx, :$font, :$font2, :$debug;
        if $c.two-sided {
            # for now just add a blank page
            $page = $pdf.add-page;
        }
    }

    for @pdf-objs.kv -> $i, $pdf-obj {

        # handle multi-page files being combined
        my $part = $i+1;

        =begin comment
        # add a cover for part $part
        $page = $pdf.add-page;
        $page.text: -> $txt {
            my $text = "Part $part";
            $txt.font = $font, 16;
            $txt.text-position = 0, 7*72; # baseline height is determined here
            # output aligned text
            $txt.say: $text, :align<center>, :position[$centerx];
        }
        =end comment

        my $pc = $pdf-obj.page-count;
        say "Input doc $part: $pc pages";
        $tot-pages += $pc;
        for 1..$pc -> $page-num {
            $pdf.add-page: $pdf-obj.page($page-num);
            $parent-pdf.add-page: $pdf-obj.page($page-num);
        }
    }

    if $has-back {
        # add a single blank page
        $page = $pdf.add-page;
        say "A single page, empty back cover added.";
        $parent-pdf.add-page: $page;
    }

    if $c.numbers {
        say "Page numbers being added";
        # note we vary position of the number depending
        # on two-sided or not

        #method !paginate($pdf) {
        my $page-count = $pdf.Pages.page-count;
        my $font = $pdf.core-font: "Helvetica";
        my $font-size := 9;
        my $align := 'right';
        my $page-num = 0;
        --$page-count if $has-back;

        PAGE: for $pdf.Pages.iterate-pages -> $page {
            ++$page-num;
            next PAGE if $page-num == 1 and $has-cover;
            last PAGE if $has-back and $page-num > $page-count;
            #if $has-back and $page-num == $page-count {
            #    last;
            #}

            my PDF::Content $gfx = $page.gfx;

            my $is-odd = $page-num % 2 ?? True !! False;

            my $text = "Page {$page-num} of $page-count";
            my @position = $gfx.width - $c.margins, $c.margins - $font-size;
            if $c.two-sided and not $is-odd {
                # odd numbers on facing pages (obverse) are bottom right
                #   (or none on front cover)
                # even numbers on back side (reverse) are bottom left
                @position = 0 + $c.margins, $c.margins - $font-size;
                $gfx.print: $text, :@position, :$font, :$font-size, :align<left>;
            }
            else {
                $gfx.print: $text, :@position, :$font, :$font-size, :$align;
            }
            $page.finish;
        }
    }

    # report final results
    {
        # the parent
        my $tp = $parent-pdf.page-count;
        say "Parent pdf pages: $tp";
        my $outfile = $c.outfile;
        if $ofile.defined {
            $outfile = $ofile;
        }
        if $outfile !~~ /:i '.pdf'$/ {
            $outfile ~= '.pdf';
            # eliminate double dots
            $outfile ~~ s:g/'..'/./;
        }
        else {
            # lower-case the .pdf
            $outfile ~~ s/:i pdf$/pdf/;
        }
        $pdf.save-as: $outfile;
        say "See parent pdf: {$outfile}";
    }

    say "Total input pages: $tot-pages";
    my $new-pages = $pdf.page-count;

    my $outfile = $c.outfile;
    if $ofile.defined {
        $outfile = $ofile;
    }
    if $outfile !~~ /:i '.pdf'$/ {
        $outfile ~= '.pdf';
        # eliminate double dots
        $outfile ~~ s:g/'..'/./;
    }
    else {
        # lower-case the .pdf
        $outfile ~~ s/:i pdf$/pdf/;
    }

    my $Zip = $zip ?? $zip !! $c.zip;
    if $Zip {
        # insert the correct zip info
        $outfile ~~ s/'.pdf'$/.{$Zip}dpi.pdf/;
        my $tmpfil = "/tmp/pdfout.pdf";
        $pdf.save-as: $tmpfil;
        my $arg;
        if $Zip eq "150" {
            $arg = "-dPDFSETTINGS=/ebook";
        }
        elsif $Zip eq "300" {
            $arg = "-dPDFSETTINGS=/printer";
        }
        run "ps2pdf", $arg, $tmpfil, $outfile;
    }
    else {
        $pdf.save-as: $outfile;
    }
    say "See combined pdf: {$outfile}";
    say "Total pages: $new-pages";

} #multi sub run-cli(@args) is export {
#==== end of this file's content ============
