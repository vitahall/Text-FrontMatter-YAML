use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::FrontMatter::YAML',
    AUTHOR              => 'Aaron Hall <ahall@vitaphone.net>',
    VERSION_FROM        => 'lib/Text/FrontMatter/YAML.pm',
    ABSTRACT_FROM       => 'lib/Text/FrontMatter/YAML.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'YAML::XS' => 0,
        'Carp'     => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Text-FrontMatter-YAML-*' },
);
