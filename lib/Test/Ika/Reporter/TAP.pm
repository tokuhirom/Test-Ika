package Test::Ika::Reporter::TAP;
use strict;
use warnings;
use utf8;
use Test::More ();
use Scope::Guard ();

sub new {
    my $class = shift;
    return bless {describe => []}, $class;
}

sub describe {
    my ($self, $name) = @_;

    push @{$self->{describe}}, $name;
    return Scope::Guard->new(sub {
        pop @{$self->{describe}};
    });
}

sub exception {
    my ($self, $name) = @_;
    $name =~ s/\n\Z//;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = Test::More->builder;
    $builder->ok(0, "Error: $name");
}

sub it {
    my ($self, $name, $test) = @_;

    my $builder = Test::More->builder;
    $builder->ok($test, '(' . join("/", @{$self->{describe}}) . ') ' . $name);
}

sub finalize {
    my $self = shift;
    if ($self->{finalized}++) {
        Carp::croak("Do not finalize twice.");
    } else {
        my $builder = Test::More->builder;
        $builder->done_testing;
    }
}

1;
__END__

=head1 NAME

Test::Ika::Reporter::TAP - TAP

=head1 DESCRIPTION

This reporter displays a testing result as TAP(Test Anything Protocol).

