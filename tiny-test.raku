#!/usr/bin/env raku

use v6;
use PDF::API6;
use PDF::Page;

my PDF::API6 $pdf .= new;

$pdf.media-box = [
    0,
    0,
    792,
    612,
];

my PDF::Page $page = $pdf.add-page;

say "pages = {$pdf.page-count}";

$pdf.save-as('page-test.pdf');
