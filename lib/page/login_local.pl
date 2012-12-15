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

use constant PW_RESET_SECRET => 'Secr3t!';

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
        # The above creates a hash with status/error keys.
        $vars->{ result }{ bad_email } = message(
            $email_ok->{ error },
        );
        template "login_local" => $vars;
    }
# 3

    # Create an account object
    my $result = schema->resultset("Account")->get_account_by_email( $email );
    my $account = ($result->{ status } eq "ok") ?
        $result->{ account } : undef;
    my $exception = ($result->{ status } eq "error") ?
        $result->{ exception } : undef;

    debug Dumper($account);
    debug "found account" if ($account);
    debug "account_id : " . $account->account_id if ($account);
    debug "found exception" if ($exception);
# 4
    # If the account was located successfully...
    if ($account && $account->account_id) {

        debug "4.1";
# 4.1
        my $password = param 'password';

#   4.2 If there's a 'local' entry
        my $account_auth_local = $account->fetch_auth_method({ auth_type => 'local' });
        if ($account_auth_local && $account_auth_local->{ account_auth } && $password) {
#       4.2.1 Compare the (hashed) password with the hash of the one given
            if ($account_auth_local->{ account_auth }->check_password( $password )) {
#       4.2.2 If it matches,
                debug "Login ok";
#           4.2.2.1 log the user in (set session vars)
                my $destination = '/account';
                # If there's a 'source' defined in session, use it as the destination
                if (session('source')) {
                    $destination = '/' . session('source');
                    # Remove the source definition
                    session source => undef;
                }
                # Redirect
                return redirect $destination;
            } else {
#       4.2.3 else login error (bad password)
                $vars->{ result } = RPG::Base->error_response(
                    "ACCOUNT_LOGIN_FAIL", # MSG
                    stage => "4.2.3",
                );
            }
#   4.3 else login error (no local account for this email)
        } else {
            $vars->{ result } = RPG::Base->error_response(
                "ACCOUNT_LOGIN_FAIL", # MSG
                stage => "4.3",
            );
        }

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

=head2 login_local_pwrecover

Ask for email address, and on submission lookup account and either display
'not found' error message, or send an email with a link to the password reset
page.

=cut

get '/login/local/pwrecover' => sub {
    template "login_local_pwrecover";
};

post '/login/local/pwrecover' => sub {
    my $vars = { };

    my $email       = param "email";
    my $email_ok    = RPG::Utils->is_valid_email($email);

    if ($email_ok->{ status } ne "ok") {
        $vars->{ result } = {
            status => "error",
            error => ($email_ok->{ error } || "EMAIL_INVALID"), # MSG
        };
    } else {
        # Create an account object
        my $result = schema->resultset("Account")->get_account_by_email( $email );
        my $account = ($result->{ status } eq "ok") ?
            $result->{ account } : undef;
        my $exception = ($result->{ status } eq "error") ?
            $result->{ exception } : undef;

        debug Dumper($account);
        debug "found account" if ($account);
        debug "account_id : " . $account->account_id if ($account);
        debug "found exception" if ($exception);

        $vars->{ account } = $account;

        # If the account was located successfully...
        if ($account && $account->account_id) {

            my $reset_url = uri_for("/login/local/pwreset");
            my $reset_param = $account->account_id . "/" . time();

            my $password_checksum = RPG::Utils->short_checksum(
                $reset_param,  PW_RESET_SECRET
            );

            $reset_url .= "?acc=$reset_param/" . RPG::Utils->uri_escape($password_checksum);
            debug "send the pwrecover email - url $reset_url";

            # Temporary way to show it on the page until the email is sent
            $vars->{ reset_url } = $reset_url;

            $vars->{ result } = {
                status => "ok",
                message => "EMAIL_PWRECOVER_SENT", # MSG
            };

        } else {
            $vars->{ result } = {
                status => "error",
                error => ($exception || "ACCOUNT_NOTFOUND"), # MSG
            };
        }

    }

    template "login_local_pwrecover" => $vars;
};

=head2 login_local_pwreset

GET /login/local/pwreset?acc=ID/TIMESTAMP/CHECKSUM
POST /login/local/pwreset

ID = accounts.id
TIMESTAMP = unixtime
CHECKSUM = md5 of secret, id and timestamp (and maybe other stuff)

If POSTed data, includes the acc parameter as well
as password1 and password2 which are the new password
to use for the account.

=cut

any ['get', 'post'] => '/login/local/pwreset' => sub {
    my $vars = { };

    my $accparam = param "acc";
    my ($acc_id, $time, $given_checksum) = split '/', $accparam, 3;
    # Up to an hour old...
    my $too_old = time() - 3600;
    # But only 5m the other way
    my $too_new = time() + 300;

    # Calculate the checksum for the provided parameters
    my $password_checksum = RPG::Utils->short_checksum(
        "$acc_id/$time",  PW_RESET_SECRET
    );

    # Search for the account by id
    my $account = schema->resultset("Account")->find({
        account_id => $acc_id
    });

    # Check if we have the new password parameters
    my $password1 = param "password1";
    my $password2 = param "password2";

    if (($time < $too_old) || ($time > $too_new)) {
        # This password reset link has expired
        $vars->{ result } = RPG::Base->error_response(
            "LINK_EXPIRED", # MSG
        );

    } elsif ($given_checksum ne $password_checksum) {
        # This password reset link is invalid
        $vars->{ result } = RPG::Base->error_response(
            "LINK_INVALID", # MSG
        );

    } elsif (! $account) {
        # Account not found
        $vars->{ result } = RPG::Base->error_response(
            "ACCOUNT_NOTFOUND", # MSG
        );

    } elsif ($password1 && $password2 && ($password1 eq $password2)) {
        # A variable for the template...
        $vars->{ account } = $account;

        # Go ahead and reset it as the new passwords matched

        # Fetch the local auth object
        # Update the password field
        my $account_auth_result = $account->fetch_auth_method( auth_type => "local" );

        if ($account_auth_result->{ status } eq "ok") {
            my $account_auth = $account_auth_result->{ account_auth };

            # Set the password!
            $account_auth->password( $password1 );
            $account_auth->update();

            $vars->{ result } = RPG::Base->ok_response(
                message => "PASSWORD_RESET", # MSG
            );
        } else {
            # There was an error fetching the auth object
            $vars->{ result } = RPG::Base->error_response(
                "PASSWORD_RESET_ERROR", # MSG
            );
        }

    } else {
        # Allow the reset as the checksum matched, the account
        # was found, and the time is still recent enough
        debug "Allow user to reset the password";

        # Update a new acc parameter with an updated timeout.
        my $new_reset_param = $account->account_id . "/" . time();
        my $new_password_checksum = RPG::Utils->short_checksum(
            $new_reset_param,  PW_RESET_SECRET
        );
        # Template content that will be required for the page
        $vars->{ acc } = "$new_reset_param/$new_password_checksum";
        $vars->{ account } = $account;

        # Passwords were provided but didn't match, as opposed
        # to not being provided at all during first page load
        if ($password1 && $password2 && ($password1 ne $password2)) {
            # If we set it as 'error', it would prevent the user
            # from retrying the password reset without clicking
            # on the link again
            $vars->{ result } = RPG::Base->error_response(
                "PASSWORD_MISMATCH", # MSG
            );
        }
    }

    template "login_local_pwreset" => $vars;
};

true;
