package Test::Max;
use strict;
use warnings;
use 5.010001;
our $VERSION = '0.01';

use Try::Tiny;
use Module::Load;
use Test::Name::FromLine;

use parent qw/Exporter/;

our @EXPORT = (qw(describe it before_each runtests));

our @BLOCKS;
our $EXECUTING;
our %HOOKS;

our $REPORTER = do {
    my $module = $ENV{TEST_MAX_REPORTER};
    unless ($module) {
        $module = $ENV{HARNESS_ACTIVE} || $^O eq 'MSWin32' ? 'TAP' : 'Spec';
    }
    $module = $module =~ s/^\+// ? $module : "Test::Max::Reporter::$module";
    Module::Load::load($module);
    $module->new();
};

sub describe {
    my ($name, $code) = @_;

    if ($EXECUTING) {
        _run_describe($name, $code);
    } else {
        push @BLOCKS, [$name, $code];
    }
}

sub _run_describe {
    my ($name, $code) = @_;

    my $guard = $REPORTER->describe($name);
    try {
        local %Test::Max::HOOKS;
        $code->();
    } catch {
        $REPORTER->exception($_);
    };
}

sub it {
    my ($name, $code) = @_;

    $_->() for @{$Test::Max::HOOKS{before_each} || []};

    try {
        open my $fh, '>', \my $output;
        my $ok = do {
            no warnings 'redefine';
            my $builder = Test::Builder->create();
            local $Test::Builder::Test = $builder;
            $builder->no_header(1);
            $builder->no_ending(1);
            $builder->output($fh);
            $builder->failure_output($fh);
            $builder->todo_output($fh);

                $code->();

            $builder->finalize();
            $builder->is_passing();
        };
        $REPORTER->it($name, !!$ok, $output);
    } catch {
        $REPORTER->exception($_);
    };
}

sub before_each(&) {
    my $code = shift;
    push @{$Test::Max::HOOKS{before_each}}, $code;
}

sub runtests {
    local $EXECUTING = 1;
    for my $block (@BLOCKS) {
        my ($name, $code) = @$block;
        _run_describe($name, $code);
    }
    $REPORTER->finalize();
}

END {
    if (@BLOCKS) {
        runtests();
    }
}

1;
__END__

=encoding utf8

=head1 NAME

Test::Max - B!D!D! B!D!D!

=head1 SYNOPSIS

    use Test::Max;
    use Test::Expects;

    describe 'MessageFilter' => sub {
        my $filter;

        before_each {
            $filter = MessageFilter->new();
        };

        it 'should detect message with NG word' => sub {
            my $filter = MessageFilter->new('foo');
            expect($filter->detect('hello foo'))->ok;
        };
        it 'should detect message with NG word' => sub {
            my $filter = MessageFilter->new('foo');
            expect($filter->detect('hello foo'))->ok;
        };
    };

    runtests;

=head1 DESCRIPTION

Test::Max is yet another BDD framework for Perl5.

This module provides pretty output for testing.

=over 4

=item The spec mode(default)

=begin html

<div><img src="https://raw.github.com/tokuhirom/Test-Max/master/img/spec.png"></div>

<div><img src="https://raw.github.com/tokuhirom/Test-Max/master/img/spec2.png"></div>

=end html

=item TAP output(it's enabled under $ENV{HARNESS_ACTIVE} is true)

=begin html

<img src="https://raw.github.com/tokuhirom/Test-Max/master/img/tap.png">

=end html

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
