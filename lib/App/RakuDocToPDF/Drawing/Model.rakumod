unit module App::RakuDocToPDF::Drawing::Model;

class PageSpec is export {
    has Str $.media = 'Letter';
    has Str $.orientation = 'portrait';
    has Numeric $.margin = 36;
}

class RowLabelsSpec is export {
    has Int $.row is required;
    has Str @.labels;
}

class GridSpec is export {
    has Int $.columns;
    has Numeric $.line-width = 0.75;

    has Numeric @.column-widths;
    has Numeric @.fixed-row-heights;
    has Numeric $.repeat-row-height;
    has Bool $.fill = False;

    has RowLabelsSpec @.row-labels;
}

class DrawingSpec is export {
    has PageSpec $.page;
    has GridSpec $.grid;
}
