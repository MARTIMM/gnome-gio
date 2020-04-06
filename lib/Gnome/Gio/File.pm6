#TL:1:Gnome::Gio::File:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::File

File and Directory Handling

=comment ![](images/X.png)

=head1 Description

I<include>: gio/gio.h

B<N-GFile> is a high level abstraction for manipulating files on a virtual file system. B<N-GFiles> are lightweight, immutable objects that do no I/O upon creation. It is necessary to understand that B<N-GFile> objects do not represent files, merely an identifier for a file. All file content I/O is implemented as streaming operations (see B<GInputStream> and B<GOutputStream>).

To construct a B<N-GFile>, you can use:
=item C<g_file_new_for_path()> if you have a path.
=item C<g_file_new_for_uri()> if you have a URI.
=item C<g_file_new_for_commandline_arg()> for a command line argument.
=item C<g_file_new_tmp()> to create a temporary file from a template.
=item C<g_file_parse_name()> from a UTF-8 string gotten from C<g_file_get_parse_name()>.
=item C<g_file_new_build_filename()> to create a file from path elements.

One way to think of a B<N-GFile> is as an abstraction of a pathname. For normal files the system pathname is what is stored internally, but as B<N-GFiles> are extensible it could also be something else that corresponds to a pathname in a userspace implementation of a filesystem.

B<N-GFiles> make up hierarchies of directories and files that correspond to the files on a filesystem. You can move through the file system with B<N-GFile> using C<g_file_get_parent()> to get an identifier for the parent directory, C<g_file_get_child()> to get a child within a directory, C<g_file_resolve_relative_path()> to resolve a relative path between two B<N-GFiles>. There can be multiple hierarchies, so you may not end up at the same root if you repeatedly call C<g_file_get_parent()> on two different files.

All B<N-GFiles> have a basename (get with C<g_file_get_basename()>). These names are byte strings that are used to identify the file on the filesystem (relative to its parent directory) and there is no guarantees that they have any particular charset encoding or even make any sense at all. If you want to use filenames in a user interface you should use the display name that you can get by requesting the C<G_FILE_ATTRIBUTE_STANDARD_DISPLAY_NAME> attribute with C<g_file_query_info()>. This is guaranteed to be in UTF-8 and can be used in a user interface. But always store the real basename or the B<N-GFile> to use to actually access the file, because there is no way to go from a display name to the actual name.

Using B<N-GFile> as an identifier has the same weaknesses as using a path in that there may be multiple aliases for the same file. For instance, hard or soft links may cause two different B<N-GFiles> to refer to the same file. Other possible causes for aliases are: case insensitive filesystems, short and long names on FAT/NTFS, or bind mounts in Linux. If you want to check if two B<N-GFiles> point to the same file you can query for the C<G_FILE_ATTRIBUTE_ID_FILE> attribute. Note that B<N-GFile> does some trivial canonicalization of pathnames passed in, so that trivial differences in the path string used at creation (duplicated slashes, slash at end of path, "." or ".." path segments, etc) does not create different B<N-GFiles>.

Many B<N-GFile> operations have both synchronous and asynchronous versions to suit your application. Asynchronous versions of synchronous functions simply have C<_async()> appended to their function names. The asynchronous I/O functions call a B<GAsyncReadyCallback> which is then used to finalize the operation, producing a GAsyncResult which is then passed to the function's matching C<_finish()> operation.

It is highly recommended to use asynchronous calls when running within a shared main loop, such as in the main thread of an application. This avoids I/O operations blocking other sources on the main loop from being dispatched. Synchronous I/O operations should be performed from worker threads. See the [introduction to asynchronous programming section][async-programming] for more.

Some B<N-GFile> operations almost always take a noticeable amount of time, and so do not have synchronous analogs. Notable cases include:
=item C<g_file_mount_mountable()> to mount a mountable file.
=item C<g_file_unmount_mountable_with_operation()> to unmount a mountable file.
=item C<g_file_eject_mountable_with_operation()> to eject a mountable file.

=head2 Entity Tags

One notable feature of B<N-GFiles> are entity tags, or "etags" for short. Entity tags are somewhat like a more abstract version of the traditional mtime, and can be used to quickly determine if the file has been modified from the version on the file system. See the HTTP 1.1 [specification](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html) for HTTP Etag headers, which are a very similar concept.


=head2 See Also

B<GFileInfo>, B<GFileEnumerator>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::File;
  also is Gnome::N::TopLevelClassSupport;

=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::File;

  unit class MyGuiClass;
  also is Gnome::Gio::File;

  submethod new ( |c ) {
    # let the Gnome::Gio::File class process the options
    self.bless( :GFile, |c);
  }

  submethod BUILD ( ... ) {
    ...
  }

=end comment
=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::File:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types

=head2 class N-GFile

Native object to hold a file representation

=end pod

#TT:1:N-GFile:
class N-GFile
  is repr('CPointer')
  is export
  { }

#`{{
=begin pod
=head2 class N-GFileIface

An interface for writing VFS file handles.


=item UInt $.g_iface: The parent interface.
=item ___dup: Duplicates a B<GFile>.
=item ___hash: Creates a hash of a B<GFile>.
=item ___equal: Checks equality of two given B<GFiles>.
=item ___is_native: Checks to see if a file is native to the system.
=item ___has_uri_scheme: Checks to see if a B<GFile> has a given URI scheme.
=item ___get_uri_scheme: Gets the URI scheme for a B<GFile>.
=item ___get_basename: Gets the basename for a given B<GFile>.
=item ___get_path: Gets the current path within a B<GFile>.
=item ___get_uri: Gets a URI for the path within a B<GFile>.
=item ___get_parse_name: Gets the parsed name for the B<GFile>.
=item ___get_parent: Gets the parent directory for the B<GFile>.
=item ___prefix_matches: Checks whether a B<GFile> contains a specified file.
=item ___get_relative_path: Gets the path for a B<GFile> relative to a given path.
=item ___resolve_relative_path: Resolves a relative path for a B<GFile> to an absolute path.
=item ___get_child_for_display_name: Gets the child B<GFile> for a given display name.
=item ___enumerate_children: Gets a B<GFileEnumerator> with the children of a B<GFile>.
=item ___enumerate_children_async: Asynchronously gets a B<GFileEnumerator> with the children of a B<GFile>.
=item ___enumerate_children_finish: Finishes asynchronously enumerating the children.
=item ___query_info: Gets the B<GFileInfo> for a B<GFile>.
=item ___query_info_async: Asynchronously gets the B<GFileInfo> for a B<GFile>.
=item ___query_info_finish: Finishes an asynchronous query info operation.
=item ___query_filesystem_info: Gets a B<GFileInfo> for the file system B<GFile> is on.
=item ___query_filesystem_info_async: Asynchronously gets a B<GFileInfo> for the file system B<GFile> is on.
=item ___query_filesystem_info_finish: Finishes asynchronously getting the file system info.
=item ___find_enclosing_mount: Gets a B<GMount> for the B<GFile>.
=item ___find_enclosing_mount_async: Asynchronously gets the B<GMount> for a B<GFile>.
=item ___find_enclosing_mount_finish: Finishes asynchronously getting the volume.
=item ___set_display_name: Sets the display name for a B<GFile>.
=item ___set_display_name_async: Asynchronously sets a B<GFile>'s display name.
=item ___set_display_name_finish: Finishes asynchronously setting a B<GFile>'s display name.
=item ___query_settable_attributes: Returns a list of B<GFileAttributes> that can be set.
=item ____query_settable_attributes_async: Asynchronously gets a list of B<GFileAttributes> that can be set.
=item ____query_settable_attributes_finish: Finishes asynchronously querying settable attributes.
=item ___query_writable_namespaces: Returns a list of B<GFileAttribute> namespaces that are writable.
=item ____query_writable_namespaces_async: Asynchronously gets a list of B<GFileAttribute> namespaces that are writable.
=item ____query_writable_namespaces_finish: Finishes asynchronously querying the writable namespaces.
=item ___set_attribute: Sets a B<GFileAttribute>.
=item ___set_attributes_from_info: Sets a B<GFileAttribute> with information from a B<GFileInfo>.
=item ___set_attributes_async: Asynchronously sets a file's attributes.
=item ___set_attributes_finish: Finishes setting a file's attributes asynchronously.
=item ___read_fn: Reads a file asynchronously.
=item ___read_async: Asynchronously reads a file.
=item ___read_finish: Finishes asynchronously reading a file.
=item ___append_to: Writes to the end of a file.
=item ___append_to_async: Asynchronously writes to the end of a file.
=item ___append_to_finish: Finishes an asynchronous file append operation.
=item ___create: Creates a new file.
=item ___create_async: Asynchronously creates a file.
=item ___create_finish: Finishes asynchronously creating a file.
=item ___replace: Replaces the contents of a file.
=item ___replace_async: Asynchronously replaces the contents of a file.
=item ___replace_finish: Finishes asynchronously replacing a file.
=item ___delete_file: Deletes a file.
=item ___delete_file_async: Asynchronously deletes a file.
=item ___delete_file_finish: Finishes an asynchronous delete.
=item ___trash: Sends a B<GFile> to the Trash location.
=item ___trash_async: Asynchronously sends a B<GFile> to the Trash location.
=item ___trash_finish: Finishes an asynchronous file trashing operation.
=item ___make_directory: Makes a directory.
=item ___make_directory_async: Asynchronously makes a directory.
=item ___make_directory_finish: Finishes making a directory asynchronously.
=item ___make_symbolic_link: Makes a symbolic link.
=item ____make_symbolic_link_async: Asynchronously makes a symbolic link
=item ____make_symbolic_link_finish: Finishes making a symbolic link asynchronously.
=item ___copy: Copies a file.
=item ___copy_async: Asynchronously copies a file.
=item ___copy_finish: Finishes an asynchronous copy operation.
=item ___move: Moves a file.
=item ____move_async: Asynchronously moves a file.
=item ____move_finish: Finishes an asynchronous move operation.
=item ___mount_mountable: Mounts a mountable object.
=item ___mount_mountable_finish: Finishes a mounting operation.
=item ___unmount_mountable: Unmounts a mountable object.
=item ___unmount_mountable_finish: Finishes an unmount operation.
=item ___eject_mountable: Ejects a mountable.
=item ___eject_mountable_finish: Finishes an eject operation.
=item ___mount_enclosing_volume: Mounts a specified location.
=item ___mount_enclosing_volume_finish: Finishes mounting a specified location.
=item ___monitor_dir: Creates a B<GFileMonitor> for the location.
=item ___monitor_file: Creates a B<GFileMonitor> for the location.
=item ___open_readwrite: Open file read/write. Since 2.22.
=item ___open_readwrite_async: Asynchronously opens file read/write. Since 2.22.
=item ___open_readwrite_finish: Finishes an asynchronous open read/write. Since 2.22.
=item ___create_readwrite: Creates file read/write. Since 2.22.
=item ___create_readwrite_async: Asynchronously creates file read/write. Since 2.22.
=item ___create_readwrite_finish: Finishes an asynchronous creates read/write. Since 2.22.
=item ___replace_readwrite: Replaces file read/write. Since 2.22.
=item ___replace_readwrite_async: Asynchronously replaces file read/write. Since 2.22.
=item ___replace_readwrite_finish: Finishes an asynchronous replace read/write. Since 2.22.
=item ___start_mountable: Starts a mountable object. Since 2.22.
=item ___start_mountable_finish: Finishes an start operation. Since 2.22.
=item ___stop_mountable: Stops a mountable. Since 2.22.
=item ___stop_mountable_finish: Finishes an stop operation. Since 2.22.
=item Int $.supports_thread_contexts: a boolean that indicates whether the B<GFile> implementation supports thread-default contexts. Since 2.22.
=item ___unmount_mountable_with_operation: Unmounts a mountable object using a B<GMountOperation>. Since 2.22.
=item ___unmount_mountable_with_operation_finish: Finishes an unmount operation using a B<GMountOperation>. Since 2.22.
=item ___eject_mountable_with_operation: Ejects a mountable object using a B<GMountOperation>. Since 2.22.
=item ___eject_mountable_with_operation_finish: Finishes an eject operation using a B<GMountOperation>. Since 2.22.
=item ___poll_mountable: Polls a mountable object for media changes. Since 2.22.
=item ___poll_mountable_finish: Finishes an poll operation for media changes. Since 2.22.
=item ___measure_disk_usage: Recursively measures the disk usage of I<file>. Since 2.38
=item ___measure_disk_usage_async: Asynchronously recursively measures the disk usage of I<file>. Since 2.38
=item ___measure_disk_usage_finish: Finishes an asynchronous recursive measurement of the disk usage of I<file>. Since 2.38


=end pod

#TT:0:N-GFileIface:
class N-GFileIface is export is repr('CStruct') {
  has uint64 $.g_iface;
  has GFil $.e *             (* dup)                         (GFile         *file);
  has guin $.t               (* hash)                        (GFile         *file);
  has GFile $.file2);
  has gboolea $.n            (* is_native)                   (GFile         *file);
  has str $.uri_scheme);
  has cha $.r *              (* get_uri_scheme)              (GFile         *file);
  has cha $.r *              (* get_basename)                (GFile         *file);
  has cha $.r *              (* get_path)                    (GFile         *file);
  has cha $.r *              (* get_uri)                     (GFile         *file);
  has cha $.r *              (* get_parse_name)              (GFile         *file);
  has GFil $.e *             (* get_parent)                  (GFile         *file);
  has GFile $.file);
  has GFile $.descendant);
  has str $.relative_path);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has voi $.d                (* _query_settable_attributes_async)  (void);
  has voi $.d                (* _query_settable_attributes_finish) (void);
  has N-GError $.error);
  has voi $.d                (* _query_writable_namespaces_async)  (void);
  has voi $.d                (* _query_writable_namespaces_finish) (void);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has voi $.d                (* _make_symbolic_link_async)   (void);
  has voi $.d                (* _make_symbolic_link_finish)  (void);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has voi $.d                (* _move_async)                 (void);
  has voi $.d                (* _move_finish)                (void);
  has Pointer $.user_data);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has int32 $.supports_thread_contexts;
  has Pointer $.user_data);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
  has N-GError $.error);
  has Pointer $.user_data);
  has N-GError $.error);
}
}}

#-------------------------------------------------------------------------------

=begin pod
=head1 Methods
=head2 new

Create a new File object.

  multi method new ( )

Create a File object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

Create a File object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

#TM:0:new():inheriting
#TM:0:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
#TM:4:new(:build-id):Gnome::GObject::Object

submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::File' #`{{ or %options<GFile> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists or %options<widget>:exists { }
    elsif %options<build-id>:exists { }

    elsif ? %options<path> {
      self.set-native-object(_g_file_new_for_path(%options<path>));
    }

    elsif ? %options<uri> {
      self.set-native-object(_g_file_new_for_uri(%options<uri>));
    }

    # check if there are unknown options
    elsif %options.elems {
      die X::Gnome.new(
        :message(
          'Unsupported, undefined, incomplete or wrongly typed options for ' ~
          self.^name ~ ': ' ~ %options.keys.join(', ')
        )
      );
    }

    ##`{{ when there are no defaults use this
    # check if there are any options
    elsif %options.elems == 0 {
      die X::Gnome.new(:message('No options specified ' ~ self.^name));
    }
    #}}

    #`{{ when there are options use this instead
    # create default object
    else {
      self.set-native-object(g_file_new());
    }
    }}

    # only after creating the native-object, the gtype is known
    self.set-class-info('GFile');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("g_file_$native-sub"); };
# check for gtk_, gdk_, g_, pango_, cairo_ !!!
  try { $s = &::("gtk_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'gtk_' /;

  self.set-class-name-of-sub('GFile');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object --> N-GFile ) {
  $n-native-object
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  g_object_unref($n-native-object)
}

#-------------------------------------------------------------------------------
#TM:0:g_object_unref:
=begin pod
=head2 [g_] object_unref

Decreases the reference count of the native object. When its reference count drops to 0, the object is finalized (i.e. its memory is freed).

=begin comment
If the pointer to the native object may be reused in future (for example, if it is an instance variable of another object), it is recommended to clear the pointer to C<Any> rather than retain a dangling pointer to a potentially invalid I<N-GFile> instance. Use C<g_clear_object()> for this.
=end comment

  method g_object_unref ( N-GFile $object )

=item N-GObject $object; a I<N-GFile>

=end pod

sub g_object_unref ( N-GFile $object is copy ) {

  #$object = g_object_ref_sink($object) if g_object_is_floating($object);
  _g_object_unref($object)
}

sub _g_object_unref ( N-GFile $object )
  is native(&gobject-lib)
  is symbol('g_object_unref')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_file_new_for_path:new()
#`{{
=begin pod
=head2 [g_file_] new_for_path

Constructs a B<N-GFile> for a given path. This operation never
fails, but the returned object might not support any I/O
operation if I<path> is malformed.

Returns: (transfer full): a new B<N-GFile> for the given I<path>.
Free the returned object with C<clear-object()>.

  method g_file_new_for_path ( Str $path --> N-GFile )

=item Str $path; (type filename): a string containing a relative or absolute path. The string must be encoded in the glib filename encoding.

=end pod
}}

sub _g_file_new_for_path ( Str $path --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_for_path')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_file_new_for_uri:new()
#`{{
=begin pod
=head2 [g_file_] new_for_uri

Constructs a B<N-GFile> for a given URI. This operation never
fails, but the returned object might not support any I/O
operation if I<uri> is malformed or if the uri type is
not supported.

Returns: (transfer full): a new B<N-GFile> for the given I<uri>.
Free the returned object with C<clear-object()>.

  method g_file_new_for_uri ( Str $uri --> N-GFile )

=item Str $uri; a UTF-8 string containing a URI

=end pod
}}

sub _g_file_new_for_uri ( Str $uri --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_for_uri')
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_file_new_for_commandline_arg:new()
#`{{
=begin pod
=head2 [g_file_] new_for_commandline_arg

Creates a B<N-GFile> with the given argument from the command line.
The value of I<arg> can be either a URI, an absolute path or a
relative path resolved relative to the current working directory.
This operation never fails, but the returned object might not
support any I/O operation if I<arg> points to a malformed path.

Note that on Windows, this function expects its argument to be in
UTF-8 -- not the system code page.  This means that you
should not use this function with string from argv as it is passed
to C<main()>.  C<g_win32_get_command_line()> will return a UTF-8 version of
the commandline.  B<GApplication> also uses UTF-8 but
C<g_application_command_line_create_file_for_arg()> may be more useful
for you there.  It is also always possible to use this function with
B<GOptionContext> arguments of type C<G_OPTION_ARG_FILENAME>.

Returns: (transfer full): a new B<N-GFile>.
Free the returned object with C<clear-object()>.

  method g_file_new_for_commandline_arg ( Str $arg --> N-GFile )

=item Str $arg; (type filename): a command line string

=end pod
}}

sub _g_file_new_for_commandline_arg ( Str $arg --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_for_commandline_arg')
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_file_new_for_commandline_arg_and_cwd:new()
#`{{
=begin pod
=head2 [g_file_] new_for_commandline_arg_and_cwd

Creates a B<N-GFile> with the given argument from the command line.

This function is similar to C<g_file_new_for_commandline_arg()> except
that it allows for passing the current working directory as an
argument instead of using the current working directory of the
process.

This is useful if the commandline argument was given in a context
other than the invocation of the current process.

See also C<g_application_command_line_create_file_for_arg()>.

Returns: (transfer full): a new B<N-GFile>

Since: 2.36

  method g_file_new_for_commandline_arg_and_cwd ( Str $arg, Str $cwd --> N-GFile )

=item Str $arg; (type filename): a command line string
=item Str $cwd; (type filename): the current working directory of the commandline

=end pod
}}

sub _g_file_new_for_commandline_arg_and_cwd ( Str $arg, Str $cwd --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_for_commandline_arg_and_cwd')
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_file_new_tmp:new()
#`{{
=begin pod
=head2 [g_file_] new_tmp

Opens a file in the preferred directory for temporary files (as
returned by C<g_get_tmp_dir()>) and returns a B<N-GFile> and
B<N-GFileIOStream> pointing to it.

I<tmpl> should be a string in the GLib file name encoding
containing a sequence of six 'X' characters, and containing no
directory components. If it is C<Any>, a default template is used.

Unlike the other B<N-GFile> constructors, this will return C<Any> if
a temporary file could not be created.

Returns: (transfer full): a new B<N-GFile>.
Free the returned object with C<clear-object()>.

Since: 2.32

  method g_file_new_tmp ( Str $tmpl, GFileIOStream $iostream, N-GError $error --> N-GFile )

=item Str $tmpl; (type filename) (nullable): Template for the file name, as in C<g_file_open_tmp()>, or C<Any> for a default template
=item GFileIOStream $iostream; (out): on return, a B<GFileIOStream> for the created file
=item N-GError $error; a B<GError>, or C<Any>

=end pod
}}

#`{{
sub _g_file_new_tmp ( Str $tmpl, GFileIOStream $iostream, N-GError $error --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_tmp')
  { * }
}}
#-------------------------------------------------------------------------------
#TM:1:_g_file_parse_name:new()
#`{{
=begin pod
=head2 [g_file_] parse_name

Constructs a B<N-GFile> with the given I<parse_name> (i.e. something
given by C<g_file_get_parse_name()>). This operation never fails,
but the returned object might not support any I/O operation if
the I<parse_name> cannot be parsed.

Returns: (transfer full): a new B<N-GFile>.

  method g_file_parse_name ( Str $parse_name --> N-GFile )

=item Str $parse_name; a file name or path to be parsed
=end pod
}}

sub _g_file_parse_name ( Str $parse_name --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_parse_name')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:_g_file_new_build_filename:new()
#`{{
=begin pod
=head2 [g_file_] new_build_filename

Constructs a B<N-GFile> from a series of elements using the correct
separator for filenames.

Using this function is equivalent to calling C<g_build_filename()>,
followed by C<g_file_new_for_path()> on the result.

Returns: (transfer full): a new B<N-GFile>

Since: 2.56

  method g_file_new_build_filename ( Str $first_element --> N-GFile )

=item Str $first_element; (type filename): the first element in the path @...: remaining elements in path, terminated by C<Any>

=end pod
}}

sub _g_file_new_build_filename ( Str $first_element, Any $any = Any --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_build_filename')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_file_dup:
=begin pod
=head2 g_file_dup

Duplicates a B<N-GFile> handle. This operation does not duplicate
the actual file or directory represented by the B<N-GFile>; see
C<g_file_copy()> if attempting to copy a file.

C<g_file_dup()> is useful when a second handle is needed to the same underlying
file, for use in a separate thread (B<N-GFile> is not thread-safe). For use
within the same thread, use C<g_object_ref()> to increment the existing object’s
reference count.

This call does no blocking I/O.

Returns: (transfer full): a new B<N-GFile> that is a duplicate
of the given B<N-GFile>.

  method g_file_dup ( --> N-GFile )


=end pod

sub g_file_dup ( N-GFile $file --> N-GFile )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_hash:
=begin pod
=head2 g_file_hash

Creates a hash value for a B<N-GFile>.

This call does no blocking I/O.

Virtual: hash
Returns: 0 if I<file> is not a valid B<N-GFile>, otherwise an
integer that can be used as hash value for the B<N-GFile>.
This function is intended for easily hashing a B<N-GFile> to
add to a B<GHashTable> or similar data structure.

  method g_file_hash ( Pointer $file --> UInt )

=item Pointer $file; (type N-GFile): B<gconstpointer> to a B<N-GFile>

=end pod

sub g_file_hash ( Pointer $file --> uint32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_equal:
=begin pod
=head2 g_file_equal

Checks if the two given B<N-GFiles> refer to the same file.

Note that two B<N-GFiles> that differ can still refer to the same
file on the filesystem due to various forms of filename
aliasing.

This call does no blocking I/O.

Returns: C<1> if I<file1> and I<file2> are equal.

  method g_file_equal ( N-GFile $file2 --> Int )

=item N-GFile $file2; the second B<N-GFile>

=end pod

sub g_file_equal ( N-GFile $file1, N-GFile $file2 --> int32 )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:g_file_get_basename:
=begin pod
=head2 [g_file_] get_basename

Gets the base name (the last component of the path) for a given B<N-GFile>.

If called for the top level of a system (such as the filesystem root
or a uri like sftp://host/) it will return a single directory separator
(and on Windows, possibly a drive letter).

The base name is a byte string (not UTF-8). It has no defined encoding
or rules other than it may not contain zero bytes.  If you want to use
filenames in a user interface you should use the display name that you
can get by requesting the C<G_FILE_ATTRIBUTE_STANDARD_DISPLAY_NAME>
attribute with C<g_file_query_info()>.

This call does no blocking I/O.

Returns: (type filename) (nullable): string containing the B<N-GFile>'s
base name, or C<Any> if given B<N-GFile> is invalid. The returned string
should be freed with C<g_free()> when no longer needed.

  method g_file_get_basename ( --> Str )


=end pod

sub g_file_get_basename ( N-GFile $file --> Str )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_file_get_path:
=begin pod
=head2 [g_file_] get_path

Gets the local pathname for B<N-GFile>, if one exists. If non-C<Any>, this is
guaranteed to be an absolute, canonical path. It might contain symlinks.

This call does no blocking I/O.

Returns: (type filename) (nullable): string containing the B<N-GFile>'s path,
or C<Any> if no such path exists. The returned string should be freed
with C<g_free()> when no longer needed.

  method g_file_get_path ( --> Str )


=end pod

sub g_file_get_path ( N-GFile $file --> Str )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_file_peek_path:
=begin pod
=head2 [g_file_] peek_path

Exactly like C<g_file_get_path()>, but caches the result via
C<g_object_set_qdata_full()>.  This is useful for example in C
applications which mix `g_file_*` APIs with native ones.  It
also avoids an extra duplicated string when possible, so will be
generally more efficient.

This call does no blocking I/O.

Returns: (type filename) (nullable): string containing the B<N-GFile>'s path,
or C<Any> if no such path exists. The returned string is owned by I<file>.
Since: 2.56

  method g_file_peek_path ( --> Str )


=end pod

sub g_file_peek_path ( N-GFile $file --> Str )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:g_file_get_uri:
=begin pod
=head2 [g_file_] get_uri

Gets the URI for the I<file>.

This call does no blocking I/O.

Returns: a string containing the B<N-GFile>'s URI.
The returned string should be freed with C<g_free()>
when no longer needed.

  method g_file_get_uri ( --> Str )


=end pod

sub g_file_get_uri ( N-GFile $file --> Str )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_get_parse_name:
=begin pod
=head2 [g_file_] get_parse_name

Gets the parse name of the I<file>.
A parse name is a UTF-8 string that describes the
file such that one can get the B<N-GFile> back using
C<g_file_parse_name()>.

This is generally used to show the B<N-GFile> as a nice
full-pathname kind of string in a user interface,
like in a location entry.

For local files with names that can safely be converted
to UTF-8 the pathname is used, otherwise the IRI is used
(a form of URI that allows UTF-8 characters unescaped).

This call does no blocking I/O.

Returns: a string containing the B<N-GFile>'s parse name.
The returned string should be freed with C<g_free()>
when no longer needed.

  method g_file_get_parse_name ( --> Str )


=end pod

sub g_file_get_parse_name ( N-GFile $file --> Str )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_file_get_parent:
=begin pod
=head2 [g_file_] get_parent

Gets the parent directory for the I<file>.
If the I<file> represents the root directory of the
file system, then C<Any> will be returned.

This call does no blocking I/O.

Returns: (nullable) (transfer full): a B<N-GFile> structure to the
parent of the given B<N-GFile> or C<Any> if there is no parent. Free
the returned object with C<clear-object()>.

  method g_file_get_parent ( --> N-GFile )


=end pod

sub g_file_get_parent ( N-GFile $file --> N-GFile )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_has_parent:
=begin pod
=head2 [g_file_] has_parent

Checks if I<file> has a parent, and optionally, if it is I<parent>.

If I<parent> is C<Any> then this function returns C<1> if I<file> has any
parent at all.  If I<parent> is non-C<Any> then C<1> is only returned
if I<file> is an immediate child of I<parent>.

Returns: C<1> if I<file> is an immediate child of I<parent> (or any parent in
the case that I<parent> is C<Any>).

Since: 2.24

  method g_file_has_parent ( N-GFile $parent --> Int )

=item N-GFile $parent; (nullable): the parent to check for, or C<Any>

=end pod

sub g_file_has_parent ( N-GFile $file, N-GFile $parent --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_get_child:
=begin pod
=head2 [g_file_] get_child

Gets a child of I<file> with basename equal to I<name>.

Note that the file with that specific name might not exist, but
you can still have a B<N-GFile> that points to it. You can use this
for instance to create that file.

This call does no blocking I/O.

Returns: (transfer full): a B<N-GFile> to a child specified by I<name>.
Free the returned object with C<clear-object()>.

  method g_file_get_child ( Str $name --> N-GFile )

=item Str $name; (type filename): string containing the child's basename

=end pod

sub g_file_get_child ( N-GFile $file, Str $name --> N-GFile )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_get_child_for_display_name:
=begin pod
=head2 [g_file_] get_child_for_display_name

Gets the child of I<file> for a given I<display_name> (i.e. a UTF-8
version of the name). If this function fails, it returns C<Any>
and I<error> will be set. This is very useful when constructing a
B<N-GFile> for a new file and the user entered the filename in the
user interface, for instance when you select a directory and
type a filename in the file selector.

This call does no blocking I/O.

Returns: (transfer full): a B<N-GFile> to the specified child, or
C<Any> if the display name couldn't be converted.
Free the returned object with C<clear-object()>.

  method g_file_get_child_for_display_name ( Str $display_name, N-GError $error --> N-GFile )

=item Str $display_name; string to a possible child
=item N-GError $error; return location for an error

=end pod

sub g_file_get_child_for_display_name ( N-GFile $file, Str $display_name, N-GError $error --> N-GFile )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_has_prefix:
=begin pod
=head2 [g_file_] has_prefix

Checks whether I<file> has the prefix specified by I<prefix>.

In other words, if the names of initial elements of I<file>'s
pathname match I<prefix>. Only full pathname elements are matched,
so a path like /foo is not considered a prefix of /foobar, only
of /foo/bar.

A B<N-GFile> is not a prefix of itself. If you want to check for
equality, use C<g_file_equal()>.

This call does no I/O, as it works purely on names. As such it can
sometimes return C<0> even if I<file> is inside a I<prefix> (from a
filesystem point of view), because the prefix of I<file> is an alias
of I<prefix>.

Virtual: prefix_matches
Returns:  C<1> if the I<files>'s parent, grandparent, etc is I<prefix>,
C<0> otherwise.

  method g_file_has_prefix ( N-GFile $prefix --> Int )

=item N-GFile $prefix; input B<N-GFile>

=end pod

sub g_file_has_prefix ( N-GFile $file, N-GFile $prefix --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_get_relative_path:
=begin pod
=head2 [g_file_] get_relative_path

Gets the path for I<descendant> relative to I<parent>.

This call does no blocking I/O.

Returns: (type filename) (nullable): string with the relative path from
I<descendant> to I<parent>, or C<Any> if I<descendant> doesn't have I<parent> as
prefix. The returned string should be freed with C<g_free()> when
no longer needed.

  method g_file_get_relative_path ( N-GFile $descendant --> Str )

=item N-GFile $descendant; input B<N-GFile>

=end pod

sub g_file_get_relative_path ( N-GFile $parent, N-GFile $descendant --> Str )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_resolve_relative_path:
=begin pod
=head2 [g_file_] resolve_relative_path

Resolves a relative path for I<file> to an absolute path.

This call does no blocking I/O.

Returns: (transfer full): B<N-GFile> to the resolved path.
C<Any> if I<relative_path> is C<Any> or if I<file> is invalid.
Free the returned object with C<clear-object()>.

  method g_file_resolve_relative_path ( Str $relative_path --> N-GFile )

=item Str $relative_path; (type filename): a given relative path string

=end pod

sub g_file_resolve_relative_path ( N-GFile $file, Str $relative_path --> N-GFile )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:g_file_is_native:
=begin pod
=head2 [g_file_] is_native

Checks to see if a file is native to the platform.

A native file is one expressed in the platform-native filename format,
e.g. "C:\Windows" or "/usr/bin/". This does not mean the file is local,
as it might be on a locally mounted remote filesystem.

On some systems non-native files may be available using the native
filesystem via a userspace filesystem (FUSE), in these cases this call
will return C<0>, but C<g_file_get_path()> will still return a native path.

This call does no blocking I/O.

Returns: C<1> if I<file> is native

  method g_file_is_native ( --> Int )


=end pod

sub g_file_is_native ( N-GFile $file --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_file_has_uri_scheme:
=begin pod
=head2 [g_file_] has_uri_scheme

Checks to see if a B<N-GFile> has a given URI scheme.

This call does no blocking I/O.

Returns: C<1> if B<N-GFile>'s backend supports the
given URI scheme, C<0> if URI scheme is C<Any>,
not supported, or B<N-GFile> is invalid.

  method g_file_has_uri_scheme ( Str $uri_scheme --> Int )

=item Str $uri_scheme; a string containing a URI scheme

=end pod

sub g_file_has_uri_scheme ( N-GFile $file, Str $uri_scheme --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_file_get_uri_scheme:
=begin pod
=head2 [g_file_] get_uri_scheme

Gets the URI scheme for a B<N-GFile>.
RFC 3986 decodes the scheme as:
|[
URI = scheme ":" hier-part [ "?" query ] [ "#" fragment ]
]|
Common schemes include "file", "http", "ftp", etc.

This call does no blocking I/O.

Returns: a string containing the URI scheme for the given
B<N-GFile>. The returned string should be freed with C<g_free()>
when no longer needed.

  method g_file_get_uri_scheme ( --> Str )


=end pod

sub g_file_get_uri_scheme ( N-GFile $file --> Str )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_file_read:
=begin pod
=head2 g_file_read

Opens a file for reading. The result is a B<N-GFileInputStream> that
can be used to read the contents of the file.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

If the file does not exist, the C<G_IO_ERROR_NOT_FOUND> error will be
returned. If the file is a directory, the C<G_IO_ERROR_IS_DIRECTORY>
error will be returned. Other errors are possible too, and depend
on what kind of filesystem the file is on.

Virtual: read_fn
Returns: (transfer full): B<GFileInputStream> or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_read ( GCancellable $cancellable, N-GError $error --> GFileInputStream )

=item GCancellable $cancellable; (nullable): a B<GCancellable>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_read ( N-GFile $file, GCancellable $cancellable, N-GError $error --> GFileInputStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_read_async:
=begin pod
=head2 [g_file_] read_async

Asynchronously opens I<file> for reading.

For more details, see C<g_file_read()> which is
the synchronous version of this call.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_read_finish()> to get the result
of the operation.

  method g_file_read_async ( Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_read_async ( N-GFile $file, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_read_finish:
=begin pod
=head2 [g_file_] read_finish

Finishes an asynchronous file read operation started with
C<g_file_read_async()>.

Returns: (transfer full): a B<GFileInputStream> or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_read_finish ( GAsyncResult $res, N-GError $error --> GFileInputStream )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_read_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileInputStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_append_to:
=begin pod
=head2 [g_file_] append_to

Gets an output stream for appending data to the file.
If the file doesn't already exist it is created.

By default files created are generally readable by everyone,
but if you pass B<G_FILE_CREATE_PRIVATE> in I<flags> the file
will be made readable only to the current user, to the level that
is supported on the target filesystem.

If I<cancellable> is not C<Any>, then the operation can be cancelled
by triggering the cancellable object from another thread. If the
operation was cancelled, the error C<G_IO_ERROR_CANCELLED> will be
returned.

Some file systems don't allow all file names, and may return an
C<G_IO_ERROR_INVALID_FILENAME> error. If the file is a directory the
C<G_IO_ERROR_IS_DIRECTORY> error will be returned. Other errors are
possible too, and depend on what kind of filesystem the file is on.

Returns: (transfer full): a B<GFileOutputStream>, or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_append_to ( GFileCreateFlags $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream )

=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_append_to ( N-GFile $file, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_create:
=begin pod
=head2 g_file_create

Creates a new file and returns an output stream for writing to it.
The file must not already exist.

By default files created are generally readable by everyone,
but if you pass B<G_FILE_CREATE_PRIVATE> in I<flags> the file
will be made readable only to the current user, to the level
that is supported on the target filesystem.

If I<cancellable> is not C<Any>, then the operation can be cancelled
by triggering the cancellable object from another thread. If the
operation was cancelled, the error C<G_IO_ERROR_CANCELLED> will be
returned.

If a file or directory with this name already exists the
C<G_IO_ERROR_EXISTS> error will be returned. Some file systems don't
allow all file names, and may return an C<G_IO_ERROR_INVALID_FILENAME>
error, and if the name is to long C<G_IO_ERROR_FILENAME_TOO_LONG> will
be returned. Other errors are possible too, and depend on what kind
of filesystem the file is on.

Returns: (transfer full): a B<GFileOutputStream> for the newly created
file, or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_create ( GFileCreateFlags $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream )

=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_create ( N-GFile $file, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace:
=begin pod
=head2 g_file_replace

Returns an output stream for overwriting the file, possibly
creating a backup copy of the file first. If the file doesn't exist,
it will be created.

This will try to replace the file in the safest way possible so
that any errors during the writing will not affect an already
existing copy of the file. For instance, for local files it
may write to a temporary file and then atomically rename over
the destination when the stream is closed.

By default files created are generally readable by everyone,
but if you pass B<G_FILE_CREATE_PRIVATE> in I<flags> the file
will be made readable only to the current user, to the level that
is supported on the target filesystem.

If I<cancellable> is not C<Any>, then the operation can be cancelled
by triggering the cancellable object from another thread. If the
operation was cancelled, the error C<G_IO_ERROR_CANCELLED> will be
returned.

If you pass in a non-C<Any> I<etag> value and I<file> already exists, then
this value is compared to the current entity tag of the file, and if
they differ an C<G_IO_ERROR_WRONG_ETAG> error is returned. This
generally means that the file has been changed since you last read
it. You can get the new etag from C<g_file_output_stream_get_etag()>
after you've finished writing and closed the B<GFileOutputStream>. When
you load a new file you can use C<g_file_input_stream_query_info()> to
get the etag of the file.

If I<make_backup> is C<1>, this function will attempt to make a
backup of the current file before overwriting it. If this fails
a C<G_IO_ERROR_CANT_CREATE_BACKUP> error will be returned. If you
want to replace anyway, try again with I<make_backup> set to C<0>.

If the file is a directory the C<G_IO_ERROR_IS_DIRECTORY> error will
be returned, and if the file is some other form of non-regular file
then a C<G_IO_ERROR_NOT_REGULAR_FILE> error will be returned. Some
file systems don't allow all file names, and may return an
C<G_IO_ERROR_INVALID_FILENAME> error, and if the name is to long
C<G_IO_ERROR_FILENAME_TOO_LONG> will be returned. Other errors are
possible too, and depend on what kind of filesystem the file is on.

Returns: (transfer full): a B<GFileOutputStream> or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_replace ( Str $etag, Int $make_backup, GFileCreateFlags $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream )

=item Str $etag; (nullable): an optional [entity tag][gfile-etag] for the current B<N-GFile>, or B<NULL> to ignore
=item Int $make_backup; C<1> if a backup should be created
=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_replace ( N-GFile $file, Str $etag, int32 $make_backup, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_append_to_async:
=begin pod
=head2 [g_file_] append_to_async

Asynchronously opens I<file> for appending.

For more details, see C<g_file_append_to()> which is
the synchronous version of this call.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_append_to_finish()> to get the result
of the operation.

  method g_file_append_to_async ( GFileCreateFlags $flags, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_append_to_async ( N-GFile $file, int32 $flags, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_append_to_finish:
=begin pod
=head2 [g_file_] append_to_finish

Finishes an asynchronous file append operation started with
C<g_file_append_to_async()>.

Returns: (transfer full): a valid B<GFileOutputStream>
or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_append_to_finish ( GAsyncResult $res, N-GError $error --> GFileOutputStream )

=item GAsyncResult $res; B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_append_to_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileOutputStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_create_async:
=begin pod
=head2 [g_file_] create_async

Asynchronously creates a new file and returns an output stream
for writing to it. The file must not already exist.

For more details, see C<g_file_create()> which is
the synchronous version of this call.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_create_finish()> to get the result
of the operation.

  method g_file_create_async ( GFileCreateFlags $flags, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_create_async ( N-GFile $file, int32 $flags, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_create_finish:
=begin pod
=head2 [g_file_] create_finish

Finishes an asynchronous file create operation started with
C<g_file_create_async()>.

Returns: (transfer full): a B<GFileOutputStream> or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_create_finish ( GAsyncResult $res, N-GError $error --> GFileOutputStream )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_create_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileOutputStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace_async:
=begin pod
=head2 [g_file_] replace_async

Asynchronously overwrites the file, replacing the contents,
possibly creating a backup copy of the file first.

For more details, see C<g_file_replace()> which is
the synchronous version of this call.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_replace_finish()> to get the result
of the operation.

  method g_file_replace_async ( Str $etag, Int $make_backup, GFileCreateFlags $flags, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $etag; (nullable): an [entity tag][gfile-etag] for the current B<N-GFile>, or C<Any> to ignore
=item Int $make_backup; C<1> if a backup should be created
=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_replace_async ( N-GFile $file, Str $etag, int32 $make_backup, int32 $flags, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace_finish:
=begin pod
=head2 [g_file_] replace_finish

Finishes an asynchronous file replace operation started with
C<g_file_replace_async()>.

Returns: (transfer full): a B<GFileOutputStream>, or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_replace_finish ( GAsyncResult $res, N-GError $error --> GFileOutputStream )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_replace_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileOutputStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_open_readwrite:
=begin pod
=head2 [g_file_] open_readwrite

Opens an existing file for reading and writing. The result is
a B<GFileIOStream> that can be used to read and write the contents
of the file.

If I<cancellable> is not C<Any>, then the operation can be cancelled
by triggering the cancellable object from another thread. If the
operation was cancelled, the error C<G_IO_ERROR_CANCELLED> will be
returned.

If the file does not exist, the C<G_IO_ERROR_NOT_FOUND> error will
be returned. If the file is a directory, the C<G_IO_ERROR_IS_DIRECTORY>
error will be returned. Other errors are possible too, and depend on
what kind of filesystem the file is on. Note that in many non-local
file cases read and write streams are not supported, so make sure you
really need to do read and write streaming, rather than just opening
for reading or writing.

Returns: (transfer full): B<GFileIOStream> or C<Any> on error.
Free the returned object with C<clear-object()>.

Since: 2.22

  method g_file_open_readwrite ( GCancellable $cancellable, N-GError $error --> GFileIOStream )

=item GCancellable $cancellable; (nullable): a B<GCancellable>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_open_readwrite ( N-GFile $file, GCancellable $cancellable, N-GError $error --> GFileIOStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_open_readwrite_async:
=begin pod
=head2 [g_file_] open_readwrite_async



  method g_file_open_readwrite_async ( Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int $io_priority;
=item GCancellable $cancellable;
=item GAsyncReadyCallback $callback;
=item Pointer $user_data;

=end pod

sub g_file_open_readwrite_async ( N-GFile $file, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_open_readwrite_finish:
=begin pod
=head2 [g_file_] open_readwrite_finish

Finishes an asynchronous file read operation started with
C<g_file_open_readwrite_async()>.

Returns: (transfer full): a B<GFileIOStream> or C<Any> on error.
Free the returned object with C<clear-object()>.

Since: 2.22

  method g_file_open_readwrite_finish ( GAsyncResult $res, N-GError $error --> GFileIOStream )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_open_readwrite_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileIOStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_create_readwrite:
=begin pod
=head2 [g_file_] create_readwrite

Creates a new file and returns a stream for reading and
writing to it. The file must not already exist.

By default files created are generally readable by everyone,
but if you pass B<G_FILE_CREATE_PRIVATE> in I<flags> the file
will be made readable only to the current user, to the level
that is supported on the target filesystem.

If I<cancellable> is not C<Any>, then the operation can be cancelled
by triggering the cancellable object from another thread. If the
operation was cancelled, the error C<G_IO_ERROR_CANCELLED> will be
returned.

If a file or directory with this name already exists, the
C<G_IO_ERROR_EXISTS> error will be returned. Some file systems don't
allow all file names, and may return an C<G_IO_ERROR_INVALID_FILENAME>
error, and if the name is too long, C<G_IO_ERROR_FILENAME_TOO_LONG>
will be returned. Other errors are possible too, and depend on what
kind of filesystem the file is on.

Note that in many non-local file cases read and write streams are
not supported, so make sure you really need to do read and write
streaming, rather than just opening for reading or writing.

Returns: (transfer full): a B<GFileIOStream> for the newly created
file, or C<Any> on error.
Free the returned object with C<clear-object()>.

Since: 2.22

  method g_file_create_readwrite ( GFileCreateFlags $flags, GCancellable $cancellable, N-GError $error --> GFileIOStream )

=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; return location for a B<GError>, or C<Any>

=end pod

sub g_file_create_readwrite ( N-GFile $file, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileIOStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_create_readwrite_async:
=begin pod
=head2 [g_file_] create_readwrite_async

Asynchronously creates a new file and returns a stream
for reading and writing to it. The file must not already exist.

For more details, see C<g_file_create_readwrite()> which is
the synchronous version of this call.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_create_readwrite_finish()> to get
the result of the operation.

Since: 2.22

  method g_file_create_readwrite_async ( GFileCreateFlags $flags, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_create_readwrite_async ( N-GFile $file, int32 $flags, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_create_readwrite_finish:
=begin pod
=head2 [g_file_] create_readwrite_finish

Finishes an asynchronous file create operation started with
C<g_file_create_readwrite_async()>.

Returns: (transfer full): a B<GFileIOStream> or C<Any> on error.
Free the returned object with C<clear-object()>.

Since: 2.22

  method g_file_create_readwrite_finish ( GAsyncResult $res, N-GError $error --> GFileIOStream )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_create_readwrite_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileIOStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace_readwrite:
=begin pod
=head2 [g_file_] replace_readwrite

Returns an output stream for overwriting the file in readwrite mode,
possibly creating a backup copy of the file first. If the file doesn't
exist, it will be created.

For details about the behaviour, see C<g_file_replace()> which does the
same thing but returns an output stream only.

Note that in many non-local file cases read and write streams are not
supported, so make sure you really need to do read and write streaming,
rather than just opening for reading or writing.

Returns: (transfer full): a B<GFileIOStream> or C<Any> on error.
Free the returned object with C<clear-object()>.

Since: 2.22

  method g_file_replace_readwrite ( Str $etag, Int $make_backup, GFileCreateFlags $flags, GCancellable $cancellable, N-GError $error --> GFileIOStream )

=item Str $etag; (nullable): an optional [entity tag][gfile-etag] for the current B<GFile>, or B<NULL> to ignore
=item Int $make_backup; C<1> if a backup should be created
=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; return location for a B<GError>, or C<Any>

=end pod

sub g_file_replace_readwrite ( N-GFile $file, Str $etag, int32 $make_backup, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileIOStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace_readwrite_async:
=begin pod
=head2 [g_file_] replace_readwrite_async

Asynchronously overwrites the file in read-write mode,
replacing the contents, possibly creating a backup copy
of the file first.

For more details, see C<g_file_replace_readwrite()> which is
the synchronous version of this call.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_replace_readwrite_finish()> to get
the result of the operation.

Since: 2.22

  method g_file_replace_readwrite_async ( Str $etag, Int $make_backup, GFileCreateFlags $flags, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $etag; (nullable): an [entity tag][gfile-etag] for the current B<N-GFile>, or C<Any> to ignore
=item Int $make_backup; C<1> if a backup should be created
=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_replace_readwrite_async ( N-GFile $file, Str $etag, int32 $make_backup, int32 $flags, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace_readwrite_finish:
=begin pod
=head2 [g_file_] replace_readwrite_finish

Finishes an asynchronous file replace operation started with
C<g_file_replace_readwrite_async()>.

Returns: (transfer full): a B<GFileIOStream>, or C<Any> on error.
Free the returned object with C<clear-object()>.

Since: 2.22

  method g_file_replace_readwrite_finish ( GAsyncResult $res, N-GError $error --> GFileIOStream )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_replace_readwrite_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileIOStream )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_exists:
=begin pod
=head2 [g_file_] query_exists

Utility function to check if a particular file exists. This is
implemented using C<g_file_query_info()> and as such does blocking I/O.

Note that in many cases it is [racy to first check for file existence](https://en.wikipedia.org/wiki/Time_of_check_to_time_of_use)
and then execute something based on the outcome of that, because the
file might have been created or removed in between the operations. The
general approach to handling that is to not check, but just do the
operation and handle the errors as they come.

As an example of race-free checking, take the case of reading a file,
and if it doesn't exist, creating it. There are two racy versions: read
it, and on error create it; and: check if it exists, if not create it.
These can both result in two processes creating the file (with perhaps
a partially written file as the result). The correct approach is to
always try to create the file with C<g_file_create()> which will either
atomically create the file or fail with a C<G_IO_ERROR_EXISTS> error.

However, in many cases an existence check is useful in a user interface,
for instance to make a menu item sensitive/insensitive, so that you don't
have to fool users that something is possible and then just show an error
dialog. If you do this, you should make sure to also handle the errors
that can happen due to races when you execute the operation.

Returns: C<1> if the file exists (and can be detected without error),
C<0> otherwise (or if cancelled).

  method g_file_query_exists ( GCancellable $cancellable --> Int )

=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore

=end pod

sub g_file_query_exists ( N-GFile $file, GCancellable $cancellable --> int32 )
  is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_file_query_file_type:
=begin pod
=head2 [g_file_] query_file_type

Utility function to inspect the B<GFileType> of a file. This is
implemented using C<g_file_query_info()> and as such does blocking I/O.

The primary use case of this method is to check if a file is
a regular file, directory, or symlink.

Returns: The B<GFileType> of the file and B<G_FILE_TYPE_UNKNOWN>
if the file does not exist

Since: 2.18

  method g_file_query_file_type ( GFileQueryInfoFlags $flags, GCancellable $cancellable --> GFileType )

=item GFileQueryInfoFlags $flags; a set of B<GFileQueryInfoFlags> passed to C<g_file_query_info()>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore

=end pod

sub g_file_query_file_type ( N-GFile $file, int32 $flags, GCancellable $cancellable --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_info:
=begin pod
=head2 [g_file_] query_info

Gets the requested information about specified I<file>.
The result is a B<GFileInfo> object that contains key-value
attributes (such as the type or size of the file).

The I<attributes> value is a string that specifies the file
attributes that should be gathered. It is not an error if
it's not possible to read a particular requested attribute
from a file - it just won't be set. I<attributes> should be a
comma-separated list of attributes or attribute wildcards.
The wildcard "*" means all attributes, and a wildcard like
"standard::*" means all attributes in the standard namespace.
An example attribute query be "standard::*,owner::user".
The standard attributes are available as defines, like
B<G_FILE_ATTRIBUTE_STANDARD_NAME>.

If I<cancellable> is not C<Any>, then the operation can be cancelled
by triggering the cancellable object from another thread. If the
operation was cancelled, the error C<G_IO_ERROR_CANCELLED> will be
returned.

For symlinks, normally the information about the target of the
symlink is returned, rather than information about the symlink
itself. However if you pass B<G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS>
in I<flags> the information about the symlink itself will be returned.
Also, for symlinks that point to non-existing files the information
about the symlink itself will be returned.

If the file does not exist, the C<G_IO_ERROR_NOT_FOUND> error will be
returned. Other errors are possible too, and depend on what kind of
filesystem the file is on.

Returns: (transfer full): a B<GFileInfo> for the given I<file>, or C<Any>
on error. Free the returned object with C<clear-object()>.

  method g_file_query_info ( Str $attributes, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> GFileInfo )

=item Str $attributes; an attribute query string
=item GFileQueryInfoFlags $flags; a set of B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>

=end pod

sub g_file_query_info ( N-GFile $file, Str $attributes, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileInfo )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_info_async:
=begin pod
=head2 [g_file_] query_info_async

Asynchronously gets the requested information about specified I<file>.
The result is a B<GFileInfo> object that contains key-value attributes
(such as type or size for the file).

For more details, see C<g_file_query_info()> which is the synchronous
version of this call.

When the operation is finished, I<callback> will be called. You can
then call C<g_file_query_info_finish()> to get the result of the operation.

  method g_file_query_info_async ( Str $attributes, GFileQueryInfoFlags $flags, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $attributes; an attribute query string
=item GFileQueryInfoFlags $flags; a set of B<GFileQueryInfoFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_query_info_async ( N-GFile $file, Str $attributes, int32 $flags, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_info_finish:
=begin pod
=head2 [g_file_] query_info_finish

Finishes an asynchronous file info query.
See C<g_file_query_info_async()>.

Returns: (transfer full): B<GFileInfo> for given I<file>
or C<Any> on error. Free the returned object with
C<clear-object()>.

  method g_file_query_info_finish ( GAsyncResult $res, N-GError $error --> GFileInfo )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>

=end pod

sub g_file_query_info_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileInfo )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_filesystem_info:
=begin pod
=head2 [g_file_] query_filesystem_info

Similar to C<g_file_query_info()>, but obtains information
about the filesystem the I<file> is on, rather than the file itself.
For instance the amount of space available and the type of
the filesystem.

The I<attributes> value is a string that specifies the attributes
that should be gathered. It is not an error if it's not possible
to read a particular requested attribute from a file - it just
won't be set. I<attributes> should be a comma-separated list of
attributes or attribute wildcards. The wildcard "*" means all
attributes, and a wildcard like "filesystem::*" means all attributes
in the filesystem namespace. The standard namespace for filesystem
attributes is "filesystem". Common attributes of interest are
B<G_FILE_ATTRIBUTE_FILESYSTEM_SIZE> (the total size of the filesystem
in bytes), B<G_FILE_ATTRIBUTE_FILESYSTEM_FREE> (number of bytes available),
and B<G_FILE_ATTRIBUTE_FILESYSTEM_TYPE> (type of the filesystem).

If I<cancellable> is not C<Any>, then the operation can be cancelled
by triggering the cancellable object from another thread. If the
operation was cancelled, the error C<G_IO_ERROR_CANCELLED> will be
returned.

If the file does not exist, the C<G_IO_ERROR_NOT_FOUND> error will
be returned. Other errors are possible too, and depend on what
kind of filesystem the file is on.

Returns: (transfer full): a B<GFileInfo> or C<Any> if there was an error.
Free the returned object with C<clear-object()>.

  method g_file_query_filesystem_info ( Str $attributes, GCancellable $cancellable, N-GError $error --> GFileInfo )

=item Str $attributes; an attribute query string
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>

=end pod

sub g_file_query_filesystem_info ( N-GFile $file, Str $attributes, GCancellable $cancellable, N-GError $error --> GFileInfo )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_filesystem_info_async:
=begin pod
=head2 [g_file_] query_filesystem_info_async

Asynchronously gets the requested information about the filesystem
that the specified I<file> is on. The result is a B<GFileInfo> object
that contains key-value attributes (such as type or size for the
file).

For more details, see C<g_file_query_filesystem_info()> which is the
synchronous version of this call.

When the operation is finished, I<callback> will be called. You can
then call C<g_file_query_info_finish()> to get the result of the
operation.

  method g_file_query_filesystem_info_async ( Str $attributes, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $attributes; an attribute query string
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_query_filesystem_info_async ( N-GFile $file, Str $attributes, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_filesystem_info_finish:
=begin pod
=head2 [g_file_] query_filesystem_info_finish

Finishes an asynchronous filesystem info query.
See C<g_file_query_filesystem_info_async()>.

Returns: (transfer full): B<GFileInfo> for given I<file>
or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_query_filesystem_info_finish ( GAsyncResult $res, N-GError $error --> GFileInfo )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>

=end pod

sub g_file_query_filesystem_info_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileInfo )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_find_enclosing_mount:
=begin pod
=head2 [g_file_] find_enclosing_mount

Gets a B<GMount> for the B<N-GFile>.

If the B<GFileIface> for I<file> does not have a mount (e.g.
possibly a remote share), I<error> will be set to C<G_IO_ERROR_NOT_FOUND>
and C<Any> will be returned.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: (transfer full): a B<GMount> where the I<file> is located
or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_find_enclosing_mount ( GCancellable $cancellable, N-GError $error --> GMount )

=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>

=end pod

sub g_file_find_enclosing_mount ( N-GFile $file, GCancellable $cancellable, N-GError $error --> GMount )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_find_enclosing_mount_async:
=begin pod
=head2 [g_file_] find_enclosing_mount_async

Asynchronously gets the mount for the file.

For more details, see C<g_file_find_enclosing_mount()> which is
the synchronous version of this call.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_find_enclosing_mount_finish()> to
get the result of the operation.

  method g_file_find_enclosing_mount_async ( Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_find_enclosing_mount_async ( N-GFile $file, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_find_enclosing_mount_finish:
=begin pod
=head2 [g_file_] find_enclosing_mount_finish

Finishes an asynchronous find mount request.
See C<g_file_find_enclosing_mount_async()>.

Returns: (transfer full): B<GMount> for given I<file> or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_find_enclosing_mount_finish ( GAsyncResult $res, N-GError $error --> GMount )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>

=end pod

sub g_file_find_enclosing_mount_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GMount )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_enumerate_children:
=begin pod
=head2 [g_file_] enumerate_children

Gets the requested information about the files in a directory.
The result is a B<GFileEnumerator> object that will give out
B<GFileInfo> objects for all the files in the directory.

The I<attributes> value is a string that specifies the file
attributes that should be gathered. It is not an error if
it's not possible to read a particular requested attribute
from a file - it just won't be set. I<attributes> should
be a comma-separated list of attributes or attribute wildcards.
The wildcard "*" means all attributes, and a wildcard like
"standard::*" means all attributes in the standard namespace.
An example attribute query be "standard::*,owner::user".
The standard attributes are available as defines, like
B<G_FILE_ATTRIBUTE_STANDARD_NAME>.

If I<cancellable> is not C<Any>, then the operation can be cancelled
by triggering the cancellable object from another thread. If the
operation was cancelled, the error C<G_IO_ERROR_CANCELLED> will be
returned.

If the file does not exist, the C<G_IO_ERROR_NOT_FOUND> error will
be returned. If the file is not a directory, the C<G_IO_ERROR_NOT_DIRECTORY>
error will be returned. Other errors are possible too.

Returns: (transfer full): A B<GFileEnumerator> if successful,
C<Any> on error. Free the returned object with C<clear-object()>.

  method g_file_enumerate_children ( Str $attributes, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> GFileEnumerator )

=item Str $attributes; an attribute query string
=item GFileQueryInfoFlags $flags; a set of B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; B<GError> for error reporting

=end pod

sub g_file_enumerate_children ( N-GFile $file, Str $attributes, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileEnumerator )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_enumerate_children_async:
=begin pod
=head2 [g_file_] enumerate_children_async

Asynchronously gets the requested information about the files
in a directory. The result is a B<GFileEnumerator> object that will
give out B<GFileInfo> objects for all the files in the directory.

For more details, see C<g_file_enumerate_children()> which is
the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can
then call C<g_file_enumerate_children_finish()> to get the result of
the operation.

  method g_file_enumerate_children_async ( Str $attributes, GFileQueryInfoFlags $flags, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $attributes; an attribute query string
=item GFileQueryInfoFlags $flags; a set of B<GFileQueryInfoFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_enumerate_children_async ( N-GFile $file, Str $attributes, int32 $flags, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_enumerate_children_finish:
=begin pod
=head2 [g_file_] enumerate_children_finish

Finishes an async enumerate children operation.
See C<g_file_enumerate_children_async()>.

Returns: (transfer full): a B<GFileEnumerator> or C<Any>
if an error occurred.
Free the returned object with C<clear-object()>.

  method g_file_enumerate_children_finish ( GAsyncResult $res, N-GError $error --> GFileEnumerator )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>

=end pod

sub g_file_enumerate_children_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> GFileEnumerator )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_display_name:
=begin pod
=head2 [g_file_] set_display_name

Renames I<file> to the specified display name.

The display name is converted from UTF-8 to the correct encoding
for the target filesystem if possible and the I<file> is renamed to this.

If you want to implement a rename operation in the user interface the
edit name (B<G_FILE_ATTRIBUTE_STANDARD_EDIT_NAME>) should be used as the
initial value in the rename widget, and then the result after editing
should be passed to C<g_file_set_display_name()>.

On success the resulting converted filename is returned.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: (transfer full): a B<N-GFile> specifying what I<file> was renamed to,
or C<Any> if there was an error.
Free the returned object with C<clear-object()>.

  method g_file_set_display_name ( Str $display_name, GCancellable $cancellable, N-GError $error --> N-GFile )

=item Str $display_name; a string
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_display_name ( N-GFile $file, Str $display_name, GCancellable $cancellable, N-GError $error --> N-GFile )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_display_name_async:
=begin pod
=head2 [g_file_] set_display_name_async

Asynchronously sets the display name for a given B<N-GFile>.

For more details, see C<g_file_set_display_name()> which is
the synchronous version of this call.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_set_display_name_finish()> to get
the result of the operation.

  method g_file_set_display_name_async ( Str $display_name, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $display_name; a string
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_set_display_name_async ( N-GFile $file, Str $display_name, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_display_name_finish:
=begin pod
=head2 [g_file_] set_display_name_finish

Finishes setting a display name started with
C<g_file_set_display_name_async()>.

Returns: (transfer full): a B<N-GFile> or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_set_display_name_finish ( GAsyncResult $res, N-GError $error --> N-GFile )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_display_name_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> N-GFile )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_delete:
=begin pod
=head2 g_file_delete

Deletes a file. If the I<file> is a directory, it will only be
deleted if it is empty. This has the same semantics as C<g_unlink()>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Virtual: delete_file
Returns: C<1> if the file was deleted. C<0> otherwise.

  method g_file_delete ( GCancellable $cancellable, N-GError $error --> Int )

=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_delete ( N-GFile $file, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_delete_async:
=begin pod
=head2 [g_file_] delete_async

Asynchronously delete a file. If the I<file> is a directory, it will
only be deleted if it is empty.  This has the same semantics as
C<g_unlink()>.

Virtual: delete_file_async
Since: 2.34

  method g_file_delete_async ( Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_delete_async ( N-GFile $file, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_delete_finish:
=begin pod
=head2 [g_file_] delete_finish

Finishes deleting a file started with C<g_file_delete_async()>.

Virtual: delete_file_finish
Returns: C<1> if the file was deleted. C<0> otherwise.
Since: 2.34

  method g_file_delete_finish ( GAsyncResult $result, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_delete_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:g_file_trash:
=begin pod
=head2 g_file_trash

Sends I<file> to the "Trashcan", if possible. This is similar to
deleting it, but the user can recover it before emptying the trashcan.
Not all file systems support trashing, so this call can return the
C<G_IO_ERROR_NOT_SUPPORTED> error.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Virtual: trash
Returns: C<1> on successful trash, C<0> otherwise.

  method g_file_trash ( GCancellable $cancellable, N-GError $error --> Int )

=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_trash ( N-GFile $file, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_trash_async:
=begin pod
=head2 [g_file_] trash_async

Asynchronously sends I<file> to the Trash location, if possible.

Virtual: trash_async
Since: 2.38

  method g_file_trash_async ( Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_trash_async ( N-GFile $file, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_trash_finish:
=begin pod
=head2 [g_file_] trash_finish

Finishes an asynchronous file trashing operation, started with
C<g_file_trash_async()>.

Virtual: trash_finish
Returns: C<1> on successful trash, C<0> otherwise.
Since: 2.38

  method g_file_trash_finish ( GAsyncResult $result, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_trash_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_copy:
=begin pod
=head2 g_file_copy

Copies the file I<source> to the location specified by I<destination>.
Can not handle recursive copies of directories.

If the flag B<G_FILE_COPY_OVERWRITE> is specified an already
existing I<destination> file is overwritten.

If the flag B<G_FILE_COPY_NOFOLLOW_SYMLINKS> is specified then symlinks
will be copied as symlinks, otherwise the target of the
I<source> symlink will be copied.

If the flag B<G_FILE_COPY_ALL_METADATA> is specified then all the metadata
that is possible to copy is copied, not just the default subset (which,
for instance, does not include the owner, see B<GFileInfo>).

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

If I<progress_callback> is not C<Any>, then the operation can be monitored
by setting this to a B<GFileProgressCallback> function.
I<progress_callback_data> will be passed to this function. It is guaranteed
that this callback will be called after all data has been transferred with
the total number of bytes copied during the operation.

If the I<source> file does not exist, then the C<G_IO_ERROR_NOT_FOUND> error
is returned, independent on the status of the I<destination>.

If B<G_FILE_COPY_OVERWRITE> is not specified and the target exists, then
the error C<G_IO_ERROR_EXISTS> is returned.

If trying to overwrite a file over a directory, the C<G_IO_ERROR_IS_DIRECTORY>
error is returned. If trying to overwrite a directory with a directory the
C<G_IO_ERROR_WOULD_MERGE> error is returned.

If the source is a directory and the target does not exist, or
B<G_FILE_COPY_OVERWRITE> is specified and the target is a file, then the
C<G_IO_ERROR_WOULD_RECURSE> error is returned.

If you are interested in copying the B<N-GFile> object itself (not the on-disk
file), see C<g_file_dup()>.

Returns: C<1> on success, C<0> otherwise.

  method g_file_copy ( N-GFile $destination, GFileCopyFlags $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, N-GError $error --> Int )

=item N-GFile $destination; destination B<N-GFile>
=item GFileCopyFlags $flags; set of B<GFileCopyFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GFileProgressCallback $progress_callback; (nullable) (scope call): function to callback with progress information, or C<Any> if progress information is not needed
=item Pointer $progress_callback_data; (closure): user data to pass to I<progress_callback>
=item N-GError $error; B<GError> to set on error, or C<Any>

=end pod

sub g_file_copy ( N-GFile $source, N-GFile $destination, int32 $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_copy_async:
=begin pod
=head2 [g_file_] copy_async

Copies the file I<source> to the location specified by I<destination>
asynchronously. For details of the behaviour, see C<g_file_copy()>.

If I<progress_callback> is not C<Any>, then that function that will be called
just like in C<g_file_copy()>. The callback will run in the default main context
of the thread calling C<g_file_copy_async()> — the same context as I<callback> is
run in.

When the operation is finished, I<callback> will be called. You can then call
C<g_file_copy_finish()> to get the result of the operation.

  method g_file_copy_async ( N-GFile $destination, GFileCopyFlags $flags, Int $io_priority, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, GAsyncReadyCallback $callback, Pointer $user_data )

=item N-GFile $destination; destination B<N-GFile>
=item GFileCopyFlags $flags; set of B<GFileCopyFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GFileProgressCallback $progress_callback; (nullable) (scope notified): function to callback with progress information, or C<Any> if progress information is not needed
=item Pointer $progress_callback_data; (closure progress_callback) (nullable): user data to pass to I<progress_callback>
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure callback): the data to pass to callback function

=end pod

sub g_file_copy_async ( N-GFile $source, N-GFile $destination, int32 $flags, int32 $io_priority, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_copy_finish:
=begin pod
=head2 [g_file_] copy_finish

Finishes copying the file started with C<g_file_copy_async()>.

Returns: a C<1> on success, C<0> on error.

  method g_file_copy_finish ( GAsyncResult $res, N-GError $error --> Int )

=item GAsyncResult $res; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_copy_finish ( N-GFile $file, GAsyncResult $res, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_move:
=begin pod
=head2 g_file_move

Tries to move the file or directory I<source> to the location specified
by I<destination>. If native move operations are supported then this is
used, otherwise a copy + delete fallback is used. The native
implementation may support moving directories (for instance on moves
inside the same filesystem), but the fallback code does not.

If the flag B<G_FILE_COPY_OVERWRITE> is specified an already
existing I<destination> file is overwritten.

If the flag B<G_FILE_COPY_NOFOLLOW_SYMLINKS> is specified then symlinks
will be copied as symlinks, otherwise the target of the
I<source> symlink will be copied.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

If I<progress_callback> is not C<Any>, then the operation can be monitored
by setting this to a B<GFileProgressCallback> function.
I<progress_callback_data> will be passed to this function. It is
guaranteed that this callback will be called after all data has been
transferred with the total number of bytes copied during the operation.

If the I<source> file does not exist, then the C<G_IO_ERROR_NOT_FOUND>
error is returned, independent on the status of the I<destination>.

If B<G_FILE_COPY_OVERWRITE> is not specified and the target exists,
then the error C<G_IO_ERROR_EXISTS> is returned.

If trying to overwrite a file over a directory, the C<G_IO_ERROR_IS_DIRECTORY>
error is returned. If trying to overwrite a directory with a directory the
C<G_IO_ERROR_WOULD_MERGE> error is returned.

If the source is a directory and the target does not exist, or
B<G_FILE_COPY_OVERWRITE> is specified and the target is a file, then
the C<G_IO_ERROR_WOULD_RECURSE> error may be returned (if the native
move operation isn't available).

Returns: C<1> on successful move, C<0> otherwise.

  method g_file_move ( N-GFile $destination, GFileCopyFlags $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, N-GError $error --> Int )

=item N-GFile $destination; B<N-GFile> pointing to the destination location
=item GFileCopyFlags $flags; set of B<GFileCopyFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GFileProgressCallback $progress_callback; (nullable) (scope call): B<GFileProgressCallback> function for updates
=item Pointer $progress_callback_data; (closure): gpointer to user data for the callback function
=item N-GError $error; B<GError> for returning error conditions, or C<Any>

=end pod

sub g_file_move ( N-GFile $source, N-GFile $destination, int32 $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_make_directory:
=begin pod
=head2 [g_file_] make_directory

Creates a directory. Note that this will only create a child directory
of the immediate parent directory of the path or URI given by the B<N-GFile>.
To recursively create directories, see C<g_file_make_directory_with_parents()>.
This function will fail if the parent directory does not exist, setting
I<error> to C<G_IO_ERROR_NOT_FOUND>. If the file system doesn't support
creating directories, this function will fail, setting I<error> to
C<G_IO_ERROR_NOT_SUPPORTED>.

For a local B<N-GFile> the newly created directory will have the default
(current) ownership and permissions of the current process.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> on successful creation, C<0> otherwise.

  method g_file_make_directory ( GCancellable $cancellable, N-GError $error --> Int )

=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_make_directory ( N-GFile $file, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_make_directory_async:
=begin pod
=head2 [g_file_] make_directory_async

Asynchronously creates a directory.

Virtual: make_directory_async
Since: 2.38

  method g_file_make_directory_async ( Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_make_directory_async ( N-GFile $file, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_make_directory_finish:
=begin pod
=head2 [g_file_] make_directory_finish

Finishes an asynchronous directory creation, started with
C<g_file_make_directory_async()>.

Virtual: make_directory_finish
Returns: C<1> on successful directory creation, C<0> otherwise.
Since: 2.38

  method g_file_make_directory_finish ( GAsyncResult $result, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_make_directory_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_make_directory_with_parents:
=begin pod
=head2 [g_file_] make_directory_with_parents

Creates a directory and any parent directories that may not
exist similar to 'mkdir -p'. If the file system does not support
creating directories, this function will fail, setting I<error> to
C<G_IO_ERROR_NOT_SUPPORTED>. If the directory itself already exists,
this function will fail setting I<error> to C<G_IO_ERROR_EXISTS>, unlike
the similar C<g_mkdir_with_parents()>.

For a local B<N-GFile> the newly created directories will have the default
(current) ownership and permissions of the current process.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> if all directories have been successfully created, C<0>
otherwise.

Since: 2.18

  method g_file_make_directory_with_parents ( GCancellable $cancellable, N-GError $error --> Int )

=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_make_directory_with_parents ( N-GFile $file, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_make_symbolic_link:
=begin pod
=head2 [g_file_] make_symbolic_link

Creates a symbolic link named I<file> which contains the string
I<symlink_value>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> on the creation of a new symlink, C<0> otherwise.

  method g_file_make_symbolic_link ( Str $symlink_value, GCancellable $cancellable, N-GError $error --> Int )

=item Str $symlink_value; (type filename): a string with the path for the target of the new symlink
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>

=end pod

sub g_file_make_symbolic_link ( N-GFile $file, Str $symlink_value, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_settable_attributes:
=begin pod
=head2 [g_file_] query_settable_attributes

Obtain the list of settable attributes for the file.

Returns the type and full attribute name of all the attributes
that can be set on this file. This doesn't mean setting it will
always succeed though, you might get an access failure, or some
specific file may not support a specific attribute.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: a B<GFileAttributeInfoList> describing the settable attributes.
When you are done with it, release it with
C<g_file_attribute_info_list_unref()>

  method g_file_query_settable_attributes ( GCancellable $cancellable, N-GError $error --> GFileAttributeInfoList )

=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_query_settable_attributes ( N-GFile $file, GCancellable $cancellable, N-GError $error --> GFileAttributeInfoList )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_writable_namespaces:
=begin pod
=head2 [g_file_] query_writable_namespaces

Obtain the list of attribute namespaces where new attributes
can be created by a user. An example of this is extended
attributes (in the "xattr" namespace).

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: a B<GFileAttributeInfoList> describing the writable namespaces.
When you are done with it, release it with
C<g_file_attribute_info_list_unref()>

  method g_file_query_writable_namespaces ( GCancellable $cancellable, N-GError $error --> GFileAttributeInfoList )

=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_query_writable_namespaces ( N-GFile $file, GCancellable $cancellable, N-GError $error --> GFileAttributeInfoList )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attribute:
=begin pod
=head2 [g_file_] set_attribute

Sets an attribute in the file with attribute name I<attribute> to I<value>.

Some attributes can be unset by setting I<type> to
C<G_FILE_ATTRIBUTE_TYPE_INVALID> and I<value_p> to C<Any>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> if the attribute was set, C<0> otherwise.

  method g_file_set_attribute ( Str $attribute, GFileAttributeType $type, Pointer $value_p, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Int )

=item Str $attribute; a string containing the attribute's name
=item GFileAttributeType $type; The type of the attribute
=item Pointer $value_p; (nullable): a pointer to the value (or the pointer itself if the type is a pointer type)
=item GFileQueryInfoFlags $flags; a set of B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_attribute ( N-GFile $file, Str $attribute, int32 $type, Pointer $value_p, int32 $flags, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attributes_from_info:
=begin pod
=head2 [g_file_] set_attributes_from_info

Tries to set all attributes in the B<GFileInfo> on the target
values, not stopping on the first error.

If there is any error during this operation then I<error> will
be set to the first error. Error on particular fields are flagged
by setting the "status" field in the attribute value to
C<G_FILE_ATTRIBUTE_STATUS_ERROR_SETTING>, which means you can
also detect further errors.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<0> if there was any error, C<1> otherwise.

  method g_file_set_attributes_from_info ( GFileInfo $info, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Int )

=item GFileInfo $info; a B<GFileInfo>
=item GFileQueryInfoFlags $flags; B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_attributes_from_info ( N-GFile $file, GFileInfo $info, int32 $flags, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attributes_async:
=begin pod
=head2 [g_file_] set_attributes_async

Asynchronously sets the attributes of I<file> with I<info>.

For more details, see C<g_file_set_attributes_from_info()>,
which is the synchronous version of this call.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_set_attributes_finish()> to get
the result of the operation.

  method g_file_set_attributes_async ( GFileInfo $info, GFileQueryInfoFlags $flags, Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GFileInfo $info; a B<GFileInfo>
=item GFileQueryInfoFlags $flags; a B<GFileQueryInfoFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback>
=item Pointer $user_data; (closure): a B<gpointer>

=end pod

sub g_file_set_attributes_async ( N-GFile $file, GFileInfo $info, int32 $flags, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attributes_finish:
=begin pod
=head2 [g_file_] set_attributes_finish

Finishes setting an attribute started in C<g_file_set_attributes_async()>.

Returns: C<1> if the attributes were set correctly, C<0> otherwise.

  method g_file_set_attributes_finish ( GAsyncResult $result, GFileInfo $info, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item GFileInfo $info; (out) (transfer full): a B<GFileInfo>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_attributes_finish ( N-GFile $file, GAsyncResult $result, GFileInfo $info, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attribute_string:
=begin pod
=head2 [g_file_] set_attribute_string

Sets I<attribute> of type C<G_FILE_ATTRIBUTE_TYPE_STRING> to I<value>.
If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> if the I<attribute> was successfully set, C<0> otherwise.

  method g_file_set_attribute_string ( Str $attribute, Str $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Int )

=item Str $attribute; a string containing the attribute's name
=item Str $value; a string containing the attribute's value
=item GFileQueryInfoFlags $flags; B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_attribute_string ( N-GFile $file, Str $attribute, Str $value, int32 $flags, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attribute_byte_string:
=begin pod
=head2 [g_file_] set_attribute_byte_string

Sets I<attribute> of type C<G_FILE_ATTRIBUTE_TYPE_BYTE_STRING> to I<value>.
If I<attribute> is of a different type, this operation will fail,
returning C<0>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> if the I<attribute> was successfully set to I<value>
in the I<file>, C<0> otherwise.

  method g_file_set_attribute_byte_string ( Str $attribute, Str $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Int )

=item Str $attribute; a string containing the attribute's name
=item Str $value; a string containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_attribute_byte_string ( N-GFile $file, Str $attribute, Str $value, int32 $flags, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attribute_uint32:
=begin pod
=head2 [g_file_] set_attribute_uint32

Sets I<attribute> of type C<G_FILE_ATTRIBUTE_TYPE_UINT32> to I<value>.
If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> if the I<attribute> was successfully set to I<value>
in the I<file>, C<0> otherwise.

  method g_file_set_attribute_uint32 ( Str $attribute, UInt $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Int )

=item Str $attribute; a string containing the attribute's name
=item UInt $value; a B<guint32> containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_attribute_uint32 ( N-GFile $file, Str $attribute, uint32 $value, int32 $flags, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attribute_int32:
=begin pod
=head2 [g_file_] set_attribute_int32

Sets I<attribute> of type C<G_FILE_ATTRIBUTE_TYPE_INT32> to I<value>.
If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> if the I<attribute> was successfully set to I<value>
in the I<file>, C<0> otherwise.

  method g_file_set_attribute_int32 ( Str $attribute, Int $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Int )

=item Str $attribute; a string containing the attribute's name
=item Int $value; a B<gint32> containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_attribute_int32 ( N-GFile $file, Str $attribute, int32 $value, int32 $flags, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attribute_uint64:
=begin pod
=head2 [g_file_] set_attribute_uint64

Sets I<attribute> of type C<G_FILE_ATTRIBUTE_TYPE_UINT64> to I<value>.
If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> if the I<attribute> was successfully set to I<value>
in the I<file>, C<0> otherwise.

  method g_file_set_attribute_uint64 ( Str $attribute, UInt $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Int )

=item Str $attribute; a string containing the attribute's name
=item UInt $value; a B<guint64> containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_attribute_uint64 ( N-GFile $file, Str $attribute, uint64 $value, int32 $flags, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_set_attribute_int64:
=begin pod
=head2 [g_file_] set_attribute_int64

Sets I<attribute> of type C<G_FILE_ATTRIBUTE_TYPE_INT64> to I<value>.
If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> if the I<attribute> was successfully set, C<0> otherwise.

  method g_file_set_attribute_int64 ( Str $attribute, Int $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Int )

=item Str $attribute; a string containing the attribute's name
=item Int $value; a B<guint64> containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<GFileQueryInfoFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_set_attribute_int64 ( N-GFile $file, Str $attribute, int64 $value, int32 $flags, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_mount_enclosing_volume:
=begin pod
=head2 [g_file_] mount_enclosing_volume

Starts a I<mount_operation>, mounting the volume that contains
the file I<location>.

When this operation has completed, I<callback> will be called with
I<user_user> data, and the operation can be finalized with
C<g_file_mount_enclosing_volume_finish()>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

  method g_file_mount_enclosing_volume ( GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountMountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; (nullable): a B<GMountOperation> or C<Any> to avoid user interaction
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (nullable): a B<GAsyncReadyCallback> to call when the request is satisfied, or C<Any>
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_mount_enclosing_volume ( N-GFile $location, GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_mount_enclosing_volume_finish:
=begin pod
=head2 [g_file_] mount_enclosing_volume_finish

Finishes a mount operation started by C<g_file_mount_enclosing_volume()>.

Returns: C<1> if successful. If an error has occurred,
this function will return C<0> and set I<error>
appropriately if present.

  method g_file_mount_enclosing_volume_finish ( GAsyncResult $result, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_mount_enclosing_volume_finish ( N-GFile $location, GAsyncResult $result, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_mount_mountable:
=begin pod
=head2 [g_file_] mount_mountable

Mounts a file of type G_FILE_TYPE_MOUNTABLE.
Using I<mount_operation>, you can request callbacks when, for instance,
passwords are needed during authentication.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_mount_mountable_finish()> to get
the result of the operation.

  method g_file_mount_mountable ( GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountMountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; (nullable): a B<GMountOperation>, or C<Any> to avoid user interaction
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async) (nullable): a B<GAsyncReadyCallback> to call when the request is satisfied, or C<Any>
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_mount_mountable ( N-GFile $file, GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_mount_mountable_finish:
=begin pod
=head2 [g_file_] mount_mountable_finish

Finishes a mount operation. See C<g_file_mount_mountable()> for details.

Finish an asynchronous mount operation that was started
with C<g_file_mount_mountable()>.

Returns: (transfer full): a B<N-GFile> or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_mount_mountable_finish ( GAsyncResult $result, N-GError $error --> N-GFile )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_mount_mountable_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> N-GFile )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_unmount_mountable_with_operation:
=begin pod
=head2 [g_file_] unmount_mountable_with_operation

Unmounts a file of type B<G_FILE_TYPE_MOUNTABLE>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_unmount_mountable_finish()> to get
the result of the operation.

Since: 2.22

  method g_file_unmount_mountable_with_operation ( GMountUnmountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountUnmountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; (nullable): a B<GMountOperation>, or C<Any> to avoid user interaction
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async) (nullable): a B<GAsyncReadyCallback> to call when the request is satisfied, or C<Any>
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_unmount_mountable_with_operation ( N-GFile $file, int32 $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_unmount_mountable_with_operation_finish:
=begin pod
=head2 [g_file_] unmount_mountable_with_operation_finish

Finishes an unmount operation,
see C<g_file_unmount_mountable_with_operation()> for details.

Finish an asynchronous unmount operation that was started
with C<g_file_unmount_mountable_with_operation()>.

Returns: C<1> if the operation finished successfully.
C<0> otherwise.

Since: 2.22

  method g_file_unmount_mountable_with_operation_finish ( GAsyncResult $result, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_unmount_mountable_with_operation_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_eject_mountable_with_operation:
=begin pod
=head2 [g_file_] eject_mountable_with_operation

Starts an asynchronous eject on a mountable.
When this operation has completed, I<callback> will be called with
I<user_user> data, and the operation can be finalized with
C<g_file_eject_mountable_with_operation_finish()>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Since: 2.22

  method g_file_eject_mountable_with_operation ( GMountUnmountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountUnmountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; (nullable): a B<GMountOperation>, or C<Any> to avoid user interaction
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (scope async) (nullable): a B<GAsyncReadyCallback> to call when the request is satisfied, or C<Any>
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_eject_mountable_with_operation ( N-GFile $file, int32 $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_eject_mountable_with_operation_finish:
=begin pod
=head2 [g_file_] eject_mountable_with_operation_finish

Finishes an asynchronous eject operation started by
C<g_file_eject_mountable_with_operation()>.

Returns: C<1> if the I<file> was ejected successfully.
C<0> otherwise.

Since: 2.22

  method g_file_eject_mountable_with_operation_finish ( GAsyncResult $result, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_eject_mountable_with_operation_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_copy_attributes:
=begin pod
=head2 [g_file_] copy_attributes

Copies the file attributes from I<source> to I<destination>.

Normally only a subset of the file attributes are copied,
those that are copies in a normal file copy operation
(which for instance does not include e.g. owner). However
if B<G_FILE_COPY_ALL_METADATA> is specified in I<flags>, then
all the metadata that is possible to copy is copied. This
is useful when implementing move by copy + delete source.

Returns: C<1> if the attributes were copied successfully,
C<0> otherwise.

  method g_file_copy_attributes ( N-GFile $destination, GFileCopyFlags $flags, GCancellable $cancellable, N-GError $error --> Int )

=item N-GFile $destination; a B<N-GFile> to copy attributes to
=item GFileCopyFlags $flags; a set of B<GFileCopyFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, C<Any> to ignore

=end pod

sub g_file_copy_attributes ( N-GFile $source, N-GFile $destination, int32 $flags, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

}}


#`{{
#-------------------------------------------------------------------------------
#TM:0:g_file_monitor_directory:
=begin pod
=head2 [g_file_] monitor_directory

Obtains a directory monitor for the given file.
This may fail if directory monitoring is not supported.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

It does not make sense for I<flags> to contain
C<G_FILE_MONITOR_WATCH_HARD_LINKS>, since hard links can not be made to
directories.  It is not possible to monitor all the files in a
directory for changes made via hard links; if you want to do this then
you must register individual watches with C<g_file_monitor()>.

Virtual: monitor_dir
Returns: (transfer full): a B<GFileMonitor> for the given I<file>,
or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_monitor_directory ( GFileMonitorFlags $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor )

=item GFileMonitorFlags $flags; a set of B<GFileMonitorFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_monitor_directory ( N-GFile $file, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_monitor_file:
=begin pod
=head2 [g_file_] monitor_file

Obtains a file monitor for the given file. If no file notification
mechanism exists, then regular polling of the file is used.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

If I<flags> contains C<G_FILE_MONITOR_WATCH_HARD_LINKS> then the monitor
will also attempt to report changes made to the file via another
filename (ie, a hard link). Without this flag, you can only rely on
changes made through the filename contained in I<file> to be
reported. Using this flag may result in an increase in resource
usage, and may not have any effect depending on the B<GFileMonitor>
backend and/or filesystem type.

Returns: (transfer full): a B<GFileMonitor> for the given I<file>,
or C<Any> on error.
Free the returned object with C<clear-object()>.

  method g_file_monitor_file ( GFileMonitorFlags $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor )

=item GFileMonitorFlags $flags; a set of B<GFileMonitorFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_monitor_file ( N-GFile $file, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_monitor:
=begin pod
=head2 g_file_monitor

Obtains a file or directory monitor for the given file,
depending on the type of the file.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: (transfer full): a B<GFileMonitor> for the given I<file>,
or C<Any> on error.
Free the returned object with C<clear-object()>.

Since: 2.18

  method g_file_monitor ( GFileMonitorFlags $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor )

=item GFileMonitorFlags $flags; a set of B<GFileMonitorFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_monitor ( N-GFile $file, int32 $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_measure_disk_usage:
=begin pod
=head2 [g_file_] measure_disk_usage

Recursively measures the disk usage of I<file>.

This is essentially an analog of the 'du' command, but it also
reports the number of directories and non-directory files encountered
(including things like symbolic links).

By default, errors are only reported against the toplevel file
itself.  Errors found while recursing are silently ignored, unless
C<G_FILE_DISK_USAGE_REPORT_ALL_ERRORS> is given in I<flags>.

The returned size, I<disk_usage>, is in bytes and should be formatted
with C<g_format_size()> in order to get something reasonable for showing
in a user interface.

I<progress_callback> and I<progress_data> can be given to request
periodic progress updates while scanning.  See the documentation for
B<GFileMeasureProgressCallback> for information about when and how the
callback will be invoked.

Returns: C<1> if successful, with the out parameters set.
C<0> otherwise, with I<error> set.

Since: 2.38

  method g_file_measure_disk_usage ( GFileMeasureFlags $flags, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, Pointer $progress_data, UInt $disk_usage, UInt $num_dirs, UInt $num_files, N-GError $error --> Int )

=item GFileMeasureFlags $flags; B<GFileMeasureFlags>
=item GCancellable $cancellable; (nullable): optional B<GCancellable>
=item GFileMeasureProgressCallback $progress_callback; (nullable): a B<GFileMeasureProgressCallback>
=item Pointer $progress_data; user_data for I<progress_callback>
=item UInt $disk_usage; (out) (optional): the number of bytes of disk space used
=item UInt $num_dirs; (out) (optional): the number of directories encountered
=item UInt $num_files; (out) (optional): the number of non-directories encountered
=item N-GError $error; (nullable): C<Any>, or a pointer to a C<Any> B<GError> pointer

=end pod

sub g_file_measure_disk_usage ( N-GFile $file, int32 $flags, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, Pointer $progress_data, uint64 $disk_usage, uint64 $num_dirs, uint64 $num_files, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_measure_disk_usage_async:
=begin pod
=head2 [g_file_] measure_disk_usage_async

Recursively measures the disk usage of I<file>.

This is the asynchronous version of C<g_file_measure_disk_usage()>.  See
there for more information.

Since: 2.38

  method g_file_measure_disk_usage_async ( GFileMeasureFlags $flags, Int $io_priority, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, Pointer $progress_data, GAsyncReadyCallback $callback, Pointer $user_data )

=item GFileMeasureFlags $flags; B<GFileMeasureFlags>
=item Int $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; (nullable): optional B<GCancellable>
=item GFileMeasureProgressCallback $progress_callback; (nullable): a B<GFileMeasureProgressCallback>
=item Pointer $progress_data; user_data for I<progress_callback>
=item GAsyncReadyCallback $callback; (nullable): a B<GAsyncReadyCallback> to call when complete
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_measure_disk_usage_async ( N-GFile $file, int32 $flags, int32 $io_priority, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, Pointer $progress_data, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_measure_disk_usage_finish:
=begin pod
=head2 [g_file_] measure_disk_usage_finish

Collects the results from an earlier call to
C<g_file_measure_disk_usage_async()>.  See C<g_file_measure_disk_usage()> for
more information.

Returns: C<1> if successful, with the out parameters set.
C<0> otherwise, with I<error> set.

Since: 2.38

  method g_file_measure_disk_usage_finish ( GAsyncResult $result, UInt $disk_usage, UInt $num_dirs, UInt $num_files, N-GError $error --> Int )

=item GAsyncResult $result; the B<GAsyncResult> passed to your B<GAsyncReadyCallback>
=item UInt $disk_usage; (out) (optional): the number of bytes of disk space used
=item UInt $num_dirs; (out) (optional): the number of directories encountered
=item UInt $num_files; (out) (optional): the number of non-directories encountered
=item N-GError $error; (nullable): C<Any>, or a pointer to a C<Any> B<GError> pointer

=end pod

sub g_file_measure_disk_usage_finish ( N-GFile $file, GAsyncResult $result, uint64 $disk_usage, uint64 $num_dirs, uint64 $num_files, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_start_mountable:
=begin pod
=head2 [g_file_] start_mountable

Starts a file of type B<G_FILE_TYPE_MOUNTABLE>.
Using I<start_operation>, you can request callbacks when, for instance,
passwords are needed during authentication.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_mount_mountable_finish()> to get
the result of the operation.

Since: 2.22

  method g_file_start_mountable ( GDriveStartFlags $flags, GMountOperation $start_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GDriveStartFlags $flags; flags affecting the operation
=item GMountOperation $start_operation; (nullable): a B<GMountOperation>, or C<Any> to avoid user interaction
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (nullable): a B<GAsyncReadyCallback> to call when the request is satisfied, or C<Any>
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_start_mountable ( N-GFile $file, GDriveStartFlags $flags, GMountOperation $start_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_start_mountable_finish:
=begin pod
=head2 [g_file_] start_mountable_finish

Finishes a start operation. See C<g_file_start_mountable()> for details.

Finish an asynchronous start operation that was started
with C<g_file_start_mountable()>.

Returns: C<1> if the operation finished successfully. C<0>
otherwise.

Since: 2.22

  method g_file_start_mountable_finish ( GAsyncResult $result, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_start_mountable_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_stop_mountable:
=begin pod
=head2 [g_file_] stop_mountable

Stops a file of type B<G_FILE_TYPE_MOUNTABLE>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_stop_mountable_finish()> to get
the result of the operation.

Since: 2.22

  method g_file_stop_mountable ( GMountUnmountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountUnmountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; (nullable): a B<GMountOperation>, or C<Any> to avoid user interaction.
=item GCancellable $cancellable; (nullable): optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (nullable): a B<GAsyncReadyCallback> to call when the request is satisfied, or C<Any>
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_stop_mountable ( N-GFile $file, int32 $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_stop_mountable_finish:
=begin pod
=head2 [g_file_] stop_mountable_finish

Finishes an stop operation, see C<g_file_stop_mountable()> for details.

Finish an asynchronous stop operation that was started
with C<g_file_stop_mountable()>.

Returns: C<1> if the operation finished successfully.
C<0> otherwise.

Since: 2.22

  method g_file_stop_mountable_finish ( GAsyncResult $result, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_stop_mountable_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_poll_mountable:
=begin pod
=head2 [g_file_] poll_mountable

Polls a file of type B<G_FILE_TYPE_MOUNTABLE>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

When the operation is finished, I<callback> will be called.
You can then call C<g_file_mount_mountable_finish()> to get
the result of the operation.

Since: 2.22

  method g_file_poll_mountable ( GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GCancellable $cancellable; optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; (nullable): a B<GAsyncReadyCallback> to call when the request is satisfied, or C<Any>
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_poll_mountable ( N-GFile $file, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_poll_mountable_finish:
=begin pod
=head2 [g_file_] poll_mountable_finish

Finishes a poll operation. See C<g_file_poll_mountable()> for details.

Finish an asynchronous poll operation that was polled
with C<g_file_poll_mountable()>.

Returns: C<1> if the operation finished successfully. C<0>
otherwise.

Since: 2.22

  method g_file_poll_mountable_finish ( GAsyncResult $result, N-GError $error --> Int )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_poll_mountable_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_default_handler:
=begin pod
=head2 [g_file_] query_default_handler

Returns the B<GAppInfo> that is registered as the default
application to handle the file specified by I<file>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: (transfer full): a B<GAppInfo> if the handle was found,
C<Any> if there were errors.
When you are done with it, release it with C<clear-object()>

  method g_file_query_default_handler ( GCancellable $cancellable, N-GError $error --> GAppInfo )

=item GCancellable $cancellable; optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_query_default_handler ( N-GFile $file, GCancellable $cancellable, N-GError $error --> GAppInfo )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_default_handler_async:
=begin pod
=head2 [g_file_] query_default_handler_async

Async version of C<g_file_query_default_handler()>.

Since: 2.60

  method g_file_query_default_handler_async ( Int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int $io_priority; optional B<GCancellable> object, C<Any> to ignore
=item GCancellable $cancellable; (nullable): a B<GAsyncReadyCallback> to call when the request is done
=item GAsyncReadyCallback $callback; (nullable): data to pass to I<callback>
=item Pointer $user_data;

=end pod

sub g_file_query_default_handler_async ( N-GFile $file, int32 $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_query_default_handler_finish:
=begin pod
=head2 [g_file_] query_default_handler_finish

Finishes a C<g_file_query_default_handler_async()> operation.

Returns: (transfer full): a B<GAppInfo> if the handle was found,
C<Any> if there were errors.
When you are done with it, release it with C<clear-object()>

Since: 2.60

  method g_file_query_default_handler_finish ( GAsyncResult $result, N-GError $error --> GAppInfo )

=item GAsyncResult $result; a B<GAsyncResult>
=item N-GError $error; (nullable): a B<GError>

=end pod

sub g_file_query_default_handler_finish ( N-GFile $file, GAsyncResult $result, N-GError $error --> GAppInfo )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_load_contents:
=begin pod
=head2 [g_file_] load_contents

Loads the content of the file into memory. The data is always
zero-terminated, but this is not included in the resultant I<length>.
The returned I<content> should be freed with C<g_free()> when no longer
needed.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

Returns: C<1> if the I<file>'s contents were successfully loaded.
C<0> if there were errors.

  method g_file_load_contents ( GCancellable $cancellable, CArray[Str] $contents, UInt $length, CArray[Str] $etag_out, N-GError $error --> Int )

=item GCancellable $cancellable; optional B<GCancellable> object, C<Any> to ignore
=item CArray[Str] $contents; (out) (transfer full) (element-type guint8) (array length=length): a location to place the contents of the file
=item UInt $length; (out) (optional): a location to place the length of the contents of the file, or C<Any> if the length is not needed
=item CArray[Str] $etag_out; (out) (optional): a location to place the current entity tag for the file, or C<Any> if the entity tag is not needed
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_load_contents ( N-GFile $file, GCancellable $cancellable, CArray[Str] $contents, uint64 $length, CArray[Str] $etag_out, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_load_contents_async:
=begin pod
=head2 [g_file_] load_contents_async

Starts an asynchronous load of the I<file>'s contents.

For more details, see C<g_file_load_contents()> which is
the synchronous version of this call.

When the load operation has completed, I<callback> will be called
with I<user> data. To finish the operation, call
C<g_file_load_contents_finish()> with the B<GAsyncResult> returned by
the I<callback>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

  method g_file_load_contents_async ( GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GCancellable $cancellable; optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_load_contents_async ( N-GFile $file, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_load_contents_finish:
=begin pod
=head2 [g_file_] load_contents_finish

Finishes an asynchronous load of the I<file>'s contents.
The contents are placed in I<contents>, and I<length> is set to the
size of the I<contents> string. The I<content> should be freed with
C<g_free()> when no longer needed. If I<etag_out> is present, it will be
set to the new entity tag for the I<file>.

Returns: C<1> if the load was successful. If C<0> and I<error> is
present, it will be set appropriately.

  method g_file_load_contents_finish ( GAsyncResult $res, CArray[Str] $contents, UInt $length, CArray[Str] $etag_out, N-GError $error --> Int )

=item GAsyncResult $res; a B<GAsyncResult>
=item CArray[Str] $contents; (out) (transfer full) (element-type guint8) (array length=length): a location to place the contents of the file
=item UInt $length; (out) (optional): a location to place the length of the contents of the file, or C<Any> if the length is not needed
=item CArray[Str] $etag_out; (out) (optional): a location to place the current entity tag for the file, or C<Any> if the entity tag is not needed
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_load_contents_finish ( N-GFile $file, GAsyncResult $res, CArray[Str] $contents, uint64 $length, CArray[Str] $etag_out, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_load_partial_contents_async:
=begin pod
=head2 [g_file_] load_partial_contents_async

Reads the partial contents of a file. A B<GFileReadMoreCallback> should
be used to stop reading from the file when appropriate, else this
function will behave exactly as C<g_file_load_contents_async()>. This
operation can be finished by C<g_file_load_partial_contents_finish()>.

Users of this function should be aware that I<user_data> is passed to
both the I<read_more_callback> and the I<callback>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

  method g_file_load_partial_contents_async ( GCancellable $cancellable, GFileReadMoreCallback $read_more_callback, GAsyncReadyCallback $callback, Pointer $user_data )

=item GCancellable $cancellable; optional B<GCancellable> object, C<Any> to ignore
=item GFileReadMoreCallback $read_more_callback; (scope call) (closure user_data): a B<GFileReadMoreCallback> to receive partial data and to specify whether further data should be read
=item GAsyncReadyCallback $callback; (scope async) (closure user_data): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to the callback functions

=end pod

sub g_file_load_partial_contents_async ( N-GFile $file, GCancellable $cancellable, GFileReadMoreCallback $read_more_callback, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_load_partial_contents_finish:
=begin pod
=head2 [g_file_] load_partial_contents_finish

Finishes an asynchronous partial load operation that was started
with C<g_file_load_partial_contents_async()>. The data is always
zero-terminated, but this is not included in the resultant I<length>.
The returned I<content> should be freed with C<g_free()> when no longer
needed.

Returns: C<1> if the load was successful. If C<0> and I<error> is
present, it will be set appropriately.

  method g_file_load_partial_contents_finish ( GAsyncResult $res, CArray[Str] $contents, UInt $length, CArray[Str] $etag_out, N-GError $error --> Int )

=item GAsyncResult $res; a B<GAsyncResult>
=item CArray[Str] $contents; (out) (transfer full) (element-type guint8) (array length=length): a location to place the contents of the file
=item UInt $length; (out) (optional): a location to place the length of the contents of the file, or C<Any> if the length is not needed
=item CArray[Str] $etag_out; (out) (optional): a location to place the current entity tag for the file, or C<Any> if the entity tag is not needed
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_load_partial_contents_finish ( N-GFile $file, GAsyncResult $res, CArray[Str] $contents, uint64 $length, CArray[Str] $etag_out, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace_contents:
=begin pod
=head2 [g_file_] replace_contents

Replaces the contents of I<file> with I<contents> of I<length> bytes.

If I<etag> is specified (not C<Any>), any existing file must have that etag,
or the error C<G_IO_ERROR_WRONG_ETAG> will be returned.

If I<make_backup> is C<1>, this function will attempt to make a backup
of I<file>. Internally, it uses C<g_file_replace()>, so will try to replace the
file contents in the safest way possible. For example, atomic renames are
used when replacing local files’ contents.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

The returned I<new_etag> can be used to verify that the file hasn't
changed the next time it is saved over.

Returns: C<1> if successful. If an error has occurred, this function
will return C<0> and set I<error> appropriately if present.

  method g_file_replace_contents ( Str $contents, UInt $length, Str $etag, Int $make_backup, GFileCreateFlags $flags, CArray[Str] $new_etag, GCancellable $cancellable, N-GError $error --> Int )

=item Str $contents; (element-type guint8) (array length=length): a string containing the new contents for I<file>
=item UInt $length; the length of I<contents> in bytes
=item Str $etag; (nullable): the old [entity-tag][gfile-etag] for the document, or C<Any>
=item Int $make_backup; C<1> if a backup should be created
=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item CArray[Str] $new_etag; (out) (optional): a location to a new [entity tag][gfile-etag] for the document. This should be freed with C<g_free()> when no longer needed, or C<Any>
=item GCancellable $cancellable; optional B<GCancellable> object, C<Any> to ignore
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_replace_contents ( N-GFile $file, Str $contents, uint64 $length, Str $etag, int32 $make_backup, int32 $flags, CArray[Str] $new_etag, GCancellable $cancellable, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace_contents_async:
=begin pod
=head2 [g_file_] replace_contents_async

Starts an asynchronous replacement of I<file> with the given
I<contents> of I<length> bytes. I<etag> will replace the document's
current entity tag.

When this operation has completed, I<callback> will be called with
I<user_user> data, and the operation can be finalized with
C<g_file_replace_contents_finish()>.

If I<cancellable> is not C<Any>, then the operation can be cancelled by
triggering the cancellable object from another thread. If the operation
was cancelled, the error C<G_IO_ERROR_CANCELLED> will be returned.

If I<make_backup> is C<1>, this function will attempt to
make a backup of I<file>.

Note that no copy of I<content> will be made, so it must stay valid
until I<callback> is called. See C<g_file_replace_contents_bytes_async()>
for a B<GBytes> version that will automatically hold a reference to the
contents (without copying) for the duration of the call.

  method g_file_replace_contents_async ( Str $contents, UInt $length, Str $etag, Int $make_backup, GFileCreateFlags $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $contents; (element-type guint8) (array length=length): string of contents to replace the file with
=item UInt $length; the length of I<contents> in bytes
=item Str $etag; (nullable): a new [entity tag][gfile-etag] for the I<file>, or C<Any>
=item Int $make_backup; C<1> if a backup should be created
=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item GCancellable $cancellable; optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_replace_contents_async ( N-GFile $file, Str $contents, uint64 $length, Str $etag, int32 $make_backup, int32 $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace_contents_bytes_async:
=begin pod
=head2 [g_file_] replace_contents_bytes_async

Same as C<g_file_replace_contents_async()> but takes a B<GBytes> input instead.
This function will keep a ref on I<contents> until the operation is done.
Unlike C<g_file_replace_contents_async()> this allows forgetting about the
content without waiting for the callback.

When this operation has completed, I<callback> will be called with
I<user_user> data, and the operation can be finalized with
C<g_file_replace_contents_finish()>.

Since: 2.40

  method g_file_replace_contents_bytes_async ( N-GObject $contents, Str $etag, Int $make_backup, GFileCreateFlags $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item N-GObject $contents; a B<GBytes>
=item Str $etag; (nullable): a new [entity tag][gfile-etag] for the I<file>, or C<Any>
=item Int $make_backup; C<1> if a backup should be created
=item GFileCreateFlags $flags; a set of B<GFileCreateFlags>
=item GCancellable $cancellable; optional B<GCancellable> object, C<Any> to ignore
=item GAsyncReadyCallback $callback; a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function

=end pod

sub g_file_replace_contents_bytes_async ( N-GFile $file, N-GObject $contents, Str $etag, int32 $make_backup, int32 $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_replace_contents_finish:
=begin pod
=head2 [g_file_] replace_contents_finish

Finishes an asynchronous replace of the given I<file>. See
C<g_file_replace_contents_async()>. Sets I<new_etag> to the new entity
tag for the document, if present.

Returns: C<1> on success, C<0> on failure.

  method g_file_replace_contents_finish ( GAsyncResult $res, CArray[Str] $new_etag, N-GError $error --> Int )

=item GAsyncResult $res; a B<GAsyncResult>
=item CArray[Str] $new_etag; (out) (optional): a location of a new [entity tag][gfile-etag] for the document. This should be freed with C<g_free()> when it is no longer needed, or C<Any>
=item N-GError $error; a B<GError>, or C<Any>

=end pod

sub g_file_replace_contents_finish ( N-GFile $file, GAsyncResult $res, CArray[Str] $new_etag, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_supports_thread_contexts:
=begin pod
=head2 [g_file_] supports_thread_contexts

Checks if I<file> supports
[thread-default contexts][g-main-context-push-thread-default-context].
If this returns C<0>, you cannot perform asynchronous operations on
I<file> in a thread that has a thread-default context.

Returns: Whether or not I<file> supports thread-default contexts.

Since: 2.22

  method g_file_supports_thread_contexts ( --> Int )


=end pod

sub g_file_supports_thread_contexts ( N-GFile $file --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_load_bytes:
=begin pod
=head2 [g_file_] load_bytes

Loads the contents of I<file> and returns it as B<GBytes>.

If I<file> is a resource:// based URI, the resulting bytes will reference the
embedded resource instead of a copy. Otherwise, this is equivalent to calling
C<g_file_load_contents()> and C<g_bytes_new_take()>.

For resources, I<etag_out> will be set to C<Any>.

The data contained in the resulting B<GBytes> is always zero-terminated, but
this is not included in the B<GBytes> length. The resulting B<GBytes> should be
freed with C<g_bytes_unref()> when no longer in use.

Returns: (transfer full): a B<GBytes> or C<Any> and I<error> is set

Since: 2.56

  method g_file_load_bytes ( GCancellable $cancellable, CArray[Str] $etag_out, N-GError $error --> N-GObject )

=item GCancellable $cancellable; (nullable): a B<GCancellable> or C<Any>
=item CArray[Str] $etag_out; (out) (nullable) (optional): a location to place the current entity tag for the file, or C<Any> if the entity tag is not needed
=item N-GError $error; a location for a B<GError> or C<Any>

=end pod

sub g_file_load_bytes ( N-GFile $file, GCancellable $cancellable, CArray[Str] $etag_out, N-GError $error --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_load_bytes_async:
=begin pod
=head2 [g_file_] load_bytes_async

Asynchronously loads the contents of I<file> as B<GBytes>.

If I<file> is a resource:// based URI, the resulting bytes will reference the
embedded resource instead of a copy. Otherwise, this is equivalent to calling
C<g_file_load_contents_async()> and C<g_bytes_new_take()>.

I<callback> should call C<g_file_load_bytes_finish()> to get the result of this
asynchronous operation.

See C<g_file_load_bytes()> for more information.

Since: 2.56

  method g_file_load_bytes_async ( GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GCancellable $cancellable; (nullable): a B<GCancellable> or C<Any>
=item GAsyncReadyCallback $callback; (scope async): a B<GAsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function

=end pod

sub g_file_load_bytes_async ( N-GFile $file, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_file_load_bytes_finish:
=begin pod
=head2 [g_file_] load_bytes_finish

Completes an asynchronous request to C<g_file_load_bytes_async()>.

For resources, I<etag_out> will be set to C<Any>.

The data contained in the resulting B<GBytes> is always zero-terminated, but
this is not included in the B<GBytes> length. The resulting B<GBytes> should be
freed with C<g_bytes_unref()> when no longer in use.

See C<g_file_load_bytes()> for more information.

Returns: (transfer full): a B<GBytes> or C<Any> and I<error> is set

Since: 2.56

  method g_file_load_bytes_finish ( GAsyncResult $result, CArray[Str] $etag_out, N-GError $error --> N-GObject )

=item GAsyncResult $result; a B<GAsyncResult> provided to the callback
=item CArray[Str] $etag_out; (out) (nullable) (optional): a location to place the current entity tag for the file, or C<Any> if the entity tag is not needed
=item N-GError $error; a location for a B<GError>, or C<Any>

=end pod

sub g_file_load_bytes_finish ( N-GFile $file, GAsyncResult $result, CArray[Str] $etag_out, N-GError $error --> N-GObject )
  is native(&gio-lib)
  { * }
}}
