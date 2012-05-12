package RPG::Messages;

use Locale::Messages; # qw(:libintl_h); adding this causes warnings
use Locale::TextDomain ("com.rpgwnn");

=head1 NAME

RPG::Messages - a generic message module

=head1 DESCRIPTION

This module converts strings into alternative languages (if translation
files are available). To translate the messages, create a .mo file within
lib/LocaleData

The exact path will vary depending on the locale that you're translating
for. To change the English translation, you would use en, en_GB or 
en_GB.UTF-8 as the locale code.
For example, lib/LocaleData/en_GB.UTF-8/LC_MESSAGES/com.rpgwnn.mo

=head1 SYNOPSIS

    # Locale message translation
    use Locale::Messages qw(LC_MESSAGES);
    use Locale::TextDomain ("com.rpgwnn");

    # This can be time-consuming so do it once only
    POSIX::setlocale(LC_MESSAGES, '');

=head1 METHODS

=head2 $obj = $class->new( )

Initialises the object. Not really required as you can just call it
like this.

 RPG::Messages->message("...");

=cut

sub new {
    my $class = shift;
    my $self = { };

    bless $self, $class;
}

=head2 $str = $obj->message( $code_str )

This method takes a message and converts it to another language if
the translation file is provided.

=cut

sub message {
    my $self = shift;
    my $msg = shift;

    return __"Unknown error" unless $msg;
    return __$msg;
}

1;
