package Dist::Zilla::PluginBundle::MSCHOUT;

# ABSTRACT: Use L<Dist::Zilla> like MSCHOUT does

use Moose;
use Moose::Autobox;

with 'Dist::Zilla::Role::PluginBundle::Easy';

sub configure {
    my $self = shift;

    my $args = $self->payload;

    my $upload = $$args{no_upload} ? 0 : 1;

    $self->add_bundle(Filter => {
        bundle => '@Classic',
        remove => ['PodVersion', ($upload ? () : 'UploadToCPAN')]
    });

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
 dist = MyDist

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

