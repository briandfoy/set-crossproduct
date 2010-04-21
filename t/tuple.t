BEGIN { $| = 1; print "1..14\n"; }
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

my $tuple = $i->get;
print +($tuple->[0] eq $apples[0] and $tuple->[1] eq $oranges[0]) ?
	OK : NOT_OK;

$tuple = $i->next;
print +($tuple->[0] eq $apples[0] and $tuple->[1] eq $oranges[1]) ?
    OK : NOT_OK;

$tuple = $i->get;
print +($tuple->[0] eq $apples[0] and $tuple->[1] eq $oranges[1]) ?
    OK : NOT_OK;

$tuple = $i->previous;
print +($tuple->[0] eq $apples[0] and $tuple->[1] eq $oranges[1]) ?
    OK : NOT_OK;

$status = $i->unget;
print $status ? OK : NOT_OK;

$tuple = $i->get;
print +($tuple->[0] eq $apples[0] and $tuple->[1] eq $oranges[1]) ?
    OK : NOT_OK;

$tuple = $i->get;
print +($tuple->[0] eq $apples[1] and $tuple->[1] eq $oranges[0]) ?
    OK : NOT_OK;

$tuple = $i->get;
print +($tuple->[0] eq $apples[1] and $tuple->[1] eq $oranges[1]) ?
    OK : NOT_OK;

$tuple = $i->get;
print +($tuple->[0] eq $apples[2] and $tuple->[1] eq $oranges[0]) ?
    OK : NOT_OK;

$tuple = $i->get;
print +($tuple->[0] eq $apples[2] and $tuple->[1] eq $oranges[1]) ?
    OK : NOT_OK;

$tuple = $i->get;
print defined $tuple ? NOT_OK : OK;
