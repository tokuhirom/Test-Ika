package Test::Ika::Context;
use strict;
use warnings;
use utf8;
use Carp ();

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    my $name = delete $args{name} || Carp::croak "Missing name";
    bless {
        triggers => {
            before_all => [],
            before_each => [],
            after_all => [],
            after_each => [],
        },
        contexts => [],
        its => [],
        name => $name,
        parent => $args{parent},
    }, $class;
}

sub push_context {
    my ($self, $context) = @_;
    push @{$self->{contexts}}, $context;
}

sub push_it {
    my ($self, $it) = @_;
    push @{$self->{its}}, $it;
}

sub add_trigger {
    my ($self, $trigger_name, $code) = @_;
    push @{$self->{triggers}->{$trigger_name}}, $code;
}

sub call_trigger {
    my ($self, $trigger_name) = @_;
    $_->() for @{$self->{triggers}->{$trigger_name}};
}

sub call_before_each_trigger {
    my ($self) = @_;
    $self->{parent}->call_before_each_trigger() if $self->{parent};
    $_->() for @{$self->{triggers}->{'before_each'}};
}

sub call_after_each_trigger {
    my ($self) = @_;
    $_->() for @{$self->{triggers}->{'after_each'}};
    $self->{parent}->call_after_each_trigger() if $self->{parent};
}

sub run {
    my ($self) = @_;
    $self->call_trigger('before_all');
    for my $stuff (@{$self->{its}}) {
        $self->call_before_each_trigger();
        $stuff->run(); 
        $self->call_after_each_trigger();
    }
    for my $stuff (@{$self->{contexts}}) {
        $stuff->run(); 
    }
    $self->call_trigger('after_all');
}

1;

