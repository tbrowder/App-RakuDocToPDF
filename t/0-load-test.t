use Test;

my @modules = <
    App::RakuDocToPDF
    App::RakuDocToPDF::DocumentType
    App::RakuDocToPDF::Layout
    App::RakuDocToPDF::Media
    App::RakuDocToPDF::Reader
    App::RakuDocToPDF::RakuASTReader
>;

plan @modules.elems;

for @modules -> $m {
    use-ok $m, "Module '$m' used okay";
}
