# NAME

Test::Ika - Yet another BDD testing library(Development Release)

# SYNOPSIS

    use Test::Ika;
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

# DESCRIPTION

Test::Ika is yet another BDD framework for Perl5.

This module provides pretty output for testing.

__THIS IS A DEVELOPMENT RELEASE. API MAY CHANGE WITHOUT NOTICE__.

# FAQ

- Ika?

    This module is dedicated to ikasam\_a, a famous Japanese testing engineer.

- Why another one?

    This module focused to pretty output. Another modules doesn't provide this feature.

- Where is 'should'?

    I think the keyword 'should' is not a core feature of BDD.

# Reporters

Test::Ika provides some reporters.

- The spec mode(default)

    <div><img src="https://raw.github.com/tokuhirom/Test-Ika/master/img/spec.png"></div>

    <div><img src="https://raw.github.com/tokuhirom/Test-Ika/master/img/spec2.png"></div>

- TAP output(it's enabled under $ENV{HARNESS\_ACTIVE} is true)

    <img src="https://raw.github.com/tokuhirom/Test-Ika/master/img/tap.png">

# FUNCTIONS

- `describe($name, $code)`

    Create new [Test::Ika::ExampleGroup](http://search.cpan.org/perldoc?Test::Ika::ExampleGroup).

- context

    It's alias of 'describe' function.

- `it($name, \&code)`

    Create new [Test::Ika::Example](http://search.cpan.org/perldoc?Test::Ika::Example).

- `it($name, $cond, \&code)`

    Create new conditional [Test::Ika::Example](http://search.cpan.org/perldoc?Test::Ika::Example).

    `$cond` is usually a sub-routine reference.
    You can set it with "when" statement.

        # run this example, if C<$ENV{TEST_MESSAGE}> returns true

        my $cond = sub { $ENV{TEST_MESSAGE} };

        it 'should detect message', $cond => sub {
            my $filter = MessageFilter->new('foo');
            expect($filter->detect('hello foo'))->ok;
        };

- `when(\&code)`

    Specify conditional sub-routine.

    You can write conditional example as shown below:

        it 'should detect message', when { $ENV{TEST_MESSAGE} } => sub {
            my $filter = MessageFilter->new('foo');
            expect($filter->detect('hello foo'))->ok;
        };

- `xit($name, \&code)`
- `xit($name, $cond, \&code)`

    Create new [Test::Ika::Example](http://search.cpan.org/perldoc?Test::Ika::Example) which marked "disabled".

- `before_suite(\&code)`

    Register hook.

- `before_all(\&code)`

    Register hook.

- `before_each(\&code)`

    Register hook.

- `after_suite(\&code)`

    Register hook.

- `after_all(\&code)`

    Register hook.

- `after_each(\&code)`

    Register hook.

- `runtests()`

    Do run test cases immediately.

    Normally, you don't call this method expressly. Test::Ika runs test cases on END { } phase.

# CLASS METHODS

- `Test::Ika->reporter()`

    Get a reporter instance.

- `Test::Ika->set_reporter($module)`

    Load a reporter class.

# AUTHOR

Tokuhiro Matsuno <tokuhirom AAJKLFJEF@ GMAIL COM>

# SEE ALSO

[Test::Spec](http://search.cpan.org/perldoc?Test::Spec)

[Test::Behavior::Spec](http://search.cpan.org/perldoc?Test::Behavior::Spec)

[Test::More::Behaviours](http://search.cpan.org/perldoc?Test::More::Behaviours)

# LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
