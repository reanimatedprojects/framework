
# Local account creation
get '/register/local' => sub {
    template "register_local";
};

post '/register/local' => sub {
    my $vars = { };

    template "register_local" => $vars;
};

true;
