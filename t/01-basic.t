use strict;
use warnings;
use lib 'lib';
use autodie qw(chdir fork);

use Test::More tests => 1;
use Test::DZil;

sub silent_system {
    my ( @args ) = @_;

    my $pid = fork;

    if($pid) {
        waitpid -1, 0;
    } else {
        close STDOUT;
        close STDERR;

        exec @args;
        exit 1;
    }
}

sub list_archive {
    my ( $archive_filename ) = @_;

    my $archive_class;

    my $ok = eval {
        require Archive::Tar::Wrapper;
    };

    if($ok) {
        $archive_class = 'Archive::Tar::Wrapper';
    } else {
        require Archive::Tar;
        $archive_class = 'Archive::Tar';
    }

    my $archive = $archive_class->new($archive_filename);

    my @files = $archive->list_files;

    return @files;
}

my $tzil = Builder->from_config(
    { dist_root => 'fake-distributions/Fake' },
    { add_files => {
        'source/dist.ini' => simple_ini({
            name    => 'Fake',
            version => '0.01',
        }, [GatherDir => {
            include_dotfiles => '1',
        }], qw/FakeRelease MakeMaker Manifest Git::ExcludeUntracked/
        ),
      },
    }
);

chdir $tzil->tempdir->file('source');

silent_system 'git', 'init';
silent_system 'git', 'add', 'dist.ini', 'lib/', '.gitignore';
silent_system 'git', 'commit', '-m', 'Initial commit';

$tzil->build_archive;

my @archive_files = sort(list_archive($tzil->archive_filename));

is_deeply \@archive_files, [
    'Fake-0.01',
    'Fake-0.01/MANIFEST',
    'Fake-0.01/Makefile.PL',
    'Fake-0.01/dist.ini',
    'Fake-0.01/lib',
    'Fake-0.01/lib/Fake.pm',
];
