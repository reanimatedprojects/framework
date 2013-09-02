
use Test::More;
use strict;
use warnings;

=pod

The simplest test possible. Do all the included modules, and the
main RPG::App module actually load successfully?

We don't test for Dancer because if that's not present, the whole
project won't work and it'll be pretty obvious.

We also don't test the individual DBIx::Class modules within the 
RPG::DB namespace as if any of these fail to compile, RPG::DB itself
will fail the use_ok test below.

=cut

our @modules = (
# Dancer plugins we need
    'Dancer::Plugin::DBIC',
    'Dancer::Plugin::Ajax',
# DBIx::Class (rather important)
    'DBIx::Class',
# Assorted other modules whose absence may not be noticed immediately
    'JSON',
    'URI::Escape',
    'Mail::RFC822::Address',
# Now the schema
    'RPG::DB',
# And finally the app
    'RPG::App',
);

foreach my $module (@modules) {
    use_ok $module;
}
done_testing(scalar(@modules));
