use strict;
use warnings;

use Test::More 0.95;
use Data::Dumper;
my $Class = 'Set::CrossProduct';
my $method = 'position';

subtest 'sanity' => sub {
	use_ok( $Class ) or BAIL_OUT( "$Class did not compile" );
	can_ok $Class, $method;
	};

my $cross = $Class->new( [ [1,2,3], [qw(a b)], [qw(x y z)], [qw(red blue green yellow)] ] );
isa_ok $cross, $Class;

subtest 'start' => sub {
	is $cross->position, 0, 'position is 0 before first fetch';

	my $first = $cross->get;
	is $cross->position, 1, 'position is  1 after first fetch';

	my $second = $cross->get;
	is $cross->position, 2, 'position is 2 after second fetch';

	$cross->reset_cursor;
	is $cross->position, 0, 'position is 0 after reset_cursor';
	};

subtest 'at end' => sub {
	my $all = $cross->combinations;
	is $cross->position, undef, 'position is undef after combinations';

	my $past = $cross->get;
	is $cross->position, undef, 'position is undef fetching past last';

	my $un = $cross->unget;
	is $cross->position, $cross->cardinality - 1, 'position is (cardinality - 2) ungetting past last';
	};

subtest 'one by one' => sub {
	$cross->reset_cursor;
	is $cross->position, 0, 'position is 0 after reset_cursor';

	my $pos = 0;
	until( $cross->done ) {
		is $cross->position, $pos++, 'cross position before tracks';
		my $tuple = $cross->get;
		isa_ok $tuple, ref [], '$tuple';
		$pos = undef if $cross->done;
		is $cross->position, $pos, 'cross position after tracks';
		}
	};

done_testing;
