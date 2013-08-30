package RPG::DB::Base;

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

use RPG::Base;
use strict;
use warnings;

=head1 NAME

RPG::DB::Base

=head1 DESCRIPTION

This module is for providing *some* but not all of the
RPG::Base methods to the RPG::DB modules - for example,
args, error_response and ok_response

=head1 METHODS

=head2 CLASS->args( )

See RPG::Base->args( )

=cut

sub args {
    my $self = shift;
    return RPG::Base->args(@_);
}

=head2 CLASS->ok_response( %params )

See RPG::Base->ok_response( )

=cut

sub ok_response {
    my $self = shift;
    return RPG::Base->ok_response(@_);
}

=head2 CLASS->error_response( $errormsg, %params )

See RPG::Base->error_response( )

=cut

sub error_response {
    my $self = shift;
    return RPG::Base->error_response(@_);
}

sub schema {
    my $self = shift;
    return $self->result_source->schema();
}

1;

=head1 SEE ALSO

L<RPG::Base>

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011-2012 Reanimated Projects and Games Ltd
