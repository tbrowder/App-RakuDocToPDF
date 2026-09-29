#!/usr/bin/env raku

if 0 {
die qq:to/HERE/;
Tom, see work in module Slidemaker
   AND @finanalyst's rakuast-rakudoc-render
HERE
}

# Ideas:
#   treat like a vulnerability tree:
#
#   top-level nodes have no parent (except the rakudoc file)
#   every pod node has:
#        a link to its parent
#        a level number (increasing from zero)
#        a unique ID 
#        a list of its children's IDs

# master data for the entire document
my $numnodes = 0; # same as pod ID
my %nodes;        # hash of IDs and pod nodes

class PodNode {
    has UInt $.id     is required;
    has UInt $.parent is required; # the parent's ID
    has UInt $.level  is required;

    has UInt @.children; # their IDs
    has Str  $.text is rw = "";
    has Str  $.type;
    has      @.content; # from the original parse
}

# SEE COKE's link for reading a pod file:
# See details of RakuAST rakudoc parsing at:
#   http://github.com/Rakudo/rakudo/lib/RakuDoc/To/Text.rakumod

use experimental :rakuast;
#%*ENV<RAKUDO_RAKUAST> = 1;

#my $pod-file = "../docs/README.rakudoc";
#my $pod-file = "resources/example.rakudoc";
my $pod-file = "resources/real-pod-example.rakudoc";
my $ofil1    = "pod-dump.txt";
my $ofil2    = "pod-unhandled.txt";

my $debug = 0;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM} go | <rakudoc file>

    Extracts pod into a list of objects in a suitable format
    for processing into a PDF document.

    See details of RakuAST rakudoc parsing at:
        http://github.com/Rakudo/rakudo/lib/RakuDoc/To/Text.rakumod

    HERE
    exit;
}

for @*ARGS {
    when /^ :i d / {
        ++$debug;
    }
    when /^ :i 'doc=' (\S+) / {
        $pod-file = ~$0;
        unless $pod-file.IO.r {
            die "FATAL: Unable to open input file '$pod-file'";
        }
        say "Proccessing input file '$pod-file'";
    }
}

my @unhandled-pod;
my @pod-chunks; # a global array to collect chunks from the pod walk

#for $pod-file.IO.slurp.AST.rakudoc -> $pod-node {
for $pod-file.IO.slurp.AST -> $pod-node {
    #say $pod-node.WHAT;
    say dd $pod-node;
    exit;

    =begin comment
    a $pod-node is roughly same as $ast in 
        multi sub rakudoc2text(
            RakuAST::Doc::Block:D $ast
            --> Str
        )
    the $ast handling is further broken down by $ast.type into
    specialized multi subs:
        alias            ''
        code             code2text($ast)
        comment          ''
        config           ''
        head             heading2text($ast)
        implicit-code
        item
        pod
        rakudoc
        table
        default          block2text($ast)
    =end comment

     
    #dd $pod-node;
    #next;

    #say dd $pod-node;
    #exit;
    #  $=pod

    walk-pod $pod-node, :parent(0), :level(0); # top-level pod;
}

if @pod-chunks {
    my $ofil = "pod-chunks.txt";

    my $fh = open $ofil, :w;
    $fh.say: "#== Dumping pod chunks:";
    $fh.say: "  $_" for @pod-chunks;
    $fh.say: "#== End Dumping pod chunks";
    $fh.close;
    my $nlines = $ofil.IO.lines.elems - 2;
    say "See file '$ofil' ($nlines lines)";
}

if @unhandled-pod {
    my $ofil = "pod-unhandled.txt";

    my $fh = open $ofil, :w;
    $fh.say: "#== Dumping unhandled pod:";
    $fh.say: "  $_" for @pod-chunks;
    $fh.say: "#== End Dumping unhandled pod";
    $fh.close;
    my $nlines = $ofil.IO.lines.elems - 2;
    say "See file '$ofil' ($nlines lines)";
}

say "Found $numnodes pod nodes.";

# my $numnodes = 0; # same as pod ID
# my %nodes;        # hash of IDs and pod nodes
say "Nodes in order:";
my @k = %nodes.keys;
for @k.sort({$^a <=> $^bi}) -> $id {
    my $n = %nodes{$id};
    my $level = $n.level;
    my $txt = $n.text;
    $txt ~~ s:g/\s+/ /;

    my $s = "   " xx $level;
    say "$s $level id: $id '$txt'";
    next;

    say " $id";
}


#=== subroutines ====
sub walk-pod($node, :$parent, :$level, :$debug) is export {
    ++$numnodes;
    my $id = $numnodes;
    say "  New pod node ID: $id";
    say "    parent: $parent";
    say "    parents's level: $level";
    say "    child level:     {$level+1}";

    if 0 or $debug {
        say dd $node;
        #exit;
        return;
    }

    my $pnode = PodNode.new: :$id, :$parent, :level($level+1);
    %nodes{$id} = $pnode; # hash of IDs and pod nodes

    # as defined in the link above as "sub walk($node)"
    # also see the supporting test code using nqp and precomp and cache

    # push chunks to @pod-chunks for further processing

    my @children;

    my $Typ = "(none)";
    my $Nam = "(none)";

    =begin comment
    note qq:to/HERE/;
    DEBUG: found new node 
      pod type name: $Nam
          node.type: $Typ
    HERE
    =end comment

    my ($pod-type-name, $node-type, $type) = "N/A", "N/A", "";
    with $node {
        when $_ ~~ 'RakuAST::Node' {
            $pod-type-name = "RakuAST::Node";
        }
        when $_ ~~ 'RakuAST::Doc::Paragraph' {
            $pod-type-name = "RakuAST::Doc::Paragraph";
        }
        when $_ ~~ 'RakuAST::Doc::Block' {
            $pod-type-name = "RakuAST::Doc::Block";
            $type = $_.type;
        }
        when $_ ~~ 'RakuAST::Doc::Block' {
            $pod-type-name = "RakuAST::Doc::Block";
        }
        when $_ ~~ 'RakuAST::Doc::Markup' {
            $pod-type-name = "RakuAST::Doc::Markup";
        }
        when $_ ~~ Str {
            $pod-type-name = "String";
        }
        default {
            note "WARNING: Unknown node type '$type'...";
        }
    }

    if $node ~~ RakuAST::Doc::Paragraph {
        @children = $node.atoms;
    }
    elsif $node ~~ RakuAST::Doc::Block {
        # some other types to handle later:
        my $typ = $node.type;
        $Typ = $typ;

        =begin comment
        if $node.type eq 'code'|'implicit-code'|'comment'|'table' {
            note "NOTE: skipping node typ '$typ' for now." if 0 or $debug;
            @unhandled-pod.push: $typ;
            return;
        }
        =end comment

        @children = $node.paragraphs;
    }
    elsif $node ~~ RakuAST::Doc::Markup {
        # handles formatting code like B<>, C<>, etc.
        # TODO fix this
        # some other types to handle later:
        my $typ = "Markup"; #$node.type;
        $Typ = $typ;
        $Nam = $node.^name;
        
        =begin comment
        if 1 {
            note "NOTE: skipping node name '$Nam', type '$typ' for now."
               if 0 or $debug;
            @unhandled-pod.push: $typ;
            return;
        }
        =end comment
        @children = $node.atoms;

        #note "WARNING: Unhandled pod node type: $node.^name";
    }
    elsif $node ~~ Str {
        $pnode.text = $node;
        @pod-chunks.push: $node;
    }
    else {
        # report unhandled types
        note "WARNING: Unhandled pod node name: $node.^name" if 1 or $debug;
    }

    my $nc = @children.elems;
    my $nam = $node.^name;
    my $typ = $Typ;
    if $debug {
        note qq:to/HERE/;
        NOTE: found $nc child nodes for node name '$nam' and type '$typ'.
        HERE
    }

    for @children -> $child {
        
        =begin comment
        if $child ~~ Str {
            @pod-chunks.push: $child;
            next;
        }
        =end comment
  
        walk-pod $child, :parent($id), :level($level+1);
    }
} 
