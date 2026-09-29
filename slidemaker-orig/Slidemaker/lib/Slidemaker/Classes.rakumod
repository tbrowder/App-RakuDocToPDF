unit module Slidemaker::Classes;

class Config is export {
    # line index number where found (0-indexed)
    has $.i is required;
    # raw lines with keyed pairs
    has @.lines;
    # resulting hash
    has %.config;

    submethod TWEAK {
    }
}

class Slide is export {

    # line index number where found (0-indexed)
    has $.i is required;
    has $.title;
    has @.raw-lines; # as input
    has %.config;

    submethod TWEAK {
    }
}

