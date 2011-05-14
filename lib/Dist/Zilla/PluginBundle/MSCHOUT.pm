package Dist::Zilla::PluginBundle::MSCHOUT;
BEGIN {
  $Dist::Zilla::PluginBundle::MSCHOUT::VERSION = '0.21';
}

# ABSTRACT: Use L<Dist::Zilla> like MSCHOUT does

use Moose;
use Moose::Autobox;

with 'Dist::Zilla::Role::PluginBundle::Easy';

sub configure {
    my $self = shift;

    my $args = $self->payload;

    my $upload = $$args{no_upload} ? 0 : 1;
    my $release_branch = $$args{release_branch} || 'build/releases';

    my @remove = qw(PodVersion);

    # if not uploading, remove the upload plugin, and the confirmation plugin
    unless ($upload) {
        push @remove, 'UploadToCPAN', 'ConfirmRelease';
    }

    $self->add_bundle(Filter => {
        bundle => '@Classic',
        remove => \@remove
    });

    # add FakeRelease plugin if uploads are off
    unless ($upload) {
        $self->add_plugins('FakeRelease');
    }

    $self->add_plugins(
        qw(
            AutoPrereqs
            Repository
            Bugtracker
            Homepage
            Signature
            ArchiveRelease
        ),
        # update release in Changes file
        [ NextRelease => { format => '%-2v  %{yyyy-MM-dd}d' } ],
        [ PodWeaver => { config_plugin => '@MSCHOUT' } ],
        qw(
            Git::Check
            Git::Commit
        ),
        [ 'BumpVersionFromGit' => { first_version => '0.01' } ],
        [ 'Git::CommitBuild' => { release_branch => $release_branch } ],
        [ 'Git::Tag' => { branch => $release_branch } ],
        qw(
            Git::Push
        )
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;



=pod

=head1 NAME

Dist::Zilla::PluginBundle::MSCHOUT - Use L<Dist::Zilla> like MSCHOUT does

=head1 VERSION

version 0.21

=head1 DESCRIPTION

This is the pluginbundle that MSCHOUT uses. Use it as:

 [@MSCHOUT]

Optionally, for a dist that you do not want to upload to CPAN:
 [@MSCHOUT]
 no_upload = 1

It's equivalent to:

 [@Filter]
 bundle = @Classic
 remove = PodVersion

 [AutoPrereqs]
 [PodWeaver]
 [Repository]
 [Bugtracker]
 [Homepage]
 [Signature]
 [ArchiveRelease]
 [NextRelease]
    format = "%-2v  %{yyyy-MM-dd}d"
 [Git::Check]
 [Git::Commit]
 [BumpVersionFromGit]
    first_version = 0.01
 [Git::CommitBuild]
    release_branch = build/releases
 [Git::Tag]
    branch = build/releases
 [Git::Push]

=head2 Options

The following configuration settings are available:

=over 4

=item * no_upload

Disables C<UploadToCPAN> and C<ConfirmRelease>.  Adds C<FakeRelease>.

=item * release_branch

Sets the release branch name.  Default is C<build/releases>.

=back

=for Pod::Coverage configure

=head1 SOURCE

The development version is on github at L<http://github.com/mschout/dist-zilla-pluginbundle-mschout>
and may be cloned from L<git://github.com/mschout/dist-zilla-pluginbundle-mschout.git>

=head1 BUGS

Please report any bugs or feature requests to bug-dist-zilla-pluginbundle-mschout@rt.cpan.org or through the web interface at:
 http://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-PluginBundle-MSCHOUT

=head1 AUTHOR

Michael Schout <mschout@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Michael Schout.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

