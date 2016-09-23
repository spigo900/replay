#!/usr/bin/env perl
use Getopt::Long qw(:config no_ignore_case bundling);
use Carp;
use Replay::Format qw(replay);
use strict;
use warnings;
use feature 'say';

my $g_die_on_errors = 0;


# Takes a Replay (again, working title!) playlist file and a base path and
# writes the constructed .m3u file to the output file.
sub match_and_write {
    my ($playlist_file, $out_file, $base_path) = @_;
    my $m3u = replay($playlist_file, $base_path);
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
    my ($playlist_file, $out_file, $base_path);
    my $ignore = 0;
    GetOptions("ignore|i" => \$ignore);

    if (! $ignore) {
        $Replay::Format::g_die_on_errors = 1;
    }

    croak <<'CROAK'
Wrong number of arguments! (Takes three: base path, playlist file, and output
file.)
CROAK
        unless $#ARGV == 2;

    ($playlist_file, $out_file, $base_path) = @ARGV;

    match_and_write($playlist_file, $out_file, $base_path);
    return 0;
}

main();
