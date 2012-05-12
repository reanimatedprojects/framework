package RPG;
use Dancer ':syntax';
use POSIX;
use Dancer::Plugin::DBIC qw(schema);

use RPG::Messages;

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

load "page/register_local.pl";

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
