package RPG::App;

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

use Dancer ':syntax';
use POSIX;
use Dancer::Plugin::DBIC qw(schema);

# We want message() from RPG::Messages
use RPG::Messages;
# We want args() from RPG::Base
use RPG::Base;

use strict;
use warnings;

# This can be time-consuming so do it once only on startup
POSIX::setlocale(LC_MESSAGES, '');

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

# Register a new account
get '/register' => sub {
    # Blank out the account registration information so
    # the user starts again if they visit the /register url
    session "register" => undef;

    my @auth_keys = keys %{config->{ auths }};
    if (scalar(@auth_keys) == 1) {
        my $auth_key = shift @auth_keys;
        return redirect "/register/" . $auth_key;
    }
    template "register" => { auths => config->{ auths } };
};

post '/register' => sub {
    # Validate the form values from the first page

    # Only value is the authentication method (auth_type)
    my $auth_param = param("auth_type");
    # If no auth parameter was provided, just show the template page
    unless ($auth_param) {
        template "register" => { auths => config->{ auths } }
    }

    # Extract the auth information
    my $auth_info = config->{ auths }{ $auth_param };
    if ($auth_info && $auth_info) {
        # Redirect to the relevant registration page
        return redirect "/register/" . $auth_param;
    }
    template "register" => { auths => config->{ auths } };
};

get '/login' => sub {
    # Figure out if there's somewhere we need to be returned back to
    my $source = session('requested_path');
    if (defined $source) {
        debug "Source is $source";
    } else {
        debug "Direct to /login";
    }
    $source ||= "/account";

    # More than one auth method? If so, prompt for login method
    my @auth_keys = keys %{config->{ auths }};
    if (scalar(@auth_keys) == 1) {
        my $auth_key = shift @auth_keys;
        return redirect "/login/" . $auth_key;
    }
    template "login" => { auths => config->{ auths } };
};

post '/login' => sub {
    # Validate the form values from the first page

    # Only value is the authentication method (auth_type)
    my $auth_param = param("auth_type");
    # If no auth parameter was provided, just show the template page
    unless ($auth_param) {
        template "login" => { auths => config->{ auths } }
    }

    # Extract the auth information
    my $auth_info = config->{ auths }{ $auth_param };
    if ($auth_info && $auth_info) {
        # Redirect to the relevant registration page
        return redirect "/login/" . $auth_param;
    }
    template "login" => { auths => config->{ auths } };
};

# These are includes for the different pages that aren't directly
# included in this file.

# Main account page (must be logged in)
require "page/account.pl";

# Using the Dancer keyword 'load' instead of the Perl keyword
# 'require' seems to cause warnings about schema possibly being
# reserved when used in the loaded file
#
# Register a local account (email+password)
require "page/register_local.pl";

# Login with a local account (email+password)
require "page/login_local.pl";

# Logout of any account
require "page/logout.pl";

# Character profile
require "page/character.pl";

# Game page
require "page/game.pl";

# Define any hooks here

# Add Expires and Cache-Control headers to static content (css, images etc)
# Set it for one day from now.
hook after_file_render => sub {
    my $response = shift;
    my $cache_age = 86_400;

    $response->header( 'Cache-Control' => "max-age=$cache_age" );
    $response->header( 'Expires' => POSIX::strftime(
        '%a, %d %b %Y %H:%M:%S GMT', gmtime( time() + $cache_age ) ) );
    return $response;
};

=head2 fetch_account( [ no_redirect => 1 ] )

If no_redirect is true, the account is optional so if the user isn't
logged in we won't setup a redirect to /login - need to check $account
before attempting to use it though!

    my $account = fetch_account( no_redirect => 1 );

If false (or omitted) the account is required for access to the page
and the redirect to /login will be setup so the calling function can
do something like:

    my $account = fetch_account();
    if (! $account) { return; }

=cut

sub fetch_account {
    # If this function is passed a true value, the account is optional
    # and we will simply return undef
    my $args = RPG::Base->args(@_);

    if (! session('account_id')) {
        # If a valid account is required, redirect to /login
        if (! $args->{ no_redirect }) {
            session 'requested_path' => request->path_info;
            debug 'Redirecting to /login from ' . session('requested_path');
            redirect '/login';
        }
        # Return an undef value (optional=1 results in no account returned)
        return;
    }

    my $account = schema->resultset("Account")->find({
        account_id => session('account_id'),
    });

    # This would only be empty if the session contained an account id
    # that had been deleted. Since we shouldn't ever delete accounts
    # this is hopefully never going to be executed and is included for
    # completeness.
    if ((! $account) && (! $args->{ no_redirect })) {
        debug "session account_id " . session('account_id') .  " not found in db.";
        session 'requested_path' => request->path_info;
        session 'account_id' => undef;
        debug 'Redirecting to /login from ' . session('requested_path');
        return redirect '/login';
    }

    return $account;
}


sub fetch_character {
    my $cid;
    unless ($cid = session('character_id')) {
        return undef;
    }
    my $aid = session('account_id');
    my $character = schema->resultset("Character")->find({
        character_id => $cid,
    });
    if ($character && $aid && ($character->account_id != $aid)) {
        debug "got character and account_id but character's account id doesn't match";
        return undef;
    }
    return $character;
}

sub message {
    return RPG::Messages->message(@_);
}

true;
