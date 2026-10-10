use Test;

my @modules = <
    App::RakuDocToPDF
    App::RakuDocToPDF::DocumentType
    App::RakuDocToPDF::Layout
    App::RakuDocToPDF::Media
    App::RakuDocToPDF::RakuASTReader
    App::RakuDocToPDF::SlideMaker
    App::RakuDocToPDF::SlideLayout
    App::RakuDocToPDF::Drawing::Layout 
    App::RakuDocToPDF::Drawing::Model
    App::RakuDocToPDF::Drawing::Parser
    App::RakuDocToPDF::Drawing::Renderer
    App::RakuDocToPDF::Drawing::Units
>;

plan @modules.elems;

for @modules -> $m {
    use-ok $m, "Module '$m' used okay";
}
