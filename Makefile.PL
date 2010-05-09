use inc::Module::Install;

githubmeta;

name     'CPAN-MetaMuncher';
all_from 'lib/CPAN/MetaMuncher.pm';
author   'Chris Weyl <cweyl@alumni.drew.edu>';
license  'lgpl';

readme_from 'lib/CPAN/MetaMuncher.pm';
readme_markdown_from 'lib/CPAN/MetaMuncher.pm';

requires 'autodie';
requires 'namespace::autoclean';

# silent autodie dep
requires 'IPC::System::Simple';

# min version for native traits
requires 'Moose' => '0.90';
requires 'MooseX::Traits' => '0.09';
requires 'MooseX::Types';
requires 'MooseX::Types::Path::Class';
#requires 'MooseX::Types::URI';

requires 'CPAN::Easy';
requires 'File::Slurp';
requires 'Path::Class';
requires 'YAML::XS';

requires 'RPM::Spec'        => '0.04';
requires 'RPM::VersionSort' => '1.00';

# for when we're smarter
#requires 'JSON';
#recommends 'JSON::XS';

test_requires 'Test::More' => '0.92';

extra_tests;
auto_provides;
auto_install;
write_mymeta_json;

WriteAll;

