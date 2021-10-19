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
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $f .= new(:uri<https://developer.gnome.org/gio/2.62/GFile.html>);
  is $f.get-basename, 'GFile.html', '.get-basename()';
  is $f.get-path, Str, '.get-path() no path for uri';
  is $f.get-uri, 'https://developer.gnome.org/gio/2.62/GFile.html',
     '.get-uri()';
  is $f.is-native, False, '.is-native()';
#  is $f.has-uri-scheme('ftp'), 0, '.has-uri-scheme() no ftp';
#  is $f.has-uri-scheme('http'), 1, '.has-uri-scheme() has http';
#  is $f.get-uri-scheme, 'http', '.get-uri-scheme()';
  $f.clear-object;

  $f .= new(:path<t/data/g-resources/rtest>);
  like $f.get-path,
    / t <[/\\]> data <[/\\]> g\-resources <[/\\]> rtest $/, '.get-path()';
  $f.clear-object;
}


#-------------------------------------------------------------------------------
done-testing;

=finish

#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::File', {
  class MyClass is Gnome::Gio::File {
    method new ( |c ) {
      self.bless( :GFile, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::File, 'MyClass.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::File $f .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $f.get-property( $prop, $gv);
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
      Gnome::Gio::File :$_widget, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Gio::File;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::File :$widget --> Str ) {

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

  my Gnome::Gio::File $f .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $f.register-signal( $sh, 'method', 'signal');

  my Promise $p = $f.start-thread(
    $sh, 'signal-emitter',
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
