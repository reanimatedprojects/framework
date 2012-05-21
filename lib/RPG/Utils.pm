package RPG::Utils;

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

use base "RPG::Base";

=head1 NAME

RPG::Utils - assorted functions

=head1 DESCRIPTION

This module provides assorted functions for use by other modules.

=head1 METHODS

The following methods are provided:

=head2 $username_ok = RPG::Utils->is_valid_username( $username );

Verify the username provided is 1-10 characters long and contains a-z,0-9

Return value is a hashref. Check ->{ status } for either "ok" or "error"
If there is an error, ->{ error } will contain the error code

=cut

sub is_valid_username {
    my $self = shift; # Either an object or a class, doesn't matter.

    # Min and max username lengths
    # No point in having anything too short, 3 seems about right
    my $ul_min = 3;

    # If you make the max bigger, remember to adjust the size
    # of the username field in the account_auths_local table
    my $ul_max = 15;

    my $username = shift || return $self->error_response(
        "USERNAME_INVALID", # MSG
    );

    # The minimum length of a username is $ul_min characters
    if (length($username) < $ul_min) {
        return $self->error_response(
            "USERNAME_TOO_SHORT", # MSG
            size => $ul_min,
        );
    }

    # Maximum length of a username is $ul_max characters
    if (length($username) > $ul_max) {
        return $self->error_response(
            "USERNAME_TOO_LONG", # MSG
            size => $ul_max,
        );
    }

    # Allow only alphanumeric characters
    if ($username =~ /^[a-z0-9]+$/i) {
        return $self->ok_response();
    }
    # Anything else is a failure
    return $self->error_response(
        "USERNAME_INVALID", # MSG
    );
}

=head2 $password_ok = RPG::Utils->is_valid_password( $password );

Verify if the password is a good one or not

=cut

sub is_valid_password {
    my $self = shift; # Either an object or a class, doesn't matter.

    # If no password is provided, it's not a valid one.
    # Even if nothing else, we are enforcing the requirement
    # of at least one character in passwords!
    my $password = shift || return $self->error_response(
        "PASSWORD_INVALID", # MSG
    );

    # FIXME: What attributes make a valid password?
    # FIXME: Probably a minimum length of a few characters
    # FIXME: Do we need/want to be strict about passwords?

    return $self->ok_response();
}


=head2 $email_ok = RPG::Utils->is_valid_email( $email )

Verify the email address provided is a valid format

=cut

sub is_valid_email {
    my $class = shift;
    my $email = shift || return $self->error_response(
        "EMAIL_INVALID", # MSG
    );

    return $self->ok_response();
}

1;

=head1 BUGS

Please report any you find. Patches to fix bugs are also welcomed.

=head1 COPYRIGHT

Copyright (C) 2011-2012 Reanimated Projects and Games Ltd
