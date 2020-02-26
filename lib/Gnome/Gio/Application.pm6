#TL:1:Gnome::Gio::Application:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Application

Core application class

=comment ![](images/X.png)

=head1 Description

A B<Gnome::Gio::Application> is the foundation of an application.  It wraps some low-level platform-specific services and is intended to act as the foundation for higher-level application classes such as B<Gnome::Gtk3::Application> or B<MxApplication>.  In general, you should not use this class outside of a higher level framework.

Gnome::Gio::Application provides convenient life cycle management by maintaining a "use count" for the primary application instance. The use count can be changed using C<g_application_hold()> and C<g_application_release()>. If it drops to zero, the application exits. Higher-level classes such as B<Gnome::Gtk3::Application> employ the use count to ensure that the application stays alive as long as it has any opened windows.

Another feature that Gnome::Gio::Application (optionally) provides is process uniqueness. Applications can make use of this functionality by providing a unique application ID. If given, only one application with this ID can be running at a time per session. The session concept is platform-dependent, but corresponds roughly to a graphical desktop login. When your application is launched again, its arguments are passed through platform communication to the already running program. The already running instance of the program is called the "primary instance"; for non-unique applications this is the always the current instance. On Linux, the D-Bus session bus is used for communication.

The use of B<Gnome::Gio::Application> differs from some other commonly-used uniqueness libraries (such as libunique) in important ways. The application is not expected to manually register itself and check if it is the primary instance. Instead, the C<main()> function of a B<Gnome::Gio::Application> should do very little more than instantiating the application instance, possibly connecting signal handlers, then calling C<g_application_run()>. All checks for uniqueness are done internally. If the application is the primary instance then the startup signal is emitted and the mainloop runs. If the application is not the primary instance then a signal is sent to the primary instance and C<g_application_run()> promptly returns. See the code examples below.

If used, the expected form of an application identifier is the same as that of of a [D-Bus well-known bus name](https://dbus.freedesktop.org/doc/dbus-specification.html#message-protocol-names-bus). Examples include: `com.example.MyApp`, `org.example.internal_apps.Calculator`, `org._7_zip.Archiver`. For details on valid application identifiers, see C<g_application_id_is_valid()>.

On Linux, the application identifier is claimed as a well-known bus name on the user's session bus.  This means that the uniqueness of your application is scoped to the current session.  It also means that your application may provide additional services (through registration of other object paths) at that bus name.  The registration of these object paths should be done with the shared GDBus session bus.  Note that due to the internal architecture of GDBus, method calls can be dispatched at any time (even if a main loop is not running).  For this reason, you must ensure that any object paths that you wish to register are registered before B<Gnome::Gio::Application> attempts to acquire the bus name of your application (which happens in C<g_application_register()>).  Unfortunately, this means that you cannot use C<g_application_get_is_remote()> to decide if you want to register object paths.

Gnome::Gio::Application also implements the B<GActionGroup> and B<GActionMap> interfaces and lets you easily export actions by adding them with C<g_action_map_add_action()>. When invoking an action by calling C<g_action_group_activate_action()> on the application, it is always invoked in the primary instance. The actions are also exported on the session bus, and GIO provides the B<GDBusActionGroup> wrapper to conveniently access them remotely. GIO provides a B<GDBusMenuModel> wrapper for remote access to exported B<GMenuModels>.

There is a number of different entry points into a Gnome::Gio::Application:

- via 'Activate' (i.e. just starting the application)

- via 'Open' (i.e. opening some files)

- by handling a command-line

- via activating an action

The  I<startup> signal lets you handle the application initialization for all of these in a single place.

Regardless of which of these entry points is used to start the application, Gnome::Gio::Application passes some "platform data from the launching instance to the primary instance, in the form of a B<GVariant> dictionary mapping strings to variants. To use platform data, override the I<before_emit> or I<after_emit> virtual functions in your B<Gnome::Gio::Application> subclass. When dealing with B<Gnome::Gio::ApplicationCommandLine> objects, the platform data is directly available via C<g_application_command_line_get_cwd()>, C<g_application_command_line_get_environ()> and C<g_application_command_line_get_platform_data()>.

As the name indicates, the platform data may vary depending on the operating system, but it always includes the current directory (key "cwd"), and optionally the environment (ie the set of environment variables and their values) of the calling process (key "environ"). The environment is only added to the platform data if the C<G_APPLICATION_SEND_ENVIRONMENT> flag is set. B<Gnome::Gio::Application> subclasses can add their own platform data by overriding the I<add_platform_data> virtual function. For instance, B<Gnome::Gtk3::Application> adds startup notification data in this way.

To parse commandline arguments you may handle the I<command-line> signal or override the C<local_command_line()> vfunc, to parse them in either the primary instance or the local instance, respectively.

For an example of opening files with a Gnome::Gio::Application, see [Gnome::Gio::Application-example-open.c](https://git.gnome.org/browse/glib/tree/gio/tests/Gnome::Gio::Application-example-open.c).

For an example of using actions with Gnome::Gio::Application, see [Gnome::Gio::Application-example-actions.c](https://git.gnome.org/browse/glib/tree/gio/tests/Gnome::Gio::Application-example-actions.c).

For an example of using extra D-Bus hooks with Gnome::Gio::Application, see [Gnome::Gio::Application-example-dbushooks.c](https://git.gnome.org/browse/glib/tree/gio/tests/Gnome::Gio::Application-example-dbushooks.c).


=head2 Implemented Interfaces

Gnome::Gio::Application implements
=item Gnome::Gio::ActionGroup
=item Gnome::Gio::ActionMap


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::Application;
  also is Gnome::GObject::Object;

=comment  also does Gnome::Gio::ActionGroup;
=comment  also does Gnome::Gio::ActionMap;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::Glib::Error;
use Gnome::Glib::Option;
use Gnome::GObject::Object;
use Gnome::Gio::Enums;

#use Gnome::Gio::ActionGroup;
#use Gnome::Gio::ActionMap;

#-------------------------------------------------------------------------------
# https://developer.gnome.org/gio/stable/GApplication.html
unit class Gnome::Gio::Application:auth<github:MARTIMM>;
also is Gnome::GObject::Object;

#also does Gnome::Gio::ActionGroup;
#also does Gnome::Gio::ActionMap;

#-------------------------------------------------------------------------------
my Bool $signals-added = False;
#-------------------------------------------------------------------------------

=begin pod
=head1 Methods
=head2 new

Create a new object with a valid application id and application flags.

  multi method new (
    Bool :$app-id!, GApplicationFlags :$flags = G_APPLICATION_FLAGS_NONE
  )

Create an object using a native object from elsewhere.

  multi method new ( N-GObject :$object! )

=end pod

#TM:2:new():inheriting:Gnome::Gtk3::Application
#TM:1:new():
#TM:1:new(:app-id):
#TM:0:new(:native-object):
submethod BUILD ( *%options ) {

  # add signal info in the form of group<signal-name>.
  # groups are e.g. signal, event, nativeobject etc
  $signals-added = self.add-signal-types( $?CLASS.^name,
    :w0<startup shutdown activate name-lost>,
    :w1<command-line handle-local-options>,
    :w3<open>,
  ) unless $signals-added;


  # prevent creating wrong widgets
  return unless self.^name eq 'Gnome::Gio::Application';

  # process all named arguments
  if ? %options<app-id> {
    if g_application_id_is_valid(%options<app-id>) {
      my GApplicationFlags $f = %options<flags> // G_APPLICATION_FLAGS_NONE;
      self.set-native-object(g_application_new( %options<app-id>, $f));
    }

    else {
      die X::Gnome.new(
        :message("Invalid application id: %options<app-id>")
      );
    }
  }

  elsif ? %options<object> {
    self.set-native-object(%options<object>);
  }

  elsif %options.keys.elems {
    die X::Gnome.new(
      :message('Unsupported options for ' ~ self.^name ~
               ': ' ~ %options.keys.join(', ')
              )
    );
  }

  else {
    self.set-native-object(g_application_new( '', G_APPLICATION_FLAGS_NONE));
  }

  # only after creating the widget, the gtype is known
  self.set-class-info('GApplication');
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("g_application_$native-sub"); } unless ?$s;
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); }
#  $s = self._buildable_interface($native-sub) unless ?$s;
#  $s = self._orientable_interface($native-sub) unless ?$s;
#also does Gnome::Gio::ActionGroup;
#also does Gnome::Gio::ActionMap;

  self.set-class-name-of-sub('GApplication');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
#TM:1:g_application_id_is_valid:
=begin pod
=head2 [g_application_] id_is_valid

Checks if I<application_id> is a valid application identifier.

A valid ID is required for calls to C<g_application_new()> and C<g_application_set_application_id()>.

Application identifiers follow the same format as [D-Bus well-known bus names](https://dbus.freedesktop.org/doc/dbus-specification.htmlB<message>-protocol-names-bus).

For convenience, the restrictions on application identifiers are reproduced here:
=item Application identifiers are composed of 1 or more elements separated by a period (`.`) character. All elements must contain at least one character.

=item Each element must only contain the ASCII characters `[A-Z][a-z][0-9]_-`, with `-` discouraged in new application identifiers. Each element must not begin with a digit.

=item Application identifiers must contain at least one `.` (period) character (and thus at least two elements).

=item Application identifiers must not begin with a `.` (period) character.

=item Application identifiers must not exceed 255 characters.

Note that the hyphen (`-`) character is allowed in application identifiers, but is problematic or not allowed in various specifications and APIs that refer to D-Bus, such as [Flatpak application IDs](http://docs.flatpak.org/en/latest/introduction.html#identifiers), the [DBusActivatable interface in the Desktop Entry Specification](https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.htmlB<dbus>), and the convention that an application's "main" interface and object path resemble its application identifier and bus name. To avoid situations that require special-case handling, it is recommended that new application identifiers consistently replace hyphens with underscores.

Like D-Bus interface names, application identifiers should start with the reversed DNS domain name of the author of the interface (in lower-case), and it is conventional for the rest of the application identifier to consist of words run together, with initial capital letters.

As with D-Bus interface names, if the author's DNS domain name contains hyphen/minus characters they should be replaced by underscores, and if it contains leading digits they should be escaped by prepending an underscore. For example, if the owner of 7-zip.org used an application identifier for an archiving application, it might be named `org._7_zip.Archiver`.

Returns: C<1> if I<application_id> is valid

  method g_application_id_is_valid ( Str $application_id --> Int  )

=item Str $application_id; a potential application identifier

=end pod

sub g_application_id_is_valid ( Str $application_id )
  returns int32
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_application_new:new(:app-id)
=begin pod
=head2 g_application_new

Creates a new B<Gnome::Gio::Application> instance.

If defined, the application id must be valid.  See C<g_application_id_is_valid()>.

If no application ID is given then some features of B<Gnome::Gio::Application> (most notably application uniqueness) will be disabled.

Returns: a new B<Gnome::Gio::Application> instance

  method g_application_new (
    Str $application_id, GApplicationFlags $flags --> N-GObject
  )

=item Str $application_id; (nullable): the application id
=item GApplicationFlags $flags; the application flags

=end pod

sub g_application_new ( Str $application_id, int32 $flags )
  returns N-GObject
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_application_get_application_id:
=begin pod
=head2 [g_application_] get_application_id

Gets the unique identifier for I<application>.

Returns: the identifier for I<application>, owned by I<application>

  method g_application_get_application_id ( --> Str  )


=end pod

sub g_application_get_application_id ( N-GObject $application )
  returns Str
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_application_set_application_id:
=begin pod
=head2 [g_application_] set_application_id

Sets the unique identifier for I<application>. The application id can only be modified if I<application> has not yet been registered. The application id must be valid, see C<g_application_id_is_valid()>.

  method g_application_set_application_id ( Str $application_id )

=item Str $application_id; (nullable): the identifier for I<application>

=end pod

sub g_application_set_application_id ( N-GObject $application, Str $application_id )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_get_dbus_connection:
=begin pod
=head2 [g_application_] get_dbus_connection

Gets the B<GDBusConnection> being used by the application, or C<Any>.

If B<Gnome::Gio::Application> is using its D-Bus backend then this function will
return the B<GDBusConnection> being used for uniqueness and
communication with the desktop environment and other instances of the
application.

If B<Gnome::Gio::Application> is not using D-Bus then this function will return
C<Any>.  This includes the situation where the D-Bus backend would
normally be in use but we were unable to connect to the bus.

This function must not be called before the application has been
registered.  See C<g_application_get_is_registered()>.

Returns: (transfer none): a B<GDBusConnection>, or C<Any>

  method g_application_get_dbus_connection ( --> N-GObject  )


=end pod

sub g_application_get_dbus_connection ( N-GObject $application )
  returns N-GObject
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_get_dbus_object_path:
=begin pod
=head2 [g_application_] get_dbus_object_path

Gets the D-Bus object path being used by the application, or C<Any>.

If B<Gnome::Gio::Application> is using its D-Bus backend then this function will
return the D-Bus object path that B<Gnome::Gio::Application> is using.  If the
application is the primary instance then there is an object published
at this path.  If the application is not the primary instance then
the result of this function is undefined.

If B<Gnome::Gio::Application> is not using D-Bus then this function will return
C<Any>.  This includes the situation where the D-Bus backend would
normally be in use but we were unable to connect to the bus.

This function must not be called before the application has been
registered.  See C<g_application_get_is_registered()>.

Returns: the object path, or C<Any>

  method g_application_get_dbus_object_path ( --> Str  )


=end pod

sub g_application_get_dbus_object_path ( N-GObject $application )
  returns Str
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_get_inactivity_timeout:
=begin pod
=head2 [g_application_] get_inactivity_timeout

Gets the current inactivity timeout for the application.

This is the amount of time (in milliseconds) after the last call to
C<g_application_release()> before the application stops running.

Returns: the timeout, in milliseconds

  method g_application_get_inactivity_timeout ( --> UInt  )


=end pod

sub g_application_get_inactivity_timeout ( N-GObject $application )
  returns uint32
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_set_inactivity_timeout:
=begin pod
=head2 [g_application_] set_inactivity_timeout

Sets the current inactivity timeout for the application.

This is the amount of time (in milliseconds) after the last call to
C<g_application_release()> before the application stops running.

This call has no side effects of its own.  The value set here is only
used for next time C<g_application_release()> drops the use count to
zero.  Any timeouts currently in progress are not impacted.

  method g_application_set_inactivity_timeout ( UInt $inactivity_timeout )

=item UInt $inactivity_timeout; the timeout, in milliseconds

=end pod

sub g_application_set_inactivity_timeout ( N-GObject $application, uint32 $inactivity_timeout )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_application_get_flags:
=begin pod
=head2 [g_application_] get_flags

Gets the flags for I<application>.

See B<GApplicationFlags>.

  method g_application_get_flags ( --> Int )


=end pod

sub g_application_get_flags ( N-GObject $application )
  returns int32
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_application_set_flags:
=begin pod
=head2 [g_application_] set_flags

Sets the flags for I<application>. The flags can only be modified if I<application> has not yet been registered.

See B<GApplicationFlags>.

  method g_application_set_flags ( GApplicationFlags $flags )

=item GApplicationFlags $flags; the flags for I<application>

=end pod

sub g_application_set_flags ( N-GObject $application, int32 $flags )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_get_resource_base_path:
=begin pod
=head2 [g_application_] get_resource_base_path

Gets the resource base path of I<application>.

See C<g_application_set_resource_base_path()> for more information.

Returns: (nullable): the base resource path, if one is set

  method g_application_get_resource_base_path ( --> Str  )


=end pod

sub g_application_get_resource_base_path ( N-GObject $application )
  returns Str
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_set_resource_base_path:
=begin pod
=head2 [g_application_] set_resource_base_path

Sets (or unsets) the base resource path of I<application>.

The path is used to automatically load various [application
resources][gresource] such as menu layouts and action descriptions.
The various types of resources will be found at fixed names relative
to the given base path.

By default, the resource base path is determined from the application
ID by prefixing '/' and replacing each '.' with '/'.  This is done at
the time that the B<Gnome::Gio::Application> object is constructed.  Changes to
the application ID after that point will not have an impact on the
resource base path.

As an example, if the application has an ID of "org.example.app" then
the default resource base path will be "/org/example/app".  If this
is a B<Gnome::Gtk3::Application> (and you have not manually changed the path)
then B<Gnome::Gtk3:: will> then search for the menus of the application at
"/org/example/app/gtk/menus.ui".

See B<GResource> for more information about adding resources to your
application.

You can disable automatic resource loading functionality by setting
the path to C<Any>.

Changing the resource base path once the application is running is
not recommended.  The point at which the resource path is consulted
for forming paths for various purposes is unspecified.  When writing
a sub-class of B<Gnome::Gio::Application> you should either set the
 I<resource-base-path> property at construction time, or call
this function during the instance initialization. Alternatively, you
can call this function in the B<Gnome::Gio::ApplicationClass>.startup virtual function,
before chaining up to the parent implementation.

  method g_application_set_resource_base_path ( Str $resource_path )

=item Str $resource_path; (nullable): the resource path to use

=end pod

sub g_application_set_resource_base_path ( N-GObject $application, Str $resource_path )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_add_main_option_entries:
=begin pod
=head2 [g_application_] add_main_option_entries

Adds main option entries to be handled by I<application>.

This function is comparable to C<g_option_context_add_main_entries()>.

After the commandline arguments are parsed, the
 I<handle-local-options> signal will be emitted.  At this
point, the application can inspect the values pointed to by I<arg_data>
in the given B<N-GOptionEntrys>.

Unlike B<GOptionContext>, B<Gnome::Gio::Application> supports giving a C<Any>
I<arg_data> for a non-callback B<N-GOptionEntry>.  This results in the
argument in question being packed into a B<GVariantDict> which is also
passed to  I<handle-local-options>, where it can be
inspected and modified.  If C<G_APPLICATION_HANDLES_COMMAND_LINE> is
set, then the resulting dictionary is sent to the primary instance,
where C<g_application_command_line_get_options_dict()> will return it.
This "packing" is done according to the type of the argument --
booleans for normal flags, strings for strings, bytestrings for
filenames, etc.  The packing only occurs if the flag is given (ie: we
do not pack a "false" B<GVariant> in the case that a flag is missing).

In general, it is recommended that all commandline arguments are
parsed locally.  The options dictionary should then be used to
transmit the result of the parsing to the primary instance, where
C<g_variant_dict_lookup()> can be used.  For local options, it is
possible to either use I<arg_data> in the usual way, or to consult (and
potentially remove) the option from the options dictionary.

This function is new in GLib 2.40.  Before then, the only real choice
was to send all of the commandline arguments (options and all) to the
primary instance for handling.  B<Gnome::Gio::Application> ignored them completely
on the local side.  Calling this function "opts in" to the new
behaviour, and in particular, means that unrecognised options will be
treated as errors.  Unrecognised options have never been ignored when
C<G_APPLICATION_HANDLES_COMMAND_LINE> is unset.

If  I<handle-local-options> needs to see the list of
filenames, then the use of C<G_OPTION_REMAINING> is recommended.  If
I<arg_data> is C<Any> then C<G_OPTION_REMAINING> can be used as a key into
the options dictionary.  If you do use C<G_OPTION_REMAINING> then you
need to handle these arguments for yourself because once they are
consumed, they will no longer be visible to the default handling
(which treats them as filenames to be opened).

It is important to use the proper GVariant format when retrieving
the options with C<g_variant_dict_lookup()>:
- for C<G_OPTION_ARG_NONE>, use b
- for C<G_OPTION_ARG_STRING>, use &s
- for C<G_OPTION_ARG_INT>, use i
- for C<G_OPTION_ARG_INT64>, use x
- for C<G_OPTION_ARG_DOUBLE>, use d
- for C<G_OPTION_ARG_FILENAME>, use ^ay
- for C<G_OPTION_ARG_STRING_ARRAY>, use &as
- for C<G_OPTION_ARG_FILENAME_ARRAY>, use ^aay

  method g_application_add_main_option_entries ( N-GOptionEntry $entries )

=item N-GOptionEntry $entries; (array zero-terminated=1) (element-type N-GOptionEntry) a C<Any>-terminated list of B<N-GOptionEntrys>

=end pod

sub g_application_add_main_option_entries ( N-GObject $application, N-GOptionEntry $entries )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_add_main_option:
=begin pod
=head2 [g_application_] add_main_option

Add an option to be handled by I<application>.

Calling this function is the equivalent of calling C<g_application_add_main_option_entries()> with a single B<N-GOptionEntry> that has its arg_data member set to C<Any>.

The parsed arguments will be packed into a B<GVariantDict> which is passed to  I<handle-local-options>. If C<G_APPLICATION_HANDLES_COMMAND_LINE> is set, then it will also be sent to the primary instance. See C<g_application_add_main_option_entries()> for more details.

See B<N-GOptionEntry> for more documentation of the arguments.

  method g_application_add_main_option (
    Str $long_name, char $short_name, GOptionFlags $flags,
    GOptionArg $arg, Str $description, Str $arg_description
  )

=item Str $long_name; the long name of an option used to specify it in a commandline
=item char $short_name; the short name of an option
=item GOptionFlags $flags; flags from B<GOptionFlags>
=item GOptionArg $arg; the type of the option, as a B<GOptionArg>
=item Str $description; the description for the option in `--help` output
=item Str $arg_description; (nullable): the placeholder to use for the extra argument parsed by the option in `--help` output

=end pod

sub g_application_add_main_option ( N-GObject $application, Str $long_name, int8 $short_name, int32 $flags, int32 $arg, Str $description, Str $arg_description )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_add_option_group:
=begin pod
=head2 [g_application_] add_option_group

Adds a B<N-GOptionGroup> to the commandline handling of I<application>.

This function is comparable to C<g_option_context_add_group()>.

Unlike C<g_application_add_main_option_entries()>, this function does
not deal with C<Any> I<arg_data> and never transmits options to the
primary instance.

The reason for that is because, by the time the options arrive at the
primary instance, it is typically too late to do anything with them.
Taking the GTK option group as an example: GTK will already have been
initialised by the time the  I<command-line> handler runs.
In the case that this is not the first-running instance of the
application, the existing instance may already have been running for
a very long time.

This means that the options from B<N-GOptionGroup> are only really usable
in the case that the instance of the application being run is the
first instance.  Passing options like `--display=` or `--gdk-debug=`
on future runs will have no effect on the existing primary instance.

Calling this function will cause the options in the supplied option
group to be parsed, but it does not cause you to be "opted in" to the
new functionality whereby unrecognised options are rejected even if
C<G_APPLICATION_HANDLES_COMMAND_LINE> was given.

  method g_application_add_option_group ( N-GOptionGroup $group )

=item N-GOptionGroup $group; (transfer full): a B<N-GOptionGroup>

=end pod

sub g_application_add_option_group ( N-GObject $application, N-GOptionGroup $group )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_set_option_context_parameter_string:
=begin pod
=head2 [g_application_] set_option_context_parameter_string

Sets the parameter string to be used by the commandline handling of I<application>. This function registers the argument to be passed to C<g_option_context_new()> when the internal B<GOptionContext> of I<application> is created. See C<g_option_context_new()> for more information about I<parameter_string>.

  method g_application_set_option_context_parameter_string (
    Str $parameter_string
  )

=item Str $parameter_string; a string which is displayed in the first line of `--help` output, after the usage summary `programname [OPTION...]`.

=end pod

sub g_application_set_option_context_parameter_string ( N-GObject $application, Str $parameter_string )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_set_option_context_summary:
=begin pod
=head2 [g_application_] set_option_context_summary

Adds a summary to the I<application> option context.

See C<g_option_context_set_summary()> for more information.

  method g_application_set_option_context_summary ( Str $summary )

=item Str $summary; (nullable): a string to be shown in `--help` output before the list of options, or C<Any>

=end pod

sub g_application_set_option_context_summary ( N-GObject $application, Str $summary )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_set_option_context_description:
=begin pod
=head2 [g_application_] set_option_context_description

Adds a description to the I<application> option context.

See C<g_option_context_set_description()> for more information.

  method g_application_set_option_context_description ( Str $description )

=item Str $description; (nullable): a string to be shown in `--help` output after the list of options, or C<Any>

=end pod

sub g_application_set_option_context_description ( N-GObject $application, Str $description )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:g_application_get_is_registered:ex-application.pl6
=begin pod
=head2 [g_application_] get_is_registered

Checks if I<application> is registered. An application is registered if C<g_application_register()> has been successfully called. Returns: C<1> if I<application> is registered.

  method g_application_get_is_registered ( --> Int  )


=end pod

sub g_application_get_is_registered ( N-GObject $application )
  returns int32
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_get_is_remote:
=begin pod
=head2 [g_application_] get_is_remote

Checks if I<application> is remote.

If I<application> is remote then it means that another instance of
application already exists (the 'primary' instance).  Calls to
perform actions on I<application> will result in the actions being
performed by the primary instance.

The value of this property cannot be accessed before
C<g_application_register()> has been called.  See
C<g_application_get_is_registered()>.

Returns: C<1> if I<application> is remote

  method g_application_get_is_remote ( --> Int  )


=end pod

sub g_application_get_is_remote ( N-GObject $application )
  returns int32
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:g_application_register:ex-application.pl6
=begin pod
=head2 g_application_register

Attempts registration of the application.

This is the point at which the application discovers if it is the primary instance or merely acting as a remote for an already-existing primary instance.  This is implemented by attempting to acquire the application identifier as a unique bus name on the session bus using GDBus.

If there is no application ID or if C<G_APPLICATION_NON_UNIQUE> was given, then this process will always become the primary instance.

Due to the internal architecture of GDBus, method calls can be dispatched at any time (even if a main loop is not running).  For this reason, you must ensure that any object paths that you wish to register are registered before calling this function.

If the application has already been registered then C<1> is returned with no work performed.

The  I<startup> signal is emitted if registration succeeds and I<application> is the primary instance (including the non-unique case).

In the event of an error (such as I<cancellable> being cancelled, or a failure to connect to the session bus), C<0> is returned and I<error> is set appropriately.

Note: the return value of this function is not an indicator that this instance is or is not the primary instance of the application.  See C<g_application_get_is_remote()> for that.

Returns a valid error object if registration didn't succeed.

  method g_application_register (
    N-GObject :$cancellable
    --> Gnome::Glib::Error
  )

=item N-GObject $cancellable; (nullable): a B<GCancellable>, or C<Any>

=end pod
sub g_application_register (
  N-GObject $application, N-GObject :$cancellable,
  --> Gnome::Glib::Error
) {
  my N-GError $error .= new;
  if _g_application_register( $application, $cancellable, $error) {
    Gnome::Glib::Error.new(:native-object(N-GError))
  }

  else {
    Gnome::Glib::Error.new(:native-object($error))
  }
}

sub _g_application_register (
  N-GObject $application, N-GObject $cancellable, N-GError $error is rw
  --> int32
) is native(&gio-lib)
  is symbol('g_application_register')
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_hold:
=begin pod
=head2 g_application_hold

Increases the use count of I<application>.

Use this function to indicate that the application has a reason to
continue to run.  For example, C<g_application_hold()> is called by GTK+
when a toplevel window is on the screen.

To cancel the hold, call C<g_application_release()>.

  method g_application_hold ( )


=end pod

sub g_application_hold ( N-GObject $application )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_release:
=begin pod
=head2 g_application_release

Decrease the use count of I<application>.

When the use count reaches zero, the application will stop running.

Never call this function except to cancel the effect of a previous
call to C<g_application_hold()>.

  method g_application_release ( )


=end pod

sub g_application_release ( N-GObject $application )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_activate:
=begin pod
=head2 g_application_activate

Activates the application.

In essence, this results in the  I<activate> signal being
emitted in the primary instance.

The application must be registered before calling this function.

  method g_application_activate ( )


=end pod

sub g_application_activate ( N-GObject $application )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_open:
=begin pod
=head2 g_application_open

Opens the given files.

In essence, this results in the  I<open> signal being emitted
in the primary instance.

I<n_files> must be greater than zero.

I<hint> is simply passed through to the I<open> signal.  It is
intended to be used by applications that have multiple modes for
opening files (eg: "view" vs "edit", etc).  Unless you have a need
for this functionality, you should use "".

The application must be registered before calling this function
and it must have the C<G_APPLICATION_HANDLES_OPEN> flag set.

  method g_application_open ( N-GObject $files, Int $n_files, Str $hint )

=item N-GObject $files; (array length=n_files): an array of B<GFiles> to open
=item Int $n_files; the length of the I<files> array
=item Str $hint; a hint (or ""), but never C<Any>

=end pod

sub g_application_open ( N-GObject $application, N-GObject $files, int32 $n_files, Str $hint )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_run:
=begin pod
=head2 g_application_run

Runs the application.

This function is intended to be run from C<main()> and its return value
is intended to be returned by C<main()>. Although you are expected to pass
the I<argc>, I<argv> parameters from C<main()> to this function, it is possible
to pass C<Any> if I<argv> is not available or commandline handling is not
required.  Note that on Windows, I<argc> and I<argv> are ignored, and
C<g_win32_get_command_line()> is called internally (for proper support
of Unicode commandline arguments).

B<Gnome::Gio::Application> will attempt to parse the commandline arguments.  You
can add commandline flags to the list of recognised options by way of
C<g_application_add_main_option_entries()>.  After this, the
 I<handle-local-options> signal is emitted, from which the
application can inspect the values of its B<N-GOptionEntrys>.

 I<handle-local-options> is a good place to handle options
such as `--version`, where an immediate reply from the local process is
desired (instead of communicating with an already-running instance).
A  I<handle-local-options> handler can stop further processing
by returning a non-negative value, which then becomes the exit status of
the process.

What happens next depends on the flags: if
C<G_APPLICATION_HANDLES_COMMAND_LINE> was specified then the remaining
commandline arguments are sent to the primary instance, where a
 I<command-line> signal is emitted.  Otherwise, the
remaining commandline arguments are assumed to be a list of files.
If there are no files listed, the application is activated via the
 I<activate> signal.  If there are one or more files, and
C<G_APPLICATION_HANDLES_OPEN> was specified then the files are opened
via the  I<open> signal.

If you are interested in doing more complicated local handling of the
commandline then you should implement your own B<Gnome::Gio::Application> subclass
and override C<local_command_line()>. In this case, you most likely want
to return C<1> from your C<local_command_line()> implementation to
suppress the default handling. See
[Gnome::Gio::Application-example-cmdline2.c][Gnome::Gio::Application-example-cmdline2]
for an example.

If, after the above is done, the use count of the application is zero
then the exit status is returned immediately.  If the use count is
non-zero then the default main context is iterated until the use count
falls to zero, at which point 0 is returned.

If the C<G_APPLICATION_IS_SERVICE> flag is set, then the service will
run for as much as 10 seconds with a use count of zero while waiting
for the message that caused the activation to arrive.  After that,
if the use count falls to zero the application will exit immediately,
except in the case that C<g_application_set_inactivity_timeout()> is in
use.

This function sets the prgname (C<g_set_prgname()>), if not already set,
to the basename of argv[0].

Much like C<g_main_loop_run()>, this function will acquire the main context
for the duration that the application is running.

Since 2.40, applications that are not explicitly flagged as services
or launchers (ie: neither C<G_APPLICATION_IS_SERVICE> or
C<G_APPLICATION_IS_LAUNCHER> are given as flags) will check (from the
default handler for local_command_line) if "--Gnome::Gio::Application-service"
was given in the command line.  If this flag is present then normal
commandline processing is interrupted and the
C<G_APPLICATION_IS_SERVICE> flag is set.  This provides a "compromise"
solution whereby running an application directly from the commandline
will invoke it in the normal way (which can be useful for debugging)
while still allowing applications to be D-Bus activated in service
mode.  The D-Bus service file should invoke the executable with
"--Gnome::Gio::Application-service" as the sole commandline argument.  This
approach is suitable for use by most graphical applications but
should not be used from applications like editors that need precise
control over when processes invoked via the commandline will exit and
what their exit status will be.

Returns: the exit status

  method g_application_run ( int32 $argc, CArray[Str] $argv --> int32  )

=item int32 $argc; the argc from C<main()> (or 0 if I<argv> is C<Any>)
=item CArray[Str] $argv; (array length=argc) (element-type filename) (nullable): the argv from C<main()>, or C<Any>

=end pod

sub g_application_run ( N-GObject $application, int32 $argc, CArray[Str] $argv )
  returns int32
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_quit:
=begin pod
=head2 g_application_quit

Immediately quits the application.

Upon return to the mainloop, C<g_application_run()> will return,
calling only the 'shutdown' function before doing so.

The hold count is ignored.
Take care if your code has called C<g_application_hold()> on the application and
is therefore still expecting it to exist.
(Note that you may have called C<g_application_hold()> indirectly, for example
through C<gtk_application_add_window()>.)

The result of calling C<g_application_run()> again after it returns is
unspecified.

  method g_application_quit ( )


=end pod

sub g_application_quit ( N-GObject $application )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_get_default:
=begin pod
=head2 [g_application_] get_default

Returns the default B<Gnome::Gio::Application> instance for this process.

Normally there is only one B<Gnome::Gio::Application> per process and it becomes
the default when it is created.  You can exercise more control over
this by using C<g_application_set_default()>.

If there is no default application then C<Any> is returned.

Returns: (transfer none): the default application for this process, or C<Any>

  method g_application_get_default ( --> N-GObject  )


=end pod

sub g_application_get_default (  )
  returns N-GObject
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_set_default:
=begin pod
=head2 [g_application_] set_default

Sets or unsets the default application for the process, as returned
by C<g_application_get_default()>.

This function does not take its own reference on I<application>.  If
I<application> is destroyed then the default application will revert
back to C<Any>.

  method g_application_set_default ( )


=end pod

sub g_application_set_default ( N-GObject $application )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_mark_busy:
=begin pod
=head2 [g_application_] mark_busy

Increases the busy count of I<application>.

Use this function to indicate that the application is busy, for instance
while a long running operation is pending.

The busy state will be exposed to other processes, so a session shell will
use that information to indicate the state to the user (e.g. with a
spinner).

To cancel the busy indication, use C<g_application_unmark_busy()>.

  method g_application_mark_busy ( )


=end pod

sub g_application_mark_busy ( N-GObject $application )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_unmark_busy:
=begin pod
=head2 [g_application_] unmark_busy

Decreases the busy count of I<application>.

When the busy count reaches zero, the new state will be propagated
to other processes.

This function must only be called to cancel the effect of a previous
call to C<g_application_mark_busy()>.

  method g_application_unmark_busy ( )


=end pod

sub g_application_unmark_busy ( N-GObject $application )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_get_is_busy:
=begin pod
=head2 [g_application_] get_is_busy

Gets the application's current busy state, as set through
C<g_application_mark_busy()> or C<g_application_bind_busy_property()>.

Returns: C<1> if I<application> is currenty marked as busy

  method g_application_get_is_busy ( --> Int  )


=end pod

sub g_application_get_is_busy ( N-GObject $application )
  returns int32
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_send_notification:
=begin pod
=head2 [g_application_] send_notification

Sends a notification on behalf of I<application> to the desktop shell.
There is no guarantee that the notification is displayed immediately,
or even at all.

Notifications may persist after the application exits. It will be
D-Bus-activated when the notification or one of its actions is
activated.

Modifying I<notification> after this call has no effect. However, the
object can be reused for a later call to this function.

I<id> may be any string that uniquely identifies the event for the
application. It does not need to be in any special format. For
example, "new-message" might be appropriate for a notification about
new messages.

If a previous notification was sent with the same I<id>, it will be
replaced with I<notification> and shown again as if it was a new
notification. This works even for notifications sent from a previous
execution of the application, as long as I<id> is the same string.

I<id> may be C<Any>, but it is impossible to replace or withdraw
notifications without an id.

If I<notification> is no longer relevant, it can be withdrawn with
C<g_application_withdraw_notification()>.

  method g_application_send_notification ( Str $id, N-GObject $notification )

=item Str $id; (nullable): id of the notification, or C<Any>
=item N-GObject $notification; the B<GNotification> to send

=end pod

sub g_application_send_notification ( N-GObject $application, Str $id, N-GObject $notification )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_withdraw_notification:
=begin pod
=head2 [g_application_] withdraw_notification

Withdraws a notification that was sent with
C<g_application_send_notification()>.

This call does nothing if a notification with I<id> doesn't exist or
the notification was never sent.

This function works even for notifications sent in previous
executions of this application, as long I<id> is the same as it was for
the sent notification.

Note that notifications are dismissed when the user clicks on one
of the buttons in a notification or triggers its default action, so
there is no need to explicitly withdraw the notification in that case.

  method g_application_withdraw_notification ( Str $id )

=item Str $id; id of a previously sent notification

=end pod

sub g_application_withdraw_notification ( N-GObject $application, Str $id )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_bind_busy_property:
=begin pod
=head2 [g_application_] bind_busy_property

Marks I<application> as busy (see C<g_application_mark_busy()>) while
I<property> on I<object> is C<1>.

The binding holds a reference to I<application> while it is active, but
not to I<object>. Instead, the binding is destroyed when I<object> is
finalized.

  method g_application_bind_busy_property ( Pointer $object, Str $property )

=item Pointer $object; (type GObject.Object): a B<GObject>
=item Str $property; the name of a boolean property of I<object>

=end pod

sub g_application_bind_busy_property ( N-GObject $application, Pointer $object, Str $property )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_application_unbind_busy_property:
=begin pod
=head2 [g_application_] unbind_busy_property

Destroys a binding between I<property> and the busy state of
I<application> that was previously created with
C<g_application_bind_busy_property()>.

  method g_application_unbind_busy_property ( Pointer $object, Str $property )

=item Pointer $object; (type GObject.Object): a B<GObject>
=item Str $property; the name of a boolean property of I<object>

=end pod

sub g_application_unbind_busy_property ( N-GObject $application, Pointer $object, Str $property )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head1 Signals

There are two ways to connect to a signal. The first option you have is to use C<register-signal()> from B<Gnome::GObject::Object>. The second option is to use C<g_signal_connect_object()> directly from B<Gnome::GObject::Signal>.

=head2 First method

The positional arguments of the signal handler are all obligatory as well as their types. The named attributes C<:$widget> and user data are optional.

  # handler method
  method mouse-event ( GdkEvent $event, :$widget ) { ... }

  # connect a signal on window object
  my Gnome::Gtk3::Window $w .= new( ... );
  $w.register-signal( self, 'mouse-event', 'button-press-event');

=head2 Second method

  my Gnome::Gtk3::Window $w .= new( ... );
  my Callable $handler = sub (
    N-GObject $native, GdkEvent $event, OpaquePointer $data
  ) {
    ...
  }

  $w.connect-object( 'button-press-event', $handler);

Also here, the types of positional arguments in the signal handler are important. This is because both methods C<register-signal()> and C<g_signal_connect_object()> are using the signatures of the handler routines to setup the native call interface.

=head2 Supported signals


=comment #TS:0:startup:
=head3 startup

The I<startup> signal is emitted on the primary instance immediately
after registration. See C<g_application_register()>.

  method handler (
    Gnome::GObject::Object :widget($application),
    *%user-options
  );

=item $application; the application


=comment #TS:0:shutdown:
=head3 shutdown

The I<shutdown> signal is emitted only on the registered primary instance
immediately after the main loop terminates.

  method handler (
    Gnome::GObject::Object :widget($application),
    *%user-options
  );

=item $application; the application


=comment #TS:0:activate:
=head3 activate

The I<activate> signal is emitted on the primary instance when an
activation occurs. See C<g_application_activate()>.

  method handler (
    Gnome::GObject::Object :widget($application),
    *%user-options
  );

=item $application; the application


=comment #TS:0:open:
=head3 open

The I<open> signal is emitted on the primary instance when there are
files to open. See C<g_application_open()> for more information.

  method handler (
    Unknown type G_TYPE_POINTER $files,
    Int $n_files,
    Str $hint,
    Gnome::GObject::Object :widget($application),
    *%user-options
  );

=item $application; the application

=item $files; (array length=n_files) (element-type GFile): an array of B<GFiles>

=item $n_files; the length of I<files>

=item $hint; a hint provided by the calling instance


=comment #TS:0:command-line:
=head3 command-line

The I<command-line> signal is emitted on the primary instance when
a commandline is not handled locally. See C<g_application_run()> and
the B<Gnome::Gio::ApplicationCommandLine> documentation for more information.

Returns: An integer that is set as the exit status for the calling
process. See C<g_application_command_line_set_exit_status()>.

  method handler (
    Unknown type G_TYPE_APPLICATION_COMMAND_LINE $command_line,
    Gnome::GObject::Object :widget($application),
    *%user-options
    --> Int
  );

=item $application; the application

=item $command_line; a B<Gnome::Gio::ApplicationCommandLine> representing the
passed commandline

=comment #TS:0:handle-local-options:
=head3 handle-local-options

The I<handle-local-options> signal is emitted on the local instance
after the parsing of the commandline options has occurred.

You can add options to be recognised during commandline option
parsing using C<g_application_add_main_option_entries()> and
C<g_application_add_option_group()>.

Signal handlers can inspect I<options> (along with values pointed to
from the I<arg_data> of an installed B<N-GOptionEntrys>) in order to
decide to perform certain actions, including direct local handling
(which may be useful for options like --version).

In the event that the application is marked
C<G_APPLICATION_HANDLES_COMMAND_LINE> the "normal processing" will
send the I<options> dictionary to the primary instance where it can be
read with C<g_application_command_line_get_options_dict()>.  The signal
handler can modify the dictionary before returning, and the
modified dictionary will be sent.

In the event that C<G_APPLICATION_HANDLES_COMMAND_LINE> is not set,
"normal processing" will treat the remaining uncollected command
line arguments as filenames or URIs.  If there are no arguments,
the application is activated by C<g_application_activate()>.  One or
more arguments results in a call to C<g_application_open()>.

If you want to handle the local commandline arguments for yourself
by converting them to calls to C<g_application_open()> or
C<g_action_group_activate_action()> then you must be sure to register
the application first.  You should probably not call
C<g_application_activate()> for yourself, however: just return -1 and
allow the default handler to do it for you.  This will ensure that
the `--Gnome::Gio::Application-service` switch works properly (i.e. no activation
in that case).

Note that this signal is emitted from the default implementation of
C<local_command_line()>.  If you override that function and don't
chain up then this signal will never be emitted.

You can override C<local_command_line()> if you need more powerful
capabilities than what is provided here, but this should not
normally be required.

Returns: an exit code. If you have handled your options and want
to exit the process, return a non-negative option, 0 for success,
and a positive value for failure. To continue, return -1 to let
the default option processing continue.

  method handler (
    Unknown type G_TYPE_VARIANT_DICT $options,
    Gnome::GObject::Object :widget($application),
    *%user-options
    --> Int
  );

=item $application; the application

=item $options; the options dictionary


=comment #TS:0:name-lost:
=head3 name-lost

The I<name-lost> signal is emitted only on the registered primary instance
when a new instance has taken over. This can only happen if the application
is using the C<G_APPLICATION_ALLOW_REPLACEMENT> flag.

The default handler for this signal calls C<g_application_quit()>.

Returns: C<1> if the signal has been handled

  method handler (
    Gnome::GObject::Object :widget($application),
    *%user-options
    --> Int
  );

=item $application; the application


=end pod


#-------------------------------------------------------------------------------
=begin pod
=head1 Properties

An example of using a string type property of a B<Gnome::Gtk3::Label> object. This is just showing how to set/read a property, not that it is the best way to do it. This is because a) The class initialization often provides some options to set some of the properties and b) the classes provide many methods to modify just those properties. In the case below one can use B<new(:label('my text label'))> or B<gtk_label_set_text('my text label')>.

  my Gnome::Gtk3::Label $label .= new(:empty);
  my Gnome::GObject::Value $gv .= new(:init(G_TYPE_STRING));
  $label.g-object-get-property( 'label', $gv);
  $gv.g-value-set-string('my text label');

=head2 Supported properties

=comment #TP:0:application-id:
=head3 Application identifier

The unique identifier for the application
Default value: Any


The B<Gnome::GObject::Value> type of property I<application-id> is C<G_TYPE_STRING>.

=comment #TP:0:flags:
=head3 Application flags



The B<Gnome::GObject::Value> type of property I<flags> is C<G_TYPE_FLAGS>.

=comment #TP:0:resource-base-path:
=head3 Resource base path

The base resource path for the application
Default value: Any


The B<Gnome::GObject::Value> type of property I<resource-base-path> is C<G_TYPE_STRING>.

=comment #TP:0:is-registered:
=head3 Is registered

If g_application_register( has been called)
Default value: False


The B<Gnome::GObject::Value> type of property I<is-registered> is C<G_TYPE_BOOLEAN>.

=comment #TP:0:is-remote:
=head3 Is remote

If this application instance is remote
Default value: False


The B<Gnome::GObject::Value> type of property I<is-remote> is C<G_TYPE_BOOLEAN>.

=comment #TP:0:inactivity-timeout:
=head3 Inactivity timeout



The B<Gnome::GObject::Value> type of property I<inactivity-timeout> is C<G_TYPE_UINT>.

=comment #TP:0:action-group:
=head3 Action group

The group of actions that the application exports
Widget type: G_TYPE_ACTION_GROUP


The B<Gnome::GObject::Value> type of property I<action-group> is C<G_TYPE_OBJECT>.

=comment #TP:0:is-busy:
=head3 Is busy


Whether the application is currently marked as busy through
C<g_application_mark_busy()> or C<g_application_bind_busy_property()>.
The B<Gnome::GObject::Value> type of property I<is-busy> is C<G_TYPE_BOOLEAN>.
=end pod
