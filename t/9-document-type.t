use v6.d;
use Test;

use App::RakuDocToPDF::DocumentType;
use App::RakuDocToPDF::Reader;

is normalize-document-type('generic'), 'generic', 'generic document type is known';
is normalize-document-type('MODULE-README'), 'module-readme', 'document type is case-insensitive';

my $good = $*TMPDIR.add("rakudoc2pdf-module-readme-good-$*PID.rakudoc");
my $bad = $*TMPDIR.add("rakudoc2pdf-module-readme-bad-$*PID.rakudoc");
LEAVE $good.unlink if $good.e;
LEAVE $bad.unlink if $bad.e;

$good.spurt: q:to/END/;
=begin pod
=TITLE App::Example
=SUBTITLE Example documentation
=head1 NAME
App::Example
=end pod
END

my @good-blocks = read-rakudoc($good);
my @good-issues = validate-document(@good-blocks, :type<module-readme>);
is @good-issues.elems, 0, 'valid module README has no document-type issues';

$bad.spurt: q:to/END/;
=begin pod
=SUBTITLE Too early
=TITLE First
=TITLE Second
=head1 DESCRIPTION
Example.
=end pod
END

my @bad-blocks = read-rakudoc($bad);
my @issues = validate-document(@bad-blocks, :type<module-readme>);

ok @issues.first(* eq '=SUBTITLE occurs before =TITLE').defined,
    'subtitle before title is reported';
ok @issues.first(* eq 'duplicate =TITLE').defined,
    'duplicate title is reported';
ok @issues.first(* eq 'module-readme document has no =head1 NAME section').defined,
    'missing NAME section is reported';

done-testing;
