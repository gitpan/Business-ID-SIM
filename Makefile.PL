use inc::Module::Install;

name     'Business-ID-SIM';
all_from 'lib/Business/ID/SIM.pm';
author   q{Steven Haryanto <stevenharyanto@gmail.com>};
license  'perl';

build_requires 'Test::More';
requires 'DateTime';

auto_install;

WriteAll;

