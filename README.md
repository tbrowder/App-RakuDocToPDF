[![Actions Status](https://github.com/tbrowder/App-RakuDocToPDF/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/App-RakuDocToPDF/actions) [![Actions Status](https://github.com/tbrowder/App-RakuDocToPDF/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/App-RakuDocToPDF/actions) [![Actions Status](https://github.com/tbrowder/App-RakuDocToPDF/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/App-RakuDocToPDF/actions)

NAME
====

**App::RakuDocToPDF** - Provides routines to convert RakuDoc to PDF

SYNOPSIS
========

From the command line:

    rakudoc2pdf README.rakudoc

    rakudoc2pdf README.rakudoc --output=README.pdf

    rakudoc2pdf README.rakudoc --media=A4

From Raku:

```raku
use App::RakuDocToPDF;

my IO::Path $pdf = rakudoc-to-pdf(
'README.rakudoc',
:output<README.pdf>,
:media<Letter>,
);
```

DESCRIPTION
===========

**App::RakuDocToPDF** converts simple RakuDoc files to paginated PDF documents.

Its primary purpose is to produce a printable draft of a module's RakuDoc README for proofreading and handwritten editing. The generated document uses normal Letter or A4 pages rather than one continuously growing PDF page.

The current version deliberately supports a useful subset of RakuDoc rather than attempting to be a complete RakuDoc publishing system.

PDF pages use the standard PDF core fonts:

  * Times-Roman for normal body text

  * Helvetica Bold for headings

  * Courier for code

  * Helvetica for page footers

Each page has a centered footer in the form:

    Page M of N

where `M` is the current page number and `N` is the total number of pages.

COMMAND LINE
============

The distribution installs the `rakudoc2pdf` program.

Execute the program without an input file, or use `--help` or `-h`, to see its usage information:

    Usage:
    rakudoc2pdf INPUT.rakudoc [--output=FILE.pdf] [--media=Letter|A4]

    Examples:
    rakudoc2pdf README.rakudoc
    rakudoc2pdf README.rakudoc --output=README.pdf
    rakudoc2pdf README.rakudoc --media=A4

Only one input file may be specified.

OPTIONS
=======

`--output=FILE.pdf`
-------------------

Specifies the output PDF file.

For example:

    rakudoc2pdf README.rakudoc --output=draft.pdf

If `--output` is omitted, the output file is created in the current working directory using the input file's basename, with the `.rakudoc` suffix replaced by `.pdf`.

Thus:

    docs/README.rakudoc

produces:

    ./README.pdf

`--media=Letter|A4`
-------------------

Selects the PDF page media.

The supported values are:

  * `Letter`

  * `A4`

The default is `Letter`.

For example:

    rakudoc2pdf README.rakudoc --media=A4

`--help`, `-h`
--------------

Displays command-line usage information and exits.

LIBRARY INTERFACE
=================

The distribution exports the `rakudoc-to-pdf` routine:

```raku
use App::RakuDocToPDF;

my IO::Path $pdf = rakudoc-to-pdf(
'README.rakudoc',
:output<README.pdf>,
:media<Letter>,
);
```

The `:output` argument is optional. If it is omitted, the output filename is derived from the input file's basename and is written in the current working directory.

The `:media` argument is also optional and defaults to `Letter`.

The routine returns the `IO::Path` of the generated PDF file.

SUPPORTED RAKUDOC
=================

The current version is intended primarily for ordinary module README files.

It recognizes and renders:

  * headings written with `=headN`

  * ordinary paragraphs

  * `=item` entries

  * `=code` lines

  * `=begin code` and `=end code` blocks

  * the visible contents of common `B<>`, `I<>`, and `C<>` inline formatting codes

  * the visible label of a labeled `L<>` link

Text is wrapped to the available page width, and new PDF pages are created as needed.

REPRODUCIBLE OUTPUT
===================

The renderer is designed so that identical RakuDoc input and identical rendering options produce identical PDF bytes. Volatile PDF metadata, such as the current creation time, is not written. The PDF file identifier is derived deterministically from the input text and media choice.

This makes generated README drafts suitable for checksum comparison and prevents a PDF from appearing to change when its rendered content has not.

LIMITATIONS
===========

This is an intentionally lightweight renderer. It does not yet implement the complete RakuDoc specification.

In particular:

  * Inline `B<>`, `I<>`, and `C<>` markup is currently rendered as ordinary visible text rather than with bold, italic, or code styling.

  * Labeled links retain their visible label, but the generated PDF does not currently create active PDF hyperlinks.

  * Unsupported RakuDoc block directives are currently ignored.

  * Richer RakuDoc features such as tables and images are not currently rendered.

  * The current output is intended primarily as a clean printable draft for proofreading rather than as publication-quality typesetting.

These limitations may be reduced in later releases while retaining the simple draft-generation use case.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2026 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

