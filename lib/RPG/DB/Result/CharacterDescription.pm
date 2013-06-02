package RPG::DB::Result::CharacterDescription;

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

RPG::DB::Result::CharacterDescription - Database module for character descriptions

=head1 DESCRIPTION

This object represents a character description - a character id and
the description associated with that character.

The character id provides a reference into the characters table which
allows us to select the description for the character.

=head1 METHODS

=cut

use base qw/DBIx::Class::Core RPG::DB::Base/;

use strict;
use warnings;

__PACKAGE__->table("character_descriptions");
__PACKAGE__->add_columns(
    character_id => {
        data_type           => "integer",
        size                => 11,
        extra               => { unsigned => 1 },
        is_nullable         => 0,
    },
    description => {
        data_type           => "text",
    },
);
__PACKAGE__->set_primary_key('character_id');
__PACKAGE__->belongs_to(
    character => 'RPG::DB::Result::Character',
    'character_id'
);

1;

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011-2013 Reanimated Projects and Games Ltd

