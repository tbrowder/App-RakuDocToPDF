use v6.d;
use Test;

use App::RakuDocToPDF::Reader;

my $file = $*TMPDIR.add("rakudoc2pdf-linear-$*PID.rakudoc");
LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
=begin pod

=head1 NAME

Top-level paragraph.

=head2 DETAILS

Second-level paragraph.

=item First item

=code say 'hello';

=end pod
END

my @blocks = read-rakudoc($file);
my @seq;
my @types;
my @depths;

for @blocks -> %block {
    @seq.push: %block<seq>;
    @types.push: %block<type>;
    @depths.push: %block<depth>;
}

is @blocks.elems, 6, 'six linear blocks';
is-deeply @seq, [1, 2, 3, 4, 5, 6],
'blocks have consecutive sequence numbers';

my @expected = <heading paragraph heading paragraph item code>;
my @got;

for @blocks -> %block {
    @got.push: %block<type>;
}

is-deeply @got, @expected,
    'block order is preserved';



is-deeply @types,
    <heading paragraph heading paragraph item code>,
    'block order is preserved';

is-deeply @depths, [0, 0, 1, 1, 2, 1],
    'blocks have explicit finite depth values';
is @blocks[0]<level>, 1, 'head1 retains heading level';
is @blocks[2]<level>, 2, 'head2 retains heading level';

done-testing;
