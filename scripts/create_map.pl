#!/usr/bin/perl

use strict;
use warnings;

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

my @columns = ("x", "y", "z", "world", "tile_id", "name");

# Tile types 0-3
my @tiles = ( "forest", "grass", "path", "water" );

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
            $col, $row, 0, 0,
            $map[$row][$col], $tiles[ $map[$row][$col] ]
        ];
    }
}

my @results = $schema->populate("Map", [ \@columns, @data ]);
# Should return 100 results (10x10)
print scalar(@results), " results\n";

