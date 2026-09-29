[![Actions Status](https://github.com/tbrowder/Slidemaker/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/Slidemaker/actions) [![Actions Status](https://github.com/tbrowder/Slidemaker/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/Slidemaker/actions) [![Actions Status](https://github.com/tbrowder/Slidemaker/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/Slidemaker/actions)

NAME
====

**Slidemaker** - Provides routines for generating PDF slides from Rakudoc input.

SYNOPSIS
========

```raku
use Slidemaker;
$ parse-slides <rakudoc file>
$ See file 'MyBriefing.pdf'
```

DESCRIPTION
===========

**Slidemaker** provides a system to create a PDF slide deck from a Rakudoc description. Following is an example of such a description:

    =begin pod

    # Config entries apply to the entire document
    # until the first slide. Then each slide can
    # have its own Config entries. 

    =for Config :paper<letter> :title-bar-color<blue> :title-bar-height<1>
    = :dimensions<in>
    = :font<serif> :title-font-size<> :subtitle-font-size<> :font-size<>
    = :margins<1> 

    # A '=slide' starts a new slide and subsequent Config entries
    # are constrained to the current slide.

    =slide 
    =Title Why Linux?
    =Subtitle Introduction to the Windows/Mac alternative
    =author Joey Marshal
    =date 2024-05-10
    =item It's good for you.
    =item It's fun, too!

    =slide 
    =Title Why Linux?
    =Subtitle That's all folks!

    # Document definition is complete

    =end pod

The process currently uses **Pod::To::PDF::Lite** to render the Rakudoc slides to individual pages in a single PDF document.

See slide input format details at [SlideFormats](SlideFormats.md) for defaults and recognized key/value pairs.

Currently, the input document satisfies a basic need for a quick, text-based briefing presentation. It can provide:

  * Letter or A4 paper in landscape orientation

  * text

  * images

  * links

  * colored borders

  * colored text boxes (or frames)

Run `$ create-slides eg` to download the example file from './resources'.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2024-2025 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

