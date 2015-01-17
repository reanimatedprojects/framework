package RPG::DB::Result::Tile;

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

RPG::DB::Result::Tile - Database module for tiles

=head1 DESCRIPTION

This object represents a map tile - including the name, map id
and various other map specific parameters that will be added
as required.

=head1 METHODS

=cut

use base qw/DBIx::Class::Core RPG::DB::Base/;

use RPG::Utils;
use Dancer ':syntax';

use strict;
use warnings;

__PACKAGE__->table("tiles");
__PACKAGE__->add_columns(
    tile_id => {
        data_type           => "integer",
        size                => 10,
        is_auto_increment   => 1,
        extra               => { unsigned => 1 },
    },
    # The following have to match the name, description,
    # background_image and background_colour columns in the
    # tiles table
    name => {
        data_type           => "char",
        size                => 32,
        is_nullable         => 0,
    },
    description => {
        data_type           => "char",
        size                => 255,
    },
    background_image => {
        data_type           => "char",
        size                => 32,
    },
    background_colour => {
        data_type           => "char",
        size                => 7,
    },
    css_class => {
        data_type           => "char",
        size                => 32,
        is_nullable         => 1,
    },
);
__PACKAGE__->set_primary_key('tile_id');

1;

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2013 Reanimated Projects and Games Ltd

