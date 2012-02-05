package RPG::Auth::Local;

=head1 NAME

RPG::Auth::Local - Local authentication module

=head1 DESCRIPTION

This module provides basic authentication via local
username/password which are stored in a database
table.

=head2 new()

Requires no parameters and returns a basic object

=cut

sub new {
    my $class = shift;
    my $self = {
        auth => "local",
    };
    bless $self, $class;
    return $self;
}

1;

