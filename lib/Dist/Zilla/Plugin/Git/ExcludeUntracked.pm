## no critic (RequireUseStrict)
package Dist::Zilla::Plugin::Git::ExcludeUntracked;

## use critic (RequireUseStrict)
use Moose;

with 'Dist::Zilla::Role::FilePruner';


sub _assemble_untracked_lookup {
    my ( $self ) = @_;

    my @untracked_files = map {
        chomp; $_
    } qx(git ls-files --other);

    return map { $_ => 1 } @untracked_files;
}

sub prune_files {
    my ( $self ) = @_;

    my $zilla            = $self->zilla;
    my @files            = @{ $zilla->files };
    my %untracked_lookup = $self->_assemble_untracked_lookup;

    foreach my $file (@files) {
        if(exists $untracked_lookup{$file->name}) {
            $self->log_debug([ 'pruning %s', $file->name ]);
            $zilla->prune_file($file);
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

# ABSTRACT:  Excludes untracked files from your dist

=head1 SYNOPSIS

  [Git::ExcludeUntracked]

=head1 DESCRIPTION

This L<Dist::Zilla> plugin automatically excludes any files from your
distribution that are not currently tracked by Git.

=head1 COMPARED TO GIT::GATHERDIR

There's another plugin that provides similar functionality:
L<Dist::Zilla::Plugin::Git::GatherDir>.  The chief difference is that
while this plugin is designed to work in concert with
L<Dist::Zilla::Plugin::GatherDir>, C<Git::GatherDir> is designed to work
as a replacement for C<GatherDir>.

=head1 SEE ALSO

L<Dist::Zilla>

=begin comment

=over

=item prune_files

=back

=end comment

=cut
