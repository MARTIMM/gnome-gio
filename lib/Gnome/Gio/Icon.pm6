#TL:1:Gnome::Gio::Icon:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Icon

Interface for icons


=comment ![](images/X.png)


=head1 Description

B<Gnome::Gio::Icon> is a very minimal interface for icons. It provides functions for checking the equality of two icons, hashing of icons and serializing an icon to and from strings.

B<Gnome::Gio::Icon> does not provide the actual pixmap for the icon as this is out of GIO's scope, however implementations of B<Gnome::Gio::Icon> may contain the name of an icon (see B<Gnome::Gio::ThemedIcon>), or the path to an icon (see B<Gnome::Gio::LoadableIcon>).

=comment To obtain a hash of a B<Gnome::Gio::Icon>, see C<hash()>.

To check if two B<Gnome::Gio::Icons> are equal, see C<equal()>.

=comment For serializing a B<Gnome::Gio::Icon>, use C<serialize()> and C<g-icon-deserialize()>.

=comment If you want to consume B<Gnome::Gio::Icon> (for example, in a toolkit) you must be prepared to handle at least the three following cases: B<Gnome::Gio::LoadableIcon>, B<Gnome::Gio::ThemedIcon> and B<Gnome::Gio::EmblemedIcon>. It may also make sense to have fast-paths for other cases (like handling B<Gnome::Gdk3::Pixbuf> directly, for example) but all compliant B<Gnome::Gio::Icon> implementations outside of GIO must implement B<Gnome::Gio::LoadableIcon>.

=comment If your application or library provides one or more B<Gnome::Gio::Icon> implementations you need to ensure that your new implementation also implements B<Gnome::Gio::LoadableIcon>. Additionally, you must provide an implementation of C<g-icon-serialize()> that gives a result that is understood by C<g-icon-deserialize()>, yielding one of the built-in icon types.


=head1 Synopsis

=head2 Declaration

  unit role Gnome::Gio::Icon;

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::Error;
#use Gnome::Glib::Variant;

#-------------------------------------------------------------------------------
unit role Gnome::Gio::Icon:auth<github:MARTIMM>:ver<0.1.0>;

has Gnome::Glib::Error $.last-error;

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 class N-GIconIface

GIconIface is used to implement GIcon types for various
different systems. See B<Gnome::Gio::ThemedIcon> and B<Gnome::Gio::LoadableIcon> for
examples of how to implement this interface.


=item GTypeInterface $.g-iface: The parent interface.
=item ---hash: A hash for a given B<Gnome::Gio::Icon>.
=item ---equal: Checks if two B<Gnome::Gio::Icons> are equal.
=item ---to-tokens: Serializes a B<Gnome::Gio::Icon> into tokens. The tokens must not contain any whitespace. Don't implement if the B<Gnome::Gio::Icon> can't be serialized (Since 2.20).
=item ---from-tokens: Constructs a B<Gnome::Gio::Icon> from tokens. Set the B<Gnome::Gio::Error> if the tokens are malformed. Don't implement if the B<Gnome::Gio::Icon> can't be serialized (Since 2.20).
=item ---serialize: Serializes a B<Gnome::Gio::Icon> into a B<Gnome::Gio::Variant>. Since: 2.38


=end pod

# TT:0:N-GIconIface:
class N-GIconIface is export is repr('CStruct') {
  has GTypeInterface $.g_iface;
  has guin $.t       (* hash)        (GIcon   *icon);
  has N-GObject $.icon2);
  has gint-ptr $.out_version);
  has N-GError $.error);
  has GVarian $.t *  (* serialize)   (GIcon   *icon);
}
}}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

# interfaces are not instantiated
#submethod BUILD ( *%options ) { }

#`{{
# All interface calls should become methods
#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _g_icon_interface ( $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &:("g_icon_$native-sub"); };
# check for gtk_, gdk_, g_, pango_, cairo_ !!!
  try { $s = &:("gtk_$native-sub"); } unless ?$s;
  try { $s = &:($native-sub); } if !$s and $native-sub ~~ m/^ 'gtk_' /;

  $s;
}
}}


#-------------------------------------------------------------------------------
# setup signals from interface
#method _add_g_icon_interface_signal_types ( Str $class-name ) {
#}


#-------------------------------------------------------------------------------
#TM:1:deserialize:
=begin pod
=head2 deserialize

Deserializes a B<Gnome::Gio::Icon> previously serialized using C<serialize()>.

Returns: a B<Gnome::Gio::Icon>, or C<undefined> when deserialization fails.

  method deserialize ( N-GObject $value --> N-GObject )

=item N-GObject $value; a B<Gnome::Glib::Variant> created with C<serialize()>
=end pod

method deserialize ( $value is copy --> N-GObject ) {
  $value .= get-native-object-no-reffing unless $value ~~ N-GObject;
  g_icon_deserialize($value)
}

sub g_icon_deserialize (
  N-GObject $value --> N-GObject
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:equal:
=begin pod
=head2 equal

Checks if two icons are equal.

Returns: C<True> if the icon is equal to I<$icon>. C<False> otherwise.

  method equal ( N-GObject $icon --> Bool )

=item N-GObject $icon; pointer to the other B<Gnome::Gio::Icon>.
=end pod

method equal ( $icon is copy --> Bool ) {
  $icon .= get-native-object-no-reffing unless $icon ~~ N-GObject;
  g_icon_equal( self._f('GIcon'), $icon).Bool
}

sub g_icon_equal (
  N-GObject $icon1, N-GObject $icon2 --> gboolean
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:hash:
=begin pod
=head2 hash

Gets a hash for an icon.

Virtual: hash

Returns: a B<guint> containing a hash for the I<icon>, suitable for use in a B<Gnome::Gio::HashTable> or similar data structure.

  method hash ( Pointer $icon --> UInt )

=item Pointer $icon; B<gconstpointer> to an icon object.
=end pod

method hash ( Pointer $icon --> UInt ) {
  g_icon_hash( self._f('GIcon'), $icon)
}

sub g_icon_hash (
  gpointer $icon --> guint
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:serialize:
=begin pod
=head2 serialize

Serializes a B<Gnome::Gio::Icon> into a B<Gnome::Glib::Variant>. An equivalent B<Gnome::Gio::Icon> can be retrieved back by calling C<deserialize()> on the returned value. As serialization will avoid using raw icon data when possible, it only makes sense to transfer the B<Gnome::Glib::Variant> between processes on the same machine, (as opposed to over the network), and within the same file system namespace.

Returns: a B<Gnome::Glib::Variant>, or C<undefined> when serialization fails.

  method serialize ( --> N-GObject )

=end pod

method serialize ( --> N-GObject ) {
  g_icon_serialize(self._f('GIcon'))
}

sub g_icon_serialize (
  N-GObject $icon --> N-GObject
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:to-string:
=begin pod
=head2 to-string

Generates a textual representation of I<icon> that can be used for serialization such as when passing I<icon> to a different process or saving it to persistent storage. Use C<new-for-string()> to get I<icon> back from the returned string.

The encoding of the returned string is proprietary to B<Gnome::Gio::Icon> except in the following two cases

- If I<icon> is a B<Gnome::Gio::FileIcon>, the returned string is a native path (such as `/path/to/my icon.png`) without escaping if the B<Gnome::Gio::File> for I<icon> is a native file. If the file is not native, the returned string is the result of C<g-file-get-uri()> (such as `sftp://path/to/myC<20icon>.png`).

- If I<icon> is a B<Gnome::Gio::ThemedIcon> with exactly one name and no fallbacks, the encoding is simply the name (such as `network-server`).

Virtual: to-tokens

Returns: An allocated NUL-terminated UTF8 string or C<undefined> if I<icon> can't be serialized. Use C<g-free()> to free.

  method to-string ( --> Str )

=end pod

method to-string ( --> Str ) {
  g_icon_to_string(self._f('GIcon'))
}

sub g_icon_to_string (
  N-GObject $icon --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_icon_new_for_string:
#`{{
=begin pod
=head2 _g_icon_new_for_string

Generate a B<Gnome::Gio::Icon> instance from I<str>. This function can fail if I<str> is not valid - see C<to-string()> for discussion.

If your application or library provides one or more B<Gnome::Gio::Icon> implementations you need to ensure that each B<Gnome::Glib::Type> is registered with the type system prior to calling C<g-icon-new-for-string()>.

Returns: An object implementing the B<Gnome::Gio::Icon> interface or C<undefined> if I<error> is set.

  method _g_icon_new_for_string ( Str $str, N-GError $error --> N-GObject )

=item Str $str; A string obtained via C<to-string()>.
=item N-GError $error; Return location for error.
=end pod
}}

# Only to use from BUILD routines in classes using this role!
method _g_icon_new_for_string ( Str $string --> N-GObject ) {
  my CArray[N-GError] $error .= new(N-GError);
  my N-GObject $no = g_icon_new_for_string( $string, $error);
  $!last-error.clear-object if $!last-error.defined;
  $!last-error .= new(:native-object(?$no ?? N-GError !! $error[0]));

  $no
}

sub g_icon_new_for_string ( gchar-ptr $str, CArray[N-GError] $error --> N-GObject )
  is native(&gio-lib)
  { * }
