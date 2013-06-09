package RPG::DB::Result::Character;

# RPGWNN - Perl Browser-Based MMORPG Framework
# Copyright (C) 2011-2013 Reanimated Projects and Games Ltd

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

RPG::DB::Result::Character - Database module for characters

=head1 DESCRIPTION

This object represents a character - including the name, account id
and various other character specific parameters that will be added
as required.

The account id provides a reference into the accounts table which
allows us to select all characters for the logged in account.

=head1 METHODS

=cut

use base qw/DBIx::Class::Core RPG::DB::Base/;

use Dancer ':syntax';

use strict;
use warnings;

__PACKAGE__->table("characters");
__PACKAGE__->add_columns(
    character_id => {
        data_type           => "integer",
        size                => 11,
        is_auto_increment   => 1,
        extra               => { unsigned => 1 },
    },
    account_id => {
        data_type           => "integer",
        size                => 11,
        is_nullable         => 0,
        extra               => { unsigned => 1 },
    },
    name => {
        data_type           => "char",
        size                => 64,
        is_nullable         => 0,
    },
    xp => {
        data_type           => "integer",
        size                => 11,
        is_nullable         => 0,
        extra               => { unsigned => 1 },
    },
    disabled => {
        data_type           => "char",
        size                => 10,
        is_nullable         => 0,
    },
);
__PACKAGE__->set_primary_key('character_id');
__PACKAGE__->add_unique_constraint("name" => [qw/name/]);
__PACKAGE__->belongs_to(
    account => 'RPG::DB::Result::Account',
    'account_id'
);
__PACKAGE__->might_have(
    description => 'RPG::DB::Result::CharacterDescription',
    'character_id'
);

=head2 new()

We override this method so that we can check the name
provided is a valid syntax.

=cut

sub new {
    my ( $class, $attrs ) = @_;

    # FIXME: Check the name is acceptable
    # FIXME: Check what to return if it's not - what does DBIx::Class do?
    # FIXME: 5-64 alphanumeric characters
    #
    return unless ($attrs->{ name } &&
        $attrs->{ name } =~ /^[a-z0-9A-Z]{5,64}$/);

    $attrs->{ disabled } //= "";
    $attrs->{ xp } //= 0;

    my $new = $class->next::method($attrs);
    return $new;
}

=head2 profile_link()

Generate a profile link as basic HTML - if you ever change the route
in lib/page/character.pl you will need to adjust the URL this method
produces.

FIXME: We probably need to HTML encode the character name in case someone
allows & < or > in character names.

=cut

sub profile_link {
    my $self = shift;
    return '<a href="/character/' . $self->character_id() . '">' . $self->name() . '</a>';
}

1;

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011-2013 Reanimated Projects and Games Ltd

