use Test::More tests => 6;
use strict;
use warnings;

# the order is important
use RPG::App;
use RPG::DB;
use Dancer qw(:syntax :script :tests);
use Dancer::Test;
use Dancer::Plugin::DBIC qw(schema);

my $schema = schema;

my $email = 'dummy@example.com';

# Check to see if there's already one with that email address
my $account1 = $schema->resultset('Account')->find({ email => $email });
if ($account1) {
    # Delete it if there is otherwise the next test will fail
    print "Found account with email=$email\n";
    print "Deleting account ", $account1->account_id, "\n";
    $account1->delete;
    # If it fails to delete (e.g has characters) things go wrong
}

my $account2 = $schema->resultset('Account')->create({
    email => $email,
});

if (! defined $account2) {
    die "duplicate";
}

ok($account2->account_id, "account object created");
ok($account2->email eq $email, "  and email matches the one used");

my $account3 = $schema->resultset('Account')->find( $account2->account_id );
ok($account3, "account object fetched by id");
ok($account3->email eq $email, "  and email matches the original");

# Final cleanup of the two newly created accounts
ok($account2->delete, "created account deleted");
ok($account3->delete, "fetched account deleted"); # Should be the same as above
