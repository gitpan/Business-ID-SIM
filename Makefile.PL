
use strict;
use warnings;



use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Business::ID::SIM',
                       'DISTNAME' => 'Business-ID-SIM',
                       'AUTHOR' => 'Steven Haryanto <stevenharyanto@gmail.com>',
                       'ABSTRACT' => 'Validate Indonesian driving license number (nomor SIM)',
                       'EXE_FILES' => [],
                       'VERSION' => '0.02',
                       'LICENSE' => 'perl',
                       'PREREQ_PM' => {
                                        'DateTime' => '0',
                                        'Pod::Coverage' => '0.18',
                                        'Test::More' => '0',
                                        'Test::Pod::Coverage' => '1.08',
                                        'ExtUtils::MakeMaker' => '6.11'
                                      }
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



