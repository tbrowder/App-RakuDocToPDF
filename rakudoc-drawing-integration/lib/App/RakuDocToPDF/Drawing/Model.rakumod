unit module App::RakuDocToPDF::Drawing::Model;

class PageSpec is export {
    has Str $.media = 'Letter';
    has Str $.orientation = 'portrait';
    has Numeric $.margin = 36;
}

class GridSpec is export {
    has Int $.columns;
    has Numeric $.line-width = 0.75;

    has Numeric @.fixed-row-heights;
    has Numeric $.repeat-row-height;
    has Bool $.fill = False;
}

class DrawingSpec is export {
    has PageSpec $.page;
    has GridSpec $.grid;
}
