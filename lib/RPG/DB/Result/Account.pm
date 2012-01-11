package RPG::DB::Result::Account;

=head1 NAME

RPG::DB::Result::Account - Database module for user accounts

=head1 DESCRIPTION

This module associates an account id with an email address. Other fields
will be added as required.

The account id provides a reference into the account_auths table which
holds data for various authentication methods such as local accounts or
remote authentication via openid/facebook/etc.

=cut

use base qw/DBIx::Class::Core/;

__PACKAGE__->table("accounts");
__PACKAGE__->add_columns(qw/account_id email/);
__PACKAGE__->set_primary_key('account_id');
__PACKAGE__->has_many(
    account_auths => 'RPG::DB::Result::AccountAuth',
    'account_id'
);

1;

=head1 AUTHOR

Simon Amor E<lt>simon@rpgwnn.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2011 Reanimated Projects and Games Ltd

