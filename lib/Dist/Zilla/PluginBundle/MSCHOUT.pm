package Dist::Zilla::PluginBundle::MSCHOUT;

# ABSTRACT: Use L<Dist::Zilla> like MSCHOUT does

use Moose;
use Moose::Autobox;

with 'Dist::Zilla::Role::PluginBundle::Easy';

sub configure {
    my $self = shift;

    my $args = $self->payload;

    my $upload = $$args{no_upload} ? 0 : 1;

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
            AutoPrereq
            PodWeaver
            Repository
            Bugtracker
            Homepage
            Signature
            ArchiveRelease
        ),
        [
            BumpVersionFromGit => {
                first_version => '0.01'
            }
        ]
    );

    $self->add_bundle('Git');
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

 [@Git]
 [ArchiveRelease]
 [AutoPrereq]
 [Bugtracker]
 [BumpVersionFromGit]
 [Homepage]
 [NextRelease]
 [PodWeaver]
 [Repository]
 [Signature]

In addition, if C<no_upload> is true, then C<UploadToCPAN> is replaced with C<FakeRelease>.
