#TL:1:Gnome::Gio::Resource:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Resource

Resource framework

=comment ![](images/X.png)

=head1 Description

Applications and libraries often contain binary or textual data that is really part of the application, rather than user data. For instance B<Gnome::Gtk3::Builder> .ui files, splashscreen images, B<Gnome::Gio::Menu> markup XML, CSS files, icons, etc. These are often shipped as files in 'some-data-dir/app-name', or manually included as literal strings in the code.

The B<Gnome::Gio::Resource> API and the C<glib-compile-resources> program provide a convenient and efficient alternative to this which has some nice properties. You maintain the files as normal files, so it is easy to edit them, but during the build the files are combined into a binary bundle.
=comment that is linked into the executable. This means that loading the resource files are efficient (as they are already in memory, shared with other instances) and simple (no need to check for things like I/O errors or locate the files in the filesystem). It also makes it easier to create relocatable applications.

Resource files can also be marked as compressed. Such files will be included in the resource bundle in a compressed form, but will be automatically uncompressed when the resource is used. This is very useful e.g. for larger text files that are parsed once (or rarely) and then thrown away.

Resource files can also be marked to be preprocessed, by setting the value of the `preprocess` attribute to a comma-separated list of preprocessing options. The only options currently supported are:

=item C<xml-stripblanks> which will use the xmllint command to strip ignorable whitespace from the XML file. For this to work, the `XMLLINT` environment variable must be set to the full path to the xmllint executable, or C<xmllint> must be in the `PATH`; otherwise the preprocessing step is skipped.

=item C<to-pixdata> which will use the C<gdk-pixbuf-pixdata> command to convert images to the B<Gnome::Gdk3::Pixdata> format, which allows you to create pixbufs directly using the data inside the resource file, rather than an (uncompressed) copy if it. For this, the C<gdk-pixbuf-pixdata> program must be in the PATH, or the C<GDK_PIXBUF_PIXDATA> environment variable must be set to the full path to the C<gdk-pixbuf-pixdata> executable; otherwise the resource compiler will abort.

Resource files will be exported in the N-GResource namespace using the combination of the given `prefix` and the filename from the `file` element. The `alias` attribute can be used to alter the filename to expose them at a different location in the resource namespace. Typically, this is used to include files from a different source directory without exposing the source directory in the resource namespace, as in the example below.

Resource bundles are created by the glib-compile-resources program which takes an XML file that describes the bundle, and a set of files that the XML references. These are combined into a binary resource bundle.

An example resource description:

  <?xml version="1.0" encoding="UTF-8"?>
  <gresources>
    <gresource prefix="/org/gtk/Example">
      <file>data/splashscreen.png</file>
      <file compressed="true">dialog.ui</file>
      <file preprocess="xml-stripblanks">menumarkup.xml</file>
      <file alias="example.css">data/example.css</file>
    </gresource>
  </gresources>


This will create a resource bundle with the following files:

  /org/gtk/Example/data/splashscreen.png
  /org/gtk/Example/dialog.ui
  /org/gtk/Example/menumarkup.xml
  /org/gtk/Example/example.css


=comment Note that all resources in the process share the same namespace, so use Java-style path prefixes (like in the above example) to avoid conflicts.

You can then use C<glib-compile-resources> to compile the XML to a binary bundle that you can load with C<new(:load)>.
=comment However, it's more common to use the --generate-source and --generate-header arguments to create a source file and header to link directly into your application. This will generate `C<get_resource()>`, `C<register_resource()>` and `C<unregister_resource()>` functions, prefixed by the `--c-name` argument passed to C<glib-compile-resources>. `C<get_resource()>` returns the generated B<Gnome::Gio::Resource> object. The register and unregister functions register the resource so its files can be accessed using C<g_resources_lookup_data()>.

Once a B<Gnome::Gio::Resource> has been created and registered all the data in it can be accessed globally in the process by using API calls like
=comment C<g_resources_open_stream()> to stream the data or
C<g_resources_lookup_data()> to get a direct pointer to the data. You can also use URIs like "resource:///org/gtk/Example/data/splashscreen.png" with B<Gnome::Gio::File> to access the resource data.

Some higher-level APIs, such as B<Gnome::Gtk3::Application>, will automatically load resources from certain well-known paths in the resource namespace as a convenience. See the documentation for those APIs for details.

There are two forms of the generated source, the default version uses the compiler support for constructor and destructor functions (where available) to automatically create and register the B<Gnome::Gio::Resource> on startup or library load time. If you pass `--manual-register`, two functions to register/unregister the resource are created instead. This requires an explicit initialization call in your application/library, but it works on all platforms, even on the minor ones where constructors are not supported. (Constructor support is available for at least Win32, Mac OS and Linux.)

Note that resource data can point directly into the data segment of e.g. a library, so if you are unloading libraries during runtime you need to be very careful with keeping around pointers to data from a resource, as this goes away when the library is unloaded. However, in practice this is not generally a problem, since most resource accesses are for your own resources, and resource data is often used once, during parsing, and then released.

When debugging a program or testing a change to an installed version, it is often useful to be able to replace resources in the program or library, without recompiling, for debugging or quick hacking and testing purposes. Since GLib 2.50, it is possible to use the `G_RESOURCE_OVERLAYS` environment variable to selectively overlay resources with replacements from the filesystem.  It is a C<G_SEARCHPATH_SEPARATOR>-separated list of substitutions to perform during resource lookups.

A substitution has the form

  /org/gtk/libgtk=/home/desrt/gtk-overlay

The part before the `=` is the resource subpath for which the overlay applies.  The part after is a filesystem path which contains files and subdirectories as you would like to be loaded as resources with the equivalent names.

In the example above, if an application tried to load a resource with the resource path `/org/gtk/libgtk/ui/gtkdialog.ui` then N-GResource would check the filesystem path `/home/desrt/gtk-overlay/ui/gtkdialog.ui`.  If a file was found there, it would be used instead.  This is an overlay, not an outright replacement, which means that if a file is not found at that path, the built-in version will be used instead.  Whiteouts are not currently supported.

Substitutions must start with a slash, and must not contain a trailing slash before the '='.  The path after the slash should ideally be absolute, but this is not strictly required.  It is possible to overlay the location of a single resource with an individual file.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::Resource;
  also is Gnome::GObject::Boxed;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X:api<1>;
use Gnome::N::NativeLib:api<1>;
use Gnome::N::N-GObject:api<1>;
use Gnome::N::GlibToRakuTypes:api<1>;

use Gnome::Glib::Error:api<1>;

use Gnome::GObject::Boxed:api<1>;

use Gnome::Gio::Enums:api<1>;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::Resource:auth<github:MARTIMM>:api<1>;
also is Gnome::GObject::Boxed;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types

=head2 class N-GResource

Native object to hold a resource bundle

=end pod

#TT:1:N-GResource:
class N-GResource
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :load

Loads a binary resource bundle and creates a B<Gnome::Gio::Resource> representation of it, allowing you to query it for data.

If you want to use this resource in the global resource namespace you need to register it with C<register()>.

If I<filename> is empty or the data in it is corrupt, an exception is thrown with a message about the reason.

  multi method new ( :load! )


=head3 :native-object

Create a Resource object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )


=begin comment
=head3 :build-id

Create a Resource object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )
=end comment
=end pod

#TM:1:new(:load):
#TM:0:new(:native-object):
#TM:0:new(:build-id):
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::Resource' #`{{ or %options<GResource> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists or %options<widget>:exists { }
    elsif %options<build-id>:exists { }


    # process all other options
    else {
      my $no;
      if ? %options<load> {
        my CArray[N-GError] $ne .= new(N-GError);
        my Gnome::Glib::Error $e;
        $no = _g_resource_load( %options<load>, $ne);

        if ? $no {
          $e .= new(:native-object(N-GError));
        }

        else {
          $e .= new(:native-object($ne[0]));
        }

        die X::Gnome.new(:message($e.message)) if $e.is-valid;
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
        $no = _g_resource_new();
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GResource');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("g_resource_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'gtk_' /;

  self._set-class-name-of-sub('GResource');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
# no ref/unref
method native-object-ref ( $n-native-object --> Any ) {
  _g_resource_ref($n-native-object)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_resource_unref($n-native-object)
}

#-------------------------------------------------------------------------------
#TM:1:_g_resource_ref:
#`{{
=begin pod
=head2 g_resource_ref

Atomically increments the reference count of I<resource> by one. This
function is MT-safe and may be called from any thread.

Returns: The passed in B<N-GResource>

Since: 2.32

  method g_resource_ref ( --> N-GResource )

=end pod
}}

sub _g_resource_ref ( N-GResource $resource --> N-GResource )
  is native(&gio-lib)
  is symbol('g_resource_ref')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_resource_unref:
#`{{
=begin pod
=head2 g_resource_unref

Atomically decrements the reference count of I<resource> by one. If the
reference count drops to 0, all memory allocated by the resource is
released. This function is MT-safe and may be called from any
thread.

Since: 2.32

  method g_resource_unref ( )

=end pod
}}

sub _g_resource_unref ( N-GResource $resource  )
  is native(&gio-lib)
  is symbol('g_resource_unref')
  { * }


#-------------------------------------------------------------------------------
#TM:1:enumerate-children:
=begin pod
=head2 enumerate-children

Returns all the names of children at the specified I<$path> in the resource.

If I<$path> is invalid or does not exist in the B<Gnome::Gio::Resource>, C<G-RESOURCE-ERROR-NOT-FOUND> will be returned.

Returns: a List

  method enumerate-children ( Str $path --> List )

=item Str $path; A pathname inside the resource

The returned list contains;
=item Gnome::Glib::Error; a error object. When I<$path> is invalid or does not exist in the resource, this object is valid and the message will show the reason.
=item Array; when there are children at the specified path, they will be stored in this array. B<Note that there might be a bug in the C-library. Whatever (correct) path is used, there are no children returned>.

=end pod

method enumerate-children ( Str $path --> List ) {
  my $e = CArray[N-GError].new(N-GError);

  # lookup_flags G_RESOURCE_LOOKUP_FLAGS_NONE is not used in C code!

  my CArray[Str] $a = g_resource_enumerate_children(
    self._get-native-object-no-reffing, $path,
    G_RESOURCE_LOOKUP_FLAGS_NONE.value, $e
  );

  if $e.defined {
    ( Gnome::Glib::Error.new(:native-object($e[0])), [])
  }

  else {
    my Array $children = [];
    my $i = 0;
    while $a[$i] {
      $children[$i] = $a[$i];
      $i++;
    }

    ( Gnome::Glib::Error.new(:native-object(N-GError)), $children)
  }
}

sub g_resource_enumerate_children ( N-GResource $resource, gchar-ptr $path, GEnum $lookup_flags, CArray[N-GError] $error --> gchar-pptr )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:error-quark:
=begin pod
=head2 error-quark

Gets the B<Gnome::Gio::Resource> Error Quark.

Returns: a B<GQuark>

  method error-quark ( --> UInt )

=end pod

method error-quark ( --> UInt ) {
  g_resource_error_quark;
}

sub g_resource_error_quark (  --> GQuark )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-info:
=begin pod
=head2 get-info


Looks for a file at the specified I<path> in the set of
globally registered resources and if found returns information about it.

I<lookup-flags> controls the behaviour of the lookup.

Returns: C<True> if the file was found. C<False> if there were errors


  method get-info ( Str $path, GResourceLookupFlags $lookup_flags, UInt $size, UInt $flags, N-GError $error --> Int )

=item Str $path; A pathname inside the resource
=item GResourceLookupFlags $lookup_flags; A B<GResourceLookupFlags>
=item UInt $size; (out) (optional): a location to place the length of the contents of the file, or C<undefined> if the length is not needed
=item UInt $flags; (out) (optional): a location to place the B<GResourceFlags> about the file, or C<undefined> if the flags are not needed
=item N-GError $error; return location for a B<GError>, or C<undefined>

=end pod

method get-info ( Str $path, GResourceLookupFlags $lookup_flags, UInt $size, UInt $flags, N-GError $error --> Int ) {

  g_resources_get_info(
    self._get-native-object-no-reffing, $path, $lookup_flags, $size, $flags, $error
  );
}

sub g_resources_get_info ( gchar-ptr $path, GEnum $lookup_flags, gsize $size, guint32 $flags, N-GError $error --> gboolean )
  is native(&gio-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:lookup-data:
=begin pod
=head2 lookup-data


Looks for a file at the specified I<path> in the set of
globally registered resources and returns a B<GBytes> that
lets you directly access the data in memory.

The data is always followed by a zero byte, so you
can safely use the data as a C string. However, that byte
is not included in the size of the GBytes.

For uncompressed resource files this is a pointer directly into
the resource bundle, which is typically in some readonly data section
in the program binary. For compressed files we allocate memory on
the heap and automatically uncompress the data.

I<lookup-flags> controls the behaviour of the lookup.

Returns: (transfer full): B<GBytes> or C<undefined> on error.
Free the returned object with C<g-bytes-unref()>



  method lookup-data ( Str $path, GResourceLookupFlags $lookup_flags, N-GError $error --> N-GObject )

=item Str $path; A pathname inside the resource
=item GResourceLookupFlags $lookup_flags; A B<GResourceLookupFlags>
=item N-GError $error; return location for a B<GError>, or C<undefined>

=end pod

method lookup-data ( Str $path, GResourceLookupFlags $lookup_flags, N-GError $error --> N-GObject ) {

  g_resources_lookup_data(
    self._get-native-object-no-reffing, $path, $lookup_flags, $error
  );
}

sub g_resources_lookup_data ( gchar-ptr $path, GEnum $lookup_flags, N-GError $error --> N-GObject )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:register:
=begin pod
=head2 register

Registers the resource with the process-global set of resources. Once a resource is registered the files in it can be accessed with the global resource lookup functions like C<lookup-data()>.

  method register ( )

=end pod

method register ( ) {

  g_resources_register(
    self._get-native-object-no-reffing,
  );
}

sub g_resources_register ( N-GResource $resource )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:unregister:
=begin pod
=head2 unregister

Unregisters the resource from the process-global set of resources.

  method unregister ( )

=end pod

method unregister ( ) {

  g_resources_unregister(
    self._get-native-object-no-reffing,
  );
}

sub g_resources_unregister ( N-GResource $resource )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:g-static-resource-fini:
=begin pod
=head2 g-static-resource-fini

Finalized a N-GResource initialized by C<g-static-resource-init()>.

This is normally used by code generated by
[glib-compile-resources][glib-compile-resources]
and is not typically used by other code.

  method g-static-resource-fini ( GStaticResource $static_resource )

=item GStaticResource $static_resource; pointer to a static B<GStaticResource>

=end pod

method g-static-resource-fini ( GStaticResource $static_resource ) {

  g_static_resource_fini(
    self._get-native-object-no-reffing, $static_resource
  );
}

sub g_static_resource_fini ( GStaticResource $static_resource  )
  is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g-static-resource-get-resource:
=begin pod
=head2 g-static-resource-get-resource

Gets the N-GResource that was registered by a call to C<g-static-resource-init()>.

This is normally used by code generated by
[glib-compile-resources][glib-compile-resources]
and is not typically used by other code.

Returns:  (transfer none): a B<Gnome::Gio::Resource>

  method g-static-resource-get-resource ( GStaticResource $static_resource --> N-GResource )

=item GStaticResource $static_resource; pointer to a static B<GStaticResource>

=end pod

method g-static-resource-get-resource ( GStaticResource $static_resource --> N-GResource ) {

  g_static_resource_get_resource(
    self._get-native-object-no-reffing, $static_resource
  );
}

sub g_static_resource_get_resource ( GStaticResource $static_resource --> N-GResource )
  is native(&gio-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:g-static-resource-init:
=begin pod
=head2 g-static-resource-init

Initializes a N-GResource from static data using a
GStaticResource.

This is normally used by code generated by
[glib-compile-resources][glib-compile-resources]
and is not typically used by other code.

  method g-static-resource-init ( GStaticResource $static_resource )

=item GStaticResource $static_resource; pointer to a static B<GStaticResource>

=end pod

method g-static-resource-init ( GStaticResource $static_resource ) {

  g_static_resource_init(
    self._get-native-object-no-reffing, $static_resource
  );
}

sub g_static_resource_init ( GStaticResource $static_resource  )
  is native(&gio-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:get-info:
=begin pod
=head2 get-info

Looks for a file at the specified I<path> in the resource and if found returns information about it.

I<lookup-flags> controls the behaviour of the lookup.

Returns: C<True> if the file was found. C<False> if there were errors

  method get-info ( Str $path, GResourceLookupFlags $lookup_flags, UInt $size, UInt $flags, N-GError $error --> Int )

=item Str $path; A pathname inside the resource
=item GResourceLookupFlags $lookup_flags; A B<GResourceLookupFlags>
=item UInt $size; (out) (optional): a location to place the length of the contents of the file, or C<undefined> if the length is not needed
=item UInt $flags; (out) (optional): a location to place the flags about the file, or C<undefined> if the length is not needed
=item N-GError $error; return location for a B<GError>, or C<undefined>

=end pod

method get-info ( Str $path, GResourceLookupFlags $lookup_flags, UInt $size, UInt $flags, N-GError $error --> Int ) {

  g_resource_get_info(
    self._get-native-object-no-reffing, $path, $lookup_flags, $size, $flags, $error
  );
}

sub g_resource_get_info ( N-GResource $resource, gchar-ptr $path, GEnum $lookup_flags, gsize $size, guint32 $flags, N-GError $error --> gboolean )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:_g_resource_load:new(:load)
#`{{
=begin pod
=head2 load


Loads a binary resource bundle and creates a B<Gnome::Gio::Resource> representation of it, allowing
you to query it for data.

If you want to use this resource in the global resource namespace you need
to register it with C<register()>.

If I<filename> is empty or the data in it is corrupt,
C<G-RESOURCE-ERROR-INTERNAL> will be returned. If I<filename> doesn’t exist, or
there is an error in reading it, an error from C<g-mapped-file-new()> will be
returned.

Returns: (transfer full): a new B<Gnome::Gio::Resource>, or C<undefined> on error

  method load ( Str $filename, N-GError $error --> N-GResource )

=item Str $filename; (type filename): the path of a filename to load, in the GLib filename encoding
=item N-GError $error; return location for a B<GError>, or C<undefined>

=end pod

method load ( Str $filename, N-GError $error --> N-GResource ) {

  g_resource_load(
    self._get-native-object-no-reffing, $filename, $error
  );
}
}}

sub _g_resource_load (
  gchar-ptr $filename, CArray[N-GError] $error --> N-GResource
) is native(&gio-lib)
  is symbol('g_resource_load')
  { * }


#`{{ GBytes not (yet) supported
#-------------------------------------------------------------------------------
# TM:0:lookup-data:
=begin pod
=head2 lookup-data

Looks for a file at the specified I<path> in the resource and
returns a B<GBytes> that lets you directly access the data in
memory.

The data is always followed by a zero byte, so you
can safely use the data as a C string. However, that byte
is not included in the size of the GBytes.

For uncompressed resource files this is a pointer directly into
the resource bundle, which is typically in some readonly data section
in the program binary. For compressed files we allocate memory on
the heap and automatically uncompress the data.

I<lookup-flags> controls the behaviour of the lookup.

Returns: (transfer full): B<GBytes> or C<undefined> on error.
Free the returned object with C<g-bytes-unref()>



  method lookup-data ( Str $path, GResourceLookupFlags $lookup_flags, N-GError $error --> N-GObject )

=item Str $path; A pathname inside the resource
=item GResourceLookupFlags $lookup_flags; A B<GResourceLookupFlags>
=item N-GError $error; return location for a B<GError>, or C<undefined>

=end pod

method lookup-data ( Str $path, GResourceLookupFlags $lookup_flags, N-GError $error --> N-GObject ) {

  g_resource_lookup_data(
    self._get-native-object-no-reffing, $path, $lookup_flags, $error
  );
}

sub g_resource_lookup_data ( N-GResource $resource, gchar-ptr $path, GEnum $lookup_flags, N-GError $error --> N-GObject )
  is native(&gio-lib)
  { * }
}}

#`{{ low level I/O handles not supported by Raku
#-------------------------------------------------------------------------------
# TM:0:open-stream:
=begin pod
=head2 open-stream

Looks for a file at the specified I<path> in the resource and
returns a B<GInputStream> that lets you read the data.

I<lookup-flags> controls the behaviour of the lookup.

Returns: (transfer full): B<GInputStream> or C<undefined> on error.
Free the returned object with C<g-object-unref()>

  method open-stream ( Str $path, GResourceLookupFlags $lookup_flags, N-GError $error --> GInputStream )

=item Str $path; A pathname inside the resource
=item GResourceLookupFlags $lookup_flags; A B<GResourceLookupFlags>
=item N-GError $error; return location for a B<GError>, or C<undefined>

=end pod

method open-stream ( Str $path, GResourceLookupFlags $lookup_flags, N-GError $error --> GInputStream ) {

  g_resource_open_stream(
    self._get-native-object-no-reffing, $path, $lookup_flags, $error
  );
}

sub g_resource_open_stream ( N-GResource $resource, gchar-ptr $path, GEnum $lookup_flags, N-GError $error --> GInputStream )
  is native(&gio-lib)
  { * }
}}

#`{{ GBytes not (yet) supported
#-------------------------------------------------------------------------------
# TM:1:_g_resource_new_from_data:
#`{{
=begin pod
=head2 _g_resource_new_from_data

Creates a N-GResource from a reference to the binary resource bundle.
This will keep a reference to I<data> while the resource lives, so
the data should not be modified or freed.

If you want to use this resource in the global resource namespace you need
to register it with C<register()>.

Note: I<data> must be backed by memory that is at least pointer aligned.
Otherwise this function will internally create a copy of the memory since
GLib 2.56, or in older versions fail and exit the process.

If I<data> is empty or corrupt, C<G-RESOURCE-ERROR-INTERNAL> will be returned.

Returns: (transfer full): a new B<Gnome::Gio::Resource>, or C<undefined> on error

  method _g_resource_new_from_data ( N-GObject $data, N-GError $error --> N-GResource )

=item N-GObject $data; A B<GBytes>
=item N-GError $error; return location for a B<GError>, or C<undefined>

=end pod
}}

sub _g_resource_new_from_data ( N-GObject $data, N-GError $error --> N-GResource )
  is native(&gio-lib)
  is symbol('g_resource_new_from_data')
  { * }
}}
