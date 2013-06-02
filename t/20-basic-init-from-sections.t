use strict;

use Test::More;

use Text::FrontMatter::YAML;

##############################

my $INPUT_HASH = {
    title => 'The first sentence of the "Gettysburg Address"',
    author => 'Abraham Lincoln',
    date => 18631119
};

my $INPUT_TEXT = <<END_DATA;
Four score and seven years ago our fathers brought forth on this continent
a new nation, conceived in liberty, and dedicated to the proposition that
all men are created equal.
END_DATA

my $tfm = Text::FrontMatter::YAML->new(
    frontmatter_hashref => $INPUT_HASH,
    data_text           => $INPUT_TEXT,
);

##############################

ok(ref($tfm), 'new returned an object');

# No, we can't rely on the ordering of keys in the returned YAML, but
# YAML::Tiny currently sorts the keys when it writes out the hash. I'll deal
# with it if that changes.

my $expected_doc = <<'END_DOCUMENT';
---
author: 'Abraham Lincoln'
date: 18631119
title: "The first sentence of the \"Gettysburg Address\""
---
Four score and seven years ago our fathers brought forth on this continent
a new nation, conceived in liberty, and dedicated to the proposition that
all men are created equal.
END_DOCUMENT

my $doc = $tfm->document_string;
is($doc, $expected_doc, "document_string returned joined document");

my $data = $tfm->data_text;
is($data, $INPUT_TEXT, "data_text round-tripped correctly");

my $hash = $tfm->frontmatter_hashref;
is_deeply($hash, $INPUT_HASH, "frontmatter_hashref round-tripped correctly");

done_testing();
1;
