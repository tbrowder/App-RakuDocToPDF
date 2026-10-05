use v6.d;

unit module App::RakuDocToPDF;

use PDF::API6;
use PDF::Content::FontObj;
use PDF::Page;

use App::RakuDocToPDF::DocumentType;
use App::RakuDocToPDF::Drawing::Parser;
use App::RakuDocToPDF::Drawing::Renderer;
use App::RakuDocToPDF::Layout;
use App::RakuDocToPDF::Media;
use App::RakuDocToPDF::RakuASTReader;
use App::RakuDocToPDF::SlideLayout;
use App::RakuDocToPDF::SlideMaker;

sub deterministic-pdf-id(
    Str $text,
    --> Str
) {
    my UInt $hash-one = 2166136261;
    my UInt $hash-two = 1315423911;

    for $text.encode.list -> $byte {
        $hash-one = (($hash-one +^ $byte) * 16777619) +& 0xffffffff;
        $hash-two = (($hash-two +^ $byte) * 2246822519) +& 0xffffffff;
    }

    my @values = (
        $hash-one,
        $hash-two,
        $hash-one +^ 0xa5a5a5a5,
        $hash-two +^ 0x5a5a5a5a,
    );

    my @bytes;
    for @values -> $value {
        for 0, 8, 16, 24 -> $shift {
            @bytes.push: (($value +> $shift) +& 0xff);
        }
    }

    return Buf.new(@bytes).decode('latin-1');
}

sub normalize-style(
    $style is copy,
    --> Str
) {
    $style .= Str;
    $style .= lc;

    return $style if $style eq 'document';
    return $style if $style eq 'slides';
    return $style if $style eq 'drawing';

    die "Unknown PDF style '$style'. Expected one of: document, slides, drawing.";
}

sub rakudoc-to-pdf(
    $input,
    :$output,
    :$media = 'Letter',
    :$type = 'generic',
    :$style = 'document',
    --> IO::Path
) is export {

    my IO::Path $source = $input.IO;
    die "RakuDoc file '$source' does not exist." unless $source.e;

    my IO::Path $destination;
    if $output.defined {
        $destination = $output.IO;
    }
    else {
        my Str $basename = $source.basename;
        if $basename.ends-with('.rakudoc') {
            $basename = $basename.substr(0, $basename.chars - 8);
        }
        $destination = "$basename.pdf".IO;
    }

    my Str $document-type = normalize-document-type($type);
    my Str $pdf-style = normalize-style($style);

    #my @blocks = read-rakudoc($source);
    my @blocks = read-rakudoc-rakuast($source);

    if $pdf-style eq 'drawing' {
        my @drawing-blocks;

        for @blocks -> %block {
            if %block<type> eq 'drawing' {
                @drawing-blocks.push(%block);
            }
        }

        die "Drawing style requires one '=begin drawing' block."
            unless @drawing-blocks.elems;

        die "Drawing style currently supports only one drawing block."
            if @drawing-blocks.elems > 1;

        my $spec = parse-drawing(
            @drawing-blocks[0]<text>
        );

        render-drawing(
            $spec,
            :output($destination.Str),
        );

        return $destination;
    }

    my @issues = validate-document(
        @blocks,
        :type($document-type),
    );

    if @issues.elems {
        my Str $message = "Document validation failed for type '$document-type':";
        for @issues -> $issue {
            $message ~= "\n  - $issue";
        }
        die $message;
    }

    if $pdf-style eq 'slides' {
        my $deck = make-slides(@blocks);
        my Str $pdf-id = deterministic-pdf-id(
            $source.slurp ~ "\0slides"
        );

        return render-slides(
            $deck,
            $destination,
            :$pdf-id,
            :base-dir($source.parent),
        );
    }

    my @box = media-box($media);
    my Numeric $width = media-width($media);
    my Numeric $height = media-height($media);

    my PDF::API6 $pdf .= new;
    $pdf.id = deterministic-pdf-id($source.slurp ~ "\0{$media.Str.lc}");
    my PDF::Content::FontObj $body-font = $pdf.core-font('Times-Roman');
    my PDF::Content::FontObj $heading-font = $pdf.core-font: :family<Helvetica>, :weight<bold>;
    my PDF::Content::FontObj $code-font = $pdf.core-font('Courier');
    my PDF::Content::FontObj $footer-font = $pdf.core-font('Helvetica');

    my %fonts = (
        body    => $body-font,
        heading => $heading-font,
        code    => $code-font,
        footer  => $footer-font,
    );

    my @pages = layout-pages(
        @blocks,
        %fonts,
        :page-width($width),
        :page-height($height),
    );

    my Int $total-pages = @pages.elems;
    my Int $number = 0;

    for @pages -> @lines {
        $number++;
        my PDF::Page $page = $pdf.add-page;
        $page.media-box = @box;

        $page.text: {
            for @lines -> %line {
                .font = %fonts{%line<font>}, %line<size>;
                .text-position = %line<x>, %line<y>;
                .say: %line<text>;
            }

            my Str $footer = "Page $number of $total-pages";
            my Numeric $footer-size = 9;
            my Numeric $footer-width = $footer-font.stringwidth(
                $footer,
                $footer-size,
            );
            my Numeric $footer-x = ($width - $footer-width) / 2;

            .font = $footer-font, $footer-size;
            .text-position = $footer-x, 24;
            .say: $footer;
        }
    }

    $pdf.save-as: $destination.Str, :!info;
    return $destination;
}
