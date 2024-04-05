#TL:1:Gnome::Gio::MenuItem:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::MenuItem

An entry in a menu

=comment ![](images/X.png)

=head1 Description

B<Gnome::Gio::Menu> is a simple implementation of B<Gnome::Gio::MenuModel>. You populate a B<Gnome::Gio::Menu> by adding B<Gnome::Gio::MenuItem> instances to it.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::MenuItem;
  also is Gnome::GObject::Object;


=head2 Uml Diagram

![](plantuml/MenuModel.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::MenuItem:api<1>;

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

#use Gnome::N::X:api<1>;
use Gnome::N::NativeLib:api<1>;
use Gnome::N::N-GObject:api<1>;
use Gnome::N::GlibToRakuTypes:api<1>;

use Gnome::Glib::Variant:api<1>;
use Gnome::Glib::VariantType:api<1>;

use Gnome::GObject::Object:api<1>;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::MenuItem:auth<github:MARTIMM>:api<1>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :label

Creates a menu item. Call one of C<set-action-and-target-value>, C<set-detailed-action>, C<set-section>, C<set-submenu> to set purpose of this menu item.

  multi method new ( Str :$label! )

=item $label; the menu item label


=head3 :label, :action

Creates a new B<Gnome::Gio::MenuItem>.

If I<$label> is defined, then it is used to set the "label" attribute of the new item.

I<$action> is used to set the "action" and possibly the "target" attribute of the new item.  See C<set-detailed-action()> for more information.

  multi method new ( Str :$label?, Str :$action! )

=item $label; the menu item label, or C<undefined>
=item $action; the detailed action string


=head3 :model, :item-index

Creates a B<Gnome::Gio::MenuItem> as an exact copy of an existing menu item in a
B<Gnome::Gio::MenuModel>.

I<$item-index> must be valid (ie: be sure to call C<model-get-n-items()> first).

  multi method new ( N-GObject :$model!, Int :$item-index! )


=head3 :section, :label

Creates a new B<Gnome::Gio::MenuItem> representing a section.

This is a convenience API around C<new(:label<…>)> followed by C<set-section()>.

The effect of having one menu appear as a section of another is exactly as it sounds: the items from I<$section> become a direct part of the menu that this menu item is added to.

Visual separation is typically displayed between two non-empty sections.  If I<$label> is defined then it will be encorporated into this visual indication. This allows for labeled subsections of a menu.

As a simple example, consider a typical "Edit" menu from a simple program.  It probably contains an "Undo" and "Redo" item, followed by a separator, followed by "Cut", "Copy" and "Paste".

This would be accomplished by creating three B<Gnome::Gio::Menu> instances.  The first would be populated with the "Undo" and "Redo" items, and the second with the "Cut", "Copy" and "Paste" items.  The first and second menus would then be added as submenus of the third. In XML format, this would look something like the following:

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


The following example is exactly equivalent. It is more illustrative of the exact relationship between the menus and items (keeping in mind that the 'link' element defines a new menu that is linked to the containing one).

The style of the second example is more verbose and difficult to read (and therefore not recommended except for the purpose of understanding what is really going on).

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

  multi method new ( Str :$label?, N-GObject :$section! )

=item $label; the menu item label, or C<undefined>
=item $section; a B<Gnome::Gio::MenuModel> with the items of the section


=head3 :submenu, :label

Creates a new B<Gnome::Gio::MenuItem> representing a submenu.

This is a convenience API around C<new()> followed by C<set-submenu()>.

  method item-new-submenu ( Str :$label?, N-GObject :$submenu! )

=item $label; the section label, or C<undefined>
=item $submenu; a B<Gnome::Gio::MenuModel> with the items of the submenu


=head3 :native-object

Create a Menu object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )


=head3 :build-id

Create a Menu object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )


=end pod

#TM:1:new(:label):
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
      my N-GObject() $no;
      if %options<action>:exists {
        $no = _g_menu_item_new( %options<label>//Str, %options<action>);
      }

      elsif %options<section>:exists {
        $no = %options<section>;
        $no = _g_menu_item_new_section( %options<label>//Str, $no);
      }

      elsif %options<submenu>:exists {
        $no = %options<submenu>;
        $no = _g_menu_item_new_submenu( %options<label>//Str, $no);
      }

      elsif %options<model>:exists and %options<item-index>:exists {
        $no = %options<model>;
        $no = _g_menu_item_new_from_model( $no, %options<item-index>);
      }

      elsif %options<label>:exists {
        $no = _g_menu_item_new( %options<label>, Nil);
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
#TM:0:get-attribute:
=begin pod
=head2 get-attribute

Queries the named I<attribute> on I<menu_item>.

If the attribute exists and matches the B<Gnome::Gio::VariantType> corresponding to I<format_string> then I<format_string> is used to deconstruct the value into the positional parameters and C<True> is returned.

If the attribute does not exist, or it does exist but has the wrong type, then the positional parameters are ignored and C<False> is returned.

Returns: C<True> if the named attribute was found with the expected type

  method get-attribute ( Str $attribute, Str $format_string --> Bool )

=item $attribute; the attribute name to query
=item $format_string; a B<Gnome::Gio::Variant> format string @...: positional parameters, as per I<format_string>
=end pod

method get-attribute ( Str $attribute, Str $format_string --> Bool ) {
  g_menu_item_get_attribute( self._get-native-object-no-reffing, $attribute, $format_string).Bool
}

sub g_menu_item_get_attribute (
  N-GObject $menu_item, gchar-ptr $attribute, gchar-ptr $format_string, Any $any = Any --> gboolean
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:get-attribute-value:
=begin pod
=head2 get-attribute-value

Queries the named I<attribute> on I<menu_item>.

If I<expected_type> is specified and the attribute does not have this type, C<undefined> is returned. C<undefined> is also returned if the attribute simply does not exist.

Returns: the attribute value, or C<undefined>

  method get-attribute-value (
    Str $attribute, N-GObject() $expected_type
    --> N-GObject
  )

=item $attribute; the attribute name to query
=item $expected_type; the expected type of the attribute
=end pod

method get-attribute-value (
  Str $attribute, N-GObject() $expected_type --> N-GObject
) {
  g_menu_item_get_attribute_value(
    self._get-native-object-no-reffing, $attribute, $expected_type
  )
}

sub g_menu_item_get_attribute_value (
  N-GObject $menu_item, gchar-ptr $attribute, N-GObject $expected_type --> N-GObject
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-link:
=begin pod
=head2 get-link

Queries the named I<link> on I<menu_item>.

Returns: the link, or C<undefined>

  method get-link ( Str $link --> N-GObject )

=item $link; the link name to query
=end pod

method get-link ( Str $link --> N-GObject ) {
  g_menu_item_get_link( self._get-native-object-no-reffing, $link)
}

sub g_menu_item_get_link (
  N-GObject $menu_item, gchar-ptr $link --> N-GObject
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:set-action-and-target:
=begin pod
=head2 set-action-and-target

Sets or unsets the "action" and "target" attributes of I<menu_item>.

If I<action> is C<undefined> then both the "action" and "target" attributes are unset (and I<format_string> is ignored along with the positional parameters).

If I<action> is defined then the "action" attribute is set. I<format_string> is then inspected. If it is defined then the proper position parameters are collected to create a B<Gnome::Gio::Variant> instance to use as the target value. If it is C<undefined> then the positional parameters are ignored and the "target" attribute is unset.

See also C<set_action_and_target_value()> for an equivalent call that directly accepts a B<Gnome::Gio::Variant>. See C<set_detailed_action()> for a more convenient version that works with string-typed targets.

See also C<set_action_and_target_value()> for a description of the semantics of the action and target attributes.

  method set-action-and-target ( Str $action, Str $format_string )

=item $action; the name of the action for this item
=item $format_string; a GVariant format string @...: positional parameters, as per I<format_string>
=end pod

method set-action-and-target ( Str $action, Str $format_string ) {
  g_menu_item_set_action_and_target( self._get-native-object-no-reffing, $action, $format_string);
}

sub g_menu_item_set_action_and_target (
  N-GObject $menu_item, gchar-ptr $action, gchar-ptr $format_string, Any $any = Any
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:set-action-and-target-value:
=begin pod
=head2 set-action-and-target-value

Sets or unsets the "action" and "target" attributes of I<menu_item>.

If I<action> is C<undefined> then both the "action" and "target" attributes are unset (and I<target_value> is ignored).

If I<action> is defined then the "action" attribute is set. The "target" attribute is then set to the value of I<target_value> if it is defined or unset otherwise.

Normal menu items (ie: not submenu, section or other custom item types) are expected to have the "action" attribute set to identify the action that they are associated with. The state type of the action help to determine the disposition of the menu item. See B<Gnome::Gio::Action> and B<Gnome::Gio::ActionGroup> for an overview of actions.

In general, clicking on the menu item will result in activation of the named action with the "target" attribute given as the parameter to the action invocation. If the "target" attribute is not set then the action is invoked with no parameter.

If the action has no state then the menu item is usually drawn as a plain menu item (ie: with no additional decoration).

If the action has a boolean state then the menu item is usually drawn as a toggle menu item (ie: with a checkmark or equivalent indication). The item should be marked as 'toggled' or 'checked' when the boolean state is C<True>.

If the action has a string state then the menu item is usually drawn as a radio menu item (ie: with a radio bullet or equivalent indication). The item should be marked as 'selected' when the string state is equal to the value of the I<target> property.

See C<set_action_and_target()> or C<set_detailed_action()> for two equivalent calls that are probably more convenient for most uses.

  method set-action-and-target-value ( Str $action, N-GObject() $target_value )

=item $action; the name of the action for this item
=item $target_value; a B<Gnome::Gio::Variant> to use as the action target
=end pod

method set-action-and-target-value ( Str $action, N-GObject() $target_value ) {
  g_menu_item_set_action_and_target_value( self._get-native-object-no-reffing, $action, $target_value);
}

sub g_menu_item_set_action_and_target_value (
  N-GObject $menu_item, gchar-ptr $action, N-GObject $target_value
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:set-attribute:
=begin pod
=head2 set-attribute

Sets or unsets an attribute on I<menu_item>.

The attribute to set or unset is specified by I<attribute>. This can be one of the standard attribute names C<G_MENU_ATTRIBUTE_LABEL>, C<G_MENU_ATTRIBUTE_ACTION>, C<G_MENU_ATTRIBUTE_TARGET>, or a custom attribute name. Attribute names are restricted to lowercase characters, numbers and '-'. Furthermore, the names must begin with a lowercase character, must not end with a '-', and must not contain consecutive dashes.

If I<format_string> is defined then the proper position parameters are collected to create a B<Gnome::Gio::Variant> instance to use as the attribute value. If it is C<undefined> then the positional parameterrs are ignored and the named attribute is unset.

See also C<set_attribute_value()> for an equivalent call that directly accepts a B<Gnome::Gio::Variant>.

  method set-attribute ( Str $attribute, Str $format_string )

=item $attribute; the attribute to set
=item $format_string; a B<Gnome::Gio::Variant> format string, or C<undefined> @...: positional parameters, as per I<format_string>
=end pod

method set-attribute ( Str $attribute, Str $format_string ) {
  g_menu_item_set_attribute( self._get-native-object-no-reffing, $attribute, $format_string);
}

sub g_menu_item_set_attribute (
  N-GObject $menu_item, gchar-ptr $attribute, gchar-ptr $format_string, Any $any = Any
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:set-attribute-value:
=begin pod
=head2 set-attribute-value

Sets or unsets an attribute on I<menu_item>.

The attribute to set or unset is specified by I<attribute>. This can be one of the standard attribute names C<G_MENU_ATTRIBUTE_LABEL>, C<G_MENU_ATTRIBUTE_ACTION>, C<G_MENU_ATTRIBUTE_TARGET>, or a custom attribute name. Attribute names are restricted to lowercase characters, numbers and '-'. Furthermore, the names must begin with a lowercase character, must not end with a '-', and must not contain consecutive dashes.

must consist only of lowercase ASCII characters, digits and '-'.

If I<value> is defined then it is used as the new value for the attribute. If I<value> is C<undefined> then the attribute is unset. If the I<value> B<Gnome::Gio::Variant> is floating, it is consumed.

See also C<set_attribute()> for a more convenient way to do the same.

  method set-attribute-value ( Str $attribute, N-GObject() $value )

=item $attribute; the attribute to set
=item $value; a B<Gnome::Gio::Variant> to use as the value, or C<undefined>
=end pod

method set-attribute-value ( Str $attribute, N-GObject() $value ) {
  g_menu_item_set_attribute_value( self._get-native-object-no-reffing, $attribute, $value);
}

sub g_menu_item_set_attribute_value (
  N-GObject $menu_item, gchar-ptr $attribute, N-GObject $value
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-detailed-action:
=begin pod
=head2 set-detailed-action

Sets the "action" and possibly the "target" attribute of I<menu_item>.

The format of I<detailed_action> is the same format parsed by C<Gnome::Gio::Action.parse_detailed_name()>.

See C<set_action_and_target()> or C<set_action_and_target_value()> for more flexible (but slightly less convenient) alternatives.

See also C<set_action_and_target_value()> for a description of the semantics of the action and target attributes.

  method set-detailed-action ( Str $detailed_action )

=item $detailed_action; the "detailed" action string
=end pod

method set-detailed-action ( Str $detailed_action ) {
  g_menu_item_set_detailed_action( self._get-native-object-no-reffing, $detailed_action);
}

sub g_menu_item_set_detailed_action (
  N-GObject $menu_item, gchar-ptr $detailed_action
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-icon:
=begin pod
=head2 set-icon

Sets (or unsets) the icon on I<menu_item>.

This call is the same as calling C<Gnome::Gio::Icon.serialize()> and using the result as the value to C<set_attribute_value()> for C<G_MENU_ATTRIBUTE_ICON>.

This API is only intended for use with "noun" menu items; things like bookmarks or applications in an "Open With" menu. Don't use it on menu items corresponding to verbs (eg: stock icons for 'Save' or 'Quit').

If I<icon> is C<undefined> then the icon is unset.

  method set-icon ( N-GObject() $icon )

=item $icon; a B<Gnome::Gio::Icon>, or C<undefined>
=end pod

method set-icon ( N-GObject() $icon ) {
  g_menu_item_set_icon( self._get-native-object-no-reffing, $icon);
}

sub g_menu_item_set_icon (
  N-GObject $menu_item, N-GObject $icon
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-label:
=begin pod
=head2 set-label

Sets or unsets the "label" attribute of I<menu_item>.

If I<label> is defined it is used as the label for the menu item. If it is C<undefined> then the label attribute is unset.

  method set-label ( Str $label )

=item $label; the label to set, or C<undefined> to unset
=end pod

method set-label ( Str $label ) {
  g_menu_item_set_label( self._get-native-object-no-reffing, $label);
}

sub g_menu_item_set_label (
  N-GObject $menu_item, gchar-ptr $label
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-link:
=begin pod
=head2 set-link

Creates a link from I<menu_item> to I<model> if defined, or unsets it.

Links are used to establish a relationship between a particular menu item and another menu. For example, C<G_MENU_LINK_SUBMENU> is used to associate a submenu with a particular menu item, and C<G_MENU_LINK_SECTION> is used to create a section. Other types of link can be used, but there is no guarantee that clients will be able to make sense of them. Link types are restricted to lowercase characters, numbers and '-'. Furthermore, the names must begin with a lowercase character, must not end with a '-', and must not contain consecutive dashes.

  method set-link ( Str $link, N-GObject() $model )

=item $link; type of link to establish or unset
=item $model; the B<Gnome::Gio::MenuModel> to link to (or C<undefined> to unset)
=end pod

method set-link ( Str $link, N-GObject() $model ) {
  g_menu_item_set_link( self._get-native-object-no-reffing, $link, $model);
}

sub g_menu_item_set_link (
  N-GObject $menu_item, gchar-ptr $link, N-GObject $model
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-section:
=begin pod
=head2 set-section

Sets or unsets the "section" link of I<menu_item> to I<section>.

The effect of having one menu appear as a section of another is exactly as it sounds: the items from I<section> become a direct part of the menu that I<menu_item> is added to. See C<new_section()> for more information about what it means for a menu item to be a section.

  method set-section ( N-GObject() $section )

=item $section; a B<Gnome::Gio::MenuModel>, or C<undefined>
=end pod

method set-section ( N-GObject() $section ) {
  g_menu_item_set_section( self._get-native-object-no-reffing, $section);
}

sub g_menu_item_set_section (
  N-GObject $menu_item, N-GObject $section
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-submenu:
=begin pod
=head2 set-submenu

Sets or unsets the "submenu" link of I<menu_item> to I<submenu>.

If I<submenu> is defined, it is linked to. If it is C<undefined> then the link is unset.

The effect of having one menu appear as a submenu of another is exactly as it sounds.

  method set-submenu ( N-GObject() $submenu )

=item $submenu; a B<Gnome::Gio::MenuModel>, or C<undefined>
=end pod

method set-submenu ( N-GObject() $submenu ) {
  g_menu_item_set_submenu( self._get-native-object-no-reffing, $submenu);
}

sub g_menu_item_set_submenu (
  N-GObject $menu_item, N-GObject $submenu
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_menu_item_new:
#`{{
=begin pod
=head2 _g_menu_item_new

Creates a new B<Gnome::Gio::MenuItem>.

If I<label> is defined it is used to set the "label" attribute of the new item.

If I<detailed_action> is defined it is used to set the "action" and possibly the "target" attribute of the new item. See C<set_detailed_action()> for more information.

Returns: a new B<Gnome::Gio::MenuItem>

  method _g_menu_item_new ( Str $label, Str $detailed_action --> N-GObject )

=item $label; the section label, or C<undefined>
=item $detailed_action; the detailed action string, or C<undefined>
=end pod
}}

sub _g_menu_item_new ( gchar-ptr $label, gchar-ptr $detailed_action --> N-GObject )
  is native(&gio-lib)
  is symbol('g_menu_item_new')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_menu_item_new_from_model:
#`{{
=begin pod
=head2 _g_menu_item_new_from_model

Creates a B<Gnome::Gio::MenuItem> as an exact copy of an existing menu item in a B<Gnome::Gio::MenuModel>.

I<item_index> must be valid (ie: be sure to call C<g_menu_model_get_n_items()> first).

Returns: a new B<Gnome::Gio::MenuItem>.

  method _g_menu_item_new_from_model ( N-GObject() $model, Int() $item_index --> N-GObject )

=item $model; a B<Gnome::Gio::MenuModel>
=item $item_index; the index of an item in I<model>
=end pod
}}

sub _g_menu_item_new_from_model ( N-GObject $model, gint $item_index --> N-GObject )
  is native(&gio-lib)
  is symbol('g_menu_item_new_from_model')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_menu_item_new_section:
#`{{
=begin pod
=head2 _g_menu_item_new_section

Creates a new B<Gnome::Gio::MenuItem> representing a section.

This is a convenience API around C<new()> and C<set_section()>.

The effect of having one menu appear as a section of another is exactly as it sounds: the items from I<section> become a direct part of the menu that I<menu_item> is added to.

Visual separation is typically displayed between two non-empty sections. If I<label> is defined then it will be encorporated into this visual indication. This allows for labeled subsections of a menu.

As a simple example, consider a typical "Edit" menu from a simple program. It probably contains an "Undo" and "Redo" item, followed by a separator, followed by "Cut", "Copy" and "Paste".

This would be accomplished by creating three B<Gnome::Gio::Menu> instances. The first would be populated with the "Undo" and "Redo" items, and the second with the "Cut", "Copy" and "Paste" items. The first and second menus would then be added as submenus of the third. In XML format, this would look something like the following: |[ <menu id='edit-menu'> <section> <item label='Undo'/> <item label='Redo'/> </section> <section> <item label='Cut'/> <item label='Copy'/> <item label='Paste'/> </section> </menu> ]|

The following example is exactly equivalent. It is more illustrative of the exact relationship between the menus and items (keeping in mind that the 'link' element defines a new menu that is linked to the containing one). The style of the second example is more verbose and difficult to read (and therefore not recommended except for the purpose of understanding what is really going on). |[ <menu id='edit-menu'> <item> <link name='section'> <item label='Undo'/> <item label='Redo'/> </link> </item> <item> <link name='section'> <item label='Cut'/> <item label='Copy'/> <item label='Paste'/> </link> </item> </menu> ]|

Returns: a new B<Gnome::Gio::MenuItem>

  method _g_menu_item_new_section ( Str $label, N-GObject() $section --> N-GObject )

=item $label; the section label, or C<undefined>
=item $section; a B<Gnome::Gio::MenuModel> with the items of the section
=end pod
}}

sub _g_menu_item_new_section ( gchar-ptr $label, N-GObject $section --> N-GObject )
  is native(&gio-lib)
  is symbol('g_menu_item_new_section')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_menu_item_new_submenu:
#`{{
=begin pod
=head2 _g_menu_item_new_submenu

Creates a new B<Gnome::Gio::MenuItem> representing a submenu.

This is a convenience API around C<new()> and C<set_submenu()>.

Returns: a new B<Gnome::Gio::MenuItem>

  method _g_menu_item_new_submenu ( Str $label, N-GObject() $submenu --> N-GObject )

=item $label; the section label, or C<undefined>
=item $submenu; a B<Gnome::Gio::MenuModel> with the items of the submenu
=end pod
}}

sub _g_menu_item_new_submenu ( gchar-ptr $label, N-GObject $submenu --> N-GObject )
  is native(&gio-lib)
  is symbol('g_menu_item_new_submenu')
  { * }
