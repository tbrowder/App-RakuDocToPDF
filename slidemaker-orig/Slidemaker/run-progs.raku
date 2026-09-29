#!/usr/bin/env raku

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {} c | u

    c - create-slides
    u - unpack-pod.raku

    HERE
    exit;
}

for @*ARGS {
    when /^ :i c/ {
        shell "raku -I. bin/create-slides";
    }
    when /^ :i u/ {
        shell "raku -I. bin/unpack-pod.raku";
    }
}
