use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    license              => 'perl',
    dynamic_config       => 0,

    build_requires       => {
        'Test::More' => '0.98',
        'Test::Requires' => 0,
    },
    configure_requires   => { 'Module::Build' => '0.38' },
    requires             => {
        perl => '5.010001',
        'Exporter'                      => '0',
        'Test::More'                    => '0.98',
        'parent'                        => '0',
        'Term::Encoding' => 0,
        'Module::Load' => 0,
        'Scope::Guard' => 0,
        'Try::Tiny' => 0,
        'Test::Name::FromLine' => 0.06,
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'Test-Ika',
    module_name => 'Test::Ika',

    # script_files => [''],

    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,
   
    create_readme  => 1,
    create_license => 1,
);
$build->create_build_script();
