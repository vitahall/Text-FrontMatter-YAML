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

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Text::FrontMatter::YAML;

    my $filepath = shift(@ARGV);
    my $tfm = Text::FrontMatter::YAML->new(
        path => $filepath,
    );

    my $hashref   = $tfm->get_frontmatter_hash();
    my $mumble    = $hashref->{'mumble'};

    my $fh = $tfm->get_data_fh();
    while (defined(my $line = <$fh>)) {
        # do something with the file data
    }

    # or also

    my $tfm = Text::FrontMatter::YAML->new(
        string => $text_with_frontmatter
    );

    my $yaml = $tfm->get_frontmatter_text();
    my $data = $tfm->get_data_text();

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

If the input has front matter, a triple-dashed line must be the first line
of the file. If not, the file is considered to have no front matter; it's
all data. get_frontmatter_text() and get_frontmatter_hash() will return
undef in this case.

The triple-dashed line ending the block is taken as a separator. It is not
returned in either the frontmatter or data. In files with a front matter
block, the first line following the triple-dashed line begins the data
section. If there I<is> no trailing triple-dashed line the file is
considered to have no data section, and get_data_text() and get_data_fh()
will return undef.


=head1 METHODS

=head2 new

new() created a new Text::FrontMatter::YAML object. You can create an object
from an existing filehandle, a string, or a file. It takes a hash, and one
of the following arguments must be passed:

=over 4

=item I<fh>

A filehandle, ready for reading. The filehandle will be read to the end
but not closed. The filehandle is not used for any other purposes, so it's
all right to close it after new() returns.

=item I<path>

The path to the file you want to open. If the file cannot be opened,
Text::FrontMatter::YAML will croak().

=item I<string>

Um, a string. :)

=back

=cut

sub new {
    my $class = shift;
    my $self  = {};
    bless $self => $class;

    my %args = @_;

    # disallow passing incompatible arguments
    my $initargs;
    $initargs++ if $args{'fh'};
    $initargs++ if $args{'string'};
    $initargs++ if $args{'path'};
    croak "must give one (and only one) of 'fh', 'string', or 'path'"
      if $initargs != 1;

    # initialize from whatever we've got
    if ($args{'fh'}) {
        $self->_init_from_fh($args{'fh'});
    }
    elsif ($args{'string'}) {
        $self->_init_from_string($args{'string'});
    }
    elsif ($args{'path'}) {
        $self->_init_from_file($args{'path'}, $args{'mode'});
    }
    else {
        die "internal error: no init argument";
    }

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

    open my $fh, '<', \$string
      or die "internal error: cannot open filehandle on string, $!";

    $self->_init_from_fh($fh);

    close $fh;
}


sub _init_from_file {
    my $self = shift;
    my $path = shift;
    my $mode = shift || '<';  # mode is currently undocumented

    if ($mode ne '<') {
        croak "can only open files read-only";
    }

    open my $fh, $mode, $path
      or croak "cannot open $path, $!";

    $self->_init_from_fh($fh);

    close $fh;
}


=head2 get_frontmatter_hash

get_frontmatter_hash() loads the YAML in the front matter using YAML::Tiny
and returns the resulting hash. It takes no parameters.

If there is no front matter block, it returns undef.

=cut

sub get_frontmatter_hash {
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

=head2 get_frontmatter_text

get_frontmatter_text() returns the text found the front matter block,
if any. The trailing triple-dash line (C<--->), if any, is removed. It takes
no parameters.

If there is no front matter block, it returns undef.

=cut

sub get_frontmatter_text {
    my $self = shift;

    return $self->{'yaml'};
}


=head2 get_data_fh

get_data_fh() returns a filehandle whose contents are the data section
of the file. It takes no parameters. The filehandle will be ready for
reading from the beginning. A new filehandle will be returned each time
get_data_fh() is called.

If there is no data section, it returns undef.

=cut

sub get_data_fh {
    my $self = shift;

    if (! defined($self->{'data'})) {
        return;
    }

    my $data = $self->{'data'};
    open my $fh, '<', \$data
      or die "internal error: cannot open filehandle on string, $!";

    return $fh;
}


=head2 get_data_text

get_data_text() returns a string contaning the data section of the file.
It takes no parameters.

If there is no data section, it returns undef.

=cut

sub get_data_text {
    my $self = shift;

    return $self->{'data'};
}

=head1 BUGS

=over 4

=item *

Errors in the YAML will only be detected upon calling get_frontmatter_hash(),
because that's the only time that YAML::Tiny is called to parse the YAML.

=back

Please report any bugs or feature requests to C<bug-text-frontmatter-yaml at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-FrontMatter-YAML>.  I
will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 DIAGNOSTICS

=over 4

=item must give one (and only one) of 'fh', 'string', or 'path'

When calling new(), you must tell it to take the data from an open
filehandle you supply, a string, or a file. You'll get this message
if you specify none of those, or more than one.

=item can only open files read-only

Heh, you found the I<mode> parameter to new(). It only accepts C<< < >>,
which is the default, and so probably isn't worth using yet. If write
access is added, this will do something.

=item cannot open <path>...

You passed a filename (via C<path>) to new(), and the file couldn't be
opened.

=item internal error: ...

Something went wrong that wasn't supposed to, and points to a bug. Please
report it to me at C<< ahall@vitahall.org >>. Thanks!

=back

=head1 DEPENDENCIES

YAML::Tiny (available from CPAN) is used to process the YAML front matter
when get_frontmatter_hash() is called.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::FrontMatter::YAML


=head1 SEE ALSO

Jekyll L<https://github.com/mojombo/jekyll/wiki/yaml-front-matter>

This implementation is believed to be compatible with Jekyll's, which is
the originator of the concept, as far as I can tell.

L<YAML>

L<YAML::Tiny>

=head1 AUTHOR

Aaron Hall, C<< ahall@vitahall.org >>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Aaron Hall.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Text::FrontMatter::YAML
