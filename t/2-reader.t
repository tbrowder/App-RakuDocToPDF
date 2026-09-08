use v6.d;
use Test;

use App::RakuDocToPDF::Reader;

my IO::Path $file = $*TMPDIR.add("rakudoc-reader-{$*PID}.rakudoc");
LEAVE unlink $file if $file.e;

spurt $file, q:to/END/;
=begin pod

=head1 NAME

B<Demo> - a small document

=item first item

=begin code
say "hello";
=end code

=end pod
END

my @blocks = read-rakudoc($file);

plan 9;

is @blocks.elems, 4, 'four blocks read';
is @blocks[0]<type>, 'heading', 'first block is heading';
is @blocks[0]<level>, 1, 'heading level read';
is @blocks[0]<text>, 'NAME', 'heading text read';
is @blocks[1]<type>, 'paragraph', 'paragraph read';
is @blocks[1]<text>, 'Demo - a small document', 'inline bold markup reduced to visible text';
is @blocks[2]<type>, 'item', 'item read';
is @blocks[2]<text>, 'first item', 'item text read';
is @blocks[3]<text>, 'say "hello";', 'code block retained';
