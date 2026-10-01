use Test;

use App::RakuDocToPDF;

=begin comment

This test uses a round-tripped slide deck from PDF to
Rakudoc to test slide PDF generation by Rakudoc.

=end comment

my $png11 = "./projects/why-linux/why-linux-slide-11.png".IO;
my $png12 = "./projects/why-linux/why-linux-slide-12.png".IO;
my $rd    = "./projects/why-linux/README".IO;
my $rdoc  = "./projects/why-linux/why-linux.rakudoc".IO;

# convert the rakudoc and pics to PDF
my $pdf   

=begin comment
sub rakudoc-to-pdf(
    $input,
    :$output,
    :$media = 'Letter',
    :$type = 'generic',
    --> IO::Path
) is export {
=end comment

rakudoc-to-pdf($rdoc, :output<test.pdf>, :type<slide>);



done-testing;

