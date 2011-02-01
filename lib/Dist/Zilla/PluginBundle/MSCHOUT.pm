package Dist::Zilla::PluginBundle::MSCHOUT;

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

__END__

=begin Pod::Coverage

configure

=end Pod::Coverage

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
