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
    my $code = delete $args{code} || Carp::croak "Missing code";
    bless {
        name => $name,
        code => $code,
    }, $class;
}

sub run {
    my $self = shift;

    my $error;
    my $ok;
    my $output = "";
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

                $self->{code}->();

            $builder->finalize();
            $builder->is_passing();
        };
    } catch {
        $error = "$_";
    } finally {
        $Test::Ika::REPORTER->it($self->{name}, !!$ok, $output, $error);
    };
}

1;
