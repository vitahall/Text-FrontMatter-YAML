use Test::More;

use Text::FrontMatter::YAML;

my $file = 't/data/basic';

my $tfm = Text::FrontMatter::YAML->new(
    path => $file,
);

my $DATA_TEXT = <<'END_DATA';
This is just some random text. Nothing to see here. Move along.

---
Ha!
...
END_DATA

my $fh = $tfm->data_fh;
ok(ref($fh) eq 'GLOB', 'data_fh returned a filehandle');


my $output;
while (defined(my $line = <$fh>)) {
    $output .= $line;
}

is($output, $DATA_TEXT, 'filehandle outputs correct data');

my $fh2 = $tfm->data_fh;
my $fh3 = $tfm->data_fh;
isnt($fh2, $fh3, 'data_fh returns a new filehandle on each call');

done_testing();
