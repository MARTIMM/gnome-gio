use v6;
use NativeCall;
use Test;

use Gnome::Glib::Error;

use Gnome::Gio::Enums;
use Gnome::Gio::Resource;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::Resource $r;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  dies-ok(
    { $r .= new(:load<non-existent.gresource>); },
    'Failed to open file'
  );

  $r .= new(:load<t/data/g-resources/rtest.gresource>);
  ok $r.is-valid, 'valid resource';
  isa-ok $r, Gnome::Gio::Resource, '.new(:load)';
}

unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  ok 1, $r.register // '.register()';
  ok 1, $r.unregister // '.unregister()';

  my Gnome::Glib::Error $e;
  my Array $a;
  ( $e, $a) = $r.enumerate-children('/io/gith ub/martimm/rtest');
  ok $e.is-valid, $e.message;
  is $e.domain, $r.error-quark, '.error-quark()';
  is GResourceError($e.code), G_RESOURCE_ERROR_NOT_FOUND, 'G_RESOURCE_ERROR_NOT_FOUND';
  ( $e, $a) = $r.enumerate-children(
    '/io/github/martimm/rtest/t/data/g-resources/'
  );
  nok $e.is-valid, '.enumerate-children()';

  #TODO no children....
  my @parts = 'io/github/martimm/rtest/t/data/g-resources'.split('/');
  my $path = '/';
  for @parts -> $p {
    $path ~= "$p/";
    ( $e, $a) = $r.enumerate-children($path);
    diag "Path: $path, $e.is-valid(), $a.gist()";
  }
}

#-------------------------------------------------------------------------------
done-testing;

=finish



#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::Resource', {
  class MyClass is Gnome::Gio::Resource {
    method new ( |c ) {
      self.bless( :GResource, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::Resource, '.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::Resource $r .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $r.get-property( $prop, $gv);
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
  #test-property( G_TYPE_BOOLEAN, 'homogeneous', 'get-boolean', 0);
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
      Gnome::Gio::Resource :$_widget, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Gio::Resource;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::Resource :$widget --> Str ) {

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

  my Gnome::Gio::Resource $r .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $r.register-signal( $sh, 'method', 'signal');

  my Promise $p = $r.start-thread(
    $sh, 'signal-emitter',
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
