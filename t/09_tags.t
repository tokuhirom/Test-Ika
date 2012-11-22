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

    $ENV{"TEST_IKA_TAG${_}"} = 1 for 1..6;

    describe 'foo' => sub {
        it 'foo' => { TEST_IKA_TAG1 => 1 } => sub {
            push @RESULT, 'test foo';
        };

        it 'bar' => { TEST_IKA_TAG2 => 'bar' } => sub {
            push @RESULT, 'test bar';
        };

        it 'baz' => { TEST_IKA_TAG3 => 1, TEST_IKA_TAG4 => 1 } => sub {
            push @RESULT, 'test baz';
        };

        it 'quux' => { TEST_IKA_TAG5 => 1, TEST_IKA_TAG6 => 'quux' } => sub {
            push @RESULT, 'test quux';
        };
    };

    runtests;
}
is(join("\n", @RESULT), join("\n", (
    'test foo',
    # skip test bar
    'test baz',
    # skip test quux
)));

done_testing;

