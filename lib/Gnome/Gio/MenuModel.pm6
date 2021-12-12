#TL:1:Gnome::Gio::MenuModel:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::MenuModel

An abstract class representing the contents of a menu

=comment ![](images/X.png)

=head1 Description

B<Gnome::Gio::MenuModel> represents the contents of a menu -- an ordered list of menu items. The items are associated with actions, which can be activated through them. Items can be grouped in sections, and may have submenus associated with them. Both items and sections usually have some representation data, such as labels or icons. The type of the associated action (ie whether it is stateful, and what kind of state it has) can influence the representation of the item.

The conceptual model of menus in B<Gnome::Gio::MenuModel> is hierarchical: sections and submenus are again represented by B<Gnome::Gio::MenuModel>s. Menus themselves do not define their own roles. Rather, the role of a particular B<Gnome::Gio::MenuModel> is defined by the item that references it (or, in the case of the 'root' menu, is defined by the context in which it is used).

As an example, consider the visible portions of this menu:

=head2 An example menu

![](images/menu-example.png)

There are 8 "menus" visible in the screenshot: one menubar, two submenus and 5 sections:

=item the toplevel menubar (containing 4 items)
=item the View submenu (containing 3 sections)
=item the first section of the View submenu (containing 2 items)
=item the second section of the View submenu (containing 1 item)
=item the final section of the View submenu (containing 1 item)
=item the Highlight Mode submenu (containing 2 sections)
=item the Sources section (containing 2 items)
=item the Markup section (containing 2 items)

The example illustrates the conceptual connection between these 8 menus. Each large block in the figure represents a menu and the smaller blocks within the large block represent items in that menu. Some items contain references to other menus.

![](images/menu-model.png)

Notice that the separators visible in the example appear nowhere in the menu model. This is because separators are not explicitly represented in the menu model. Instead, a separator is inserted between any two non-empty sections of a menu. Section items can have labels just like any other item. In that case, a display system may show a section header instead of a separator.

The motivation for this abstract model of application controls is that modern user interfaces tend to make these controls available outside the application. Examples include global menus, jumplists, dash boards, etc. To support such uses, it is necessary to 'export' information about actions and their representation in menus, which is exactly what the B<GActionGroup> exporter and the B<Gnome::Gio::MenuModel> exporter do for B<GActionGroup> and B<Gnome::Gio::MenuModel>. The client-side counterparts to make use of the exported information are B<GDBusActionGroup> and B<GDBusMenuModel>.

The API of B<Gnome::Gio::MenuModel> is very generic, with iterators for the attributes and links of an item, see C<g_menu_model_iterate_item_attributes()> and C<g_menu_model_iterate_item_links()>. The 'standard' attributes and link types have predefined names: C<G_MENU_ATTRIBUTE_LABEL>, C<G_MENU_ATTRIBUTE_ACTION>, C<G_MENU_ATTRIBUTE_TARGET>, C<G_MENU_LINK_SECTION> and C<G_MENU_LINK_SUBMENU>.

Items in a B<Gnome::Gio::MenuModel> represent active controls if they refer to an action that can get activated when the user interacts with the menu item. The reference to the action is encoded by the string id in the C<G_MENU_ATTRIBUTE_ACTION> attribute. An action id uniquely identifies an action in an action group. Which action group(s) provide actions depends on the context in which the menu model is used. E.g. when the model is exported as the application menu of a B<Gnome::Gtk3::Application>, actions can be application-wide or window-specific (and thus come from two different action groups). By convention, the application-wide actions have names that start with "app.", while the names of window-specific actions start with "win.".

While a wide variety of stateful actions is possible, the following is the minimum that is expected to be supported by all users of exported menu information:
=item an action with no parameter type and no state
=item an action with no parameter type and boolean state
=item an action with string parameter type and string state

=head2 Stateless

A stateless action typically corresponds to an ordinary menu item. Selecting such a menu item will activate the action (with no parameter).

=head2 Boolean State

An action with a boolean state will most typically be used with a "toggle" or "switch" menu item. The state can be set directly, but activating the action (with no parameter) results in the state being toggled.

Selecting a toggle menu item will activate the action. The menu item should be rendered as "checked" when the state is true.

=head2 String Parameter and State

Actions with string parameters and state will most typically be used to represent an enumerated choice over the items available for a group of radio menu items. Activating the action with a string parameter is equivalent to setting that parameter as the state.

Radio menu items, in addition to being associated with the action, will have a target value. Selecting that menu item will result in activation of the action with the target value as the parameter. The menu item should be rendered as "selected" when the state of the action is equal to the target value of the menu item.


=head2 See Also

B<GActionGroup>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::MenuModel;
  also is Gnome::GObject::Object;


=head2 Uml Diagram

![](plantuml/MenuModel.svg)


=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::Variant;
use Gnome::Glib::VariantType;

use Gnome::Gio::MenuAttributeIter;
use Gnome::Gio::MenuLinkIter;

use Gnome::GObject::Object;

#-------------------------------------------------------------------------------
# /usr/include/gtk-3.0/gtk/INCLUDE
# https://developer.gnome.org/WWW
unit class Gnome::Gio::MenuModel:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
=begin pod
=head1 Constants

=begin item
C<G_MENU_ATTRIBUTE_ACTION> = "action"; The menu item attribute which holds the action name of the item. Action names are namespaced with an identifier for the action group in which the action resides. For example, "win." for window-specific actions and "app." for application-wide actions.

See also C<get_item_attribute()> and C<Gnome::Gio::MenuItem.set_attribute()>.
=end item
=begin item
C<G_MENU_ATTRIBUTE_ACTION_NAMESPACE> = "action-namespace"; The menu item attribute that holds the namespace for all action names in menus that are linked from this item.
=end item
=begin item
C<G_MENU_ATTRIBUTE_TARGET> = "target"; The menu item attribute which holds the target with which the item's action will be activated.

See also C<Gnome::Gio::MenuItem.set_action_and_target()>.
=end item
=begin item
C<G_MENU_ATTRIBUTE_LABEL> = "label"; The menu item attribute which holds the label of the item.
=end item
=begin item
C<G_MENU_ATTRIBUTE_ICON> = "icon"; The menu item attribute which holds the icon of the item.

=comment The icon is stored in the format returned by C<Gnome::Gio::Icon.serialize()>.

This attribute is intended only to represent 'noun' icons such as favicons for a webpage, or application icons. It should not be used for 'verbs' (ie: stock icons).
=end item
=begin item
C<G_MENU_LINK_SECTION> = "section"; The name of the link that associates a menu item with a section. The linked menu will usually be shown in place of the menu item, using the item's label as a header.

See also C<Gnome::Gio::MenuItem.set_link()>.
=end item
=begin item
C<G_MENU_LINK_SUBMENU> = "submenu"; The name of the link that associates a menu item with a submenu.

See also C<Gnome::Gio::MenuItem.set_link()>.
=end item
=end pod

#TT:1:constants
constant G_MENU_ATTRIBUTE_ACTION           is export = "action";
constant G_MENU_ATTRIBUTE_ACTION_NAMESPACE is export = "action-namespace";
constant G_MENU_ATTRIBUTE_TARGET           is export = "target";
constant G_MENU_ATTRIBUTE_LABEL            is export = "label";
constant G_MENU_ATTRIBUTE_ICON             is export = "icon";
constant G_MENU_LINK_SECTION               is export = "section";
constant G_MENU_LINK_SUBMENU               is export = "submenu";

#-------------------------------------------------------------------------------
my Bool $signals-added = False;
#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

#`{{
=begin pod
=head2 new

Create an object using a native object from elsewhere. See also B<Gnome::GObject::Object>.

  multi method new ( N-GObject :$native-object! )

Create an object using a native object from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

# TM:0:new(:widget):
# TM:1:new(:build-id):
}}

#TM:0:new():
submethod BUILD ( *%options ) {

  # add signal info in the form of group<signal-name>.
  # groups are e.g. signal, event, nativeobject etc
  $signals-added = self.add-signal-types( $?CLASS.^name,
    :w3<items-changed>,
  ) unless $signals-added;


  # prevent creating wrong widgets
  return unless self.^name eq 'Gnome::Gio::MenuModel';

#`{{
  # process all named arguments
  if ? %options<native-object> || %options<build-id> {
    # provided in Gnome::GObject::Object
  }

  elsif %options.keys.elems {
    die X::Gnome.new(
      :message('Unsupported options for ' ~ self.^name ~
               ': ' ~ %options.keys.join(', ')
              )
    );
  }
}}

  # only after creating the widget, the gtype is known
  self._set-class-info('GMenuModel');
}

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-item-attribute:
=begin pod
=head2 get-item-attribute


Queries item at position I<item-index> in I<model> for the attribute
specified by I<attribute>.

If the attribute exists and matches the B<GVariantType> corresponding
to I<format-string> then I<format-string> is used to deconstruct the
value into the positional parameters and C<True> is returned.

If the attribute does not exist, or it does exist but has the wrong
type, then the positional parameters are ignored and C<False> is
returned.

This function is a mix of C<get-item-attribute-value()> and
C<g-variant-get()>, followed by a C<g-variant-unref()>.  As such,
I<format-string> must make a complete copy of the data (since the
B<GVariant> may go away after the call to C<g-variant-unref()>).  In
particular, no '&' characters are allowed in I<format-string>.

Returns: C<True> if the named attribute was found with the expected
type



  method get-item-attribute ( Int $item_index, Str $attribute, Str $format_string --> Int )

=item Int $item_index; the index of the item
=item Str $attribute; the attribute to query
=item Str $format_string; a B<GVariant> format string @...: positional parameters, as per I<format-string>

=end pod

method get-item-attribute ( Int $item_index, Str $attribute, Str $format_string --> Int ) {

  g_menu_model_get_item_attribute(
    self._f('GMenuModel'), $item_index, $attribute, $format_string
  );
}

sub g_menu_model_get_item_attribute ( N-GObject $model, gint $item_index, gchar-ptr $attribute, gchar-ptr $format_string, Any $any = Any --> gboolean )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:get-item-attribute-value:
=begin pod
=head2 get-item-attribute-value


Queries the item at position I<item-index> in I<model> for the attribute
specified by I<attribute>.

If I<expected-type> is non-C<undefined> then it specifies the expected type of
the attribute.  If it is C<undefined> then any type will be accepted.

If the attribute exists and matches I<expected-type> (or if the
expected type is unspecified) then the value is returned.

If the attribute does not exist, or does not match the expected type
then C<undefined> is returned.

Returns: (transfer full): the value of the attribute



  method get-item-attribute-value ( Int $item_index, Str $attribute, N-GObject $expected_type --> N-GObject )

=item Int $item_index; the index of the item
=item Str $attribute; the attribute to query
=item N-GObject $expected_type; (nullable): the expected type of the attribute, or C<undefined>

=end pod

method get-item-attribute-value ( Int $item_index, Str $attribute, N-GObject $expected_type --> N-GObject ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GObject;

  g_menu_model_get_item_attribute_value(
    self._f('GMenuModel'), $item_index, $attribute, $expected_type
  );
}

sub g_menu_model_get_item_attribute_value ( N-GObject $model, gint $item_index, gchar-ptr $attribute, N-GObject $expected_type --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-item-link:
=begin pod
=head2 get-item-link


Queries the item at position I<item-index> in I<model> for the link
specified by I<link>.

If the link exists, the linked B<Gnome::Gio::MenuModel> is returned.  If the link
does not exist, C<undefined> is returned.

Returns: (transfer full): the linked B<Gnome::Gio::MenuModel>, or C<undefined>



  method get-item-link ( Int $item_index, Str $link --> N-GObject )

=item Int $item_index; the index of the item
=item Str $link; the link to query

=end pod

method get-item-link ( Int $item_index, Str $link --> N-GObject ) {

  g_menu_model_get_item_link(
    self._f('GMenuModel'), $item_index, $link
  );
}

sub g_menu_model_get_item_link ( N-GObject $model, gint $item_index, gchar-ptr $link --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-n-items:
=begin pod
=head2 get-n-items

Query the number of items in I<model>.

  method get-n-items ( --> Int )

=end pod

method get-n-items ( --> Int ) {
  g_menu_model_get_n_items(self._f('GMenuModel'));
}

sub g_menu_model_get_n_items ( N-GObject $model --> gint )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-mutable:
=begin pod
=head2 is-mutable

Queries if I<model> is mutable.

An immutable B<Gnome::Gio::MenuModel> will never emit the  I<items-changed> signal. Consumers of the model may make optimisations accordingly.

Returns: C<True> if the model is mutable (ie: "items-changed" may be emitted).

  method is-mutable ( --> Bool )

=end pod

method is-mutable ( --> Bool ) {
  g_menu_model_is_mutable(self._f('GMenuModel')).Bool
}

sub g_menu_model_is_mutable ( N-GObject $model --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:items-changed:
=begin pod
=head2 items-changed


Requests emission of the  I<items-changed> signal on I<model>.

This function should never be called except by B<Gnome::Gio::MenuModel>
subclasses.  Any other calls to this function will very likely lead
to a violation of the interface of the model.

The implementation should update its internal representation of the
menu before emitting the signal.  The implementation should further
expect to receive queries about the new state of the menu (and
particularly added menu items) while signal handlers are running.

The implementation must dispatch this call directly from a mainloop
entry and not in response to calls -- particularly those from the
B<Gnome::Gio::MenuModel> API.  Said another way: the menu must not change while
user code is running without returning to the mainloop.



  method items-changed ( Int $position, Int $removed, Int $added )

=item Int $position; the position of the change
=item Int $removed; the number of items removed
=item Int $added; the number of items added

=end pod

method items-changed ( Int $position, Int $removed, Int $added ) {

  g_menu_model_items_changed(
    self._f('GMenuModel'), $position, $removed, $added
  );
}

sub g_menu_model_items_changed ( N-GObject $model, gint $position, gint $removed, gint $added  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:iterate-item-attributes:
=begin pod
=head2 iterate-item-attributes


Creates a B<Gnome::Gio::MenuLinkIter> to iterate over the attributes of the item at position I<$item-index> in I<model>. You must free the iterator with C<clear-object()> when you are done.

Returns: a new B<Gnome::Gio::MenuLinkIter>

  method iterate-item-attributes (
    Int $item_index --> Gnome::Gio::MenuLinkIter
  )

=item Int $item_index; the index of the item

=end pod

method iterate-item-attributes (
  Int $item_index --> Gnome::Gio::MenuLinkIter
) {
  Gnome::Gio::MenuLinkIter.new(
    :native-object(
      g_menu_model_iterate_item_attributes(
        self._f('GMenuModel'), $item_index
      )
    )
  );
}

sub g_menu_model_iterate_item_attributes ( N-GObject $model, gint $item_index --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:iterate-item-links:
=begin pod
=head2 iterate-item-links

Creates a B<Gnome::Gio::MenuLinkIter> to iterate over the links of the item at position I<item-index> in I<model>. You must free the iterator with C<clear-object()> when you are done.

Returns: a new B<Gnome::Gio::MenuLinkIter>

  method iterate-item-links (
    Int $item_index --> Gnome::Gio::MenuLinkIter
  )

=item Int $item_index; the index of the item

=end pod

method iterate-item-links ( Int $item_index --> Gnome::Gio::MenuLinkIter ) {

  Gnome::Gio::MenuLinkIter.new(
    :native-object(
      g_menu_model_iterate_item_links(self._f('GMenuModel'), $item_index)
    )
  );
}

sub g_menu_model_iterate_item_links ( N-GObject $model, gint $item_index --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head1 Signals

There are two ways to connect to a signal. The first option you have is to use C<register-signal()> from B<Gnome::GObject::Object>. The second option is to use C<connect-object()> directly from B<Gnome::GObject::Signal>.

=head2 First method

The positional arguments of the signal handler are all obligatory as well as their types. The named attributes C<:$widget> and user data are optional.

  # handler method
  method mouse-event ( GdkEvent $event, :$widget ) { ... }

  # connect a signal on window object
  my Gnome::Gtk3::Window $w .= new( ... );
  $w.register-signal( self, 'mouse-event', 'button-press-event');

=head2 Second method

  my Gnome::Gtk3::Window $w .= new( ... );
  my Callable $handler = sub (
    N-GObject $native, GdkEvent $event, OpaquePointer $data
  ) {
    ...
  }

  $w.connect-object( 'button-press-event', $handler);

Also here, the types of positional arguments in the signal handler are important. This is because both methods C<register-signal()> and C<connect-object()> are using the signatures of the handler routines to setup the native call interface.

=head2 Supported signals


=comment -----------------------------------------------------------------------
=comment #TS:0:items-changed:
=head3 items-changed

Emitted when a change has occured to the menu.

The only changes that can occur to a menu is that items are removed
or added.  Items may not change (except by being removed and added
back in the same location).  This signal is capable of describing
both of those changes (at the same time).

The signal means that starting at the index I<position>, I<removed>
items were removed and I<added> items were added in their place.  If
I<removed> is zero then only items were added.  If I<added> is zero
then only items were removed.

As an example, if the menu contains items a, b, c, d (in that
order) and the signal (2, 1, 3) occurs then the new composition of
the menu will be a, b, -, -, -, d (with each - representing some
new item).

Signal handlers may query the model (particularly the added items)
and expect to see the results of the modification that is being
reported.  The signal is emitted after the modification.

  method handler (
    Int $position,
    Int $removed,
    Int $added,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($model),
    *%user-options
  );

=item $model; the B<Gnome::Gio::MenuModel> that is changing

=item $position; the position of the change

=item $removed; the number of items removed

=item $added; the number of items added


=end pod
