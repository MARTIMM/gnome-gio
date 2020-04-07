use v6;
use NativeCall;
use Test;

use Gnome::Gio::File;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#`{{
#-------------------------------------------------------------------------------
class MyGuiClass is Gnome::Gio::File {
  submethod new ( |c ) {
    self.bless( :GFile, |c);
  }
}

subtest 'User class test', {
  my MyGuiClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::File, '.new()';
}

}}
#-------------------------------------------------------------------------------
my Gnome::Gio::File $f;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $f .= new(:path<t/data/g-resources/rtest>);
  isa-ok $f, Gnome::Gio::File, '.new(:path)';
  $f.clear-object;

  $f .= new(:uri<https://developer.gnome.org/gio/2.62/GFile.html>);
  isa-ok $f, Gnome::Gio::File, '.new(:uri)';
  $f.clear-object;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $f .= new(:uri<https://developer.gnome.org/gio/2.62/GFile.html>);
  is $f.get-basename, 'GFile.html', '.get-basename()';
  is $f.get-path, Str, '.get-path() no path for uri';
  is $f.get-uri, 'https://developer.gnome.org/gio/2.62/GFile.html',
     '.get-uri()';
  is $f.is-native, 0, '.is-native()';
#  is $f.has-uri-scheme('ftp'), 0, '.has-uri-scheme() no ftp';
#  is $f.has-uri-scheme('http'), 1, '.has-uri-scheme() has http';
#  is $f.get-uri-scheme, 'http', '.get-uri-scheme()';
  $f.clear-object;

  $f .= new(:path<t/data/g-resources/rtest>);
  like $f.get-path, / 't/data/g-resources/rtest' $/, '.get-path()';
  $f.clear-object;
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Inherit ...', {
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
}

#-------------------------------------------------------------------------------
subtest 'Themes ...', {
}

#-------------------------------------------------------------------------------
subtest 'Signals ...', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
