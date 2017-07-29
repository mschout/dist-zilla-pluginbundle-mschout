package Dist::Zilla::PluginBundle::MSCHOUT;

# ABSTRACT: Use L<Dist::Zilla> like MSCHOUT does

use Moose;
use MooseX::AttributeShortcuts;
use namespace::autoclean;

with qw(Dist::Zilla::Role::PluginBundle::Easy
        Dist::Zilla::Role::PluginBundle::Config::Slicer
        Dist::Zilla::Role::PluginBundle::PluginRemover);

has is_task => (is => 'lazy', isa => 'Bool');

has release_branch => (is => 'lazy', isa => 'Str');

has upload => (is => 'lazy', isa => 'Bool');

has use_travis => (is => 'lazy', isa => 'Bool');

has use_twitter => (is => 'lazy', isa => 'Bool');

sub configure {
    my $self = shift;

    my $args = $self->payload;

    my @remove = qw(PodVersion);

    # if not uploading, remove the upload plugin, and the confirmation plugin
    if ($self->upload) {
        push @remove, 'UploadToCPAN', 'ConfirmRelease';
    }

    $self->add_plugins('CheckPrereqsIndexed');

    $self->add_bundle(Filter => {
        bundle => '@Classic',
        remove => \@remove
    });

    # add FakeRelease plugin if uploads are off
    if ($self->upload) {
        $self->add_plugins('FakeRelease');
    }

    $self->add_plugins(
        qw(
            AutoPrereqs
            MinimumPerl
            InsertCopyright
            Repository
            Bugtracker
            Homepage
            Signature
            MetaJSON
            ArchiveRelease
        ),
        # update release in Changes file
        [ NextRelease => { format => '%-2v  %{yyyy-MM-dd}d' } ]
    );

    if ($self->is_task) {
        $self->add_plugins(
            'TaskWeaver',
            [ AutoVersion => { time_zone => 'America/Chicago' } ]
        );
    }
    else {
        $self->add_plugins(
            [ PodWeaver => { config_plugin => '@MSCHOUT' } ],
            [ 'Git::NextVersion' => { first_version => '0.01' } ]
        );
    }

    # we must add Travis before Git::CommitBuild because CommitBuild needs to
    # include the .travis.yml file
    if ($self->use_travis) {
        $self->add_plugins(
            [ 'TravisYML' => { build_branch => $self->release_branch } ]
        );
    }

    $self->add_plugins(
        qw(
            Git::Check
            Git::Commit
        ),
        [ 'Git::CommitBuild' => { release_branch => $self->release_branch } ],
        [ 'Git::Tag'         => { branch => $self->release_branch } ],
        [
            'Git::Push'        => {
                push_to => [
                    'origin master:master',
                    'origin build/releases:build/releases'
                ]
            }
        ],
    );

    # Module::Signature requires a massive wad of dependencies, and is
    # optional.  Remove it from the PREREQ list.
    $self->add_plugins(
        [ RemovePrereqs => { remove => 'Module::Signature' } ]
    );

    if ($self->use_twitter and $self->upload) {
        $self->add_plugins(
            [ Twitter => { hash_tags => '#perl' } ]
        );
    }
}

sub _option {
    my ($self, $name, $default) = @_;

    if (exists $self->payload->{$name}) {
        return $self->payload->{$name}
    }
    else {
        return $default;
    }
}

sub _build_is_task {
    my $self = shift;

    # recognize older option name "task" if present
    my $task = $self->_option('task');
    if (defined $task) {
        return $task;
    }

    $self->_option('is_task', 0);
}

sub _build_release_branch {
    my $self = shift;

    $self->_option('release_branch', 'build/releases');
}

sub _build_upload {
    my $self = shift;

    ! $self->_option('no_upload', 0);
}

sub _build_use_travis {
    my $self = shift;

    $self->_option('use_travis', 0);
}

sub _build_use_twitter {
    my $self = shift;

    $self->_option('use_twitter', 0);
}

__PACKAGE__->meta->make_immutable;

__END__

=begin Pod::Coverage

configure

=end Pod::Coverage

=head1 DESCRIPTION

This is the pluginbundle that MSCHOUT uses. Use it as:

 [@MSCHOUT]

It's equivalent to:

 [@Filter]
 bundle = @Classic
 remove = PodVersion

 [AutoPrereqs]
 [MinimumPerl]
 [InsertCopyright]
 [PodWeaver]
 [Repository]
 [Bugtracker]
 [Homepage]
 [Signature]
 [MetaJSON]
 [ArchiveRelease]
 [NextRelease]
    format = "%-2v  %{yyyy-MM-dd}d"
 [Git::Check]
 [Git::Commit]
 [Git::NextVersion]
    first_version = 0.01
 [Git::CommitBuild]
    release_branch = build/releases
 [Git::Tag]
    branch = build/releases
 [Git::Push]

=head2 Options

Plugins can be removed from the bundle via L<Dist::Zilla::PluginBundle::PluginRemover>:

 [@MSCHOUT]
 -remove = AutoPrereqs
 ...

The following configuration settings are available:

=begin :list

* is_task
Replaces C<Pod::Weaver> with C<Task::Weaver> and uses C<AutoVersion> instead of
C<Git::NextVersion>
* no_upload
Disables C<UploadToCPAN> and C<ConfirmRelease>.  Adds C<FakeRelease>.
* release_branch
Sets the release branch name.  Default is C<build/releases>.
* use_travis
Enables the L<TravisYML|Dist::Zilla::Plugin::TravisYML> Dist Zilla plugin.
* use_twitter
Enables the L<Twitter|Dist::Zilla::Plugin::Twitter> Dist Zilla plugin.  If
C<no_upload> is set, this plugin is skipped.

=end :list

