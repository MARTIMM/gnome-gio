#TL:1:Gnome::Gio::MenuAttributeIter:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::MenuAttributeIter

An iterator for attributes


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::MenuAttributeIter;
  also is Gnome::GObject::Object;


=head2 Uml Diagram

![](plantuml/MenuModel.svg)


=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X:api<1>;
use Gnome::N::NativeLib:api<1>;
use Gnome::N::N-GObject:api<1>;
use Gnome::N::GlibToRakuTypes:api<1>;

use Gnome::Glib::Variant:api<1>;
use Gnome::Glib::VariantType:api<1>;

use Gnome::GObject::Object:api<1>;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::MenuAttributeIter:auth<github:MARTIMM>:api<1>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :native-object

Create a Menu object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::MenuAttributeIter' #`{{or %options<GMenuAttributeIter>}} {

    # check if native object is set by a parent class
    #if self.is-valid { }

    # check if common options are handled by some parent
    #elsif %options<native-object>:exists or %options<widget>:exists { }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMenuAttributeIter');
  }
}

#-------------------------------------------------------------------------------
#TM:0:attribute-iter-get-name:
=begin pod
=head2 attribute-iter-get-name

Gets the name of the attribute at the current iterator position, as
a string.

The iterator is not advanced.

Returns: the name of the attribute

  method attribute-iter-get-name ( --> Str )

=end pod

method attribute-iter-get-name ( --> Str ) {

  g_menu_attribute_iter_get_name(
    self._f('GMenuAttributeIter')
  );
}

sub g_menu_attribute_iter_get_name ( N-GObject $iter --> gchar-ptr )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:attribute-iter-get-next:
=begin pod
=head2 attribute-iter-get-next

This function combines C<attribute-iter-next()> with C<attribute-iter-get-name()> and C<attribute-iter-get-value()>.

First the iterator is advanced to the next (possibly first) attribute. If that fails, then C<False> is returned and there are no other effects.

If successful, I<name> and I<value> are set to the name and value of the attribute that has just been advanced to.  At this point,C<attribute-iter-get-name()> and C<attribute-iter-get-value()> will return the same values again.

The value returned in I<name> remains valid for as long as the iterator remains at the current position.  The value returned in I<value> must be unreffed using C<g-variant-unref()> when it is no longer in use.

Returns: C<True> on success, or C<False> if there is no additional attribute

  method attribute-iter-get-next (
    CArray[Str] $out_name, N-GObject $value
    --> Int
  )

=item CArray[Str] $out_name; (out) (optional) (transfer none): the type of the attribute
=item N-GObject $value; (out) (optional) (transfer full): the attribute value

=end pod

method attribute-iter-get-next ( CArray[Str] $out_name, N-GObject $value --> Int ) {
  my $no = …;
  $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;

  g_menu_attribute_iter_get_next(
    self._f('GMenuAttributeIter'), $out_name, $value
  );
}

sub g_menu_attribute_iter_get_next ( N-GObject $iter, gchar-pptr $out_name, N-GObject $value --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:attribute-iter-get-value:
=begin pod
=head2 attribute-iter-get-value


Gets the value of the attribute at the current iterator position.

The iterator is not advanced.

Returns: (transfer full): the value of the current attribute



  method attribute-iter-get-value ( --> N-GObject )

=end pod

method attribute-iter-get-value ( --> N-GObject ) {

  g_menu_attribute_iter_get_value(
    self._f('GMenuAttributeIter')
  );
}

sub g_menu_attribute_iter_get_value ( N-GObject $iter --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:attribute-iter-next:
=begin pod
=head2 attribute-iter-next


Attempts to advance the iterator to the next (possibly first)
attribute.

C<True> is returned on success, or C<False> if there are no more
attributes.

You must call this function when you first acquire the iterator
to advance it to the first attribute (and determine if the first
attribute exists at all).

Returns: C<True> on success, or C<False> when there are no more attributes



  method attribute-iter-next ( --> Int )

=end pod

method attribute-iter-next ( --> Int ) {

  g_menu_attribute_iter_next(
    self._f('GMenuAttributeIter')
  );
}

sub g_menu_attribute_iter_next ( N-GObject $iter --> gboolean )
  is native(&gio-lib)
  { * }
