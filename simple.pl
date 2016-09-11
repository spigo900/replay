use Config;
use Carp;
use Getopt::Long;
use strict;
use warnings;
use feature 'say';

my $PATH_SEP = $Config{osname} eq "MSWin32" ? q(\\) : "/";
my ($playlist_file, $out_file, $base_path) = @ARGV;

# my %REGEXES = +{add => qr{s/^(.+)$/$base_path$1/gm},
#                 remove => s/^\Q$base_path\E(.+)$/$1/m};

my $remove = 0;
GetOptions("remove|r" => \$remove);

# my $regex = $remove ? $REGEXES{remove} : $REGEXES{add};


my $contents_;
{
    local $/ = undef;
    open(my $file, "<", $playlist_file)
        or croak "Could not open playlist file $playlist_file: $!";
    $contents_ = <$file>;
    close($file);
}

if($base_path =~ /[^\Q$PATH_SEP\E]$/) {
    $base_path = $base_path . $PATH_SEP;
}

$base_path =~ s{\Q$PATH_SEP\E}{/}gm;
# $contents_ =~ $regex;
if(!$remove) {
    $contents_ =~ s/^(.+)$/$base_path$1/gm;
} else {
    $contents_ =~ s/^\Q$base_path\E(.+)$/$1/m
}

print($contents_);

0;
