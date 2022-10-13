#TL:1:Gnome::Gio::Menu:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Menu

A simple implementation of N-GObject

=comment ![](images/X.png)


=head1 Description

B<Gnome::Gio::Menu> is a simple implementation of B<Gnome::Gio::MenuModel>. You populate a B<Gnome::Gio::Menu> by adding B<Gnome::Gio::MenuItem> instances to it.

There are some convenience functions to allow you to directly add items (avoiding B<Gnome::Gio::MenuItem>) for the common cases. To add a regular item, use C<insert()>. To add a section, use C<insert-section()>. To add a submenu, use C<insert-submenu()>.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::Menu;
  also is Gnome::Gio::MenuModel;


=head2 Uml Diagram

![](plantuml/MenuModel.svg)


=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::Menu;

  unit class MyGuiClass;
  also is Gnome::Gio::Menu;

  submethod new ( |c ) {
    # let the Gnome::Gio::Menu class process the options
    self.bless( :N-GObject, |c);
  }

  submethod BUILD ( ... ) {
    ...
  }

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

#use Gnome::GObject::Object;
use Gnome::Gio::MenuModel;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::Menu:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::Gio::MenuModel;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 default, no options

Create a new Menu object.

  multi method new ( )

=head3 :native-object

Create a Menu object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=head3 :build-id

Create a Menu object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

#TM:0:new():inheriting
#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
#TM:4:new(:build-id):Gnome::GObject::Object

submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::Menu' or %options<GMenu> {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists or %options<widget>:exists { }
    elsif %options<build-id>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<___x___> {
        #$no = %options<___x___>;
        #$no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        #$no = _g_menu_new___x___($no);
      }

      #`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
      }}

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      ##`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _g_menu_new();
      }
      #}}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMenu');

  }
}


#-------------------------------------------------------------------------------
#TM:1:append:
=begin pod
=head2 append

Convenience function for appending a normal menu item to the end of I<menu>.  Combine C<Gnome::Gio::MenuItem.new()> and C<insert-item()> for a more flexible alternative.

  method append ( Str $label, Str $detailed_action )

=item Str $label; the section label, or C<undefined>
=item Str $detailed_action;the detailed action string, or C<undefined>

=end pod

method append ( Str $label, Str $detailed_action ) {

  g_menu_append(
    self._get-native-object-no-reffing, $label, $detailed_action
  );
}

sub g_menu_append ( N-GObject $menu, gchar-ptr $label, gchar-ptr $detailed_action  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:append-item:
=begin pod
=head2 append-item

Appends I<$item> to the end of I<menu>. See C<insert-item()> for more information.

  method append-item ( N-GObject $item )

=item N-GObject $item; a B<Gnome::Gio::MenuItem> to append

=end pod

method append-item ( $item is copy ) {
  $item .= _get-native-object-no-reffing unless $item ~~ N-GObject;

  g_menu_append_item( self._get-native-object-no-reffing, $item);
}

sub g_menu_append_item ( N-GObject $menu, N-GObject $item  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:append-section:
=begin pod
=head2 append-section

Convenience function for appending a section menu item to the end of I<menu>.  Combine C<Gnome::Gio::MenuItem(:section)> and C<insert-item()> for a more flexible alternative.

  method append-section ( Str $label, N-GObject $section )

=item Str $label; the section label, or C<undefined>
=item N-GObject $section; a B<Gnome::Gio::MenuModel> with the items of the section

=end pod

method append-section ( Str $label, $section is copy ) {
  $section .= _get-native-object-no-reffing unless $section ~~ N-GObject;

  g_menu_append_section(
    self._get-native-object-no-reffing, $label, $section
  );
}

sub g_menu_append_section (
  N-GObject $menu, gchar-ptr $label, N-GObject $section
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:append-submenu:
=begin pod
=head2 append-submenu

Convenience function for appending a submenu menu item to the end of I<menu>.  Combine C<Gnome::Gio::MenuItem(:submenu)> and C<insert-item()> for a more flexible alternative.

  method append-submenu ( Str $label, N-GObject $submenu )

=item Str $label; (nullable): the section label, or C<undefined>
=item N-GObject $submenu; a B<Gnome::Gio::MenuModel> with the items of the submenu

=end pod

method append-submenu ( Str $label, $submenu is copy ) {
  $submenu .= _get-native-object-no-reffing unless $submenu ~~ N-GObject;

  g_menu_append_submenu(
    self._get-native-object-no-reffing, $label, $submenu
  );
}

sub g_menu_append_submenu ( N-GObject $menu, gchar-ptr $label, N-GObject $submenu  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:freeze:
=begin pod
=head2 freeze

Marks I<menu> as frozen.

After the menu is frozen, it is an error to attempt to make any changes to it.  In effect this means that the B<Gnome::Gio::Menu> API must no longer be used.

This function causes C<model-is-mutable()> to begin returning C<False>, which has some positive performance implications.

  method freeze ( )

=end pod

method freeze ( ) {
  g_menu_freeze( self._get-native-object-no-reffing);
}

sub g_menu_freeze ( N-GObject $menu )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:insert:
=begin pod
=head2 insert

Convenience function for inserting a normal menu item into I<menu>. Combine C<Gnome::Gio::MenuItem.new()> and C<insert-item()> for a more flexible alternative.

  method insert ( Int $position, Str $label, Str $detailed_action )

=item Int $position; the position at which to insert the item
=item Str $label; the section label, or C<undefined>
=item Str $detailed_action; the detailed action string, or C<undefined>

=end pod

method insert ( Int $position, Str $label, Str $detailed_action ) {

  g_menu_insert(
    self._get-native-object-no-reffing, $position, $label, $detailed_action
  );
}

sub g_menu_insert ( N-GObject $menu, gint $position, gchar-ptr $label, gchar-ptr $detailed_action  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:insert-item:
=begin pod
=head2 insert-item

Inserts I<$item> into I<menu>.

The "insertion" is actually done by copying all of the attribute and link values of I<item> and using them to form a new item within I<menu>. As such, I<item> itself is not really inserted, but rather, a menu item that is exactly the same as the one presently described by I<item>.

This means that I<item> is essentially useless after the insertion occurs.  Any changes you make to it are ignored unless it is inserted again (at which point its updated values will be copied).

You should probably just free I<item> once you're done.

There are many convenience functions to take care of common cases. See C<insert()>, C<insert-section()> and C<insert-submenu()> as well as "prepend" and "append" variants of each of these functions.

  method insert-item ( Int $position, N-GObject $item )

=item Int $position; the position at which to insert the item
=item N-GObject $item; the B<Gnome::Gio::MenuItem> to insert

=end pod

method insert-item ( Int $position, $item is copy ) {
  $item .= _get-native-object-no-reffing unless $item ~~ N-GObject;

  g_menu_insert_item(
    self._get-native-object-no-reffing, $position, $item
  );
}

sub g_menu_insert_item ( N-GObject $menu, gint $position, N-GObject $item  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:insert-section:
=begin pod
=head2 insert-section

Convenience function for inserting a section menu item into I<menu>. Combine C<Gnome::Gio::MenuItem.new(:section)> and C<insert-item()> for a more flexible alternative.

  method insert-section ( Int $position, Str $label, N-GObject $section )

=item Int $position; the position at which to insert the item
=item Str $label; the section label, or C<undefined>
=item N-GObject $section; a B<Gnome::Gio::MenuModel> with the items of the section

=end pod

method insert-section ( Int $position, Str $label, $section is copy ) {
  $section .= _get-native-object-no-reffing unless $section ~~ N-GObject;

  g_menu_insert_section(
    self._get-native-object-no-reffing, $position, $label, $section
  );
}

sub g_menu_insert_section ( N-GObject $menu, gint $position, gchar-ptr $label, N-GObject $section  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:insert-submenu:
=begin pod
=head2 insert-submenu

Convenience function for inserting a submenu menu item into I<menu>. Combine C<Gnome::Gio::MenuItem.new(:submenu)> and C<insert-item()> for a more flexible alternative.

  method insert-submenu ( Int $position, Str $label, N-GObject $submenu )

=item Int $position; the position at which to insert the item
=item Str $label; the section label, or C<undefined>
=item N-GObject $submenu; a B<Gnome::Gio::MenuModel> with the items of the submenu

=end pod

method insert-submenu ( Int $position, Str $label, $submenu is copy ) {
  $submenu .= _get-native-object-no-reffing unless $submenu ~~ N-GObject;

  g_menu_insert_submenu(
    self._get-native-object-no-reffing, $position, $label, $submenu
  );
}

sub g_menu_insert_submenu ( N-GObject $menu, gint $position, gchar-ptr $label, N-GObject $submenu  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:prepend:
=begin pod
=head2 prepend

Convenience function for prepending a normal menu item to the start of I<menu>.  Combine C<Gnome::Gio::MenuItem.new()> and C<insert-item()> for a more flexible alternative.

  method prepend ( Str $label, Str $detailed_action )

=item Str $label; the section label, or C<undefined>
=item Str $detailed_action; the detailed action string, or C<undefined>

=end pod

method prepend ( Str $label, Str $detailed_action ) {

  g_menu_prepend(
    self._get-native-object-no-reffing, $label, $detailed_action
  );
}

sub g_menu_prepend ( N-GObject $menu, gchar-ptr $label, gchar-ptr $detailed_action  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:prepend-item:
=begin pod
=head2 prepend-item

Prepends I<item> to the start of I<menu>.

See C<insert-item()> for more information.

  method prepend-item ( N-GObject $item )

=item N-GObject $item; a B<Gnome::Gio::MenuItem> to prepend

=end pod

method prepend-item ( $item is copy ) {
  $item .= _get-native-object-no-reffing unless $item ~~ N-GObject;

  g_menu_prepend_item(
    self._get-native-object-no-reffing, $item
  );
}

sub g_menu_prepend_item ( N-GObject $menu, N-GObject $item  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:prepend-section:
=begin pod
=head2 prepend-section

Convenience function for prepending a section menu item to the start of I<menu>.  Combine C<Gnome::Gio::MenuItem.new(:section)> and C<insert-item()> for a more flexible alternative.

  method prepend-section ( Str $label, N-GObject $section )

=item Str $label; (nullable): the section label, or C<undefined>
=item N-GObject $section; a B<Gnome::Gio::MenuModel> with the items of the section

=end pod

method prepend-section ( Str $label, $section is copy ) {
  $section .= _get-native-object-no-reffing unless $section ~~ N-GObject;

  g_menu_prepend_section(
    self._get-native-object-no-reffing, $label, $section
  );
}

sub g_menu_prepend_section ( N-GObject $menu, gchar-ptr $label, N-GObject $section  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:prepend-submenu:
=begin pod
=head2 prepend-submenu

Convenience function for prepending a submenu menu item to the start of I<menu>.  Combine C<Gnome::Gio::MenuItem.new(:submenu)> and C<insert-item()> for a more flexible alternative.

  method prepend-submenu ( Str $label, N-GObject $submenu )

=item Str $label; the section label, or C<undefined>
=item N-GObject $submenu; a B<Gnome::Gio::MenuModel> with the items of the submenu

=end pod

method prepend-submenu ( Str $label, $submenu is copy ) {
  $submenu .= _get-native-object-no-reffing unless $submenu ~~ N-GObject;

  g_menu_prepend_submenu(
    self._get-native-object-no-reffing, $label, $submenu
  );
}

sub g_menu_prepend_submenu ( N-GObject $menu, gchar-ptr $label, N-GObject $submenu  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:remove:
=begin pod
=head2 remove

Removes an item from the menu.

I<$position> gives the index of the item to remove.

It is an error if position is not in range the range from 0 to one less than the number of items in the menu.

It is not possible to remove items by identity since items are added to the menu simply by copying their links and attributes (ie: identity of the item itself is not preserved).

  method remove ( Int $position )

=item Int $position; the position of the item to remove

=end pod

method remove ( Int $position ) {

  g_menu_remove(
    self._get-native-object-no-reffing, $position
  );
}

sub g_menu_remove ( N-GObject $menu, gint $position  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:remove-all:
=begin pod
=head2 remove-all

Removes all items in the menu.

  method remove-all ( )

=end pod

method remove-all ( ) {

  g_menu_remove_all(
    self._get-native-object-no-reffing,
  );
}

sub g_menu_remove_all ( N-GObject $menu  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_menu_new:
#`{{
=begin pod
=head2 _g_menu_new

Creates a new B<Gnome::Gio::Menu>.

The new menu has no items.

Returns: a new B<Gnome::Gio::Menu>

  method _g_menu_new ( --> N-GObject )

=end pod
}}

sub _g_menu_new (  --> N-GObject )
  is native(&gio-lib)
  is symbol('g_menu_new')
  { * }
