package RPG::Messages;

=head1 NAME

RPG::Messages - a generic message module

=head1 DESCRIPTION

This module converts standard message codes into English strings. If you
wish to translate the messages, create a .mo file within lib/LocaleData

The exact path will vary depending on the locale that you're translating
for. To change the English translation, you would use en, en_GB or 
en_GB.UTF-8 as the locale code.
For example, lib/LocaleData/en_GB.UTF-8/LC_MESSAGES/com.rpgwnn.mo

    # Locale message translation
    use Locale::Messages qw(LC_MESSAGES);
    use Locale::TextDomain ("com.rpgwnn");

    # This can be time-consuming so do it once only
    POSIX::setlocale(LC_MESSAGES, '');

=head1 METHODS

=cut

# Default messages - can't access them from outside this module, but can
# reference RPG::Messages->{ code2msg }

my %code2msg = (

    ACCOUNT_NX     => "Account does not exist",
    ACCOUNT_OK     => "Account registered successfully",

    CHARACTER_NX   => "Character does not exist",

    FORM_FIELDS    => "You need to fill all required fields",

    UNKNOWN        => "Unknown error occurred",
);

=head2 $obj = $class->new( )

Initialises the object and copies the code2msg hash into the object.

=cut

sub new {
    my $class = shift;
    my $self = { };

    # Stick (a copy of) the code2msg hash in the object
    $self->{ messages } = { %code2msg };

    bless $self, $class;
}

=head2 $str = $obj->message( $code_str )

This method takes a standard message code as defined in the code2msg hash
in this module, and converts it to human readable text.

=cut

sub message {
    my $self = shift;
    my $code = shift;

    return __"Unknown code" unless $code;

    if ($self->{ messages }{ $code }) {
        return __$self->{ messages }{ $code };
    }

    return __"Unknown code";
}

1;

