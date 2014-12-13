package RPG::DB::Result::Account;

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

=head1 NAME

RPG::DB::Result::Account - Database module for user accounts

=head1 DESCRIPTION

This module associates an account id with an email address. Other fields
will be added as required.

The account id provides a reference into the account_auths table which
holds data for various authentication methods such as local accounts or
remote authentication via openid/facebook/etc.

=head1 METHODS

=cut

use base qw/DBIx::Class::Core RPG::DB::Base/;

use Dancer ':syntax';

use strict;
use warnings;

__PACKAGE__->table("accounts");
__PACKAGE__->add_columns(
    account_id => {
        data_type           => "integer",
        size                => 11,
        is_auto_increment   => 1,
        extra               => { unsigned => 1 },
    },
    email => {
        data_type           => "char",
        size                => 128,
        is_nullable         => 0,
    },
    max_characters => {
        data_type           => "integer",
        size                => 4,
        extra               => { unsigned => 1 },
        is_nullable         => 0,
    },
);
__PACKAGE__->set_primary_key('account_id');
__PACKAGE__->add_unique_constraint("email" => [qw/email/]);
__PACKAGE__->has_many(
    account_auths => 'RPG::DB::Result::AccountAuth',
    'account_id'
);
__PACKAGE__->has_many(
    characters => 'RPG::DB::Result::Character',
    'account_id'
);

=head2 new()

We override this method so that we can check the email
address provided is valid in appearance. The email verification
email/url will be used to check that it actually works.

=cut

sub new {
    my ( $class, $attrs ) = @_;

    # FIXME: Verify the email address is a valid-looking address
    # FIXME: Check what to return if it's not - what does DBIx::Class do?
    #
    return unless ($attrs->{ email } &&
        $attrs->{ email } =~ /\@/);

    # Set the default number of characters allowed. This is used rather
    # than setting a default_value in the add_columns definition because
    # that would require re-fetching the row after inserting it.
    $attrs->{ max_characters } = 3
        unless exists $attrs->{ max_characters };

    my $new = $class->next::method($attrs);
    return $new;
}

=head2 register_auth_method( auth_type => "TYPE", ... )

Add an authentication method to the current account. auth_type would be
a word such as "local" and has corresponding files within the system.

For example, the "local" authentication method (email + local password)
has the following files associated with it.

* lib/page/register_local.pl
    - display the registration page for local accounts

* views/register_local.tt
    - the registration page template for local accounts

* lib/RPG/Auth/Local.pm
    - methods for processing local authentication (non-db)

* lib/RPG/DB/Result/AccountAuthLocal.pm
    - database module for local authentication

=cut

sub register_auth_method {
    my $self = shift;
    my $args = $self->args(@_);

    my $auth_type = delete $args->{ auth_type };

    return $self->error_response(
        "ACCOUNT_AUTHTYPE_INVALID", # MSG
    ) unless (defined $auth_type);

    # The auth_type refers to a section within the auths part
    # of config.yml and this section contains certain keys
    # related to how the authentication method is used.
    return $self->error_response(
        "ACCOUNT_AUTHTYPE_INVALID", # MSG
    ) unless (defined config->{ auths }{ $auth_type });

    # Auth method $auth_type adding for account $self->{ id }

    my $account_auth = $self->create_related( "account_auths", {
        auth_type => $auth_type,
    });

    # If it failed to create the record, return an error
    # This might happen if there are some unique keys and we
    # already have a particular auth method registered for an
    # account.
    # FIXME: Nicer and more helpful error required
    return $self->error_response(
        "ACCOUNT_REGISTERAUTH_FAIL", # MSG
    ) unless ($account_auth && $account_auth->account_auth_id);

    # Added successfully? Create the linked record based on the auth_type
    # FIXME: watch out here as there is no trap for undefined
    # resultset variable in the config.yml!
    my $resultset = config->{ auths }{ $auth_type }{ table };

    # The account_auth_XXXX record needs an account_auth_id
    $args->{ account_auth_id } = $account_auth->account_auth_id;

    # Create the linked record
    my $schema = $self->result_source->schema;
    my $authresult = $schema->resultset($resultset)->create( $args );
    unless ($authresult) {
        # If it failed, remove the account_auths record
        $account_auth->delete();
        return $self->error_response(
            "ACCOUNT_REGISTERAUTH_FAIL", # MSG
        );
    }
    # we have to return $self->ok_response() so that we can test
    # the status attribute and have it work for both errors and ok
    return $self->ok_response(
        account_auth => $account_auth,
    );
}

=head2 fetch_auth_method( auth_type => "TYPE", ... )

Fetch an authentication method for the current account. auth_type would be
a word such as "local" and has corresponding files within the system.

=cut

sub fetch_auth_method {
    my $self = shift;
    my $args = $self->args(@_);

    my $auth_type = delete $args->{ auth_type };

    return $self->error_response(
        "ACCOUNT_AUTHTYPE_INVALID", # MSG
    ) unless (defined $auth_type);

    # The auth_type refers to a section within the auths part
    # of config.yml and this section contains certain keys
    # related to how the authentication method is used.
    return $self->error_response(
        "ACCOUNT_AUTHTYPE_INVALID", # MSG
    ) unless (defined config->{ auths }{ $auth_type });

    # Auth method $auth_type fetch for account $self->{ id }
    my $account_auths = $self->account_auths->search({
        auth_type => $auth_type,
    });

    my @account_auth_array = $account_auths->all();
    if (scalar(@account_auth_array) != 1) {
        return $self->error_response(
            "ACCOUNT_AUTHTYPE_INVALID", # MSG
        );
    }
    my $account_auth = shift @account_auth_array;

    # Fetch the linked record based on the auth_type
    # FIXME: watch out here as there is no trap for undefined
    # resultset variable in the config.yml!
    my $resultset = config->{ auths }{ $auth_type }{ table };

    my $schema = $self->result_source->schema;
    my $authresult = $schema->resultset($resultset)->search({
        account_auth_id => $account_auth->id(),
    })->first();

    # we have to return $self->ok_response() so that we can test
    # the status attribute and have it work for both errors and ok
    return $self->ok_response(
        account_auth => $authresult,
    );
}

1;

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011-2012 Reanimated Projects and Games Ltd

