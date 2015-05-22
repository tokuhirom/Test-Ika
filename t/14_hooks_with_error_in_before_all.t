use strict;
use warnings;
use utf8;
use Test::More tests => 1;
use Test::Ika;
use Carp qw(croak);

Test::Ika->set_reporters('Test');
my @RESULT;
{
    package sandbox;
    use Test::Ika;
    use Test::More;

    describe 'outer' => sub {
        before_all {
            push @RESULT, 'OUTER BEFORE';
        };
        after_all {
            push @RESULT, 'OUTER AFTER';
        };
        before_each {
            push @RESULT, 'OUTER BEFORE_EACH';
        };
        after_each {
            push @RESULT, 'OUTER AFTER_EACH';
        };
        it u => sub {
            push @RESULT, 'test u';
        };
        it v => sub {
            push @RESULT, 'test v';
        };
        describe 'middle' => sub {
            before_all {
                push @RESULT,  'MIDDLE BEFORE_ALL';
                die "error";
            };
            after_all {
                push @RESULT,  'MIDDLE AFTER_ALL';
            };
            before_each {
                push @RESULT, 'MIDDLE BEFORE_EACH';
            };
            after_each {
                push @RESULT, 'MIDDLE AFTER_EACH';
            };
            it w => sub {
                push @RESULT, 'test w';
            };
            it x => sub {
                push @RESULT, 'test x';
            };
            describe 'inner' => sub {
                before_all {
                    push @RESULT,  'INNER BEFORE_ALL';
                };
                after_all {
                    push @RESULT,  'INNER AFTER_ALL';
                };
                before_each {
                    push @RESULT, 'INNER BEFORE_EACH';
                };
                after_each {
                    push @RESULT, 'INNER AFTER_EACH';
                };
                it y => sub {
                    push @RESULT, 'test y';
                };
                it z => sub {
                    push @RESULT, 'test z';
                };
            };
        };
    };
    runtests;
}
is(join("\n", @RESULT), join("\n", (
    'OUTER BEFORE',
        'OUTER BEFORE_EACH',
            'test u',
        'OUTER AFTER_EACH',
        'OUTER BEFORE_EACH',
            'test v',
        'OUTER AFTER_EACH',

        'MIDDLE BEFORE_ALL',
    'OUTER AFTER',
)));
