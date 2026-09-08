[![Actions Status](https://github.com/tbrowder/App-RakuDocToPDF/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/App-RakuDocToPDF/actions) [![Actions Status](https://github.com/tbrowder/App-RakuDocToPDF/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/App-RakuDocToPDF/actions) [![Actions Status](https://github.com/tbrowder/App-RakuDocToPDF/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/App-RakuDocToPDF/actions)

NAME
====

**App::RakuDocToPDF** - Provides routines to convert RakuDoc to PDF

SYNOPSIS
========

```raku
use App::RakuDocToPDF;

# use the provided script to convert RakuDoc to PDF
rakudoc2pdf some.rakudoc
# OUTPUT
some.pdf
```

DESCRIPTION
===========

**App::RakuDocToPDF** provides a script (`rakudoc2pdf`) to convert simple RakuDoc files to PDF. Execcute the program without an argument to see more information as shown here:

    $ rakudoc2pdf
    Usage:
        rakudoc2pdf INPUT.rakudoc [--output=FILE.pdf] [--media=Letter|A4]

    Examples:
        rakudoc2pdf README.rakudoc
        rakudoc2pdf README.rakudoc --output=README.pdf
        rakudoc2pdf README.rakudoc --media=A4

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2026 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

