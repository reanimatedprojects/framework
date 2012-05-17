package RPG::DB;

# RPGWNN - Perl Browser-Based MMORPG Framework
# Copyright (C) 2011-2012 Reanimated Projects and Games Ltd

# This file is part of RPGWNN
#
# RPGWNN is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# RPGWNN is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with RPGWNN.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact information for Reanimated Projects and Games Ltd
# can be found at http://rpgwnn.com/

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

Copyright (C) 2011-2012 Reanimated Projects and Games Ltd

