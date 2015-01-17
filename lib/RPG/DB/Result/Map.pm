package RPG::DB::Result::Map;

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

RPG::DB::Result::Map - Database module for map

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

__PACKAGE__->table("maps");
__PACKAGE__->add_columns(
    map_id => {
        data_type           => "integer",
        size                => 11,
        is_auto_increment   => 1,
        extra               => { unsigned => 1 },
    },
    # The following have to match the x,y,z,world columns
    # in the characters table
    x => {
        data_type           => "integer",
        size                => 11,
        is_nullable         => 0,
        default_value       => 0,
    },
    y => {
        data_type           => "integer",
        size                => 11,
        is_nullable         => 0,
        default_value       => 0,
    },
    z => {
        data_type           => "integer",
        size                => 11,
        is_nullable         => 0,
        default_value       => 0,
    },
    world => {
        data_type           => "integer",
        size                => 11,
        is_nullable         => 0,
        default_value       => 0,
    },
    tile_id => {
        data_type           => "integer",
        size                => 10,
        is_nullable         => 0,
        extra               => { unsigned => 1 },
    },
    name => {
        data_type           => "char",
        size                => 32,
        is_nullable         => 0,
    },
    css_class => {
        data_type           => "char",
        size                => 32,
        is_nullable         => 1,
    },
);
__PACKAGE__->set_primary_key('map_id');
__PACKAGE__->might_have(
    description => 'RPG::DB::Result::MapDescription',
    'map_id'
);
__PACKAGE__->belongs_to(
    tile => 'RPG::DB::Result::Tile',
    'tile_id'
);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'xyzw_idx', fields =>  ['x', 'y', 'z', 'world']);
}

=head2 fetch_map_area({ min_x => -dx, max_x => dx, min_y => -dy, max_y => dy })

parameters passed are min_x, max_x, min_y and max_y but they are relative and
added to the current x,y values of the location

e.g min_x => -2, max_x => 2, min_y => -2, max_y => 2

=cut

sub fetch_map_area {
    my $self = shift;
    my $args = ref $_[0] eq 'HASH' ? shift : { @_ };

## radius OR min_x,max_x,min_y,max_y are required

    if (defined $args->{ radius }) {
        $args->{ max_x } = $args->{ max_y } = $args->{ radius };
        $args->{ min_x } = $args->{ min_y } = (0 - $args->{ radius });
    }

    return $self->schema->resultset("Map")->fetch_map_area({
        min_x => $self->x + $args->{ min_x },
        max_x => $self->x + $args->{ max_x },
        min_y => $self->y + $args->{ min_y },
        max_y => $self->y + $args->{ max_y },
        z => $self->z, world => $self->world,
    });
}

1;

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011-2013 Reanimated Projects and Games Ltd

