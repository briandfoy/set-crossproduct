package Set::CrossProduct;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw( $VERSION );

$VERSION = '1.96';

=head1 NAME

Set::CrossProduct - work with the cross product of two or more sets

=head1 SYNOPSIS

	my $iterator = Set::CrossProduct->new( ARRAY_OF_ARRAYS );

	# get the number of tuples
	my $number_of_tuples = $iterator->cardinality;

	# get the next tuple
	my $tuple            = $iterator->get;

	# move back one position
	my $tuple            = $iterator->unget;

	# get the next tuple without resetting
	# the cursor (peek at it)
	my $next_tuple       = $iterator->next;

	# get the previous tuple without resetting
	# the cursor
	my $last_tuple       = $iterator->previous;

	# get a random tuple
	my $tuple            = $iterator->random;

	# in list context returns a list of all tuples
	my @tuples           = $iterator->combinations;

	# in scalar context returns an array reference to all tuples
	my $tuples           = $iterator->combinations;

=head1 DESCRIPTION

Given sets S(1), S(2), ..., S(k), each of cardinality n(1), n(2), ..., n(k)
respectively, the cross product of the sets is the set CP of ordered
tuples such that { <s1, s2, ..., sk> | s1 => S(1), s2 => S(2), ....
sk => S(k). }

If you do not like that description, how about:

Create a list by taking one item from each array, and do that for all
possible ways that can be done, so that the first item in the list is
always from the first array, the second item from the second array,
and so on.

If you need to see it:

	A => ( a, b, c )
	B => ( 1, 2, 3 )
	C => ( foo, bar )

The cross product of A and B and C, A x B x C, is the set of
tuples shown:

	( a, 1, foo )
	( a, 1, bar )
	( a, 2, foo )
	( a, 2, bar )
	( a, 3, foo )
	( a, 3, bar )
	( b, 1, foo )
	( b, 1, bar )
	( b, 2, foo )
	( b, 2, bar )
	( b, 3, foo )
	( b, 3, bar ) 
	( c, 1, foo )
	( c, 1, bar )
	( c, 2, foo )
	( c, 2, bar )
	( c, 3, foo )
	( c, 3, bar )

If one of the sets happens to be empty, the cross product is empty
too.

	A => ( a, b, c )
	B => ( )
	
In this case, A x B is the empty set, so you'll get no tuples.

This module combines the arrays that give to it to create this
cross product, then allows you to access the elements of the
cross product in sequence, or to get all of the elements at
once.  Be warned! The cardnality of the cross product, that is,
the number of elements in the cross product, is the product of
the cardinality of all of the sets.

The constructor, C<new>, gives you an iterator that you can
use to move around the cross product.  You can get the next
tuple, peek at the previous or next tuples, or get a random
tuple.  If you were inclined, you could even get all of the
tuples at once, but that might be a very large list. This module
lets you handle the tuples one at a time.

I have found this module very useful for creating regression
tests.  I identify all of the boundary conditions for all of
the code branches, then choose bracketing values for each of them.
With this module I take all of the values for each test and
create every possibility in the hopes of exercising all of the
code.  Of course, your use is probably more interesting. :)

=head1 METHODS

=head2 new( ARRAY_REF_OF_ARRAY_REFS )

Given the array of arrays that represent some sets, return a
C<Set::CrossProduct> instance that represents the cross product
of those sets.

The single argument is an array reference that has as its
elements other array references.  The C<new> method will
return undef in scalar context and the empty list in list
context if you give it something different.

You must have at least two sets, or the constructor will
fail.

=cut

# The iterator object is a hash with these keys
#
#	arrays   - holds an array ref of array refs for each list
#	counters - the current position in each array for generating
#		combinations
#	lengths  - the precomputed lengths of the lists in arrays
#	done     - true if the last combination has been fetched
#	previous - the previous value of counters in case we want
#		to unget something and roll back the counters
#	ungot    - true if we just ungot something--to prevent
#		attempts at multiple ungets which we don't support

sub new
	{
	my( $class, $array_ref ) = @_;

	return unless ref $array_ref eq ref [];
	return unless @$array_ref > 1;

	foreach my $array ( @$array_ref ) {
		return unless ref $array eq ref [];
		}

	my $self = {};

	$self->{arrays}   = $array_ref;
	$self->{counters} = [ map { 0 }      @$array_ref ];
	$self->{lengths}  = [ map { $#{$_} } @$array_ref ];
	$self->{previous} = [];
	$self->{ungot}    = 1;

	$self->{done}     = grep( $_ == -1, @{ $self->{lengths} } )
		? 1 : 0;

	bless $self, $class;

	return $self;
	}

sub _increment
	{
	my $self = shift;

	$self->{previous} = [ @{$self->{counters}} ]; # need a deep copy

	my $tail = $#{ $self->{counters} };

	COUNTERS:
		{
		if( $self->{counters}[$tail] == $self->{lengths}[$tail] )
			{
			$self->{counters}[$tail] = 0;
			$tail--;

			if( $tail == 0
				and $self->{counters}[$tail] == $self->{lengths}[$tail] )
				{
				$self->done(1);
				return;
				}

			redo COUNTERS;
			}

		$self->{counters}[$tail]++;
		}

	return 1;
	}

sub _decrement
	{
	my $self = shift;

	my $tail = $#{ $self->{counters} };

	$self->{counters} = $self->_previous( $self->{counters} );
	$self->{previous} = $self->_previous( $self->{counters} );

	return 1;
	}

sub _previous
	{
	my $self = shift;

	my $counters = $self->{counters};

	my $tail = $#{ $counters };

	return [] unless grep { $_ } @$counters;

	COUNTERS:
		{
		if( $counters->[$tail] == 0 )
			{
			$counters->[$tail] = $self->{lengths}[$tail];
			$tail--;

			if( $tail == 0 and $counters->[$tail] == 0)
				{
				$counters = [ map { 0 } 0 .. $tail ];
				last COUNTERS;
				}

			redo COUNTERS;
			}

		$counters->[$tail]--;
		}

	return $counters;
	}

=head2 cardinality()

Return the carnality of the cross product.  This is the number
of tuples, which is the product of the number of elements in
each set.

Strict set theorists will realize that this isn't necessarily
the real cardinality since some tuples may be indentical, making
the actual cardinality smaller.

=cut

sub cardinality
	{
	my $self = shift;

	my $product = 1;

	foreach my $length ( @{ $self->{lengths} } )
		{
		$product *= ( $length + 1 );
		}

	return $product;
	}

=head2 reset_cursor()

Return the pointer to the first element of the cross product.

=cut

sub reset_cursor
	{
	my $self = shift;

	$self->{counters} = [ map { 0 } @{ $self->{counters} } ];
	$self->{previous} = [];
	$self->{ungot}    = 1;
	$self->{done}     = 0;

	return 1;
	}

=head2 get()

Return the next tuple from the cross product, and move the position
to the tuple after it.

In list context, C<get> returns the tuple as a list.  In scalar context
C<get> returns the tuple as an array reference.

If you have already gotten the last tuple in
the cross product, then C<get> returns undef in scalar context and
the empty list in list context.

=cut

sub get
	{
	my $self = shift;

	return if $self->done;

	my @array = map {  ${ $self->{arrays}[$_] }[ $self->{counters}[$_] ]  }
			0 .. $#{ $self->{arrays} };

	$self->_increment;
	$self->{ungot} = 0;

	if( wantarray ) { return  @array }
	else            { return \@array }
	}

=head2 unget()

Pretend we did not get the tuple we just got.  The next
time we get a tuple, we will get the same thing.  You
can use this to peek at the next value and put it back
if you do not like it.

You can only do this for the previous tuple.  C<unget>
does not do multiple levels of unget.

=cut

sub unget
	{
	my $self = shift;

	return if $self->{ungot};

	$self->{counters} = $self->{previous};

	$self->{ungot} = 1;

	# if we just got the last element, we had set the done flag,
	# so unset it.
	$self->{done}  = 0;

	return 1;
	}

=head2 next()

Return the next tuple, but do not move the pointer.  This
way you can look at the next value without affecting your
position in the cross product.

In list context, C<get> returns the tuple as a list.  In scalar context
C<get> returns the tuple as an array reference.

For the last combination, next() returns undef.

=cut

sub next
	{
	my $self = shift;

	return if $self->done;

	my @array = map( {  ${ $self->{arrays}[$_] }[ $self->{counters}[$_] ]  }
			0 .. $#{ $self->{arrays} } );

	if( wantarray ) { return  @array }
	else            { return \@array }
	}

=head2 previous()

Return the previous tuple, but do not move the pointer.  This
way you can look at the last value without affecting your
position in the cross product.

In list context, C<get> returns the tuple as a list.  In scalar context
C<get> returns the tuple as an array reference.

=cut

sub previous
	{
	my $self = shift;

	my @array = map( {  ${ $self->{arrays}[$_] }[ $self->{previous}[$_] ]  }
			0 .. $#{ $self->{arrays} } );

	if( wantarray ) { return  @array }
	else            { return \@array }
	}

=head2 done()

Without an argument, C<done> returns true if there are no more
combinations to fetch with C<get>. and returns false otherwise.

With an argument, it acts as if there are no more arguments to fetch, no
matter the value. If you want to start over, use C<reset_cursor> instead.

=cut

sub done { $_[0]->{done} = 1 if @_ > 1; $_[0]->{done} }

=head2 random()

Return a random tuple from the cross product.

In list context, C<get> returns the tuple as a list.  In scalar context
C<get> returns the tuple as an array reference.

=cut

sub random
	{
	my $self = shift;

	my @array = map {  ${ $self->{arrays}[$_] }[ rand(1+$self->{lengths}[$_]) ] }
			0 .. $#{ $self->{arrays} };

	if( wantarray ) { return  @array }
	else            { return \@array }
	}

=head2 combinations()

Returns a reference to an arrray that contains all of the tuples
of the cross product.  This can be quite large, so you might
want to check the cardinality first.

In list context, C<get> returns the tuple as a list.  In scalar context
C<get> returns the tuple as an array reference.  However, you should
probably always use this in scalar context except for very low
cardnalities to avoid returning huge lists.

=cut

sub combinations
	{
	my $self = shift;

	my @array = ();

	while( my $ref = $self->get )
		{
		push @array, $ref;
		}

	if( wantarray ) { return  @array }
	else            { return \@array }
	}

=head1 TO DO

* it would be nice to be able to name the sets, and then access
elements from a tuple by name, like

	my $i = Set::CrossProduct->new( {
			Apples => [ ... ],
			Oranges => [ ... ],
			}
		);

	my $tuple = $i->get;

	my $apple = $tuple->Apples;

* I need to fix the cardinality method. it returns the total number
of possibly non-unique tuples.

=head1 BUGS

* none that i know about (yet)

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/Set-CrossProduct

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2001-2015, brian d foy <bdfoy@cpan.org>. All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
