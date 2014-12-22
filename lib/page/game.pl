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

# This file is not a module, it is simply 'require'd
# into the main RPG/App.pm

# Any other modules which are needed

use Data::Dumper;

use strict;
use warnings;

# Main game page
get '/game' => sub {
    return redirect "/game/index";
};

## All of these templates will need to validate the currently logged
## in account and character. They should then be passed a data structure
## containing character objects and any additional information required
## for the template. In the event that the logged in character isn't
## valid (deleted, retired, or just corrupt session data) we should
## present an error message with a link to reload /game/index and
## /game/index should handle redirection back to the account page if
## the account is valid but the character isn't, or back to the login
## page if the account isn't valid.

get '/game/index' => sub {
    my $vars = { };
    $vars->{ character } = fetch_character();

    # Ensure there's a character, if not, redirect back to account page
    unless ($vars->{ character }) {
        return redirect "/account";
    }





    template "game_index" => $vars;
};

# This provides just the map part of the game index page
get '/game/map' => sub {
    my $vars = { };
    $vars->{ character } = fetch_character();

    # Ensure there's a character, if not, redirect back to account page
    unless ($vars->{ character }) {
        return redirect "/account";
    }



    template "game_map" => $vars;
};

# This provides just the inventory
get '/game/inventory' => sub {
    my $vars = { };
    $vars->{ character } = fetch_character();

    # Ensure there's a character, if not, redirect back to account page
    unless ($vars->{ character }) {
        return redirect "/account";
    }



    template "game_inventory" => $vars;
};

# This provides just the current location description
get '/game/description' => sub {
    my $vars = { };
    $vars->{ character } = fetch_character();

    # Ensure there's a character, if not, redirect back to account page
    unless ($vars->{ character }) {
        return redirect "/account";
    }



    template "game_description" => $vars;
};

# This provides just the unseen game messages
get '/game/messages' => sub {
    my $vars = { };
    $vars->{ character } = fetch_character();

    # Ensure there's a character, if not, redirect back to account page
    unless ($vars->{ character }) {
        return redirect "/account";
    }



    template "game_messages" => $vars;
};

true;
