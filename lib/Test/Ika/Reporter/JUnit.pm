package Test::Ika::Reporter::JUnit;

use strict;
use warnings;
use utf8;

use XML::Simple;
use Scope::Guard;
use Time::HiRes qw(gettimeofday tv_interval);

use IO::Scalar;
use Term::ANSIColor;

sub new {
    my ($class, $args) = @_;

    return bless {
        buffer     => \my $buffer,
        time       => [ gettimeofday ],
        test_suite => {},
        describes  => [],
    }, $class;
}

sub output { IO::Scalar->new(shift->{buffer}) }

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

sub describe {
    my ($self, $name) = @_;

    push @{$self->{describes}}, $name;
    return Scope::Guard->new(sub {
        pop @{$self->{describes}};
    });
}

sub it {
    my ($self, $name, $test, $results, $exception) = @_;

    my $test_name = join " ", (@{$self->{describes}}[1..$#{$self->{describes}}], $name);

    my $time   = tv_interval($self->{time});
    $self->{time} = [ gettimeofday ];

    my @result;
    my $suite_name = @{$self->{describes}}[0];
    $self->{test_suite}->{$suite_name}->{failed} //= 0;
    if ($test > 0) {
        $exception = $self->fetch_output;
        @result = (success => {});
    } elsif ($test < 0) {
        @result = (skipped => {});
    } else {
        # not ok
        $self->{test_suite}->{$suite_name}->{failed} += 1;
        $exception = $self->fetch_output . ($exception || '');
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

    my %testsuites = ();
    while (my ($suite_name, $hash) = each(%{$self->{test_suite}})) {
        $testsuites{$suite_name} = {
            tests    => scalar(@{$hash->{cases}}),
            errors   => $hash->{failed},
            failures => $hash->{failed},
            testcase => $hash->{cases},
        };
    }
    my $args = {
        XMLDecl => "<?xml version='1.0' encoding='utf-8'?>",
        RootName => 'testsuites',
    };
    $args->{OutputFile} = $ENV{JUNIT_OUTPUT_FILE} if ($ENV{JUNIT_OUTPUT_FILE});

    my $xml = XMLout(
        { testsuite => \%testsuites },
        %$args,
    );
    print $xml if (!$ENV{JUNIT_OUTPUT_FILE});
}

1;
__END__

=head1 NAME

Test::Ika::Reporter::JUnit - Like TAP::Harness::JUnit but with case specific STDOUT as well as STDERR logs

=head1 SYNOPSIS

    Test::Ika->set_reporter('JUnit');

=head1 DESCRIPTION

This module creates XML with necessary info for failures

=head1 SEE ALSO

L<Test::Ika>
