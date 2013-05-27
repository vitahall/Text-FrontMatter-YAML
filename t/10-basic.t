use Test::More;

use Text::FrontMatter::YAML;

my $file = 't/data/basic';

open my $fh, '<', $file or die "can't open $file";
my $tfm = Text::FrontMatter::YAML->new(
    fh => $fh,
);

ok(ref($tfm), 'new returned an object');

my $YAML_TEXT = <<'END_YAML';
---
layout: frontpage
title: My New Site
END_YAML

my $yaml = $tfm->frontmatter_text;
ok($yaml, 'frontmatter_text returned text');
is($yaml, $YAML_TEXT, "frontmatter_text returned correct text for filehandle");


my $DATA_TEXT = <<'END_DATA';
This is just some random text. Nothing to see here. Move along.

---
Ha!
...
END_DATA

my $data = $tfm->data_text;
ok($data, 'data_text returned text');
is($data, $DATA_TEXT, "data_text returned correct text for filehandle");

done_testing();
1;
