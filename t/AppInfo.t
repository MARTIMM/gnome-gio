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
my Gnome::Gio::AppInfo $ai2;
#my Gnome::Gio::AppLaunchContext $alc .= new;

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
  nok $ai.can-delete, '.can-delete()';
  nok $ai.delete, '.delete()';


  # this will set the file type options of a yaml file. after this
  # ls will show in the list of possible programs for this file type.
  ok $ai.add-supports-type('text/x-yaml'), '.add-supports-type()';

  # works, but starts my filebrowser
  #ok $ai.launch-default-for-uri( 'file:///tmp', N-GObject),
  #   '.launch-default-for-uri()';
ok $ai.launch-default-for-uri( 'file:///no-dir', N-GObject),
note $ai.last-error.message;

  $ai2 = $ai.get-default-for-uri-scheme-rk('http');
  diag $ai2.get-commandline;

  ok $ai.set-as-last-used-for-type('text/x-yaml'),
     '.set-as-last-used-for-type()';

  subtest 'app info lists', {
    my Gnome::Glib::List $list = $ai.get-all;
    ok $list.length > 1, '.get-all()';
    my Gnome::Gio::AppInfo $ai3 .= new(
      :native-object(nativecast( N-GObject, $list.nth-data(0)))
    );
    diag (
      "  " ~ $ai3.get-name, $ai3.get-display-name, $ai3.get-id,
      $ai3.get-description, $ai3.get-commandline, $ai3.get-executable
    ).join("\n  ");
    $list.clear-object; #TODO no items cleared

    $list = $ai.get-all-for-type('text/x-yaml');
    ok $list.length > 1, '.get-all-for-type()';
    $ai3 .= new( :native-object(nativecast( N-GObject, $list.nth-data(0))));
    diag (
      "  " ~ $ai3.get-name, $ai3.get-display-name, $ai3.get-id,
      $ai3.get-description, $ai3.get-commandline, $ai3.get-executable
    ).join("\n  ");
    $list.clear-object;

    # no fallback for this type
    $list = $ai.get-fallback-for-type('text/plain');
    ok $list.length == 0, '.get-fallback-for-type()';

    $list = $ai.get-fallback-for-type('text/html');
    ok $list.length > 1, '.get-fallback-for-type()';
    $ai3 .= new( :native-object(nativecast( N-GObject, $list.nth-data(0))));
    diag (
      "  " ~ $ai3.get-name, $ai3.get-display-name, $ai3.get-id,
      $ai3.get-description, $ai3.get-commandline, $ai3.get-executable
    ).join("\n  ");
    $list.clear-object;

    $list = $ai.get-recommended-for-type('text/html');
    ok $list.length > 1, '.get-recommended-for-type()';
    $ai3 .= new( :native-object(nativecast( N-GObject, $list.nth-data(0))));
    diag (
      "  " ~ $ai3.get-name, $ai3.get-display-name, $ai3.get-id,
      $ai3.get-description, $ai3.get-commandline, $ai3.get-executable
    ).join("\n  ");
    $list.clear-object;

    ok $ai3.get-supported-types.elems > 1, '.get-supported-types()';
  }

  # remove it from the list
  ok $ai.can-remove-supports-type, '.can-remove-supports-type()';
  ok $ai.remove-supports-type('text/x-yaml'), '.remove-supports-type()';

#  my Gnome::Gio::AppLaunchContext $alc .= new;
  ok $ai.launch( [ 'LICENSE', 'appveyor.yml' ], N-GObject), '.launch()';

  # this will set the file type options of a jpeg image. after this
  # ls will run instead of gwenview (or other image viewer).
  ok $ai.set-as-default-for-type('image/jpeg'), '.set-as-default-for-type()';
  ok $ai.set-as-default-for-extension('jpg'), '.set-as-default-for-extension()';
#note $e.raku;

  $ai2 = $ai.get-default-for-type-rk( 'image/jpeg', True);
  is $ai2.get-commandline, 'gwenview %U', '.get-default-for-type-rk';

  # remove previous set default associations
  $ai.reset-type-associations('image/jpeg');
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
