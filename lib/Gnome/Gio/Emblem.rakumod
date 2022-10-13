#TL:1:Gnome::Gio::Emblem:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Emblem

An object for emblems


=comment ![](images/X.png)


=head1 Description

B<Gnome::Gio::Emblem> is an implementation of B<Gnome::Gio::Icon> that supports having an emblem, which is an icon with additional properties. It can than be added to a B<Gnome::Gio::EmblemedIcon>.

Currently, only metainformation about the emblem's origin is  supported. More may be added in the future.


=head2 See Also

B<Gnome::Gio::Icon>, B<Gnome::Gio::EmblemedIcon>, B<Gnome::Gio::LoadableIcon>, B<Gnome::Gio::ThemedIcon>


=head1 Synopsis

=head2 Declaration

  unit class Gnome::Gio::Emblem;
  also is Gnome::GObject::Object;
  also does Gnome::Gio::Icon;


=head2 Uml Diagram

![](plantuml/Emblem.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::Emblem;

  unit class MyGuiClass;
  also is Gnome::Gio::Emblem;

  submethod new ( |c ) {
    # let the Gnome::Gio::Emblem class process the options
    self.bless( :GEmblem, |c);
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

#-------------------------------------------------------------------------------
unit class Gnome::Gio::Emblem:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::GObject::Object;
also does Gnome::Gio::Icon;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :icon

Create a new Emblem object.

  multi method new ( N-GObject :$icon!, UInt :$origin? )

=item N-GObject $icon; an object containing the icon.
=item UInt $origin; a GEmblemOrigin enum defining the emblem's origin


=head3 :string

Generate a B<Gnome::Gio::FileIcon> instance from a string. This function can fail if the string is not valid - see C<Gnome::Gio::Icon.to-string()> for discussion. When it fails, the error object in the attribute C<$.last-error> will be set.

=comment If your application or library provides one or more B<Gnome::Gio::Icon> implementations you need to ensure that each B<Gnome::Glib::Type> is registered with the type system prior to calling C<g-icon-new-for-string()>.

  method new ( Str :$string! )

=item Str $string; A string obtained via C<Gnome::Gio::Icon.to-string()>.


=head3 :native-object

Create a Emblem object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

# TM:0:new():inheriting
#TM:1:new(:icon):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::Emblem' #`{{ or %options<GEmblem> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<icon> {
        $no = %options<icon>;
        $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        if ?%options<origin> {
          $no = _g_emblem_new_with_origin( $no, %options<origin>);
        }

        else {
          $no = _g_emblem_new($no);
        }
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
        $no = _g_emblem_new();
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GEmblem');
  }
}

##`{{ TODO gnome instantiation of interfaces, what is returned??
#-------------------------------------------------------------------------------
# TM:1:get-icon:
# TM:1:get-icon-rk:
=begin pod
=head2 get-icon, get-icon-rk

Gives back the icon from this I<emblem>.

Returns: a B<Gnome::Gio::Emblem>. The returned object belongs to the emblem and should not be modified or freed.

  method get-icon ( --> N-GObject )
  method get-icon-rk ( --> Gnome::Gio::Emblem )

=end pod

method get-icon ( --> N-GObject ) {
  g_emblem_get_icon(self._get-native-object-no-reffing)
}

method get-icon-rk ( --> Gnome::Gio::Emblem ) {
  my GEnum $origin = g_emblem_get_origin(self._get-native-object-no-reffing);
  if ?$origin {
    Gnome::Gio::Emblem.new(
      :icon(g_emblem_get_icon(self._get-native-object-no-reffing))
      :$origin
    )
  }

  else {
    Gnome::Gio::Emblem.new(
      :icon(g_emblem_get_icon(self._get-native-object-no-reffing))
    )
  }
}

sub g_emblem_get_icon (
  N-GObject $emblem --> N-GObject
) is native(&gio-lib)
  { * }
#}}

#-------------------------------------------------------------------------------
#TM:1:get-origin:
=begin pod
=head2 get-origin

Gets the origin of the emblem.

Returns: the origin of the emblem as an GEmblemOrigin enum

  method get-origin ( --> GEmblemOrigin )

=end pod

method get-origin ( --> GEmblemOrigin ) {
  GEmblemOrigin(g_emblem_get_origin(self._get-native-object-no-reffing))
}

sub g_emblem_get_origin (
  N-GObject $emblem --> GEnum
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_emblem_new:
#`{{
=begin pod
=head2 _g_emblem_new

Creates a new emblem for I<icon>.

Returns: a new B<Gnome::Gio::Emblem>.

  method _g_emblem_new ( N-GObject $icon --> N-GObject )

=item N-GObject $icon; a GIcon containing the icon.
=end pod
}}

sub _g_emblem_new ( N-GObject $icon --> N-GObject )
  is native(&gio-lib)
  is symbol('g_emblem_new')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_emblem_new_with_origin:
#`{{
=begin pod
=head2 _g_emblem_new_with_origin

Creates a new emblem for I<icon>.

Returns: a new B<Gnome::Gio::Emblem>.

  method _g_emblem_new_with_origin ( N-GObject $icon, GEmblemOrigin $origin --> N-GObject )

=item N-GObject $icon; a GIcon containing the icon.
=item GEmblemOrigin $origin; a GEmblemOrigin enum defining the emblem's origin
=end pod
}}

sub _g_emblem_new_with_origin ( N-GObject $icon, GEnum $origin --> N-GObject )
  is native(&gio-lib)
  is symbol('g_emblem_new_with_origin')
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
=comment #TP:0:icon:
=head3 The icon of the emblem: icon

The actual icon of the emblem
Widget type: G-TYPE-OBJECT

The B<Gnome::GObject::Value> type of property I<icon> is C<G_TYPE_OBJECT>.

=comment -----------------------------------------------------------------------
=comment #TP:0:origin:
=head3 GEmblem’s origin: origin

Tells which origin the emblem is derived from
Default value: False

The B<Gnome::GObject::Value> type of property I<origin> is C<G_TYPE_ENUM>.
=end pod
