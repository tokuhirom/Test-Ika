package Test::Ika::Reporter::JUnit;

use strict;
use warnings;
use utf8;

use Test::Ika::Reporter::Spec;

use XML::Simple;
use Time::HiRes qw(gettimeofday tv_interval);

sub new {
    my ($class, $args) = @_;

    return bless {
        tee        => Test::Ika::Reporter::Spec->new($args),
        builder    => Test::Ika::Reporter::JUnit::IO->new,
        time       => [ gettimeofday ],
        test_suite => {},
        describes  => [],
    }, $class;
}

sub builder { shift->{builder} }

sub describe {
    my ($self, $name) = @_;

    push @{$self->{describes}}, $name;
    print(('  ' x @{$self->{describes}}) . "$name\n"); # as Test::Ika::Reporter::Spec;
    return Scope::Guard->new(sub {
        pop @{$self->{describes}};
    });
}

sub it {
    my ($self, $name, $test, $results, $exception) = @_;

    print ('  ' x (@{$self->{describes}}+1)); # as Test::Ika::Reporeter::Spec;
    $self->{tee}->it($name, $test, $results, $exception);

    my $test_name = join " ", (@{$self->{describes}}[1..$#{$self->{describes}}], $name);

    my $time   = tv_interval($self->{time});
    $self->{time} = [ gettimeofday ];

    my @result;
    my $suite_name = @{$self->{describes}}[0];
    $self->{test_suite}->{$suite_name}->{failed} //= 0;
    if ($test > 0) {
        $exception = $self->builder->fetch_output;
        print $exception;
        @result = (success => {});
    } elsif ($test < 0) {
        @result = (skipped => {});
    } else {
        # not ok
        $self->{test_suite}->{$suite_name}->{failed} += 1;
        $exception = $self->builder->fetch_output . ($exception || '');
        print $exception;
        @result = (failure => {});
    }

    push @{$self->{test_suite}->{$suite_name}->{cases}}, +{
        name => $test_name,
        time => $time,
        'system-out' => { content => $results },
        'system-err' => { content => $exception },
        @result,
    };
}

sub finalize {
    my $self = shift;
    $self->{tee}->finalize;

    my %testsuites = ();
    while (my ($suite_name, $hash) = each(%{$self->{test_suite}})) {
        $testsuites{$suite_name} = {
            tests    => scalar(@{$hash->{cases}}),
            errors   => $hash->{failed},
            failures => $hash->{failed},
            testcase => $hash->{cases},
        };
    }
    XMLout(
        { testsuite => \%testsuites },
        XMLDecl => "<?xml version='1.0' encoding='utf-8'?>",
        RootName => 'testsuites',
        OutputFile => $ENV{JUNIT_OUTPUT_FILE} // "junitoutput.xml",
    );
}

1;

package Test::Ika::Reporter::JUnit::IO;

use IO::Scalar;
use Term::ANSIColor;

sub new {
    my $class = shift;

    return bless {
        buffer => \my $buffer,
    }, $class;
}

sub output {
    return IO::Scalar->new(shift->{buffer});
}

sub failure_output {
    return IO::Scalar->new(shift->{buffer});
}

sub fetch_output {
    my $self = shift;

    my $tmp = '';
    if (defined $self->{buffer}) {
        $tmp = ${$self->{buffer}} || '';
        $tmp = Term::ANSIColor::colorstrip($tmp);

        $self->{buffer} = \my $buffer;
    }

    return $tmp;
}

1;
__END__

=head1 NAME

Test::Ika::Reporter::JUnit - Reporter like RSpec but also spits out XML

=head1 SYNOPSIS

    Test::Ika->set_reporter('JUnit');

=head1 DESCRIPTION

This module displays pretty output like RSpec, while also creating XML with necessary info for failures.

=head1 SEE ALSO

L<Test::Ika>
