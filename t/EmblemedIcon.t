use v6;
use NativeCall;
use Test;

use Gnome::Gio::Emblem;
use Gnome::Gio::EmblemedIcon;
use Gnome::Gio::Icon;
use Gnome::Gio::File;
use Gnome::Gio::FileIcon;
use Gnome::Gio::Enums;

use Gnome::Glib::List;

ok 1, 'loads ok';

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::EmblemedIcon $ei;
my Gnome::Gio::Emblem $e;
my Gnome::Gio::File $f .= new(:path<LICENSE>);
my Gnome::Gio::FileIcon $fi;

#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $fi .= new(:file($f));
  $e .= new(:icon($fi), :origin(G_EMBLEM_ORIGIN_TAG));
  $ei .= new(:icon($fi), :emblem($e));
#note 'S: ', $ei.to-string;
  ok $ei.is-valid, '.new( :icon, :origin)';
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  my Str $eistring = $ei.to-string;
  my Gnome::Gio::EmblemedIcon $ei2 .= new(:string($eistring));
  ok $ei2.equal($ei), '.new(:string)';
#note 'S: ', $e2.to-string;

  $f .= new(:path<appveyor.yml>);
  my Gnome::Gio::FileIcon $fi2 .= new(:file($f));
  $e .= new(:icon($fi2), :origin(G_EMBLEM_ORIGIN_TAG));
  lives-ok {
    $ei2.add-emblem($e);
  }, '.add-emblem()';

  my Gnome::Glib::List $l = $ei2.get-emblems-rk;
  is $l.length, 2, '.get-emblems-rk()';
  $ei2.clear-emblems;
  $l = $ei2.get-emblems-rk;
  is $l.length, 0, '.clear-emblems()';

  $fi .= new(:file($f));
  $e .= new(:icon($fi), :origin(G_EMBLEM_ORIGIN_TAG));
  $ei .= new(:icon($fi), :emblem($e));

#  my Gnome::Gio::EmblemedIcon $ei3 = $ei.get-icon-rk;
#  $l = $ei3.get-emblems-rk;
#  is $l.length, 0, '.get-icon-rk()';
}

#-------------------------------------------------------------------------------
done-testing;

=finish

#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::EmblemedIcon', {
  class MyClass is Gnome::Gio::EmblemedIcon {
    method new ( |c ) {
      self.bless( :GEmblemedIcon, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::EmblemedIcon, 'MyClass.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::EmblemedIcon $ei .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $ei.get-property( $prop, $gv);
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

  # example calls
  #test-property( G_TYPE_BOOLEAN, 'homogeneous', 'get-boolean', False);
  #test-property( G_TYPE_STRING, 'label', 'get-string', '...');
  #test-property( G_TYPE_FLOAT, 'xalign', 'get-float', 23e-2, :approx);
}

#-------------------------------------------------------------------------------
subtest 'Themes ...', {
}

#-------------------------------------------------------------------------------
subtest 'Signals ...', {
  use Gnome::Gtk3::Main;
  use Gnome::N::GlibToRakuTypes;

  my Gnome::Gtk3::Main $main .= new;

  class SignalHandlers {
    has Bool $!signal-processed = False;

    method ... (
      'any-args',
      Gnome::Gio::EmblemedIcon :$_widget, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Gio::EmblemedIcon;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::EmblemedIcon :$widget --> Str ) {

      while $main.gtk-events-pending() { $main.iteration-do(False); }

      $widget.emit-by-name(
        'signal',
      #  'any-args',
      #  :return-type(int32),
      #  :parameters([int32,])
      );
      is $!signal-processed, True, '\'...\' signal processed';

      while $main.gtk-events-pending() { $main.iteration-do(False); }

      #$!signal-processed = False;
      #$widget.emit-by-name(
      #  'signal',
      #  'any-args',
      #  :return-type(int32),
      #  :parameters([int32,])
      #);
      #is $!signal-processed, True, '\'...\' signal processed';

      while $main.gtk-events-pending() { $main.iteration-do(False); }
      sleep(0.4);
      $main.gtk-main-quit;

      'done'
    }
  }

  my Gnome::Gio::EmblemedIcon $ei .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $ei.register-signal( $sh, 'method', 'signal');

  my Promise $p = $ei.start-thread(
    $sh, 'signal-emitter',
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
