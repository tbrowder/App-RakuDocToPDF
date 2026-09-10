use Test;

my @modules = <
    App::RakuDocToPDF
    App::RakuDocToPDF::Layout
    App::RakuDocToPDF::Reader
>;

plan @modules.elems;

for @modules -> $m {
    use-ok $m, "Module '$m' used okay";
}
