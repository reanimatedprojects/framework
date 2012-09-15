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

use RPG::Utils;
use RPG::Base;
use Try::Tiny;

use Data::Dumper;

use strict;
use warnings;

# Local account creation
get '/login/local' => sub {
    template "login_local";
};

post '/login/local' => sub {
    my $vars = { };

# 1 Check email is ok (rfc2822 format)
# 2 If it's not,
#   2.1 setup error for invalid email format
#   2.2 display login page with error
# 3 else check accounts record exists for the email address given
# 4 If it does,
#   4.1 Load the AccountsAuths list for the account
#   4.2 If there's a 'local' entry
#       4.2.1 Compare the (hashed) password with the hash of the one given
#       4.2.2 If it matches,
#           4.2.2.1 log the user in (set session vars)
#           4.2.2.2 If there's a 'source' defined in session
#               4.2.2.2.1 redirect to it
#           4.2.2.3 else redirect to account page
#       4.2.3 else login error (bad password)
#   4.3 else login error (no local account for this email)
# 5 else no account for that email
#   5.1 display password recovery option (link)

# 1
    my $email       = param "email";
    my $email_ok    = RPG::Utils->is_valid_email($email);
# 2
    if ($email_ok->{ status } ne "ok") {
# 2.1
        # FIXME: Highlight the fields they missed out
        $vars->{ result } = RPG::Base->error_response(
            "FORM_FIELD_INVALID", # MSG
        );
# 2.2
        $vars->{ result }{ bad_email } = message(
            $email_ok->{ error },
        );
        template "login_local" => $vars;
    }
# 3

    # Create an account object
    my ($account, $exception);
    try {
        $account = schema->resultset("Account")->fetch({
            email => $email,
        });
    } catch {
        $exception = $_;
        debug "Got an exception " . ref($exception) . " - $exception";
    };

    debug Dumper($account);
    debug "found account" if ($account);
    debug "account_id : " . $account->account_id if ($account);
    debug "found exception" if ($exception);
# 4
    # If the account was located successfully...
    if ((!$exception) && $account && $account->account_id) {

        debug "4.1";
# 4.1



    } else {
# 5
        # FIXME: Figure out why it failed - perhaps the email
        # address is already in use by another account?
        # For now, just return a generic creation failed error
# 5.1
        debug Dumper($exception);

        $vars->{ result } = RPG::Base->error_response(
            "ACCOUNT_LOGIN_FAIL", # MSG
            stage => "5.1",
        );
# 5.2 (just drop through to bottom)
    }
    template "login_local" => $vars;
};

true;
