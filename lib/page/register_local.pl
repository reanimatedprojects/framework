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

# This file is not a module, it is simple 'require'd
# into the main RPG/App.pm

# Any other modules which are needed

use RPG::Utils;

# Local account creation
get '/register/local' => sub {
    template "register_local";
};

post '/register/local' => sub {
    my $vars = { };

    my $username = param "username";
    my $password = param "password";

    if ($username && $password) {

        # Create an account object
        # Then add the local auth method to it

        # This next line causes a warning:
        # Unquoted string "schema" may clash with future reserved word
        my $new_account = schema->resultset("Account")->create({ email => param "email" });
        # If an error occurred creating the new account..
        unless ($new_account) {

            # FIXME: Figure out why it failed - perhaps the email
            # address is already in use by another account?
            $vars->{ result } = {
                status => "error",
                message => message("Account creation failed"), #MSG
            };
        }

        debug "Created.\n";

        # FIXME: Add the authentication method to the account_auths table
        $vars->{ result } = {
            status => "ok",
            message => message("Account created successfully"), #MSG
        };


    } else {

        # FIXME: Highlight the fields they missed out
        $vars->{ result } = {
            status => "error",
            message => message("You need to fill all required fields"), #MSG
        };

    }

    template "register_local" => $vars;
};

true;
