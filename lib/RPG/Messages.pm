package RPG::Messages;

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

use Locale::Messages; # qw(:libintl_h); adding this causes warnings
use Locale::TextDomain ("com.rpgwnn");

=head1 NAME

RPG::Messages - a generic message module

=head1 DESCRIPTION

This module converts strings into alternative languages (if translation
files are available). To translate the messages, create a .mo file within
lib/LocaleData

The exact path will vary depending on the locale that you're translating
for. To change the English translation, you would use en, en_GB or 
en_GB.UTF-8 as the locale code.
For example, lib/LocaleData/en_GB.UTF-8/LC_MESSAGES/com.rpgwnn.mo

=head1 SYNOPSIS

    # Locale message translation
    use Locale::Messages qw(LC_MESSAGES);
    use Locale::TextDomain ("com.rpgwnn");

    # This can be time-consuming so do it once only
    POSIX::setlocale(LC_MESSAGES, '');

=head1 METHODS

=head2 $obj = $class->new( )

Initialises the object. Not really required as you can just call it
like this.

 RPG::Messages->message("...");

=cut

sub new {
    my $class = shift;
    my $self = { };

    bless $self, $class;
}

=head2 $str = $obj->message( $code_str, @params )

This method takes a message (and optional parameters) and converts
it to a human-readable language if there are translations available.

=cut

sub message {
    my $self = shift;
    my $msg = shift;

    return "$msg: " . join ",", map { "\"$_\"" } @_;

# See perldoc Locale::TextDomain for information about translating
# strings containing parameters e.g __x() __n() and __nx()

#    return __"Unknown error" unless $msg;
#    return __$msg;
}

1;

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011-2012 Reanimated Projects and Games Ltd
