use Test;

my @modules = <
    App::RakuDocToPDF
>;

plan @modules.elems;

for @modules -> $m {
    use-ok $m, "Module '$m' used okay";
}
