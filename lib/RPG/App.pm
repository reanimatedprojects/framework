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

use RPG::Messages;

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
    # Blank out the account registration information so
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

# These are includes for the different pages that aren't directly
# included in this file.

require "page/account.pl";

# Using the Dancer keyword 'load' instead of the Perl keyword
# 'require' seems to cause warnings about schema possibly being
# reserved when used in the loaded file
#
require "page/register_local.pl";

# Define any hooks here

# Add Expires and Cache-Control headers to static content (css, images etc)
# Set it for one day from now.
hook after_file_render => sub {
    my $response = shift;
    my $cache_age = 86400;

    $response->header( "Cache-Control" => "max-age=$cache_age" );
    $response->header( "Expires" => POSIX::strftime(
        "%a, %d %b %Y %H:%M:%S GMT", gmtime( time() + $cache_age ) ) );
    return $response;
};


sub message {
    return RPG::Messages->message(@_);
}

true;
