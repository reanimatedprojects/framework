# RPGWNN - Perl Browser-Based MMORPG Framework
# Copyright (C) 2013 Reanimated Projects and Games Ltd

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

use RPG::Utils;
use RPG::Base;
use URI::Escape;
use Dancer::Plugin::Ajax;

use strict;
use warnings;

# Redirect to character search
get '/character' => sub {
    return redirect "/character/search";
};

# Search characters by name
any ['get','post'] => '/character/search' => sub {
    my $vars = { };
    $vars->{ character_name } = trim_space( param "character_name" );
    if ($vars->{ character_name }) {
        my $uri_name = uri_escape($vars->{ character_name });
        return redirect "/character/search/" . $uri_name;
    }
    template "character_search" => $vars;
};

get '/character/search/:character_name' => sub {
    my $vars = { };

    # Need to strip spaces from start/end!
    $vars->{ character_name } = trim_space( params->{ character_name } );

    if (length($vars->{ character_name }) < 3) {
        $vars->{ message } = message( "CHARACTER_NAME_TOOSHORT" ); # MSG
        return template "character_search" => $vars;
    }

    my @characters = schema->resultset("Character")->search({
        name => { like => "%" . $vars->{ character_name } . "%" }
    })->all();

    # If it's an exact match (case insensitive), redirect to the profile
    if ((scalar(@characters) == 1) &&
        (lc($characters[0]->name()) eq lc($vars->{ character_name }))) {
        return redirect "/character/" . $characters[0]->id();
    }

    $vars->{ characters } = \@characters;
    template "character_search" => $vars;
};

ajax '/character/search' => sub {
    my $vars = { };

    # Need to strip spaces from start/end!
    $vars->{ character_name } = trim_space( params->{ character_name } );

    debug ":$vars->{ character_name }:";
    if (length($vars->{ character_name }) < 3) {
        $vars->{ status } = "error";
        $vars->{ message } = message( "CHARACTER_NAME_TOOSHORT" ); # MSG
        return template "character_search_xml" => $vars;
    }

    # Exact match for the name?
    my $characters = schema->resultset("Character")->search({
        name => $vars->{ character_name }
    });
    # If there's an exact match, return the character data
    if ($characters->count() == 1) {
        $vars->{ character } = $characters->first();
        $vars->{ status } = "error";
        $vars->{ message } = message( "CHARACTER_NAME_EXISTS" );
    } else {
        $vars->{ status } = "ok";
        $vars->{ message } = message( "CHARACTER_NAME_OK" );
    }
    template "character_search_xml" => $vars;
};

# Display character profiles
get '/character/:character_id' => sub {
    my $vars = { };

    $vars->{ character_id } = trim_space( params->{ character_id } );
    $vars->{ character } = schema->resultset("Character")->find({
        character_id => $vars->{ character_id },
    });

    # Displaying a character profile doesn't require the user
    # to be logged in
    template "character" => $vars;
};

# Character creation
get '/character/create' => sub {
    my $vars = { };

    my $account = fetch_account();
    if (! $account) { return; }

    $vars->{ account } = $account;

    # Check the limit hasn't been reached yet
    my @account_characters = $account->characters();
    if (scalar(@account_characters) >= $account->max_characters()) {
        session 'account_message' => RPG::Base->error_response(
            "ACCOUNT_MAX_CHARACTERS", # MSG
            current => scalar(@account_characters),
            maximum => $account->max_characters(),
        );
        return redirect "/account";
    }

    # Display the account page
    template "character_create" => $vars;
};

true;
