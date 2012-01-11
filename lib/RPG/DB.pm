package RPG::DB;

=head1 NAME

RPG::DB - Database Schema module

=head1 SYNOPSIS

This module initialises the database modules using DBIx::Class and
provides the base schema

=head1 EXAMPLE

 # Initialise database connection
 my $schema = RPG::DB->connect("dbi:mysql:dbname", "dbuser", "dbpass");

 # Load account id 1
 my $account = $schema->resultset("Accounts")->find(1);

=cut

use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces();

1;

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011 Reanimated Projects and Games Ltd

