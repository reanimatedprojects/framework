#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

use FindBin qw( $Bin );
use lib "$Bin/../lib";

use RPG::App;
use Dancer qw(:syntax :script);
use Dancer::Plugin::DBIC qw(schema);
use Dancer::Test;

=pod

=head1 NAME

scripts/create_map.pl

=head1 DESCRIPTION

This script is a quick test to create some basic map records so that
we can at least load the map and work on moving characters around.

=cut

my $schema = schema;
die "No schema defined" unless ($schema && (ref($schema) eq "RPG::DB"));

# Create tiles
# Tile types 1-4
my @tile_data = (
    {
        name => "forest",
        description => "A heavily wooded area.",
        background_image => "bg_wood.png",
        background_colour => "#339933",
    },
    {
        name => "grass",
        description => "A large expanse of grass.",
        background_image => "bg_grass.png",
        background_colour => "#11ee11",
    },
    {
        name => "path",
        description => "A gravel path.",
        background_image => "bg_path.png",
        background_colour => "#666666",
    },
    {
        name => "water",
        description => "A very wet place with lots of water.",
        background_image => "bg_water.png",
        background_colour => "#3333cc",
    }
);

my $rs = $schema->resultset("Tile");
unless ($rs->all() == 0) {
    die "Tile table already has records - aborting\n";
}
$rs = $schema->resultset("Map");
unless ($rs->all() == 0) {
    die "Map table already has records - aborting\n";
}

print "Populating tiles\n";
my @tile_results = $schema->populate("Tile", \@tile_data);
print scalar(@tile_results), " records\n";

my @tiles = sort { $a->tile_id <=> $b->tile_id } @tile_results;

# Create map
my @columns = ("x", "y", "z", "world", "tile_id", "name");

# Sample map showing the 4 different tile types in a 10x10 grid
my @map = (
    [ 0, 0, 1, 1, 1, 2, 1, 1, 3, 3 ],
    [ 0, 0, 0, 1, 1, 2, 1, 1, 3, 3 ],
    [ 0, 0, 0, 1, 1, 2, 2, 1, 3, 3 ],
    [ 0, 0, 0, 1, 1, 1, 2, 1, 3, 3 ],
    [ 0, 0, 1, 1, 1, 1, 2, 2, 1, 3 ],
    [ 0, 0, 1, 1, 1, 1, 1, 2, 2, 3 ],
    [ 0, 0, 0, 1, 1, 1, 1, 2, 1, 3 ],
    [ 2, 0, 0, 1, 1, 1, 1, 2, 1, 3 ],
    [ 2, 2, 2, 2, 2, 2, 2, 2, 3, 3 ],
    [ 0, 0, 0, 0, 1, 2, 1, 1, 3, 3 ],
);

my @data = ();
foreach my $row (0..9) {
    foreach my $col (0..9) {
        push @data, [
            $col - 3, $row - 2, 0, 0,
            $tiles[ $map[$row][$col]]->id, $tiles[ $map[$row][$col]]->name,
        ];
    }
}

print "Populating 10x10 map\n";
my @results = $schema->populate("Map", [ \@columns, @data ]);
# Should return 100 results (10x10)
print scalar(@results), " records\n";

