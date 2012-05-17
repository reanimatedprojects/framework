package RPG::Base;

# RPGWNN - Perl Browser-Based MMORPG Framework
# Copyright (C) 2011-2012 Reanimated Projects and Games Ltd

# This file is part of RPGWNN
#
# RPGWNN is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# RPGWNN is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with RPGWNN.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact information for Reanimated Projects and Games Ltd
# can be found at http://rpgwnn.com/

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

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011-2012 Reanimated Projects and Games Ltd
