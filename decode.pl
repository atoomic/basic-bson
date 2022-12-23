#!perl

package bson;

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
    return unless ref $r_str;
    return $1 if $$r_str =~ s{^([^\0]+)\0}{};
    return;
}

sub _read_int ($r_str) {
    return 0 unless ref $r_str;

    $$r_str =~ s{^(.{4})}{};
    return unpack( 'l', $1 );
}

sub _read_bool ($r_str) {
    return 'false' unless ref $r_str;
    my ($b) = ( $$r_str =~ s{^(.)}{} );
    no warnings;
    return int($b) ? 'true' : 'false';
}

1;
