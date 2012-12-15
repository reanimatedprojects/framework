package RPG::DB::ResultSet::Account;

use base qw/DBIx::Class::ResultSet RPG::Base/;

use Try::Tiny;
use Dancer ':syntax';

use strict;
use warnings;

=head2 $account = get_account_by_email( $email )

Takes an email address and returns an ok/error response hashref.
If successful, ok_response includes an account attribute which
is the resultset object

=cut

sub get_account_by_email {
    my $self = shift;
    my $email = shift || return $self->error_response(
        "EMAIL_INVALID", # MSG
    );

    my (@accounts, $exception);
    try {
        my $account_rs = $self->search({
            email => $email,
        });
        # If everything is valid in the database, this should only ever
        # return a single row or nothing at all.
        @accounts = $account_rs->all();
    } catch {
        $exception = $_;
        debug "Got an exception " . ref($exception) . " - $exception";
    };

    if (! $exception) {
        if (scalar(@accounts) == 1) {
            my $account = shift @accounts;
            return $self->ok_response(
                account => $account,
            );
        }
        return $self->error_response(
            "ACCOUNT_NOTFOUND", # MSG
            accounts => \@accounts,
        );
    }
    return $self->error_response(
        "ACCOUNT_NOTFOUND", # MSG
        exception => $exception,
    );
}

1;
