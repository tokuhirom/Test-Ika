# NAME

Test::Ika - Yet another BDD testing library(Development Release)

# SYNOPSIS

    use Test::Ika;

    describe 'MessageFilter' => sub {
        my $filter;

        before_each {
            $filter = MessageFilter->new();
        };

        it 'should detect message with profanity word' => sub {
            ok $filter->detect('foo');
        };

        it 'should not detect message without profanity word' => sub {
            ok ! $filter->detect('bar');
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

    <div>
            <div><img src="https://raw.github.com/tokuhirom/Test-Ika/master/img/spec.png"></div>

            <div><img src="https://raw.github.com/tokuhirom/Test-Ika/master/img/spec2.png"></div>
    </div>

- TAP output(it's enabled under $ENV{HARNESS\_ACTIVE} is true)

    <div>
            <img src="https://raw.github.com/tokuhirom/Test-Ika/master/img/tap.png">
    </div>

- The JUnit mode creates XML containing metadata logs for the tests run, sans the console output

    ```xml
    <?xml version='1.0' encoding='utf-8'?>
    <testsuites>
        <testsuite name="Array" errors="2" failures="2" tests="3">
            <testcase name="#push can push to array" time="0.003349">
                <success></success>
                <system-err></system-err>
                <system-out>ok 1 - L31: is($a-&gt;size, 1);
    </system-out>
            </testcase>
            <testcase name="#push put pushed element to tail" time="0.000649">
                <failure></failure>
                <system-err></system-err>
                <system-out>not ok 1 - L37: is($a-&gt;at(0), 1);
    #   Failed test 'L37: is($a-&gt;at(0), 1);'
    #   at eg/oops.t line 37.
    #          got: '2'
    #     expected: '1'
    </system-out>
            </testcase>
            <testcase name="#map can apply the function to array" time="0.000724">
                <failure></failure>
                <system-err></system-err>
                <system-out>not ok 1 - L45: is_deeply([$a-&gt;map(sub { $_ * 2 })], [2,4]);
    #   Failed test 'L45: is_deeply([$a-&gt;map(sub { $_ * 2 })], [2,4]);'
    #   at eg/oops.t line 45.
    #     Structures begin differing at:
    #          $got-&gt;[0] = '4'
    #     $expected-&gt;[0] = '2'
    </system-out>
            </testcase>
        </testsuite>
    </testsuites>
    ```

# FUNCTIONS

- `describe($name, $code)`

    Create new [Test::Ika::ExampleGroup](https://metacpan.org/pod/Test::Ika::ExampleGroup).

- context

    It's alias of 'describe' function.

- `it($name, \&code)`

    Create new [Test::Ika::Example](https://metacpan.org/pod/Test::Ika::Example).

- `it($name, $cond, \&code)`

    Create new conditional [Test::Ika::Example](https://metacpan.org/pod/Test::Ika::Example).

    `$cond` is usually a sub-routine reference.
    You can set it with "when" statement.

        # run this example, if C<$ENV{TEST_MESSAGE}> returns true

        my $cond = sub { $ENV{TEST_MESSAGE} };

        it 'should detect message', $cond => sub {
            my $filter = MessageFilter->new('foo');
            ok $filter->detect('hello foo');
        };

- `when(\&code)`

    Specify conditional sub-routine.

    You can write conditional example as shown below:

        it 'should detect message', when { $ENV{TEST_MESSAGE} } => sub {
            my $filter = MessageFilter->new('foo');
            ok $filter->detect('hello foo');
        };

- `xit($name, \&code)`
- `xit($name, $cond, \&code)`

    Create new [Test::Ika::Example](https://metacpan.org/pod/Test::Ika::Example) which marked "disabled".

- `before_suite(\&code)`

    Register hook for before running suite.

- `before_all(\&code)`

    Register hook for before running example group.

- `before_each(\&code)`

    Register hook for before running each examples.

    This block can receive example and example group.

        before_each {
            my ($example, $group) = @_;
            # ...
        };

- `after_suite(\&code)`

    Register hook for after running suite.

- `after_all(\&code)`

    Register hook for after running example group.

- `after_each(\&code)`

    Register hook for after running each examples.

    This block can receive example and example group.

        after_each {
            my ($example, $group) = @_;
            # ...
        };

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

[Test::Spec](https://metacpan.org/pod/Test::Spec)

[Test::Behavior::Spec](https://metacpan.org/pod/Test::Behavior::Spec)

[Test::More::Behaviours](https://metacpan.org/pod/Test::More::Behaviours)

# LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
