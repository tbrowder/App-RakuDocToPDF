use v6.d;
use Test;

use App::RakuDocToPDF::Media;

plan 8;

is-deeply media-box('Letter'), (0, 0, 612, 792), 'Letter media box';
is media-width('Letter'), 612, 'Letter width';
is media-height('Letter'), 792, 'Letter height';

is-deeply media-box('A4'), (0, 0, 595, 842), 'A4 media box';
is media-width('A4'), 595, 'A4 width';
is media-height('A4'), 842, 'A4 height';

is-deeply media-box('letter'), (0, 0, 612, 792), 'media name is case insensitive';
dies-ok { media-box('Legal') }, 'unsupported media dies';
