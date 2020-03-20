use v6;
#use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Gio::Application;
use Gnome::Gio::Enums;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::Application $a;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $a .= new(:app-id('io.github.martimm.gio'));
  isa-ok $a, Gnome::Gio::Application, '.new(:app-id)';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  ok $a.id-is-valid('io.github.martimm.gio'), '.id-is-valid()';
  is $a.get-application-id, 'io.github.martimm.gio', '.get-application-id()';
  $a.set-application-id('io.mt.xyz');
  is $a.get-application-id, 'io.mt.xyz', '.set-application-id()';

  my Int $f = $a.get-flags;
  is GApplicationFlags($f), G_APPLICATION_FLAGS_NONE, '.get-flags()';
  $a.set-flags(G_APPLICATION_IS_SERVICE +| G_APPLICATION_CAN_OVERRIDE_APP_ID);
  $f = $a.get-flags;
  ok $f +& G_APPLICATION_IS_SERVICE, '.set-flags()';
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