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
get '/register/local' => sub {
    template "register_local";
};

post '/register/local' => sub {
    my $vars = { };

# 1 Check password is ok (at least 3 characters?)
# 2 Check email is ok (rfc822? format)
# 3 If both ok,
#   3.1 create the account using the email address
#   3.2 If it works,
#       3.2.1 register an authentication method for the account
#             (type=local, password=$password
#       3.2.2 If that works,
#           3.2.2.1 great - log them in
#           3.2.2.2 and redirect to the account page
#       3.2.3 If it fails,
#           3.2.3.1 delete the account that was created
#           3.2.3.2 setup error
#           3.2.3.3 redirect back to registration form with error
#   3.3 If it fails,
#       3.3.1 setup error
#       3.3.2 redirect back to registration form with error
# 4 If one or both fail,
#   4.1 setup error with bad email address error if applicable
#   4.2 setup error with bad password error if applicable
#   4.3 redirect back to registration form with error(s)

    # The email is stored in the accounts table, the password
    # field is in the account_auths_local table

# 1
    my $password    = param "password";
    my $password_ok = RPG::Utils->is_valid_password($password);
# 2
    my $email       = param "email";
    my $email_ok    = RPG::Utils->is_valid_email($email);
# 3
    if (($password_ok->{ status } eq "ok") &&
        ($email_ok->{ status } eq "ok")) {
# 3.1
        # Create an account object
        my ($new_account, $exception);
        try {
            $new_account = schema->resultset("Account")->create({
                email => $email,
            });
        } catch {
            $exception = $_;
            debug "Got an exception " . ref($exception) . " - $exception";
        };

        debug Dumper($new_account);
        debug "found new_account" if ($new_account);
        debug "account_id : " . $new_account->account_id if ($new_account);
        debug "found exception" if ($exception);
# 3.2
        # If the account was created successfully...
        if ((!$exception) && $new_account && $new_account->account_id) {

    debug "3.2.1";
# 3.2.1
            # FIXME: Add the authentication method to the account_auths table
            my $ram = $new_account->register_auth_method(
                auth_type => "local",
                password  => $password
            );

            debug Dumper($ram);
# 3.2.2
            if ($ram->{ status } eq "ok") {
                # Possibly not required unless it's stored in the session
                # as an 'account' message
                $vars->{ result } = RPG::Base->ok_response(
                    "ACCOUNT_CREATE_OK", # MSG
                );
# 3.2.2.1
                # FIXME: Login newly created account
# 3.2.2.2
                # FIXME: redirect to account page
            } else {
# 3.2.3

# 3.2.3.1
                # FIXME: Delete $new_account->{ id }
# 3.2.3.2
                $vars->{ result } = RPG::Base->error_response(
                    "ACCOUNT_CREATE_FAIL", # MSG
                    stage => "3.2.3.2",
                );
# 3.2.3.3 (just drop through to bottom)
            }
        } else {
# 3.3
            # FIXME: Figure out why it failed - perhaps the email
            # address is already in use by another account?
            # For now, just return a generic creation failed error
# 3.3.1
            debug Dumper($exception);

            $vars->{ result } = RPG::Base->error_response(
                "ACCOUNT_CREATE_FAIL", # MSG
                stage => "3.3.1",
            );
# 3.3.2 (just drop through to bottom)
        }
    } else {
# 4
        # FIXME: Highlight the fields they missed out
        $vars->{ result } = RPG::Base->error_response(
            "FORM_FIELD_INVALID", # MSG
        );
# 4.1
        $vars->{ result }{ bad_email } = message(
            $email_ok->{ error },
        ) unless ($email_ok->{ status } eq "ok");
# 4.2
        $vars->{ result }{ bad_password } = message(
            $password_ok->{ error },
        ) unless ($password_ok->{ status } eq "ok");
# 4.3 (just drop through to bottom)
    }

    template "register_local" => $vars;
};

true;
