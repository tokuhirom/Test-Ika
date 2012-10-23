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
        before {
            push @RESULT, 'OUTER BEFORE';
        };
        before_each {
            push @RESULT, 'OUTER BEFORE_EACH';
        };
        after_each {
            push @RESULT, 'OUTER AFTER_EACH';
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
    'OUTER BEFORE_EACH',
        'test p',
    'OUTER AFTER_EACH',

    'OUTER BEFORE_EACH',
        'BEFORE INNER',
            'test y',
        'AFTER INNER',

        'BEFORE INNER',
            'test z',
        'AFTER INNER',
    'OUTER AFTER_EACH',
)));

done_testing;

