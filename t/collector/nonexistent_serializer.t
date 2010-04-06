#!perl

use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

use Data::Collector;

# what happens when we want an engine that doesn't exist?
my $collector;

# engine is lazy
lives_ok {
    $collector = Data::Collector->new( format => 'J7fhZd90aZZ' );
} 'Creating collector object';

isa_ok( $collector, 'Data::Collector' );

throws_ok {
    $collector->serialize;
} qr/^Can't load serializer/;

