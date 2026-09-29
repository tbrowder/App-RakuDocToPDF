#!/usr/bin/env raku

use experimental :rakuast;

%*ENV<RAKUDO_RAKUAST> = 1;
#use Slidemaker::RakuDoc::To::Parts;
use RakuDoc::To::RakuDoc;

my $ifil = "resources/real-pod-example.rakudoc";

=begin comment
my $ast = $ifil.IO.slurp.AST;
#my @ast = $ifil.IO.slurp.AST;

#say rakudoc2parts($ast);
#say RakuDoc::To::RakuDoc.render($ast);
say RakuDoc::To::RakuDoc.render(@ast);
=end comment

raku --rakudoc $ifil;
