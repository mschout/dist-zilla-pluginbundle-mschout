package Dist::Zilla::PluginBundle::MSCHOUT;

# ABSTRACT: Use L<Dist::Zilla> like MSCHOUT does

use Moose;
use Moose::Autobox;

with 'Dist::Zilla::Role::PluginBundle';

use Dist::Zilla::PluginBundle::Filter;
use Dist::Zilla::PluginBundle::Git;
use Dist::Zilla::Plugin::AutoPrereq;
use Dist::Zilla::Plugin::Bugtracker;
use Dist::Zilla::Plugin::BumpVersionFromGit;
use Dist::Zilla::Plugin::Homepage;
use Dist::Zilla::Plugin::NextRelease;
use Dist::Zilla::Plugin::PodWeaver;
use Dist::Zilla::Plugin::Repository;
use Dist::Zilla::Plugin::Signature;

sub bundle_config {
    my ($self, $section) = @_;

    my $args = $section->{payload};

    my $upload = $$args{no_upload} ? 0 : 1;

    my @plugins = Dist::Zilla::PluginBundle::Filter->bundle_config({
        name => $section->{name} . '/@Classic',
        payload => {
            bundle => '@Classic',
            remove => [
                'PodVersion',
                # remove UploadToCPAN if no_upload is given
                ($upload ? () : 'UploadToCPAN')
            ]
        }
    });

    my $prefix = 'Dist::Zilla::Plugin::';
    my @extra = map {[ "$section->{name}/$_->[0]" => "$prefix$_->[0]" => $_->[1] ]}
    (
        [ AutoPrereq  => {} ],
        [ PodWeaver   => {} ],
        [
            NextRelease => {
                format => '%-2v  %{yyyy-MM-dd}d',
            }
        ],
        [ Repository  => { } ],
        [ Bugtracker  => { } ],
        [ Homepage    => { } ],
        [ Signature   => { } ],
        [
            BumpVersionFromGit => {
                first_version => 'v0.01'
            }
        ],
    );
    push @plugins, @extra;

    push @plugins, Dist::Zilla::PluginBundle::Git->bundle_config({
        name    => "$section->{name}/\@Git",
        payload => { }
    });

    return @plugins;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=begin Pod::Coverage

bundle_config

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
 [AutoPrereq]
 [Bugtracker]
 [BumpVersionFromGit]
 [Homepage]
 [NextRelease]
 [PodWeaver]
 [Repository]
 [Signature]

