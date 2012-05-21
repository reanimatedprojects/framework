package RPG::DB::Result::Account;

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

=head1 NAME

RPG::DB::Result::Account - Database module for user accounts

=head1 DESCRIPTION

This module associates an account id with an email address. Other fields
will be added as required.

The account id provides a reference into the account_auths table which
holds data for various authentication methods such as local accounts or
remote authentication via openid/facebook/etc.

=head1 METHODS

=cut

use base qw/DBIx::Class::Core/;

__PACKAGE__->table("accounts");
__PACKAGE__->add_columns(qw/account_id email/);
__PACKAGE__->set_primary_key('account_id');
__PACKAGE__->has_many(
    account_auths => 'RPG::DB::Result::AccountAuth',
    'account_id'
);

1;

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011-2012 Reanimated Projects and Games Ltd

