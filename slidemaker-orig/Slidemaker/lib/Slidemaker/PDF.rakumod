unit module Slidemaker::PDF;

use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;
use PDF::Content::Font;
use Pod::To::PDF::Lite;

use Compress::PDF;

use Slidemaker::RakudocUtils;
use Slidemaker::Classes;

sub fix-title(
    :$page!,
    :$debug,
    ) is export {
    # box the top part of the slide
    # color it
    # overlay white title and any subtitle
    my $g = $page.gfx;
    $g.Save;
    $g.Restore;
}

sub slide2pdf(
    Slide $slide,
    Config :$config,
    :$debug,
    --> PDF::Lite
    ) is export {
}

# my @slide-pdfs = slides2pdf @slides, :$config, :$debug;
sub slides2pdf(
    # combines into one, compressed PDF file
    @slides-pdf,  # PDF objects (one-page each)
    Config :$config!,
    :$ofil!,
    :$debug,
    --> PDF::Lite
    ) is export {

    # each slide object creates a separate PDF::Lite file
    for @slides-pdf -> $s {
    }
}

=begin comment
sub combine-pdfs(
    @slides-pdf,  # PDF objects (one-page each)
    :$debug,
    --> PDF::Lite
    ) is export {

    # each slide object creates a separate PDF::Lite file
    for @slides-pdf -> $s {
    }
}
=end comment

=begin comment

my %m = %(PageSizes.enums);
my @m = %m.keys.sort;
my $media = 'Letter';

my ($text, $page);
my $landscape = 1;
my $upside-down = 0;
my $pdf = PDF::Lite.new;
my $font = $pdf.core-font(:family<Times-Roman>, :weight<bold>); # good
for 1..6 -> $page-num {
    my $text = @pagecontent[$page-num-1];
    $pdf.media-box = %(PageSizes.enums){$media};
    $page = $pdf.add-page;
    make-page :$pdf, :$page, :$text, :$font, :$media, :$landscape, :$upside-down;
}

# finish the document
$pdf.save-as: $ofile;
say "See output file: $ofile";

=end comment

# subroutines
sub make-page(
              PDF::Lite :$pdf!,
              PDF::Lite::Page :$page!,
              :$text!,
              :$font!,
              :$media,
              :$landscape,
              :$upside-down,
) is export {

    # using make-page, modified, from PDF::Document.make-page
    # always save the CTM
    $page.media-box = %(PageSizes.enums){$media};
    $page.graphics: {
        # always save the CTM
        .Save;

        my ($cx, $cy);
        my ($w, $h);
        if $landscape {
            if not $upside-down {
                =begin comment
                           x=2, y=3


                x=0, y=1
                =end comment

                # translate from: lower-left corner to: lower-right corner
                # LLX, LLY -> URX, LLY
                .transform: :translate($page.media-box[2], $page.media-box[1]);
                # rotate: left (ccw) 90 degrees
                .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees
                $w = $page.media-box[3] - $page.media-box[1];
                $h = $page.media-box[2] - $page.media-box[0];
            }
            else {
                # $upside-down: invert the page image
                # translate from: lower-left corner to: upper-left corner
                # LLX, LLY -> LLX, URY
                .transform: :translate($page.media-box[0], $page.media-box[3]);
                # rotate: right (cw) 90 degrees
                .transform: :rotate(-90 * pi/180); # right (cw) 90 degrees
                # Media edge lengths should be the same because the media-box array
                # doesn't change with transformations unless the user
                # spexifically changes it.
                $w = $page.media-box[3] - $page.media-box[1];
                $h = $page.media-box[2] - $page.media-box[0];
            }
        }
        else {
            $w = $page.media-box[2] - $page.media-box[0];
            $h = $page.media-box[3] - $page.media-box[1];
        }

        $cx = 0.5 * $w;
        $cy = 0.5 * $h;
        my @position = [$cx, $cy];
        my @box = .print: $text, :@position, :$font,
        :align<center>, :valign<center>;

        # and restore the CTM
        .Restore;
    }

    =begin comment
    my ($cx, $cy);
    if $media {
        # use the page media-box
        $page.media-box = %(PageSizes.enums){$media};
        $cx = 0.5 * ($page.media-box[2] - $page.media-box[0]);
        $cy = 0.5 * ($page.media-box[3] - $page.media-box[1]);
    }
    else {
        $cx = 0.5 * ($pdf.media-box[2] - $pdf.media-box[0]);
        $cy = 0.5 * ($pdf.media-box[3] - $pdf.media-box[1]);
    }

    $page.graphics: {
        #my @box = .say: "Second page", :@position, :$font, :align<center>, :valign<center>;
        .print: $text, :position[$cx, $cy], :$font, :align<center>, :valign<center>;
    }
    =end comment
}

=begin comment
# file: boxes-and-graphics.raku from Calendar/dev
#!/bin/env raku

use v6;
use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;

my $ofile = "draw-cells.pdf";
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Demonstrates drawing cells containing text and graphics.
    HERE
    exit
}

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
# letter, portrait
$page.media-box = [0, 0, 8.5*72, 11*72];

my $height = 1*72;
my $width  = 1.5*72;
my $x0     = 0.5*72;
my $y0     = 8*72;

for 1..3 -> $i {
    my $x = $x0 + $i * $width;
    my $text = "Number $i";
    draw-cell :$text, :$page, :x0($x), :$y0, :$width, :$height;
    write-cell-line :$text, :$page, :x0($x), :$y0, :$width, :$height,
                     :Halign<left>;
}

$pdf.save-as: $ofile;
say "See output file: ", $ofile;

#==== subroutines

sub write-cell-line(
    # text only
    :$text = "<text>",
    :$page!,
    :$x0!, :$y0!, # the desired text origin
    :$width!, :$height!,
    :$Halign = "center",
    :$Valign = "center",
) {
    $page.text: {
        # $x0, $y0 MUST be the desired origin for the text
        .text-transform: :translate($x0+0.5*$width, $y0-0.5*$height);
        .font = .core-font('Helvetica'), 15;
        with $Halign {
            when /left/   { :align<left> }
            when /center/ { :align<center> }
            when /right/  { :align<right> }
            default {
                :align<left>;
            }
        }
        with $Valign {
            when /top/    { :valign<top> }
            when /center/ { :valign<center> }
            when /bottom/ { :valign<bottom> }
            default {
                :valign<center>;
            }
        }
        .print: $text, :align<center>, :valign<center>;
    }
}

sub draw-cell(
    # graphics only
    :$text,
    :$page!,
    :$x0!, :$y0!, # upper left corner
    :$width!, :$height!,
    ) is export {

    # Note we bound the area by width and height and put any
    # graphics inside that area.
    $page.graphics: {
        .Save;
        .transform: :translate($x0, $y0);
        # color the entire form
        .StrokeColor = color Black;
        #.FillColor = rgb(0, 0, 0); #color Black
        .LineWidth = 2;
        .Rectangle(0, -$height, $width, $height);
        .Stroke; #paint: :fill, :stroke;
        .Restore;
    }
}
=end comment
