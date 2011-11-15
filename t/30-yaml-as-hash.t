use Test::More;

use Text::FrontMatter::YAML;

my $file = 't/data/basic';

my $tfm = Text::FrontMatter::YAML->new(
    path => $file,
);

my $expected_yaml = {
    layout => 'frontpage',
    title  => 'My New Site',
};

my $gotyaml = $tfm->get_frontmatter_hash;
is_deeply($gotyaml, $expected_yaml,
    "get_frontmatter_hash returned correct hash");

done_testing();
