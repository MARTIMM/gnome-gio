use v6;
use NativeCall;
use Test;

use Gnome::Gio::Resource;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::Resource $r;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  throws-like(
    { $r .= new(:load<non-existent.gresource>); },
    X::Gnome, 'Non existent resource',
    :message(/:s Failed to open file/)
  );

  $r .= new(:load<t/data/g-resources/rtest.gresource>);
  isa-ok $r, Gnome::Gio::Resource, '.new(:load)';
}

subtest 'Manipulations', {
  ok 1, $r.register // '.register()';
  ok 1, $r.unregister // '.unregister()';
}

#`{{
#-------------------------------------------------------------------------------
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