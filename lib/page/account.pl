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

use strict;
use warnings;

# Local account creation
get '/account' => sub {
    my $vars = { };

    my $account = fetch_account();
    if (! $account) {
        # At this point, if no account was returned, a redirect
        # will already have been setup so we just return to make
        # it take effect.
        return;
    }
    $vars->{ account } = $account;


    # Display the account page
    template "account" => $vars;
};

true;
