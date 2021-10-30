use v6;
use NativeCall;
use Test;

use Gnome::Gio::File;
use Gnome::Gio::FileIcon;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::File $f .= new(:path<LICENSE>);
my Gnome::Gio::FileIcon $fi;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $fi .= new(:file($f));
  isa-ok $fi, Gnome::Gio::FileIcon, '.new(:file)';
}


#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  like my $fstring = $fi.to-string, / 'LICENSE' /, '.to-string()';

  my Gnome::Gio::FileIcon $fi2 .= new(:string($fstring));
  ok $fi2.equal($fi), '.new(:string)';

  is $fi.get-file-rk.get-basename, 'LICENSE', '.get-file-rk()';
}

#`{{ N-GFile not supported
#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  my @r = $fi.get-properties( 'file', N-GFile);
  my Gnome::Gio::File $f .= new(:native-object(@r[0]));
  is $f.get-basename, 'LICENSE', 'file';
}
}}

#-------------------------------------------------------------------------------
done-testing;

=finish

#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::FileIcon', {
  class MyClass is Gnome::Gio::FileIcon {
    method new ( |c ) {
      self.bless( :GFileIcon, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::FileIcon, 'MyClass.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::FileIcon $fi .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $fi.get-property( $prop, $gv);
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
      Gnome::Gio::FileIcon :$_widget, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Gio::FileIcon;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::FileIcon :$widget --> Str ) {

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

  my Gnome::Gio::FileIcon $fi .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $fi.register-signal( $sh, 'method', 'signal');

  my Promise $p = $fi.start-thread(
    $sh, 'signal-emitter',
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
