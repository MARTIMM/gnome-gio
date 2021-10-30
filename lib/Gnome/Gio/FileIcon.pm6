#TL:1:Gnome::Gio::FileIcon:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::FileIcon

Icons pointing to an image file


=comment ![](images/X.png)


=head1 Description

I<include>: gio/gio.h

B<Gnome::Gio::FileIcon> specifies an icon by pointing to an image file
to be used as icon.


=head2 See Also

B<Gnome::Gio::Icon>, B<Gnome::Gio::LoadableIcon>


=head1 Synopsis

=head2 Declaration

  unit class Gnome::Gio::FileIcon;
  also is Gnome::GObject::Object;
  also does Gnome::Gio::Icon;


=head2 Uml Diagram

![](plantuml/FileIcon.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::FileIcon;

  unit class MyGuiClass;
  also is Gnome::Gio::FileIcon;

  submethod new ( |c ) {
    # let the Gnome::Gio::FileIcon class process the options
    self.bless( :GFileIcon, |c);
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
use Gnome::Gio::File;
#use Gnome::Gio::Enums;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::FileIcon:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::GObject::Object;
also does Gnome::Gio::Icon;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :file

Create a new FileIcon object.

  multi method new ( N-GObject :$file! )


=head3 :string

Generate a B<Gnome::Gio::FileIcon> instance from a string. This function can fail if the string is not valid - see C<Gnome::Gio::Icon.to-string()> for discussion. When it fails, the error object in the attribute C<$.last-error> will be set.

=comment If your application or library provides one or more B<Gnome::Gio::Icon> implementations you need to ensure that each B<Gnome::Glib::Type> is registered with the type system prior to calling C<g-icon-new-for-string()>.

  method new ( Str :$strinng! )

=item Str $string; A string obtained via C<Gnome::Gio::Icon.to-string()>.


=head3 :native-object

Create a FileIcon object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

# TM:0:new():inheriting
#TM:1:new(:file):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::FileIcon' #`{{ or %options<GFileIcon> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<file> {
        $no = %options<file>;
        $no .= get-native-object-no-reffing unless $no ~~ N-GObject;
        $no = _g_file_icon_new($no);
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
        $no = _g_file_icon_new();
      }
      }}

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GFileIcon');
  }
}


#-------------------------------------------------------------------------------
#TM:1:get-file:
#TM:1:get-file-rk:
=begin pod
=head2 get-file, get-file-rk

Gets the B<Gnome::Gio::File> associated with the given I<icon>.

Returns: a B<Gnome::Gio::File>, or C<undefined>.

  method get-file ( --> N-GFile )
  method get-file-rk ( --> Gnome::Gio::File )

=end pod

method get-file ( --> N-GFile ) {
  g_file_icon_get_file(self.get-native-object-no-reffing)
}

method get-file-rk ( --> Gnome::Gio::File ) {
  Gnome::Gio::File.new(
    :native-object(g_file_icon_get_file(self.get-native-object-no-reffing))
  )
}

sub g_file_icon_get_file (
  N-GObject $icon --> N-GFile
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_file_icon_new:
#`{{
=begin pod
=head2 _g_file_icon_new

Creates a new icon for a file.

Returns:  (type GFileIcon): a B<Gnome::Gio::Icon> for the given I<file>, or C<undefined> on error.

  method _g_file_icon_new ( N-GObject $file --> N-GObject )

=item N-GObject $file; a B<Gnome::Gio::File>.
=end pod
}}

sub _g_file_icon_new ( N-GObject $file --> N-GObject )
  is native(&gio-lib)
  is symbol('g_file_icon_new')
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
=comment #TP:0:file:
=head3 file: file

The file containing the icon.Widget type: G_TYPE_FILE

The B<Gnome::GObject::Value> type of property I<file> is C<G_TYPE_OBJECT>.
=end pod
