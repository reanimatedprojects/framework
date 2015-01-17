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
    x => 0, y => 0, z => 0, world => 1
});
unless ($map) {
    print "No map, creating\n";
    $map = schema->resultset('Map')->create({
        x => 0, y => 0, z => 0, world => 1,
        tile_id => $tile->tile_id, name => $tile->name,
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
    $character->update({ x => $map->x, y => $map->y, z => $map->z, world => $map->world });
}
ok($character->character_id(), "character fetched");

my $location = $character->location();
ok($location->map_id(), " got map");
ok($location->x == $character->x, " map/character x match");
ok($location->y == $character->y, " map/character y match");
ok($location->z == $character->z, " map/character z match");
ok($location->world == $character->world, " map/character world match");

isa_ok($location, "RPG::DB::Result::Map");

print "location->tile_id : ", $location->tile_id, "\n";

print "location->tile->tile_id : ", $location->tile->tile_id, "\n";

