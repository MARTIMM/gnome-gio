#TL:1:Gnome::Gio::Enums:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Enums

=head1 Description

All enummerations and flags used for Gio are defined here.

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::Enums;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::Enums:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=end pod
#-------------------------------------------------------------------------------
=begin pod
=head2 enum GAppInfoCreateFlags

Flags used when creating a B<GAppInfo>.

=item G_APP_INFO_CREATE_NONE: No flags.
=item G_APP_INFO_CREATE_NEEDS_TERMINAL: Application opens in a terminal window.
=item G_APP_INFO_CREATE_SUPPORTS_URIS: Application supports URI arguments.
=item G_APP_INFO_CREATE_SUPPORTS_STARTUP_NOTIFICATION: Application supports startup notification.

=end pod

#TE:0:GAppInfoCreateFlags:
enum GAppInfoCreateFlags is export (
  G_APP_INFO_CREATE_NONE                            => 0x00,
  G_APP_INFO_CREATE_NEEDS_TERMINAL                  => 0x01,
  G_APP_INFO_CREATE_SUPPORTS_URIS                   => 0x02,
  G_APP_INFO_CREATE_SUPPORTS_STARTUP_NOTIFICATION   => 0x04,
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GConverterFlags

Flags used when calling a C<g_converter_convert()>.

=item G_CONVERTER_NO_FLAGS: No flags.
=item G_CONVERTER_INPUT_AT_END: At end of input data
=item G_CONVERTER_FLUSH: Flush data

=end pod

#TE:0:GConverterFlags:
enum GConverterFlags is export (
  'G_CONVERTER_FLUSH'        => (1 +< 1)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GConverterResult

Results returned from C<g_converter_convert()>.

Since: 2.24


=item G_CONVERTER_ERROR: There was an error during conversion.
=item G_CONVERTER_CONVERTED: Some data was consumed or produced
=item G_CONVERTER_FINISHED: The conversion is finished
=item G_CONVERTER_FLUSHED: Flushing is finished


=end pod

#TE:0:GConverterResult:
enum GConverterResult is export (
  'G_CONVERTER_FLUSHED'   => 3
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDataStreamByteOrder

B<GDataStreamByteOrder> is used to ensure proper endianness of streaming data sources
across various machine architectures.



=item G_DATA_STREAM_BYTE_ORDER_BIG_ENDIAN: Selects Big Endian byte order.
=item G_DATA_STREAM_BYTE_ORDER_LITTLE_ENDIAN: Selects Little Endian byte order.
=item G_DATA_STREAM_BYTE_ORDER_HOST_ENDIAN: Selects endianness based on host machine's architecture.


=end pod

#TE:0:GDataStreamByteOrder:
enum GDataStreamByteOrder is export (
  'G_DATA_STREAM_BYTE_ORDER_BIG_ENDIAN',
  'G_DATA_STREAM_BYTE_ORDER_LITTLE_ENDIAN',
  'G_DATA_STREAM_BYTE_ORDER_HOST_ENDIAN'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDataStreamNewlineType

B<GDataStreamNewlineType> is used when checking for or setting the line endings for a given file.


=item G_DATA_STREAM_NEWLINE_TYPE_LF: Selects "LF" line endings, common on most modern UNIX platforms.
=item G_DATA_STREAM_NEWLINE_TYPE_CR: Selects "CR" line endings.
=item G_DATA_STREAM_NEWLINE_TYPE_CR_LF: Selects "CR, LF" line ending, common on Microsoft Windows.
=item G_DATA_STREAM_NEWLINE_TYPE_ANY: Automatically try to handle any line ending type.


=end pod

#TE:0:GDataStreamNewlineType:
enum GDataStreamNewlineType is export (
  'G_DATA_STREAM_NEWLINE_TYPE_LF',
  'G_DATA_STREAM_NEWLINE_TYPE_CR',
  'G_DATA_STREAM_NEWLINE_TYPE_CR_LF',
  'G_DATA_STREAM_NEWLINE_TYPE_ANY'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileAttributeType

The data types for file attributes.


=item G_FILE_ATTRIBUTE_TYPE_INVALID: indicates an invalid or uninitalized type.
=item G_FILE_ATTRIBUTE_TYPE_STRING: a null terminated UTF8 string.
=item G_FILE_ATTRIBUTE_TYPE_BYTE_STRING: a zero terminated string of non-zero bytes.
=item G_FILE_ATTRIBUTE_TYPE_BOOLEAN: a boolean value.
=item G_FILE_ATTRIBUTE_TYPE_UINT32: an unsigned 4-byte/32-bit integer.
=item G_FILE_ATTRIBUTE_TYPE_INT32: a signed 4-byte/32-bit integer.
=item G_FILE_ATTRIBUTE_TYPE_UINT64: an unsigned 8-byte/64-bit integer.
=item G_FILE_ATTRIBUTE_TYPE_INT64: a signed 8-byte/64-bit integer.
=item G_FILE_ATTRIBUTE_TYPE_OBJECT: a B<GObject>.
=item G_FILE_ATTRIBUTE_TYPE_STRINGV: a C<Any> terminated char **. Since 2.22


=end pod

#TE:0:GFileAttributeType:
enum GFileAttributeType is export (
  'G_FILE_ATTRIBUTE_TYPE_INVALID' => 0,
  'G_FILE_ATTRIBUTE_TYPE_STRING',
  'G_FILE_ATTRIBUTE_TYPE_BOOLEAN',
  'G_FILE_ATTRIBUTE_TYPE_UINT32',
  'G_FILE_ATTRIBUTE_TYPE_INT32',
  'G_FILE_ATTRIBUTE_TYPE_UINT64',
  'G_FILE_ATTRIBUTE_TYPE_INT64',
  'G_FILE_ATTRIBUTE_TYPE_OBJECT',
  'G_FILE_ATTRIBUTE_TYPE_STRINGV'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileAttributeInfoFlags

Flags specifying the behaviour of an attribute.


=item G_FILE_ATTRIBUTE_INFO_NONE: no flags set.
=item G_FILE_ATTRIBUTE_INFO_COPY_WITH_FILE: copy the attribute values when the file is copied.
=item G_FILE_ATTRIBUTE_INFO_COPY_WHEN_MOVED: copy the attribute values when the file is moved.


=end pod

#TE:0:GFileAttributeInfoFlags:
enum GFileAttributeInfoFlags is export (
  'G_FILE_ATTRIBUTE_INFO_NONE'            => 0,
  'G_FILE_ATTRIBUTE_INFO_COPY_WITH_FILE'  => (1 +< 0),
  'G_FILE_ATTRIBUTE_INFO_COPY_WHEN_MOVED' => (1 +< 1)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileAttributeStatus

Used by C<g_file_set_attributes_from_info()> when setting file attributes.


=item G_FILE_ATTRIBUTE_STATUS_UNSET: Attribute value is unset (empty).
=item G_FILE_ATTRIBUTE_STATUS_SET: Attribute value is set.
=item G_FILE_ATTRIBUTE_STATUS_ERROR_SETTING: Indicates an error in setting the value.


=end pod

#TE:0:GFileAttributeStatus:
enum GFileAttributeStatus is export (
  'G_FILE_ATTRIBUTE_STATUS_UNSET' => 0,
  'G_FILE_ATTRIBUTE_STATUS_SET',
  'G_FILE_ATTRIBUTE_STATUS_ERROR_SETTING'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileQueryInfoFlags

Flags used when querying a B<GFileInfo>.


=item G_FILE_QUERY_INFO_NONE: No flags set.
=item G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS: Don't follow symlinks.


=end pod

#TE:0:GFileQueryInfoFlags:
enum GFileQueryInfoFlags is export (
  'G_FILE_QUERY_INFO_NONE'              => 0,
  'G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS' => (1 +< 0)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileCreateFlags

Flags used when an operation may create a file.


=item G_FILE_CREATE_NONE: No flags set.
=item G_FILE_CREATE_PRIVATE: Create a file that can only be accessed by the current user.
=item G_FILE_CREATE_REPLACE_DESTINATION: Replace the destination as if it didn't exist before. Don't try to keep any old permissions, replace instead of following links. This is generally useful if you're doing a "copy over" rather than a "save new version of" replace operation. You can think of it as "unlink destination" before writing to it, although the implementation may not be exactly like that. Since 2.20


=end pod

#TE:0:GFileCreateFlags:
enum GFileCreateFlags is export (
  'G_FILE_CREATE_NONE'    => 0,
  'G_FILE_CREATE_PRIVATE' => (1 +< 0),
  'G_FILE_CREATE_REPLACE_DESTINATION' => (1 +< 1)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileMeasureFlags

Flags that can be used with C<g_file_measure_disk_usage()>.

Since: 2.38


=item G_FILE_MEASURE_NONE: No flags set.
=item G_FILE_MEASURE_REPORT_ANY_ERROR: Report any error encountered while traversing the directory tree.  Normally errors are only reported for the toplevel file.
=item G_FILE_MEASURE_APPARENT_SIZE: Tally usage based on apparent file sizes.  Normally, the block-size is used, if available, as this is a more accurate representation of disk space used. Compare with `du --apparent-size`.
=item G_FILE_MEASURE_NO_XDEV: Do not cross mount point boundaries. Compare with `du -x`.


=end pod

#TE:0:GFileMeasureFlags:
enum GFileMeasureFlags is export (
  'G_FILE_MEASURE_NONE'                 => 0,
  'G_FILE_MEASURE_REPORT_ANY_ERROR'     => (1 +< 1),
  'G_FILE_MEASURE_APPARENT_SIZE'        => (1 +< 2),
  'G_FILE_MEASURE_NO_XDEV'              => (1 +< 3)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GMountUnmountFlags

Flags used when an unmounting a mount.


=item G_MOUNT_UNMOUNT_NONE: No flags set.
=item G_MOUNT_UNMOUNT_FORCE: Unmount even if there are outstanding file operations on the mount.


=end pod

#TE:0:GMountUnmountFlags:
enum GMountUnmountFlags is export (
  'G_MOUNT_UNMOUNT_NONE'  => 0,
  'G_MOUNT_UNMOUNT_FORCE' => (1 +< 0)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDriveStartStopType

Enumeration describing how a drive can be started/stopped.

Since: 2.22


=item G_DRIVE_START_STOP_TYPE_UNKNOWN: Unknown or drive doesn't support start/stop.
=item G_DRIVE_START_STOP_TYPE_SHUTDOWN: The stop method will physically shut down the drive and e.g. power down the port the drive is attached to.
=item G_DRIVE_START_STOP_TYPE_NETWORK: The start/stop methods are used for connecting/disconnect to the drive over the network.
=item G_DRIVE_START_STOP_TYPE_MULTIDISK: The start/stop methods will assemble/disassemble a virtual drive from several physical drives.
=item G_DRIVE_START_STOP_TYPE_PASSWORD: The start/stop methods will unlock/lock the disk (for example using the ATA SECURITY UNLOCK DEVICE command)


=end pod

#TE:0:GDriveStartStopType:
enum GDriveStartStopType is export (
  'G_DRIVE_START_STOP_TYPE_UNKNOWN',
  'G_DRIVE_START_STOP_TYPE_SHUTDOWN',
  'G_DRIVE_START_STOP_TYPE_NETWORK',
  'G_DRIVE_START_STOP_TYPE_MULTIDISK',
  'G_DRIVE_START_STOP_TYPE_PASSWORD'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileCopyFlags

Flags used when copying or moving files.


=item G_FILE_COPY_NONE: No flags set.
=item G_FILE_COPY_OVERWRITE: Overwrite any existing files
=item G_FILE_COPY_BACKUP: Make a backup of any existing files.
=item G_FILE_COPY_NOFOLLOW_SYMLINKS: Don't follow symlinks.
=item G_FILE_COPY_ALL_METADATA: Copy all file metadata instead of just default set used for copy (see B<GFileInfo>).
=item G_FILE_COPY_NO_FALLBACK_FOR_MOVE: Don't use copy and delete fallback if native move not supported.
=item G_FILE_COPY_TARGET_DEFAULT_PERMS: Leaves target file with default perms, instead of setting the source file perms.


=end pod

#TE:0:GFileCopyFlags:
enum GFileCopyFlags is export (
  'G_FILE_COPY_OVERWRITE'            => (1 +< 0),
  'G_FILE_COPY_BACKUP'               => (1 +< 1),
  'G_FILE_COPY_NOFOLLOW_SYMLINKS'    => (1 +< 2),
  'G_FILE_COPY_ALL_METADATA'         => (1 +< 3),
  'G_FILE_COPY_NO_FALLBACK_FOR_MOVE' => (1 +< 4),
  'G_FILE_COPY_TARGET_DEFAULT_PERMS' => (1 +< 5)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileMonitorFlags

Flags used to set what a B<GFileMonitor> will watch for.


=item G_FILE_MONITOR_NONE: No flags set.
=item G_FILE_MONITOR_WATCH_MOUNTS: Watch for mount events.
=item G_FILE_MONITOR_SEND_MOVED: Pair DELETED and CREATED events caused by file renames (moves) and send a single G_FILE_MONITOR_EVENT_MOVED event instead (NB: not supported on all backends; the default behaviour -without specifying this flag- is to send single DELETED and CREATED events).  Deprecated since 2.46: use C<G_FILE_MONITOR_WATCH_MOVES> instead.
=item G_FILE_MONITOR_WATCH_HARD_LINKS: Watch for changes to the file made via another hard link. Since 2.36.
=item G_FILE_MONITOR_WATCH_MOVES: Watch for rename operations on a monitored directory.  This causes C<G_FILE_MONITOR_EVENT_RENAMED>, C<G_FILE_MONITOR_EVENT_MOVED_IN> and C<G_FILE_MONITOR_EVENT_MOVED_OUT> events to be emitted when possible.  Since: 2.46.


=end pod

#TE:0:GFileMonitorFlags:
enum GFileMonitorFlags is export (
  'G_FILE_MONITOR_NONE'             => 0,
  'G_FILE_MONITOR_WATCH_MOUNTS'     => (1 +< 0),
  'G_FILE_MONITOR_SEND_MOVED'       => (1 +< 1),
  'G_FILE_MONITOR_WATCH_HARD_LINKS' => (1 +< 2),
  'G_FILE_MONITOR_WATCH_MOVES'      => (1 +< 3)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileType

Indicates the file's on-disk type.


=item G_FILE_TYPE_UNKNOWN: File's type is unknown.
=item G_FILE_TYPE_REGULAR: File handle represents a regular file.
=item G_FILE_TYPE_DIRECTORY: File handle represents a directory.
=item G_FILE_TYPE_SYMBOLIC_LINK: File handle represents a symbolic link (Unix systems).
=item G_FILE_TYPE_SPECIAL: File is a "special" file, such as a socket, fifo, block device, or character device.
=item G_FILE_TYPE_SHORTCUT: File is a shortcut (Windows systems).
=item G_FILE_TYPE_MOUNTABLE: File is a mountable location.


=end pod

#TE:0:GFileType:
enum GFileType is export (
  'G_FILE_TYPE_UNKNOWN' => 0,
  'G_FILE_TYPE_REGULAR',
  'G_FILE_TYPE_DIRECTORY',
  'G_FILE_TYPE_SYMBOLIC_LINK',
  'G_FILE_TYPE_SHORTCUT',
  'G_FILE_TYPE_MOUNTABLE'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFilesystemPreviewType

Indicates a hint from the file system whether files should be
previewed in a file manager. Returned as the value of the key
B<G_FILE_ATTRIBUTE_FILESYSTEM_USE_PREVIEW>.


=item G_FILESYSTEM_PREVIEW_TYPE_IF_ALWAYS: Only preview files if user has explicitly requested it.
=item G_FILESYSTEM_PREVIEW_TYPE_IF_LOCAL: Preview files if user has requested preview of "local" files.
=item G_FILESYSTEM_PREVIEW_TYPE_NEVER: Never preview files.


=end pod

#TE:0:GFilesystemPreviewType:
enum GFilesystemPreviewType is export (
  'G_FILESYSTEM_PREVIEW_TYPE_IF_ALWAYS' => 0,
  'G_FILESYSTEM_PREVIEW_TYPE_IF_LOCAL',
  'G_FILESYSTEM_PREVIEW_TYPE_NEVER'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GFileMonitorEvent

Specifies what type of event a monitor event is.


=item G_FILE_MONITOR_EVENT_CHANGED: a file changed.
=item G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT: a hint that this was probably the last change in a set of changes.
=item G_FILE_MONITOR_EVENT_DELETED: a file was deleted.
=item G_FILE_MONITOR_EVENT_CREATED: a file was created.
=item G_FILE_MONITOR_EVENT_ATTRIBUTE_CHANGED: a file attribute was changed.
=item G_FILE_MONITOR_EVENT_PRE_UNMOUNT: the file location will soon be unmounted.
=item G_FILE_MONITOR_EVENT_UNMOUNTED: the file location was unmounted.
=item G_FILE_MONITOR_EVENT_MOVED: the file was moved -- only sent if the (deprecated) C<G_FILE_MONITOR_SEND_MOVED> flag is set
=item G_FILE_MONITOR_EVENT_RENAMED: the file was renamed within the current directory -- only sent if the C<G_FILE_MONITOR_WATCH_MOVES> flag is set.  Since: 2.46.
=item G_FILE_MONITOR_EVENT_MOVED_IN: the file was moved into the monitored directory from another location -- only sent if the C<G_FILE_MONITOR_WATCH_MOVES> flag is set.  Since: 2.46.
=item G_FILE_MONITOR_EVENT_MOVED_OUT: the file was moved out of the monitored directory to another location -- only sent if the C<G_FILE_MONITOR_WATCH_MOVES> flag is set.  Since: 2.46


=end pod

#TE:0:GFileMonitorEvent:
enum GFileMonitorEvent is export (
  'G_FILE_MONITOR_EVENT_CHANGED',
  'G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT',
  'G_FILE_MONITOR_EVENT_DELETED',
  'G_FILE_MONITOR_EVENT_CREATED',
  'G_FILE_MONITOR_EVENT_ATTRIBUTE_CHANGED',
  'G_FILE_MONITOR_EVENT_PRE_UNMOUNT',
  'G_FILE_MONITOR_EVENT_UNMOUNTED',
  'G_FILE_MONITOR_EVENT_MOVED',
  'G_FILE_MONITOR_EVENT_RENAMED',
  'G_FILE_MONITOR_EVENT_MOVED_IN',
  'G_FILE_MONITOR_EVENT_MOVED_OUT'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GIOErrorEnum

Error codes returned by GIO functions.

Note that this domain may be extended in future GLib releases. In
general, new error codes either only apply to new APIs, or else
replace C<G_IO_ERROR_FAILED> in cases that were not explicitly
distinguished before. You should therefore avoid writing code like
|[<!-- language="C" -->
if (g_error_matches (error, G_IO_ERROR, G_IO_ERROR_FAILED))
{
// Assume that this is EPRINTERONFIRE
...
}
]|
but should instead treat all unrecognized error codes the same as
B<G_IO_ERROR_FAILED>.


=item G_IO_ERROR_FAILED: Generic error condition for when an operation fails and no more specific B<GIOErrorEnum> value is defined.
=item G_IO_ERROR_NOT_FOUND: File not found.
=item G_IO_ERROR_EXISTS: File already exists.
=item G_IO_ERROR_IS_DIRECTORY: File is a directory.
=item G_IO_ERROR_NOT_DIRECTORY: File is not a directory.
=item G_IO_ERROR_NOT_EMPTY: File is a directory that isn't empty.
=item G_IO_ERROR_NOT_REGULAR_FILE: File is not a regular file.
=item G_IO_ERROR_NOT_SYMBOLIC_LINK: File is not a symbolic link.
=item G_IO_ERROR_NOT_MOUNTABLE_FILE: File cannot be mounted.
=item G_IO_ERROR_FILENAME_TOO_LONG: Filename is too many characters.
=item G_IO_ERROR_INVALID_FILENAME: Filename is invalid or contains invalid characters.
=item G_IO_ERROR_TOO_MANY_LINKS: File contains too many symbolic links.
=item G_IO_ERROR_NO_SPACE: No space left on drive.
=item G_IO_ERROR_INVALID_ARGUMENT: Invalid argument.
=item G_IO_ERROR_PERMISSION_DENIED: Permission denied.
=item G_IO_ERROR_NOT_SUPPORTED: Operation (or one of its parameters) not supported
=item G_IO_ERROR_NOT_MOUNTED: File isn't mounted.
=item G_IO_ERROR_ALREADY_MOUNTED: File is already mounted.
=item G_IO_ERROR_CLOSED: File was closed.
=item G_IO_ERROR_CANCELLED: Operation was cancelled. See B<GCancellable>.
=item G_IO_ERROR_PENDING: Operations are still pending.
=item G_IO_ERROR_READ_ONLY: File is read only.
=item G_IO_ERROR_CANT_CREATE_BACKUP: Backup couldn't be created.
=item G_IO_ERROR_WRONG_ETAG: File's Entity Tag was incorrect.
=item G_IO_ERROR_TIMED_OUT: Operation timed out.
=item G_IO_ERROR_WOULD_RECURSE: Operation would be recursive.
=item G_IO_ERROR_BUSY: File is busy.
=item G_IO_ERROR_WOULD_BLOCK: Operation would block.
=item G_IO_ERROR_HOST_NOT_FOUND: Host couldn't be found (remote operations).
=item G_IO_ERROR_WOULD_MERGE: Operation would merge files.
=item G_IO_ERROR_FAILED_HANDLED: Operation failed and a helper program has already interacted with the user. Do not display any error dialog.
=item G_IO_ERROR_TOO_MANY_OPEN_FILES: The current process has too many files open and can't open any more. Duplicate descriptors do count toward this limit. Since 2.20
=item G_IO_ERROR_NOT_INITIALIZED: The object has not been initialized. Since 2.22
=item G_IO_ERROR_ADDRESS_IN_USE: The requested address is already in use. Since 2.22
=item G_IO_ERROR_PARTIAL_INPUT: Need more input to finish operation. Since 2.24
=item G_IO_ERROR_INVALID_DATA: The input data was invalid. Since 2.24
=item G_IO_ERROR_DBUS_ERROR: A remote object generated an error that doesn't correspond to a locally registered B<GError> error domain. Use C<g_dbus_error_get_remote_error()> to extract the D-Bus error name and C<g_dbus_error_strip_remote_error()> to fix up the message so it matches what was received on the wire. Since 2.26.
=item G_IO_ERROR_HOST_UNREACHABLE: Host unreachable. Since 2.26
=item G_IO_ERROR_NETWORK_UNREACHABLE: Network unreachable. Since 2.26
=item G_IO_ERROR_CONNECTION_REFUSED: Connection refused. Since 2.26
=item G_IO_ERROR_PROXY_FAILED: Connection to proxy server failed. Since 2.26
=item G_IO_ERROR_PROXY_AUTH_FAILED: Proxy authentication failed. Since 2.26
=item G_IO_ERROR_PROXY_NEED_AUTH: Proxy server needs authentication. Since 2.26
=item G_IO_ERROR_PROXY_NOT_ALLOWED: Proxy connection is not allowed by ruleset. Since 2.26
=item G_IO_ERROR_BROKEN_PIPE: Broken pipe. Since 2.36
=item G_IO_ERROR_CONNECTION_CLOSED: Connection closed by peer. Note that this is the same code as C<G_IO_ERROR_BROKEN_PIPE>; before 2.44 some "connection closed" errors returned C<G_IO_ERROR_BROKEN_PIPE>, but others returned C<G_IO_ERROR_FAILED>. Now they should all return the same value, which has this more logical name. Since 2.44.
=item G_IO_ERROR_NOT_CONNECTED: Transport endpoint is not connected. Since 2.44
=item G_IO_ERROR_MESSAGE_TOO_LARGE: Message too large. Since 2.48.


=end pod

#TE:0:GIOErrorEnum:
enum GIOErrorEnum is export (
  'G_IO_ERROR_FAILED',
  'G_IO_ERROR_NOT_FOUND',
  'G_IO_ERROR_EXISTS',
  'G_IO_ERROR_IS_DIRECTORY',
  'G_IO_ERROR_NOT_DIRECTORY',
  'G_IO_ERROR_NOT_EMPTY',
  'G_IO_ERROR_NOT_REGULAR_FILE',
  'G_IO_ERROR_NOT_SYMBOLIC_LINK',
  'G_IO_ERROR_NOT_MOUNTABLE_FILE',
  'G_IO_ERROR_FILENAME_TOO_LONG',
  'G_IO_ERROR_INVALID_FILENAME',
  'G_IO_ERROR_TOO_MANY_LINKS',
  'G_IO_ERROR_NO_SPACE',
  'G_IO_ERROR_INVALID_ARGUMENT',
  'G_IO_ERROR_PERMISSION_DENIED',
  'G_IO_ERROR_NOT_SUPPORTED',
  'G_IO_ERROR_NOT_MOUNTED',
  'G_IO_ERROR_ALREADY_MOUNTED',
  'G_IO_ERROR_CLOSED',
  'G_IO_ERROR_CANCELLED',
  'G_IO_ERROR_PENDING',
  'G_IO_ERROR_READ_ONLY',
  'G_IO_ERROR_CANT_CREATE_BACKUP',
  'G_IO_ERROR_WRONG_ETAG',
  'G_IO_ERROR_TIMED_OUT',
  'G_IO_ERROR_WOULD_RECURSE',
  'G_IO_ERROR_BUSY',
  'G_IO_ERROR_WOULD_BLOCK',
  'G_IO_ERROR_HOST_NOT_FOUND',
  'G_IO_ERROR_WOULD_MERGE',
  'G_IO_ERROR_FAILED_HANDLED',
  'G_IO_ERROR_TOO_MANY_OPEN_FILES',
  'G_IO_ERROR_NOT_INITIALIZED',
  'G_IO_ERROR_ADDRESS_IN_USE',
  'G_IO_ERROR_PARTIAL_INPUT',
  'G_IO_ERROR_INVALID_DATA',
  'G_IO_ERROR_DBUS_ERROR',
  'G_IO_ERROR_HOST_UNREACHABLE',
  'G_IO_ERROR_NETWORK_UNREACHABLE',
  'G_IO_ERROR_CONNECTION_REFUSED',
  'G_IO_ERROR_PROXY_FAILED',
  'G_IO_ERROR_PROXY_AUTH_FAILED',
  'G_IO_ERROR_PROXY_NEED_AUTH',
  'G_IO_ERROR_PROXY_NOT_ALLOWED',
  'G_IO_ERROR_BROKEN_PIPE',
  'G_IO_ERROR_CONNECTION_CLOSED' => 44, # G_IO_ERROR_BROKEN_PIPE,
  'G_IO_ERROR_NOT_CONNECTED',
  'G_IO_ERROR_MESSAGE_TOO_LARGE'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GAskPasswordFlags

B<GAskPasswordFlags> are used to request specific information from the
user, or to notify the user of their choices in an authentication
situation.


=item G_ASK_PASSWORD_NEED_PASSWORD: operation requires a password.
=item G_ASK_PASSWORD_NEED_USERNAME: operation requires a username.
=item G_ASK_PASSWORD_NEED_DOMAIN: operation requires a domain.
=item G_ASK_PASSWORD_SAVING_SUPPORTED: operation supports saving settings.
=item G_ASK_PASSWORD_ANONYMOUS_SUPPORTED: operation supports anonymous users.
=item G_ASK_PASSWORD_TCRYPT: operation takes TCRYPT parameters (Since: 2.58)


=end pod

#TE:0:GAskPasswordFlags:
enum GAskPasswordFlags is export (
  'G_ASK_PASSWORD_NEED_PASSWORD'           => (1 +< 0),
  'G_ASK_PASSWORD_NEED_USERNAME'           => (1 +< 1),
  'G_ASK_PASSWORD_NEED_DOMAIN'             => (1 +< 2),
  'G_ASK_PASSWORD_SAVING_SUPPORTED'        => (1 +< 3),
  'G_ASK_PASSWORD_ANONYMOUS_SUPPORTED'     => (1 +< 4),
  'G_ASK_PASSWORD_TCRYPT'                  => (1 +< 5),
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GPasswordSave

B<GPasswordSave> is used to indicate the lifespan of a saved password.

B<Gvfs> stores passwords in the Gnome keyring when this flag allows it
to, and later retrieves it again from there.


=item G_PASSWORD_SAVE_NEVER: never save a password.
=item G_PASSWORD_SAVE_FOR_SESSION: save a password for the session.
=item G_PASSWORD_SAVE_PERMANENTLY: save a password permanently.


=end pod

#TE:0:GPasswordSave:
enum GPasswordSave is export (
  'G_PASSWORD_SAVE_NEVER',
  'G_PASSWORD_SAVE_FOR_SESSION',
  'G_PASSWORD_SAVE_PERMANENTLY'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GMountOperationResult

B<GMountOperationResult> is returned as a result when a request for
information is send by the mounting operation.


=item G_MOUNT_OPERATION_HANDLED: The request was fulfilled and the user specified data is now available
=item G_MOUNT_OPERATION_ABORTED: The user requested the mount operation to be aborted
=item G_MOUNT_OPERATION_UNHANDLED: The request was unhandled (i.e. not implemented)


=end pod

#TE:0:GMountOperationResult:
enum GMountOperationResult is export (
  'G_MOUNT_OPERATION_HANDLED',
  'G_MOUNT_OPERATION_ABORTED',
  'G_MOUNT_OPERATION_UNHANDLED'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GOutputStreamSpliceFlags

GOutputStreamSpliceFlags determine how streams should be spliced.


=item G_OUTPUT_STREAM_SPLICE_NONE: Do not close either stream.
=item G_OUTPUT_STREAM_SPLICE_CLOSE_SOURCE: Close the source stream after the splice.
=item G_OUTPUT_STREAM_SPLICE_CLOSE_TARGET: Close the target stream after the splice.


=end pod

#TE:0:GOutputStreamSpliceFlags:
enum GOutputStreamSpliceFlags is export (
  'G_OUTPUT_STREAM_SPLICE_NONE'         => 0,
  'G_OUTPUT_STREAM_SPLICE_CLOSE_SOURCE' => (1 +< 0),
  'G_OUTPUT_STREAM_SPLICE_CLOSE_TARGET' => (1 +< 1)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GIOStreamSpliceFlags

GIOStreamSpliceFlags determine how streams should be spliced.

Since: 2.28


=item G_IO_STREAM_SPLICE_NONE: Do not close either stream.
=item G_IO_STREAM_SPLICE_CLOSE_STREAM1: Close the first stream after the splice.
=item G_IO_STREAM_SPLICE_CLOSE_STREAM2: Close the second stream after the splice.
=item G_IO_STREAM_SPLICE_WAIT_FOR_BOTH: Wait for both splice operations to finish before calling the callback.


=end pod

#TE:0:GIOStreamSpliceFlags:
enum GIOStreamSpliceFlags is export (
  'G_IO_STREAM_SPLICE_NONE'          => 0,
  'G_IO_STREAM_SPLICE_CLOSE_STREAM1' => (1 +< 0),
  'G_IO_STREAM_SPLICE_CLOSE_STREAM2' => (1 +< 1),
  'G_IO_STREAM_SPLICE_WAIT_FOR_BOTH' => (1 +< 2)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GEmblemOrigin

GEmblemOrigin is used to add information about the origin of the emblem
to B<GEmblem>.

Since: 2.18


=item G_EMBLEM_ORIGIN_UNKNOWN: Emblem of unknown origin
=item G_EMBLEM_ORIGIN_DEVICE: Emblem adds device-specific information
=item G_EMBLEM_ORIGIN_LIVEMETADATA: Emblem depicts live metadata, such as "readonly"
=item G_EMBLEM_ORIGIN_TAG: Emblem comes from a user-defined tag, e.g. set by nautilus (in the future)


=end pod

#TE:0:GEmblemOrigin:
enum GEmblemOrigin is export (
  'G_EMBLEM_ORIGIN_UNKNOWN',
  'G_EMBLEM_ORIGIN_DEVICE',
  'G_EMBLEM_ORIGIN_LIVEMETADATA',
  'G_EMBLEM_ORIGIN_TAG'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GResolverError

An error code used with C<G_RESOLVER_ERROR> in a B<GError> returned
from a B<GResolver> routine.

Since: 2.22


=item G_RESOLVER_ERROR_NOT_FOUND: the requested name/address/service was not found
=item G_RESOLVER_ERROR_TEMPORARY_FAILURE: the requested information could not be looked up due to a network error or similar problem
=item G_RESOLVER_ERROR_INTERNAL: unknown error


=end pod

#TE:0:GResolverError:
enum GResolverError is export (
  'G_RESOLVER_ERROR_NOT_FOUND',
  'G_RESOLVER_ERROR_TEMPORARY_FAILURE',
  'G_RESOLVER_ERROR_INTERNAL'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GResolverRecordType

The type of record that C<g_resolver_lookup_records()> or
C<g_resolver_lookup_records_async()> should retrieve. The records are returned
as lists of B<GVariant> tuples. Each record type has different values in
the variant tuples returned.

C<G_RESOLVER_RECORD_SRV> records are returned as variants with the signature
'(qqqs)', containing a guint16 with the priority, a guint16 with the
weight, a guint16 with the port, and a string of the hostname.

C<G_RESOLVER_RECORD_MX> records are returned as variants with the signature
'(qs)', representing a guint16 with the preference, and a string containing
the mail exchanger hostname.

C<G_RESOLVER_RECORD_TXT> records are returned as variants with the signature
'(as)', representing an array of the strings in the text record.

C<G_RESOLVER_RECORD_SOA> records are returned as variants with the signature
'(ssuuuuu)', representing a string containing the primary name server, a
string containing the administrator, the serial as a guint32, the refresh
interval as guint32, the retry interval as a guint32, the expire timeout
as a guint32, and the ttl as a guint32.

C<G_RESOLVER_RECORD_NS> records are returned as variants with the signature
'(s)', representing a string of the hostname of the name server.

Since: 2.34


=item G_RESOLVER_RECORD_SRV: lookup DNS SRV records for a domain
=item G_RESOLVER_RECORD_MX: lookup DNS MX records for a domain
=item G_RESOLVER_RECORD_TXT: lookup DNS TXT records for a name
=item G_RESOLVER_RECORD_SOA: lookup DNS SOA records for a zone
=item G_RESOLVER_RECORD_NS: lookup DNS NS records for a domain


=end pod

#TE:0:GResolverRecordType:
enum GResolverRecordType is export (
  'G_RESOLVER_RECORD_SRV' => 1,
  'G_RESOLVER_RECORD_MX',
  'G_RESOLVER_RECORD_TXT',
  'G_RESOLVER_RECORD_SOA',
  'G_RESOLVER_RECORD_NS'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GResourceError

An error code used with C<G_RESOURCE_ERROR> in a B<GError> returned
from a B<GResource> routine.

Since: 2.32


=item G_RESOURCE_ERROR_NOT_FOUND: no file was found at the requested path
=item G_RESOURCE_ERROR_INTERNAL: unknown error


=end pod

#TE:1:GResourceError:
enum GResourceError is export (
  'G_RESOURCE_ERROR_NOT_FOUND',
  'G_RESOURCE_ERROR_INTERNAL'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GResourceFlags

GResourceFlags give information about a particular file inside a resource
bundle.

Since: 2.32


=item G_RESOURCE_FLAGS_NONE: No flags set.
=item G_RESOURCE_FLAGS_COMPRESSED: The file is compressed.


=end pod

#TE:0:GResourceFlags:
enum GResourceFlags is export (
  'G_RESOURCE_FLAGS_NONE'       => 0,
  'G_RESOURCE_FLAGS_COMPRESSED' => (1+<0)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GSocketFamily

The protocol family of a B<GSocketAddress>. (These values are
identical to the system defines C<AF_INET>, C<AF_INET6> and C<AF_UNIX>,
if available.)

Since: 2.22


=item G_SOCKET_FAMILY_INVALID: no address family
=item G_SOCKET_FAMILY_IPV4: the IPv4 family
=item G_SOCKET_FAMILY_IPV6: the IPv6 family
=item G_SOCKET_FAMILY_UNIX: the UNIX domain family


=end pod

#TE:0:GSocketFamily:
enum GSocketFamily is export (
  'G_SOCKET_FAMILY_INVALID',
  'G_SOCKET_FAMILY_UNIX' => 1,  #GLIB_SYSDEF_AF_UNIX,
  'G_SOCKET_FAMILY_IPV4' => 2,  #GLIB_SYSDEF_AF_INET,
  'G_SOCKET_FAMILY_IPV6' => 10, #GLIB_SYSDEF_AF_INET6

# From http://repository.egi.eu/mirrors/EMI/tarball/cvmfsdevel/emi-ui-2.10.4-1_sl6v1/usr/lib64/glib-2.0/include/glibconfig.h

#define GLIB_SYSDEF_AF_UNIX 1
#define GLIB_SYSDEF_AF_INET 2
#define GLIB_SYSDEF_AF_INET6 10
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GSocketType

Flags used when creating a B<GSocket>. Some protocols may not implement
all the socket types.

Since: 2.22


=item G_SOCKET_TYPE_INVALID: Type unknown or wrong
=item G_SOCKET_TYPE_STREAM: Reliable connection-based byte streams (e.g. TCP).
=item G_SOCKET_TYPE_DATAGRAM: Connectionless, unreliable datagram passing. (e.g. UDP)
=item G_SOCKET_TYPE_SEQPACKET: Reliable connection-based passing of datagrams of fixed maximum length (e.g. SCTP).


=end pod

#TE:0:GSocketType:
enum GSocketType is export (
  'G_SOCKET_TYPE_INVALID',
  'G_SOCKET_TYPE_STREAM',
  'G_SOCKET_TYPE_DATAGRAM',
  'G_SOCKET_TYPE_SEQPACKET'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GSocketProtocol

A protocol identifier is specified when creating a B<GSocket>, which is a
family/type specific identifier, where 0 means the default protocol for
the particular family/type.

This enum contains a set of commonly available and used protocols. You
can also pass any other identifiers handled by the platform in order to
use protocols not listed here.

Since: 2.22


=item G_SOCKET_PROTOCOL_UNKNOWN: The protocol type is unknown
=item G_SOCKET_PROTOCOL_DEFAULT: The default protocol for the family/type
=item G_SOCKET_PROTOCOL_TCP: TCP over IP
=item G_SOCKET_PROTOCOL_UDP: UDP over IP
=item G_SOCKET_PROTOCOL_SCTP: SCTP over IP


=end pod

#TE:0:GSocketProtocol:
enum GSocketProtocol is export (
  'G_SOCKET_PROTOCOL_UNKNOWN' => -1,
  'G_SOCKET_PROTOCOL_DEFAULT' => 0,
  'G_SOCKET_PROTOCOL_TCP'     => 6,
  'G_SOCKET_PROTOCOL_UDP'     => 17,
  'G_SOCKET_PROTOCOL_SCTP'    => 132
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GZlibCompressorFormat

Used to select the type of data format to use for B<GZlibDecompressor>
and B<GZlibCompressor>.

Since: 2.24


=item G_ZLIB_COMPRESSOR_FORMAT_ZLIB: deflate compression with zlib header
=item G_ZLIB_COMPRESSOR_FORMAT_GZIP: gzip file format
=item G_ZLIB_COMPRESSOR_FORMAT_RAW: deflate compression with no header


=end pod

#TE:0:GZlibCompressorFormat:
enum GZlibCompressorFormat is export (
  'G_ZLIB_COMPRESSOR_FORMAT_ZLIB',
  'G_ZLIB_COMPRESSOR_FORMAT_GZIP',
  'G_ZLIB_COMPRESSOR_FORMAT_RAW'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GUnixSocketAddressType

The type of name used by a B<GUnixSocketAddress>.
C<G_UNIX_SOCKET_ADDRESS_PATH> indicates a traditional unix domain
socket bound to a filesystem path. C<G_UNIX_SOCKET_ADDRESS_ANONYMOUS>
indicates a socket not bound to any name (eg, a client-side socket,
or a socket created with C<socketpair()>).

For abstract sockets, there are two incompatible ways of naming
them; the man pages suggest using the entire `struct sockaddr_un`
as the name, padding the unused parts of the C<sun_path> field with
zeroes; this corresponds to C<G_UNIX_SOCKET_ADDRESS_ABSTRACT_PADDED>.
However, many programs instead just use a portion of C<sun_path>, and
pass an appropriate smaller length to C<bind()> or C<connect()>. This is
C<G_UNIX_SOCKET_ADDRESS_ABSTRACT>.

Since: 2.26


=item G_UNIX_SOCKET_ADDRESS_INVALID: invalid
=item G_UNIX_SOCKET_ADDRESS_ANONYMOUS: anonymous
=item G_UNIX_SOCKET_ADDRESS_PATH: a filesystem path
=item G_UNIX_SOCKET_ADDRESS_ABSTRACT: an abstract name
=item G_UNIX_SOCKET_ADDRESS_ABSTRACT_PADDED: an abstract name, 0-padded to the full length of a unix socket name


=end pod

#TE:0:GUnixSocketAddressType:
enum GUnixSocketAddressType is export (
  'G_UNIX_SOCKET_ADDRESS_INVALID',
  'G_UNIX_SOCKET_ADDRESS_ANONYMOUS',
  'G_UNIX_SOCKET_ADDRESS_PATH',
  'G_UNIX_SOCKET_ADDRESS_ABSTRACT',
  'G_UNIX_SOCKET_ADDRESS_ABSTRACT_PADDED'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GBusType

An enumeration for well-known message buses.

Since: 2.26


=item G_BUS_TYPE_STARTER: An alias for the message bus that activated the process, if any.
=item G_BUS_TYPE_NONE: Not a message bus.
=item G_BUS_TYPE_SYSTEM: The system-wide message bus.
=item G_BUS_TYPE_SESSION: The login session message bus.


=end pod

#TE:0:GBusType:
enum GBusType is export (
  'G_BUS_TYPE_STARTER' => -1,
  'G_BUS_TYPE_NONE' => 0,
  'G_BUS_TYPE_SYSTEM'  => 1,
  'G_BUS_TYPE_SESSION' => 2
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GBusNameOwnerFlags

Flags used in C<g_bus_own_name()>.

Since: 2.26


=item G_BUS_NAME_OWNER_FLAGS_NONE: No flags set.
=item G_BUS_NAME_OWNER_FLAGS_ALLOW_REPLACEMENT: Allow another message bus connection to claim the name.
=item G_BUS_NAME_OWNER_FLAGS_REPLACE: If another message bus connection owns the name and have specified B<G_BUS_NAME_OWNER_FLAGS_ALLOW_REPLACEMENT>, then take the name from the other connection.
=item G_BUS_NAME_OWNER_FLAGS_DO_NOT_QUEUE: If another message bus connection owns the name, immediately return an error from C<g_bus_own_name()> rather than entering the waiting queue for that name. (Since 2.54)


=end pod

#TE:0:GBusNameOwnerFlags:
enum GBusNameOwnerFlags is export (
  'G_BUS_NAME_OWNER_FLAGS_DO_NOT_QUEUE' => (1+<2)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GBusNameWatcherFlags

Flags used in C<g_bus_watch_name()>.

Since: 2.26


=item G_BUS_NAME_WATCHER_FLAGS_NONE: No flags set.
=item G_BUS_NAME_WATCHER_FLAGS_AUTO_START: If no-one owns the name when beginning to watch the name, ask the bus to launch an owner for the name.


=end pod

#TE:0:GBusNameWatcherFlags:
enum GBusNameWatcherFlags is export (
  'G_BUS_NAME_WATCHER_FLAGS_NONE' => 0,
  'G_BUS_NAME_WATCHER_FLAGS_AUTO_START' => (1+<0)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusProxyFlags

Flags used when constructing an instance of a B<GDBusProxy> derived class.

Since: 2.26


=item G_DBUS_PROXY_FLAGS_NONE: No flags set.
=item G_DBUS_PROXY_FLAGS_DO_NOT_LOAD_PROPERTIES: Don't load properties.
=item G_DBUS_PROXY_FLAGS_DO_NOT_CONNECT_SIGNALS: Don't connect to signals on the remote object.
=item G_DBUS_PROXY_FLAGS_DO_NOT_AUTO_START: If the proxy is for a well-known name, do not ask the bus to launch an owner during proxy initialization or a method call. This flag is only meaningful in proxies for well-known names.
=item G_DBUS_PROXY_FLAGS_GET_INVALIDATED_PROPERTIES: If set, the property value for any __invalidated property__ will be (asynchronously) retrieved upon receiving the [`PropertiesChanged`](http://dbus.freedesktop.org/doc/dbus-specification.htmlB<standard>-interfaces-properties) D-Bus signal and the property will not cause emission of the  I<g-properties-changed> signal. When the value is received the  I<g-properties-changed> signal is emitted for the property along with the retrieved value. Since 2.32.
=item G_DBUS_PROXY_FLAGS_DO_NOT_AUTO_START_AT_CONSTRUCTION: If the proxy is for a well-known name, do not ask the bus to launch an owner during proxy initialization, but allow it to be autostarted by a method call. This flag is only meaningful in proxies for well-known names, and only if C<G_DBUS_PROXY_FLAGS_DO_NOT_AUTO_START> is not also specified.


=end pod

#TE:0:GDBusProxyFlags:
enum GDBusProxyFlags is export (
  'G_DBUS_PROXY_FLAGS_NONE' => 0,
  'G_DBUS_PROXY_FLAGS_DO_NOT_LOAD_PROPERTIES' => (1+<0),
  'G_DBUS_PROXY_FLAGS_DO_NOT_CONNECT_SIGNALS' => (1+<1),
  'G_DBUS_PROXY_FLAGS_DO_NOT_AUTO_START' => (1+<2),
  'G_DBUS_PROXY_FLAGS_GET_INVALIDATED_PROPERTIES' => (1+<3),
  'G_DBUS_PROXY_FLAGS_DO_NOT_AUTO_START_AT_CONSTRUCTION' => (1+<4)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusError

Error codes for the C<G_DBUS_ERROR> error domain.

Since: 2.26


=item G_DBUS_ERROR_FAILED: A generic error; "something went wrong" - see the error message for more.
=item G_DBUS_ERROR_NO_MEMORY: There was not enough memory to complete an operation.
=item G_DBUS_ERROR_SERVICE_UNKNOWN: The bus doesn't know how to launch a service to supply the bus name you wanted.
=item G_DBUS_ERROR_NAME_HAS_NO_OWNER: The bus name you referenced doesn't exist (i.e. no application owns it).
=item G_DBUS_ERROR_NO_REPLY: No reply to a message expecting one, usually means a timeout occurred.
=item G_DBUS_ERROR_IO_ERROR: Something went wrong reading or writing to a socket, for example.
=item G_DBUS_ERROR_BAD_ADDRESS: A D-Bus bus address was malformed.
=item G_DBUS_ERROR_NOT_SUPPORTED: Requested operation isn't supported (like ENOSYS on UNIX).
=item G_DBUS_ERROR_LIMITS_EXCEEDED: Some limited resource is exhausted.
=item G_DBUS_ERROR_ACCESS_DENIED: Security restrictions don't allow doing what you're trying to do.
=item G_DBUS_ERROR_AUTH_FAILED: Authentication didn't work.
=item G_DBUS_ERROR_NO_SERVER: Unable to connect to server (probably caused by ECONNREFUSED on a socket).
=item G_DBUS_ERROR_TIMEOUT: Certain timeout errors, possibly ETIMEDOUT on a socket.  Note that C<G_DBUS_ERROR_NO_REPLY> is used for message reply timeouts. Warning: this is confusingly-named given that C<G_DBUS_ERROR_TIMED_OUT> also exists. We can't fix it for compatibility reasons so just be careful.
=item G_DBUS_ERROR_NO_NETWORK: No network access (probably ENETUNREACH on a socket).
=item G_DBUS_ERROR_ADDRESS_IN_USE: Can't bind a socket since its address is in use (i.e. EADDRINUSE).
=item G_DBUS_ERROR_DISCONNECTED: The connection is disconnected and you're trying to use it.
=item G_DBUS_ERROR_INVALID_ARGS: Invalid arguments passed to a method call.
=item G_DBUS_ERROR_FILE_NOT_FOUND: Missing file.
=item G_DBUS_ERROR_FILE_EXISTS: Existing file and the operation you're using does not silently overwrite.
=item G_DBUS_ERROR_UNKNOWN_METHOD: Method name you invoked isn't known by the object you invoked it on.
=item G_DBUS_ERROR_UNKNOWN_OBJECT: Object you invoked a method on isn't known. Since 2.42
=item G_DBUS_ERROR_UNKNOWN_INTERFACE: Interface you invoked a method on isn't known by the object. Since 2.42
=item G_DBUS_ERROR_UNKNOWN_PROPERTY: Property you tried to access isn't known by the object. Since 2.42
=item G_DBUS_ERROR_PROPERTY_READ_ONLY: Property you tried to set is read-only. Since 2.42
=item G_DBUS_ERROR_TIMED_OUT: Certain timeout errors, e.g. while starting a service. Warning: this is confusingly-named given that C<G_DBUS_ERROR_TIMEOUT> also exists. We can't fix it for compatibility reasons so just be careful.
=item G_DBUS_ERROR_MATCH_RULE_NOT_FOUND: Tried to remove or modify a match rule that didn't exist.
=item G_DBUS_ERROR_MATCH_RULE_INVALID: The match rule isn't syntactically valid.
=item G_DBUS_ERROR_SPAWN_EXEC_FAILED: While starting a new process, the C<exec()> call failed.
=item G_DBUS_ERROR_SPAWN_FORK_FAILED: While starting a new process, the C<fork()> call failed.
=item G_DBUS_ERROR_SPAWN_CHILD_EXITED: While starting a new process, the child exited with a status code.
=item G_DBUS_ERROR_SPAWN_CHILD_SIGNALED: While starting a new process, the child exited on a signal.
=item G_DBUS_ERROR_SPAWN_FAILED: While starting a new process, something went wrong.
=item G_DBUS_ERROR_SPAWN_SETUP_FAILED: We failed to setup the environment correctly.
=item G_DBUS_ERROR_SPAWN_CONFIG_INVALID: We failed to setup the config parser correctly.
=item G_DBUS_ERROR_SPAWN_SERVICE_INVALID: Bus name was not valid.
=item G_DBUS_ERROR_SPAWN_SERVICE_NOT_FOUND: Service file not found in system-services directory.
=item G_DBUS_ERROR_SPAWN_PERMISSIONS_INVALID: Permissions are incorrect on the setuid helper.
=item G_DBUS_ERROR_SPAWN_FILE_INVALID: Service file invalid (Name, User or Exec missing).
=item G_DBUS_ERROR_SPAWN_NO_MEMORY: Tried to get a UNIX process ID and it wasn't available.
=item G_DBUS_ERROR_UNIX_PROCESS_ID_UNKNOWN: Tried to get a UNIX process ID and it wasn't available.
=item G_DBUS_ERROR_INVALID_SIGNATURE: A type signature is not valid.
=item G_DBUS_ERROR_INVALID_FILE_CONTENT: A file contains invalid syntax or is otherwise broken.
=item G_DBUS_ERROR_SELINUX_SECURITY_CONTEXT_UNKNOWN: Asked for SELinux security context and it wasn't available.
=item G_DBUS_ERROR_ADT_AUDIT_DATA_UNKNOWN: Asked for ADT audit data and it wasn't available.
=item G_DBUS_ERROR_OBJECT_PATH_IN_USE: There's already an object with the requested object path.


=end pod

#TE:0:GDBusError:
enum GDBusError is export (
  'G_DBUS_ERROR_PROPERTY_READ_ONLY'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusConnectionFlags

Flags used when creating a new B<GDBusConnection>.

Since: 2.26

=item G_DBUS_CONNECTION_FLAGS_NONE: No flags set.
=item G_DBUS_CONNECTION_FLAGS_AUTHENTICATION_CLIENT: Perform authentication against server.
=item G_DBUS_CONNECTION_FLAGS_AUTHENTICATION_SERVER: Perform authentication against client.
=item G_DBUS_CONNECTION_FLAGS_AUTHENTICATION_ALLOW_ANONYMOUS: When authenticating as a server, allow the anonymous authentication method.
=item G_DBUS_CONNECTION_FLAGS_MESSAGE_BUS_CONNECTION: Pass this flag if connecting to a peer that is a message bus. This means that the C<Hello()> method will be invoked as part of the connection setup.
=item G_DBUS_CONNECTION_FLAGS_DELAY_MESSAGE_PROCESSING: If set, processing of D-Bus messages is delayed until C<g_dbus_connection_start_message_processing()> is called.


=end pod

#TE:0:GDBusConnectionFlags:
enum GDBusConnectionFlags is export (
  'G_DBUS_CONNECTION_FLAGS_NONE' => 0,
  'G_DBUS_CONNECTION_FLAGS_AUTHENTICATION_CLIENT' => (1+<0),
  'G_DBUS_CONNECTION_FLAGS_AUTHENTICATION_SERVER' => (1+<1),
  'G_DBUS_CONNECTION_FLAGS_AUTHENTICATION_ALLOW_ANONYMOUS' => (1+<2),
  'G_DBUS_CONNECTION_FLAGS_MESSAGE_BUS_CONNECTION' => (1+<3),
  'G_DBUS_CONNECTION_FLAGS_DELAY_MESSAGE_PROCESSING' => (1+<4)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusCapabilityFlags

Capabilities negotiated with the remote peer.

Since: 2.26


=item G_DBUS_CAPABILITY_FLAGS_NONE: No flags set.
=item G_DBUS_CAPABILITY_FLAGS_UNIX_FD_PASSING: The connection supports exchanging UNIX file descriptors with the remote peer.


=end pod

#TE:0:GDBusCapabilityFlags:
enum GDBusCapabilityFlags is export (
  'G_DBUS_CAPABILITY_FLAGS_NONE' => 0,
  'G_DBUS_CAPABILITY_FLAGS_UNIX_FD_PASSING' => (1+<0)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusCallFlags

Flags used in C<g_dbus_connection_call()> and similar APIs.

Since: 2.26


=item G_DBUS_CALL_FLAGS_NONE: No flags set.
=item G_DBUS_CALL_FLAGS_NO_AUTO_START: The bus must not launch an owner for the destination name in response to this method invocation.
=item G_DBUS_CALL_FLAGS_ALLOW_INTERACTIVE_AUTHORIZATION: the caller is prepared to wait for interactive authorization. Since 2.46.


=end pod

#TE:0:GDBusCallFlags:
enum GDBusCallFlags is export (
  'G_DBUS_CALL_FLAGS_NONE' => 0,
  'G_DBUS_CALL_FLAGS_NO_AUTO_START' => (1+<0),
  'G_DBUS_CALL_FLAGS_ALLOW_INTERACTIVE_AUTHORIZATION' => (1+<1)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusMessageType

Message types used in B<GDBusMessage>.

Since: 2.26


=item G_DBUS_MESSAGE_TYPE_INVALID: Message is of invalid type.
=item G_DBUS_MESSAGE_TYPE_METHOD_CALL: Method call.
=item G_DBUS_MESSAGE_TYPE_METHOD_RETURN: Method reply.
=item G_DBUS_MESSAGE_TYPE_ERROR: Error reply.
=item G_DBUS_MESSAGE_TYPE_SIGNAL: Signal emission.


=end pod

#TE:0:GDBusMessageType:
enum GDBusMessageType is export (
  'G_DBUS_MESSAGE_TYPE_INVALID',
  'G_DBUS_MESSAGE_TYPE_METHOD_CALL',
  'G_DBUS_MESSAGE_TYPE_METHOD_RETURN',
  'G_DBUS_MESSAGE_TYPE_ERROR',
  'G_DBUS_MESSAGE_TYPE_SIGNAL'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusMessageFlags

Message flags used in B<GDBusMessage>.

Since: 2.26


=item G_DBUS_MESSAGE_FLAGS_NONE: No flags set.
=item G_DBUS_MESSAGE_FLAGS_NO_REPLY_EXPECTED: A reply is not expected.
=item G_DBUS_MESSAGE_FLAGS_NO_AUTO_START: The bus must not launch an owner for the destination name in response to this message.
=item G_DBUS_MESSAGE_FLAGS_ALLOW_INTERACTIVE_AUTHORIZATION: If set on a method call, this flag means that the caller is prepared to wait for interactive authorization. Since 2.46.


=end pod

#TE:0:GDBusMessageFlags:
enum GDBusMessageFlags is export (
  'G_DBUS_MESSAGE_FLAGS_NONE' => 0,
  'G_DBUS_MESSAGE_FLAGS_NO_REPLY_EXPECTED' => (1+<0),
  'G_DBUS_MESSAGE_FLAGS_NO_AUTO_START' => (1+<1),
  'G_DBUS_MESSAGE_FLAGS_ALLOW_INTERACTIVE_AUTHORIZATION' => (1+<2)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusMessageHeaderField

Header fields used in B<GDBusMessage>.

Since: 2.26


=item G_DBUS_MESSAGE_HEADER_FIELD_INVALID: Not a valid header field.
=item G_DBUS_MESSAGE_HEADER_FIELD_PATH: The object path.
=item G_DBUS_MESSAGE_HEADER_FIELD_INTERFACE: The interface name.
=item G_DBUS_MESSAGE_HEADER_FIELD_MEMBER: The method or signal name.
=item G_DBUS_MESSAGE_HEADER_FIELD_ERROR_NAME: The name of the error that occurred.
=item G_DBUS_MESSAGE_HEADER_FIELD_REPLY_SERIAL: The serial number the message is a reply to.
=item G_DBUS_MESSAGE_HEADER_FIELD_DESTINATION: The name the message is intended for.
=item G_DBUS_MESSAGE_HEADER_FIELD_SENDER: Unique name of the sender of the message (filled in by the bus).
=item G_DBUS_MESSAGE_HEADER_FIELD_SIGNATURE: The signature of the message body.
=item G_DBUS_MESSAGE_HEADER_FIELD_NUM_UNIX_FDS: The number of UNIX file descriptors that accompany the message.


=end pod

#TE:0:GDBusMessageHeaderField:
enum GDBusMessageHeaderField is export (
  'G_DBUS_MESSAGE_HEADER_FIELD_INVALID',
  'G_DBUS_MESSAGE_HEADER_FIELD_PATH',
  'G_DBUS_MESSAGE_HEADER_FIELD_INTERFACE',
  'G_DBUS_MESSAGE_HEADER_FIELD_MEMBER',
  'G_DBUS_MESSAGE_HEADER_FIELD_ERROR_NAME',
  'G_DBUS_MESSAGE_HEADER_FIELD_REPLY_SERIAL',
  'G_DBUS_MESSAGE_HEADER_FIELD_DESTINATION',
  'G_DBUS_MESSAGE_HEADER_FIELD_SENDER',
  'G_DBUS_MESSAGE_HEADER_FIELD_SIGNATURE',
  'G_DBUS_MESSAGE_HEADER_FIELD_NUM_UNIX_FDS'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusPropertyInfoFlags

Flags describing the access control of a D-Bus property.

Since: 2.26


=item G_DBUS_PROPERTY_INFO_FLAGS_NONE: No flags set.
=item G_DBUS_PROPERTY_INFO_FLAGS_READABLE: Property is readable.
=item G_DBUS_PROPERTY_INFO_FLAGS_WRITABLE: Property is writable.


=end pod

#TE:0:GDBusPropertyInfoFlags:
enum GDBusPropertyInfoFlags is export (
  'G_DBUS_PROPERTY_INFO_FLAGS_NONE' => 0,
  'G_DBUS_PROPERTY_INFO_FLAGS_READABLE' => (1+<0),
  'G_DBUS_PROPERTY_INFO_FLAGS_WRITABLE' => (1+<1)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusSubtreeFlags

Flags passed to C<g_dbus_connection_register_subtree()>.

Since: 2.26


=item G_DBUS_SUBTREE_FLAGS_NONE: No flags set.
=item G_DBUS_SUBTREE_FLAGS_DISPATCH_TO_UNENUMERATED_NODES: Method calls to objects not in the enumerated range will still be dispatched. This is useful if you want to dynamically spawn objects in the subtree.


=end pod

#TE:0:GDBusSubtreeFlags:
enum GDBusSubtreeFlags is export (
  'G_DBUS_SUBTREE_FLAGS_NONE' => 0,
  'G_DBUS_SUBTREE_FLAGS_DISPATCH_TO_UNENUMERATED_NODES' => (1+<0)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusServerFlags

Flags used when creating a B<GDBusServer>.

Since: 2.26


=item G_DBUS_SERVER_FLAGS_NONE: No flags set.
=item G_DBUS_SERVER_FLAGS_RUN_IN_THREAD: All  I<new-connection> signals will run in separated dedicated threads (see signal for details).
=item G_DBUS_SERVER_FLAGS_AUTHENTICATION_ALLOW_ANONYMOUS: Allow the anonymous authentication method.


=end pod

#TE:0:GDBusServerFlags:
enum GDBusServerFlags is export (
  'G_DBUS_SERVER_FLAGS_NONE' => 0,
  'G_DBUS_SERVER_FLAGS_RUN_IN_THREAD' => (1+<0),
  'G_DBUS_SERVER_FLAGS_AUTHENTICATION_ALLOW_ANONYMOUS' => (1+<1)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusSendMessageFlags

Flags used when sending B<GDBusMessages> on a B<GDBusConnection>.

Since: 2.26


=item G_DBUS_SEND_MESSAGE_FLAGS_NONE: No flags set.
=item G_DBUS_SEND_MESSAGE_FLAGS_PRESERVE_SERIAL: Do not automatically assign a serial number from the B<GDBusConnection> object when sending a message.


=end pod

#TE:0:GDBusSendMessageFlags:
enum GDBusSendMessageFlags is export (
  'G_DBUS_SEND_MESSAGE_FLAGS_NONE' => 0,
  'G_DBUS_SEND_MESSAGE_FLAGS_PRESERVE_SERIAL' => (1+<0)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GCredentialsType

Enumeration describing different kinds of native credential types.

Since: 2.26


=item G_CREDENTIALS_TYPE_INVALID: Indicates an invalid native credential type.
=item G_CREDENTIALS_TYPE_LINUX_UCRED: The native credentials type is a struct ucred.
=item G_CREDENTIALS_TYPE_FREEBSD_CMSGCRED: The native credentials type is a struct cmsgcred.
=item G_CREDENTIALS_TYPE_OPENBSD_SOCKPEERCRED: The native credentials type is a struct sockpeercred. Added in 2.30.
=item G_CREDENTIALS_TYPE_SOLARIS_UCRED: The native credentials type is a ucred_t. Added in 2.40.
=item G_CREDENTIALS_TYPE_NETBSD_UNPCBID: The native credentials type is a struct unpcbid.


=end pod

#TE:0:GCredentialsType:
enum GCredentialsType is export (
  'G_CREDENTIALS_TYPE_INVALID',
  'G_CREDENTIALS_TYPE_LINUX_UCRED',
  'G_CREDENTIALS_TYPE_FREEBSD_CMSGCRED',
  'G_CREDENTIALS_TYPE_OPENBSD_SOCKPEERCRED',
  'G_CREDENTIALS_TYPE_SOLARIS_UCRED',
  'G_CREDENTIALS_TYPE_NETBSD_UNPCBID'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusMessageByteOrder

Enumeration used to describe the byte order of a D-Bus message.

Since: 2.26


=item G_DBUS_MESSAGE_BYTE_ORDER_BIG_ENDIAN: The byte order is big endian.
=item G_DBUS_MESSAGE_BYTE_ORDER_LITTLE_ENDIAN: The byte order is little endian.


=end pod

#TE:0:GDBusMessageByteOrder:
enum GDBusMessageByteOrder is export (
  'G_DBUS_MESSAGE_BYTE_ORDER_BIG_ENDIAN'    => 'B',
  'G_DBUS_MESSAGE_BYTE_ORDER_LITTLE_ENDIAN' => 'l'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GApplicationFlags

Flags used to define the behaviour of a B<GApplication>.

Since: 2.28


=item G_APPLICATION_FLAGS_NONE: Default
=item G_APPLICATION_IS_SERVICE: Run as a service. In this mode, registration fails if the service is already running, and the application will initially wait up to 10 seconds for an initial activation message to arrive.
=item G_APPLICATION_IS_LAUNCHER: Don't try to become the primary instance.
=item G_APPLICATION_HANDLES_OPEN: This application handles opening files (in the primary instance). Note that this flag only affects the default implementation of C<local_command_line()>, and has no effect if C<G_APPLICATION_HANDLES_COMMAND_LINE> is given. See C<g_application_run()> for details.
=item G_APPLICATION_HANDLES_COMMAND_LINE: This application handles command line arguments (in the primary instance). Note that this flag only affect the default implementation of C<local_command_line()>. See C<g_application_run()> for details.
=item G_APPLICATION_SEND_ENVIRONMENT: Send the environment of the launching process to the primary instance. Set this flag if your application is expected to behave differently depending on certain environment variables. For instance, an editor might be expected to use the `GIT_COMMITTER_NAME` environment variable when editing a git commit message. The environment is available to the  I<command-line> signal handler, via C<g_application_command_line_getenv()>.
=item G_APPLICATION_NON_UNIQUE: Make no attempts to do any of the typical single-instance application negotiation, even if the application ID is given.  The application neither attempts to become the owner of the application ID nor does it check if an existing owner already exists.  Everything occurs in the local process. Since: 2.30.
=item G_APPLICATION_CAN_OVERRIDE_APP_ID: Allow users to override the application ID from the command line with `--gapplication-app-id`. Since: 2.48


=end pod

#TE:1:GApplicationFlags:
enum GApplicationFlags is export (
  'G_APPLICATION_FLAGS_NONE',
  'G_APPLICATION_IS_SERVICE'  =>          (1 +< 0),
  'G_APPLICATION_IS_LAUNCHER' =>          (1 +< 1),
  'G_APPLICATION_HANDLES_OPEN' =>         (1 +< 2),
  'G_APPLICATION_HANDLES_COMMAND_LINE' => (1 +< 3),
  'G_APPLICATION_SEND_ENVIRONMENT'    =>  (1 +< 4),
  'G_APPLICATION_NON_UNIQUE' =>           (1 +< 5),
  'G_APPLICATION_CAN_OVERRIDE_APP_ID' =>  (1 +< 6)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GTlsError

An error code used with C<G_TLS_ERROR> in a B<GError> returned from a
TLS-related routine.

Since: 2.28


=item G_TLS_ERROR_UNAVAILABLE: No TLS provider is available
=item G_TLS_ERROR_MISC: Miscellaneous TLS error
=item G_TLS_ERROR_BAD_CERTIFICATE: A certificate could not be parsed
=item G_TLS_ERROR_NOT_TLS: The TLS handshake failed because the peer does not seem to be a TLS server.
=item G_TLS_ERROR_HANDSHAKE: The TLS handshake failed because the peer's certificate was not acceptable.
=item G_TLS_ERROR_CERTIFICATE_REQUIRED: The TLS handshake failed because the server requested a client-side certificate, but none was provided. See C<g_tls_connection_set_certificate()>.
=item G_TLS_ERROR_EOF: The TLS connection was closed without proper notice, which may indicate an attack. See C<g_tls_connection_set_require_close_notify()>.


=end pod

#TE:0:GTlsError:
enum GTlsError is export (
  'G_TLS_ERROR_UNAVAILABLE',
  'G_TLS_ERROR_MISC',
  'G_TLS_ERROR_BAD_CERTIFICATE',
  'G_TLS_ERROR_NOT_TLS',
  'G_TLS_ERROR_HANDSHAKE',
  'G_TLS_ERROR_CERTIFICATE_REQUIRED',
  'G_TLS_ERROR_EOF'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GTlsCertificateFlags

A set of flags describing TLS certification validation. This can be
used to set which validation steps to perform (eg, with
C<g_tls_client_connection_set_validation_flags()>), or to describe why
a particular certificate was rejected (eg, in
 I<accept-certificate>).

Since: 2.28


=item G_TLS_CERTIFICATE_UNKNOWN_CA: The signing certificate authority is not known.
=item G_TLS_CERTIFICATE_BAD_IDENTITY: The certificate does not match the expected identity of the site that it was retrieved from.
=item G_TLS_CERTIFICATE_NOT_ACTIVATED: The certificate's activation time is still in the future
=item G_TLS_CERTIFICATE_EXPIRED: The certificate has expired
=item G_TLS_CERTIFICATE_REVOKED: The certificate has been revoked according to the B<GTlsConnection>'s certificate revocation list.
=item G_TLS_CERTIFICATE_INSECURE: The certificate's algorithm is considered insecure.
=item G_TLS_CERTIFICATE_GENERIC_ERROR: Some other error occurred validating the certificate
=item G_TLS_CERTIFICATE_VALIDATE_ALL: the combination of all of the above flags


=end pod

#TE:0:GTlsCertificateFlags:
enum GTlsCertificateFlags is export (
  'G_TLS_CERTIFICATE_UNKNOWN_CA'    => (1 +< 0),
  'G_TLS_CERTIFICATE_BAD_IDENTITY'  => (1 +< 1),
  'G_TLS_CERTIFICATE_NOT_ACTIVATED' => (1 +< 2),
  'G_TLS_CERTIFICATE_EXPIRED'       => (1 +< 3),
  'G_TLS_CERTIFICATE_REVOKED'       => (1 +< 4),
  'G_TLS_CERTIFICATE_INSECURE'      => (1 +< 5),
  'G_TLS_CERTIFICATE_GENERIC_ERROR' => (1 +< 6),
  'G_TLS_CERTIFICATE_VALIDATE_ALL'  => 0x007f
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GTlsAuthenticationMode

The client authentication mode for a B<GTlsServerConnection>.

Since: 2.28


=item G_TLS_AUTHENTICATION_NONE: client authentication not required
=item G_TLS_AUTHENTICATION_REQUESTED: client authentication is requested
=item G_TLS_AUTHENTICATION_REQUIRED: client authentication is required


=end pod

#TE:0:GTlsAuthenticationMode:
enum GTlsAuthenticationMode is export (
  'G_TLS_AUTHENTICATION_NONE',
  'G_TLS_AUTHENTICATION_REQUESTED',
  'G_TLS_AUTHENTICATION_REQUIRED'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GTlsRehandshakeMode

When to allow rehandshaking. See
C<g_tls_connection_set_rehandshake_mode()>.

Since: 2.28


=item G_TLS_REHANDSHAKE_NEVER: Never allow rehandshaking
=item G_TLS_REHANDSHAKE_SAFELY: Allow safe rehandshaking only
=item G_TLS_REHANDSHAKE_UNSAFELY: Allow unsafe rehandshaking


=end pod

#TE:0:GTlsRehandshakeMode:
enum GTlsRehandshakeMode is export (
  'G_TLS_REHANDSHAKE_NEVER',
  'G_TLS_REHANDSHAKE_SAFELY',
  'G_TLS_REHANDSHAKE_UNSAFELY'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GTlsInteractionResult

B<GTlsInteractionResult> is returned by various functions in B<GTlsInteraction>
when finishing an interaction request.

Since: 2.30


=item G_TLS_INTERACTION_UNHANDLED: The interaction was unhandled (i.e. not implemented).
=item G_TLS_INTERACTION_HANDLED: The interaction completed, and resulting data is available.
=item G_TLS_INTERACTION_FAILED: The interaction has failed, or was cancelled. and the operation should be aborted.


=end pod

#TE:0:GTlsInteractionResult:
enum GTlsInteractionResult is export (
  'G_TLS_INTERACTION_UNHANDLED',
  'G_TLS_INTERACTION_HANDLED',
  'G_TLS_INTERACTION_FAILED'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusInterfaceSkeletonFlags

Flags describing the behavior of a B<GDBusInterfaceSkeleton> instance.

Since: 2.30


=item G_DBUS_INTERFACE_SKELETON_FLAGS_NONE: No flags set.
=item G_DBUS_INTERFACE_SKELETON_FLAGS_HANDLE_METHOD_INVOCATIONS_IN_THREAD: Each method invocation is handled in a thread dedicated to the invocation. This means that the method implementation can use blocking IO without blocking any other part of the process. It also means that the method implementation must use locking to access data structures used by other threads.


=end pod

#TE:0:GDBusInterfaceSkeletonFlags:
enum GDBusInterfaceSkeletonFlags is export (
  'G_DBUS_INTERFACE_SKELETON_FLAGS_NONE' => 0,
  'G_DBUS_INTERFACE_SKELETON_FLAGS_HANDLE_METHOD_INVOCATIONS_IN_THREAD' => (1+<0)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GDBusObjectManagerClientFlags

Flags used when constructing a B<GDBusObjectManagerClient>.

Since: 2.30


=item G_DBUS_OBJECT_MANAGER_CLIENT_FLAGS_NONE: No flags set.
=item G_DBUS_OBJECT_MANAGER_CLIENT_FLAGS_DO_NOT_AUTO_START: If not set and the manager is for a well-known name, then request the bus to launch an owner for the name if no-one owns the name. This flag can only be used in managers for well-known names.


=end pod

#TE:0:GDBusObjectManagerClientFlags:
enum GDBusObjectManagerClientFlags is export (
  'G_DBUS_OBJECT_MANAGER_CLIENT_FLAGS_NONE' => 0,
  'G_DBUS_OBJECT_MANAGER_CLIENT_FLAGS_DO_NOT_AUTO_START' => (1+<0)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GTlsDatabaseLookupFlags

Flags for C<g_tls_database_lookup_certificate_for_handle()>,
C<g_tls_database_lookup_certificate_issuer()>,
and C<g_tls_database_lookup_certificates_issued_by()>.

Since: 2.30


=item G_TLS_DATABASE_LOOKUP_NONE: No lookup flags
=item G_TLS_DATABASE_LOOKUP_KEYPAIR: Restrict lookup to certificates that have a private key.


=end pod

#TE:0:GTlsDatabaseLookupFlags:
enum GTlsDatabaseLookupFlags is export (
  'G_TLS_DATABASE_LOOKUP_NONE' => 0,
  'G_TLS_DATABASE_LOOKUP_KEYPAIR' => 1
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GTlsCertificateRequestFlags

Flags for C<g_tls_interaction_request_certificate()>,
C<g_tls_interaction_request_certificate_async()>, and
C<g_tls_interaction_invoke_request_certificate()>.

Since: 2.40


=item G_TLS_CERTIFICATE_REQUEST_NONE: No flags


=end pod

#TE:0:GTlsCertificateRequestFlags:
enum GTlsCertificateRequestFlags is export (
  'G_TLS_CERTIFICATE_REQUEST_NONE' => 0
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GIOModuleScopeFlags

Flags for use with C<g_io_module_scope_new()>.

Since: 2.30


=item G_IO_MODULE_SCOPE_NONE: No module scan flags
=item G_IO_MODULE_SCOPE_BLOCK_DUPLICATES: When using this scope to load or scan modules, automatically block a modules which has the same base basename as previously loaded module.


=end pod

#TE:0:GIOModuleScopeFlags:
enum GIOModuleScopeFlags is export (
  'G_IO_MODULE_SCOPE_NONE',
  'G_IO_MODULE_SCOPE_BLOCK_DUPLICATES'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GSocketClientEvent

Describes an event occurring on a B<GSocketClient>. See the
 I<event> signal for more details.

Additional values may be added to this type in the future.

Since: 2.32


=item G_SOCKET_CLIENT_RESOLVING: The client is doing a DNS lookup.
=item G_SOCKET_CLIENT_RESOLVED: The client has completed a DNS lookup.
=item G_SOCKET_CLIENT_CONNECTING: The client is connecting to a remote host (either a proxy or the destination server).
=item G_SOCKET_CLIENT_CONNECTED: The client has connected to a remote host.
=item G_SOCKET_CLIENT_PROXY_NEGOTIATING: The client is negotiating with a proxy to connect to the destination server.
=item G_SOCKET_CLIENT_PROXY_NEGOTIATED: The client has negotiated with the proxy server.
=item G_SOCKET_CLIENT_TLS_HANDSHAKING: The client is performing a TLS handshake.
=item G_SOCKET_CLIENT_TLS_HANDSHAKED: The client has performed a TLS handshake.
=item G_SOCKET_CLIENT_COMPLETE: The client is done with a particular B<GSocketConnectable>.


=end pod

#TE:0:GSocketClientEvent:
enum GSocketClientEvent is export (
  'G_SOCKET_CLIENT_RESOLVING',
  'G_SOCKET_CLIENT_RESOLVED',
  'G_SOCKET_CLIENT_CONNECTING',
  'G_SOCKET_CLIENT_CONNECTED',
  'G_SOCKET_CLIENT_PROXY_NEGOTIATING',
  'G_SOCKET_CLIENT_PROXY_NEGOTIATED',
  'G_SOCKET_CLIENT_TLS_HANDSHAKING',
  'G_SOCKET_CLIENT_TLS_HANDSHAKED',
  'G_SOCKET_CLIENT_COMPLETE'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GSocketListenerEvent

Describes an event occurring on a B<GSocketListener>. See the
 I<event> signal for more details.

Additional values may be added to this type in the future.

Since: 2.46


=item G_SOCKET_LISTENER_BINDING: The listener is about to bind a socket.
=item G_SOCKET_LISTENER_BOUND: The listener has bound a socket.
=item G_SOCKET_LISTENER_LISTENING: The listener is about to start listening on this socket.
=item G_SOCKET_LISTENER_LISTENED: The listener is now listening on this socket.


=end pod

#TE:0:GSocketListenerEvent:
enum GSocketListenerEvent is export (
  'G_SOCKET_LISTENER_BINDING',
  'G_SOCKET_LISTENER_BOUND',
  'G_SOCKET_LISTENER_LISTENING',
  'G_SOCKET_LISTENER_LISTENED'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GSubprocessFlags

Flags to define the behaviour of a B<GSubprocess>.

Note that the default for stdin is to redirect from `/dev/null`.  For
stdout and stderr the default are for them to inherit the
corresponding descriptor from the calling process.

Note that it is a programmer error to mix 'incompatible' flags.  For
example, you may not request both C<G_SUBPROCESS_FLAGS_STDOUT_PIPE> and
C<G_SUBPROCESS_FLAGS_STDOUT_SILENCE>.

Since: 2.40


=item G_SUBPROCESS_FLAGS_NONE: No flags.
=item G_SUBPROCESS_FLAGS_STDIN_PIPE: create a pipe for the stdin of the spawned process that can be accessed with C<g_subprocess_get_stdin_pipe()>.
=item G_SUBPROCESS_FLAGS_STDIN_INHERIT: stdin is inherited from the calling process.
=item G_SUBPROCESS_FLAGS_STDOUT_PIPE: create a pipe for the stdout of the spawned process that can be accessed with C<g_subprocess_get_stdout_pipe()>.
=item G_SUBPROCESS_FLAGS_STDOUT_SILENCE: silence the stdout of the spawned process (ie: redirect to `/dev/null`).
=item G_SUBPROCESS_FLAGS_STDERR_PIPE: create a pipe for the stderr of the spawned process that can be accessed with C<g_subprocess_get_stderr_pipe()>.
=item G_SUBPROCESS_FLAGS_STDERR_SILENCE: silence the stderr of the spawned process (ie: redirect to `/dev/null`).
=item G_SUBPROCESS_FLAGS_STDERR_MERGE: merge the stderr of the spawned process with whatever the stdout happens to be.  This is a good way of directing both streams to a common log file, for example.
=item G_SUBPROCESS_FLAGS_INHERIT_FDS: spawned processes will inherit the file descriptors of their parent, unless those descriptors have been explicitly marked as close-on-exec.  This flag has no effect over the "standard" file descriptors (stdin, stdout, stderr).


=end pod

#TE:0:GSubprocessFlags:
enum GSubprocessFlags is export (
  'G_SUBPROCESS_FLAGS_NONE'                  => 0,
  'G_SUBPROCESS_FLAGS_STDIN_PIPE'            => (1 +< 0),
  'G_SUBPROCESS_FLAGS_STDIN_INHERIT'         => (1 +< 1),
  'G_SUBPROCESS_FLAGS_STDOUT_PIPE'           => (1 +< 2),
  'G_SUBPROCESS_FLAGS_STDOUT_SILENCE'        => (1 +< 3),
  'G_SUBPROCESS_FLAGS_STDERR_PIPE'           => (1 +< 4),
  'G_SUBPROCESS_FLAGS_STDERR_SILENCE'        => (1 +< 5),
  'G_SUBPROCESS_FLAGS_STDERR_MERGE'          => (1 +< 6),
  'G_SUBPROCESS_FLAGS_INHERIT_FDS'           => (1 +< 7)
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GNotificationPriority

Priority levels for B<GNotifications>.

=item G_NOTIFICATION_PRIORITY_LOW: for notifications that do not require immediate attention - typically used for contextual background information, such as contact birthdays or local weather
=item G_NOTIFICATION_PRIORITY_NORMAL: the default priority, to be used for the majority of notifications (for example email messages, software updates, completed download/sync operations)
=item G_NOTIFICATION_PRIORITY_HIGH: for events that require more attention, usually because responses are time-sensitive (for example chat and SMS messages or alarms)
=item G_NOTIFICATION_PRIORITY_URGENT: for urgent notifications, or notifications that require a response in a short space of time (for example phone calls or emergency warnings)


=end pod

#TE:1:GNotificationPriority:
enum GNotificationPriority is export (
  'G_NOTIFICATION_PRIORITY_NORMAL',
  'G_NOTIFICATION_PRIORITY_LOW',
  'G_NOTIFICATION_PRIORITY_HIGH',
  'G_NOTIFICATION_PRIORITY_URGENT'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GNetworkConnectivity

The host's network connectivity state, as reported by B<GNetworkMonitor>.

=item G_NETWORK_CONNECTIVITY_LOCAL: The host is not configured with a route to the Internet; it may or may not be connected to a local network.
=item G_NETWORK_CONNECTIVITY_LIMITED: The host is connected to a network, but does not appear to be able to reach the full Internet, perhaps due to upstream network problems.
=item G_NETWORK_CONNECTIVITY_PORTAL: The host is behind a captive portal and cannot reach the full Internet.
=item G_NETWORK_CONNECTIVITY_FULL: The host is connected to a network, and appears to be able to reach the full Internet.


=end pod

#TE:0:GNetworkConnectivity:
enum GNetworkConnectivity is export (
  'G_NETWORK_CONNECTIVITY_LOCAL'       => 1,
  'G_NETWORK_CONNECTIVITY_LIMITED'     => 2,
  'G_NETWORK_CONNECTIVITY_PORTAL'      => 3,
  'G_NETWORK_CONNECTIVITY_FULL'        => 4
);

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GResourceLookupFlags

GResourceLookupFlags determine how resource path lookups are handled.

=item G_RESOURCE_LOOKUP_FLAGS_NONE: No flags set.

=end pod

#TE:1:GResourceLookupFlags:
enum GResourceLookupFlags is export (
  'G_RESOURCE_LOOKUP_FLAGS_NONE',
);
