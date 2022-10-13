use v6;
use NativeCall;
use Test;

use Gnome::Glib::Variant;

use Gnome::Gio::MenuModel;
use Gnome::Gio::Menu;
use Gnome::Gio::MenuItem;
use Gnome::Gio::MenuLinkIter;

#use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;
#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
subtest 'ISA test', {
  my Gnome::Gio::Menu $m .= new;
  isa-ok $m, Gnome::Gio::Menu, '.new()';
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
# See also https://developer.gnome.org/GMenu/
subtest 'Manipulations', {

#`{{
<interface>
  <menu id="view-menu">
    <section>
      <item>
        <attribute name="label">Toolbar</attribute>
        <attribute name="action">app.set-toolbar</attribute>
      </item>
      <item>
        <attribute name="label">Statusbar</attribute>
        <attribute name="action">app.set-statusbar</attribute>
      </item>
    </section>
    <section>
      <item>
        <attribute name="label">Fullscreen</attribute>
        <attribute name="action">app.set-fullscreen</attribute>
      </item>
    </section>
    <section>
      <attribute name="label">Highlight Mode</attribute>
      <submenu>
        <section>
          <attribute name="label">Sources</attribute>
          <item>
            <attribute name="label">Vala</attribute>
            <attribute name="action">app.select-vala</attribute>
          </item>
          <item>
            <attribute name="label">Python</attribute>
            <attribute name="action">app.select-python</attribute>
          </item>
        </section>
        <section>
          <attribute name="label">Markup</attribute>
          <item>
            <attribute name="label">asciidoc</attribute>
            <attribute name="action">app.select-asciidoc</attribute>
          </item>
          <item>
            <attribute name="label">HTML</attribute>
            <attribute name="action">app.select-html</attribute>
          </item>
        </section>
      </submenu>
    </section>
  </menu>
</interface>
}}

  my Gnome::Gio::Menu $menu;
  my Gnome::Gio::Menu $section;
  my Gnome::Gio::Menu $submenu;

  # Make a section menu with 2 items in it; Toolbar and Statusbar
  $section .= new;
  # 1st method to add an item
  $section.append-item(
    Gnome::Gio::MenuItem.new( :label<Toolbar>, :action<app.set-toolbar>)
  );
  # 2nd method to add an item
  $section.append( 'Statusbar', 'app.set-statusbar');
  is $section.get-n-items, 2, '.get-n-items() / .append-item() / Gnome::Gio::MenuItem.new(:label,:action)';
  ok $section.is-mutable, '.is-mutable()';

  # make the top menu and append 1st section made above
  $menu .= new;
  # 1st method to add a section
  $menu.append-item(Gnome::Gio::MenuItem.new(:section($section)));
  $section.clear-object;
  is $menu.get-n-items, 1, '$menu.append-item()';

  # 2nd section menu with only one item; Fullscreen
  $section .= new;
  $section.append( 'Fullscreen', 'app.set-fullscreen');
  is $section.get-n-items, 1, '.append()';
  # 2nd method to add a section
  $menu.append-section( Str, $section);
  $section.clear-object;
  is $menu.get-n-items, 2, '$menu.append-section()';

  # Now to create a submenu, start with a section menu within
  # (check/radio entries later)
  # 1st section with 2 items; Vala and Python
  $section .= new;
  $section.append( 'Vala', 'app.select-vala');
  $section.append( 'Python', 'app.select-python');

  # Add to submenu and give section a name
  $submenu .= new;
  $submenu.insert-section( 1, 'Sources', $section);
  $section.clear-object;
  is $submenu.get-n-items, 1, '$submenu.insert-section()';

  # 2st section with 2 items; asciidoc and HTML
  $section .= new;
  $section.append( 'asciidoc', 'app.select-asciidoc');
  #$section.append( 'HTML', 'app.select-html');
  $section.insert-item(
    1, Gnome::Gio::MenuItem.new( :label<HTML>, :action<app.select-html>)
  );
  is $section.get-n-items, 2, '$section.insert-item()';

  # Add to submenu and give section a name
  $submenu.append-section( 'Markup', $section);
  $section.clear-object;
  is $submenu.get-n-items, 2, '$submenu.append-section()';

  $menu.append-submenu( 'Highlight Mode', $submenu);
  $submenu.clear-object;
  is $menu.get-n-items, 3, '$menu.append-submenu()';





  $menu.freeze;
  nok $menu.is-mutable, '.freeze()';


#`{{

  my Gnome::Gio::Menu $section .= new;
  $section.append( 'Incendio', 'app.incendio');

  my Gnome::Gio::Menu $menu .= new;
  $menu.append-section( 'Offensive Spells', $section);
  $section.clear-object;

  $section .= new;
  my Gnome::Gio::MenuItem $item .= new(
    :label<Expelliarmus>, :action<app.expelliarmus>
  );
  #$item.set-icon(defensive_icon);
  $section.append-item($item);
#  $item.clear-object;
  $menu.append-section( 'Defensive Charms', $section);
  $section.clear-object;



  my Gnome::Gio::Menu $submenu .= new;
  $submenu.append( 'foo', 'app.foo');

  $menu.append-submenu( 'foo-menu', $submenu);
  $submenu.clear-object;

  $section .= new;
  $item .= new( :label<Foo-1>, :action<app.foo-1>);
  #$item.set-icon(defensive_icon);
  $section.append-item($item);
#  $item.clear-object;


  is $menu.get-n-items, 3, '.get-n-items()';
  ok $menu.is-mutable, '.is-mutable()';

  my Gnome::Gio::MenuLinkIter $l-iter = $menu.iterate-item-links(0);
  ok $l-iter.is-valid(), '.iterate-item-links()';
  ok $l-iter.next, 'MenuLinkIter.next()';
  is $l-iter.get-name, G_MENU_LINK_SECTION, 'MenuLinkIter.get-name()';
  $section = Gnome::Gio::Menu.new(:native-object($l-iter.get-value));
  is $section.get-n-items, 1, 'MenuLinkIter.get-value()';
#  is $nxt-lnk.get-name, G_MENU_LINK_SUBMENU, '.get-name()';

  ok $l-iter.next, 'MenuLinkIter.next()';
  is $l-iter.get-name, G_MENU_LINK_SECTION, 'MenuLinkIter.get-name()';


  my ( $n, $no) = $l-iter.get-next;
  is $n, G_MENU_LINK_SUBMENU, 'MenuLinkIter.get-next() name';

#  my Gnome::Glib::Variant $v = $l-iter.get-attribute-value( 'label', 's');
#  is $v.get-string, 'Incendio', '.get-attribute-value()';
  $l-iter.clear-object;
}}
}

#-------------------------------------------------------------------------------
done-testing;

=finish


#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Gio::Menu', {
  class MyClass is Gnome::Gio::Menu {
    method new ( |c ) {
      self.bless( :GMenu, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Gio::Menu, '.new()';
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
      Gnome::Gio::Menu() :$_native-object, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Gio::Menu;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Gio::Menu :$widget --> Str ) {

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

  my Gnome::Gio::Menu $m .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $m.register-signal( $sh, 'method', 'signal');

  my Promise $p = $m.start-thread(
    $sh, 'signal-emitter',
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
