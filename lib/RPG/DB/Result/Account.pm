package RPG::DB::Result::Account;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table("accounts");
__PACKAGE__->add_columns(qw/account_id email/);
__PACKAGE__->set_primary_key('account_id');
__PACKAGE__->has_many(
    account_auths => 'RPG::DB::Result::AccountAuth',
    'account_id'
);

1;
