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

use strict;
use warnings;

# Local account creation
get '/character' => sub {
    my $vars = { };

    $vars->{ character_id } = param("id");
    $vars->{ character } = schema->resultset("Character")->find({
        character_id => $vars->{ character_id },
    });

    # Displaying a character profile doesn't require the user
    # to be logged in
    template "character" => $vars;
};

get '/character/create' => sub {
    my $vars = { };

    unless (session('account_id')) {
        debug "account id not found in session";
        # Set where to redirect back to after logging in
        session 'source' => '/account';
        return redirect "/login";
    }

    my $account = schema->resultset("Account")->find({
        account_id => session('account_id'),
    });
    $vars->{ account } = $account;

    unless ($account) {
        debug "account id ", session('account_id'), " not found.";
        # Set where to redirect back to after logging in
        session 'source' => '/character';
        return redirect "/login";
    }

    # Display the account page
    template "character_create" => $vars;
};

true;