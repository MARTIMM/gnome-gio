#TL:1:Gnome::Gio::MenuItem:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::MenuItem

An entry in a menu

=comment ![](images/X.png)

=head1 Description


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::MenuItem;
  also is Gnome::GObject::Object;


=head2 Uml Diagram

![](plantuml/MenuModel.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::MenuItem;

  unit class MyGuiClass;
  also is Gnome::Gio::MenuItem;

  submethod new ( |c ) {
    # let the Gnome::Gio::MenuItem class process the options
    self.bless( :GMenuItem, |c);
  }

  submethod BUILD ( ... ) {
    ...
  }

=end comment
=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::Variant;
use Gnome::Glib::VariantType;

use Gnome::GObject::Object;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::MenuItem:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------

=begin pod
=head1 Methods
=head2 new

=head3 :label, :action

Creates a new B<Gnome::Gio::MenuItem>.

If I<$label> is defined, then it is used to set the "label" attribute of the new item.

I<$action> is used to set the "action" and possibly the "target" attribute of the new item.  See C<set-detailed-action()> for more information.

  multi method new ( Str :$label?, Str :$action! )


=head3 :model, :item-index

Creates a B<Gnome::Gio::MenuItem> as an exact copy of an existing menu item in a
B<Gnome::Gio::MenuModel>.

I<$item-index> must be valid (ie: be sure to call C<model-get-n-items()> first).

  multi method new ( N-GObject :$model!, Int :$item-index! )


=head3 :section, :label

Creates a new B<Gnome::Gio::MenuItem> representing a section.

This is a convenience API around C<new()> followed by C<set-section()>.

The effect of having one menu appear as a section of another is exactly as it sounds: the items from I<$section> become a direct part of the menu that I<menu-item> is added to.

Visual separation is typically displayed between two non-empty sections.  If I<$label> is non-C<undefined> then it will be encorporated into this visual indication.  This allows for labeled subsections of a menu.

As a simple example, consider a typical "Edit" menu from a simple program.  It probably contains an "Undo" and "Redo" item, followed by a separator, followed by "Cut", "Copy" and "Paste".

This would be accomplished by creating three B<Gnome::Gio::Menu> instances.  The first would be populated with the "Undo" and "Redo" items, and the second with the "Cut", "Copy" and "Paste" items.  The first and second menus would then be added as submenus of the third.  In XML format, this would look something like the following:

  <menu id='edit-menu'>
    <section>
      <item label='Undo'/>
      <item label='Redo'/>
    </section>
    <section>
      <item label='Cut'/>
      <item label='Copy'/>
      <item label='Paste'/>
    </section>
  </menu>


The following example is exactly equivalent.  It is more illustrative of the exact relationship between the menus and items (keeping in mind that the 'link' element defines a new menu that is linked to the containing one).  The style of the second example is more verbose and difficult to read (and therefore not recommended except for the purpose of understanding what is really going on).

  <menu id='edit-menu'>
    <item>
      <link name='section'>
        <item label='Undo'/>
        <item label='Redo'/>
      </link>
    </item>
    <item>
      <link name='section'>
        <item label='Cut'/>
        <item label='Copy'/>
        <item label='Paste'/>
      </link>
    </item>
  </menu>

The method is defined as

  multi method new ( Str $label?, N-GObject $section! )


=head3 :submenu, :label

Creates a new B<Gnome::Gio::MenuItem> representing a submenu.

This is a convenience API around C<new()> followed by C<set-submenu()>.

  method item-new-submenu ( Str :$label?, N-GObject :$submenu! )

=head3 :native-object

Create a Menu object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )


=head3 :build-id

Create a Menu object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

#TM:1:new(:label,:action):
#TM:1:new(:model,:item_index):
#TM:1:new(:label,:section):
#TM:1:new(:label,:submenu):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
#TM:4:new(:build-id):Gnome::GObject::Object
submethod BUILD ( *%options ) {
  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::MenuItem' #`{{ or %options<GMenu> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }
    elsif %options<build-id>:exists { }

    # process all other options
    else {
      my $no;
      if %options<action>:exists {
        #$no = %options<>;
        #$no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        $no = _g_menu_item_new( %options<label>//Str, %options<action>);
      }

      elsif %options<section>:exists {
        $no = %options<section>;
        $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        $no = _g_menu_item_new_section( %options<label>//Str, $no);
      }

      elsif %options<submenu>:exists {
        $no = %options<submenu>;
        $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        $no = _g_menu_item_new_submenu( %options<label>//Str, $no);
      }

      elsif %options<model>:exists and %options<item-index>:exists {
        $no = %options<model>;
        $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        $no = _g_menu_item_new_from_model( $no, %options<item-index>);
      }

      ##`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
      #}}

      ##`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      #}}

      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _g_menu_new();
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMenuItem');

  }
}

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-attribute:
=begin pod
=head2 get-attribute


Queries the named I<attribute> on I<menu-item>.

If the attribute exists and matches the B<GVariantType> corresponding
to I<format-string> then I<format-string> is used to deconstruct the
value into the positional parameters and C<True> is returned.

If the attribute does not exist, or it does exist but has the wrong
type, then the positional parameters are ignored and C<False> is
returned.

Returns: C<True> if the named attribute was found with the expected
type



  method get-attribute ( Str $attribute, Str $format_string --> Int )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $attribute; the attribute name to query
=item Str $format_string; a B<GVariant> format string @...: positional parameters, as per I<format-string>

=end pod

method get-attribute ( Str $attribute, Str $format_string --> Int ) {

  g_menu_item_get_attribute(
    self._get-native-object-no-reffing, $attribute, $format_string
  );
}

sub g_menu_item_get_attribute ( N-GObject $menu_item, gchar-ptr $attribute, gchar-ptr $format_string, Any $any = Any --> gboolean )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:get-attribute-value:
=begin pod
=head2 get-attribute-value

Queries the named I<attribute> on I<menu-item>.

If I<$expected-type> is specified and the attribute does not have this type, C<undefined> is returned.  C<undefined> is also returned if the attribute simply does not exist.

Returns: the attribute value, or C<undefined>

  method get-attribute-value (
    Str $attribute, N-GObject $expected_type
    --> Gnome::Glib::Variant
  )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $attribute; the attribute name to query
=item N-GObject $expected_type; (nullable): the expected type of the attribute

=end pod

method get-attribute-value (
  Str $attribute, $expected_type --> Gnome::Glib::Variant
) {
  my $no = $expected_type;
  $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;

  Gnome::Glib::Variant.new(
    :native-object(
      g_menu_item_get_attribute_value(
        self._get-native-object-no-reffing, $attribute, $no
      )
    )
  )
}

sub g_menu_item_get_attribute_value ( N-GObject $menu_item, gchar-ptr $attribute, N-GObject $expected_type --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-link:
=begin pod
=head2 get-link


Queries the named I<link> on I<menu-item>.

Returns: (transfer full): the link, or C<undefined>



  method get-link ( Str $link --> N-GObject )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $link; the link name to query

=end pod

method get-link ( Str $link --> N-GObject ) {

  g_menu_item_get_link(
    self._get-native-object-no-reffing, $link
  );
}

sub g_menu_item_get_link ( N-GObject $menu_item, gchar-ptr $link --> N-GObject )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:set-action-and-target:
=begin pod
=head2 set-action-and-target


Sets or unsets the "action" and "target" attributes of I<menu-item>.

If I<action> is C<undefined> then both the "action" and "target" attributes
are unset (and I<format-string> is ignored along with the positional
parameters).

If I<action> is non-C<undefined> then the "action" attribute is set.
I<format-string> is then inspected.  If it is non-C<undefined> then the proper
position parameters are collected to create a B<GVariant> instance to
use as the target value.  If it is C<undefined> then the positional
parameters are ignored and the "target" attribute is unset.

See also C<set-action-and-target-value()> for an equivalent
call that directly accepts a B<GVariant>.  See
C<g-menu-set-detailed-action()> for a more convenient version that
works with string-typed targets.

See also C<g-menu-set-action-and-target-value()> for a
description of the semantics of the action and target attributes.



  method set-action-and-target ( Str $action, Str $format_string )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $action; (nullable): the name of the action for this item
=item Str $format_string; (nullable): a GVariant format string @...: positional parameters, as per I<format-string>

=end pod

method set-action-and-target ( Str $action, Str $format_string ) {

  g_menu_item_set_action_and_target(
    self._get-native-object-no-reffing, $action, $format_string
  );
}

sub g_menu_item_set_action_and_target ( N-GObject $menu_item, gchar-ptr $action, gchar-ptr $format_string, Any $any = Any  )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:set-action-and-target-value:
=begin pod
=head2 set-action-and-target-value


Sets or unsets the "action" and "target" attributes of I<menu-item>.

If I<action> is C<undefined> then both the "action" and "target" attributes
are unset (and I<target-value> is ignored).

If I<action> is non-C<undefined> then the "action" attribute is set.  The
"target" attribute is then set to the value of I<target-value> if it is
non-C<undefined> or unset otherwise.

Normal menu items (ie: not submenu, section or other custom item
types) are expected to have the "action" attribute set to identify
the action that they are associated with.  The state type of the
action help to determine the disposition of the menu item.  See
B<GAction> and B<GActionGroup> for an overview of actions.

In general, clicking on the menu item will result in activation of
the named action with the "target" attribute given as the parameter
to the action invocation.  If the "target" attribute is not set then
the action is invoked with no parameter.

If the action has no state then the menu item is usually drawn as a
plain menu item (ie: with no additional decoration).

If the action has a boolean state then the menu item is usually drawn
as a toggle menu item (ie: with a checkmark or equivalent
indication).  The item should be marked as 'toggled' or 'checked'
when the boolean state is C<True>.

If the action has a string state then the menu item is usually drawn
as a radio menu item (ie: with a radio bullet or equivalent
indication).  The item should be marked as 'selected' when the string
state is equal to the value of the I<target> property.

See C<set-action-and-target()> or
C<g-menu-set-detailed-action()> for two equivalent calls that are
probably more convenient for most uses.



  method set-action-and-target-value ( Str $action, N-GObject $target_value )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $action; (nullable): the name of the action for this item
=item N-GObject $target_value; (nullable): a B<GVariant> to use as the action target

=end pod

method set-action-and-target-value ( Str $action, N-GObject $target_value ) {
  my $no = …;
  $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;

  g_menu_item_set_action_and_target_value(
    self._get-native-object-no-reffing, $action, $target_value
  );
}

sub g_menu_item_set_action_and_target_value ( N-GObject $menu_item, gchar-ptr $action, N-GObject $target_value  )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:set-attribute:
=begin pod
=head2 set-attribute


Sets or unsets an attribute on I<menu-item>.

The attribute to set or unset is specified by I<attribute>. This
can be one of the standard attribute names C<G-MENU-ATTRIBUTE-LABEL>,
C<G-MENU-ATTRIBUTE-ACTION>, C<G-MENU-ATTRIBUTE-TARGET>, or a custom
attribute name.
Attribute names are restricted to lowercase characters, numbers
and '-'. Furthermore, the names must begin with a lowercase character,
must not end with a '-', and must not contain consecutive dashes.

If I<format-string> is non-C<undefined> then the proper position parameters
are collected to create a B<GVariant> instance to use as the attribute
value.  If it is C<undefined> then the positional parameterrs are ignored
and the named attribute is unset.

See also C<set-attribute-value()> for an equivalent call
that directly accepts a B<GVariant>.



  method set-attribute ( Str $attribute, Str $format_string )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $attribute; the attribute to set
=item Str $format_string; (nullable): a B<GVariant> format string, or C<undefined> @...: positional parameters, as per I<format-string>

=end pod

method set-attribute ( Str $attribute, Str $format_string ) {

  g_menu_item_set_attribute(
    self._get-native-object-no-reffing, $attribute, $format_string
  );
}

sub g_menu_item_set_attribute ( N-GObject $menu_item, gchar-ptr $attribute, gchar-ptr $format_string, Any $any = Any  )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:set-attribute-value:
=begin pod
=head2 set-attribute-value


Sets or unsets an attribute on I<menu-item>.

The attribute to set or unset is specified by I<attribute>. This
can be one of the standard attribute names C<G-MENU-ATTRIBUTE-LABEL>,
C<G-MENU-ATTRIBUTE-ACTION>, C<G-MENU-ATTRIBUTE-TARGET>, or a custom
attribute name.
Attribute names are restricted to lowercase characters, numbers
and '-'. Furthermore, the names must begin with a lowercase character,
must not end with a '-', and must not contain consecutive dashes.

must consist only of lowercase
ASCII characters, digits and '-'.

If I<value> is non-C<undefined> then it is used as the new value for the
attribute.  If I<value> is C<undefined> then the attribute is unset. If
the I<value> B<GVariant> is floating, it is consumed.

See also C<set-attribute()> for a more convenient way to do
the same.



  method set-attribute-value ( Str $attribute, N-GObject $value )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $attribute; the attribute to set
=item N-GObject $value; (nullable): a B<GVariant> to use as the value, or C<undefined>

=end pod

method set-attribute-value ( Str $attribute, N-GObject $value ) {
  my $no = …;
  $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;

  g_menu_item_set_attribute_value(
    self._get-native-object-no-reffing, $attribute, $value
  );
}

sub g_menu_item_set_attribute_value ( N-GObject $menu_item, gchar-ptr $attribute, N-GObject $value  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-detailed-action:
=begin pod
=head2 set-detailed-action


Sets the "action" and possibly the "target" attribute of I<menu-item>.

The format of I<detailed-action> is the same format parsed by
C<g-action-parse-detailed-name()>.

See C<set-action-and-target()> or
C<g-menu-set-action-and-target-value()> for more flexible (but
slightly less convenient) alternatives.

See also C<g-menu-set-action-and-target-value()> for a description of
the semantics of the action and target attributes.



  method set-detailed-action ( Str $detailed_action )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $detailed_action; the "detailed" action string

=end pod

method set-detailed-action ( Str $detailed_action ) {

  g_menu_item_set_detailed_action(
    self._get-native-object-no-reffing, $detailed_action
  );
}

sub g_menu_item_set_detailed_action ( N-GObject $menu_item, gchar-ptr $detailed_action  )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:set-icon:
=begin pod
=head2 set-icon


Sets (or unsets) the icon on I<menu-item>.

This call is the same as calling C<g-icon-serialize()> and using the
result as the value to C<set-attribute-value()> for
C<G-MENU-ATTRIBUTE-ICON>.

This API is only intended for use with "noun" menu items; things like
bookmarks or applications in an "Open With" menu.  Don't use it on
menu items corresponding to verbs (eg: stock icons for 'Save' or
'Quit').

If I<icon> is C<undefined> then the icon is unset.



  method set-icon ( GIcon $icon )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item GIcon $icon; a B<GIcon>, or C<undefined>

=end pod

method set-icon ( GIcon $icon ) {

  g_menu_item_set_icon(
    self._get-native-object-no-reffing, $icon
  );
}

sub g_menu_item_set_icon ( N-GObject $menu_item, GIcon $icon  )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:set-label:
=begin pod
=head2 set-label


Sets or unsets the "label" attribute of I<menu-item>.

If I<label> is non-C<undefined> it is used as the label for the menu item.  If
it is C<undefined> then the label attribute is unset.



  method set-label ( Str $label )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $label; (nullable): the label to set, or C<undefined> to unset

=end pod

method set-label ( Str $label ) {

  g_menu_item_set_label(
    self._get-native-object-no-reffing, $label
  );
}

sub g_menu_item_set_label ( N-GObject $menu_item, gchar-ptr $label  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-link:
=begin pod
=head2 set-link


Creates a link from I<menu-item> to I<model> if non-C<undefined>, or unsets it.

Links are used to establish a relationship between a particular menu
item and another menu.  For example, C<G-MENU-LINK-SUBMENU> is used to
associate a submenu with a particular menu item, and C<G-MENU-LINK-SECTION>
is used to create a section. Other types of link can be used, but there
is no guarantee that clients will be able to make sense of them.
Link types are restricted to lowercase characters, numbers
and '-'. Furthermore, the names must begin with a lowercase character,
must not end with a '-', and must not contain consecutive dashes.



  method set-link ( Str $link, N-GObject $model )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item Str $link; type of link to establish or unset
=item N-GObject $model; (nullable): the B<Gnome::Gio::MenuModel> to link to (or C<undefined> to unset)

=end pod

method set-link ( Str $link, N-GObject $model ) {

  g_menu_item_set_link(
    self._get-native-object-no-reffing, $link, $model
  );
}

sub g_menu_item_set_link ( N-GObject $menu_item, gchar-ptr $link, N-GObject $model  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-section:
=begin pod
=head2 set-section


Sets or unsets the "section" link of I<menu-item> to I<section>.

The effect of having one menu appear as a section of another is
exactly as it sounds: the items from I<section> become a direct part of
the menu that I<menu-item> is added to.  See C<new-section()>
for more information about what it means for a menu item to be a
section.



  method set-section ( N-GObject $section )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item N-GObject $section; (nullable): a B<Gnome::Gio::MenuModel>, or C<undefined>

=end pod

method set-section ( N-GObject $section ) {

  g_menu_item_set_section(
    self._get-native-object-no-reffing, $section
  );
}

sub g_menu_item_set_section ( N-GObject $menu_item, N-GObject $section  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-submenu:
=begin pod
=head2 set-submenu


Sets or unsets the "submenu" link of I<menu-item> to I<submenu>.

If I<submenu> is non-C<undefined>, it is linked to.  If it is C<undefined> then the
link is unset.

The effect of having one menu appear as a submenu of another is
exactly as it sounds.



  method set-submenu ( N-GObject $submenu )

=item N-GObject $menu_item; a B<Gnome::Gio::MenuItem>
=item N-GObject $submenu; (nullable): a B<Gnome::Gio::MenuModel>, or C<undefined>

=end pod

method set-submenu ( N-GObject $submenu ) {

  g_menu_item_set_submenu(
    self._get-native-object-no-reffing, $submenu
  );
}

sub g_menu_item_set_submenu ( N-GObject $menu_item, N-GObject $submenu  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_menu_item_new:
#`{{
=begin pod
=head2 new


Creates a new B<Gnome::Gio::MenuItem>.

If I<label> is non-C<undefined> it is used to set the "label" attribute of the
new item.

If I<detailed-action> is non-C<undefined> it is used to set the "action" and
possibly the "target" attribute of the new item.  See
C<set-detailed-action()> for more information.

Returns: a new B<Gnome::Gio::MenuItem>

  method item-new ( Str $label, Str $detailed_action --> N-GObject )

=item Str $label; (nullable): the section label, or C<undefined>
=item Str $detailed_action; (nullable): the detailed action string, or C<undefined>

=end pod

method item-new ( Str $label, Str $detailed_action --> N-GObject ) {

  g_menu_item_new(
    self._get-native-object-no-reffing, $label, $detailed_action
  );
}
}}

sub _g_menu_item_new (
  gchar-ptr $label, gchar-ptr $detailed_action --> N-GObject
) is symbol('g_menu_item_new')
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_menu_item_new_from_model:
#`{{
=begin pod
=head2 item-new-from-model


Creates a B<Gnome::Gio::MenuItem> as an exact copy of an existing menu item in a
B<Gnome::Gio::MenuModel>.

I<item-index> must be valid (ie: be sure to call
C<model-get-n-items()> first).

Returns: a new B<Gnome::Gio::MenuItem>.



  method item-new-from-model ( N-GObject $model, Int $item_index --> N-GObject )

=item N-GObject $model; a B<Gnome::Gio::MenuModel>
=item Int $item_index; the index of an item in I<model>

=end pod

method item-new-from-model ( N-GObject $model, Int $item_index --> N-GObject ) {

  g_menu_item_new_from_model(
    self._get-native-object-no-reffing, $model, $item_index
  );
}
}}

sub _g_menu_item_new_from_model ( N-GObject $model, gint $item_index --> N-GObject )
  is symbol('g_menu_item_new_from_model')
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_menu_item_new_section:
#`{{
=begin pod
=head2 item-new-section


Creates a new B<Gnome::Gio::MenuItem> representing a section.

This is a convenience API around C<item-new()> and
C<g-menu-item-set-section()>.

The effect of having one menu appear as a section of another is
exactly as it sounds: the items from I<section> become a direct part of
the menu that I<menu-item> is added to.

Visual separation is typically displayed between two non-empty
sections.  If I<label> is non-C<undefined> then it will be encorporated into
this visual indication.  This allows for labeled subsections of a
menu.

As a simple example, consider a typical "Edit" menu from a simple
program.  It probably contains an "Undo" and "Redo" item, followed by
a separator, followed by "Cut", "Copy" and "Paste".

This would be accomplished by creating three B<Gnome::Gio::Menu> instances.  The
first would be populated with the "Undo" and "Redo" items, and the
second with the "Cut", "Copy" and "Paste" items.  The first and
second menus would then be added as submenus of the third.  In XML
format, this would look something like the following:

  <menu id='edit-menu'>
    <section>
      <item label='Undo'/>
      <item label='Redo'/>
    </section>
    <section>
      <item label='Cut'/>
      <item label='Copy'/>
      <item label='Paste'/>
    </section>
  </menu>


The following example is exactly equivalent.  It is more illustrative
of the exact relationship between the menus and items (keeping in
mind that the 'link' element defines a new menu that is linked to the
containing one).  The style of the second example is more verbose and
difficult to read (and therefore not recommended except for the
purpose of understanding what is really going on).

  <menu id='edit-menu'>
    <item>
      <link name='section'>
        <item label='Undo'/>
        <item label='Redo'/>
      </link>
    </item>
    <item>
      <link name='section'>
        <item label='Cut'/>
        <item label='Copy'/>
        <item label='Paste'/>
      </link>
    </item>
  </menu>


Returns: a new B<Gnome::Gio::MenuItem>



  method item-new-section ( Str $label, N-GObject $section --> N-GObject )

=item Str $label; the section label, or C<undefined>
=item N-GObject $section; a B<Gnome::Gio::MenuModel> with the items of the section

=end pod

method item-new-section ( Str $label, N-GObject $section --> N-GObject ) {

  g_menu_item_new_section(
    self._get-native-object-no-reffing, $label, $section
  );
}
}}

sub _g_menu_item_new_section ( gchar-ptr $label, N-GObject $section --> N-GObject )
  is native(&gio-lib)
  is symbol('g_menu_item_new_section')
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_menu_item_new_submenu:
#`{{
=begin pod
=head2 item-new-submenu


Creates a new B<Gnome::Gio::MenuItem> representing a submenu.

This is a convenience API around C<item-new()> and
C<g-menu-item-set-submenu()>.

Returns: a new B<Gnome::Gio::MenuItem>



  method item-new-submenu ( Str $label, N-GObject $submenu --> N-GObject )

=item Str $label; (nullable): the section label, or C<undefined>
=item N-GObject $submenu; a B<Gnome::Gio::MenuModel> with the items of the submenu

=end pod

method item-new-submenu ( Str $label, N-GObject $submenu --> N-GObject ) {

  g_menu_item_new_submenu(
    self._get-native-object-no-reffing, $label, $submenu
  );
}
}}

sub _g_menu_item_new_submenu ( gchar-ptr $label, N-GObject $submenu --> N-GObject )
  is native(&gio-lib)
  is symbol('g_menu_item_new_submenu')
  { * }
