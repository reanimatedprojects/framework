use Test::More tests => 9;
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
my $account = schema->resultset('Account')->find_or_create({
    email => 'dummy@example.com'
});
ok($account, "account found or created");
ok($account->account_id(), "account fetched");

my $tile = schema->resultset('Tile')->find({ name => "water" });
unless ($tile) {
    print "No tile, creating\n";
    $tile = schema->create({
        name => "water", description => "Pond", background_image => "water.png", background_colour => "#3333cc"
    });
}

my $map = schema->resultset('Map')->find({
    x => 0, y => 0, z => 0, world => 0
});
unless ($map) {
    print "No map, creating\n";
    $map = schema->resultset('Map')->create({
        x => 0, y => 0, z => 0, world => 0
    });
}

# Get the first character (if there is one), or create one
my @characters = $account->characters();
my $character;
if (scalar(@characters) == 0) {
    print "No characters, creating\n";
    $character = $account->create_related('characters', {
        name => "Dummy",
        xp => 0,
        disabled => "",
        x => $map->x, y => $map->y,
        z => $map->z, world => $map->world,
    });
} else {
    $character = shift @characters;
}
ok($character->character_id(), "character fetched");

my $location = $character->location();
ok($location->map_id(), " got map");
ok($location->x == $character->x, " map/character x match");
ok($location->y == $character->y, " map/character y match");
ok($location->z == $character->z, " map/character z match");
ok($location->world == $character->world, " map/character world match");

isa_ok($location, "RPG::DB::Result::Map");

my $map_size = { min_x => 0, max_x => 0, min_y => -1, max_y => 1, };
my $results = $location->fetch_map_area({
    min_x => $map_size->{ min_x }, max_x => $map_size->{ max_x },
    min_y => $map_size->{ min_y }, max_y => $map_size->{ max_y },
    z => 0, world => 0
});

for (my $col = 0; $col <= ($map_size->{ max_x } - $map_size->{ min_x }); $col++) {
    if (! defined $results->[$col]) {
        # If [$col] is undefined then the whole column is undefined
        print "col: $col is undefined.\n";
        next;
    }
    print "col: $col has ", scalar(@{$results->[$col]}), " rows\n";

    for (my $row = 0; $row <= ($map_size->{ max_y } - $map_size->{ min_y }); $row ++) {

        my $cell = $results->[$col][$row];
        if (defined $cell) {
            print " $col, $row : ", join (",", $cell->id, $cell->x, $cell->y, $cell->z, $cell->world), "\n";
        } else {
            print " $col, $row : undef\n";
        }
    }
}

print Dumper($results);

