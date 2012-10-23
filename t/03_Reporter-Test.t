use strict;
use warnings;
use utf8;
use Test::More;
use Test::Ika;
use Test::Ika::Reporter::Test;

my $reporter = Test::Ika::Reporter::Test->new();
$Test::Ika::REPORTER = $reporter;
{
    use Test::Ika;
    use Test::More;

    describe 'foo' => sub {
        context bar => sub {
            it 'baz' => sub {
                ok 1, 'yo';
            };
            it 'boz' => sub {
                ok 0, 'ho';
            };
            it 'biz' => sub {
                die "Woot";
            };
        };
    };
    runtests;
}
is(0+@{$reporter->report}, 3);
is($reporter->report->[0]->[0], 'it');
is($reporter->report->[1]->[0], 'it');
is($reporter->report->[2]->[0], 'exception');

use Data::Dumper;
note(Dumper($reporter->report));

done_testing;

