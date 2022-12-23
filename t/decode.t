#!perl

use Test2::V0;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use FindBin;

require $FindBin::Bin . "/../decode.pl";

ok 1;

is bson::decode("\x01\x66\x6F\x6F\x00\xD2\x04\x00\x00\x02\x62\x61\x72\x00\x01\x00"),
  {
    'bar' => 'true',
    'foo' => 1234
  },
  "basic decode";

subtest '_read_bool' => sub {

    my @is_true = (
        '1',
        "\x01",
        "\x42",
    );

    foreach my $str (@is_true) {
        is bson::_read_bool( \$str ), 'true', "_read_bool(...) is true";
    }

    my @is_false = (
        '0',
        "\x00",
        "",
    );

    foreach my $str (@is_true) {
        is bson::_read_bool( \$str ), 'false', "_read_bool(...) is false";
    }

    return;
};

subtest '_read_name' => sub {

    my @tests = (
        [ "foo\0"            => "foo" ],
        [ "\x66\x6F\x6F\x00" => "foo" ],
        [ "\x62\x61\x72\x00" => "bar" ],
        [ "void"             => undef ],
    );

    foreach my $t (@tests) {
        my ( $in, $out ) = @$t;
        is bson::_read_name( \$in ), $out, "_read_name = '" . ( $out // 'undef' ) . "'";
    }

};

done_testing;
