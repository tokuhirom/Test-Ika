use strict;
use warnings;
use utf8;
use Test::More;
use Test::Ika;
use Test::Ika::Reporter::Test;

my $reporter = Test::Ika::Reporter::Test->new();
local $Test::Ika::REPORTER = $reporter;
my @RESULT;
{
    package sandbox;
    use Test::Ika;
    use Test::More;

    describe 'foo' => sub {
        before_each {
            push @RESULT, 'OUTER BEFORE';
        };
        after_each {
            push @RESULT, 'OUTER AFTER';
        };
        it p => sub {
            push @RESULT, 'test p';
        };
        describe 'x' => sub {
            before_each {
                push @RESULT, 'BEFORE INNER';
            };
            after_each {
                push @RESULT, 'AFTER INNER';
            };
            it y => sub {
                push @RESULT, 'test y';
            };
            it z => sub {
                push @RESULT, 'test z';
            };
        };
    };
    runtests;
}
is(join("\n", @RESULT), join("\n", (
    'OUTER BEFORE',
        'test p',
    'OUTER AFTER',

    'OUTER BEFORE',
        'BEFORE INNER',
            'test y',
        'AFTER INNER',

        'BEFORE INNER',
            'test z',
        'AFTER INNER',
    'OUTER AFTER',
)));

done_testing;

