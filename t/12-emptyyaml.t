use Test::More;

use Text::FrontMatter::YAML;

my $file = 't/data/emptyyaml';

open my $fh, '<', $file or die "can't open $file";
my $tfm = Text::FrontMatter::YAML->new(
    fh => $fh,
);

my $YAML_TEXT = "---\n";

my $yaml = $tfm->get_frontmatter_text;
is($yaml, $YAML_TEXT, 'empty frontmatter returned for file with no yaml');


my $DATA_TEXT = <<'END_DATA';
This is just some random text. Nothing to see here. Move along.

---
Ha!
...
END_DATA

my $data = $tfm->get_data_text;
is($data, $DATA_TEXT, 'data text returned for file with no yaml');

done_testing();
1;