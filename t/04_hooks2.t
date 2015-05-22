use strict;
use warnings;
use utf8;
use Test::More;
use Test::Ika;

Test::Ika->set_reporters('Test');
my @RESULT;
{
    package sandbox;
    use Test::Ika;
    use Test::More;

    describe 'foo' => sub {
        it p => sub {
            push @RESULT, 'test p';
        };
        it q => sub {
            push @RESULT, 'test q';
        };

        before_all {
            push @RESULT, 'BEFORE_ALL';
        };
        before_each {
            push @RESULT, 'BEFORE_EACH';
        };
        after_each {
            push @RESULT, 'AFTER_EACH';
        };
        after_all {
            push @RESULT, 'AFTER_ALL';
        };
    };
    runtests;
}
is(join("\n", @RESULT), join("\n", (
    'BEFORE_ALL',
        'BEFORE_EACH',
            'test p',
        'AFTER_EACH',
        'BEFORE_EACH',
            'test q',
        'AFTER_EACH',
    'AFTER_ALL',
)));

done_testing;

