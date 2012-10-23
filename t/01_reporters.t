use strict;
use warnings;
use utf8;
use Test::More;
use Test::Ika::Reporter::Spec;
use Test::Ika::Reporter::TAP;

my %spec = map { $_ => 1 } functions('Test::Ika::Reporter::Spec');
for (functions('Test::Ika::Reporter::TAP')) {
    ok delete $spec{$_}, $_;
}
is(join('', keys %spec), '');

done_testing;

sub filter {
    grep !/^import$/, grep /^[a-z]/, @_;
}
sub functions {
    my $klass = shift;
    no strict 'refs';
    sort grep { $_ ne 'colored' } grep { defined &{"${klass}::$_"} } keys %{"${klass}::"};
}
