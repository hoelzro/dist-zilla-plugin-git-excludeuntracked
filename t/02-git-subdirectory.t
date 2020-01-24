use strict;
use warnings;
use lib 'lib';
use lib 't/lib';
use autodie qw(chdir fork);

use Test::More tests => 1;
use Test::DZil;
use Archive::Tar;
use TestUtils;

sub touch_file {
    my ( $filename ) = @_;

    my $fh;
    open $fh, '>', $filename or die $!;
    close $fh;
}

my $tzil = Builder->from_config(
    { dist_root => 'fake-distributions/Fake' },
    { add_files => {
        'source/dist.ini' => simple_ini({
            name    => 'Fake',
            version => '0.01',
        }, [GatherDir => {
            include_dotfiles => '1',
        }], [PruneFiles => {
            filename => '.git',
        }], qw/FakeRelease MakeMaker Manifest Git::ExcludeUntracked/
        ),
      },
    }
);

chdir $tzil->tempdir->child('source');

silent_system 'git', 'init';
silent_system 'git', 'add', 'dist.ini', 'lib/', '.gitignore';
silent_system 'git', 'commit', '-m', 'Initial commit';
mkdir 'foo';
mkdir 'foo/bar';
touch_file 'foo/bar/baz.txt';
chdir 'foo';
silent_system 'git', 'init';
silent_system 'git', 'add', 'bar/baz.txt';
silent_system 'git', 'commit', '-m', 'testing';
chdir '..';

$tzil->build_archive;

my @archive_files = map { s{/$}{}; $_ } sort(list_archive($tzil->archive_filename));

is_deeply \@archive_files, [
    'Fake-0.01',
    'Fake-0.01/MANIFEST',
    'Fake-0.01/Makefile.PL',
    'Fake-0.01/dist.ini',
    'Fake-0.01/lib',
    'Fake-0.01/lib/Fake.pm',
];
