package Text::FrontMatter::YAML;

use warnings;
use strict;

use 5.10.0;

use Data::Dumper;
use Carp;
use YAML::Tiny qw/Load/;

=head1 NAME

Text::FrontMatter::YAML - read the "YAML front matter" format

=cut

our $VERSION = '0.03';


=head1 SYNOPSIS

    use Text::FrontMatter::YAML;

    my $tfm = Text::FrontMatter::YAML->new(
        from_string => $text_with_frontmatter
    );

    my $hashref  = $tfm->frontmatter_hashref();
    my $mumble   = $hashref->{'mumble'};
    my $data     = $tfm->data_text();

    # or also

    my $fh = $tfm->data_fh();
    while (defined(my $line = <$fh>)) {
        # do something with the file data
    }


=head1 DESCRIPTION

Text::FrontMatter::YAML opens files with so-called "YAML front matter",
such as are found on GitHub (and used in Jekyll, and various other
programs). It's a way of associating metadata with a file by marking off
the metadata into a YAML section at the top of the file. (See
L</The Structure of files with front matter> for more.)

The YAML front matter can be retrieved as a hash or as a string, and the
file data below can be retrieved as a string, or via a filehandle.
Access is read-only.

=head2 The Structure of files with front matter

Files with a block at the beginning like the following are considered to
have "front matter":

    ---
    author: Aaron Hall
    email:  ahall@vitahall.org
    module: Text::FrontMatter::YAML
    version: 0.50
    ---
    This is the rest of the file data, and isn't part of
    the front matter block. This section of the file is not
    interpreted in any way by Text::FrontMatter::YAML.

It is not an error to open text files that have no front matter block,
nor those that have no data block.

Triple-dashed lines (C<---\n>) mark the beginning of the two sections.
The first triple-dashed line marks the beginning of the front matter. The
second such line marks the beginning of the data section. Thus the
following is a valid document:

    ---
    ---

That defines a document with defined but empty front matter and data
sections. The triple-dashed lines are stripped when the front matter or
data are returned as text.

If the input has front matter, a triple-dashed line must be the first line
of the file. If not, the file is considered to have no front matter; it's
all data. frontmatter_text() and frontmatter_hashref() will return
undef in this case.

In files with a front matter block, the first line following the next
triple-dashed line begins the data section. If there I<is> no second
triple-dashed line the file is considered to have no data section, and
data_text() and data_fh() will return undef.

=head1 METHODS

=head2 new

new() creates a new Text::FrontMatter::YAML object. It takes one parameter,
C<from_string>, which contains the input data in a scalar.

=cut

sub new {
    my $class = shift;
    my $self  = {};
    bless $self => $class;

    my %args = @_;

    # disallow passing incompatible arguments
    croak "must pass from_string to new()" unless $args{'from_string'};

    # initialize from whatever we've got
    $self->_init_from_string($args{'from_string'});

    return $self;
}



sub _init_from_fh {
    my $self = shift;
    my $fh   = shift;

    my $yaml_marker_re = qr/^---\s*$/;
    my $state;
    my $yaml;
    my $data;
    LINE: while (defined(my $line = <$fh>)) {
        if (! $state) {
            # set initial state
            if ($line =~ $yaml_marker_re) {
                $state = 'in_yaml';
                $yaml .= ''; # define frontmatter section
                next LINE; # don't collect the leading '---'
            }
            else {
                $state = 'in_data';
            }
        }
        elsif ($state eq 'in_yaml') {
            # if state already defined, just look for trailing '---'
            # Maybe also allow '...'?
            if ($line =~ $yaml_marker_re) {
                $state = 'in_data';
                $data .= ''; # define data section
                next LINE;  # don't collect the trailing '---'
            }
        }
        # no check is performed for $state eq 'in_data'. Once you're in
        # the data section, you stay there. (It might be useful to change
        # this later to deal with document streams.)

        # collect the line
        if ($state eq 'in_yaml') {
            $yaml .= $line;
        }
        elsif ($state eq 'in_data') {
            $data .= $line;
        }
    }

    $self->{'yaml'} = $yaml;
    $self->{'data'} = $data;
}


sub _init_from_string {
    my $self   = shift;
    my $string = shift;

    open my $fh, '<:encoding(UTF-8)', \$string
      or die "internal error: cannot open filehandle on string, $!";

    $self->_init_from_fh($fh);

    close $fh;
}


=head2 frontmatter_hashref

frontmatter_hashref() loads the YAML in the front matter using YAML::Tiny
and returns a reference to the resulting hash. It takes no parameters.

If there is no front matter block, it returns undef.

=cut

sub frontmatter_hashref {
    my $self = shift;

    if (! defined($self->{'yaml'})) {
        return;
    }

    if (! $self->{'yaml_hashref'}) {
        my $href = Load($self->{'yaml'});
        $self->{'yaml_hashref'} = $href;
    }

    return $self->{'yaml_hashref'};
}

=head2 frontmatter_text

frontmatter_text() returns the text found the front matter block,
if any. The trailing triple-dash line (C<--->), if any, is removed. It takes
no parameters.

If there is no front matter block, it returns undef.

=cut

sub frontmatter_text {
    my $self = shift;

    return $self->{'yaml'};
}


=head2 data_fh

data_fh() returns a filehandle whose contents are the data section
of the file. It takes no parameters. The filehandle will be ready for
reading from the beginning. A new filehandle will be returned each time
data_fh() is called.

If there is no data section, it returns undef.

=cut

sub data_fh {
    my $self = shift;

    if (! defined($self->{'data'})) {
        return;
    }

    my $data = $self->{'data'};
    open my $fh, '<', \$data
      or die "internal error: cannot open filehandle on string, $!";

    return $fh;
}


=head2 data_text

data_text() returns a string contaning the data section of the file.
It takes no parameters.

If there is no data section, it returns undef.

=cut

sub data_text {
    my $self = shift;

    return $self->{'data'};
}

=head1 BUGS

=over 4

=item *

Errors in the YAML will only be detected upon calling frontmatter_hashref(),
because that's the only time that YAML::Tiny is called to parse the YAML.

=back

Please report bugs to me at C<ahall@vitaphone.net>. Please include
C<Text::FrontMatter::YAML> in the subject line of the e-mail. Thanks!

=head1 DIAGNOSTICS

=over 4

=item must give one (and only one) of 'fh', 'string', or 'path'

When calling new(), you must tell it to take the data from an open
filehandle you supply, a string, or a file. You'll get this message
if you specify none of those, or more than one.

=item cannot open <path>...

You passed a filename (via C<path>) to new(), and the file couldn't be
opened.

=item internal error: ...

Something went wrong that wasn't supposed to, and points to a bug. Please
report it to me at C<< ahall@vitahall.org >>. Thanks!

=back

=head1 DEPENDENCIES

YAML::Tiny (available from CPAN) is used to process the YAML front matter
when frontmatter_hashref() is called.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::FrontMatter::YAML

Send questions, feature requests, and bug reports to me at
C<ahall@vitaphone.net>. Please include C<Text::FrontMatter::YAML> in the
subject line of the e-mail. Thanks!

=head1 SEE ALSO

Jekyll - L<https://github.com/mojombo/jekyll/wiki/yaml-front-matter>


L<YAML>

L<YAML::Tiny>

=head1 AUTHOR

Aaron Hall, C<< ahall@vitaphone.net >>

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Aaron Hall.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl 5.10.0.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1; # End of Text::FrontMatter::YAML
