package RPG;
use Dancer ':syntax';

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

# Register a new account
get '/register' => sub {
    # Blank out the account registration information so
    # the user starts again if they visit the /register url
    session "register" => undef;
    template "register";
};

post '/register' => sub {
    # Validate the form values from the first page

    # Only value is the authentication method (auth_type)
    my $auth = param("auth_type");
    if ($auth && $auth eq "local") {
        return redirect '/register/local';
    }
    template "register";
};

get '/register/local' => sub {
    # Local account creation only.
    template "register_local";
};

post '/register/local' => sub {
    # Local account creation only.
    template "register_local";
};

true;
