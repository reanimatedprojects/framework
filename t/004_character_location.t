use Test::More tests => 7;
use strict;
use warnings;

# the order is important
use RPG::App;
use RPG::DB;
use Dancer qw(:syntax :script :tests);
use Dancer::Test;
use Dancer::Plugin::DBIC qw(schema);

# Get an account (and hope it exists)
my $account = schema->resultset('Account')->find(2);
ok($account->account_id(), "account fetched");

# Get the first character (if there is one)
my @characters = $account->characters();
my $character = shift @characters;
ok($character->character_id(), "character fetched");

my $location = $character->location();
ok($location->map_id(), " got map");
ok($location->x == $character->x, " map/character x match");
ok($location->y == $character->y, " map/character y match");
ok($location->z == $character->z, " map/character z match");
ok($location->world == $character->world, " map/character world match");

