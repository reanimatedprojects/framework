package RPG::DB::ResultSet::Map;

use base qw/DBIx::Class::ResultSet RPG::Base/;

use strict;
use warnings;

=head2 $blocks = fetch_map_area( $min_x, $max_x, $min_y, $max_y, $z, $world )

Takes the range of x,y co-ords to define a rectangular area and
returns an arrayref [ [ row1cell1, r2c1, r3c1 ], [ r1c2, r2c2, r3c2 ] ]

Returns an array of x columns

Where there are no entries in the database for some/all of the cells,
undefined values will be returned.

=cut

sub fetch_map_area {
    my $self = shift;

    my $args = ref $_[0] eq 'HASH' ? shift : { @_ };

    my @unsorted_results = $self->search({
        x => {
            -between => [ $args->{ min_x }, $args->{ max_x } ],
        },
        y => {
            -between => [ $args->{ min_y }, $args->{ max_y } ],
        },
        z       => $args->{ z },
        world   => $args->{ world },
    });

    # FIXME: Create array based on x,y values

    my @results_array = ();

    # Fill the array with the right number of undefined elements
    for (my $x = $args->{ min_x }; $x <= $args->{ max_x }; $x ++ ) {
        for (my $y = $args->{ min_y }; $y <= $args->{ max_y }; $y ++ ) {
            $results_array[$x - $args->{ min_x } ][ $y - $args->{ min_y } ] = undef;
        }
    }

    # Fill in the array with the things that we have in the results
    foreach my $result (@unsorted_results) {
        my $x = $result->x - $args->{ min_x };
        my $y = $result->y - $args->{ min_y };
        $results_array[ $x ][ $y ] = $result;
    }

    return \@results_array;
}

1;
