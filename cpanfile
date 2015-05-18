requires 'perl', '5.010001';

requires 'Exporter';
requires 'Module::Load';
requires 'parent';
requires 'Scope::Guard';
requires 'Term::ANSIColor';
requires 'Term::Encoding';
requires 'Test::Builder';
requires 'Test::Builder::Module';
requires 'Test::More', '0.98';
requires 'Test::Name::FromLine', '0.06';
requires 'Try::Tiny';
requires 'IO::Scalar';
requires 'Time::HiRes';
requires 'XML::Simple';

on test => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Requires';
};
