#TL:1:Gnome::Gio::ThemedIcon:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::ThemedIcon

Icon theming support


=comment ![](images/X.png)


=head1 Description

I<include>: gio/gio.h

B<Gnome::Gio::ThemedIcon> is an implementation of B<Gnome::Gio::Icon> that supports icon themes.
B<Gnome::Gio::ThemedIcon> contains a list of all of the icons present in an icon
theme, so that icons can be looked up quickly. B<Gnome::Gio::ThemedIcon> does
not provide actual pixmaps for icons, just the icon names.
Ideally something like C<gtk-icon-theme-choose-icon()> should be used to
resolve the list of names so that fallback icons work nicely with
themes that inherit other themes.


=head2 See Also

B<Gnome::Gio::Icon>, B<Gnome::Gio::LoadableIcon>


=head1 Synopsis

=head2 Declaration

  unit class Gnome::Gio::ThemedIcon;
  also is Gnome::GObject::Object;
  also does Gnome::Gio::Icon;


=comment head2 Uml Diagram

=comment ![](plantuml/.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::ThemedIcon;

  unit class MyGuiClass;
  also is Gnome::Gio::ThemedIcon;

  submethod new ( |c ) {
    # let the Gnome::Gio::ThemedIcon class process the options
    self.bless( :GThemedIcon, |c);
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
unit class Gnome::Gio::ThemedIcon:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::GObject::Object;
also does Gnome::Gio::Icon;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new


=head3 :iconname

Creates a new themed icon for I<iconname>.

  method new ( Str :$iconname! )

=item Str $iconname; A string.


=head3 :iconnames

Creates a new themed icon for I<iconnames>.

  method new ( Str :@iconnames! )

=item Str @iconnames; An array of strings.


=head3 :fallbacks

Creates a new themed icon for I<iconname>, and all the names that can be created by shortening I<iconname> at '-' characters.

  method new( Str :$fallbacks! )

=head4 Example

In the following example, I<$icon1> and I<$icon2> are equivalent:

  my @names = < gnome-dev-cdrom-audio gnome-dev-cdrom gnome-dev gnome >;
  my Gnome::Gio::ThemedIcon ( $icon1, $icon2);
  $icon1 .= new(:iconnames(@names));
  $icon2 .= new(:fallbacks<gnome-dev-cdrom-audio>);


=head3 :string

Generate a B<Gnome::Gio::FileIcon> instance from a string. This function can fail if the string is not valid - see C<Gnome::Gio::Icon.to-string()> for discussion. When it fails, the error object in the attribute C<$.last-error> will be set.

=comment If your application or library provides one or more B<Gnome::Gio::Icon> implementations you need to ensure that each B<Gnome::Glib::Type> is registered with the type system prior to calling C<g-icon-new-for-string()>.

  method new ( Str :$string! )

=item Str $string; A string obtained via C<Gnome::Gio::Icon.to-string()>.


=head3 :native-object

Create a ThemedIcon object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

# TM:0:new():inheriting
#TM:1:new(:iconname):
#TM:1:new(:iconnames):
#TM:1:new(:string):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::ThemedIcon' #`{{ or %options<GThemedIcon> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<iconname> {
        $no = _g_themed_icon_new(%options<iconname>);
      }

      elsif ? %options<iconnames> {
        my $carray = CArray[Str].new(|%options<iconnames>);
        $no = _g_themed_icon_new_from_names(
          $carray, %options<iconnames>.elems
        );
      }

      elsif ? %options<fallbacks> {
        $no = _g_themed_icon_new_with_default_fallbacks(
          %options<fallbacks>
        );
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
        $no = _g_themed_icon_new();
      }
      }}

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GThemedIcon');
  }
}


#-------------------------------------------------------------------------------
#TM:1:append-name:
=begin pod
=head2 append-name

Append a name to the list of icons from within I<icon>.

=comment Note that doing so invalidates the hash computed by prior calls to C<g-icon-hash()>.

  method append-name ( Str $iconname )

=item Str $iconname; name of icon to append to list of icons from within I<icon>.
=end pod

method append-name ( Str $iconname ) {
  g_themed_icon_append_name( self.get-native-object-no-reffing, $iconname);
}

sub g_themed_icon_append_name (
  N-GObject $icon, gchar-ptr $iconname
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-names:
=begin pod
=head2 get-names

Gets the names of icons from within I<icon>.

  method get-names ( --> Array )

=end pod

method get-names ( --> Array ) {
  my CArray[Str] $ntn = g_themed_icon_get_names(
    self.get-native-object-no-reffing,
  );

  my Array $tn = [];
  my $i = 0;
  while ?$ntn[$i] {
    $tn.push($ntn[$i]);
    $i++;
  }

  $tn
}

sub g_themed_icon_get_names (
  N-GObject $icon --> gchar-pptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:prepend-name:
=begin pod
=head2 prepend-name

Prepend a name to the list of icons from within I<icon>.

Note that doing so invalidates the hash computed by prior calls to C<g-icon-hash()>.

  method prepend-name ( Str $iconname )

=item Str $iconname; name of icon to prepend to list of icons from within I<icon>.
=end pod

method prepend-name ( Str $iconname ) {

  g_themed_icon_prepend_name(
    self.get-native-object-no-reffing, $iconname
  );
}

sub g_themed_icon_prepend_name (
  N-GObject $icon, gchar-ptr $iconname
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_themed_icon_new:
#`{{
=begin pod
=head2 _g_themed_icon_new

Creates a new themed icon for I<iconname>.

Returns:  (type GThemedIcon): a new B<Gnome::Gio::ThemedIcon>.

  method _g_themed_icon_new ( Str $iconname --> N-GObject )

=item Str $iconname; a string containing an icon name.
=end pod
}}

sub _g_themed_icon_new ( gchar-ptr $iconname --> N-GObject )
  is native(&gio-lib)
  is symbol('g_themed_icon_new')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_themed_icon_new_from_names:
#`{{
=begin pod
=head2 _g_themed_icon_new_from_names

Creates a new themed icon for I<iconnames>.

Returns:  (type GThemedIcon): a new B<Gnome::Gio::ThemedIcon>

  method _g_themed_icon_new_from_names ( CArray[Str] $iconnames, Int() $len --> N-GObject )

=item CArray[Str] $iconnames; (array length=len): an array of strings containing icon names.
=item Int() $len; the length of the I<iconnames> array, or -1 if I<iconnames> is  C<undefined>-terminated
=end pod
}}

sub _g_themed_icon_new_from_names ( gchar-pptr $iconnames, gint $len --> N-GObject )
  is native(&gio-lib)
  is symbol('g_themed_icon_new_from_names')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_themed_icon_new_with_default_fallbacks:
#`{{
=begin pod
=head2 _g_themed_icon_new_with_default_fallbacks

Creates a new themed icon for I<iconname>, and all the names that can be created by shortening I<iconname> at '-' characters.

In the following example, I<icon1> and I<icon2> are equivalent: |[<!-- language="C" --> const char *names[] = { "gnome-dev-cdrom-audio", "gnome-dev-cdrom", "gnome-dev", "gnome" };

icon1 = new-from-names (names, 4); icon2 = g-themed-icon-new-with-default-fallbacks ("gnome-dev-cdrom-audio"); ]|

Returns:  (type GThemedIcon): a new B<Gnome::Gio::ThemedIcon>.

  method _g_themed_icon_new_with_default_fallbacks ( Str $iconname --> N-GObject )

=item Str $iconname; a string containing an icon name
=end pod
}}

sub _g_themed_icon_new_with_default_fallbacks ( gchar-ptr $iconname --> N-GObject )
  is native(&gio-lib)
  is symbol('g_themed_icon_new_with_default_fallbacks')
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
=comment #TP:0:name:
=head3 name: name

The icon name.

The B<Gnome::GObject::Value> type of property I<name> is C<G_TYPE_STRING>.

=comment -----------------------------------------------------------------------
=comment #TP:0:names:
=head3 names: names

A C<null>-terminated array of icon names.

The B<Gnome::GObject::Value> type of property I<names> is C<G_TYPE_BOXED>.

=comment -----------------------------------------------------------------------
=comment #TP:0:use-default-fallbacks:
=head3 use default fallbacks: use-default-fallbacks

Whether to use the default fallbacks found by shortening the icon name
at '-' characters. If the "names" array has more than one element,
ignores any past the first.

The B<Gnome::GObject::Value> type of property I<use-default-fallbacks> is C<G_TYPE_BOOLEAN>.
=end pod
