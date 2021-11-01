use v6;
use NativeCall;
use Test;

use Gnome::Gio::Emblem;
use Gnome::Gio::Icon;
use Gnome::Gio::Enums;
use Gnome::Gio::File;
use Gnome::Gio::FileIcon;

use Gnome::GObject::Type;

ok 1, 'loads ok';

use Gnome::N::N-GObject;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::Emblem $e;
my Gnome::Gio::File $f .= new(:path<LICENSE>);
my Gnome::Gio::FileIcon $fi;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $fi .= new(:file($f));
  $e .= new(:icon($fi), :origin(G_EMBLEM_ORIGIN_TAG));
#note 'S: ', $e.to-string;
  isa-ok $e, Gnome::Gio::Emblem, '.new(:icon)';
}


#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  my Str $estring = $e.to-string;
  my Gnome::Gio::Emblem $e2 .= new(:string($estring));
  ok $e2.equal($e), '.new(:string)';
#note 'S: ', $e2.to-string;

  is $e2.get-icon-rk.to-string, $estring, '.get-icon-rk()';
  is $e2.get-origin, G_EMBLEM_ORIGIN_TAG, '.get-origin()';

#`{{ Experiment
  my Gnome::GObject::Type $type .= new;

  # check if $icon is of type GIcon
  my UInt $gtype = $type.from-name('GIcon');
  my N-GObject $icon = $e2.get-icon;
  note "is an icon: $gtype = ", $type.check-instance-is-a( $icon, $gtype);

  # check if $e2 is a GIcon
  note "emblem is an icon: $e2.get-class-gtype(), $gtype = ",
    $type.is-a( $e2.get-class-gtype, $gtype);

  # check if $emblem is of type GEmblem
  $gtype = $type.from-name('GEmblem');
  note "is an emblem: $gtype = ",
  ` $type.check-instance-is-a( $e2.get-native-object-no-reffing, $gtype);

  note $e2.^name;
}}
}

#-------------------------------------------------------------------------------
done-testing;

=finish


#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}

#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::Emblem', {
  class MyClass is Gnome::Gio::Emblem {
    method new ( |c ) {
      self.bless( :GEmblem, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::Emblem, 'MyClass.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::Emblem $e .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $e.get-property( $prop, $gv);
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
      Gnome::Gio::Emblem :$_widget, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Gio::Emblem;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::Emblem :$widget --> Str ) {

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

  my Gnome::Gio::Emblem $e .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $e.register-signal( $sh, 'method', 'signal');

  my Promise $p = $e.start-thread(
    $sh, 'signal-emitter',
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
