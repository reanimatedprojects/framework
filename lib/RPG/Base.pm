package RPG::Base;

use Data::Dumper;

=head2 CLASS->new( )

Standard constructor - returns a blessed empty hashref.

=cut

sub new {
    my $class = shift;
    my $self = { };
    bless $self, $class;
    return $self;
}

=head2 CLASS->args( )

Convert an assortment of different parameters into a hash of
arguments based on the following rules:

=over 4

=item 1. A single arg of type hash is returned as is

=item 2. A single arg of type scalar is returned as the value with 'msg' as the key

=item 3. An array is converted into a hash (first element is the key, next is the value)

=item 4. Anything else just returns the first parameter which may or may not be valid

=back

=cut

sub args {
    my $self = shift;

    # No args passed except the object - probably an error!
    if (scalar(@_) == 0) {
        return undef;
    }

    # One arg and first is a hashref, use it
    if (@_ && (scalar(@_) == 1) && (ref($_[0]) eq "HASH")) {
        return shift @_;
    }
    # One arg and just a scalar, return { msg => $arg }
    if (@_ && (scalar(@_) == 1) && (! ref($_[0]))) {
        return { msg => shift @_ };
    }
    # Just an array, convert to hash
    if (@_) {
        return { @_ };
    }
    # Anything else, return first param as is
    return shift @_;
}

1;
