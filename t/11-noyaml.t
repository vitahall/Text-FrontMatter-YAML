use Test::More;

use Text::FrontMatter::YAML;

my $file = 't/data/noyaml';

open my $fh, '<', $file or die "can't open $file";
my $tfm = Text::FrontMatter::YAML->new(
    fh => $fh,
);

my $YAML_TEXT = undef;

my $yaml = $tfm->frontmatter_text;
is($yaml, $YAML_TEXT, 'undef frontmatter returned for file with no yaml');


my $DATA_TEXT = <<'END_DATA';
This is just some random text. Nothing to see here. Move along.

---
Ha!
...
END_DATA

my $data = $tfm->data_text;
is($data, $DATA_TEXT, 'data text returned for file with no yaml');

done_testing();
1;
