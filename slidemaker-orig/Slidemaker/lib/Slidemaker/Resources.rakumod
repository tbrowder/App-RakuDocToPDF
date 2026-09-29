unit module Slidemaker::Resources; # source is copy of: ExampleLib::UseResources;

#===== exported routines
sub show-resources(:$debug --> List) is export {
    my %h = get-resources-hash;
    say "Resources:";
    say "  $_" for %h.keys.sort;
}

sub download-resources(:$debug --> List) is export {
    my %h = get-resources-hash;
    say "Resources:";
    for %h.keys.sort -> $basename {
        my $path = %h{$basename};
        my $s = get-content $path;
        spurt $basename, $s;
        say "  $basename";
    }
}

sub get-resources-hash(:$debug --> Hash) is export {
    my @list = get-resources-paths;
    # convert to a hash: key: file.basename => path
    my %h;
    for @list -> $path {
        my $f = $path.IO.basename;
        %h{$f} = $path;
    }
    %h
}

sub get-content($path, :$nlines = 0) is export {
    my $exists = resource-exists $path;
    unless $exists { return 0; }

    my $s = $?DISTRIBUTION.content($path).open.slurp;
    if $nlines {
        my @lines = $s.lines;
        my $nl = @lines.elems;
        if $nl >= $nlines {
            $s.lines[0..$nlines-1].join("\n");
        }
        else {
            $s;
        }
    }
    else {
        $s
    }
} # sub get-content($path, :$nlines = 0) is export {

#===== non-exported routines
sub get-resources-paths(:$debug --> List) {
    my @list =
        $?DISTRIBUTION.meta<resources>.map({"resources/$_"});
    @list
}

sub resource-exists($path? --> Bool) {
    return False if not $path.defined;

    # "eats" both warnings and errors; fix coming to Zef
    # as of 2023-10-29
    # current working code courtesy of @ugexe
    try {
        so quietly $?DISTRIBUTION.content($path).open(:r).close; # may die
    } // False;
}
