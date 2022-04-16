#TL:1:Gnome::Gio::File:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::File

File and Directory Handling


=head1 Description

B<Gnome::Gio::File> is a high level abstraction for manipulating files on a virtual file system. B<N-GFiles> are lightweight, immutable objects that do no I/O upon creation. It is necessary to understand that B<Gnome::Gio::File> objects do not represent files, merely an identifier for a file.

To construct a B<Gnome::Gio::File>, you can use:
=item C<.new(:path)> if you have a path.
=item C<.new(:uri)> if you have a URI.
=item C<.new(:commandline-arg)> for a command line argument.
=comment item C<g_file_new_tmp()> to create a temporary file from a template.
=comment item C<g_file_parse_name()> from a UTF-8 string gotten from C<g_file_get_parse_name()>.
=comment item C<g_file_new_build_filename()> to create a file from path elements.

One way to think of a B<Gnome::Gio::File> is as an abstraction of a pathname. For normal files the system pathname is what is stored internally, but as B<N-GFiles> are extensible it could also be something else that corresponds to a pathname in a userspace implementation of a filesystem.

Many of the native subroutines originally in this module are not implemented in this Raku class. This is because I/O is very well supported by Raku and there is no need to provide I/O routines here. This class mainly exists to handle returned native objects from other classes. The most important calls needed are thus to get the name of a file or url.


=begin comment
B<N-GFiles> make up hierarchies of directories and files that correspond to the files on a filesystem. You can move through the file system with B<Gnome::Gio::File> using C<g_file_get_parent()> to get an identifier for the parent directory, C<g_file_get_child()> to get a child within a directory, C<g_file_resolve_relative_path()> to resolve a relative path between two B<N-GFiles>. There can be multiple hierarchies, so you may not end up at the same root if you repeatedly call C<g_file_get_parent()> on two different files.

All B<N-GFiles> have a basename (get with C<g_file_get_basename()>). These names are byte strings that are used to identify the file on the filesystem (relative to its parent directory) and there is no guarantees that they have any particular charset encoding or even make any sense at all. If you want to use filenames in a user interface you should use the display name that you can get by requesting the C<G_FILE_ATTRIBUTE_STANDARD_DISPLAY_NAME> attribute with C<g_file_query_info()>. This is guaranteed to be in UTF-8 and can be used in a user interface. But always store the real basename or the B<Gnome::Gio::File> to use to actually access the file, because there is no way to go from a display name to the actual name.

Using B<Gnome::Gio::File> as an identifier has the same weaknesses as using a path in that there may be multiple aliases for the same file. For instance, hard or soft links may cause two different B<N-GFiles> to refer to the same file. Other possible causes for aliases are: case insensitive filesystems, short and long names on FAT/NTFS, or bind mounts in Linux. If you want to check if two B<N-GFiles> point to the same file you can query for the C<G_FILE_ATTRIBUTE_ID_FILE> attribute. Note that B<Gnome::Gio::File> does some trivial canonicalization of pathnames passed in, so that trivial differences in the path string used at creation (duplicated slashes, slash at end of path, "." or ".." path segments, etc) does not create different B<N-GFiles>.

Many B<Gnome::Gio::File> operations have both synchronous and asynchronous versions to suit your application. Asynchronous versions of synchronous functions simply have C<_async()> appended to their function names. The asynchronous I/O functions call a B<GAsyncReadyCallback> which is then used to finalize the operation, producing a GAsyncResult which is then passed to the function's matching C<_finish()> operation.

It is highly recommended to use asynchronous calls when running within a shared main loop, such as in the main thread of an application. This avoids I/O operations blocking other sources on the main loop from being dispatched. Synchronous I/O operations should be performed from worker threads. See the [introduction to asynchronous programming section][async-programming] for more.

Some B<Gnome::Gio::File> operations almost always take a noticeable amount of time, and so do not have synchronous analogs. Notable cases include:
=item C<g_file_mount_mountable()> to mount a mountable file.
=item C<g_file_unmount_mountable_with_operation()> to unmount a mountable file.
=item C<g_file_eject_mountable_with_operation()> to eject a mountable file.


=head2 Entity Tags

One notable feature of B<N-GFiles> are entity tags, or "etags" for short. Entity tags are somewhat like a more abstract version of the traditional mtime, and can be used to quickly determine if the file has been modified from the version on the file system. See the HTTP 1.1 [specification](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html) for HTTP Etag headers, which are a very similar concept.

=end comment


=begin comment
=head2 See Also

B<Gnome::Gio::FileInfo>, B<Gnome::Gio::FileEnumerator>
=end comment


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::File;
  also is Gnome::N::TopLevelClassSupport;


=head2 Note

B<Gnome::Gio::File> is defined as an interface in the Gnome libraries and therefore should be defined as a Raku role. However, many Gnome modules return native B<Gnome::Gio::File> objects as if they are class objects. There aren't even Gnome classes using it as an interface. Presumably, it is defined like that so the developer can create classes using the File class as an interface which will not be the case in Raku.


=head2 Note

B<Gnome::Gio::File> has many functions of which a large part will not be made available in Raku. This is because many are about read/write, move and rename which Raku is able to do very nice.


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

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::Error;
use Gnome::GObject::Object;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::File:auth<github:MARTIMM>:ver<0.2.0>;
also is Gnome::N::TopLevelClassSupport;

has Gnome::Glib::Error $.last-error;
#-------------------------------------------------------------------------------
=begin pod
=head1 Types

=head2 class N-GFile

Native object to hold a file representation

=end pod

#TODO deprecate N-GFile and make it N-GObject
#TT:1:N-GFile:
class N-GFile
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :path

Create a new File object using a path to a file.

  multi method new ( Str :$path! )


=head3 :uri

Create a new File object using a uri.

  multi method new ( Str :$uri! )


=head3 :commandline-arg, :cwd

Creates a B<Gnome::Gio::File> with the given argument from the command line. The value of I<arg> can be either a URI, an absolute path or a relative path resolved relative to the current working directory. This operation never fails, but the returned object might not support any I/O operation if I<arg> points to a malformed path.

Note that on Windows, this function expects its argument to be in UTF-8 -- not the system code page. This means that you should not use this function with string from argv as it is passed to C<main()>. C<g-win32-get-command-line()> will return a UTF-8 version of the commandline. B<Gnome::Gio::Application> also uses UTF-8 but C<g-application-command-line-create-file-for-arg()> may be more useful for you there. It is also always possible to use this function with B<Gnome::Gio::OptionContext> arguments of type C<G-OPTION-ARG-FILENAME>.

Optionally a directory relative to the argument can be given in $cwd. Otherwise the working directory of the application is used.

  multi method new ( Str :$commandline-arg!, Str :$cwd? )


=head3 :native-object

Create a File object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

# TM:0:new():inheriting
#TM:1:new(:path):
#TM:1:new(:uri):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::File' #`{{ or %options<GFile> }} {

    $!last-error .= new(:native-object(N-GError));

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    else {
      my $no;

      if ? %options<path> {
        $no = _g_file_new_for_path(%options<path>);
      }

      elsif ? %options<uri> {
        $no = _g_file_new_for_uri(%options<uri>);
      }

      elsif ? %options<commandline-arg> {
        if ? %options<cwd> {
          $no = _g_file_new_for_commandline_arg_and_cwd(
            %options<commandline-arg>, %options<cwd>
          );
        }

        else {
          $no = _g_file_new_for_commandline_arg(%options<commandline-arg>);
        }
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
        self._set-native-object(g_file_new());
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GFile');
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

  self._set-class-name-of-sub('GFile');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object --> N-GFile ) {
  $n-native-object
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_object_unref($n-native-object)
}

#-------------------------------------------------------------------------------
#TM:1:_g_object_unref:
#`{{
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
}}

# reason for File to use Object. Inheritance is not needed because there are no
# signals to process.
sub _g_object_unref ( N-GFile $object )
  is native(&gobject-lib)
  is symbol('g_object_unref')
  { * }


#`{{
#-------------------------------------------------------------------------------
# TM:0:append-to:
=begin pod
=head2 append-to

Gets an output stream for appending data to the file. If the file doesn't already exist it is created.

By default files created are generally readable by everyone, but if you pass B<Gnome::Gio::-FILE-CREATE-PRIVATE> in I<flags> the file will be made readable only to the current user, to the level that is supported on the target filesystem.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Some file systems don't allow all file names, and may return an C<G-IO-ERROR-INVALID-FILENAME> error. If the file is a directory the C<G-IO-ERROR-IS-DIRECTORY> error will be returned. Other errors are possible too, and depend on what kind of filesystem the file is on.

Returns: a B<Gnome::Gio::FileOutputStream>, or C<undefined> on error. Free the returned object with C<clear-object()>.

  method append-to ( UInt $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream )

=item UInt $flags; a set of B<UInt>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method append-to ( UInt $flags, GCancellable $cancellable, $error is copy --> GFileOutputStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_append_to(
    self._get-native-object-no-reffing, $flags, $cancellable, $error
  )
}

sub g_file_append_to (
  N-GFile $file, GFlag $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:append-to-async:
=begin pod
=head2 append-to-async

Asynchronously opens I<file> for appending.

For more details, see C<append-to()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-append-to-finish()> to get the result of the operation.

  method append-to-async ( UInt $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item UInt $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method append-to-async ( UInt $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_append_to_async(
    self._get-native-object-no-reffing, $flags, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_append_to_async (
  N-GFile $file, GFlag $flags, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:append-to-finish:
=begin pod
=head2 append-to-finish

Finishes an asynchronous file append operation started with C<append-to-async()>.

Returns: a valid B<Gnome::Gio::FileOutputStream> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method append-to-finish ( GAsyncResult $res, N-GError $error --> GFileOutputStream )

=item GAsyncResult $res; B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method append-to-finish ( GAsyncResult $res, $error is copy --> GFileOutputStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_append_to_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_append_to_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileOutputStream
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:copy:
=begin pod
=head2 copy

Copies the file I<source> to the location specified by I<destination>. Can not handle recursive copies of directories.

If the flag B<Gnome::Gio::-FILE-COPY-OVERWRITE> is specified an already existing I<destination> file is overwritten.

If the flag B<Gnome::Gio::-FILE-COPY-NOFOLLOW-SYMLINKS> is specified then symlinks will be copied as symlinks, otherwise the target of the I<source> symlink will be copied.

If the flag B<Gnome::Gio::-FILE-COPY-ALL-METADATA> is specified then all the metadata that is possible to copy is copied, not just the default subset (which, for instance, does not include the owner, see B<Gnome::Gio::FileInfo>).

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If I<progress-callback> is not C<undefined>, then the operation can be monitored by setting this to a B<Gnome::Gio::FileProgressCallback> function. I<progress-callback-data> will be passed to this function. It is guaranteed that this callback will be called after all data has been transferred with the total number of bytes copied during the operation.

If the I<source> file does not exist, then the C<G-IO-ERROR-NOT-FOUND> error is returned, independent on the status of the I<destination>.

If B<Gnome::Gio::-FILE-COPY-OVERWRITE> is not specified and the target exists, then the error C<G-IO-ERROR-EXISTS> is returned.

If trying to overwrite a file over a directory, the C<G-IO-ERROR-IS-DIRECTORY> error is returned. If trying to overwrite a directory with a directory the C<G-IO-ERROR-WOULD-MERGE> error is returned.

If the source is a directory and the target does not exist, or B<Gnome::Gio::-FILE-COPY-OVERWRITE> is specified and the target is a file, then the C<G-IO-ERROR-WOULD-RECURSE> error is returned.

If you are interested in copying the B<Gnome::Gio::File> object itself (not the on-disk file), see C<dup()>.

Returns: C<True> on success, C<False> otherwise.

  method copy ( N-GFile $destination, UInt $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, N-GError $error --> Bool )

=item N-GFile $destination; destination B<Gnome::Gio::File>
=item UInt $flags; set of B<Gnome::Gio::FileCopyFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GFileProgressCallback $progress_callback;  (scope call): function to callback with progress information, or C<undefined> if progress information is not needed
=item Pointer $progress_callback_data; (closure): user data to pass to I<progress-callback>
=item N-GError $error; B<Gnome::Gio::Error> to set on error, or C<undefined>
=end pod

method copy ( N-GFile $destination, UInt $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_copy(
    self._get-native-object-no-reffing, $destination, $flags, $cancellable, $progress_callback, $progress_callback_data, $error
  ).Bool
}

sub g_file_copy (
  N-GFile $source, N-GFile $destination, GFlag $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, gpointer $progress_callback_data, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:copy-async:
=begin pod
=head2 copy-async

Copies the file I<source> to the location specified by I<destination> asynchronously. For details of the behaviour, see C<copy()>.

If I<progress-callback> is not C<undefined>, then that function that will be called just like in C<g-file-copy()>. The callback will run in the default main context of the thread calling C<g-file-copy-async()> — the same context as I<callback> is run in.

When the operation is finished, I<callback> will be called. You can then call C<g-file-copy-finish()> to get the result of the operation.

  method copy-async ( N-GFile $destination, UInt $flags, Int() $io_priority, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, GAsyncReadyCallback $callback, Pointer $user_data )

=item N-GFile $destination; destination B<Gnome::Gio::File>
=item UInt $flags; set of B<Gnome::Gio::FileCopyFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GFileProgressCallback $progress_callback;  (scope notified): function to callback with progress information, or C<undefined> if progress information is not needed
=item Pointer $progress_callback_data; (closure progress-callback) : user data to pass to I<progress-callback>
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure callback): the data to pass to callback function
=end pod

method copy-async ( N-GFile $destination, UInt $flags, Int() $io_priority, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_copy_async(
    self._get-native-object-no-reffing, $destination, $flags, $io_priority, $cancellable, $progress_callback, $progress_callback_data, $callback, $user_data
  );
}

sub g_file_copy_async (
  N-GFile $source, N-GFile $destination, GFlag $flags, int $io_priority, GCancellable $cancellable, GFileProgressCallback $progress_callback, gpointer $progress_callback_data, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:copy-attributes:
=begin pod
=head2 copy-attributes

Copies the file attributes from I<source> to I<destination>.

Normally only a subset of the file attributes are copied, those that are copies in a normal file copy operation (which for instance does not include e.g. owner). However if B<Gnome::Gio::-FILE-COPY-ALL-METADATA> is specified in I<flags>, then all the metadata that is possible to copy is copied. This is useful when implementing move by copy + delete source.

Returns: C<True> if the attributes were copied successfully, C<False> otherwise.

  method copy-attributes ( N-GFile $destination, UInt $flags, GCancellable $cancellable, N-GError $error --> Bool )

=item N-GFile $destination; a B<Gnome::Gio::File> to copy attributes to
=item UInt $flags; a set of B<Gnome::Gio::FileCopyFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, C<undefined> to ignore
=end pod

method copy-attributes ( N-GFile $destination, UInt $flags, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_copy_attributes(
    self._get-native-object-no-reffing, $destination, $flags, $cancellable, $error
  ).Bool
}

sub g_file_copy_attributes (
  N-GFile $source, N-GFile $destination, GFlag $flags, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:copy-finish:
=begin pod
=head2 copy-finish

Finishes copying the file started with C<copy-async()>.

Returns: a C<True> on success, C<False> on error.

  method copy-finish ( GAsyncResult $res, N-GError $error --> Bool )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method copy-finish ( GAsyncResult $res, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_copy_finish(
    self._get-native-object-no-reffing, $res, $error
  ).Bool
}

sub g_file_copy_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:create:
=begin pod
=head2 create

Creates a new file and returns an output stream for writing to it. The file must not already exist.

By default files created are generally readable by everyone, but if you pass B<Gnome::Gio::-FILE-CREATE-PRIVATE> in I<flags> the file will be made readable only to the current user, to the level that is supported on the target filesystem.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If a file or directory with this name already exists the C<G-IO-ERROR-EXISTS> error will be returned. Some file systems don't allow all file names, and may return an C<G-IO-ERROR-INVALID-FILENAME> error, and if the name is to long C<G-IO-ERROR-FILENAME-TOO-LONG> will be returned. Other errors are possible too, and depend on what kind of filesystem the file is on.

Returns: a B<Gnome::Gio::FileOutputStream> for the newly created file, or C<undefined> on error. Free the returned object with C<clear-object()>.

  method create ( UInt $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream )

=item UInt $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method create ( UInt $flags, GCancellable $cancellable, $error is copy --> GFileOutputStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_create(
    self._get-native-object-no-reffing, $flags, $cancellable, $error
  )
}

sub g_file_create (
  N-GFile $file, GFlag $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:create-async:
=begin pod
=head2 create-async

Asynchronously creates a new file and returns an output stream for writing to it. The file must not already exist.

For more details, see C<create()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-create-finish()> to get the result of the operation.

  method create-async ( UInt $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item UInt $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method create-async ( UInt $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_create_async(
    self._get-native-object-no-reffing, $flags, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_create_async (
  N-GFile $file, GFlag $flags, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:create-finish:
=begin pod
=head2 create-finish

Finishes an asynchronous file create operation started with C<create-async()>.

Returns: a B<Gnome::Gio::FileOutputStream> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method create-finish ( GAsyncResult $res, N-GError $error --> GFileOutputStream )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method create-finish ( GAsyncResult $res, $error is copy --> GFileOutputStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_create_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_create_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileOutputStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:create-readwrite:
=begin pod
=head2 create-readwrite

Creates a new file and returns a stream for reading and writing to it. The file must not already exist.

By default files created are generally readable by everyone, but if you pass B<Gnome::Gio::-FILE-CREATE-PRIVATE> in I<flags> the file will be made readable only to the current user, to the level that is supported on the target filesystem.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If a file or directory with this name already exists, the C<G-IO-ERROR-EXISTS> error will be returned. Some file systems don't allow all file names, and may return an C<G-IO-ERROR-INVALID-FILENAME> error, and if the name is too long, C<G-IO-ERROR-FILENAME-TOO-LONG> will be returned. Other errors are possible too, and depend on what kind of filesystem the file is on.

Note that in many non-local file cases read and write streams are not supported, so make sure you really need to do read and write streaming, rather than just opening for reading or writing.

Returns: a B<Gnome::Gio::FileIOStream> for the newly created file, or C<undefined> on error. Free the returned object with C<clear-object()>.

  method create-readwrite ( UInt $flags, GCancellable $cancellable, N-GError $error --> GFileIOStream )

=item UInt $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; return location for a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method create-readwrite ( UInt $flags, GCancellable $cancellable, $error is copy --> GFileIOStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_create_readwrite(
    self._get-native-object-no-reffing, $flags, $cancellable, $error
  )
}

sub g_file_create_readwrite (
  N-GFile $file, GFlag $flags, GCancellable $cancellable, N-GError $error --> GFileIOStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:create-readwrite-async:
=begin pod
=head2 create-readwrite-async

Asynchronously creates a new file and returns a stream for reading and writing to it. The file must not already exist.

For more details, see C<create-readwrite()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-create-readwrite-finish()> to get the result of the operation.

  method create-readwrite-async ( UInt $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item UInt $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method create-readwrite-async ( UInt $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_create_readwrite_async(
    self._get-native-object-no-reffing, $flags, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_create_readwrite_async (
  N-GFile $file, GFlag $flags, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:create-readwrite-finish:
=begin pod
=head2 create-readwrite-finish

Finishes an asynchronous file create operation started with C<create-readwrite-async()>.

Returns: a B<Gnome::Gio::FileIOStream> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method create-readwrite-finish ( GAsyncResult $res, N-GError $error --> GFileIOStream )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method create-readwrite-finish ( GAsyncResult $res, $error is copy --> GFileIOStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_create_readwrite_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_create_readwrite_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileIOStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:delete:
=begin pod
=head2 delete

Deletes a file. If the I<file> is a directory, it will only be deleted if it is empty. This has the same semantics as C<g-unlink()>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Virtual: delete-file

Returns: C<True> if the file was deleted. C<False> otherwise.

  method delete ( GCancellable $cancellable, N-GError $error --> Bool )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method delete ( GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_delete(
    self._get-native-object-no-reffing, $cancellable, $error
  ).Bool
}

sub g_file_delete (
  N-GFile $file, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:delete-async:
=begin pod
=head2 delete-async

Asynchronously delete a file. If the I<file> is a directory, it will only be deleted if it is empty. This has the same semantics as C<g-unlink()>.

Virtual: delete-file-async

  method delete-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function
=end pod

method delete-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_delete_async(
    self._get-native-object-no-reffing, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_delete_async (
  N-GFile $file, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:delete-finish:
=begin pod
=head2 delete-finish

Finishes deleting a file started with C<delete-async()>.

Virtual: delete-file-finish

Returns: C<True> if the file was deleted. C<False> otherwise.

  method delete-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method delete-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_delete_finish(
    self._get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_file_delete_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:dup:
=begin pod
=head2 dup

Duplicates a B<Gnome::Gio::File> handle. This operation does not duplicate the actual file or directory represented by the B<Gnome::Gio::File>; see C<copy()> if attempting to copy a file.

C<g-file-dup()> is useful when a second handle is needed to the same underlying file, for use in a separate thread (B<Gnome::Gio::File> is not thread-safe). For use within the same thread, use C<g-object-ref()> to increment the existing object’s reference count.

This call does no blocking I/O.

Returns: a new B<Gnome::Gio::File> that is a duplicate of the given B<Gnome::Gio::File>.

  method dup ( --> N-GFile )

=end pod

method dup ( --> N-GFile ) {

  g_file_dup(
    self._get-native-object-no-reffing,
  )
}

sub g_file_dup (
  N-GFile $file --> N-GFile
) is native(&gio-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:eject-mountable-with-operation:
=begin pod
=head2 eject-mountable-with-operation

Starts an asynchronous eject on a mountable. When this operation has completed, I<callback> will be called with I<user-user> data, and the operation can be finalized with C<eject-mountable-with-operation-finish()>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

  method eject-mountable-with-operation ( GMountUnmountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountUnmountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; a B<Gnome::Gio::MountOperation>, or C<undefined> to avoid user interaction
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async) : a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied, or C<undefined>
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method eject-mountable-with-operation ( GMountUnmountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_eject_mountable_with_operation(
    self._get-native-object-no-reffing, $flags, $mount_operation, $cancellable, $callback, $user_data
  );
}

sub g_file_eject_mountable_with_operation (
  N-GFile $file, GFlag $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:eject-mountable-with-operation-finish:
=begin pod
=head2 eject-mountable-with-operation-finish

Finishes an asynchronous eject operation started by C<eject-mountable-with-operation()>.

Returns: C<True> if the I<file> was ejected successfully. C<False> otherwise.

  method eject-mountable-with-operation-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method eject-mountable-with-operation-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_eject_mountable_with_operation_finish(
    self._get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_file_eject_mountable_with_operation_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:enumerate-children:
=begin pod
=head2 enumerate-children

Gets the requested information about the files in a directory. The result is a B<Gnome::Gio::FileEnumerator> object that will give out B<Gnome::Gio::FileInfo> objects for all the files in the directory.

The I<attributes> value is a string that specifies the file attributes that should be gathered. It is not an error if it's not possible to read a particular requested attribute from a file - it just won't be set. I<attributes> should be a comma-separated list of attributes or attribute wildcards. The wildcard "*" means all attributes, and a wildcard like "standard::*" means all attributes in the standard namespace. An example attribute query be "standard::*,owner::user". The standard attributes are available as defines, like B<Gnome::Gio::-FILE-ATTRIBUTE-STANDARD-NAME>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If the file does not exist, the C<G-IO-ERROR-NOT-FOUND> error will be returned. If the file is not a directory, the C<G-IO-ERROR-NOT-DIRECTORY> error will be returned. Other errors are possible too.

Returns: A B<Gnome::Gio::FileEnumerator> if successful, C<undefined> on error. Free the returned object with C<clear-object()>.

  method enumerate-children ( Str $attributes, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> GFileEnumerator )

=item Str $attributes; an attribute query string
=item GFileQueryInfoFlags $flags; a set of B<Gnome::Gio::FileQueryInfoFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; B<Gnome::Gio::Error> for error reporting
=end pod

method enumerate-children ( Str $attributes, GFileQueryInfoFlags $flags, GCancellable $cancellable, $error is copy --> GFileEnumerator ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_enumerate_children(
    self._get-native-object-no-reffing, $attributes, $flags, $cancellable, $error
  )
}

sub g_file_enumerate_children (
  N-GFile $file, gchar-ptr $attributes, GFlag $flags, GCancellable $cancellable, N-GError $error --> GFileEnumerator
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:enumerate-children-async:
=begin pod
=head2 enumerate-children-async

Asynchronously gets the requested information about the files in a directory. The result is a B<Gnome::Gio::FileEnumerator> object that will give out B<Gnome::Gio::FileInfo> objects for all the files in the directory.

For more details, see C<enumerate-children()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-enumerate-children-finish()> to get the result of the operation.

  method enumerate-children-async ( Str $attributes, GFileQueryInfoFlags $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $attributes; an attribute query string
=item GFileQueryInfoFlags $flags; a set of B<Gnome::Gio::FileQueryInfoFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method enumerate-children-async ( Str $attributes, GFileQueryInfoFlags $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_enumerate_children_async(
    self._get-native-object-no-reffing, $attributes, $flags, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_enumerate_children_async (
  N-GFile $file, gchar-ptr $attributes, GFlag $flags, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:enumerate-children-finish:
=begin pod
=head2 enumerate-children-finish

Finishes an async enumerate children operation. See C<enumerate-children-async()>.

Returns: a B<Gnome::Gio::FileEnumerator> or C<undefined> if an error occurred. Free the returned object with C<clear-object()>.

  method enumerate-children-finish ( GAsyncResult $res, N-GError $error --> GFileEnumerator )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method enumerate-children-finish ( GAsyncResult $res, $error is copy --> GFileEnumerator ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_enumerate_children_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_enumerate_children_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileEnumerator
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:equal:
=begin pod
=head2 equal

Checks if the two given B<Gnome::Gio::Files> refer to the same file.

Note that two B<Gnome::Gio::Files> that differ can still refer to the same file on the filesystem due to various forms of filename aliasing.

This call does no blocking I/O.

Returns: C<True> if I<file1> and I<file2> are equal.

  method equal ( N-GFile $file2 --> Bool )

=item N-GFile $file2; the second B<Gnome::Gio::File>
=end pod

method equal ( N-GFile $file2 --> Bool ) {

  g_file_equal(
    self._get-native-object-no-reffing, $file2
  ).Bool
}

sub g_file_equal (
  N-GFile $file1, N-GFile $file2 --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:find-enclosing-mount:
=begin pod
=head2 find-enclosing-mount

Gets a B<Gnome::Gio::Mount> for the B<Gnome::Gio::File>.

If the B<Gnome::Gio::FileIface> for I<file> does not have a mount (e.g. possibly a remote share), I<error> will be set to C<G-IO-ERROR-NOT-FOUND> and C<undefined> will be returned.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: a B<Gnome::Gio::Mount> where the I<file> is located or C<undefined> on error. Free the returned object with C<clear-object()>.

  method find-enclosing-mount ( GCancellable $cancellable, N-GError $error --> GMount )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method find-enclosing-mount ( GCancellable $cancellable, $error is copy --> GMount ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_find_enclosing_mount(
    self._get-native-object-no-reffing, $cancellable, $error
  )
}

sub g_file_find_enclosing_mount (
  N-GFile $file, GCancellable $cancellable, N-GError $error --> GMount
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:find-enclosing-mount-async:
=begin pod
=head2 find-enclosing-mount-async

Asynchronously gets the mount for the file.

For more details, see C<find-enclosing-mount()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-find-enclosing-mount-finish()> to get the result of the operation.

  method find-enclosing-mount-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method find-enclosing-mount-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_find_enclosing_mount_async(
    self._get-native-object-no-reffing, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_find_enclosing_mount_async (
  N-GFile $file, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:find-enclosing-mount-finish:
=begin pod
=head2 find-enclosing-mount-finish

Finishes an asynchronous find mount request. See C<find-enclosing-mount-async()>.

Returns: B<Gnome::Gio::Mount> for given I<file> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method find-enclosing-mount-finish ( GAsyncResult $res, N-GError $error --> GMount )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method find-enclosing-mount-finish ( GAsyncResult $res, $error is copy --> GMount ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_find_enclosing_mount_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_find_enclosing_mount_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GMount
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:get-basename:
=begin pod
=head2 get-basename

Gets the base name (the last component of the path) for a given B<Gnome::Gio::File>.

If called for the top level of a system (such as the filesystem root or a uri like sftp://host/) it will return a single directory separator (and on Windows, possibly a drive letter).

The base name is a byte string (not UTF-8). It has no defined encoding or rules other than it may not contain zero bytes. If you want to use filenames in a user interface you should use the display name that you can get by requesting the C<G-FILE-ATTRIBUTE-STANDARD-DISPLAY-NAME> attribute with C<query-info()>.

This call does no blocking I/O.

Returns: (type filename) : string containing the B<Gnome::Gio::File>'s base name, or C<undefined> if given B<Gnome::Gio::File> is invalid. The returned string should be freed with C<g-free()> when no longer needed.

  method get-basename ( --> Str )

=end pod

method get-basename ( --> Str ) {

  g_file_get_basename(
    self._get-native-object-no-reffing,
  )
}

sub g_file_get_basename (
  N-GFile $file --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-child:
#TM:1:get-child-rk:
=begin pod
=head2 get-child, get-child-rk

Gets a child of this I<File> with basename equal to I<name>.

Note that the file with that specific name might not exist, but you can still have a B<Gnome::Gio::File> that points to it. You can use this for instance to create that file.

This call does no blocking I/O.

Returns: a B<Gnome::Gio::File> to a child specified by I<name>. Free the returned object with C<.clear-object()>.

  method get-child ( Str $name --> N-GFile )
  method get-child-rk ( Str $name --> Gnome::Gio::File )

=item Str $name; (type filename): string containing the child's basename
=end pod

method get-child ( Str $name --> N-GFile ) {
  g_file_get_child( self._get-native-object-no-reffing, $name)
}

method get-child-rk ( Str $name --> Gnome::Gio::File ) {
  Gnome::Gio::File.new(
    :native-object(g_file_get_child( self._get-native-object-no-reffing, $name))
  )
}

sub g_file_get_child (
  N-GFile $file, gchar-ptr $name --> N-GFile
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-child-for-display-name:
#TM:1:get-child-for-display-name-rk:
=begin pod
=head2 get-child-for-display-name, get-child-for-display-name-rk

Gets the child for a given I<display-name> (i.e. a UTF-8 version of the name). If this function fails, it returns C<undefined> and I<error> will be set. This is very useful when constructing a B<Gnome::Gio::File> for a new file and the user entered the filename in the user interface, for instance when you select a directory and type a filename in the file selector.

This call does no blocking I/O.

Returns: a native File object to the specified child, or C<undefined> if the display name couldn't be converted.

For the C<-rk()> version, when an error takes place, an error object is set and the returned object is invalid. The error is stored in the attribute C<$.last-error>. Free the returned object with C<clear-object()>.

  method get-child-for-display-name (
    Str $display_name --> N-GFile
  )

  method get-child-for-display-name-rk (
    Str $display_name --> Gnome::Gio::File
  )

=head3 Example

  my Gnome::Gio::File $f .= new(:path<t/data/g-resources>);
  my Gnome::Gio::File $f2 = $f.get-child-for-display-name-rk('rtest')
  die $f.last-error.message unless $f2.is-valid;


=item Str $display_name; string to a possible child
=end pod

method get-child-for-display-name ( Str $display_name --> N-GFile ) {
  my CArray[N-GError] $error .= new(N-GError);

  g_file_get_child_for_display_name(
    self._get-native-object-no-reffing, $display_name, $error
  );

  $!last-error.clear-object;
  $!last-error = Gnome::Glib::Error.new(:native-object($error[0]));
}

method get-child-for-display-name-rk (
  Str $display_name --> Gnome::Gio::File
) {
  my CArray[N-GError] $error .= new(N-GError);

  my N-GFile $no = g_file_get_child_for_display_name(
    self._get-native-object-no-reffing, $display_name, $error
  );

  $!last-error.clear-object;
  $!last-error = Gnome::Glib::Error.new(:native-object($error[0]));
  Gnome::Gio::File.new(:native-object($no))
}

sub g_file_get_child_for_display_name (
  N-GFile $file, gchar-ptr $display_name, CArray[N-GError] $error --> N-GFile
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-parent:
#TM:1:get-parent-rk:
=begin pod
=head2 get-parent, get-parent-rk

Gets the parent directory for the I<file>. If the I<file> represents the root directory of the file system, then C<undefined> will be returned.

This call does no blocking I/O.

Returns: a B<Gnome::Gio::File> structure to the parent of the given B<Gnome::Gio::File> or C<undefined> if there is no parent. Free the returned object with C<clear-object()>.

  method get-parent ( --> N-GFile )
  method get-parent-rk ( --> Gnome::Gio::File )

=end pod

method get-parent ( --> N-GFile ) {
  g_file_get_parent(self._get-native-object-no-reffing)
}

method get-parent-rk ( --> Gnome::Gio::File ) {
  Gnome::Gio::File.new(
    :native-object(g_file_get_parent(self._get-native-object-no-reffing))
  )
}

sub g_file_get_parent (
  N-GFile $file --> N-GFile
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-parse-name:
=begin pod
=head2 get-parse-name

Gets the parse name of the I<file>. A parse name is a UTF-8 string that describes the file such that one can get the B<Gnome::Gio::File> back using C<parse-name()>.

This is generally used to show the B<Gnome::Gio::File> as a nice full-pathname kind of string in a user interface, like in a location entry.

For local files with names that can safely be converted to UTF-8 the pathname is used, otherwise the IRI is used (a form of URI that allows UTF-8 characters unescaped).

This call does no blocking I/O.

Returns: a string containing the B<Gnome::Gio::File>'s parse name.
=comment TODO The returned string should be freed with C<g-free()> when no longer needed.

  method get-parse-name ( --> Str )

=end pod

method get-parse-name ( --> Str ) {

  g_file_get_parse_name(
    self._get-native-object-no-reffing,
  )
}

sub g_file_get_parse_name (
  N-GFile $file --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-path:
=begin pod
=head2 get-path

Gets the local pathname for B<Gnome::Gio::File>, if one exists. If non-C<undefined>, this is guaranteed to be an absolute, canonical path. It might contain symlinks.

This call does no blocking I/O.

Returns: (type filename) : string containing the B<Gnome::Gio::File>'s path, or C<undefined> if no such path exists. The returned string should be freed with C<g-free()> when no longer needed.

  method get-path ( --> Str )

=end pod

method get-path ( --> Str ) {

  g_file_get_path(
    self._get-native-object-no-reffing,
  )
}

sub g_file_get_path (
  N-GFile $file --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-relative-path:
=begin pod
=head2 get-relative-path

Gets the path for I<descendant> relative to I<parent>.

This call does no blocking I/O.

Returns: string with the relative path from I<descendant> to I<parent>, or C<undefined> if I<descendant> doesn't have I<parent> as prefix.
=comment TODO The returned string should be freed with C<g-free()> when no longer needed.

  method get-relative-path ( N-GFile $descendant --> Str )

=item N-GFile $descendant; input B<Gnome::Gio::File>
=end pod

method get-relative-path ( $descendant is copy --> Str ) {
  $descendant .= _get-native-object-no-reffing unless $descendant ~~ N-GFile;
  g_file_get_relative_path( self._get-native-object-no-reffing, $descendant)
}

sub g_file_get_relative_path (
  N-GFile $parent, N-GFile $descendant --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-uri:
=begin pod
=head2 get-uri

Gets the URI for the I<file>.

This call does no blocking I/O.

Returns: a string containing the B<Gnome::Gio::File>'s URI. The returned string should be freed with C<g-free()> when no longer needed.

  method get-uri ( --> Str )

=end pod

method get-uri ( --> Str ) {

  g_file_get_uri(
    self._get-native-object-no-reffing,
  )
}

sub g_file_get_uri (
  N-GFile $file --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-uri-scheme:
=begin pod
=head2 get-uri-scheme

Gets the URI scheme for a B<Gnome::Gio::File>. RFC 3986 decodes the scheme as:

  URI = scheme ":" hier-part [ "?" query ] [ "#" fragment ]

Common schemes include "file", "http", "ftp", etc.

This call does no blocking I/O.

Returns: a string containing the URI scheme for the given B<Gnome::Gio::File>. The returned string should be freed with C<g-free()> when no longer needed.

  method get-uri-scheme ( --> Str )

=end pod

method get-uri-scheme ( --> Str ) {
  g_file_get_uri_scheme(self._get-native-object-no-reffing)
}

sub g_file_get_uri_scheme (
  N-GFile $file --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:has-parent:
=begin pod
=head2 has-parent

Checks if I<file> has a parent, and optionally, if it is I<parent>.

If I<parent> is C<undefined> then this function returns C<True> if I<file> has any parent at all. If I<parent> is non-C<undefined> then C<True> is only returned if I<file> is an immediate child of I<parent>.

Returns: C<True> if I<file> is an immediate child of I<parent> (or any parent in the case that I<parent> is C<undefined>).

  method has-parent ( N-GFile $parent --> Bool )

=item N-GFile $parent; the parent to check for, or C<undefined>
=end pod

method has-parent ( $parent is copy --> Bool ) {
  $parent .= _get-native-object-no-reffing unless $parent ~~ N-GFile;
  g_file_has_parent( self._get-native-object-no-reffing, $parent).Bool
}

sub g_file_has_parent (
  N-GFile $file, N-GFile $parent --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:has-prefix:
=begin pod
=head2 has-prefix

Checks whether I<file> has the prefix specified by I<prefix>.

In other words, if the names of initial elements of I<file>'s pathname match I<prefix>. Only full pathname elements are matched, so a path like /foo is not considered a prefix of /foobar, only of /foo/bar.

A B<Gnome::Gio::File> is not a prefix of itself. If you want to check for equality, use C<equal()>.

This call does no I/O, as it works purely on names. As such it can sometimes return C<False> even if I<file> is inside a I<prefix> (from a filesystem point of view), because the prefix of I<file> is an alias of I<prefix>.

Virtual: prefix-matches

Returns: C<True> if the I<files>'s parent, grandparent, etc is I<prefix>, C<False> otherwise.

  method has-prefix ( N-GFile $prefix --> Bool )

=item N-GFile $prefix; input B<Gnome::Gio::File>
=end pod

method has-prefix ( $prefix is copy --> Bool ) {
  $prefix .= _get-native-object-no-reffing unless $prefix ~~ N-GFile;
  g_file_has_prefix( self._get-native-object-no-reffing, $prefix).Bool
}

sub g_file_has_prefix (
  N-GFile $file, N-GFile $prefix --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:has-uri-scheme:
=begin pod
=head2 has-uri-scheme

Checks to see if a B<Gnome::Gio::File> has a given URI scheme.

This call does no blocking I/O.

Returns: C<True> if B<Gnome::Gio::File>'s backend supports the given URI scheme, C<False> if URI scheme is C<undefined>, not supported, or B<Gnome::Gio::File> is invalid.

  method has-uri-scheme ( Str $uri_scheme --> Bool )

=item Str $uri_scheme; a string containing a URI scheme
=end pod

method has-uri-scheme ( Str $uri_scheme --> Bool ) {
  g_file_has_uri_scheme( self._get-native-object-no-reffing, $uri_scheme).Bool
}

sub g_file_has_uri_scheme (
  N-GFile $file, gchar-ptr $uri_scheme --> gboolean
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:hash:
=begin pod
=head2 hash

Creates a hash value for a B<Gnome::Gio::File>.

This call does no blocking I/O.

Virtual: hash

Returns: 0 if I<file> is not a valid B<Gnome::Gio::File>, otherwise an integer that can be used as hash value for the B<Gnome::Gio::File>. This function is intended for easily hashing a B<Gnome::Gio::File> to add to a B<Gnome::Gio::HashTable> or similar data structure.

  method hash ( Pointer $file --> UInt )

=item Pointer $file; (type N-GFile): B<gconstpointer> to a B<Gnome::Gio::File>
=end pod

method hash ( Pointer $file --> UInt ) {

  g_file_hash(
    self._get-native-object-no-reffing, $file
  )
}

sub g_file_hash (
  gpointer $file --> guint
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:is-native:
=begin pod
=head2 is-native

Checks to see if a file is native to the platform.

A native file is one expressed in the platform-native filename format, e.g. "C:\Windows" or "/usr/bin/". This does not mean the file is local, as it might be on a locally mounted remote filesystem.

On some systems non-native files may be available using the native filesystem via a userspace filesystem (FUSE), in these cases this call will return C<False>, but C<get-path()> will still return a native path.

This call does no blocking I/O.

Returns: C<True> if I<file> is native

  method is-native ( --> Bool )

=end pod

method is-native ( --> Bool ) {
  g_file_is_native(self._get-native-object-no-reffing).Bool
}

sub g_file_is_native (
  N-GFile $file --> gboolean
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:load-bytes:
=begin pod
=head2 load-bytes

Loads the contents of I<file> and returns it as B<Gnome::Gio::Bytes>.

If I<file> is a resource:// based URI, the resulting bytes will reference the embedded resource instead of a copy. Otherwise, this is equivalent to calling C<load-contents()> and C<g-bytes-new-take()>.

For resources, I<etag-out> will be set to C<undefined>.

The data contained in the resulting B<Gnome::Gio::Bytes> is always zero-terminated, but this is not included in the B<Gnome::Gio::Bytes> length. The resulting B<Gnome::Gio::Bytes> should be freed with C<g-bytes-unref()> when no longer in use.

Returns: a B<Gnome::Gio::Bytes> or C<undefined> and I<error> is set

  method load-bytes ( GCancellable $cancellable, CArray[Str] $etag_out, N-GError $error --> N-GObject )

=item GCancellable $cancellable; a B<Gnome::Gio::Cancellable> or C<undefined>
=item CArray[Str] $etag_out; a location to place the current entity tag for the file, or C<undefined> if the entity tag is not needed
=item N-GError $error; a location for a B<Gnome::Gio::Error> or C<undefined>
=end pod

method load-bytes ( GCancellable $cancellable, CArray[Str] $etag_out, $error is copy --> N-GObject ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_load_bytes(
    self._get-native-object-no-reffing, $cancellable, $etag_out, $error
  )
}

sub g_file_load_bytes (
  N-GFile $file, GCancellable $cancellable, gchar-pptr $etag_out, N-GError $error --> N-GObject
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:load-bytes-async:
=begin pod
=head2 load-bytes-async

Asynchronously loads the contents of I<file> as B<Gnome::Gio::Bytes>.

If I<file> is a resource:// based URI, the resulting bytes will reference the embedded resource instead of a copy. Otherwise, this is equivalent to calling C<load-contents-async()> and C<g-bytes-new-take()>.

I<callback> should call C<g-file-load-bytes-finish()> to get the result of this asynchronous operation.

See C<g-file-load-bytes()> for more information.

  method load-bytes-async ( GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GCancellable $cancellable; a B<Gnome::Gio::Cancellable> or C<undefined>
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method load-bytes-async ( GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_load_bytes_async(
    self._get-native-object-no-reffing, $cancellable, $callback, $user_data
  );
}

sub g_file_load_bytes_async (
  N-GFile $file, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:load-bytes-finish:
=begin pod
=head2 load-bytes-finish

Completes an asynchronous request to C<load-bytes-async()>.

For resources, I<etag-out> will be set to C<undefined>.

The data contained in the resulting B<Gnome::Gio::Bytes> is always zero-terminated, but this is not included in the B<Gnome::Gio::Bytes> length. The resulting B<Gnome::Gio::Bytes> should be freed with C<g-bytes-unref()> when no longer in use.

See C<g-file-load-bytes()> for more information.

Returns: a B<Gnome::Gio::Bytes> or C<undefined> and I<error> is set

  method load-bytes-finish ( GAsyncResult $result, CArray[Str] $etag_out, N-GError $error --> N-GObject )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult> provided to the callback
=item CArray[Str] $etag_out; a location to place the current entity tag for the file, or C<undefined> if the entity tag is not needed
=item N-GError $error; a location for a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method load-bytes-finish ( GAsyncResult $result, CArray[Str] $etag_out, $error is copy --> N-GObject ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_load_bytes_finish(
    self._get-native-object-no-reffing, $result, $etag_out, $error
  )
}

sub g_file_load_bytes_finish (
  N-GFile $file, GAsyncResult $result, gchar-pptr $etag_out, N-GError $error --> N-GObject
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:load-contents:
=begin pod
=head2 load-contents

Loads the content of the file into memory. The data is always zero-terminated, but this is not included in the resultant I<length>. The returned I<content> should be freed with C<g-free()> when no longer needed.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> if the I<file>'s contents were successfully loaded. C<False> if there were errors.

  method load-contents ( GCancellable $cancellable, CArray[Str] $contents, UInt $length, CArray[Str] $etag_out, N-GError $error --> Bool )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item CArray[Str] $contents;   (element-type guint8) (array length=length): a location to place the contents of the file
=item UInt $length; a location to place the length of the contents of the file, or C<undefined> if the length is not needed
=item CArray[Str] $etag_out; a location to place the current entity tag for the file, or C<undefined> if the entity tag is not needed
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method load-contents ( GCancellable $cancellable, CArray[Str] $contents, UInt $length, CArray[Str] $etag_out, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_load_contents(
    self._get-native-object-no-reffing, $cancellable, $contents, $length, $etag_out, $error
  ).Bool
}

sub g_file_load_contents (
  N-GFile $file, GCancellable $cancellable, gchar-pptr $contents, gsize $length, gchar-pptr $etag_out, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:load-contents-async:
=begin pod
=head2 load-contents-async

Starts an asynchronous load of the I<file>'s contents.

For more details, see C<load-contents()> which is the synchronous version of this call.

When the load operation has completed, I<callback> will be called with I<user> data. To finish the operation, call C<g-file-load-contents-finish()> with the B<Gnome::Gio::AsyncResult> returned by the I<callback>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

  method load-contents-async ( GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function
=end pod

method load-contents-async ( GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_load_contents_async(
    self._get-native-object-no-reffing, $cancellable, $callback, $user_data
  );
}

sub g_file_load_contents_async (
  N-GFile $file, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:load-contents-finish:
=begin pod
=head2 load-contents-finish

Finishes an asynchronous load of the I<file>'s contents. The contents are placed in I<contents>, and I<length> is set to the size of the I<contents> string. The I<content> should be freed with C<g-free()> when no longer needed. If I<etag-out> is present, it will be set to the new entity tag for the I<file>.

Returns: C<True> if the load was successful. If C<False> and I<error> is present, it will be set appropriately.

  method load-contents-finish ( GAsyncResult $res, CArray[Str] $contents, UInt $length, CArray[Str] $etag_out, N-GError $error --> Bool )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item CArray[Str] $contents;   (element-type guint8) (array length=length): a location to place the contents of the file
=item UInt $length; a location to place the length of the contents of the file, or C<undefined> if the length is not needed
=item CArray[Str] $etag_out; a location to place the current entity tag for the file, or C<undefined> if the entity tag is not needed
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method load-contents-finish ( GAsyncResult $res, CArray[Str] $contents, UInt $length, CArray[Str] $etag_out, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_load_contents_finish(
    self._get-native-object-no-reffing, $res, $contents, $length, $etag_out, $error
  ).Bool
}

sub g_file_load_contents_finish (
  N-GFile $file, GAsyncResult $res, gchar-pptr $contents, gsize $length, gchar-pptr $etag_out, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:load-partial-contents-async:
=begin pod
=head2 load-partial-contents-async

Reads the partial contents of a file. A B<Gnome::Gio::FileReadMoreCallback> should be used to stop reading from the file when appropriate, else this function will behave exactly as C<load-contents-async()>. This operation can be finished by C<g-file-load-partial-contents-finish()>.

Users of this function should be aware that I<user-data> is passed to both the I<read-more-callback> and the I<callback>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

  method load-partial-contents-async ( GCancellable $cancellable, GFileReadMoreCallback $read_more_callback, GAsyncReadyCallback $callback, Pointer $user_data )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GFileReadMoreCallback $read_more_callback; (scope call) (closure user-data): a B<Gnome::Gio::FileReadMoreCallback> to receive partial data and to specify whether further data should be read
=item GAsyncReadyCallback $callback; (scope async) (closure user-data): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to the callback functions
=end pod

method load-partial-contents-async ( GCancellable $cancellable, GFileReadMoreCallback $read_more_callback, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_load_partial_contents_async(
    self._get-native-object-no-reffing, $cancellable, $read_more_callback, $callback, $user_data
  );
}

sub g_file_load_partial_contents_async (
  N-GFile $file, GCancellable $cancellable, GFileReadMoreCallback $read_more_callback, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:load-partial-contents-finish:
=begin pod
=head2 load-partial-contents-finish

Finishes an asynchronous partial load operation that was started with C<load-partial-contents-async()>. The data is always zero-terminated, but this is not included in the resultant I<length>. The returned I<content> should be freed with C<g-free()> when no longer needed.

Returns: C<True> if the load was successful. If C<False> and I<error> is present, it will be set appropriately.

  method load-partial-contents-finish ( GAsyncResult $res, CArray[Str] $contents, UInt $length, CArray[Str] $etag_out, N-GError $error --> Bool )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item CArray[Str] $contents;   (element-type guint8) (array length=length): a location to place the contents of the file
=item UInt $length; a location to place the length of the contents of the file, or C<undefined> if the length is not needed
=item CArray[Str] $etag_out; a location to place the current entity tag for the file, or C<undefined> if the entity tag is not needed
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method load-partial-contents-finish ( GAsyncResult $res, CArray[Str] $contents, UInt $length, CArray[Str] $etag_out, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_load_partial_contents_finish(
    self._get-native-object-no-reffing, $res, $contents, $length, $etag_out, $error
  ).Bool
}

sub g_file_load_partial_contents_finish (
  N-GFile $file, GAsyncResult $res, gchar-pptr $contents, gsize $length, gchar-pptr $etag_out, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:make-directory:
=begin pod
=head2 make-directory

Creates a directory. Note that this will only create a child directory of the immediate parent directory of the path or URI given by the B<Gnome::Gio::File>. To recursively create directories, see C<make-directory-with-parents()>. This function will fail if the parent directory does not exist, setting I<error> to C<G-IO-ERROR-NOT-FOUND>. If the file system doesn't support creating directories, this function will fail, setting I<error> to C<G-IO-ERROR-NOT-SUPPORTED>.

For a local B<Gnome::Gio::File> the newly created directory will have the default (current) ownership and permissions of the current process.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> on successful creation, C<False> otherwise.

  method make-directory ( GCancellable $cancellable, N-GError $error --> Bool )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method make-directory ( GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_make_directory(
    self._get-native-object-no-reffing, $cancellable, $error
  ).Bool
}

sub g_file_make_directory (
  N-GFile $file, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:make-directory-async:
=begin pod
=head2 make-directory-async

Asynchronously creates a directory.

Virtual: make-directory-async

  method make-directory-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function
=end pod

method make-directory-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_make_directory_async(
    self._get-native-object-no-reffing, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_make_directory_async (
  N-GFile $file, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:make-directory-finish:
=begin pod
=head2 make-directory-finish

Finishes an asynchronous directory creation, started with C<make-directory-async()>.

Virtual: make-directory-finish

Returns: C<True> on successful directory creation, C<False> otherwise.

  method make-directory-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method make-directory-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_make_directory_finish(
    self._get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_file_make_directory_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:make-directory-with-parents:
=begin pod
=head2 make-directory-with-parents

Creates a directory and any parent directories that may not exist similar to 'mkdir -p'. If the file system does not support creating directories, this function will fail, setting I<error> to C<G-IO-ERROR-NOT-SUPPORTED>. If the directory itself already exists, this function will fail setting I<error> to C<G-IO-ERROR-EXISTS>, unlike the similar C<g-mkdir-with-parents()>.

For a local B<Gnome::Gio::File> the newly created directories will have the default (current) ownership and permissions of the current process.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> if all directories have been successfully created, C<False> otherwise.

  method make-directory-with-parents ( GCancellable $cancellable, N-GError $error --> Bool )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method make-directory-with-parents ( GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_make_directory_with_parents(
    self._get-native-object-no-reffing, $cancellable, $error
  ).Bool
}

sub g_file_make_directory_with_parents (
  N-GFile $file, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:make-symbolic-link:
=begin pod
=head2 make-symbolic-link

Creates a symbolic link named I<file> which contains the string I<symlink-value>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> on the creation of a new symlink, C<False> otherwise.

  method make-symbolic-link ( Str $symlink_value, GCancellable $cancellable, N-GError $error --> Bool )

=item Str $symlink_value; (type filename): a string with the path for the target of the new symlink
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method make-symbolic-link ( Str $symlink_value, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_make_symbolic_link(
    self._get-native-object-no-reffing, $symlink_value, $cancellable, $error
  ).Bool
}

sub g_file_make_symbolic_link (
  N-GFile $file, gchar-ptr $symlink_value, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:measure-disk-usage:
=begin pod
=head2 measure-disk-usage

Recursively measures the disk usage of I<file>.

This is essentially an analog of the 'du' command, but it also reports the number of directories and non-directory files encountered (including things like symbolic links).

By default, errors are only reported against the toplevel file itself. Errors found while recursing are silently ignored, unless C<G-FILE-DISK-USAGE-REPORT-ALL-ERRORS> is given in I<flags>.

The returned size, I<disk-usage>, is in bytes and should be formatted with C<g-format-size()> in order to get something reasonable for showing in a user interface.

I<progress-callback> and I<progress-data> can be given to request periodic progress updates while scanning. See the documentation for B<Gnome::Gio::FileMeasureProgressCallback> for information about when and how the callback will be invoked.

Returns: C<True> if successful, with the out parameters set. C<False> otherwise, with I<error> set.

  method measure-disk-usage ( UInt $flags, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, Pointer $progress_data, UInt $disk_usage, UInt $num_dirs, UInt $num_files, N-GError $error --> Bool )

=item UInt $flags; B<Gnome::Gio::FileMeasureFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable>
=item GFileMeasureProgressCallback $progress_callback; a B<Gnome::Gio::FileMeasureProgressCallback>
=item Pointer $progress_data; user-data for I<progress-callback>
=item UInt $disk_usage; the number of bytes of disk space used
=item UInt $num_dirs; the number of directories encountered
=item UInt $num_files; the number of non-directories encountered
=item N-GError $error; C<undefined>, or a pointer to a C<undefined> B<Gnome::Gio::Error> pointer
=end pod

method measure-disk-usage ( UInt $flags, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, Pointer $progress_data, UInt $disk_usage, UInt $num_dirs, UInt $num_files, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_measure_disk_usage(
    self._get-native-object-no-reffing, $flags, $cancellable, $progress_callback, $progress_data, $disk_usage, $num_dirs, $num_files, $error
  ).Bool
}

sub g_file_measure_disk_usage (
  N-GFile $file, GFlag $flags, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, gpointer $progress_data, guint64 $disk_usage, guint64 $num_dirs, guint64 $num_files, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:measure-disk-usage-async:
=begin pod
=head2 measure-disk-usage-async

Recursively measures the disk usage of I<file>.

This is the asynchronous version of C<measure-disk-usage()>. See there for more information.

  method measure-disk-usage-async ( UInt $flags, Int() $io_priority, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, Pointer $progress_data, GAsyncReadyCallback $callback, Pointer $user_data )

=item UInt $flags; B<Gnome::Gio::FileMeasureFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable>
=item GFileMeasureProgressCallback $progress_callback; a B<Gnome::Gio::FileMeasureProgressCallback>
=item Pointer $progress_data; user-data for I<progress-callback>
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when complete
=item Pointer $user_data; the data to pass to callback function
=end pod

method measure-disk-usage-async ( UInt $flags, Int() $io_priority, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, Pointer $progress_data, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_measure_disk_usage_async(
    self._get-native-object-no-reffing, $flags, $io_priority, $cancellable, $progress_callback, $progress_data, $callback, $user_data
  );
}

sub g_file_measure_disk_usage_async (
  N-GFile $file, GFlag $flags, gint $io_priority, GCancellable $cancellable, GFileMeasureProgressCallback $progress_callback, gpointer $progress_data, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:measure-disk-usage-finish:
=begin pod
=head2 measure-disk-usage-finish

Collects the results from an earlier call to C<measure-disk-usage-async()>. See C<g-file-measure-disk-usage()> for more information.

Returns: C<True> if successful, with the out parameters set. C<False> otherwise, with I<error> set.

  method measure-disk-usage-finish ( GAsyncResult $result, UInt $disk_usage, UInt $num_dirs, UInt $num_files, N-GError $error --> Bool )

=item GAsyncResult $result; the B<Gnome::Gio::AsyncResult> passed to your B<Gnome::Gio::AsyncReadyCallback>
=item UInt $disk_usage; the number of bytes of disk space used
=item UInt $num_dirs; the number of directories encountered
=item UInt $num_files; the number of non-directories encountered
=item N-GError $error; C<undefined>, or a pointer to a C<undefined> B<Gnome::Gio::Error> pointer
=end pod

method measure-disk-usage-finish ( GAsyncResult $result, UInt $disk_usage, UInt $num_dirs, UInt $num_files, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_measure_disk_usage_finish(
    self._get-native-object-no-reffing, $result, $disk_usage, $num_dirs, $num_files, $error
  ).Bool
}

sub g_file_measure_disk_usage_finish (
  N-GFile $file, GAsyncResult $result, guint64 $disk_usage, guint64 $num_dirs, guint64 $num_files, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:monitor:
=begin pod
=head2 monitor

Obtains a file or directory monitor for the given file, depending on the type of the file.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: a B<Gnome::Gio::FileMonitor> for the given I<file>, or C<undefined> on error. Free the returned object with C<clear-object()>.

  method monitor ( GFileMonitorFlags $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor )

=item GFileMonitorFlags $flags; a set of B<Gnome::Gio::FileMonitorFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method monitor ( GFileMonitorFlags $flags, GCancellable $cancellable, $error is copy --> GFileMonitor ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_monitor(
    self._get-native-object-no-reffing, $flags, $cancellable, $error
  )
}

sub g_file_monitor (
  N-GFile $file, GFlag $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:monitor-directory:
=begin pod
=head2 monitor-directory

Obtains a directory monitor for the given file. This may fail if directory monitoring is not supported.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

It does not make sense for I<flags> to contain C<G-FILE-MONITOR-WATCH-HARD-LINKS>, since hard links can not be made to directories. It is not possible to monitor all the files in a directory for changes made via hard links; if you want to do this then you must register individual watches with C<monitor()>.

Virtual: monitor-dir

Returns: a B<Gnome::Gio::FileMonitor> for the given I<file>, or C<undefined> on error. Free the returned object with C<clear-object()>.

  method monitor-directory ( GFileMonitorFlags $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor )

=item GFileMonitorFlags $flags; a set of B<Gnome::Gio::FileMonitorFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method monitor-directory ( GFileMonitorFlags $flags, GCancellable $cancellable, $error is copy --> GFileMonitor ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_monitor_directory(
    self._get-native-object-no-reffing, $flags, $cancellable, $error
  )
}

sub g_file_monitor_directory (
  N-GFile $file, GFlag $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:monitor-file:
=begin pod
=head2 monitor-file

Obtains a file monitor for the given file. If no file notification mechanism exists, then regular polling of the file is used.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If I<flags> contains C<G-FILE-MONITOR-WATCH-HARD-LINKS> then the monitor will also attempt to report changes made to the file via another filename (ie, a hard link). Without this flag, you can only rely on changes made through the filename contained in I<file> to be reported. Using this flag may result in an increase in resource usage, and may not have any effect depending on the B<Gnome::Gio::FileMonitor> backend and/or filesystem type.

Returns: a B<Gnome::Gio::FileMonitor> for the given I<file>, or C<undefined> on error. Free the returned object with C<clear-object()>.

  method monitor-file ( GFileMonitorFlags $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor )

=item GFileMonitorFlags $flags; a set of B<Gnome::Gio::FileMonitorFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method monitor-file ( GFileMonitorFlags $flags, GCancellable $cancellable, $error is copy --> GFileMonitor ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_monitor_file(
    self._get-native-object-no-reffing, $flags, $cancellable, $error
  )
}

sub g_file_monitor_file (
  N-GFile $file, GFlag $flags, GCancellable $cancellable, N-GError $error --> GFileMonitor
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:mount-enclosing-volume:
=begin pod
=head2 mount-enclosing-volume

Starts a I<mount-operation>, mounting the volume that contains the file I<location>.

When this operation has completed, I<callback> will be called with I<user-user> data, and the operation can be finalized with C<mount-enclosing-volume-finish()>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

  method mount-enclosing-volume ( GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountMountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; a B<Gnome::Gio::MountOperation> or C<undefined> to avoid user interaction
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied, or C<undefined>
=item Pointer $user_data; the data to pass to callback function
=end pod

method mount-enclosing-volume ( GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_mount_enclosing_volume(
    self._get-native-object-no-reffing, $flags, $mount_operation, $cancellable, $callback, $user_data
  );
}

sub g_file_mount_enclosing_volume (
  N-GFile $location, GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:mount-enclosing-volume-finish:
=begin pod
=head2 mount-enclosing-volume-finish

Finishes a mount operation started by C<mount-enclosing-volume()>.

Returns: C<True> if successful. If an error has occurred, this function will return C<False> and set I<error> appropriately if present.

  method mount-enclosing-volume-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method mount-enclosing-volume-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_mount_enclosing_volume_finish(
    self._get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_file_mount_enclosing_volume_finish (
  N-GFile $location, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:mount-mountable:
=begin pod
=head2 mount-mountable

Mounts a file of type G-FILE-TYPE-MOUNTABLE. Using I<mount-operation>, you can request callbacks when, for instance, passwords are needed during authentication.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

When the operation is finished, I<callback> will be called. You can then call C<mount-mountable-finish()> to get the result of the operation.

  method mount-mountable ( GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountMountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; a B<Gnome::Gio::MountOperation>, or C<undefined> to avoid user interaction
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async) : a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied, or C<undefined>
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method mount-mountable ( GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_mount_mountable(
    self._get-native-object-no-reffing, $flags, $mount_operation, $cancellable, $callback, $user_data
  );
}

sub g_file_mount_mountable (
  N-GFile $file, GMountMountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:mount-mountable-finish:
=begin pod
=head2 mount-mountable-finish

Finishes a mount operation. See C<mount-mountable()> for details.

Finish an asynchronous mount operation that was started with C<g-file-mount-mountable()>.

Returns: a B<Gnome::Gio::File> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method mount-mountable-finish ( GAsyncResult $result, N-GError $error --> N-GFile )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method mount-mountable-finish ( GAsyncResult $result, $error is copy --> N-GFile ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_mount_mountable_finish(
    self._get-native-object-no-reffing, $result, $error
  )
}

sub g_file_mount_mountable_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> N-GFile
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:move:
=begin pod
=head2 move

Tries to move the file or directory I<source> to the location specified by I<destination>. If native move operations are supported then this is used, otherwise a copy + delete fallback is used. The native implementation may support moving directories (for instance on moves inside the same filesystem), but the fallback code does not.

If the flag B<Gnome::Gio::-FILE-COPY-OVERWRITE> is specified an already existing I<destination> file is overwritten.

If the flag B<Gnome::Gio::-FILE-COPY-NOFOLLOW-SYMLINKS> is specified then symlinks will be copied as symlinks, otherwise the target of the I<source> symlink will be copied.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If I<progress-callback> is not C<undefined>, then the operation can be monitored by setting this to a B<Gnome::Gio::FileProgressCallback> function. I<progress-callback-data> will be passed to this function. It is guaranteed that this callback will be called after all data has been transferred with the total number of bytes copied during the operation.

If the I<source> file does not exist, then the C<G-IO-ERROR-NOT-FOUND> error is returned, independent on the status of the I<destination>.

If B<Gnome::Gio::-FILE-COPY-OVERWRITE> is not specified and the target exists, then the error C<G-IO-ERROR-EXISTS> is returned.

If trying to overwrite a file over a directory, the C<G-IO-ERROR-IS-DIRECTORY> error is returned. If trying to overwrite a directory with a directory the C<G-IO-ERROR-WOULD-MERGE> error is returned.

If the source is a directory and the target does not exist, or B<Gnome::Gio::-FILE-COPY-OVERWRITE> is specified and the target is a file, then the C<G-IO-ERROR-WOULD-RECURSE> error may be returned (if the native move operation isn't available).

Returns: C<True> on successful move, C<False> otherwise.

  method move ( N-GFile $destination, UInt $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, N-GError $error --> Bool )

=item N-GFile $destination; B<Gnome::Gio::File> pointing to the destination location
=item UInt $flags; set of B<Gnome::Gio::FileCopyFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GFileProgressCallback $progress_callback;  (scope call): B<Gnome::Gio::FileProgressCallback> function for updates
=item Pointer $progress_callback_data; (closure): gpointer to user data for the callback function
=item N-GError $error; B<Gnome::Gio::Error> for returning error conditions, or C<undefined>
=end pod

method move ( N-GFile $destination, UInt $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, Pointer $progress_callback_data, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_move(
    self._get-native-object-no-reffing, $destination, $flags, $cancellable, $progress_callback, $progress_callback_data, $error
  ).Bool
}

sub g_file_move (
  N-GFile $source, N-GFile $destination, GFlag $flags, GCancellable $cancellable, GFileProgressCallback $progress_callback, gpointer $progress_callback_data, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:open-readwrite:
=begin pod
=head2 open-readwrite

Opens an existing file for reading and writing. The result is a B<Gnome::Gio::FileIOStream> that can be used to read and write the contents of the file.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If the file does not exist, the C<G-IO-ERROR-NOT-FOUND> error will be returned. If the file is a directory, the C<G-IO-ERROR-IS-DIRECTORY> error will be returned. Other errors are possible too, and depend on what kind of filesystem the file is on. Note that in many non-local file cases read and write streams are not supported, so make sure you really need to do read and write streaming, rather than just opening for reading or writing.

Returns: B<Gnome::Gio::FileIOStream> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method open-readwrite ( GCancellable $cancellable, N-GError $error --> GFileIOStream )

=item GCancellable $cancellable; a B<Gnome::Gio::Cancellable>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method open-readwrite ( GCancellable $cancellable, $error is copy --> GFileIOStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_open_readwrite(
    self._get-native-object-no-reffing, $cancellable, $error
  )
}

sub g_file_open_readwrite (
  N-GFile $file, GCancellable $cancellable, N-GError $error --> GFileIOStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:open-readwrite-async:
=begin pod
=head2 open-readwrite-async



  method open-readwrite-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int() $io_priority;
=item GCancellable $cancellable;
=item GAsyncReadyCallback $callback;
=item Pointer $user_data;
=end pod

method open-readwrite-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_open_readwrite_async(
    self._get-native-object-no-reffing, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_open_readwrite_async (
  N-GFile $file, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:open-readwrite-finish:
=begin pod
=head2 open-readwrite-finish

Finishes an asynchronous file read operation started with C<open-readwrite-async()>.

Returns: a B<Gnome::Gio::FileIOStream> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method open-readwrite-finish ( GAsyncResult $res, N-GError $error --> GFileIOStream )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method open-readwrite-finish ( GAsyncResult $res, $error is copy --> GFileIOStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_open_readwrite_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_open_readwrite_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileIOStream
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:parse-name:
=begin pod
=head2 parse-name

Constructs a B<Gnome::Gio::File> with the given I<parse-name> (i.e. something given by C<get-parse-name()>). This operation never fails, but the returned object might not support any I/O operation if the I<parse-name> cannot be parsed.

Returns: a new B<Gnome::Gio::File>.

  method parse-name ( Str $parse_name --> N-GFile )

=item Str $parse_name; a file name or path to be parsed
=end pod

method parse-name ( Str $parse_name --> N-GFile ) {

  g_file_parse_name(
    self._get-native-object-no-reffing, $parse_name
  )
}

sub g_file_parse_name (
  gchar-ptr $parse_name --> N-GFile
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:peek-path:
=begin pod
=head2 peek-path

Exactly like C<get-path()>, but caches the result via C<g-object-set-qdata-full()>. This is useful for example in C applications which mix `g-file-*` APIs with native ones. It also avoids an extra duplicated string when possible, so will be generally more efficient.

This call does no blocking I/O.

Returns: (type filename) : string containing the B<Gnome::Gio::File>'s path, or C<undefined> if no such path exists. The returned string is owned by I<file>.

  method peek-path ( --> Str )

=end pod

method peek-path ( --> Str ) {

  g_file_peek_path(
    self._get-native-object-no-reffing,
  )
}

sub g_file_peek_path (
  N-GFile $file --> gchar-ptr
) is native(&gio-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:poll-mountable:
=begin pod
=head2 poll-mountable

Polls a file of type B<Gnome::Gio::-FILE-TYPE-MOUNTABLE>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

When the operation is finished, I<callback> will be called. You can then call C<mount-mountable-finish()> to get the result of the operation.

  method poll-mountable ( GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied, or C<undefined>
=item Pointer $user_data; the data to pass to callback function
=end pod

method poll-mountable ( GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_poll_mountable(
    self._get-native-object-no-reffing, $cancellable, $callback, $user_data
  );
}

sub g_file_poll_mountable (
  N-GFile $file, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:poll-mountable-finish:
=begin pod
=head2 poll-mountable-finish

Finishes a poll operation. See C<poll-mountable()> for details.

Finish an asynchronous poll operation that was polled with C<g-file-poll-mountable()>.

Returns: C<True> if the operation finished successfully. C<False> otherwise.

  method poll-mountable-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method poll-mountable-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_poll_mountable_finish(
    self._get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_file_poll_mountable_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:query-default-handler:
=begin pod
=head2 query-default-handler

Returns the B<Gnome::Gio::AppInfo> that is registered as the default application to handle the file specified by I<file>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: a B<Gnome::Gio::AppInfo> if the handle was found, C<undefined> if there were errors and C<$.last-error> becomes valid. When you are done with it, release it with C<clear-object()>

  method query-default-handler (
    N-GObject $cancellable --> Gnome::Gio::AppInfo
  )

=item N-GObject $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore. (TODO: Cancellable not defined yet)
=end pod

method query-default-handler (
  $cancellable is copy --> Gnome::GObject::Object
) {
  $cancellable .= _get-native-object-no-reffing unless $cancellable ~~ N-GObject;
  my CArray[N-GError] $error .= new(N-GError);

  my N-GObject $no = g_file_query_default_handler(
    self._get-native-object-no-reffing, $cancellable, $error
  );

  $!last-error.clear-object;
  $!last-error .= new(:native-object(?$no ?? N-GError !! $error[0]));
  self._wrap-native-type-from-no( $no, :child-type<Gnome::Gio::AppInfo>)
}

sub g_file_query_default_handler (
  N-GFile $file, N-GObject $cancellable, CArray[N-GError] $error --> N-GObject
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:query-default-handler-async:
=begin pod
=head2 query-default-handler-async

Async version of C<query-default-handler()>.

  method query-default-handler-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int() $io_priority; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GCancellable $cancellable; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is done
=item GAsyncReadyCallback $callback; data to pass to I<callback>
=item Pointer $user_data;
=end pod

method query-default-handler-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_query_default_handler_async(
    self._get-native-object-no-reffing, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_query_default_handler_async (
  N-GFile $file, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:query-default-handler-finish:
=begin pod
=head2 query-default-handler-finish

Finishes a C<query-default-handler-async()> operation.

Returns: a B<Gnome::Gio::AppInfo> if the handle was found, C<undefined> if there were errors. When you are done with it, release it with C<clear-object()>

  method query-default-handler-finish ( GAsyncResult $result, N-GError $error --> GAppInfo )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method query-default-handler-finish ( GAsyncResult $result, $error is copy --> GAppInfo ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_query_default_handler_finish(
    self._get-native-object-no-reffing, $result, $error
  )
}

sub g_file_query_default_handler_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> GAppInfo
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:query-exists:
=begin pod
=head2 query-exists

Utility function to check if a particular file exists. This is implemented using C<query-info()> and as such does blocking I/O.

Note that in many cases it is [racy to first check for file existence](https://en.wikipedia.org/wiki/Time-of-check-to-time-of-use) and then execute something based on the outcome of that, because the file might have been created or removed in between the operations. The general approach to handling that is to not check, but just do the operation and handle the errors as they come.

As an example of race-free checking, take the case of reading a file, and if it doesn't exist, creating it. There are two racy versions: read it, and on error create it; and: check if it exists, if not create it. These can both result in two processes creating the file (with perhaps a partially written file as the result). The correct approach is to always try to create the file with C<g-file-create()> which will either atomically create the file or fail with a C<G-IO-ERROR-EXISTS> error.

However, in many cases an existence check is useful in a user interface, for instance to make a menu item sensitive/insensitive, so that you don't have to fool users that something is possible and then just show an error dialog. If you do this, you should make sure to also handle the errors that can happen due to races when you execute the operation.

Returns: C<True> if the file exists (and can be detected without error), C<False> otherwise (or if cancelled).

  method query-exists ( GCancellable $cancellable --> Bool )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=end pod

method query-exists ( GCancellable $cancellable --> Bool ) {

  g_file_query_exists(
    self._get-native-object-no-reffing, $cancellable
  ).Bool
}

sub g_file_query_exists (
  N-GFile $file, GCancellable $cancellable --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:query-file-type:
=begin pod
=head2 query-file-type

Utility function to inspect the B<Gnome::Gio::FileType> of a file. This is implemented using C<query-info()> and as such does blocking I/O.

The primary use case of this method is to check if a file is a regular file, directory, or symlink.

Returns: The B<Gnome::Gio::FileType> of the file and B<Gnome::Gio::-FILE-TYPE-UNKNOWN> if the file does not exist

  method query-file-type ( GFileQueryInfoFlags $flags, GCancellable $cancellable --> GFileType )

=item GFileQueryInfoFlags $flags; a set of B<Gnome::Gio::FileQueryInfoFlags> passed to C<query-info()>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=end pod

method query-file-type ( GFileQueryInfoFlags $flags, GCancellable $cancellable --> GFileType ) {

  g_file_query_file_type(
    self._get-native-object-no-reffing, $flags, $cancellable
  )
}

sub g_file_query_file_type (
  N-GFile $file, GFlag $flags, GCancellable $cancellable --> GEnum
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:query-filesystem-info:
=begin pod
=head2 query-filesystem-info

Similar to C<query-info()>, but obtains information about the filesystem the I<file> is on, rather than the file itself. For instance the amount of space available and the type of the filesystem.

The I<attributes> value is a string that specifies the attributes that should be gathered. It is not an error if it's not possible to read a particular requested attribute from a file - it just won't be set. I<attributes> should be a comma-separated list of attributes or attribute wildcards. The wildcard "*" means all attributes, and a wildcard like "filesystem::*" means all attributes in the filesystem namespace. The standard namespace for filesystem attributes is "filesystem". Common attributes of interest are B<Gnome::Gio::-FILE-ATTRIBUTE-FILESYSTEM-SIZE> (the total size of the filesystem in bytes), B<Gnome::Gio::-FILE-ATTRIBUTE-FILESYSTEM-FREE> (number of bytes available), and B<Gnome::Gio::-FILE-ATTRIBUTE-FILESYSTEM-TYPE> (type of the filesystem).

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If the file does not exist, the C<G-IO-ERROR-NOT-FOUND> error will be returned. Other errors are possible too, and depend on what kind of filesystem the file is on.

Returns: a B<Gnome::Gio::FileInfo> or C<undefined> if there was an error. Free the returned object with C<clear-object()>.

  method query-filesystem-info ( Str $attributes, GCancellable $cancellable, N-GError $error --> GFileInfo )

=item Str $attributes; an attribute query string
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method query-filesystem-info ( Str $attributes, GCancellable $cancellable, $error is copy --> GFileInfo ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_query_filesystem_info(
    self._get-native-object-no-reffing, $attributes, $cancellable, $error
  )
}

sub g_file_query_filesystem_info (
  N-GFile $file, gchar-ptr $attributes, GCancellable $cancellable, N-GError $error --> GFileInfo
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:query-filesystem-info-async:
=begin pod
=head2 query-filesystem-info-async

Asynchronously gets the requested information about the filesystem that the specified I<file> is on. The result is a B<Gnome::Gio::FileInfo> object that contains key-value attributes (such as type or size for the file).

For more details, see C<query-filesystem-info()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-query-info-finish()> to get the result of the operation.

  method query-filesystem-info-async ( Str $attributes, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $attributes; an attribute query string
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method query-filesystem-info-async ( Str $attributes, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_query_filesystem_info_async(
    self._get-native-object-no-reffing, $attributes, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_query_filesystem_info_async (
  N-GFile $file, gchar-ptr $attributes, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:query-filesystem-info-finish:
=begin pod
=head2 query-filesystem-info-finish

Finishes an asynchronous filesystem info query. See C<query-filesystem-info-async()>.

Returns: B<Gnome::Gio::FileInfo> for given I<file> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method query-filesystem-info-finish ( GAsyncResult $res, N-GError $error --> GFileInfo )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method query-filesystem-info-finish ( GAsyncResult $res, $error is copy --> GFileInfo ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_query_filesystem_info_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_query_filesystem_info_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileInfo
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:1:query-info:

# Works but not usefull because the FileInfo will not be implemented. The
# reason is that Raku has proper tools to get all necessary information of a
# file as well as change them.

=begin pod
=head2 query-info

Gets the requested information about specified I<file>. The result is a B<Gnome::Gio::FileInfo> object that contains key-value attributes (such as the type or size of the file).

The I<attributes> value is a string that specifies the file attributes that should be gathered. It is not an error if it's not possible to read a particular requested attribute from a file - it just won't be set. I<attributes> should be a comma-separated list of attributes or attribute wildcards. The wildcard "*" means all attributes, and a wildcard like "standard::*" means all attributes in the standard namespace. An example attribute query be "standard::*,owner::user". The standard attributes are available as defines, like B<Gnome::Gio::-FILE-ATTRIBUTE-STANDARD-NAME>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

For symlinks, normally the information about the target of the symlink is returned, rather than information about the symlink itself. However if you pass B<Gnome::Gio::-FILE-QUERY-INFO-NOFOLLOW-SYMLINKS> in I<flags> the information about the symlink itself will be returned. Also, for symlinks that point to non-existing files the information about the symlink itself will be returned.

If the file does not exist, the C<G-IO-ERROR-NOT-FOUND> error will be returned. Other errors are possible too, and depend on what kind of filesystem the file is on.

Returns: a B<Gnome::Gio::FileInfo> for the given I<file>, or C<undefined> on error. Free the returned object with C<clear-object()>.

  method query-info ( Str $attributes, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> GFileInfo )

=item Str $attributes; an attribute query string
=item UInt $flags; a set of GFileQueryInfoFlags
=item N-GObject $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore

=end pod

method query-info (
  Str $attributes, GFlag $flags, N-GObject $cancellable is copy
  --> N-GObject
) {
  $cancellable .= _get-native-object-no-reffing unless $cancellable ~~ N-GObject;
  my CArray[N-GError] $error .= new(N-GError);

  my N-GObject $no = g_file_query_info(
    self._get-native-object-no-reffing, $attributes, $flags, $cancellable, $error
  );

  $!last-error.clear-object;
  $!last-error .= new(:native-object(?$no ?? N-GError !! $error[0]));

  $no
}

#`{{
method query-info-rk (
  Str $attributes, GFlag $flags, N-GObject $cancellable is copy
  -->Gnome::Gio::FileInfo
) {
  $cancellable .= _get-native-object-no-reffing unless $cancellable ~~ N-GObject;
  my CArray[N-GError] $error .= new(N-GError);

  my N-GObject $no = g_file_query_info(
    self._get-native-object-no-reffing, $attributes, $flags, $cancellable, $error
  );

  $!last-error.clear-object;
  $!last-error .= new(?$no ?? N-GError !! $error[0]);

  $no
}
}}

sub g_file_query_info (
  N-GFile $file, gchar-ptr $attributes, GFlag $flags, N-GObject $cancellable,
  CArray[N-GError] $error --> N-GObject
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:query-info-async:
=begin pod
=head2 query-info-async

Asynchronously gets the requested information about specified I<file>. The result is a B<Gnome::Gio::FileInfo> object that contains key-value attributes (such as type or size for the file).

For more details, see C<query-info()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-query-info-finish()> to get the result of the operation.

  method query-info-async ( Str $attributes, GFileQueryInfoFlags $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $attributes; an attribute query string
=item GFileQueryInfoFlags $flags; a set of B<Gnome::Gio::FileQueryInfoFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method query-info-async ( Str $attributes, GFileQueryInfoFlags $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_query_info_async(
    self._get-native-object-no-reffing, $attributes, $flags, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_query_info_async (
  N-GFile $file, gchar-ptr $attributes, GFlag $flags, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:query-info-finish:
=begin pod
=head2 query-info-finish

Finishes an asynchronous file info query. See C<query-info-async()>.

Returns: B<Gnome::Gio::FileInfo> for given I<file> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method query-info-finish ( GAsyncResult $res, N-GError $error --> GFileInfo )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method query-info-finish ( GAsyncResult $res, $error is copy --> GFileInfo ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_query_info_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_query_info_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileInfo
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:query-settable-attributes:
=begin pod
=head2 query-settable-attributes

Obtain the list of settable attributes for the file.

Returns the type and full attribute name of all the attributes that can be set on this file. This doesn't mean setting it will always succeed though, you might get an access failure, or some specific file may not support a specific attribute.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: a B<Gnome::Gio::FileAttributeInfoList> describing the settable attributes. When you are done with it, release it with C<attribute-info-list-unref()>

  method query-settable-attributes ( GCancellable $cancellable, N-GError $error --> GFileAttributeInfoList )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method query-settable-attributes ( GCancellable $cancellable, $error is copy --> GFileAttributeInfoList ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_query_settable_attributes(
    self._get-native-object-no-reffing, $cancellable, $error
  )
}

sub g_file_query_settable_attributes (
  N-GFile $file, GCancellable $cancellable, N-GError $error --> GFileAttributeInfoList
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:query-writable-namespaces:
=begin pod
=head2 query-writable-namespaces

Obtain the list of attribute namespaces where new attributes can be created by a user. An example of this is extended attributes (in the "xattr" namespace).

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: a B<Gnome::Gio::FileAttributeInfoList> describing the writable namespaces. When you are done with it, release it with C<attribute-info-list-unref()>

  method query-writable-namespaces ( GCancellable $cancellable, N-GError $error --> GFileAttributeInfoList )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method query-writable-namespaces ( GCancellable $cancellable, $error is copy --> GFileAttributeInfoList ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_query_writable_namespaces(
    self._get-native-object-no-reffing, $cancellable, $error
  )
}

sub g_file_query_writable_namespaces (
  N-GFile $file, GCancellable $cancellable, N-GError $error --> GFileAttributeInfoList
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:read:
=begin pod
=head2 read

Opens a file for reading. The result is a B<Gnome::Gio::FileInputStream> that can be used to read the contents of the file.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If the file does not exist, the C<G-IO-ERROR-NOT-FOUND> error will be returned. If the file is a directory, the C<G-IO-ERROR-IS-DIRECTORY> error will be returned. Other errors are possible too, and depend on what kind of filesystem the file is on.

Virtual: read-fn

Returns: B<Gnome::Gio::FileInputStream> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method read ( GCancellable $cancellable, N-GError $error --> GFileInputStream )

=item GCancellable $cancellable; a B<Gnome::Gio::Cancellable>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method read ( GCancellable $cancellable, $error is copy --> GFileInputStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_read(
    self._get-native-object-no-reffing, $cancellable, $error
  )
}

sub g_file_read (
  N-GFile $file, GCancellable $cancellable, N-GError $error --> GFileInputStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:read-async:
=begin pod
=head2 read-async

Asynchronously opens I<file> for reading.

For more details, see C<read()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-read-finish()> to get the result of the operation.

  method read-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method read-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_read_async(
    self._get-native-object-no-reffing, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_read_async (
  N-GFile $file, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:read-finish:
=begin pod
=head2 read-finish

Finishes an asynchronous file read operation started with C<read-async()>.

Returns: a B<Gnome::Gio::FileInputStream> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method read-finish ( GAsyncResult $res, N-GError $error --> GFileInputStream )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method read-finish ( GAsyncResult $res, $error is copy --> GFileInputStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_read_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_read_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileInputStream
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:replace:
=begin pod
=head2 replace

Returns an output stream for overwriting the file, possibly creating a backup copy of the file first. If the file doesn't exist, it will be created.

This will try to replace the file in the safest way possible so that any errors during the writing will not affect an already existing copy of the file. For instance, for local files it may write to a temporary file and then atomically rename over the destination when the stream is closed.

By default files created are generally readable by everyone, but if you pass B<Gnome::Gio::-FILE-CREATE-PRIVATE> in I<flags> the file will be made readable only to the current user, to the level that is supported on the target filesystem.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If you pass in a non-C<undefined> I<etag> value and I<file> already exists, then this value is compared to the current entity tag of the file, and if they differ an C<G-IO-ERROR-WRONG-ETAG> error is returned. This generally means that the file has been changed since you last read it. You can get the new etag from C<output-stream-get-etag()> after you've finished writing and closed the B<Gnome::Gio::FileOutputStream>. When you load a new file you can use C<g-file-input-stream-query-info()> to get the etag of the file.

If I<make-backup> is C<True>, this function will attempt to make a backup of the current file before overwriting it. If this fails a C<G-IO-ERROR-CANT-CREATE-BACKUP> error will be returned. If you want to replace anyway, try again with I<make-backup> set to C<False>.

If the file is a directory the C<G-IO-ERROR-IS-DIRECTORY> error will be returned, and if the file is some other form of non-regular file then a C<G-IO-ERROR-NOT-REGULAR-FILE> error will be returned. Some file systems don't allow all file names, and may return an C<G-IO-ERROR-INVALID-FILENAME> error, and if the name is to long C<G-IO-ERROR-FILENAME-TOO-LONG> will be returned. Other errors are possible too, and depend on what kind of filesystem the file is on.

Returns: a B<Gnome::Gio::FileOutputStream> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method replace ( Str $etag, Bool $make_backup, UInt $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream )

=item Str $etag; an optional [entity tag][gfile-etag] for the current B<Gnome::Gio::File>, or B<NULL> to ignore
=item Bool $make_backup; C<True> if a backup should be created
=item UInt $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method replace ( Str $etag, Bool $make_backup, UInt $flags, GCancellable $cancellable, $error is copy --> GFileOutputStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_replace(
    self._get-native-object-no-reffing, $etag, $make_backup, $flags, $cancellable, $error
  )
}

sub g_file_replace (
  N-GFile $file, gchar-ptr $etag, gboolean $make_backup, GFlag $flags, GCancellable $cancellable, N-GError $error --> GFileOutputStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:replace-async:
=begin pod
=head2 replace-async

Asynchronously overwrites the file, replacing the contents, possibly creating a backup copy of the file first.

For more details, see C<replace()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-replace-finish()> to get the result of the operation.

  method replace-async ( Str $etag, Bool $make_backup, UInt $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $etag; an [entity tag][gfile-etag] for the current B<Gnome::Gio::File>, or C<undefined> to ignore
=item Bool $make_backup; C<True> if a backup should be created
=item UInt $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method replace-async ( Str $etag, Bool $make_backup, UInt $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_replace_async(
    self._get-native-object-no-reffing, $etag, $make_backup, $flags, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_replace_async (
  N-GFile $file, gchar-ptr $etag, gboolean $make_backup, GFlag $flags, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:replace-contents:
=begin pod
=head2 replace-contents

Replaces the contents of I<file> with I<contents> of I<length> bytes.

If I<etag> is specified (not C<undefined>), any existing file must have that etag, or the error C<G-IO-ERROR-WRONG-ETAG> will be returned.

If I<make-backup> is C<True>, this function will attempt to make a backup of I<file>. Internally, it uses C<replace()>, so will try to replace the file contents in the safest way possible. For example, atomic renames are used when replacing local files’ contents.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

The returned I<new-etag> can be used to verify that the file hasn't changed the next time it is saved over.

Returns: C<True> if successful. If an error has occurred, this function will return C<False> and set I<error> appropriately if present.

  method replace-contents ( Str $contents, UInt $length, Str $etag, Bool $make_backup, UInt $flags, CArray[Str] $new_etag, GCancellable $cancellable, N-GError $error --> Bool )

=item Str $contents; (element-type guint8) (array length=length): a string containing the new contents for I<file>
=item UInt $length; the length of I<contents> in bytes
=item Str $etag; the old [entity-tag][gfile-etag] for the document, or C<undefined>
=item Bool $make_backup; C<True> if a backup should be created
=item UInt $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item CArray[Str] $new_etag; a location to a new [entity tag][gfile-etag] for the document. This should be freed with C<g-free()> when no longer needed, or C<undefined>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method replace-contents ( Str $contents, UInt $length, Str $etag, Bool $make_backup, UInt $flags, CArray[Str] $new_etag, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_replace_contents(
    self._get-native-object-no-reffing, $contents, $length, $etag, $make_backup, $flags, $new_etag, $cancellable, $error
  ).Bool
}

sub g_file_replace_contents (
  N-GFile $file, gchar-ptr $contents, gsize $length, gchar-ptr $etag, gboolean $make_backup, GFlag $flags, gchar-pptr $new_etag, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:replace-contents-async:
=begin pod
=head2 replace-contents-async

Starts an asynchronous replacement of I<file> with the given I<contents> of I<length> bytes. I<etag> will replace the document's current entity tag.

When this operation has completed, I<callback> will be called with I<user-user> data, and the operation can be finalized with C<replace-contents-finish()>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

If I<make-backup> is C<True>, this function will attempt to make a backup of I<file>.

Note that no copy of I<content> will be made, so it must stay valid until I<callback> is called. See C<g-file-replace-contents-bytes-async()> for a B<Gnome::Gio::Bytes> version that will automatically hold a reference to the contents (without copying) for the duration of the call.

  method replace-contents-async ( Str $contents, UInt $length, Str $etag, Bool $make_backup, UInt $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $contents; (element-type guint8) (array length=length): string of contents to replace the file with
=item UInt $length; the length of I<contents> in bytes
=item Str $etag; a new [entity tag][gfile-etag] for the I<file>, or C<undefined>
=item Bool $make_backup; C<True> if a backup should be created
=item UInt $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function
=end pod

method replace-contents-async ( Str $contents, UInt $length, Str $etag, Bool $make_backup, UInt $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_replace_contents_async(
    self._get-native-object-no-reffing, $contents, $length, $etag, $make_backup, $flags, $cancellable, $callback, $user_data
  );
}

sub g_file_replace_contents_async (
  N-GFile $file, gchar-ptr $contents, gsize $length, gchar-ptr $etag, gboolean $make_backup, GFlag $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:replace-contents-bytes-async:
=begin pod
=head2 replace-contents-bytes-async

Same as C<replace-contents-async()> but takes a B<Gnome::Gio::Bytes> input instead. This function will keep a ref on I<contents> until the operation is done. Unlike C<g-file-replace-contents-async()> this allows forgetting about the content without waiting for the callback.

When this operation has completed, I<callback> will be called with I<user-user> data, and the operation can be finalized with C<g-file-replace-contents-finish()>.

  method replace-contents-bytes-async ( N-GObject $contents, Str $etag, Bool $make_backup, self._get-native-object-no-reffing $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item N-GObject $contents; a B<Gnome::Gio::Bytes>
=item Str $etag; a new [entity tag][gfile-etag] for the I<file>, or C<undefined>
=item Bool $make_backup; C<True> if a backup should be created
=item self._get-native-object-no-reffing $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function
=end pod

method replace-contents-bytes-async ( $contents is copy, Str $etag, Bool $make_backup, self._get-native-object-no-reffing $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {
  $contents .= _get-native-object-no-reffing unless $contents ~~ N-GObject;

  g_file_replace_contents_bytes_async(
    self._get-native-object-no-reffing, $contents, $etag, $make_backup, $flags, $cancellable, $callback, $user_data
  );
}

sub g_file_replace_contents_bytes_async (
  N-GFile $file, N-GObject $contents, gchar-ptr $etag, gboolean $make_backup, GFlag $flags, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:replace-contents-finish:
=begin pod
=head2 replace-contents-finish

Finishes an asynchronous replace of the given I<file>. See C<replace-contents-async()>. Sets I<new-etag> to the new entity tag for the document, if present.

Returns: C<True> on success, C<False> on failure.

  method replace-contents-finish ( GAsyncResult $res, CArray[Str] $new_etag, N-GError $error --> Bool )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item CArray[Str] $new_etag; a location of a new [entity tag][gfile-etag] for the document. This should be freed with C<g-free()> when it is no longer needed, or C<undefined>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method replace-contents-finish ( GAsyncResult $res, CArray[Str] $new_etag, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_replace_contents_finish(
    self._get-native-object-no-reffing, $res, $new_etag, $error
  ).Bool
}

sub g_file_replace_contents_finish (
  N-GFile $file, GAsyncResult $res, gchar-pptr $new_etag, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:replace-finish:
=begin pod
=head2 replace-finish

Finishes an asynchronous file replace operation started with C<replace-async()>.

Returns: a B<Gnome::Gio::FileOutputStream>, or C<undefined> on error. Free the returned object with C<clear-object()>.

  method replace-finish ( GAsyncResult $res, N-GError $error --> GFileOutputStream )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method replace-finish ( GAsyncResult $res, $error is copy --> GFileOutputStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_replace_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_replace_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileOutputStream
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:replace-readwrite:
=begin pod
=head2 replace-readwrite

Returns an output stream for overwriting the file in readwrite mode, possibly creating a backup copy of the file first. If the file doesn't exist, it will be created.

For details about the behaviour, see C<replace()> which does the same thing but returns an output stream only.

Note that in many non-local file cases read and write streams are not supported, so make sure you really need to do read and write streaming, rather than just opening for reading or writing.

Returns: a B<Gnome::Gio::FileIOStream> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method replace-readwrite ( Str $etag, Bool $make_backup, self._get-native-object-no-reffing $flags, GCancellable $cancellable, N-GError $error --> GFileIOStream )

=item Str $etag; an optional [entity tag][gfile-etag] for the current B<Gnome::Gio::File>, or B<NULL> to ignore
=item Bool $make_backup; C<True> if a backup should be created
=item self._get-native-object-no-reffing $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; return location for a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method replace-readwrite ( Str $etag, Bool $make_backup, self._get-native-object-no-reffing $flags, GCancellable $cancellable, $error is copy --> GFileIOStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_replace_readwrite(
    self._get-native-object-no-reffing, $etag, $make_backup, $flags, $cancellable, $error
  )
}

sub g_file_replace_readwrite (
  N-GFile $file, gchar-ptr $etag, gboolean $make_backup, GFlag $flags, GCancellable $cancellable, N-GError $error --> GFileIOStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:replace-readwrite-async:
=begin pod
=head2 replace-readwrite-async

Asynchronously overwrites the file in read-write mode, replacing the contents, possibly creating a backup copy of the file first.

For more details, see C<replace-readwrite()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-replace-readwrite-finish()> to get the result of the operation.

  method replace-readwrite-async ( Str $etag, Bool $make_backup, self._get-native-object-no-reffing $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $etag; an [entity tag][gfile-etag] for the current B<Gnome::Gio::File>, or C<undefined> to ignore
=item Bool $make_backup; C<True> if a backup should be created
=item self._get-native-object-no-reffing $flags; a set of B<Gnome::Gio::FileCreateFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method replace-readwrite-async ( Str $etag, Bool $make_backup, self._get-native-object-no-reffing $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_replace_readwrite_async(
    self._get-native-object-no-reffing, $etag, $make_backup, $flags, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_replace_readwrite_async (
  N-GFile $file, gchar-ptr $etag, gboolean $make_backup, GFlag $flags, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:replace-readwrite-finish:
=begin pod
=head2 replace-readwrite-finish

Finishes an asynchronous file replace operation started with C<replace-readwrite-async()>.

Returns: a B<Gnome::Gio::FileIOStream>, or C<undefined> on error. Free the returned object with C<clear-object()>.

  method replace-readwrite-finish ( GAsyncResult $res, N-GError $error --> GFileIOStream )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method replace-readwrite-finish ( GAsyncResult $res, $error is copy --> GFileIOStream ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_replace_readwrite_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_replace_readwrite_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> GFileIOStream
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:resolve-relative-path:
=begin pod
=head2 resolve-relative-path

Resolves a relative path for I<file> to an absolute path.

This call does no blocking I/O.

Returns: B<Gnome::Gio::File> to the resolved path. C<undefined> if I<relative-path> is C<undefined> or if I<file> is invalid. Free the returned object with C<clear-object()>.

  method resolve-relative-path ( Str $relative_path --> N-GFile )

=item Str $relative_path; (type filename): a given relative path string
=end pod

method resolve-relative-path ( Str $relative_path --> N-GFile ) {

  g_file_resolve_relative_path(
    self._get-native-object-no-reffing, $relative_path
  )
}

sub g_file_resolve_relative_path (
  N-GFile $file, gchar-ptr $relative_path --> N-GFile
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attribute:
=begin pod
=head2 set-attribute

Sets an attribute in the file with attribute name I<attribute> to I<value>.

Some attributes can be unset by setting I<type> to C<G-FILE-ATTRIBUTE-TYPE-INVALID> and I<value-p> to C<undefined>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> if the attribute was set, C<False> otherwise.

  method set-attribute ( Str $attribute, GFileAttributeType $type, Pointer $value_p, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Bool )

=item Str $attribute; a string containing the attribute's name
=item GFileAttributeType $type; The type of the attribute
=item Pointer $value_p; a pointer to the value (or the pointer itself if the type is a pointer type)
=item GFileQueryInfoFlags $flags; a set of B<Gnome::Gio::FileQueryInfoFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-attribute ( Str $attribute, GFileAttributeType $type, Pointer $value_p, GFileQueryInfoFlags $flags, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_attribute(
    self._get-native-object-no-reffing, $attribute, $type, $value_p, $flags, $cancellable, $error
  ).Bool
}

sub g_file_set_attribute (
  N-GFile $file, gchar-ptr $attribute, GEnum $type, gpointer $value_p, GFlag $flags, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attribute-byte-string:
=begin pod
=head2 set-attribute-byte-string

Sets I<attribute> of type C<G-FILE-ATTRIBUTE-TYPE-BYTE-STRING> to I<value>. If I<attribute> is of a different type, this operation will fail, returning C<False>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> if the I<attribute> was successfully set to I<value> in the I<file>, C<False> otherwise.

  method set-attribute-byte-string ( Str $attribute, Str $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Bool )

=item Str $attribute; a string containing the attribute's name
=item Str $value; a string containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<Gnome::Gio::FileQueryInfoFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-attribute-byte-string ( Str $attribute, Str $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_attribute_byte_string(
    self._get-native-object-no-reffing, $attribute, $value, $flags, $cancellable, $error
  ).Bool
}

sub g_file_set_attribute_byte_string (
  N-GFile $file, gchar-ptr $attribute, gchar-ptr $value, GFlag $flags, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attribute-int32:
=begin pod
=head2 set-attribute-int32

Sets I<attribute> of type C<G-FILE-ATTRIBUTE-TYPE-INT32> to I<value>. If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> if the I<attribute> was successfully set to I<value> in the I<file>, C<False> otherwise.

  method set-attribute-int32 ( Str $attribute, Int() $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Bool )

=item Str $attribute; a string containing the attribute's name
=item Int() $value; a B<gint32> containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<Gnome::Gio::FileQueryInfoFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-attribute-int32 ( Str $attribute, Int() $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_attribute_int32(
    self._get-native-object-no-reffing, $attribute, $value, $flags, $cancellable, $error
  ).Bool
}

sub g_file_set_attribute_int32 (
  N-GFile $file, gchar-ptr $attribute, gint32 $value, GFlag $flags, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attribute-int64:
=begin pod
=head2 set-attribute-int64

Sets I<attribute> of type C<G-FILE-ATTRIBUTE-TYPE-INT64> to I<value>. If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> if the I<attribute> was successfully set, C<False> otherwise.

  method set-attribute-int64 ( Str $attribute, Int() $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Bool )

=item Str $attribute; a string containing the attribute's name
=item Int() $value; a B<guint64> containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<Gnome::Gio::FileQueryInfoFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-attribute-int64 ( Str $attribute, Int() $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_attribute_int64(
    self._get-native-object-no-reffing, $attribute, $value, $flags, $cancellable, $error
  ).Bool
}

sub g_file_set_attribute_int64 (
  N-GFile $file, gchar-ptr $attribute, gint64 $value, GFlag $flags, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attribute-string:
=begin pod
=head2 set-attribute-string

Sets I<attribute> of type C<G-FILE-ATTRIBUTE-TYPE-STRING> to I<value>. If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> if the I<attribute> was successfully set, C<False> otherwise.

  method set-attribute-string ( Str $attribute, Str $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Bool )

=item Str $attribute; a string containing the attribute's name
=item Str $value; a string containing the attribute's value
=item GFileQueryInfoFlags $flags; B<Gnome::Gio::FileQueryInfoFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-attribute-string ( Str $attribute, Str $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_attribute_string(
    self._get-native-object-no-reffing, $attribute, $value, $flags, $cancellable, $error
  ).Bool
}

sub g_file_set_attribute_string (
  N-GFile $file, gchar-ptr $attribute, gchar-ptr $value, GFlag $flags, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attribute-uint32:
=begin pod
=head2 set-attribute-uint32

Sets I<attribute> of type C<G-FILE-ATTRIBUTE-TYPE-UINT32> to I<value>. If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> if the I<attribute> was successfully set to I<value> in the I<file>, C<False> otherwise.

  method set-attribute-uint32 ( Str $attribute, UInt $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Bool )

=item Str $attribute; a string containing the attribute's name
=item UInt $value; a B<guint32> containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<Gnome::Gio::FileQueryInfoFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-attribute-uint32 ( Str $attribute, UInt $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_attribute_uint32(
    self._get-native-object-no-reffing, $attribute, $value, $flags, $cancellable, $error
  ).Bool
}

sub g_file_set_attribute_uint32 (
  N-GFile $file, gchar-ptr $attribute, guint32 $value, GFlag $flags, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attribute-uint64:
=begin pod
=head2 set-attribute-uint64

Sets I<attribute> of type C<G-FILE-ATTRIBUTE-TYPE-UINT64> to I<value>. If I<attribute> is of a different type, this operation will fail.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<True> if the I<attribute> was successfully set to I<value> in the I<file>, C<False> otherwise.

  method set-attribute-uint64 ( Str $attribute, UInt $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Bool )

=item Str $attribute; a string containing the attribute's name
=item UInt $value; a B<guint64> containing the attribute's new value
=item GFileQueryInfoFlags $flags; a B<Gnome::Gio::FileQueryInfoFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-attribute-uint64 ( Str $attribute, UInt $value, GFileQueryInfoFlags $flags, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_attribute_uint64(
    self._get-native-object-no-reffing, $attribute, $value, $flags, $cancellable, $error
  ).Bool
}

sub g_file_set_attribute_uint64 (
  N-GFile $file, gchar-ptr $attribute, guint64 $value, GFlag $flags, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attributes-async:
=begin pod
=head2 set-attributes-async

Asynchronously sets the attributes of I<file> with I<info>.

For more details, see C<set-attributes-from-info()>, which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-set-attributes-finish()> to get the result of the operation.

  method set-attributes-async ( GFileInfo $info, GFileQueryInfoFlags $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GFileInfo $info; a B<Gnome::Gio::FileInfo>
=item GFileQueryInfoFlags $flags; a B<Gnome::Gio::FileQueryInfoFlags>
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback>
=item Pointer $user_data; (closure): a B<gpointer>
=end pod

method set-attributes-async ( GFileInfo $info, GFileQueryInfoFlags $flags, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_set_attributes_async(
    self._get-native-object-no-reffing, $info, $flags, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_set_attributes_async (
  N-GFile $file, GFileInfo $info, GFlag $flags, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attributes-finish:
=begin pod
=head2 set-attributes-finish

Finishes setting an attribute started in C<set-attributes-async()>.

Returns: C<True> if the attributes were set correctly, C<False> otherwise.

  method set-attributes-finish ( GAsyncResult $result, GFileInfo $info, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item GFileInfo $info; a B<Gnome::Gio::FileInfo>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-attributes-finish ( GAsyncResult $result, GFileInfo $info, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_attributes_finish(
    self._get-native-object-no-reffing, $result, $info, $error
  ).Bool
}

sub g_file_set_attributes_finish (
  N-GFile $file, GAsyncResult $result, GFileInfo $info, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-attributes-from-info:
=begin pod
=head2 set-attributes-from-info

Tries to set all attributes in the B<Gnome::Gio::FileInfo> on the target values, not stopping on the first error.

If there is any error during this operation then I<error> will be set to the first error. Error on particular fields are flagged by setting the "status" field in the attribute value to C<G-FILE-ATTRIBUTE-STATUS-ERROR-SETTING>, which means you can also detect further errors.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: C<False> if there was any error, C<True> otherwise.

  method set-attributes-from-info ( GFileInfo $info, GFileQueryInfoFlags $flags, GCancellable $cancellable, N-GError $error --> Bool )

=item GFileInfo $info; a B<Gnome::Gio::FileInfo>
=item GFileQueryInfoFlags $flags; B<Gnome::Gio::FileQueryInfoFlags>
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-attributes-from-info ( GFileInfo $info, GFileQueryInfoFlags $flags, GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_attributes_from_info(
    self._get-native-object-no-reffing, $info, $flags, $cancellable, $error
  ).Bool
}

sub g_file_set_attributes_from_info (
  N-GFile $file, GFileInfo $info, GFlag $flags, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:set-display-name:
=begin pod
=head2 set-display-name

Renames I<file> to the specified display name.

The display name is converted from UTF-8 to the correct encoding for the target filesystem if possible and the I<file> is renamed to this.

If you want to implement a rename operation in the user interface the edit name (B<Gnome::Gio::-FILE-ATTRIBUTE-STANDARD-EDIT-NAME>) should be used as the initial value in the rename widget, and then the result after editing should be passed to C<set-display-name()>.

On success the resulting converted filename is returned.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Returns: a B<Gnome::Gio::File> specifying what I<file> was renamed to, or C<undefined> if there was an error. Free the returned object with C<clear-object()>.

  method set-display-name ( Str $display_name, GCancellable $cancellable, N-GError $error --> N-GFile )

=item Str $display_name; a string
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-display-name ( Str $display_name, GCancellable $cancellable, $error is copy --> N-GFile ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_display_name(
    self._get-native-object-no-reffing, $display_name, $cancellable, $error
  )
}

sub g_file_set_display_name (
  N-GFile $file, gchar-ptr $display_name, GCancellable $cancellable, N-GError $error --> N-GFile
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-display-name-async:
=begin pod
=head2 set-display-name-async

Asynchronously sets the display name for a given B<Gnome::Gio::File>.

For more details, see C<set-display-name()> which is the synchronous version of this call.

When the operation is finished, I<callback> will be called. You can then call C<g-file-set-display-name-finish()> to get the result of the operation.

  method set-display-name-async ( Str $display_name, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $display_name; a string
=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async): a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method set-display-name-async ( Str $display_name, Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_set_display_name_async(
    self._get-native-object-no-reffing, $display_name, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_set_display_name_async (
  N-GFile $file, gchar-ptr $display_name, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-display-name-finish:
=begin pod
=head2 set-display-name-finish

Finishes setting a display name started with C<set-display-name-async()>.

Returns: a B<Gnome::Gio::File> or C<undefined> on error. Free the returned object with C<clear-object()>.

  method set-display-name-finish ( GAsyncResult $res, N-GError $error --> N-GFile )

=item GAsyncResult $res; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method set-display-name-finish ( GAsyncResult $res, $error is copy --> N-GFile ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_set_display_name_finish(
    self._get-native-object-no-reffing, $res, $error
  )
}

sub g_file_set_display_name_finish (
  N-GFile $file, GAsyncResult $res, N-GError $error --> N-GFile
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:start-mountable:
=begin pod
=head2 start-mountable

Starts a file of type B<Gnome::Gio::-FILE-TYPE-MOUNTABLE>. Using I<start-operation>, you can request callbacks when, for instance, passwords are needed during authentication.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

When the operation is finished, I<callback> will be called. You can then call C<mount-mountable-finish()> to get the result of the operation.

  method start-mountable ( GDriveStartFlags $flags, GMountOperation $start_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GDriveStartFlags $flags; flags affecting the operation
=item GMountOperation $start_operation; a B<Gnome::Gio::MountOperation>, or C<undefined> to avoid user interaction
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied, or C<undefined>
=item Pointer $user_data; the data to pass to callback function
=end pod

method start-mountable ( GDriveStartFlags $flags, GMountOperation $start_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_start_mountable(
    self._get-native-object-no-reffing, $flags, $start_operation, $cancellable, $callback, $user_data
  );
}

sub g_file_start_mountable (
  N-GFile $file, GDriveStartFlags $flags, GMountOperation $start_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:start-mountable-finish:
=begin pod
=head2 start-mountable-finish

Finishes a start operation. See C<start-mountable()> for details.

Finish an asynchronous start operation that was started with C<g-file-start-mountable()>.

Returns: C<True> if the operation finished successfully. C<False> otherwise.

  method start-mountable-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method start-mountable-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_start_mountable_finish(
    self._get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_file_start_mountable_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:stop-mountable:
=begin pod
=head2 stop-mountable

Stops a file of type B<Gnome::Gio::-FILE-TYPE-MOUNTABLE>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

When the operation is finished, I<callback> will be called. You can then call C<stop-mountable-finish()> to get the result of the operation.

  method stop-mountable ( GMountUnmountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountUnmountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; a B<Gnome::Gio::MountOperation>, or C<undefined> to avoid user interaction.
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied, or C<undefined>
=item Pointer $user_data; the data to pass to callback function
=end pod

method stop-mountable ( GMountUnmountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_stop_mountable(
    self._get-native-object-no-reffing, $flags, $mount_operation, $cancellable, $callback, $user_data
  );
}

sub g_file_stop_mountable (
  N-GFile $file, GFlag $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:stop-mountable-finish:
=begin pod
=head2 stop-mountable-finish

Finishes an stop operation, see C<stop-mountable()> for details.

Finish an asynchronous stop operation that was started with C<g-file-stop-mountable()>.

Returns: C<True> if the operation finished successfully. C<False> otherwise.

  method stop-mountable-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method stop-mountable-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_stop_mountable_finish(
    self._get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_file_stop_mountable_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:supports-thread-contexts:
=begin pod
=head2 supports-thread-contexts

Checks if I<file> supports [thread-default contexts][g-main-context-push-thread-default-context]. If this returns C<False>, you cannot perform asynchronous operations on I<file> in a thread that has a thread-default context.

Returns: Whether or not I<file> supports thread-default contexts.

  method supports-thread-contexts ( --> Bool )

=end pod

method supports-thread-contexts ( --> Bool ) {

  g_file_supports_thread_contexts(
    self._get-native-object-no-reffing,
  ).Bool
}

sub g_file_supports_thread_contexts (
  N-GFile $file --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:trash:
=begin pod
=head2 trash

Sends I<file> to the "Trashcan", if possible. This is similar to deleting it, but the user can recover it before emptying the trashcan. Not all file systems support trashing, so this call can return the C<G-IO-ERROR-NOT-SUPPORTED> error.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

Virtual: trash

Returns: C<True> on successful trash, C<False> otherwise.

  method trash ( GCancellable $cancellable, N-GError $error --> Bool )

=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method trash ( GCancellable $cancellable, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_trash(
    self._get-native-object-no-reffing, $cancellable, $error
  ).Bool
}

sub g_file_trash (
  N-GFile $file, GCancellable $cancellable, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:trash-async:
=begin pod
=head2 trash-async

Asynchronously sends I<file> to the Trash location, if possible.

Virtual: trash-async

  method trash-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Int() $io_priority; the [I/O priority][io-priority] of the request
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied
=item Pointer $user_data; the data to pass to callback function
=end pod

method trash-async ( Int() $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_trash_async(
    self._get-native-object-no-reffing, $io_priority, $cancellable, $callback, $user_data
  );
}

sub g_file_trash_async (
  N-GFile $file, int $io_priority, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:trash-finish:
=begin pod
=head2 trash-finish

Finishes an asynchronous file trashing operation, started with C<trash-async()>.

Virtual: trash-finish

Returns: C<True> on successful trash, C<False> otherwise.

  method trash-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method trash-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_trash_finish(
    self._get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_file_trash_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:unmount-mountable-with-operation:
=begin pod
=head2 unmount-mountable-with-operation

Unmounts a file of type B<Gnome::Gio::-FILE-TYPE-MOUNTABLE>.

If I<cancellable> is not C<undefined>, then the operation can be cancelled by triggering the cancellable object from another thread. If the operation was cancelled, the error C<G-IO-ERROR-CANCELLED> will be returned.

When the operation is finished, I<callback> will be called. You can then call C<unmount-mountable-finish()> to get the result of the operation.

  method unmount-mountable-with-operation ( GMountUnmountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GMountUnmountFlags $flags; flags affecting the operation
=item GMountOperation $mount_operation; a B<Gnome::Gio::MountOperation>, or C<undefined> to avoid user interaction
=item GCancellable $cancellable; optional B<Gnome::Gio::Cancellable> object, C<undefined> to ignore
=item GAsyncReadyCallback $callback; (scope async) : a B<Gnome::Gio::AsyncReadyCallback> to call when the request is satisfied, or C<undefined>
=item Pointer $user_data; (closure): the data to pass to callback function
=end pod

method unmount-mountable-with-operation ( GMountUnmountFlags $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_file_unmount_mountable_with_operation(
    self._get-native-object-no-reffing, $flags, $mount_operation, $cancellable, $callback, $user_data
  );
}

sub g_file_unmount_mountable_with_operation (
  N-GFile $file, GFlag $flags, GMountOperation $mount_operation, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:unmount-mountable-with-operation-finish:
=begin pod
=head2 unmount-mountable-with-operation-finish

Finishes an unmount operation, see C<unmount-mountable-with-operation()> for details.

Finish an asynchronous unmount operation that was started with C<g-file-unmount-mountable-with-operation()>.

Returns: C<True> if the operation finished successfully. C<False> otherwise.

  method unmount-mountable-with-operation-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method unmount-mountable-with-operation-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;

  g_file_unmount_mountable_with_operation_finish(
    self._get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_file_unmount_mountable_with_operation_finish (
  N-GFile $file, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:_g_file_new_build_filename:
#`{{
=begin pod
=head2 _g_file_new_build_filename

Constructs a B<Gnome::Gio::File> from a series of elements using the correct separator for filenames.

Using this function is equivalent to calling C<g-build-filename()>, followed by C<new-for-path()> on the result.

Returns: a new B<Gnome::Gio::File>

  method _g_file_new_build_filename ( Str $first_element --> N-GFile )

=item Str $first_element; (type filename): the first element in the path @...: remaining elements in path, terminated by C<undefined>
=end pod
}}

sub _g_file_new_build_filename ( gchar-ptr $first_element, Any $any = Any --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_build_filename')
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:_g_file_new_for_commandline_arg:
#`{{
=begin pod
=head2 _g_file_new_for_commandline_arg

Creates a B<Gnome::Gio::File> with the given argument from the command line. The value of I<arg> can be either a URI, an absolute path or a relative path resolved relative to the current working directory. This operation never fails, but the returned object might not support any I/O operation if I<arg> points to a malformed path.

Note that on Windows, this function expects its argument to be in UTF-8 -- not the system code page. This means that you should not use this function with string from argv as it is passed to C<main()>. C<g-win32-get-command-line()> will return a UTF-8 version of the commandline. B<Gnome::Gio::Application> also uses UTF-8 but C<g-application-command-line-create-file-for-arg()> may be more useful for you there. It is also always possible to use this function with B<Gnome::Gio::OptionContext> arguments of type C<G-OPTION-ARG-FILENAME>.

Returns: a new B<Gnome::Gio::File>. Free the returned object with C<clear-object()>.

  method _g_file_new_for_commandline_arg ( Str $arg --> N-GFile )

=item Str $arg; (type filename): a command line string
=end pod
}}

sub _g_file_new_for_commandline_arg ( gchar-ptr $arg --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_for_commandline_arg')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_file_new_for_commandline_arg_and_cwd:
#`{{
=begin pod
=head2 _g_file_new_for_commandline_arg_and_cwd

Creates a B<Gnome::Gio::File> with the given argument from the command line.

This function is similar to C<new-for-commandline-arg()> except that it allows for passing the current working directory as an argument instead of using the current working directory of the process.

This is useful if the commandline argument was given in a context other than the invocation of the current process.

See also C<g-application-command-line-create-file-for-arg()>.

Returns: a new B<Gnome::Gio::File>

  method _g_file_new_for_commandline_arg_and_cwd ( Str $arg, Str $cwd --> N-GFile )

=item Str $arg; a command line string
=item Str $cwd; the current working directory of the commandline
=end pod
}}

sub _g_file_new_for_commandline_arg_and_cwd ( gchar-ptr $arg, gchar-ptr $cwd --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_for_commandline_arg_and_cwd')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_file_new_for_path:
#`{{
=begin pod
=head2 _g_file_new_for_path

Constructs a B<Gnome::Gio::File> for a given path. This operation never fails, but the returned object might not support any I/O operation if I<path> is malformed.

Returns: a new B<Gnome::Gio::File> for the given I<path>. Free the returned object with C<clear-object()>.

  method _g_file_new_for_path ( Str $path --> N-GFile )

=item Str $path; (type filename): a string containing a relative or absolute path. The string must be encoded in the glib filename encoding.
=end pod
}}

sub _g_file_new_for_path ( gchar-ptr $path --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_for_path')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_file_new_for_uri:
#`{{
=begin pod
=head2 _g_file_new_for_uri

Constructs a B<Gnome::Gio::File> for a given URI. This operation never fails, but the returned object might not support any I/O operation if I<uri> is malformed or if the uri type is not supported.

Returns: a new B<Gnome::Gio::File> for the given I<uri>. Free the returned object with C<clear-object()>.

  method _g_file_new_for_uri ( Str $uri --> N-GFile )

=item Str $uri; a UTF-8 string containing a URI
=end pod
}}

sub _g_file_new_for_uri ( gchar-ptr $uri --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_for_uri')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:_g_file_new_tmp:
#`{{
=begin pod
=head2 _g_file_new_tmp

Opens a file in the preferred directory for temporary files (as returned by C<g-get-tmp-dir()>) and returns a B<Gnome::Gio::File> and B<Gnome::Gio::FileIOStream> pointing to it.

I<tmpl> should be a string in the GLib file name encoding containing a sequence of six 'X' characters, and containing no directory components. If it is C<undefined>, a default template is used.

Unlike the other B<Gnome::Gio::File> constructors, this will return C<undefined> if a temporary file could not be created.

Returns: a new B<Gnome::Gio::File>. Free the returned object with C<clear-object()>.

  method _g_file_new_tmp ( Str $tmpl, GFileIOStream $iostream, N-GError $error --> N-GFile )

=item Str $tmpl; (type filename) : Template for the file name, as in C<open-tmp()>, or C<undefined> for a default template
=item GFileIOStream $iostream; on return, a B<Gnome::Gio::FileIOStream> for the created file
=item N-GError $error; a B<Gnome::Gio::Error>, or C<undefined>
=end pod
}}

sub _g_file_new_tmp ( gchar-ptr $tmpl, GFileIOStream $iostream, N-GError $error --> N-GFile )
  is native(&gio-lib)
  is symbol('g_file_new_tmp')
  { * }
}}
