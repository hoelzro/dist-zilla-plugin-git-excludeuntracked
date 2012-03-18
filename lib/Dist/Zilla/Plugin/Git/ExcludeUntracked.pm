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

=head1 SEE ALSO

L<Dist::Zilla>

=cut
