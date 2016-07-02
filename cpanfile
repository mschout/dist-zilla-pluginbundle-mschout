requires "Dist::Zilla" => "4.102341";
requires "Dist::Zilla::Plugin::ArchiveRelease" => "0";
requires "Dist::Zilla::Plugin::AutoPrereqs" => "0";
requires "Dist::Zilla::Plugin::Bugtracker" => "0";
requires "Dist::Zilla::Plugin::CheckPrereqsIndexed" => "0";
requires "Dist::Zilla::Plugin::FakeRelease" => "0";
requires "Dist::Zilla::Plugin::Git::NextVersion" => "0";
requires "Dist::Zilla::Plugin::Homepage" => "0";
requires "Dist::Zilla::Plugin::PodWeaver" => "0";
requires "Dist::Zilla::Plugin::RemovePrereqs" => "0";
requires "Dist::Zilla::Plugin::Repository" => "0";
requires "Dist::Zilla::Plugin::Signature" => "0";
requires "Dist::Zilla::Plugin::TaskWeaver" => "0.093330";
requires "Dist::Zilla::Plugin::Twitter" => "0";
requires "Dist::Zilla::PluginBundle::Classic" => "0";
requires "Dist::Zilla::PluginBundle::Filter" => "0";
requires "Dist::Zilla::PluginBundle::Git" => "1.101230";
requires "Dist::Zilla::Role::PluginBundle::Easy" => "0";
requires "Moose" => "0";
requires "Moose::Autobox" => "0";
requires "Pod::Elemental::Transformer::List" => "0";
requires "Pod::Weaver::Config::Assembler" => "0";
requires "Pod::Weaver::Section::AllowOverride" => "0";
requires "Pod::Weaver::Section::BugsRT" => "0";
requires "Pod::Weaver::Section::SourceGitHub" => "0";
requires "namespace::autoclean" => "0";

on 'test' => sub {
  requires "Socket" => "0";
  requires "Test::More" => "0";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};
