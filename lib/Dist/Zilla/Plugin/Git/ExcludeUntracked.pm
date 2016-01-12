## no critic (RequireUseStrict)
package Dist::Zilla::Plugin::Git::ExcludeUntracked;

## use critic (RequireUseStrict)
use Moose;
use File::Find;

with 'Dist::Zilla::Role::FilePruner';

sub _gather_files_under_dir {
    my ( $self, $dirname ) = @_;

    my @files;

    find(sub {
        return if -d;

        push @files, $File::Find::name;
    }, $dirname);

    return @files;
}

sub _assemble_untracked_lookup {
    my ( $self ) = @_;

    my @untracked_files = map {
        chomp; $_
    } qx(git ls-files --other);

    my @subdir_files;
    foreach my $file (@untracked_files) {
        if($file =~ m{/$}) {
            push @subdir_files, $self->_gather_files_under_dir($file);
            undef $file;
        }
    }
    @untracked_files = grep { defined() } @untracked_files;
    push @untracked_files, @subdir_files;

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

# ABSTRACT:  Excludes untracked files from your dist [DEPRECATED]

=head1 SYNOPSIS

  [Git::ExcludeUntracked]

=head1 DESCRIPTION

B<NOTE> This module is deprecated in favor of L<Dist::Zilla::Plugin::Git::GatherDir>.

This L<Dist::Zilla> plugin automatically excludes any files from your
distribution that are not currently tracked by Git.

=head1 SEE ALSO

L<Dist::Zilla>, L<Dist::Zilla::Plugin::Git::GatherDir>

=begin comment

=over

=item prune_files

=back

=end comment

=cut
