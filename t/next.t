# $Id$
BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $loaded;}
use Set::CrossProduct;
$loaded = 1;
print "ok\n";

use constant     OK => "ok\n";
use constant NOT_OK => "not ok\n";

my @apples  = ('Granny Smith', 'Washington', 'Red Delicious');
my @oranges = ('Navel', 'Florida');

my $i = Set::CrossProduct->new( [ \@apples, \@oranges ] );
print ref $i ? OK : NOT_OK;

my $count = $i->cardinality;
print $count == 6 ? OK : NOT_OK;

print $i->next ? OK : NOT_OK;	

# after the last fetch, next() should return undef
for( ; $count > 0; $count-- )
	{
	my @a = $i->get();
	}
print defined $i->next ? NOT_OK : OK;	

# but if i unget the last element, next should return
# the last one.
$i->unget();
print defined $i->next ? OK : NOT_OK;	

# now we should be done
my @a = $i->get();
print defined $i->next ? NOT_OK : OK;	
