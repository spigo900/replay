# Replay
Write a playlist using regular expressions for each song, then convert to .m3u
form using this script (`reformat.pl`).

The other script, `simple.pl`, takes a .m3u playlist you've already got and
(de-)relativizes it so you can use it in another music player or on another
platform (or both).

## Why?
Because I got sick of rewriting my playlists for different platforms and music
players. `simple.pl` is probably the more useful of the two for avoiding that
extra work, but `reformat.pl` was more fun to write.

## Using
```shell
$ perl reformat.pl input_file.rpl output.m3u /base/path/
```

```shell
$ perl simple.pl input_file.m3u output.m3u /base/path/
```

### As a library
```perl
use Replay::Format qw(replay);

my $playlist_file = "~/Playlists/some_file.rpl";
my $base_path = "~/Music/";
my $m3u_text = replay($playlist_file, $base_path);
```

## Known issues
Filename and directory regexes containing slashes anywhere will cause issues,
due to how the regexes are split.

If there is a filepath that would match the regex but another one matches
earlier (but doesn't match it fully), the conversion will fail without detecting
the correct file.
<!--
(fix: check against the subdirectory list instead of against the first matched.
 do this at some point?)
-->
