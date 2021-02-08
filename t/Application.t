use v6;
#use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Gio::Application;
use Gnome::Gio::Enums;
use Gnome::Gio::File;

use Gnome::Glib::Error;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::Application $a;
#-------------------------------------------------------------------------------
subtest 'ISA test', {

  $a .= new(:default);
  nok $a.is-valid, '.new(:default)';
  #$a.clear-object;

  $a .= new(:app-id('io.github.martimm.gio'));
  isa-ok $a, Gnome::Gio::Application, '.new(:app-id)';

  my Gnome::Gio::Application $b .= new(:default);
  ok $b.is-valid, '.new(:default)';
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  ok $a.id-is-valid('io.github.martimm.gio'), '.id-is-valid()';
  is $a.get-application-id, 'io.github.martimm.gio', '.get-application-id()';
  $a.set-application-id('io.mt.xyz');
  is $a.get-application-id, 'io.mt.xyz', '.set-application-id()';

  my Int $f = $a.get-flags;
  is GApplicationFlags($f), G_APPLICATION_FLAGS_NONE, '.get-flags()';
  $a.set-flags(
    G_APPLICATION_IS_SERVICE +| G_APPLICATION_CAN_OVERRIDE_APP_ID +|
    G_APPLICATION_HANDLES_OPEN
  );
  $f = $a.get-flags;
  ok $f +& G_APPLICATION_IS_SERVICE, '.set-flags()';

  nok $a.get-is-registered, '.get-is-registered() not registered';
  my Gnome::Glib::Error $e = $a.register;
  nok $e.is-valid, '.register()';
  ok $a.get-is-registered, '.get-is-registered() is registered';

  $a.set-inactivity-timeout(3600_000);
  is $a.get-inactivity-timeout, 3600_000,
    '.set-inactivity-timeout() / .get-inactivity-timeout()';

  nok $a.get-is-remote, '.get-is-remote() not remote';
}


#`{{
#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::Application', {
  class MyClass is Gnome::Gio::Application {
    method new ( |c ) {
      self.bless( :GApplication, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::Application, '.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}
}}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::Application $a .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $a.get-property( $prop, $gv);
    my $gv-value = $gv."$routine"();
    if $approx {
      is-approx $gv-value, $value,
        "property $prop, value: " ~ $gv-value;
    }

    # dependency on local settings might result in different values
    elsif $is-local {
      if $gv-value ~~ /$value/ {
        like $gv-value, /$value/, "property $prop, value: " ~ $gv-value;
      }

      else {
        ok 1, "property $prop, value: " ~ $gv-value;
      }
    }

    else {
      is $gv-value, $value,
        "property $prop, value: " ~ $gv-value;
    }
    $gv.clear-object;
  }

  test-property( G_TYPE_STRING, 'application-id', 'get-string', 'io.mt.xyz');
  test-property( G_TYPE_UINT, 'inactivity-timeout', 'get-uint', 3600_000);
  test-property( G_TYPE_BOOLEAN, 'is-busy', 'get-boolean', 0);
  test-property( G_TYPE_BOOLEAN, 'is-registered', 'get-boolean', 1);
  test-property( G_TYPE_BOOLEAN, 'is-remote', 'get-boolean', 0);
  test-property(
    G_TYPE_STRING, 'resource-base-path', 'get-string', $a.get-resource-base-path
  );

  # example calls
  #test-property( G_TYPE_BOOLEAN, 'homogeneous', 'get-boolean', 0);
  #test-property( G_TYPE_STRING, 'label', 'get-string', '...');
  #test-property( G_TYPE_FLOAT, 'xalign', 'get-float', 23e-2, :approx);
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Themes ...', {
}
}}

#-------------------------------------------------------------------------------
subtest 'Signals ...', {
  use Gnome::Gtk3::Main;
  use Gnome::N::GlibToRakuTypes;

  my Gnome::Gtk3::Main $main .= new;

  class SignalHandlers {
    has Bool $!signal-processed = False;

    method ah (
      Gnome::Gio::Application :$_widget, gulong :$_handler-id
    ) {
      $_widget.hold;
      isa-ok $_widget, Gnome::Gio::Application;
      $!signal-processed = True;
      $_widget.release;
    }

    method oh (
      CArray[N-GFile] $files, Int $n-files, Str $hint,
      Gnome::Gio::Application :$_widget, gulong :$_handler-id
    ) {
      $_widget.hold;
      isa-ok $_widget, Gnome::Gio::Application;
      is $n-files, 2, 'nbr files ok';
      my Str $path = Gnome::Gio::File.new(:native-object($files[0])).get-path;
      like $path, / 'abc.txt' /, "'$path' found";
      $!signal-processed = True;
      $_widget.release;
    }

    method signal-emitter ( Gnome::Gio::Application :$widget --> Str ) {

      while $main.gtk-events-pending() { $main.iteration-do(False); }

      $widget.activate;
      is $!signal-processed, True, '\'activate\' signal processed';

      while $main.gtk-events-pending() { $main.iteration-do(False); }

      $!signal-processed = False;
      $widget.open( [<abc.txt def.txt>], 'text');

      #is $!signal-processed, True, '\'...\' signal processed';
      #while $main.gtk-events-pending() { $main.iteration-do(False); }
      sleep(0.3);
      $main.gtk-main-quit;

      'done'
    }
  }

#  my Gnome::Gio::Application $a .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.container-add($m);

  my SignalHandlers $sh .= new;
  $a.register-signal( $sh, 'ah', 'activate');
  $a.register-signal( $sh, 'oh', 'open');

  my Promise $p = $a.start-thread(
    $sh, 'signal-emitter',
    # G_PRIORITY_DEFAULT,       # enable 'use Gnome::Glib::Main'
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}


#-------------------------------------------------------------------------------
done-testing;
