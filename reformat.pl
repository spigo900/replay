# package Replay::reformat;

use Config;
use Getopt::Long qw(:config no_ignore_case bundling);
use Carp;
use strict;
use warnings;
use feature 'say';

# NOTE: This script is in desperate need of cleanup. The function API is
# horribly inconsistent. That said, it shoudl run. Probably.
my $PATH_SEP = $Config{osname} eq "MSWin32" ? q(\\) : "/";
my $g_die_on_errors = 0;

# Takes a file name and returns an array of lines in the file.
sub get_lines {
    my ($path) = @_;
    my $text;
    {
        no warnings qw(once);
        open(my $file, "<", $path)
            or croak "Can't find input file $path: $!";
        $text = <$file>;
        close($file);
    }
    chomp $text;
    return split('\n', $text);
}

# Takes a file name and returns an array of array references, the first element
# of which is the line and the second is the line number.
sub get_lines_numbered {
    # TODO: write this function.
    ...
}

# Takes a single path regex string and returns an array of regexes.
sub to_regexes {
    my ($line) = @_;
    return map { qr{$_} } split(qr{[^\\]/}, $line);
}

# Takes a directory path and a pattern and check if any children of the path
# match the pattern. Returns the match if one is found, else returns undefined.
sub check_dir {
    my ($dir, $pat) = @_;
    opendir(my $dir_handle, $dir)
        or croak("Can't open directory $dir: $!");
    my $found = undef;

    while (my $filename = readdir($dir_handle)) {
        if ($filename =~ $pat) {
            $found = $filename;
            last
        }
    }

    closedir($dir_handle);

    return $found;
}

# Takes a root path and an array of regexes and, starting with the root path,
# recursively matches the current path's children against the current regex
# (starting with the first regex in the array). If any of the regexes in the
# chain fails to match, returns undefined.
sub match_regexes {
    my ($base_path, @regexes) = @_;
    my $match_path = $base_path;
    {
        local $/ = "\\";
        chomp $match_path;
    }
    for my $regex (@regexes) {
        my $checked = check_dir($match_path, $regex);
        if (!defined $checked) {
            $match_path = undef;
            last
        }
        $match_path = $match_path . $PATH_SEP . $checked;
    }
    return $match_path;
}

# Takes the path to a Replay (working title) playlist file and parses it into
# a list of regexes. Returns an array of path regexes (as array references).
sub extract_regexes {
    my ($playlist_file) = @_;
    my @lines = get_lines($playlist_file);
    my @regexes = map { my @a = to_regexes($_); \@a } @lines;
}

# Takes an array of path regexes (as array references) and a base path and returns
# a list of matching file paths.
sub get_matches {
    my ($base_path, @regexes) = @_;
    my @matches = map { [$_, match_regexes($base_path, @{$_})] } @regexes;
    my $text = join ";", @matches;

    my @files = ();
    my @errors = ();
    for my $pair (@matches) {
        my ($regexes_ref, $match) = @{$pair};
        my @regexes_l = @{$regexes_ref};

        if (!defined $match) {
            my $regex = join "/", @regexes_l;
            say "Error matching $regex on line number (TODO).";
            push @errors, $match;
        } else {
            push @files, $match;
        }
    }

    if ($g_die_on_errors && @errors) {
        croak "Could not process playlist file";
    }

    return @files;
}

# Takes a list of filepaths and joins them into the text of an .m3u file.
sub construct_m3u {
    my (@files) = @_;
    return (join "\n", @files) . "\n";
}

# Takes a Replay (working title!) playlist file and a base path and
# returns the text for an .m3u file containing the filepaths that matched the
# regexes from that playlist file.
sub match_file {
    my ($playlist_file, $base_path) = @_;
    my @matches = get_matches($base_path, extract_regexes($playlist_file));
    return construct_m3u(@matches);
}

# Takes a Replay (again, working title!) playlist file and a base path and
# writes the constructed .m3u file to the output file.
sub match_and_write {
    my ($playlist_file, $out_file, $base_path) = @_;
    my $m3u = match_file($playlist_file, $base_path);
    print $m3u;
    if (defined $m3u && !(-e $out_file)) {
        no warnings qw(once);
        open(my $fh, ">", $out_file)
            or croak "Could not open output file $out_file: $!";
        $fh->print($m3u);
        close($fh);
    }
    return;
}

# Main script routine.
sub main {
    my $playlist_file;
    my $out_file;
    my $base_path;
    my $ignore = 0;
    GetOptions("ignore|i" => \$ignore);

    if (! $ignore) {
        $g_die_on_errors = 1;
    }

    croak <<'CROAK'
Wrong number of arguments! (Takes three: base path, playlist file, and output
file.)
CROAK
        unless $#ARGV == 2;
    $playlist_file = $ARGV[0];
    $out_file = $ARGV[1];
    $base_path = $ARGV[2];

    match_and_write($playlist_file, $out_file, $base_path);
    return 0;
}

main();
