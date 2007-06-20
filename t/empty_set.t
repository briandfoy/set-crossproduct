#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';

my $Class = 'Set::CrossProduct';
use_ok( $Class );

my $cross = Set::CrossProduct->new( [ [1,2,3], [] ] );
isa_ok( $cross, $Class );

print STDERR Dumper( $cross ); use Data::Dumper;

is( $cross->cardinality, 0, "Cardinality is zero" );
is( $cross->done, 1, "Done is already true (good)" );
isa_ok( $cross->combinations, ref [], "Combinations is array ref" );
is( scalar @{$cross->combinations}, 0, "Combinations has zero elements" );