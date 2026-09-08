#!/usr/bin/env raku

use JSON::Fast;

my $file = "META6.json".IO;

die "FATAL: Cannot find '$file'"
    unless $file.f;

my %meta = from-json $file.slurp;

exit 0
    if %meta<api>:exists;

%meta<api> = 0;

$file.spurt: to-json(%meta, :pretty, :sorted-keys);

say "Added initial api value 0 to META6.json";
