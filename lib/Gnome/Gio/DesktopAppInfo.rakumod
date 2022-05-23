#TL:1:Gnome::Gio::DesktopAppInfo:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::DesktopAppInfo

Application information from desktop files


=comment ![](images/X.png)


=head1 Description

B<Gnome::Gio::DesktopAppInfo> is an implementation of B<Gnome::Gio::AppInfo> based on desktop files.

Note that this module belongs to the UNIX-specific GIO interfaces.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::DesktopAppInfo;
  also is Gnome::GObject::Object;


=comment head2 Uml Diagram

=comment ![](plantuml/DesktopAppInfo.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::DesktopAppInfo;

  unit class MyGuiClass;
  also is Gnome::Gio::DesktopAppInfo;

  submethod new ( |c ) {
    # let the Gnome::Gio::DesktopAppInfo class process the options
    self.bless( :GDesktopAppInfo, |c);
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

use Gnome::Glib::List;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::DesktopAppInfo:auth<github:MARTIMM>;
also is Gnome::GObject::Object;


#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :desktop-id

Create a new B<Gnome::Gio::DesktopAppInfo> object.

  multi method new ( Str :$desktop-id! )

=item $desktop-id; The name of a desktop entry file. The file must be found in one of the directories set by one of the XDG environment variables. See also L<the freedesktop|https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>.


=head3 :filename

Creates a new B<Gnome::Gio::DesktopAppInfo> using a path to a file.

  multi method new ( Str :$filename! )

=item $filename; The name of a desktop entry file using a full path.

=begin comment
NOTE: not useful, skip forever; the reason to have an opened INI file is because
one would have a use for searching through some of its keys. A desktop entry
file is like an INI file. Raku has good modules to handle INI files if one
needs to search in it.
=head3 :keyfile

Creates a new B<Gnome::Gio::DesktopAppInfo> using a path to a file.

  multi method new ( N-GObject :$keyfile! )

=item $keyfile; a Glib object .
=end comment


=head3 :native-object

Create a DesktopAppInfo object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

# TM:0:new():inheriting
#TM:1:new(:desktop-id):
#TM:1:new(:filename):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::DesktopAppInfo' #`{{ or %options<GDesktopAppInfo> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my N-GObject() $no;
      if ? %options<desktop-id> {
        $no = _g_desktop_app_info_new(%options<desktop-id>);
      }

      elsif ? %options<filename> {
        $no = _g_desktop_app_info_new_from_filename(%options<filename>);
      }

#`{{ NOTE: not useful, skip forever
      elsif ? %options<keyfile> {
        $no = %options<keyfile>;
        $no = _g_desktop_app_info_new_from_keyfile($no);
      }
}}

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
        $no = _g_desktop_app_info_new();
      }
      }}

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GDesktopAppInfo');
  }
}

#-------------------------------------------------------------------------------
#TM:1:get-action-name:
=begin pod
=head2 get-action-name

Gets the user-visible display name of the "additional application action" specified by I<action_name>.

This corresponds to the "Name" key within the keyfile group for the action.

Returns: the locale-specific action name

  method get-action-name ( Str $action_name --> Str )

=item $action_name; the name of the action as from C<list_actions()>
=end pod

method get-action-name ( Str $action_name --> Str ) {
  g_desktop_app_info_get_action_name(
    self._get-native-object-no-reffing, $action_name
  )
}

sub g_desktop_app_info_get_action_name (
  N-GObject $info, gchar-ptr $action_name --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-boolean:
=begin pod
=head2 get-boolean

Looks up a boolean value in the keyfile backing I<info>.

The I<key> is looked up in the "Desktop Entry" group.

Returns: the boolean value, or C<False> if the key is not found

  method get-boolean ( Str $key --> Bool )

=item $key; the key to look up
=end pod

method get-boolean ( Str $key --> Bool ) {
  g_desktop_app_info_get_boolean( self._get-native-object-no-reffing, $key).Bool
}

sub g_desktop_app_info_get_boolean (
  N-GObject $info, gchar-ptr $key --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-categories:
=begin pod
=head2 get-categories

Gets the categories from the desktop file.

Returns: The unparsed Categories key from the desktop file; i.e. no attempt is made to split it by ';' or validate it.

  method get-categories ( --> Str )

=end pod

method get-categories ( --> Str ) {
  g_desktop_app_info_get_categories( self._get-native-object-no-reffing)
}

sub g_desktop_app_info_get_categories (
  N-GObject $info --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-filename:
=begin pod
=head2 get-filename

When I<info> was created from a known filename, return it. In some situations such as the B<Gnome::Gio::DesktopAppInfo> returned from C<new_from_keyfile()>, this function will return C<undefined>.

Returns:  (type filename): The full path to the file for I<info>, or C<undefined> if not known.

  method get-filename ( --> Str )

=end pod

method get-filename ( --> Str ) {
  g_desktop_app_info_get_filename( self._get-native-object-no-reffing)
}

sub g_desktop_app_info_get_filename (
  N-GObject $info --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-generic-name:
=begin pod
=head2 get-generic-name

Gets the generic name from the desktop file.

Returns: The value of the GenericName key

  method get-generic-name ( --> Str )

=end pod

method get-generic-name ( --> Str ) {
  g_desktop_app_info_get_generic_name( self._get-native-object-no-reffing)
}

sub g_desktop_app_info_get_generic_name (
  N-GObject $info --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-implementations:
=begin pod
=head2 get-implementations

Gets all applications that implement I<interface>.

An application implements an interface if that interface is listed in the Implements= line of the desktop file of the application.

Returns: (element-type GDesktopAppInfo) : a list of B<Gnome::Gio::DesktopAppInfo> objects.

  method get-implementations ( Str $interface --> N-GList )

=item $interface; the name of the interface
=end pod

method get-implementations ( Str $interface --> N-GList ) {
  g_desktop_app_info_get_implementations( self._get-native-object-no-reffing, $interface)
}

sub g_desktop_app_info_get_implementations (
  gchar-ptr $interface --> N-GList
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-is-hidden:
=begin pod
=head2 get-is-hidden

A desktop file is hidden if the Hidden key in it is set to True.

Returns: C<True> if hidden, C<False> otherwise.

  method get-is-hidden ( --> Bool )

=end pod

method get-is-hidden ( --> Bool ) {
  g_desktop_app_info_get_is_hidden( self._get-native-object-no-reffing).Bool
}

sub g_desktop_app_info_get_is_hidden (
  N-GObject $info --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-keywords:
=begin pod
=head2 get-keywords

Gets the keywords from the desktop file.

Returns: The value of the Keywords key

  method get-keywords ( --> CArray[Str] )

=end pod

method get-keywords ( --> CArray[Str] ) {
  g_desktop_app_info_get_keywords( self._get-native-object-no-reffing)
}

sub g_desktop_app_info_get_keywords (
  N-GObject $info --> gchar-pptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-locale-string:
=begin pod
=head2 get-locale-string

Looks up a localized string value in the keyfile backing I<info> translated to the current locale.

The I<key> is looked up in the "Desktop Entry" group.

Returns: a newly allocated string, or C<undefined> if the key is not found

  method get-locale-string ( Str $key --> Str )

=item $key; the key to look up
=end pod

method get-locale-string ( Str $key --> Str ) {
  g_desktop_app_info_get_locale_string( self._get-native-object-no-reffing, $key)
}

sub g_desktop_app_info_get_locale_string (
  N-GObject $info, gchar-ptr $key --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-nodisplay:
=begin pod
=head2 get-nodisplay

Gets the value of the NoDisplay key, which helps determine if the application info should be shown in menus. See C<G_KEY_FILE_DESKTOP_KEY_NO_DISPLAY> and C<g_app_info_should_show()>.

Returns: The value of the NoDisplay key

  method get-nodisplay ( --> Bool )

=end pod

method get-nodisplay ( --> Bool ) {
  g_desktop_app_info_get_nodisplay( self._get-native-object-no-reffing).Bool
}

sub g_desktop_app_info_get_nodisplay (
  N-GObject $info --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-show-in:
=begin pod
=head2 get-show-in

Checks if the application info should be shown in menus that list available applications for a specific name of the desktop, based on the `OnlyShowIn` and `NotShowIn` keys.

I<desktop_env> should typically be given as C<undefined>, in which case the `XDG_CURRENT_DESKTOP` environment variable is consulted. If you want to override the default mechanism then you may specify I<desktop_env>, but this is not recommended.

Note that C<g_app_info_should_show()> for I<info> will include this check (with C<undefined> for I<desktop_env>) as well as additional checks.

Returns: C<True> if the I<info> should be shown in I<desktop_env> according to the `OnlyShowIn` and `NotShowIn` keys, C<False> otherwise.

  method get-show-in ( Str $desktop_env --> Bool )

=item $desktop_env; a string specifying a desktop name
=end pod

method get-show-in ( Str $desktop_env --> Bool ) {
  g_desktop_app_info_get_show_in( self._get-native-object-no-reffing, $desktop_env).Bool
}

sub g_desktop_app_info_get_show_in (
  N-GObject $info, gchar-ptr $desktop_env --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-startup-wm-class:
=begin pod
=head2 get-startup-wm-class

Retrieves the StartupWMClass field from I<info>. This represents the WM_CLASS property of the main window of the application, if launched through I<info>.

Returns: the startup WM class, or C<undefined> if none is set in the desktop file.

  method get-startup-wm-class ( --> Str )

=end pod

method get-startup-wm-class ( --> Str ) {
  g_desktop_app_info_get_startup_wm_class( self._get-native-object-no-reffing)
}

sub g_desktop_app_info_get_startup_wm_class (
  N-GObject $info --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-string:
=begin pod
=head2 get-string

Looks up a string value in the keyfile backing I<info>.

The I<key> is looked up in the "Desktop Entry" group.

Returns: a newly allocated string, or C<undefined> if the key is not found

  method get-string ( Str $key --> Str )

=item $key; the key to look up
=end pod

method get-string ( Str $key --> Str ) {
  g_desktop_app_info_get_string( self._get-native-object-no-reffing, $key)
}

sub g_desktop_app_info_get_string (
  N-GObject $info, gchar-ptr $key --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-string-list:
=begin pod
=head2 get-string-list

Looks up a string list value in the keyfile backing I<info>.

The I<key> is looked up in the "Desktop Entry" group.

Returns: (array zero-terminated=1 length=length) (element-type utf8) : a C<undefined>-terminated string array or C<undefined> if the specified key cannot be found. The array should be freed with C<g_strfreev()>.

  method get-string-list ( Str $key, UInt $length --> CArray[Str] )

=item $key; the key to look up
=item $length; return location for the number of returned strings, or C<undefined>
=end pod

method get-string-list ( Str $key, UInt $length --> CArray[Str] ) {
  g_desktop_app_info_get_string_list( self._get-native-object-no-reffing, $key, $length)
}

sub g_desktop_app_info_get_string_list (
  N-GObject $info, gchar-ptr $key, gsize $length --> gchar-pptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:has-key:
=begin pod
=head2 has-key

Returns whether I<key> exists in the "Desktop Entry" group of the keyfile backing I<info>.

Returns: C<True> if the I<key> exists

  method has-key ( Str $key --> Bool )

=item $key; the key to look up
=end pod

method has-key ( Str $key --> Bool ) {
  g_desktop_app_info_has_key( self._get-native-object-no-reffing, $key).Bool
}

sub g_desktop_app_info_has_key (
  N-GObject $info, gchar-ptr $key --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:launch-action:
=begin pod
=head2 launch-action

Activates the named application action.

You may only call this function on action names that were returned from C<list_actions()>.

Note that if the main entry of the desktop file indicates that the application supports startup notification, and I<launch_context> is non-C<undefined>, then startup notification will be used when activating the action (and as such, invocation of the action on the receiving side must signal the end of startup notification when it is completed). This is the expected behaviour of applications declaring additional actions, as per the desktop file specification.

As with C<g_app_info_launch()> there is no way to detect failures that occur while using this function.

  method launch-action ( Str $action_name, N-GObject $launch_context )

=item $action_name; the name of the action as from C<list_actions()>
=item $launch_context; a B<Gnome::Gio::AppLaunchContext>
=end pod

method launch-action ( Str $action_name, N-GObject $launch_context ) {
  g_desktop_app_info_launch_action( self._get-native-object-no-reffing, $action_name, $launch_context);
}

sub g_desktop_app_info_launch_action (
  N-GObject $info, gchar-ptr $action_name, N-GObject $launch_context
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:launch-uris-as-manager:
=begin pod
=head2 launch-uris-as-manager

This function performs the equivalent of C<g_app_info_launch_uris()>, but is intended primarily for operating system components that launch applications. Ordinary applications should use C<g_app_info_launch_uris()>.

If the application is launched via GSpawn, then I<spawn_flags>, I<user_setup> and I<user_setup_data> are used for the call to C<g_spawn_async()>. Additionally, I<pid_callback> (with I<pid_callback_data>) will be called to inform about the PID of the created process. See C<g_spawn_async_with_pipes()> for information on certain parameter conditions that can enable an optimized C<posix_spawn()> codepath to be used.

If application launching occurs via some other mechanism (eg: D-Bus activation) then I<spawn_flags>, I<user_setup>, I<user_setup_data>, I<pid_callback> and I<pid_callback_data> are ignored.

Returns: C<True> on successful launch, C<False> otherwise.

  method launch-uris-as-manager ( N-GList $uris, N-GObject $launch_context, GSpawnFlags $spawn_flags, GSpawnChildSetupFunc $user_setup, Pointer $user_setup_data, GDesktopAppLaunchCallback $pid_callback, Pointer $pid_callback_data, N-GError $error --> Bool )

=item $uris; (element-type utf8): List of URIs
=item $launch_context; a B<Gnome::Gio::AppLaunchContext>
=item $spawn_flags; B<Gnome::Gio::SpawnFlags>, used for each process
=item $user_setup; (scope async) : a B<Gnome::Gio::SpawnChildSetupFunc>, used once for each process.
=item $user_setup_data; (closure user_setup) : User data for I<user_setup>
=item $pid_callback; (scope call) : Callback for child processes
=item $pid_callback_data; (closure pid_callback) : User data for I<callback>
=item $error; return location for a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method launch-uris-as-manager ( $uris is copy, N-GObject $launch_context, GSpawnFlags $spawn_flags, GSpawnChildSetupFunc $user_setup, Pointer $user_setup_data, GDesktopAppLaunchCallback $pid_callback, Pointer $pid_callback_data, $error is copy --> Bool ) {
  $uris .= _get-native-object-no-reffing unless $uris ~~ N-GList;
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;
  g_desktop_app_info_launch_uris_as_manager( self._get-native-object-no-reffing, $uris, $launch_context, $spawn_flags, $user_setup, $user_setup_data, $pid_callback, $pid_callback_data, $error).Bool
}

sub g_desktop_app_info_launch_uris_as_manager (
  N-GObject $appinfo, N-GList $uris, N-GObject $launch_context, GSpawnFlags $spawn_flags, GSpawnChildSetupFunc $user_setup, gpointer $user_setup_data, GDesktopAppLaunchCallback $pid_callback, gpointer $pid_callback_data, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:launch-uris-as-manager-with-fds:
=begin pod
=head2 launch-uris-as-manager-with-fds

Equivalent to C<launch_uris_as_manager()> but allows you to pass in file descriptors for the stdin, stdout and stderr streams of the launched process.

If application launching occurs via some non-spawn mechanism (e.g. D-Bus activation) then I<stdin_fd>, I<stdout_fd> and I<stderr_fd> are ignored.

Returns: C<True> on successful launch, C<False> otherwise.

  method launch-uris-as-manager-with-fds ( N-GList $uris, N-GObject $launch_context, GSpawnFlags $spawn_flags, GSpawnChildSetupFunc $user_setup, Pointer $user_setup_data, GDesktopAppLaunchCallback $pid_callback, Pointer $pid_callback_data, Int() $stdin_fd, Int() $stdout_fd, Int() $stderr_fd, N-GError $error --> Bool )

=item $uris; (element-type utf8): List of URIs
=item $launch_context; a B<Gnome::Gio::AppLaunchContext>
=item $spawn_flags; B<Gnome::Gio::SpawnFlags>, used for each process
=item $user_setup; (scope async) : a B<Gnome::Gio::SpawnChildSetupFunc>, used once for each process.
=item $user_setup_data; (closure user_setup) : User data for I<user_setup>
=item $pid_callback; (scope call) : Callback for child processes
=item $pid_callback_data; (closure pid_callback) : User data for I<callback>
=item $stdin_fd; file descriptor to use for child's stdin, or -1
=item $stdout_fd; file descriptor to use for child's stdout, or -1
=item $stderr_fd; file descriptor to use for child's stderr, or -1
=item $error; return location for a B<Gnome::Gio::Error>, or C<undefined>
=end pod

method launch-uris-as-manager-with-fds ( $uris is copy, N-GObject $launch_context, GSpawnFlags $spawn_flags, GSpawnChildSetupFunc $user_setup, Pointer $user_setup_data, GDesktopAppLaunchCallback $pid_callback, Pointer $pid_callback_data, Int() $stdin_fd, Int() $stdout_fd, Int() $stderr_fd, $error is copy --> Bool ) {
  $uris .= _get-native-object-no-reffing unless $uris ~~ N-GList;
  $error .= _get-native-object-no-reffing unless $error ~~ N-GError;
  g_desktop_app_info_launch_uris_as_manager_with_fds( self._get-native-object-no-reffing, $uris, $launch_context, $spawn_flags, $user_setup, $user_setup_data, $pid_callback, $pid_callback_data, $stdin_fd, $stdout_fd, $stderr_fd, $error).Bool
}

sub g_desktop_app_info_launch_uris_as_manager_with_fds (
  N-GObject $appinfo, N-GList $uris, N-GObject $launch_context, GSpawnFlags $spawn_flags, GSpawnChildSetupFunc $user_setup, gpointer $user_setup_data, GDesktopAppLaunchCallback $pid_callback, gpointer $pid_callback_data, gint $stdin_fd, gint $stdout_fd, gint $stderr_fd, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:list-actions:
=begin pod
=head2 list-actions

Returns the list of "additional application actions" supported on the desktop file, as per the desktop file specification.

As per the specification, this is the list of actions that are explicitly listed in the "Actions" key of the [Desktop Entry] group.

Returns:  (element-type utf8) : a list of strings, always non-C<undefined>

  method list-actions ( --> CArray[Str] )

=end pod

method list-actions ( --> CArray[Str] ) {
  g_desktop_app_info_list_actions( self._get-native-object-no-reffing)
}

sub g_desktop_app_info_list_actions (
  N-GObject $info --> gchar-pptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:search:
=begin pod
=head2 search

Searches desktop files for ones that match I<search_string>.

The return value is an array of strvs. Each strv contains a list of applications that matched I<search_string> with an equal score. The outer list is sorted by score so that the first strv contains the best-matching applications, and so on. The algorithm for determining matches is undefined and may change at any time.

None of the search results are subjected to the normal validation checks performed by C<new()> (for example, checking that the executable referenced by a result exists), and so it is possible for C<new()> to return C<undefined> when passed an app ID returned by this function. It is expected that calling code will do this when subsequently creating a B<Gnome::Gio::DesktopAppInfo> for each result.

Returns:  (element-type GStrv) : a list of strvs. Free each item with C<g_strfreev()> and free the outer list with C<g_free()>.

  method search ( Str $search_string --> CArray[CArray[Str]] )

=item $search_string; the search string to use
=end pod

method search ( Str $search_string --> CArray[CArray[Str]] ) {
  g_desktop_app_info_search( self._get-native-object-no-reffing, $search_string)
}

sub g_desktop_app_info_search (
  gchar-ptr $search_string --> gchar-ppptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_desktop_app_info_new:
#`{{
=begin pod
=head2 _g_desktop_app_info_new

Creates a new B<Gnome::Gio::DesktopAppInfo> based on a desktop file id.

A desktop file id is the basename of the desktop file, including the .desktop extension. GIO is looking for a desktop file with this name in the `applications` subdirectories of the XDG data directories (i.e. the directories specified in the `XDG_DATA_HOME` and `XDG_DATA_DIRS` environment variables). GIO also supports the prefix-to-subdirectory mapping that is described in the [Menu Spec](http://standards.freedesktop.org/menu-spec/latest/) (i.e. a desktop id of kde-foo.desktop will match `/usr/share/applications/kde/foo.desktop`).

Returns: a new B<Gnome::Gio::DesktopAppInfo>, or C<undefined> if no desktop file with that id exists.

  method _g_desktop_app_info_new ( Str $desktop_id --> N-GObject )

=item $desktop_id; the desktop file id
=end pod
}}

sub _g_desktop_app_info_new ( gchar-ptr $desktop_id --> N-GObject )
  is native(&gio-lib)
  is symbol('g_desktop_app_info_new')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_desktop_app_info_new_from_filename:
#`{{
=begin pod
=head2 _g_desktop_app_info_new_from_filename

Creates a new B<Gnome::Gio::DesktopAppInfo>.

Returns: a new B<Gnome::Gio::DesktopAppInfo> or C<undefined> on error.

  method _g_desktop_app_info_new_from_filename ( Str $filename --> N-GObject )

=item $filename; (type filename): the path of a desktop file, in the GLib filename encoding
=end pod
}}

sub _g_desktop_app_info_new_from_filename ( gchar-ptr $filename --> N-GObject )
  is native(&gio-lib)
  is symbol('g_desktop_app_info_new_from_filename')
  { * }

#-------------------------------------------------------------------------------
#`{{ NOTE: not useful, skip forever
# TM:1:_g_desktop_app_info_new_from_keyfile:
#`{{
=begin pod
=head2 _g_desktop_app_info_new_from_keyfile

Creates a new B<Gnome::Gio::DesktopAppInfo>.

Returns: a new B<Gnome::Gio::DesktopAppInfo> or C<undefined> on error.

  method _g_desktop_app_info_new_from_keyfile ( N-GObject() $key_file --> N-GObject )

=item $key_file; an opened B<Gnome::Gio::KeyFile>
=end pod
}}

sub _g_desktop_app_info_new_from_keyfile ( N-GObject $key_file --> N-GObject )
  is native(&gio-lib)
  is symbol('g_desktop_app_info_new_from_keyfile')
  { * }
}}

#-------------------------------------------------------------------------------
=begin pod
=head1 Properties

=comment -----------------------------------------------------------------------
=comment #TP:1:filename:
=head2 filename

The filename path of the desktop entry file

=item B<Gnome::GObject::Value> type of this property is G_TYPE_STRING
=item Parameter is readable and writable.
=item Parameter is set on construction of object.
=item Default value is undefined.

=end pod

#`{{
routine from c file to check somewhat deeper
#-------------------------------------------------------------------------------
use Gnome::Glib::Error;

method load-file ( Str $filename --> Bool ) {
  my N-GObject $key_file;
  my Bool $retval = False;

  my $error = CArray[N-GError].new;
  $key_file = g_key_file_new;
  $retval = g_key_file_load_from_file( $key_file, $filename, 0, $error).Bool;
note "retval: $filename, $retval, $error";
  g_key_file_unref($key_file);
  $retval;
}

sub g_key_file_new ( --> N-GObject)
  is native(&glib-lib)
  { * }

sub g_key_file_load_from_file (
  N-GObject $key-file, Str $filename, gint $flags, CArray[N-GError] $error
  --> gboolean
) is native(&glib-lib)
  { * }

sub g_key_file_unref ( N-GObject $key_file)
  is native(&glib-lib)
  { * }
}}
