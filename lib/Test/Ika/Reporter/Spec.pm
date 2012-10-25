package Test::Ika::Reporter::Spec;
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
        describe => [],
        results => [],
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
            my $indent = ' ' x 4;
            for my $msg ($self->{results}->[$i]) {
                $msg =~ s{\n(?!\z)}{\n$indent}sg;
                print $indent . $msg;
            }
        }
    }
}

1;
__END__

=head1 NAME

Test::Ika::Reporter::Spec - Reporter like RSpec

=head1 DESCRIPTION

This module displays pretty output like RSpec.

