use strict;
use warnings;
use utf8;
use Test::More;
use Test::Max::Reporter::Spec;
use Test::Max::Reporter::TAP;

my %spec = map { $_ => 1 } functions('Test::Max::Reporter::Spec');
for (functions('Test::Max::Reporter::TAP')) {
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
