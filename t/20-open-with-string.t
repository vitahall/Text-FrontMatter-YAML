use Test::More;

use Text::FrontMatter::YAML;

my $YAML_TEXT = <<'END_YAML';
---
layout: frontpage
title: My New Site
this_reminds_me_of: resource forks
---
END_YAML

my $DATA_TEXT = <<'END_DATA';
Now, man, here's the actual data.
END_DATA

my $DOC_TEXT = $YAML_TEXT . $DATA_TEXT;

my $tfm = Text::FrontMatter::YAML->new(
    string => $DOC_TEXT,
);

# the returned YAML will be missing the '---' at the end
my $RETURNED_YAML = $YAML_TEXT;
$RETURNED_YAML =~ s/---\n\Z//;

my $yaml = $tfm->frontmatter_text;
is($yaml, $RETURNED_YAML, "frontmatter_text returned correct text for string");

my $data = $tfm->data_text;
is($data, $DATA_TEXT, "data_text returned correct text for string");

done_testing();
1;
