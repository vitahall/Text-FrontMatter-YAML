use Test::More;

use Text::FrontMatter::YAML;

my $file = 't/data/emptyboth';

open my $fh, '<', $file or die "can't open $file";
my $tfm = Text::FrontMatter::YAML->new(
    fh => $fh,
);

my $yaml = $tfm->frontmatter_text;
is($yaml, '', 'empty yaml returned for file with both sections empty');


my $data = $tfm->data_text;
is($data, '', 'empty data returned for file with both sections empty');

done_testing();
1;
