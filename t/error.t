# $Id$
BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Set::CrossProduct;
$loaded = 1;
print "ok\n";

use constant     OK => "ok\n";
use constant NOT_OK => "not ok\n";

my @apples  = ('Granny Smith', 'Washington', 'Red Delicious');
my @oranges = ('Navel', 'Florida');

my $i = Set::CrossProduct->new( [ \@apples ] );
print defined $i ? NOT_OK : OK;
