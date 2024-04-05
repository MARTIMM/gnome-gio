#TL:1:Gnome::Gio::MenuLinkIter:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::MenuLinkIter

An iterator for attributes


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::MenuLinkIter;
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
unit class Gnome::Gio::MenuLinkIter:auth<github:MARTIMM>:api<1>;
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
  if self.^name eq 'Gnome::Gio::MenuLinkIter' #`{{or %options<GMenuLinkIter>}} {

    # check if native object is set by a parent class
    #if self.is-valid { }

    # check if common options are handled by some parent
    #elsif %options<native-object>:exists or %options<widget>:exists { }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMenuLinkIter');
  }
}

#-------------------------------------------------------------------------------
#TM:1:get-name:
=begin pod
=head2 get-name

Gets the name of the link at the current iterator position. The iterator is not advanced.

Returns: the type of the link

  method get-name ( --> Str )

=end pod

method get-name ( --> Str ) {

  g_menu_link_iter_get_name(self._f('GMenuLinkIter'));
}

sub g_menu_link_iter_get_name ( N-GObject $iter --> gchar-ptr )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-next:
=begin pod
=head2 get-next

This function combines C<next()> with C<get-name()> and C<get-value()>.

First the iterator is advanced to the next (possibly first) link. If that fails, then an empty C<List> is returned and there are no other effects.

If successful, The list is filled with the name and value, a native B<Gnome::Gio::MenuModel> of the link that has just been advanced to. At this point, C<get-name()> and C<get-value()> will return the same values again.

The values returned in the C<List> remains valid for as long as the iterator remains at the current position.  The value returned in I<value> must be cleared using C<clear-object()> when it is no longer in use.

Returns: A two element list on success, or an empty List if there is no additional link

  method get-next ( --> List )

The List contains
=item Str; the name of the link
=item N-GObject; the native linked B<Gnome::Gio::MenuModel>

=end pod

method get-next ( --> List ) {
  my $out_link = CArray[Str].new(Str);
  my N-GObject $value .= new;
  my Int $r = g_menu_link_iter_get_next(
    self._f('GMenuLinkIter'), $out_link, $value
  );
note 'r: ', $r;

  if $r {
    ( $out_link[0], $value)
  }

  else {
    ()
  }
}

sub g_menu_link_iter_get_next (
  N-GObject $iter, gchar-pptr $out_link, N-GObject $value
  --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-value:
=begin pod
=head2 get-value

Gets the linked B<Gnome::Gio::MenuModel> at the current iterator position. The iterator is not advanced.

Returns: the native B<Gnome::Gio::MenuModel> that is linked to. (Cannot return a Raku object bacause of circular dependency)

  method get-value ( --> N-GObject )

=end pod

method get-value ( --> N-GObject ) {

  g_menu_link_iter_get_value(self._f('GMenuLinkIter'))
}

sub g_menu_link_iter_get_value ( N-GObject $iter --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:next:
=begin pod
=head2 next

Attempts to advance the iterator to the next (possibly first) link. C<True> is returned on success, or C<False> if there are no more links.

You must call this function when you first acquire the iterator to advance it to the first link (and determine if the first link exists at all).

Returns: C<True> on success, or C<False> when there are no more links

  method next ( --> Bool )

=end pod

method next ( --> Bool ) {

  g_menu_link_iter_next( self._f('GMenuLinkIter')).Bool
}

sub g_menu_link_iter_next ( N-GObject $iter --> gboolean )
  is native(&gio-lib)
  { * }
