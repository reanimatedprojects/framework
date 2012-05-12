
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
