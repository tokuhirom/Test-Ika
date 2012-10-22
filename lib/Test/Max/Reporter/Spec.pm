package Test::Max::Reporter::Spec;
use strict;
use warnings;
use utf8;
use Scope::Guard ();
use Term::ANSIColor qw/colored/;
use Term::Encoding ();

sub new {
    my $class = shift;

    $|++;
    my $term_encoding = Term::Encoding::term_encoding();
    binmode *STDOUT, ":encoding($term_encoding)";
    binmode *STDERR, ":encoding($term_encoding)";

    print "\n";

    return bless {
        failed => 0,
        describe => []
    }, $class;
}

sub describe {
    my ($self, $name) = @_;
    push @{$self->{describe}}, $name;
    print(('  ' x @{$self->{describe}}) . "$name\n");
    return Scope::Guard->new(sub {
        pop @{$self->{describe}};
    });
}

sub exception {
    my ($self, $msg) = @_;
    print STDERR ('  ' x (@{$self->{describe}}+1)) . colored(['red', 'bold'], 'Exception: ') . colored(['red'], $msg);
}

sub it {
    my ($self, $name, $test, $results) = @_;

    print ('  ' x (@{$self->{describe}}+1));
    if ($test) {
        print( colored( ['green'], "\x{2713} " ) );
    }
    else {
        # not ok
        print( colored( ['red'], "\x{2716} " ) );
    }
    print( colored( ["BRIGHT_BLACK"], $name ) );
    if (!$test) {
        my $failed = ++$self->{failed};
        printf(" (FAILED - %d)", $failed);
        push @{$self->{results}}, $results;
    }
    print("\n");
}

sub finalize {
    my $self = shift;
    if ($self->{finalized}++) {
        die "Do not finalize twice.";
    } else {
        print "\n";

        for my $i (0..$self->{failed}-1) {
            printf "  %s)\n", $i+1;
            for my $row (@{$self->{results}->[$i]}) {
                if ($row->[0] eq 'ok') {
                    my $caller = $row->[3];
                    printf "    %s line %d\n", $caller->[1], $caller->[2];
                } elsif ($row->[0] eq 'diag' || $row->[0] eq 'note') {
                    my $msg = $row->[1];
                    my $indent = '    ';
                    $msg =~ s{\n(?!\z)}{\n$indent}sg;
                    printf "    %s\n", $msg;
                } else {
                    die; # Should not reach here
                }
            }
        }
    }
}

1;

