use v6;
use NativeCall;
use Test;

#use Gnome::N::N-GObject;
use Gnome::Glib::Variant;
use Gnome::Glib::VariantType;
use Gnome::Gio::SimpleAction;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::SimpleAction $sa;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $sa .= new(
    :name<new-action>,
    :parameter-type(Gnome::Glib::VariantType.new(:type-string<b>))
  );
  isa-ok $sa, Gnome::Gio::SimpleAction, '.new( :name, :parameter-type)';

  $sa .= new(
    :name<my-action>,
    :parameter-type(Gnome::Glib::VariantType.new(:type-string<i>)),
    :state(Gnome::Glib::Variant.new( :type-string<i>, :value(40)))
  );
  isa-ok $sa, Gnome::Gio::SimpleAction, '.new( :name, :parameter-type, :state)';
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {

  is $sa.get-name, 'my-action', '.get-name()';

  $sa.set-enabled(True);
  ok $sa.get-enabled, '.set-enabled() / .get-enabled()';

  $sa.set-state(Gnome::Glib::Variant.new( :type-string<i>, :value(41)));
  is $sa.get-state.get-type-string, 'i', '.get-state: type = i';
  is $sa.get-state.get-int32, 41, '.get-state: value = 41';

  my Array $array = [];
  for 40..50 -> $value {
    $array.push: Gnome::Glib::Variant.new( :type-string<i>, :$value);
  }
  my Gnome::Glib::Variant $v .= new(:$array);
  is $v.get-type-string, 'ai', '.new(:array)';
  $sa.set-state-hint($v);
  $v.clear-object;

  $v = $sa.get-state-hint;
  is $v.print(False), '[40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]',
    '.get-state-hint()';

  is $sa.get-parameter-type.dup-string, 'i', '.get-parameter-type()';
  is $sa.get-state-type.dup-string, 'i', '.get-state-type()';
  ok $sa.name-is-valid('abc-def'), '.name-is-valid()';

  my List $l = $sa.parse-detailed-name('app.action(42)');
  nok $l[2].is-valid, '.parse-detailed-name(): no error';
  is $l[0], 'app.action',  '.parse-detailed-name(): action name';
  is $l[1].get-int32, 42, '.parse-detailed-name(): target value';

  $l = $sa.parse-detailed-name('a pp action (42)');
#note $l[2].gist;
  ok $l[2].is-valid(), $l[2].message;
  is $sa.print-detailed-name(
    'app.action', Gnome::Glib::Variant.new( :type-string<i>, :value(55))
  ), 'app.action(55)', '.print-detailed-name()';
}

#`{{
##-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::SimpleAction', {
  class MyClass is Gnome::Gio::SimpleAction {
    method new ( |c ) {
      self.bless( :GSimpleAction, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::SimpleAction, '.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}
}}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::SimpleAction $sa .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $sa.get-property( $prop, $gv);
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

  test-property( G_TYPE_BOOLEAN, 'enabled', 'get-boolean', 1);
  test-property( G_TYPE_STRING, 'name', 'get-string', 'my-action');

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

#`{{ issue 1 in Gio; TODO change main from Gtk3 to that of Glib; circulat dependency
#-------------------------------------------------------------------------------
subtest 'Signals ...', {
  use Gnome::Gtk3::Main;
  use Gnome::N::GlibToRakuTypes;

  my Gnome::Gtk3::Main $main .= new;

  class SignalHandlers {
    has Bool $!signal-processed = False;

    method ah (
      N-GObject $parameter,
      Gnome::Gio::SimpleAction :$_widget, gulong :$_handler-id
    ) {
      my Gnome::Glib::Variant $v .= new(:native-object($parameter));
      is $v.print(False), '43', 'activation parameter ok';
      isa-ok $_widget, Gnome::Gio::SimpleAction;
      $!signal-processed = True;
    }

    method ch (
      N-GObject $value,
      Gnome::Gio::SimpleAction :$_widget, gulong :$_handler-id
    ) {
      my Gnome::Glib::Variant $v .= new(:native-object($value));
      is $v.print(False), '49', 'activation parameter ok';
      isa-ok $_widget, Gnome::Gio::SimpleAction;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::SimpleAction :$widget --> Str ) {

      while $main.gtk-events-pending() { $main.iteration-do(False); }

      $sa.activate(Gnome::Glib::Variant.new( :type-string<i>, :value(43)));
      is $!signal-processed, True, '\'activate\' signal processed';

      while $main.gtk-events-pending() { $main.iteration-do(False); }

      $!signal-processed = False;
      $sa.change-state(Gnome::Glib::Variant.new( :type-string<i>, :value(49)));
      is $!signal-processed, True, '\'change-state\' signal processed';

      while $main.gtk-events-pending() { $main.iteration-do(False); }
      sleep(0.4);
      $main.gtk-main-quit;

      'done'
    }
  }

#  my Gnome::Gio::SimpleAction $sa .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $sa.register-signal( $sh, 'ah', 'activate');
  $sa.register-signal( $sh, 'ch', 'change-state');

  my Promise $p = $sa.start-thread(
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
}}

#-------------------------------------------------------------------------------
done-testing;
