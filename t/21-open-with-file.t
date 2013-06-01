use Test::More;

use Text::FrontMatter::YAML;

my $file = 't/data/basic';

my $tfm = Text::FrontMatter::YAML->new(
    path => $file,
);

my $YAML_TEXT = <<'END_YAML';
layout: frontpage
title: My New Site
END_YAML

my $yaml = $tfm->frontmatter_text;
is($yaml, $YAML_TEXT, "frontmatter_text returned correct text for $file");


my $DATA_TEXT = <<'END_DATA';
This is just some random text. Nothing to see here. Move along.

---
Ha!
...
END_DATA

my $data = $tfm->data_text;
is($data, $DATA_TEXT, "data_text returned correct text for $file");

done_testing();
1;
