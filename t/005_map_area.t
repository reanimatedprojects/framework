use Test::More tests => 1;
use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Maxdepth = 4;

# the order is important
use RPG::App;
use RPG::DB;
use Dancer qw(:syntax :script :tests);
use Dancer::Test;
use Dancer::Plugin::DBIC qw(schema);

# Get an account or create one
my $map = schema->resultset('Map')->find({
    x => 0, y => 0, z => 0, world => 0
});
unless ($map) {
    print "No map, creating\n";
    $map = schema->resultset('Map')->create({
        x => 0, y => 0, z => 0, world => 0
    });
}

isa_ok($map, "RPG::DB::Result::Map");

## Need to convert the following into useful tests to ensure that
## fetching the map area give the correct values including sizes
## of arrays returned and actual content.

my $map_size = { min_x => 0, max_x => 1, min_y => -1, max_y => 1, };
my $results = $map->fetch_map_area( radius => 1 );

print "min_x: $map_size->{ min_x }\n";
print "max_x: $map_size->{ max_x }\n";

print "min_y: $map_size->{ min_y }\n";
print "max_y: $map_size->{ max_y }\n";

for (my $col = 0; $col <= ($map_size->{ max_x } - $map_size->{ min_x }); $col++) {
    if (! defined $results->[$col]) {
        # If [$col] is undefined then the whole column is undefined
        print "col: $col is undefined.\n";
        next;
    }
    print "\ncol: $col has ", scalar(@{$results->[$col]}), " rows\n";

    for (my $row = 0; $row <= ($map_size->{ max_y } - $map_size->{ min_y }); $row ++) {

        print "x: ", $col + $map_size->{ min_x }, ", y: ", $row + $map_size->{ min_y }, "\n";
        my $cell = $results->[$col][$row];
        if (defined $cell) {
            print " $col, $row : ", join (",", $cell->id, $cell->x, $cell->y, $cell->z, $cell->world), "\n";
        } else {
            print " $col, $row : undef\n";
        }
    }
}
print "\n";
# print Dumper($results);

