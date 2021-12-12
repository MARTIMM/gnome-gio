#TL:1:Gnome::Gio::EmblemedIcon:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::EmblemedIcon

Icon with emblems


=comment ![](images/X.png)


=head1 Description

I<include>: gio/gio.h

B<Gnome::Gio::EmblemedIcon> is an implementation of B<Gnome::Gio::Icon> that supports adding an emblem to an icon. Adding multiple emblems to an icon is ensured via C<add-emblem()>.

Note that B<Gnome::Gio::EmblemedIcon> allows no control over the position of the emblems. See also B<Gnome::Gio::Emblem> for more information.


=head2 See Also

B<Gnome::Gio::Icon>, B<Gnome::Gio::LoadableIcon>, B<Gnome::Gio::ThemedIcon>, B<Gnome::Gio::Emblem>


=head1 Synopsis
=head2 Declaration

  unit role Gnome::Gio::EmblemedIcon;
  also is Gnome::GObject::Object;
  also does Gnome::Gio::Icon;


=head2 Uml Diagram

![](plantuml/EmblemedIcon.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::EmblemedIcon;

  unit class MyGuiClass;
  also is Gnome::Gio::EmblemedIcon;

  submethod new ( |c ) {
    # let the Gnome::Gio::EmblemedIcon class process the options
    self.bless( :GEmblemedIcon, |c);
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

use Gnome::GObject::Object;

use Gnome::Gio::Icon;
use Gnome::Gio::Enums;

use Gnome::Glib::List;

#-------------------------------------------------------------------------------
unit role Gnome::Gio::EmblemedIcon:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::GObject::Object;
also does Gnome::Gio::Icon;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :icon, :emblem

Create a new EmblemedIcon object.

  multi method new ( N-GObject :$icon!, N-GObject :$emblem! )

=item N-GObject $icon; an object containing the icon.
=item UInt $origin; a GEmblemOrigin enum defining the emblem's origin


=head3 :string

Generate a B<Gnome::Gio::FileIcon> instance from a string. This function can fail if the string is not valid - see C<Gnome::Gio::Icon.to-string()> for discussion. When it fails, the error object in the attribute C<$.last-error> will be set.

=comment If your application or library provides one or more B<Gnome::Gio::Icon> implementations you need to ensure that each B<Gnome::Glib::Type> is registered with the type system prior to calling C<g-icon-new-for-string()>.

  method new ( Str :$string! )

=item Str $string; A string obtained via C<Gnome::Gio::Icon.to-string()>.


=head3 :native-object

Create a EmblemedIcon object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

# TM:0:new():inheriting
#TM:1:new( :icon, :emblem):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::EmblemedIcon' #`{{ or %options<GEmblemedIcon> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if %options<icon>:exists and %options<emblem>:exists {
        my $no1 = %options<icon>;
        $no1 .= get-native-object-no-reffing unless $no1 ~~ N-GObject;
        my $no2 = %options<emblem>;
        $no2 .= get-native-object-no-reffing unless $no2 ~~ N-GObject;
        $no = _g_emblemed_icon_new( $no1, $no2);
      }

      elsif ? %options<string> {
        $no = self._g_icon_new_for_string(%options<string>);
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
        $no = _g_emblemed_icon_new();
      }
      }}

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GEmblemedIcon');
  }
}


#-------------------------------------------------------------------------------
#TM:1:add-emblem:
=begin pod
=head2 add-emblem

Adds I<emblem> to the B<Gnome::Gio::List> of B<Gnome::Gio::Emblems>.

  method add-emblem ( N-GObject $emblem )

=item N-GObject $emblem; a B<Gnome::Gio::Emblem>
=end pod

method add-emblem ( $emblem is copy ) {
  $emblem .= get-native-object-no-reffing unless $emblem ~~ N-GObject;

  g_emblemed_icon_add_emblem(
    self.get-native-object-no-reffing, $emblem
  );
}

sub g_emblemed_icon_add_emblem (
  N-GObject $emblemed, N-GObject $emblem
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:clear-emblems:
=begin pod
=head2 clear-emblems

Removes all the emblems from I<icon>.

  method clear-emblems ( )

=end pod

method clear-emblems ( ) {
  g_emblemed_icon_clear_emblems(self.get-native-object-no-reffing);
}

sub g_emblemed_icon_clear_emblems (
  N-GObject $emblemed
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-emblems:
#TM:1:get-emblems-rk:
=begin pod
=head2 get-emblems, get-emblems-rk

Gets the list a B<Gnome::Glib::List> of emblems for the I<icon>.

  method get-emblems ( --> N-GList )
  method get-emblems-rk ( --> Gnome::Glib::List )

=end pod

method get-emblems ( --> N-GList ) {
  g_emblemed_icon_get_emblems(self.get-native-object-no-reffing)
}

method get-emblems-rk ( --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(:native-object(
      g_emblemed_icon_get_emblems(self.get-native-object-no-reffing)
    )
  )
}

sub g_emblemed_icon_get_emblems (
  N-GObject $emblemed --> N-GList
) is native(&gio-lib)
  { * }

##`{{ TODO gnome instantiation of interfaces, what is returned??
#-------------------------------------------------------------------------------
# TM:1:get-icon:
# TM:1:get-icon-rk:
=begin pod
=head2 get-icon

Gets the main icon for I<emblemed>.

  method get-icon ( --> N-GObject )
  method get-icon-rk ( --> Gnome::Gio::EmblemedIcon )

=end pod

method get-icon ( --> N-GObject ) {
  g_emblemed_icon_get_icon(self.get-native-object-no-reffing)
}

method get-icon-rk ( --> Gnome::Gio::EmblemedIcon ) {
  Gnome::Gio::EmblemedIcon.new(
    :icon(g_emblemed_icon_get_icon(self.get-native-object-no-reffing)),
    :emblem(N-GObject)
  )
}

sub g_emblemed_icon_get_icon (
  N-GObject $emblemed --> N-GObject
) is native(&gio-lib)
  { * }
#}}

#-------------------------------------------------------------------------------
#TM:1:_g_emblemed_icon_new:
#`{{
=begin pod
=head2 _g_emblemed_icon_new

Creates a new emblemed icon for I<icon> with the emblem I<emblem>.

Returns:  (type GEmblemedIcon): a new B<Gnome::Gio::Icon>

  method _g_emblemed_icon_new ( N-GObject $icon, N-GObject $emblem --> N-GObject )

=item N-GObject $icon; a B<Gnome::Gio::Icon>
=item N-GObject $emblem; a B<Gnome::Gio::Emblem>, or C<undefined>
=end pod
}}

sub _g_emblemed_icon_new ( N-GObject $icon, N-GObject $emblem --> N-GObject )
  is native(&gio-lib)
  is symbol('g_emblemed_icon_new')
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head1 Properties

An example of using a string type property of a B<Gnome::Gtk3::Label> object. This is just showing how to set/read a property, not that it is the best way to do it. This is because a) The class initialization often provides some options to set some of the properties and b) the classes provide many methods to modify just those properties. In the case below one can use B<new(:label('my text label'))> or B<.set-text('my text label')>.

  my Gnome::Gtk3::Label $label .= new;
  my Gnome::GObject::Value $gv .= new(:init(G_TYPE_STRING));
  $label.get-property( 'label', $gv);
  $gv.set-string('my text label');

=head2 Supported properties

=comment -----------------------------------------------------------------------
=comment #TP:0:gicon:
=head3 The base GIcon: gicon

The GIcon to attach emblems to
Widget type: G-TYPE-ICON

The B<Gnome::GObject::Value> type of property I<gicon> is C<G_TYPE_OBJECT>.
=end pod
