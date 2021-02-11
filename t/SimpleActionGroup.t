use v6;
use NativeCall;
use Test;

use Gnome::Gio::SimpleActionGroup;
use Gnome::Gio::SimpleAction;

use Gnome::Glib::VariantType;
use Gnome::Glib::N-GVariant;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gio::SimpleActionGroup $sag;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $sag .= new;
  isa-ok $sag, Gnome::Gio::SimpleActionGroup, '.new()';
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {

  my Gnome::Gio::SimpleAction $sa .= new(
    :name<new-action>,
    :parameter-type(Gnome::Glib::VariantType.new(:type-string<i>))
  );
#  $sa.set-action-enabled(True);
#  ok $sa.get-action-enabled, 'action enabled';

  # through actionmap interface
  $sag.add-action($sa);
  ok $sa.is-valid, ".add-action(); 'new-action' added";

#  $sag.activate-action( 'new-action', Gnome::Glib::Variant.new(:parse<40>));

  $sag.add-action-entries( [ {
        :name<MyActionTest1>,
        :parameter-type<i>
      }, {
        :name<MyActionTest2>,
        :parameter-type<x>,
        :state('int64 55')
      }
    ]
  );

  is-deeply $sag.list-actions.sort,
     <new-action MyActionTest1 MyActionTest2>.sort,
     '.list-actions()';

  ok $sag.has-action('MyActionTest2'), '.has-action(): MyActionTest2 exists';
  nok $sag.has-action('MyActionTest10'),
    '.has-action(): MyActionTest10 not existant';

  my ( $enabled, $ptype, $stype, $shint, $state) =
    $sag.query-action('MyActionTest2');
#note "$enabled, $ptype.gist(), $stype.gist(), $shint.gist(), $state.gist()";

  is $enabled, $sag.get-action-enabled('MyActionTest2'),
    '.query-action(): .get-action-enabled()';

  is $ptype.dup-string,
    $sag.get-action-parameter-type('MyActionTest2').dup-string,
    '.query-action(): .get-action-parameter-type()';

  is $state.get-int64, $sag.get-action-state('MyActionTest2').get-int64,
    '.query-action(): .get-action-state()';

  is !$shint.is-valid, !$sag.get-action-state-hint('MyActionTest2').is-valid,
    '.query-action(): .get-action-state-hint()';

  is $stype.dup-string,
    $sag.get-action-state-type('MyActionTest2').dup-string,
    '.query-action(): .get-action-state-type()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::SimpleActionGroup', {
  class MyClass is Gnome::Gio::SimpleActionGroup {
    method new ( |c ) {
      self.bless( :GSimpleActionGroup, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::SimpleActionGroup, '.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Gio::SimpleActionGroup $sag .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $sag.get-property( $prop, $gv);
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
}}

#`{{ issue 1 in Gio; TODO change main from Gtk3 to that of Glib; circulat dependency
#-------------------------------------------------------------------------------
subtest 'Signals ...', {
#Gnome::N::debug(:on);
  use Gnome::Gtk3::Main;
  use Gnome::N::GlibToRakuTypes;

  my Gnome::Gtk3::Main $main .= new;

  class SignalHandlers {
    has Bool $!signal-processed = False;

    method a-added (
      Str $name,
      Gnome::Gio::SimpleActionGroup :$_widget, gulong :$_handler-id
    ) {
      ok $name ~~ any(<MyActionTest11 MyActionTest12>), "action name $name ok";
      isa-ok $_widget, Gnome::Gio::SimpleActionGroup;
      $!signal-processed = True;
    }

    method action-activate (
      N-GVariant $parameter,
      Gnome::Gio::SimpleAction :$_widget, gulong :$_handler-id
    ) {
      my Gnome::Glib::Variant $v .= new(:native-object($parameter));
      is $v.print(False), '43', 'activation parameter ok';
      isa-ok $_widget, Gnome::Gio::SimpleAction;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::SimpleActionGroup :$widget --> Str ) {
      while $main.gtk-events-pending() { $main.iteration-do(False); }

      $sag.action-added('MyActionTest12');

#      $widget.emit-by-name(
#        'action-added',
#        'MyActionTest11',
#      #  :return-type(int32),
#        :parameters([Str,])
#      );
      is $!signal-processed, True, '\'action-added\' signal processed';

      while $main.gtk-events-pending() { $main.iteration-do(False); }

      $!signal-processed = False;
      my Gnome::Gio::SimpleAction $sa = $sag.lookup-action('MyActionTest11');
      $sa.activate(Gnome::Glib::Variant.new( :type-string<i>, :value(43)));
      is $!signal-processed, True, '\'activate\' action processed';


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

#  my Gnome::Gio::SimpleActionGroup $sag .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.container-add($m);

  my SignalHandlers $sh .= new;
  $sag.register-signal( $sh, 'a-added', 'action-added', :a1<a1>);

  $sag.add-action-entries( [ {
        :name<MyActionTest11>,
        :activate-handler-object($sh),
        :activate<action-activate>,
        :parameter-type<i>
      },
    ]
  );

  my Promise $p = $sag.start-thread(
    $sh, 'signal-emitter',
    # G_PRIORITY_DEFAULT,       # enable 'use Gnome::Glib::Main'
    # :!new-context,
    # :start-time(now + 1)
  );

#  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
}}

#-------------------------------------------------------------------------------
done-testing;
