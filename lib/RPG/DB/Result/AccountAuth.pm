package RPG::DB::Result::AccountAuth;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('account_auths');
__PACKAGE__->add_columns(qw/account_auth_id account_id auth_type auth_data/);
__PACKAGE__->set_primary_key('account_auth_id');
__PACKAGE__->belongs_to(
    account => 'RPG::DB::Result::Account',
    'account_id'
);

1;
