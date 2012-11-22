package Test::Ika::Example;
use strict;
use warnings;
use utf8;

use Carp ();
use Try::Tiny;
use Test::Builder;

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;

    my $name = delete $args{name} || Carp::croak "Missing name";
    my $code = delete $args{code}; # allow specification only
    my $skip = exists $args{skip} ? delete $args{skip} : (!$code ? 1 : 0); # xit
    my $tags = delete $args{tags};

    bless {
        name => $name,
        code => $code,
        skip => $skip,
        tags => $tags,
    }, $class;
}

sub run {
    my $self = shift;

    my $error;
    my $ok;
    my $output = "";

    if (defined $self->{tags} && defined $self->{code}) {
        my @keys = keys %{$self->{tags}};

        my $match = 0;
        for my $key (@keys) {
            next unless exists $ENV{$key};

            my $value = $self->{tags}->{$key};
            $match++ if (ref $value eq 'Regexp' ? ($ENV{$key} =~ $value) : ($ENV{$key} eq $value));
        }

        $self->{skip}++ if $match != @keys;
    };

    try {
        open my $fh, '>', \$output;
        $ok = do {
            no warnings 'redefine';
            my $builder = Test::Builder->create();
            local $Test::Builder::Test = $builder;
            $builder->no_header(1);
            $builder->no_ending(1);
            $builder->output($fh);
            $builder->failure_output($fh);
            $builder->todo_output($fh);

            if ($self->{skip}) {
                $builder->skip;
            }
            else {
                $self->{code}->();
            }

            $builder->finalize();
            $builder->is_passing();
        };
    } catch {
        $error = "$_";
    } finally {
        my $name = $self->{name};
        if ($self->{skip}) {
            $name .= $self->{code} ? ' [DISABLED]' : ' [NOT IMPLEMENTED]';
        }

        my $test = $self->{skip} ? -1 : !!$ok;

        $Test::Ika::REPORTER->it($name, $test, $output, $error);
    };
}

1;
