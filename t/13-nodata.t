use Test::More;

use Text::FrontMatter::YAML;

my $file = 't/data/nodata';

open my $fh, '<', $file or die "can't open $file";
my $tfm = Text::FrontMatter::YAML->new(
    fh => $fh,
);

my $YAML_TEXT = <<'END_YAML';
---
title: A document
author: Aaron Hall
organization: None
END_YAML

my $yaml = $tfm->frontmatter_text;
is($yaml, $YAML_TEXT, 'yaml returned for file with no data section');


my $DATA_TEXT = undef;

my $data = $tfm->data_text;
is($data, $DATA_TEXT, 'undef data returned for file with no data section');

done_testing();
1;
