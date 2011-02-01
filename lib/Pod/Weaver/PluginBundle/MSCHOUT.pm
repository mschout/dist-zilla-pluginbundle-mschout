package Pod::Weaver::PluginBundle::MSCHOUT;

# ABSTRACT: Pod::Weaver configuration the way MSCHOUT does it

# Dependencies
use Pod::Weaver::Section::SourceGitHub;
use Pod::Weaver::Section::BugsRT;

use Pod::Weaver::Config::Assembler;

use namespace::autoclean;

sub _exp { Pod::Weaver::Config::Assembler->expand_package($_[0]) }

sub mvp_bundle_config {
    return (
        [ '@Default/CorePrep', _exp('@CorePrep'), {} ],
        [ '@Default/Name',     _exp('Name'),      {} ],
        [ '@Default/Version',  _exp('Version'),   {} ],

        [ '@Default/prelude', _exp('Region'),  { region_name => 'prelude' } ],
        [ 'SYNOPSIS',         _exp('Generic'), {} ],
        [ 'DESCRIPTION',      _exp('Generic'), {} ],
        [ 'OVERVIEW',         _exp('Generic'), {} ],

        [ 'ATTRIBUTES', _exp('Collect'), { command => 'attr' } ],
        [ 'METHODS',    _exp('Collect'), { command => 'method' } ],
        [ 'FUNCTIONS',  _exp('Collect'), { command => 'func' } ],

        [ '@MSCHOUT/Leftovers', _exp('Leftovers'), {} ],

        [ '@MSCHOUT/SourceGitHub', _exp('SourceGitHub'), {} ],
        [ '@MSCHOUT/BugsRT',       _exp('BugsRT'),       {} ],

        [ '@MSCHOUT/postlude', _exp('Region'), { region_name => 'postlude' } ],

        [ '@MSCHOUT/Authors', _exp('Authors'), {} ],
        [ '@MSCHOUT/Legal',   _exp('Legal'),   {} ]
    );
}

1;

__END__

=head1 DESCRIPTION

This is the L<Pod::Weaver> config I use for building my documentation.  I use
it with L<Dist::Zilla::PluginBundle::MSCHOUT>

