#!perl

# cleanup and simplified

use strict;
use warnings;

use v5.36;

use Test::More;

sub decode ($str) {
    return _read_document( \$str );
}

sub _read_document ($r_str) {
    my %map;

    while ( $$r_str =~ s{^(.)}{} ) {
        my $char = $1;
        my ( $k, $v );

        last if $char eq chr('0');

        if ( $char eq chr(1) ) {
            $k = _read_name($r_str);
            $v = _read_int($r_str);
        }
        elsif ( $char eq chr(2) ) {
            $k = _read_name($r_str);
            $v = _read_bool($r_str);
        }
        elsif ( $char eq chr(3) ) {
            $k = _read_name($r_str);
            $v = _read_document($r_str);
        }
        last unless length $k;
        $map{$k} = $v;
    }

    return \%map;
}

sub _read_name ($r_str) {
    return $1 if $$r_str =~ s{^([^\0]+)\0}{};
    return;
}

sub _read_int ($r_str) {
    $$r_str =~ s{^(.{4})}{};
    return unpack( 'l', $1 );
}

sub _read_bool ($r_str) {
    my ($b) = ( $r_str =~ s{^(.)}{} );
    return int($b) ? 'true' : 'false';
}

note explain decode("\x01\x66\x6F\x6F\x00\xD2\x04\x00\x00\x02\x62\x61\x72\x00\x01\x00");
