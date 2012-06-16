#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../lib";

use RPG::App;
use Dancer qw(:syntax :script);
use Dancer::Plugin::DBIC qw(schema);
use Dancer::Test;

my $schema = schema;
die "No schema defined" unless ($schema && (ref($schema) eq "RPG::DB"));

my $db_type = shift @ARGV || "MySQL";

eval "require SQL::Translator::Producer::$db_type";
if ($@) {
    die "Unknown database type $db_type - use 'sqlt -l' to get a list of Producers";
}

my $statements = $schema->deployment_statements($db_type);

print "Using database type $db_type\nWould execute:\n\n";
print $statements;

print "Ok? (y/N) ";
my $input = <STDIN>;
chomp $input;
die "Aborting" unless ($input =~ /^y/i);

$schema->deploy({ add_drop_table => 1 });

