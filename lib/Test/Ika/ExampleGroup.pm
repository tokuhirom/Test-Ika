package Test::Ika::ExampleGroup;
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
        example_groups => [],
        examples => [],
        name => $name,
        parent => $args{parent},
        root => $args{root},
    }, $class;
}

sub add_example_group {
    my ($self, $context) = @_;
    push @{$self->{example_groups}}, $context;
}

sub add_example {
    my ($self, $it) = @_;
    push @{$self->{examples}}, $it;
}

sub add_trigger {
    my ($self, $trigger_name, $code) = @_;
    push @{$self->{triggers}->{$trigger_name}}, $code;
}

sub call_trigger {
    my ($self, $trigger_name) = @_;
    for my $trigger (@{$self->{triggers}->{$trigger_name}}) {
        $trigger->();
    }
}

sub call_before_each_trigger {
    my ($self) = @_;
    $self->{parent}->call_before_each_trigger() if $self->{parent};
    for my $trigger (@{$self->{triggers}->{'before_each'}}) {
        $trigger->();
    }
}

sub call_after_each_trigger {
    my ($self) = @_;
    for my $trigger (@{$self->{triggers}->{'after_each'}}) {
        $trigger->();
    }
    $self->{parent}->call_after_each_trigger() if $self->{parent};
}

sub run {
    my ($self) = @_;

    my $guard = $self->{root} ? undef : $Test::Ika::REPORTER->describe($self->{name});
    {
        $self->call_trigger('before_all');
        for my $stuff (@{$self->{examples}}) {
            $self->call_before_each_trigger();
            $stuff->run(); 
            $self->call_after_each_trigger();
        }
        for my $stuff (@{$self->{example_groups}}) {
            $stuff->run(); 
        }
        $self->call_trigger('after_all');
    }
}

1;

