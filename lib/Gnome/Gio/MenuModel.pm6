#TL:1:Gnome::Gio::MenuModel:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::MenuModel

An abstract class representing the contents of a menu

=comment ![](images/X.png)

=head1 Description

B<GMenuModel> represents the contents of a menu -- an ordered list of menu items. The items are associated with actions, which can be activated through them. Items can be grouped in sections, and may have submenus associated with them. Both items and sections usually have some representation data, such as labels or icons. The type of the associated action (ie whether it is stateful, and what kind of state it has) can influence the representation of the item.

The conceptual model of menus in B<GMenuModel> is hierarchical: sections and submenus are again represented by B<GMenuModel>s. Menus themselves do not define their own roles. Rather, the role of a particular B<GMenuModel> is defined by the item that references it (or, in the case of the 'root' menu, is defined by the context in which it is used).

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

Notice that the separators visible in the example appear nowhere in the [menu model][menu-model]. This is because separators are not explicitly represented in the menu model. Instead, a separator is inserted between any two non-empty sections of a menu. Section items can have labels just like any other item. In that case, a display system may show a section header instead of a separator.

The motivation for this abstract model of application controls is that modern user interfaces tend to make these controls available outside the application. Examples include global menus, jumplists, dash boards, etc. To support such uses, it is necessary to 'export' information about actions and their representation in menus, which is exactly what the B<GActionGroup> exporter and the B<GMenuModel> exporter do for B<GActionGroup> and B<GMenuModel>. The client-side counterparts to make use of the exported information are B<GDBusActionGroup> and B<GDBusMenuModel>.

The API of B<GMenuModel> is very generic, with iterators for the attributes and links of an item, see C<g_menu_model_iterate_item_attributes()> and C<g_menu_model_iterate_item_links()>. The 'standard' attributes and link types have predefined names: C<G_MENU_ATTRIBUTE_LABEL>, C<G_MENU_ATTRIBUTE_ACTION>, C<G_MENU_ATTRIBUTE_TARGET>, C<G_MENU_LINK_SECTION> and C<G_MENU_LINK_SUBMENU>.

Items in a B<GMenuModel> represent active controls if they refer to an action that can get activated when the user interacts with the menu item. The reference to the action is encoded by the string id in the C<G_MENU_ATTRIBUTE_ACTION> attribute. An action id uniquely identifies an action in an action group. Which action group(s) provide actions depends on the context in which the menu model is used. E.g. when the model is exported as the application menu of a B<Gnome::Gtk3::Application>, actions can be application-wide or window-specific (and thus come from two different action groups). By convention, the application-wide actions have names that start with "app.", while the names of window-specific actions start with "win.".

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

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::GObject::Object;

#-------------------------------------------------------------------------------
# /usr/include/gtk-3.0/gtk/INCLUDE
# https://developer.gnome.org/WWW
unit class Gnome::Gio::MenuModel:auth<github:MARTIMM>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
#`{{
=begin pod
=head2 class

Gets all the links associated with the item in the menu model.


=item ___model: the B<GMenuModel> to query
=item ___item_index: The B<GMenuItem> to query
=item ___links: (out) (element-type utf8 Gio.MenuModel): Links from the item


=end pod

#TT:0::
class  is export is repr('CStruct') {
  has GObjectClass $.parent_class;
  has gboolea $.n              (*is_mutable)                       (GMenuModel          *model);
  has gin $.t                  (*get_n_items)                      (GMenuModel          *model);
  has GHashTable $.attributes);
  has int32 $.item_index);
  has N-GObject $.expected_type);
  has GHashTable $.links);
  has int32 $.item_index);
  has str $.link);
}
}}

=begin pod
=head1 Types

=head2 class N-GMenuAttributeIter

=end pod

#TT:0::N-GMenuAttributeIter
class N-GMenuAttributeIter
  is repr('CPointer')
  is export
  { }

#TT:0::N-GMenuLinkIter
class N-GMenuLinkIter
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
my Bool $signals-added = False;
#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

Create an object using a native object from elsewhere. See also B<Gnome::GObject::Object>.

  multi method new ( N-GObject :$widget! )

Create an object using a native object from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

#TM:0:new():inheriting
#TM:0:new(:widget):
#TM:0:new(:build-id):

submethod BUILD ( *%options ) {

  # add signal info in the form of group<signal-name>.
  # groups are e.g. signal, event, nativeobject etc
  $signals-added = self.add-signal-types( $?CLASS.^name,
    :w3<items-changed>,
  ) unless $signals-added;


  # prevent creating wrong widgets
  return unless self.^name eq 'Gnome::Gio::MenuModel';

  # process all named arguments
  if ? %options<widget> || %options<build-id> {
    # provided in Gnome::GObject::Object
  }

  elsif %options.keys.elems {
    die X::Gnome.new(
      :message('Unsupported options for ' ~ self.^name ~
               ': ' ~ %options.keys.join(', ')
              )
    );
  }

  # only after creating the widget, the gtype is known
  self.set-class-info('GMenuModel');
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("g_menu_model_$native-sub"); } unless ?$s;

  self.set-class-name-of-sub('GMenuModel');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
#TM:0:g_menu_model_is_mutable:
=begin pod
=head2 [g_menu_model_] is_mutable

Queries if I<model> is mutable.

An immutable B<GMenuModel> will never emit the  I<items-changed>
signal. Consumers of the model may make optimisations accordingly.

Returns: C<1> if the model is mutable (ie: "items-changed" may be
emitted).

Since: 2.32

  method g_menu_model_is_mutable ( --> Int  )

=end pod

sub g_menu_model_is_mutable ( N-GObject $model )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_model_get_n_items:
=begin pod
=head2 [g_menu_model_] get_n_items

Query the number of items in I<model>.

Returns: the number of items

Since: 2.32

  method g_menu_model_get_n_items ( --> Int  )


=end pod

sub g_menu_model_get_n_items ( N-GObject $model )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_model_iterate_item_attributes:
=begin pod
=head2 [g_menu_model_] iterate_item_attributes

Creates a B<N-GMenuAttributeIter> to iterate over the attributes of
the item at position I<item_index> in I<model>.

You must free the iterator with C<g_object_unref()> when you are done.

Returns: (transfer full): a new B<N-GMenuAttributeIter>

Since: 2.32

  method g_menu_model_iterate_item_attributes ( Int $item_index --> N-GMenuAttributeIter  )

=item Int $item_index; the index of the item

=end pod

sub g_menu_model_iterate_item_attributes ( N-GObject $model, int32 $item_index )
  returns N-GMenuAttributeIter
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_model_get_item_attribute_value:
=begin pod
=head2 [g_menu_model_] get_item_attribute_value

Queries the item at position I<item_index> in I<model> for the attribute
specified by I<attribute>.

If I<expected_type> is non-C<Any> then it specifies the expected type of
the attribute.  If it is C<Any> then any type will be accepted.

If the attribute exists and matches I<expected_type> (or if the
expected type is unspecified) then the value is returned.

If the attribute does not exist, or does not match the expected type
then C<Any> is returned.

Returns: (transfer full): the value of the attribute

Since: 2.32

  method g_menu_model_get_item_attribute_value ( Int $item_index, Str $attribute, N-GObject $expected_type --> N-GObject  )

=item Int $item_index; the index of the item
=item Str $attribute; the attribute to query
=item N-GObject $expected_type; (nullable): the expected type of the attribute, or C<Any>

=end pod

sub g_menu_model_get_item_attribute_value ( N-GObject $model, int32 $item_index, Str $attribute, N-GObject $expected_type )
  returns N-GObject
  is native(&glib-lib)
  { * }

#`[[
#-------------------------------------------------------------------------------
#TM:0:g_menu_model_get_item_attribute:
=begin pod
=head2 [g_menu_model_] get_item_attribute

Queries item at position I<item_index> in I<model> for the attribute
specified by I<attribute>.

If the attribute exists and matches the B<GVariantType> corresponding
to I<format_string> then I<format_string> is used to deconstruct the
value into the positional parameters and C<1> is returned.

If the attribute does not exist, or it does exist but has the wrong
type, then the positional parameters are ignored and C<0> is
returned.

This function is a mix of C<g_menu_model_get_item_attribute_value()> and
C<g_variant_get()>, followed by a C<g_variant_unref()>.  As such,
I<format_string> must make a complete copy of the data (since the
B<GVariant> may go away after the call to C<g_variant_unref()>).  In
particular, no '&' characters are allowed in I<format_string>.

Returns: C<1> if the named attribute was found with the expected
type

Since: 2.32

  method g_menu_model_get_item_attribute ( Int $item_index, Str $attribute, Str $format_string --> Int  )

=item Int $item_index; the index of the item
=item Str $attribute; the attribute to query
=item Str $format_string; a B<GVariant> format string @...: positional parameters, as per I<format_string>

=end pod

sub g_menu_model_get_item_attribute ( N-GObject $model, int32 $item_index, Str $attribute, Str $format_string, Any $any = Any )
  returns int32
  is native(&glib-lib)
  { * }
]]

#-------------------------------------------------------------------------------
#TM:0:g_menu_model_iterate_item_links:
=begin pod
=head2 [g_menu_model_] iterate_item_links

Creates a B<N-GMenuLinkIter> to iterate over the links of the item at
position I<item_index> in I<model>.

You must free the iterator with C<g_object_unref()> when you are done.

Returns: (transfer full): a new B<N-GMenuLinkIter>

Since: 2.32

  method g_menu_model_iterate_item_links ( Int $item_index --> N-GMenuLinkIter  )

=item Int $item_index; the index of the item

=end pod

sub g_menu_model_iterate_item_links ( N-GObject $model, int32 $item_index )
  returns N-GMenuLinkIter
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_model_get_item_link:
=begin pod
=head2 [g_menu_model_] get_item_link

Queries the item at position I<item_index> in I<model> for the link
specified by I<link>.

If the link exists, the linked B<GMenuModel> is returned.  If the link
does not exist, C<Any> is returned.

Returns: (transfer full): the linked B<GMenuModel>, or C<Any>

Since: 2.32

  method g_menu_model_get_item_link ( Int $item_index, Str $link --> N-GObject  )

=item Int $item_index; the index of the item
=item Str $link; the link to query

=end pod

sub g_menu_model_get_item_link ( N-GObject $model, int32 $item_index, Str $link )
  returns N-GObject
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_model_items_changed:
=begin pod
=head2 [g_menu_model_] items_changed

Requests emission of the  I<items-changed> signal on I<model>.

This function should never be called except by B<GMenuModel>
subclasses.  Any other calls to this function will very likely lead
to a violation of the interface of the model.

The implementation should update its internal representation of the
menu before emitting the signal.  The implementation should further
expect to receive queries about the new state of the menu (and
particularly added menu items) while signal handlers are running.

The implementation must dispatch this call directly from a mainloop
entry and not in response to calls -- particularly those from the
B<GMenuModel> API.  Said another way: the menu must not change while
user code is running without returning to the mainloop.

Since: 2.32

  method g_menu_model_items_changed ( Int $position, Int $removed, Int $added )

=item Int $position; the position of the change
=item Int $removed; the number of items removed
=item Int $added; the number of items added

=end pod

sub g_menu_model_items_changed ( N-GObject $model, int32 $position, int32 $removed, int32 $added )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_attribute_iter_get_next:
=begin pod
=head2 g_menu_attribute_iter_get_next

This function combines C<g_menu_attribute_iter_next()> with
C<g_menu_attribute_iter_get_name()> and C<g_menu_attribute_iter_get_value()>.

First the iterator is advanced to the next (possibly first) attribute.
If that fails, then C<0> is returned and there are no other
effects.

If successful, I<name> and I<value> are set to the name and value of the
attribute that has just been advanced to.  At this point,
C<g_menu_attribute_iter_get_name()> and C<g_menu_attribute_iter_get_value()> will
return the same values again.

The value returned in I<name> remains valid for as long as the iterator
remains at the current position.  The value returned in I<value> must
be unreffed using C<g_variant_unref()> when it is no longer in use.

Returns: C<1> on success, or C<0> if there is no additional
attribute

Since: 2.32

  method g_menu_attribute_iter_get_next ( N-GMenuAttributeIter $iter, CArray[Str] $out_name, N-GObject $value --> Int  )

=item N-GMenuAttributeIter $iter; a B<N-GMenuAttributeIter>
=item CArray[Str] $out_name; (out) (optional) (transfer none): the type of the attribute
=item N-GObject $value; (out) (optional) (transfer full): the attribute value

=end pod

sub g_menu_attribute_iter_get_next ( N-GMenuAttributeIter $iter, CArray[Str] $out_name, N-GObject $value )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_attribute_iter_next:
=begin pod
=head2 g_menu_attribute_iter_next

Attempts to advance the iterator to the next (possibly first)
attribute.

C<1> is returned on success, or C<0> if there are no more
attributes.

You must call this function when you first acquire the iterator
to advance it to the first attribute (and determine if the first
attribute exists at all).

Returns: C<1> on success, or C<0> when there are no more attributes

Since: 2.32

  method g_menu_attribute_iter_next ( N-GMenuAttributeIter $iter --> Int  )

=item N-GMenuAttributeIter $iter; a B<N-GMenuAttributeIter>

=end pod

sub g_menu_attribute_iter_next ( N-GMenuAttributeIter $iter )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_attribute_iter_get_name:
=begin pod
=head2 g_menu_attribute_iter_get_name

Gets the name of the attribute at the current iterator position, as
a string.

The iterator is not advanced.

Returns: the name of the attribute

Since: 2.32

  method g_menu_attribute_iter_get_name ( N-GMenuAttributeIter $iter --> Str  )

=item N-GMenuAttributeIter $iter; a B<N-GMenuAttributeIter>

=end pod

sub g_menu_attribute_iter_get_name ( N-GMenuAttributeIter $iter )
  returns Str
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_attribute_iter_get_value:
=begin pod
=head2 g_menu_attribute_iter_get_value

Gets the value of the attribute at the current iterator position.

The iterator is not advanced.

Returns: (transfer full): the value of the current attribute

Since: 2.32

  method g_menu_attribute_iter_get_value ( N-GMenuAttributeIter $iter --> N-GObject  )

=item N-GMenuAttributeIter $iter; a B<N-GMenuAttributeIter>

=end pod

sub g_menu_attribute_iter_get_value ( N-GMenuAttributeIter $iter )
  returns N-GObject
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_link_iter_get_next:
=begin pod
=head2 g_menu_link_iter_get_next

This function combines C<g_menu_link_iter_next()> with
C<g_menu_link_iter_get_name()> and C<g_menu_link_iter_get_value()>.

First the iterator is advanced to the next (possibly first) link.
If that fails, then C<0> is returned and there are no other effects.

If successful, I<out_link> and I<value> are set to the name and B<GMenuModel>
of the link that has just been advanced to.  At this point,
C<g_menu_link_iter_get_name()> and C<g_menu_link_iter_get_value()> will return the
same values again.

The value returned in I<out_link> remains valid for as long as the iterator
remains at the current position.  The value returned in I<value> must
be unreffed using C<g_object_unref()> when it is no longer in use.

Returns: C<1> on success, or C<0> if there is no additional link

Since: 2.32

  method g_menu_link_iter_get_next ( N-GMenuLinkIter $iter, CArray[Str] $out_link, N-GObject $value --> Int  )

=item N-GMenuLinkIter $iter; a B<N-GMenuLinkIter>
=item CArray[Str] $out_link; (out) (optional) (transfer none): the name of the link
=item N-GObject $value; (out) (optional) (transfer full): the linked B<GMenuModel>

=end pod

sub g_menu_link_iter_get_next ( N-GMenuLinkIter $iter, CArray[Str] $out_link, N-GObject $value )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_link_iter_next:
=begin pod
=head2 g_menu_link_iter_next

Attempts to advance the iterator to the next (possibly first)
link.

C<1> is returned on success, or C<0> if there are no more links.

You must call this function when you first acquire the iterator to
advance it to the first link (and determine if the first link exists
at all).

Returns: C<1> on success, or C<0> when there are no more links

Since: 2.32

  method g_menu_link_iter_next ( N-GMenuLinkIter $iter --> Int  )

=item N-GMenuLinkIter $iter; a B<N-GMenuLinkIter>

=end pod

sub g_menu_link_iter_next ( N-GMenuLinkIter $iter )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_link_iter_get_name:
=begin pod
=head2 g_menu_link_iter_get_name

Gets the name of the link at the current iterator position.

The iterator is not advanced.

Returns: the type of the link

Since: 2.32

  method g_menu_link_iter_get_name ( N-GMenuLinkIter $iter --> Str  )

=item N-GMenuLinkIter $iter; a B<N-GMenuLinkIter>

=end pod

sub g_menu_link_iter_get_name ( N-GMenuLinkIter $iter )
  returns Str
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_menu_link_iter_get_value:
=begin pod
=head2 g_menu_link_iter_get_value

Gets the linked B<GMenuModel> at the current iterator position.

The iterator is not advanced.

Returns: (transfer full): the B<GMenuModel> that is linked to

Since: 2.32

  method g_menu_link_iter_get_value ( N-GMenuLinkIter $iter --> N-GObject  )

=item N-GMenuLinkIter $iter; a B<N-GMenuLinkIter>

=end pod

sub g_menu_link_iter_get_value ( N-GMenuLinkIter $iter )
  returns N-GObject
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head1 Signals

There are two ways to connect to a signal. The first option you have is to use C<register-signal()> from B<Gnome::GObject::Object>. The second option is to use C<g_signal_connect_object()> directly from B<Gnome::GObject::Signal>.

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

Also here, the types of positional arguments in the signal handler are important. This is because both methods C<register-signal()> and C<g_signal_connect_object()> are using the signatures of the handler routines to setup the native call interface.

=head2 Supported signals


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
the menu will be a, b, _, _, _, d (with each _ representing some
new item).

Signal handlers may query the model (particularly the added items)
and expect to see the results of the modification that is being
reported.  The signal is emitted after the modification.

  method handler (
    Int $position,
    Int $removed,
    Int $added,
    Gnome::GObject::Object :widget($model),
    *%user-options
  );

=item $model; the B<GMenuModel> that is changing

=item $position; the position of the change

=item $removed; the number of items removed

=item $added; the number of items added


=end pod
