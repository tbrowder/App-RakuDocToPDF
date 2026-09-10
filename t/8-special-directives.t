use v6.d;
use Test;

use App::RakuDocToPDF::Reader;

my $file = $*TMPDIR.add("rakudoc2pdf-special-directives-$*PID.rakudoc");
LEAVE $file.unlink if $file.e;

$file.spurt: q:to/END/;
=begin pod

=TITLE App::Example
=SUBTITLE Example module documentation

=head1 NAME

App::Example

=slide

=head1 DESCRIPTION

Example text.

=end pod
END

my @blocks = read-rakudoc($file);
my @types;
for @blocks -> %block {
    @types.push: %block<type>;
}

is-deeply @types,
    [<title subtitle heading paragraph slide heading paragraph>],
    'special directives retain their position in the linear representation';

is @blocks[0]<text>, 'App::Example', '=TITLE text is retained';
is @blocks[0]<depth>, 0, '=TITLE is document-level';
is @blocks[1]<text>, 'Example module documentation', '=SUBTITLE text is retained';
is @blocks[1]<depth>, 0, '=SUBTITLE is document-level';
is @blocks[4]<text>, '', '=slide is a standalone marker';
is @blocks[4]<seq>, 5, '=slide participates in the linear sequence';

done-testing;
