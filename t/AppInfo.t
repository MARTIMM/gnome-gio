use v6;
use NativeCall;
use Test;

use Gnome::Gio::AppInfo;
use Gnome::Gio::AppLaunchContext;

use Gnome::Glib::Error;
use Gnome::Glib::List;

use Gnome::N::N-GObject;
#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::Error $e;
my Gnome::Gio::AppInfo $ai;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $ai .= new( :command-line('x'), :application-name('x'));
  isa-ok $ai, Gnome::Gio::AppInfo,
    '.new(:command-line, :application-name, :flags)';
  nok $ai.last-error.is-valid, 'no error';
}

#-------------------------------------------------------------------------------
# stop when on windows. rest is depending on linux
unless $*KERNEL.name ~~ 'linux' {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $ai .= new( :command-line('ls -m'), :application-name('ls'));
  is $ai.get-commandline, 'ls -m %f', '.get-commandline()';

  subtest 'app info list', {
    my Gnome::Glib::List $list = $ai.get-all;
    ok $list.length > 1, '.get-all()';
    my Gnome::Gio::AppInfo $ai3 .= new(
      :native-object(nativecast( N-GObject, $list.nth-data(0)))
    );
    diag $ai3.get-commandline;
  }

#  my Gnome::Gio::AppLaunchContext $alc .= new;
  $e = $ai.launch( [ 'LICENSE', 'appveyor.yml' ], N-GObject);
  nok $ai.last-error.is-valid, '.launch()';

  $e = $ai.set-as-default-for-type('image/jpeg');
#note $e.raku;
  nok $ai.last-error.is-valid, '.set-as-default-for-type()';

  my Gnome::Gio::AppInfo $ai2 = $ai.get-default-for-type-rk(
    'image/jpeg', True
  );
  is $ai2.get-commandline, 'gwenview %U',
    '.set-as-default-for-type() / get-default-for-type-rk';

  $e = $ai2.launch-default-for-uri( 'LICENSE', N-GObject);
#note $e.raku;
  nok $ai.last-error.is-valid, '.launch-default-for-uri()';
}

#-------------------------------------------------------------------------------
done-testing;

=finish


#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::AppInfo', {
  class MyClass is Gnome::Gio::AppInfo {
    method new ( |c ) {
      self.bless( :GAppInfo, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::AppInfo, 'MyClass.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::AppInfo $ai .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $ai.get-property( $prop, $gv);
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
      Gnome::Gio::AppInfo :$_widget, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Gio::AppInfo;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::AppInfo :$widget --> Str ) {

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

  my Gnome::Gio::AppInfo $ai .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $ai.register-signal( $sh, 'method', 'signal');

  my Promise $p = $ai.start-thread(
    $sh, 'signal-emitter',
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
