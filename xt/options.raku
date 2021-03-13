#!/usr/bin/env raku

use v6;
use Getopt::Advance;
use Getopt::Advance::Parser;
use Getopt::Advance::Exception;

my OptionSet $local-opts .= new;
$local-opts.push( 'version=b', 'Request version');
$local-opts.push( 'v|verbose=b', 'More output');
$local-opts.append(
  "h|help=b" => "print this help",
  "s|show=s" => "show text from file"
);

$local-opts.insert-pos(
  "directory",
  0,
  sub ($, $dirarg) {
    die "$dirarg: Not a valid directory" if $dirarg.value.IO !~~ :d;
  }
);

$local-opts.insert-main(
    sub main( $optset, @args) {
        return 0 if $optset<help> ^ $optset<version>;
        if $optset.get-pos('directory', 0).?success {
            @args.shift;
        } else {
            &ga-want-helper();
        }
        my $regex = +@args > 0 ?? @args.shift.value !! "";
    }
);


CATCH { default { .message.note; } }
my $a = getopt( @*ARGS, $local-opts);

say 'do verbose' if $local-opts<verbose>;
say 'return version' if $local-opts<version>;
say "show text in '$local-opts<show>'" if $local-opts<version>;
