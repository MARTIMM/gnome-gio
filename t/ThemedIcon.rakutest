use v6;
use NativeCall;
use Test;

use Gnome::Gio::ThemedIcon;
#use Gnome::Gio::Enums;
#use Gnome::Gio::File;
#use Gnome::Gio::FileIcon;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::ThemedIcon $ti;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $ti .= new(:iconname<accept-signal>);
  ok $ti.is-valid, '.new(:iconname)';

  $ti .= new(:iconnames(<accept-signal adjustlevels>));
  ok $ti.is-valid, '.new(:iconnames)';
}


#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  my Str $tistring = $ti.to-string;
  my Gnome::Gio::ThemedIcon $ti2 .= new(:string($tistring));
  ok $ti2.equal($ti), '.new(:string)';

  $ti.append-name('adjustcurves');
  $ti.prepend-name('adjustrgb');
  is $ti.get-names[0..1], [<adjustrgb accept-signal>],
   '.append-name() / .prepend-name() / .get-names()';

  my @names = < gnome-dev-cdrom-audio gnome-dev-cdrom gnome-dev gnome >;
  my Gnome::Gio::ThemedIcon ( $icon1, $icon2);
  $icon1 .= new(:iconnames(@names));
  $icon2 .= new(:fallbacks<gnome-dev-cdrom-audio>);
  is $icon1.get-names, $icon2.get-names, '.new(:fallbacks)';
}

#-------------------------------------------------------------------------------
done-testing;

=finish

#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::ThemedIcon', {
  class MyClass is Gnome::Gio::ThemedIcon {
    method new ( |c ) {
      self.bless( :GThemedIcon, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::ThemedIcon, 'MyClass.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::ThemedIcon $ti .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $ti.get-property( $prop, $gv);
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
      Gnome::Gio::ThemedIcon() :$_native-object, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Gio::ThemedIcon;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::ThemedIcon :$widget --> Str ) {

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

  my Gnome::Gio::ThemedIcon $ti .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $ti.register-signal( $sh, 'method', 'signal');

  my Promise $p = $ti.start-thread(
    $sh, 'signal-emitter',
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
