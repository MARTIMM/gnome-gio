#TL:1:Gnome::Gio::Application:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Application

Core application class

=comment ![](images/X.png)

=head1 Description

A B<Gnome::Gio::Application> is the foundation of an application.  It wraps some low-level platform-specific services and is intended to act as the foundation for higher-level application classes such as B<Gnome::Gtk3::Application>. In general, you should not use this class outside of a higher level framework.

B<Gnome::Gio::Application> provides convenient life cycle management by maintaining a "use count" for the primary application instance. The use count can be changed using C<hold()> and C<release()>. If it drops to zero, the application exits. Higher-level classes such as B<Gnome::Gtk3::Application> employ the use count to ensure that the application stays alive as long as it has any opened windows.

Another feature that B<Gnome::Gio::Application> (optionally) provides is process uniqueness. Applications can make use of this functionality by providing a unique application ID. If given, only one application with this ID can be running at a time per session. The session concept is platform-dependent, but corresponds roughly to a graphical desktop login. When your application is launched again, its arguments are passed through platform communication to the already running program. The already running instance of the program is called the "primary instance"; for non-unique applications this is the always the current instance. On Linux, the D-Bus session bus is used for communication.

The use of B<Gnome::Gio::Application> differs from some other commonly-used uniqueness libraries (such as libunique) in important ways. The application is not expected to manually register itself and check if it is the primary instance. Instead, the Raku main program of a B<Gnome::Gio::Application> based application should do very little more than instantiating the application instance, possibly connecting signal handlers, then calling C<run()>. All checks for uniqueness are done internally. If the application is the primary instance then the startup signal is emitted and the mainloop runs. If the application is not the primary instance then a signal is sent to the primary instance and C<run()> promptly returns.
=comment See the code examples below.

If used, the expected form of an application identifier is the same as that of of a L<D-Bus well-known bus name|https://dbus.freedesktop.org/doc/dbus-specification.html#message-protocol-names-bus>. Examples include: `com.example.MyApp`, `org.example.internal_apps.Calculator`, `org._7_zip.Archiver`. For details on valid application identifiers, see C<id-is-valid()>. Note; the Raku implementation of C<new(:app-id)> checks the id using that routine.

On Linux, the application identifier is claimed as a well-known bus name on the user's session bus.  This means that the uniqueness of your application is scoped to the current session.  It also means that your application may provide additional services (through registration of other object paths) at that bus name.  The registration of these object paths should be done with the shared GDBus session bus.  Note that due to the internal architecture of GDBus, method calls can be dispatched at any time (even if a main loop is not running).  For this reason, you must ensure that any object paths that you wish to register are registered before B<Gnome::Gio::Application> attempts to acquire the bus name of your application (which happens in C<register()>).  Unfortunately, this means that you cannot use C<get-is-remote()> to decide if you want to register object paths.

B<Gnome::Gio::Application> also implements the B<Gnome::Gio::ActionGroup> and B<Gnome::Gio::ActionMap> interfaces and lets you easily export actions by adding them with C<add-action()>. When invoking an action by calling C<activate-action()> on the application, it is always invoked in the primary instance. The actions are also exported on the session bus, and GIO provides the B<Gnome::Gio::DBusActionGroup> wrapper to conveniently access them remotely. GIO provides a B<Gnome::Gio::DBusMenuModel> wrapper for remote access to exported GMenuModels.

There is a number of different entry points into a B<Gnome::Gio::Application>:

=item via 'Activate' (i.e. just starting the application)
=comment item via 'Open' (i.e. opening some files).
=item by handling a command-line
=item via activating an action

The  I<startup> signal lets you handle the application initialization for all of these in a single place.

=comment Regardless of which of these entry points is used to start the application, B<Gnome::Gio::Application> passes some "platform data from the launching instance to the primary instance, in the form of a B<GVariant> dictionary mapping strings to variants. To use platform data, override the I<before_emit> or I<after_emit> virtual functions in your B<Gnome::Gio::Application> subclass.

When dealing with B<Gnome::Gio::ApplicationCommandLine> objects, the platform data is directly available via C<get-cwd()>, C<get-environ()> and C<get-platform-data()> in that object.

As the name indicates, the platform data may vary depending on the operating system, but it always includes the current directory
=comment (key "cwd")
, and optionally the environment (ie the set of environment variables and their values) of the calling process
=comment (key "environ")
. The environment is only added to the platform data if the C<G_APPLICATION_SEND_ENVIRONMENT> flag is set.
=comment B<Gnome::Gio::Application> subclasses can add their own platform data by overriding the I<add_platform_data> virtual function. For instance, B<Gnome::Gtk3::Application> adds startup notification data in this way.

=comment To parse commandline arguments you may handle the I<command-line> signal or override the C<local_command_line()> vfunc, to parse them in either the primary instance or the local instance, respectively.

=comment For an example of opening files with a B<Gnome::Gio::Application>, see [Gnome::Gio::Application-example-open.c](https://git.gnome.org/browse/glib/tree/gio/tests/Gnome::Gio::Application-example-open.c).

=comment For an example of using actions with Gnome::Gio::Application, see [Gnome::Gio::Application-example-actions.c](https://git.gnome.org/browse/glib/tree/gio/tests/Gnome::Gio::Application-example-actions.c).

=comment For an example of using extra D-Bus hooks with Gnome::Gio::Application, see [Gnome::Gio::Application-example-dbushooks.c](https://git.gnome.org/browse/glib/tree/gio/tests/Gnome::Gio::Application-example-dbushooks.c).

=head2 See Also
=item L<Application tutorial|/gnome-gtk3/content-docs/tutorial/Application/introduction.html>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::Application;
  also is Gnome::GObject::Object;
  also does Gnome::Gio::ActionMap;
  also does Gnome::Gio::ActionGroup;


=head2 Uml Diagram
![](plantuml/Application.svg)


=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::Error;

use Gnome::GObject::Object;

use Gnome::Gio::Enums;
use Gnome::Gio::File;
use Gnome::Gio::ActionMap;
use Gnome::Gio::ActionGroup;
use Gnome::Gio::Notification;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::Application:auth<github:MARTIMM>;
also is Gnome::GObject::Object;
also does Gnome::Gio::ActionMap;
also does Gnome::Gio::ActionGroup;

#-------------------------------------------------------------------------------
my Bool $signals-added = False;

#`{{
#-------------------------------------------------------------------------------
# next GOptionFlags and GOptionArg copied from GOptionContext to use in
# g_application_add_main_option without implementing a Raku module
=begin pod
=head2 enum GOptionFlags

Flags which modify individual options.

=item G_OPTION_FLAG_NONE: No flags.
=item G_OPTION_FLAG_HIDDEN: The option doesn't appear in `--help` output.
=item G_OPTION_FLAG_IN_MAIN: The option appears in the main section of the `--help` output, even if it is defined in a group.
=item G_OPTION_FLAG_REVERSE: For options of the C<G_OPTION_ARG_NONE> kind, this flag indicates that the sense of the option is reversed.
=item G_OPTION_FLAG_NO_ARG: For options of the C<G_OPTION_ARG_CALLBACK> kind, this flag indicates that the callback does not take any argument (like a C<G_OPTION_ARG_NONE> option).
=item G_OPTION_FLAG_FILENAME: For options of the C<G_OPTION_ARG_CALLBACK> kind, this flag indicates that the argument should be passed to the callback in the GLib filename encoding rather than UTF-8.
=item G_OPTION_FLAG_OPTIONAL_ARG: For options of the C<G_OPTION_ARG_CALLBACK>  kind, this flag indicates that the argument supply is optional. If no argument is given then data of C<N-GOptionParseFunc> will be set to NULL.
=item G_OPTION_FLAG_NOALIAS: This flag turns off the automatic conflict resolution which prefixes long option names with `groupname-` if  there is a conflict. This option should only be used in situations where aliasing is necessary to model some legacy commandline interface. It is not safe to use this option, unless all option groups are under your direct control.

=end pod

# TE:1:GOptionFlags:
enum GOptionFlags is export (
  'G_OPTION_FLAG_NONE'            => 0,
  'G_OPTION_FLAG_HIDDEN'		      => 1 +< 0,
  'G_OPTION_FLAG_IN_MAIN'		      => 1 +< 1,
  'G_OPTION_FLAG_REVERSE'		      => 1 +< 2,
  'G_OPTION_FLAG_NO_ARG'		      => 1 +< 3,
  'G_OPTION_FLAG_FILENAME'	      => 1 +< 4,
  'G_OPTION_FLAG_OPTIONAL_ARG'    => 1 +< 5,
  'G_OPTION_FLAG_NOALIAS'	        => 1 +< 6
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GOptionArg

The B<GOptionArg> enum values determine which type of extra argument the
options expect to find. If an option expects an extra argument, it can
be specified in several ways; with a short option: `-x arg`, with a long
option: `--name arg` or combined in a single argument: `--name=arg`.


=item G_OPTION_ARG_NONE: No extra argument. This is useful for simple flags.
=item G_OPTION_ARG_STRING: The option takes a string argument.
=item G_OPTION_ARG_INT: The option takes an integer argument.
=item G_OPTION_ARG_CALLBACK: The option provides a callback (of type B<N-GOptionArgFunc>) to parse the extra argument.
=item G_OPTION_ARG_FILENAME: The option takes a filename as argument.
=item G_OPTION_ARG_STRING_ARRAY: The option takes a string argument, multiple uses of the option are collected into an array of strings.
=item G_OPTION_ARG_FILENAME_ARRAY: The option takes a filename as argument,  multiple uses of the option are collected into an array of strings.
=item G_OPTION_ARG_DOUBLE: The option takes a double argument. The argument can be formatted either for the user's locale or for the "C" locale.
=item G_OPTION_ARG_INT64: The option takes a 64-bit integer. Like C<G_OPTION_ARG_INT> but for larger numbers. The number can be in decimal base, or in hexadecimal (when prefixed with `0x`, for example, `0xffffffff`).


=end pod

# TE:1:GOptionArg:
enum GOptionArg is export (
  'G_OPTION_ARG_NONE',
  'G_OPTION_ARG_STRING',
  'G_OPTION_ARG_INT',
  'G_OPTION_ARG_CALLBACK',
  'G_OPTION_ARG_FILENAME',
  'G_OPTION_ARG_STRING_ARRAY',
  'G_OPTION_ARG_FILENAME_ARRAY',
  'G_OPTION_ARG_DOUBLE',
  'G_OPTION_ARG_INT64'
);
}}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 default, no options

Create a new Application object with an empty application id and flags set to G_APPLICATION_FLAGS_NONE.

  multi method new ( )


=head3 :default

Sets the default B<GApplication> instance for this process.

Normally there is only one B<GApplication> per process and it becomes the default when it is created. You can exercise more control over this by using C<set-default()>. If there is no default application then this object becomes invalid.

  multi method new ( :default! )


=head3 :app-id, :flags

Create a new object with a valid application id and a mask of GApplicationFlags values.

  multi method new (
    Bool :$app-id!, Int :$flags = G_APPLICATION_FLAGS_NONE
  )


=head3 :native-object

Create an object using a native object from elsewhere.

  multi method new ( N-GObject :$native-object! )

=end pod
#TM:1:new(:app-id):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # add signal info in the form of group<signal-name>.
  # groups are e.g. signal, event, nativeobject etc
  $signals-added = self.add-signal-types( $?CLASS.^name,
    :w0<startup shutdown activate name-lost>,
    :w1<command-line handle-local-options>,
    :w3<open>,
  ) unless $signals-added;


  # prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::Application' {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }


    # process all named arguments
    else {
      my $no;

      if ? %options<app-id> {
        if g_application_id_is_valid(%options<app-id>) {
          my GApplicationFlags $f = %options<flags> // G_APPLICATION_FLAGS_NONE;
          $no = _g_application_new( %options<app-id>, $f);
        }

        else {
          die X::Gnome.new(
            :message("Invalid application id: %options<app-id>")
          );
        }
      }

      elsif %options<default>:exists {
        $no = _g_application_get_default;
      }


      #`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
      }}

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _g_application_new( '', G_APPLICATION_FLAGS_NONE);
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the widget, the gtype is known
    self._set-class-info('GApplication');
  }
}

#`{{
#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("g_application_$native-sub"); } unless ?$s;
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); }

  self._set-class-name-of-sub('GApplication');

  $s = callsame unless ?$s;

  $s;
}
}}

#-------------------------------------------------------------------------------
#TM:1:activate:
=begin pod
=head2 activate

Activates the application. In essence, this results in the I<activate> signal being emitted in the primary instance.  The application must be registered before calling this function.

  method activate ( )

=end pod

method activate ( ) {
  g_application_activate(self._get-native-object-no-reffing);
}

sub g_application_activate ( N-GObject $application  )
  is native(&gio-lib)
  { * }

#`{{ it works but we can better use Raku option management modules
#-------------------------------------------------------------------------------
#TM:1:add-main-option:
=begin pod
=head2 add-main-option

Add an option to be handled by the application.
=comment Calling this function is the equivalent of calling C<add-main-option-entries()> with a single B<GOptionEntry> that has its arg_data member set to C<undefined>.

The parsed arguments will be packed into a B<GVariantDict> which is passed to  I<handle-local-options>. If C<G_APPLICATION_HANDLES_COMMAND_LINE> is set, then it will also be sent to the primary instance.
=comment See C<g_application_add_main_option_entries()> for more details.  See B<GOptionEntry> for more documentation of the arguments.

  method add-main-option ( Str $long_name, Str $short_name, GOptionFlags $flags,
    GOptionArg $arg, Str $description, Str $arg_description?
  )

=item Str $long_name; the long name of an option used to specify it in a commandline
=item Str $short_name; the short name of an option, C<I<B<ONE>>> ascii character.
=item GOptionFlags $flags; flags from B<GOptionFlags>
=item GOptionArg $arg; the type of the option, as a B<GOptionArg>
=item Str $description; the description for the option in `--help` output
=item Str $arg_description; the placeholder to use for the extra argument parsed by the option in `--help` output

=head3 Example

  $app.add-main-option(
    'flip-it', 'f', G_OPTION_FLAG_IN_MAIN,
    G_OPTION_ARG_NONE, 'flips it to the other side'
  );

=end pod

method add-main-option ( Str $long_name, Str $short_name, GOptionFlags $flags,
  GOptionArg $arg, Str $description, Str $arg_description?
) {

  g_application_add_main_option(
    self._get-native-object-no-reffing, $long_name, $short_name.encode[0],
    $flags.Int, $arg, $description, $arg_description
  );
}

sub g_application_add_main_option ( N-GObject $application, gchar-ptr $long_name, gchar $short_name, GEnum $flags, GEnum $arg, gchar-ptr $description, gchar-ptr $arg_description
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:add-main-option-entries:
=begin pod
=head2 add-main-option-entries

Adds main option entries to be handled by the application.

This function is comparable to C<g_option_context_add_main_entries()>.

After the commandline arguments are parsed, the  I<handle-local-options> signal will be emitted.  At this point, the application can inspect the values pointed to by I<arg_data> in the given B<GOptionEntrys>.

Unlike B<GOptionContext>, B<GApplication> supports giving a C<undefined> I<arg_data> for a non-callback B<GOptionEntry>.  This results in the argument in question being packed into a B<GVariantDict> which is also passed to  I<handle-local-options>, where it can be inspected and modified.  If C<G_APPLICATION_HANDLES_COMMAND_LINE> is set, then the resulting dictionary is sent to the primary instance, where C<g_application_command_line_get_options_dict()> will return it. This "packing" is done according to the type of the argument -- booleans for normal flags, strings for strings, bytestrings for filenames, etc.  The packing only occurs if the flag is given (ie: we do not pack a "false" B<GVariant> in the case that a flag is missing).

In general, it is recommended that all commandline arguments are parsed locally.  The options dictionary should then be used to transmit the result of the parsing to the primary instance, where C<g_variant_dict_lookup()> can be used.  For local options, it is possible to either use I<arg_data> in the usual way, or to consult (and potentially remove) the option from the options dictionary.

This function is new in GLib 2.40.  Before then, the only real choice was to send all of the commandline arguments (options and all) to the primary instance for handling.  B<GApplication> ignored them completely on the local side.  Calling this function "opts in" to the new behaviour, and in particular, means that unrecognised options will be treated as errors.  Unrecognised options have never been ignored when C<G_APPLICATION_HANDLES_COMMAND_LINE> is unset.

If  I<handle-local-options> needs to see the list of filenames, then the use of C<G_OPTION_REMAINING> is recommended.  If I<arg_data> is C<undefined> then C<G_OPTION_REMAINING> can be used as a key into the options dictionary.  If you do use C<G_OPTION_REMAINING> then you need to handle these arguments for yourself because once they are consumed, they will no longer be visible to the default handling (which treats them as filenames to be opened).

It is important to use the proper GVariant format when retrieving the options with C<g_variant_dict_lookup()>:
=item for C<G_OPTION_ARG_NONE>, use b
=item for C<G_OPTION_ARG_STRING>, use &s
=item for C<G_OPTION_ARG_INT>, use i
=item for C<G_OPTION_ARG_INT64>, use x
=item for C<G_OPTION_ARG_DOUBLE>, use d
=item for C<G_OPTION_ARG_FILENAME>, use ^ay
=item for C<G_OPTION_ARG_STRING_ARRAY>, use &as
=item for C<G_OPTION_ARG_FILENAME_ARRAY>, use ^aay

  method add-main-option-entries ( GOptionEntry $entries )

=item GOptionEntry $entries; (array zero-terminated=1) (element-type GOptionEntry) a C<undefined>-terminated list of B<GOptionEntrys>

=end pod

method add-main-option-entries ( GOptionEntry $entries ) {

  g_application_add_main_option_entries(
    self._get-native-object-no-reffing, $entries
  );
}

sub g_application_add_main_option_entries ( N-GObject $application, GOptionEntry $entries  )
  is native(&gio-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:add-option-group:
=begin pod
=head2 add-option-group

Adds a B<GOptionGroup> to the commandline handling of the application.  This function is comparable to C<g_option_context_add_group()>.  Unlike C<g_application_add_main_option_entries()>, this function does not deal with C<undefined> I<arg_data> and never transmits options to the primary instance.  The reason for that is because, by the time the options arrive at the primary instance, it is typically too late to do anything with them. Taking the GTK option group as an example: GTK will already have been initialised by the time the  I<command-line> handler runs. In the case that this is not the first-running instance of the application, the existing instance may already have been running for a very long time.  This means that the options from B<GOptionGroup> are only really usable in the case that the instance of the application being run is the first instance.  Passing options like `--display=` or `--gdk-debug=` on future runs will have no effect on the existing primary instance.  Calling this function will cause the options in the supplied option group to be parsed, but it does not cause you to be "opted in" to the new functionality whereby unrecognised options are rejected even if C<G_APPLICATION_HANDLES_COMMAND_LINE> was given.

  method add-option-group ( GOptionGroup $group )

=item GOptionGroup $group; (transfer full): a B<GOptionGroup>

=end pod

method add-option-group ( GOptionGroup $group ) {

  g_application_add_option_group(
    self._get-native-object-no-reffing, $group
  );
}

sub g_application_add_option_group ( N-GObject $application, GOptionGroup $group  )
  is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:bind-busy-property:
=begin pod
=head2 bind-busy-property

Marks the application as busy (see C<g_application_mark_busy()>) while I<$property> on I<$object> is C<True>.  The binding holds a reference to the application while it is active, but not to I<object>. Instead, the binding is destroyed when I<$object> is finalized.

  method bind-busy-property ( Pointer $object, Str $property )

=item Pointer $object; (type GObject.Object): a B<GObject>
=item Str $property; the name of a boolean property of I<object>

=end pod

method bind-busy-property ( Pointer $object, Str $property ) {

  g_application_bind_busy_property(
    self._get-native-object-no-reffing, $object, $property
  );
}

sub g_application_bind_busy_property ( N-GObject $application, gpointer $object, gchar-ptr $property  )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:get-application-id:
=begin pod
=head2 get-application-id

Gets the unique identifier for the application.

Returns: the identifier for the application, owned by the application

  method get-application-id ( --> Str )

=end pod

method get-application-id ( --> Str ) {

  g_application_get_application_id(
    self._get-native-object-no-reffing,
  );
}

sub g_application_get_application_id ( N-GObject $application --> gchar-ptr )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-dbus-connection:
=begin pod
=head2 get-dbus-connection

Gets the B<GDBusConnection> being used by the application, or C<undefined>.  If B<GApplication> is using its D-Bus backend then this function will return the B<GDBusConnection> being used for uniqueness and communication with the desktop environment and other instances of the application.  If B<GApplication> is not using D-Bus then this function will return C<undefined>.  This includes the situation where the D-Bus backend would normally be in use but we were unable to connect to the bus.  This function must not be called before the application has been registered.  See C<g_application_get_is_registered()>.

Returns: (transfer none): a B<GDBusConnection>, or C<undefined>

  method get-dbus-connection ( --> GDBusConnection )


=end pod

method get-dbus-connection ( --> GDBusConnection ) {

  g_application_get_dbus_connection(
    self._get-native-object-no-reffing,
  );
}

sub g_application_get_dbus_connection ( N-GObject $application --> GDBusConnection )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:4:get-dbus-object-path:ex-application.raku
=begin pod
=head2 get-dbus-object-path

Gets the D-Bus object path being used by the application, or C<undefined>.  If B<GApplication> is using its D-Bus backend then this function will return the D-Bus object path that B<GApplication> is using.  If the application is the primary instance then there is an object published at this path.  If the application is not the primary instance then the result of this function is undefined.  If B<GApplication> is not using D-Bus then this function will return C<undefined>.  This includes the situation where the D-Bus backend would normally be in use but we were unable to connect to the bus.  This function must not be called before the application has been registered.  See C<g_application_get_is_registered()>.

Returns: the object path, or C<undefined>

  method get-dbus-object-path ( --> Str )


=end pod

method get-dbus-object-path ( --> Str ) {

  g_application_get_dbus_object_path(
    self._get-native-object-no-reffing,
  );
}

sub g_application_get_dbus_object_path ( N-GObject $application --> gchar-ptr )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#`{{
#TM:0:_get-default:
=begin pod
=head2 get-default

Returns the default B<GApplication> instance for this process.

Normally there is only one B<GApplication> per process and it becomes the default when it is created. You can exercise more control over this by using C<set_default()>. If there is no default application then C<undefined> is returned.

Returns: the default application for this process, or C<undefined>

  method get-default ( --> GApplication )

=end pod

method get-default ( --> N-GObject ) {

  g_application_get_default( );
}
}}

sub _g_application_get_default ( --> N-GObject )
  is native(&gio-lib)
  is symbol('g_application_get_default')
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-flags:
=begin pod
=head2 get-flags

Gets the flags for the application.  See B<GApplicationFlags>.

Returns: a mask of ored GApplicationFlags flags for the application

  method get-flags ( --> Int )

=end pod

method get-flags ( --> Int ) {

  g_application_get_flags(self._get-native-object-no-reffing)
}

sub g_application_get_flags ( N-GObject $application --> GEnum )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-inactivity-timeout:
=begin pod
=head2 get-inactivity-timeout

Gets the current inactivity timeout for the application. This is the amount of time (in milliseconds) after the last call to C<release()> before the application stops running.

Returns: the timeout, in milliseconds

  method get-inactivity-timeout ( --> UInt )


=end pod

method get-inactivity-timeout ( --> UInt ) {

  g_application_get_inactivity_timeout(
    self._get-native-object-no-reffing,
  );
}

sub g_application_get_inactivity_timeout ( N-GObject $application --> guint )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-is-busy:
=begin pod
=head2 get-is-busy

Gets the application's current busy state, as set through C<g_application_mark_busy()> or C<g_application_bind_busy_property()>.

Returns: C<True> if the application is currenty marked as busy

  method get-is-busy ( --> Int )


=end pod

method get-is-busy ( --> Int ) {

  g_application_get_is_busy(
    self._get-native-object-no-reffing,
  );
}

sub g_application_get_is_busy ( N-GObject $application --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:5:get-is-registered:g_application_get_is_registered
=begin pod
=head2 get-is-registered

Checks if the application is registered.  An application is registered if C<g_application_register()> has been successfully called.

Returns: C<True> if the application is registered

  method get-is-registered ( --> Bool )

=end pod

method get-is-registered ( --> Bool ) {
  g_application_get_is_registered(self._get-native-object-no-reffing).Bool
}

sub g_application_get_is_registered ( N-GObject $application --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:get-is-remote:ex-application.raku
=begin pod
=head2 get-is-remote

Checks if the application is remote.  If the application is remote then it means that another instance of application already exists (the 'primary' instance).  Calls to perform actions on the application will result in the actions being performed by the primary instance.  The value of this property cannot be accessed before C<register()> has been called.  See C<get-is-registered()>.

Returns: C<True> if the application is remote

  method get-is-remote ( --> Bool )

=end pod

method get-is-remote ( --> Bool ) {

  g_application_get_is_remote(
    self._get-native-object-no-reffing,
  ).Bool
}

sub g_application_get_is_remote ( N-GObject $application --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-resource-base-path:
=begin pod
=head2 get-resource-base-path

Gets the resource base path of the application.  See C<g_application_set_resource_base_path()> for more information.

Returns: (nullable): the base resource path, if one is set

  method get-resource-base-path ( --> Str )


=end pod

method get-resource-base-path ( --> Str ) {

  g_application_get_resource_base_path(
    self._get-native-object-no-reffing,
  );
}

sub g_application_get_resource_base_path ( N-GObject $application --> gchar-ptr )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:hold:
=begin pod
=head2 hold

Increases the use count of the application.  Use this function to indicate that the application has a reason to continue to run.  For example, C<hold()> is called by GTK+ when a toplevel window is on the screen.  To cancel the hold, call C<release()>.

  method hold ( )


=end pod

method hold ( ) {

  g_application_hold(
    self._get-native-object-no-reffing,
  );
}

sub g_application_hold ( N-GObject $application  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:id-is-valid:
=begin pod
=head2 id-is-valid

Checks if I<$application_id> is a valid application identifier.
A valid ID is required for calls to C<new(:app-id)> and C<set-application-id()>.
Application identifiers follow the same format as L<D-Bus well-known bus names|https://dbus.freedesktop.org/doc/dbus-specification.html#message-protocol-names-bus>. For convenience, the restrictions on application identifiers are reproduced here:
=item Application identifiers are composed of 1 or more elements separated by a period (`.`) character. All elements must contain at least one character.
=item Each element must only contain the ASCII characters `[A-Z][a-z][0-9]_-`, with `-` discouraged in new application identifiers. Each element must not begin with a digit.
=item Application identifiers must contain at least one `.` (period) character (and thus at least two elements).
=item Application identifiers must not begin with a `.` (period) character.
=item Application identifiers must not exceed 255 characters.

Note that the hyphen (`-`) character is allowed in application identifiers, but is problematic or not allowed in various specifications and APIs that refer to D-Bus, such as L<Flatpak application IDs|http://docs.flatpak.org/en/latest/introduction.html#identifiers>, the L<DBusActivatable interface in the Desktop Entry Specification|https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#dbus>, and the convention that an application's "main" interface and object path resemble its application identifier and bus name. To avoid situations that require special-case handling, it is recommended that new application identifiers consistently replace hyphens with underscores.

Like D-Bus interface names, application identifiers should start with the reversed DNS domain name of the author of the interface (in lower-case), and it is conventional for the rest of the application identifier to consist of words run together, with initial capital letters.

As with D-Bus interface names, if the author's DNS domain name contains hyphen/minus characters they should be replaced by underscores, and if it contains leading digits they should be escaped by prepending an underscore. For example, if the owner of 7-zip.org used an application identifier for an archiving application, it might be named `org._7_zip.Archiver`.

Returns: C<True> if I<$application_id> is valid

  method id-is-valid ( Str $application_id --> Bool )

=item Str $application_id; a potential application identifier

=end pod

method id-is-valid ( Str $application_id --> Bool ) {

  g_application_id_is_valid($application_id).Bool;
}

sub g_application_id_is_valid ( gchar-ptr $application_id --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mark-busy:
=begin pod
=head2 mark-busy

Increases the busy count of the application.  Use this function to indicate that the application is busy, for instance while a long running operation is pending.  The busy state will be exposed to other processes, so a session shell will use that information to indicate the state to the user (e.g. with a spinner).  To cancel the busy indication, use C<g_application_unmark_busy()>.

  method mark-busy ( )


=end pod

method mark-busy ( ) {

  g_application_mark_busy(
    self._get-native-object-no-reffing,
  );
}

sub g_application_mark_busy ( N-GObject $application  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:open:
=begin pod
=head2 open

Opens the given files.
In essence, this results in the I<open> signal being emitted in the primary instance. I<$hint> is simply passed through to the I<open> signal. It is intended to be used by applications that have multiple modes for opening files (eg: "view" vs "edit", etc). Unless you have a need for this functionality, you should use "". The application must be registered before calling this function and it must have the C<G_APPLICATION_HANDLES_OPEN> flag set.

  method open ( Array[Str] $files, Str $hint )

=item Array[Str] $files; an array of filenames to open
=item Str $hint; a hint (or ""), but never C<undefined>.

=end pod

method open ( Array $files, Str $hint ) {
  my Int $n_files = $files.elems;
  return unless $n_files;

  my $fa = CArray[N-GFile].new();
  my Int $i = 0;
  for @$files -> $file {
    if $file ~~ m/ '://' / {
      $fa[$i++] =
        Gnome::Gio::File.new(:uri($file))._get-native-object-no-reffing;
    }

    else {
      $fa[$i++] =
        Gnome::Gio::File.new(:path($file))._get-native-object-no-reffing;
    }
  }

  g_application_open(
    self._get-native-object-no-reffing, $fa, $n_files, $hint
  );
}

sub g_application_open (
  N-GObject $application, CArray[N-GFile] $files, gint $n_files, gchar-ptr $hint
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:quit:ex-application.raku
=begin pod
=head2 quit

Immediately quits the application.
Upon return to the mainloop, C<run()> will return, calling only the 'shutdown' function before doing so. The hold count is ignored. Take care if your code has called C<hold()> on the application and is therefore still expecting it to exist. (Note that you may have called C<hold()> indirectly, for example through C<add-window()>.) The result of calling C<run()> again after it returns is unspecified.

  method quit ( )

=end pod

method quit ( ) {
  g_application_quit(
    self._get-native-object-no-reffing,
  );
}

sub g_application_quit ( N-GObject $application  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:register:
=begin pod
=head2 register

Attempts registration of the application. This is the point at which the application discovers if it is the primary instance or merely acting as a remote for an already-existing primary instance.

This is implemented by attempting to acquire the application identifier as a unique bus name on the session bus using GDBus. If there is no application ID or if C<G_APPLICATION_NON_UNIQUE> was given, then this process will always become the primary instance.  Due to the internal architecture of GDBus, method calls can be dispatched at any time (even if a main loop is not running).
For this reason, you must ensure that any object paths that you wish to register are registered before calling this function.  If the application has already been registered then an invalid error object is returned with no work performed.

The I<startup> signal is emitted if registration succeeds and the application is the primary instance (including the non-unique case).  In the event of an error (such as I<cancellable> being cancelled, or a failure to connect to the session bus), then the error object is set appropriately.  Note: the return value of this function is not an indicator that this instance is or is not the primary instance of the application.  See C<get-is-remote()> for that.

Returns: Gnome::Glib::Error. if registration succeeded the error object is invalid.

  method register ( N-GObject $cancellable --> Gnome::Glib::Error )

=item N-GObject $cancellable; a B<N-GObject>, or C<undefined>

=end pod

method register ( N-GObject $cancellable = N-GObject --> Gnome::Glib::Error ) {

  my CArray[N-GError] $e .= new(N-GError);
  my $r = g_application_register(
    self._get-native-object-no-reffing, $cancellable, $e
  );

  my Gnome::Glib::Error $error;
  if $r {
    $error .= new(:native-object($e[0]));
  }

  else {
    $error .= new(:native-object(N-GError));
  }

  $error
}

sub g_application_register (
  N-GObject $application, N-GObject $cancellable,
  CArray[N-GError] $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:release:ex-application.raku
=begin pod
=head2 release

Decrease the use count of the application.  When the use count reaches zero, the application will stop running.  Never call this function except to cancel the effect of a previous call to C<hold()>.

  method release ( )


=end pod

method release ( ) {

  g_application_release(
    self._get-native-object-no-reffing,
  );
}

sub g_application_release ( N-GObject $application  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:run:ex-application.pl6
=begin pod
=head2 run

Runs the application.

This function is intended to be run from C<main()> and its return value is intended to be returned by your main program.

B<Gnome::Gio::Application> will attempt to parse the commandline arguments read from `@*ARGS`. You can add commandline flags to the list of recognized options by way of C<add-main-option-entries()>. After this, the I<handle-local-options> signal is emitted, from which the application can inspect the values of its B<N-GOptionEntrys>.

I<handle-local-options> is a good place to handle options such as `--version`, where an immediate reply from the local process is desired (instead of communicating with an already-running instance). A  I<handle-local-options> handler can stop further processing by returning a non-negative value, which then becomes the exit status of the process.

What happens next depends on the flags: if C<G_APPLICATION_HANDLES_COMMAND_LINE> was specified then the remaining commandline arguments are sent to the primary instance, where a I<command-line> signal is emitted.  Otherwise, the remaining commandline arguments are assumed to be a list of files. If there are no files listed, the application is activated via the I<activate> signal. If there are one or more files, and C<G_APPLICATION_HANDLES_OPEN> was specified then the files are opened via the  I<open> signal.

=begin comment
If you are interested in doing more complicated local handling of the commandline then you should implement your own B<Gnome::Gio::Application> subclass and override C<local_command_line()>. In this case, you most likely want to return C<1> from your C<local_command_line()> implementation to suppress the default handling. See Gnome::Gio::Application-example-cmdline2.c for an example.
=end comment

If, after the above is done, the use count of the application is zero then the exit status is returned immediately.  If the use count is non-zero then the default main context is iterated until the use count falls to zero, at which point 0 is returned.

If the C<G_APPLICATION_IS_SERVICE> flag is set, then the service will run for as much as 10 seconds with a use count of zero while waiting for the message that caused the activation to arrive. When a message arrives, the use count is increased. After that, if the use count falls back to zero or stays zero, the application will exit immediately, except in the case that C<g_application_set_inactivity_timeout()> is in use.

=comment This function sets the program name (C<g_set_prgname()>), if not already set, to the basename of argv[0] which is set when C<run()> is called.

Much like C<run()> from B<Gnome::Glib::MainLoop>, this function will acquire the main context for the duration that the application is running.

=comment Applications that are not explicitly flagged as services or launchers (ie: neither C<G_APPLICATION_IS_SERVICE> or C<G_APPLICATION_IS_LAUNCHER> are given as flags) will check (from the default handler for local_command_line)

Applications that are not explicitly flagged as services or launchers will check if "--gapplication-service" was given in the command line.  If this flag is present then normal commandline processing is interrupted and the C<G_APPLICATION_IS_SERVICE> flag is set.  This provides a "compromise" solution whereby running an application directly from the commandline will invoke it in the normal way (which can be useful for debugging) while still allowing applications to be D-Bus activated in service mode.  The D-Bus service file should invoke the executable with "--gapplication-service" as the sole commandline argument.  This approach is suitable for use by most graphical applications but should not be used from applications like editors that need precise control over when processes invoked via the commandline will exit and what their exit status will be.

Returns: the exit status

  method run ( --> Int )

=end pod

method run ( --> Int ) {

  my Int $argc = 1 + @*ARGS.elems;

  my $argv = CArray[Str].new;
  my Int $arg-count = 0;
  $argv[$arg-count++] = $*PROGRAM.Str;
  for @*ARGS -> $arg {
    $argv[$arg-count++] = $arg;
  }

  g_application_run(
    self._get-native-object-no-reffing, $argc, $argv
  );
}

sub g_application_run (
  N-GObject $application, gint $argc, gchar-pptr $argv --> gint
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:send-notification:ex-application.pl6
=begin pod
=head2 send-notification

Sends a notification on behalf of the application to the desktop shell. There is no guarantee that the notification is displayed immediately, or even at all.  Notifications may persist after the application exits. It will be D-Bus-activated when the notification or one of its actions is activated.  Modifying I<notification> after this call has no effect. However, the object can be reused for a later call to this function.  I<id> may be any string that uniquely identifies the event for the application. It does not need to be in any special format. For example, "new-message" might be appropriate for a notification about new messages.  If a previous notification was sent with the same I<id>, it will be replaced with I<notification> and shown again as if it was a new notification. This works even for notifications sent from a previous execution of the application, as long as I<id> is the same string.  I<id> may be C<undefined>, but it is impossible to replace or withdraw notifications without an id.  If I<notification> is no longer relevant, it can be withdrawn with C<g_application_withdraw_notification()>.

  method send-notification ( Str $id, N-GObject $notification )

=item Str $id; id of the notification, or C<undefined>
=item N-GObject $notification; the B<GNotification> to send

=end pod

method send-notification ( Str $id, $notification is copy ) {
  $notification .= _get-native-object-no-reffing
    unless $notification ~~ N-GObject;

  g_application_send_notification(
    self._get-native-object-no-reffing, $id, $notification
  );
}

sub g_application_send_notification ( N-GObject $application, gchar-ptr $id, N-GObject $notification  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-application-id:
=begin pod
=head2 set-application-id

Sets the unique identifier for the application.  The application id can only be modified if the application has not yet been registered. If defined, the application id must be valid.  See C<id-is-valid()>.

  method set-application-id (Str$application_id )

=item Str $application_id; the identifier for the application

=end pod

method set-application-id ( Str $application_id ) {

  g_application_set_application_id(
    self._get-native-object-no-reffing, $application_id
  );
}

sub g_application_set_application_id ( N-GObject $application, gchar-ptr $application_id  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-default:
=begin pod
=head2 set-default

Sets or unsets the default application for the process, as returned by C<g_application_get_default()>.  This function does not take its own reference on the application.  If the application is destroyed then the default application will revert back to C<undefined>.

  method set-default ( )


=end pod

method set-default ( ) {

  g_application_set_default(
    self._get-native-object-no-reffing,
  );
}

sub g_application_set_default ( N-GObject $application  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-flags:
=begin pod
=head2 set-flags

Sets the flags for the application.  The flags can only be modified if the application has not yet been registered.  See B<GApplicationFlags>.

  method set-flags ( Int $flags )

=item Int $flags; an ored mask of GApplicationFlags for the application

=end pod

method set-flags ( Int $flags ) {
  g_application_set_flags(
    self._get-native-object-no-reffing, $flags.Int
  );
}

sub g_application_set_flags ( N-GObject $application, GEnum $flags  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-inactivity-timeout:
=begin pod
=head2 set-inactivity-timeout

Sets the current inactivity timeout for the application.  This is the amount of time (in milliseconds) after the last call to C<g_application_release()> before the application stops running.  This call has no side effects of its own.  The value set here is only used for next time C<g_application_release()> drops the use count to zero.  Any timeouts currently in progress are not impacted.

  method set-inactivity-timeout ( UInt $inactivity_timeout )

=item UInt $inactivity_timeout; the timeout, in milliseconds

=end pod

method set-inactivity-timeout ( UInt $inactivity_timeout ) {

  g_application_set_inactivity_timeout(
    self._get-native-object-no-reffing, $inactivity_timeout
  );
}

sub g_application_set_inactivity_timeout ( N-GObject $application, guint $inactivity_timeout  )
  is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:set-option-context-description:
=begin pod
=head2 set-option-context-description

Adds a description to the the application option context.  See C<g_option_context_set_description()> for more information.

  method set-option-context-description ( Str $description )

=item Str $description; (nullable): a string to be shown in `--help` output after the list of options, or C<undefined>

=end pod

method set-option-context-description ( Str $description ) {

  g_application_set_option_context_description(
    self._get-native-object-no-reffing, $description
  );
}

sub g_application_set_option_context_description ( N-GObject $application, gchar-ptr $description  )
  is native(&gio-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:set-option-context-parameter-string:
=begin pod
=head2 set-option-context-parameter-string

Sets the parameter string to be used by the commandline handling of the application.  This function registers the argument to be passed to C<g_option_context_new()> when the internal B<GOptionContext> of the application is created.  See C<g_option_context_new()> for more information about I<parameter_string>.

  method set-option-context-parameter-string ( Str $parameter_string )

=item Str $parameter_string; (nullable): a string which is displayed in the first line of `--help` output, after the usage summary `programname [OPTION...]`.

=end pod

method set-option-context-parameter-string ( Str $parameter_string ) {

  g_application_set_option_context_parameter_string(
    self._get-native-object-no-reffing, $parameter_string
  );
}

sub g_application_set_option_context_parameter_string ( N-GObject $application, gchar-ptr $parameter_string  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-option-context-summary:
=begin pod
=head2 set-option-context-summary

Adds a summary to the the application option context.  See C<g_option_context_set_summary()> for more information.

  method set-option-context-summary ( Str $summary )

=item Str $summary; (nullable): a string to be shown in `--help` output before the list of options, or C<undefined>

=end pod

method set-option-context-summary ( Str $summary ) {

  g_application_set_option_context_summary(
    self._get-native-object-no-reffing, $summary
  );
}

sub g_application_set_option_context_summary ( N-GObject $application, gchar-ptr $summary  )
  is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:set-resource-base-path:
=begin pod
=head2 set-resource-base-path

Sets (or unsets) the base resource path of the application.  The path is used to automatically load various [application resources][gresource] such as menu layouts and action descriptions. The various types of resources will be found at fixed names relative to the given base path.  By default, the resource base path is determined from the application ID by prefixing '/' and replacing each '.' with '/'.  This is done at the time that the B<GApplication> object is constructed.  Changes to the application ID after that point will not have an impact on the resource base path.  As an example, if the application has an ID of "org.example.app" then the default resource base path will be "/org/example/app".  If this is a B<Gnome::Gtk3::Application> (and you have not manually changed the path) then B<Gnome::Gtk3:: will> then search for the menus of the application at "/org/example/app/gtk/menus.ui".  See B<GResource> for more information about adding resources to your application.  You can disable automatic resource loading functionality by setting the path to C<undefined>.  Changing the resource base path once the application is running is not recommended.  The point at which the resource path is consulted for forming paths for various purposes is unspecified.  When writing a sub-class of B<GApplication> you should either set the  I<resource-base-path> property at construction time, or call this function during the instance initialization. Alternatively, you can call this function in the B<GApplicationClass>.startup virtual function, before chaining up to the parent implementation.

  method set-resource-base-path ( Str $resource_path )

=item Str $resource_path; (nullable): the resource path to use

=end pod

method set-resource-base-path ( Str $resource_path ) {

  g_application_set_resource_base_path(
    self._get-native-object-no-reffing, $resource_path
  );
}

sub g_application_set_resource_base_path ( N-GObject $application, gchar-ptr $resource_path  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:unbind-busy-property:
=begin pod
=head2 unbind-busy-property

Destroys a binding between I<property> and the busy state of the application that was previously created with C<g_application_bind_busy_property()>.

  method unbind-busy-property ( Pointer $object, Str $property )

=item Pointer $object; (type GObject.Object): a B<GObject>
=item Str $property; the name of a boolean property of I<object>

=end pod

method unbind-busy-property ( Pointer $object, Str $property ) {

  g_application_unbind_busy_property(
    self._get-native-object-no-reffing, $object, $property
  );
}

sub g_application_unbind_busy_property ( N-GObject $application, gpointer $object, gchar-ptr $property  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:unmark-busy:
=begin pod
=head2 unmark-busy

Decreases the busy count of the application.  When the busy count reaches zero, the new state will be propagated to other processes.  This function must only be called to cancel the effect of a previous call to C<g_application_mark_busy()>.

  method unmark-busy ( )


=end pod

method unmark-busy ( ) {

  g_application_unmark_busy(
    self._get-native-object-no-reffing,
  );
}

sub g_application_unmark_busy ( N-GObject $application  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:withdraw-notification:ex-application.pl6
=begin pod
=head2 withdraw-notification

Withdraws a notification that was sent with C<g_application_send_notification()>.  This call does nothing if a notification with I<id> doesn't exist or the notification was never sent.  This function works even for notifications sent in previous executions of this application, as long I<id> is the same as it was for the sent notification.  Note that notifications are dismissed when the user clicks on one of the buttons in a notification or triggers its default action, so there is no need to explicitly withdraw the notification in that case.

  method withdraw-notification ( Str $id )

=item Str $id; id of a previously sent notification

=end pod

method withdraw-notification ( Str $id ) {

  g_application_withdraw_notification(
    self._get-native-object-no-reffing, $id
  );
}

sub g_application_withdraw_notification ( N-GObject $application, gchar-ptr $id  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_application_new:
#`{{
=begin pod
=head2 _g_application_new

Creates a new B<GApplication> instance.  If non-C<undefined>, the application id must be valid.  See C<g_application_id_is_valid()>.  If no application ID is given then some features of B<GApplication> (most notably application uniqueness) will be disabled.

Returns: a new B<GApplication> instance

  method _g_application_new ( Str $application_id, GApplicationFlags $flags --> GApplication )

=item Str $application_id; (nullable): the application id
=item GApplicationFlags $flags; the application flags

=end pod
}}

sub _g_application_new ( gchar-ptr $application_id, GEnum $flags --> N-GObject )
  is native(&gio-lib)
  is symbol('g_application_new')
  { * }


#-------------------------------------------------------------------------------
=begin pod
=head1 Signals

There are two ways to connect to a signal. The first option you have is to use C<register-signal()> from B<Gnome::GObject::Object>. The second option is to use C<connect-object()> directly from B<Gnome::GObject::Signal>.

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

Also here, the types of positional arguments in the signal handler are important. This is because both methods C<register-signal()> and C<connect-object()> are using the signatures of the handler routines to setup the native call interface.

=head2 Supported signals


=comment -----------------------------------------------------------------------
=comment #TS:1:activate:
=head3 activate

The I<activate> signal is emitted on the primary instance when an
activation occurs. See C<activate()>.

  method handler (
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($application),
    *%user-options
  );

=item $application; the application


=comment -----------------------------------------------------------------------
=comment #TS:4:command-line:ex-application.raku
=head3 command-line

The I<command-line> signal is emitted on the primary instance when
a commandline is not handled locally. See C<run()> and
the B<GApplicationCommandLine> documentation for more information.

Returns: An integer that is set as the exit status for the calling
process. See C<g_application_command_line_set_exit_status()>.

  method handler (
    N-GObject $command_line,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($application),
    *%user-options
    --> Int
  );

=item $application; the application, a B<Gnome::Gio::Application> object.

=item N-GObject $command_line; A native B<Gnome::Gio::ApplicationCommandLine> representing the
# A native Gnome::Gio::ApplicationCommandLine object
passed commandline

=comment -----------------------------------------------------------------------
=comment #TS:4:handle-local-options:ex-application.raku
=head3 handle-local-options

The I<handle-local-options> signal is emitted on the local instance
after the parsing of the commandline options has occurred.

You can add options to be recognised during commandline option
parsing using C<g_application_add_main_option_entries()> and
C<g_application_add_option_group()>.

Signal handlers can inspect I<options> (along with values pointed to
from the I<arg_data> of an installed B<GOptionEntrys>) in order to
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
the `--gapplication-service` switch works properly (i.e. no activation
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
    N-GObject $options,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($application),
    *%user-options
    --> Int
  );

=item $application; the application

=item $options; the options dictionary


=comment -----------------------------------------------------------------------
=comment #TS:0:name-lost:
=head3 name-lost

The I<name-lost> signal is emitted only on the registered primary instance
when a new instance has taken over. This can only happen if the application
is using the C<G_APPLICATION_ALLOW_REPLACEMENT> flag.

The default handler for this signal calls C<g_application_quit()>.

Returns: C<True> if the signal has been handled


  method handler (
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($application),
    *%user-options
    --> Int
  );

=item $application; the application


=comment -----------------------------------------------------------------------
=comment #TS:0:open:
=head3 open

The I<open> signal is emitted on the primary instance when there are
files to open. See C<open()> for more information.

  method handler (
    CArray[N-GFile] $files, Int $n_files, Str $hint,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($application),
    *%user-options
  );

=item $application; the application
=item $files; (array length=n_files) an array of B<N-GFiles>
=item $n_files; the length of I<files>
=item $hint; a hint provided by the calling instance


=comment -----------------------------------------------------------------------
=comment #TS:4:shutdown:ex-application.raku
=head3 shutdown

The I<shutdown> signal is emitted only on the registered primary instance
immediately after the main loop terminates.

  method handler (
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($application),
    *%user-options
  );

=item $application; the application


=comment -----------------------------------------------------------------------
=comment #TS:4:startup:ex-application.raku
=head3 startup

The I<startup> signal is emitted on the primary instance immediately
after registration. See C<g_application_register()>.

  method handler (
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($application),
    *%user-options
  );

=item $application; the application


=end pod

#-------------------------------------------------------------------------------
=begin pod
=head1 Properties

An example of using a string type property of a B<Gnome::Gtk3::Label> object. This is just showing how to set/read a property, not that it is the best way to do it. This is because a) The class initialization often provides some options to set some of the properties and b) the classes provide many methods to modify just those properties. In the case below one can use B<new(:label('my text label'))> or B<gtk_label_set_text('my text label')>.

  my Gnome::Gtk3::Label $label .= new;
  my Gnome::GObject::Value $gv .= new(:init(G_TYPE_STRING));
  $label.g-object-get-property( 'label', $gv);
  $gv.g-value-set-string('my text label');

=head2 Supported properties

=comment -----------------------------------------------------------------------
=comment #TP:0:action-group:
=head3 Action group: action-group

The group of actions that the application exports
Widget type: G-TYPE-ACTION-GROUP

The B<Gnome::GObject::Value> type of property I<action-group> is C<G_TYPE_OBJECT>.

=comment -----------------------------------------------------------------------
=comment #TP:1:application-id:
=head3 Application identifier: application-id

The unique identifier for the application
Default value: Any

The B<Gnome::GObject::Value> type of property I<application-id> is C<G_TYPE_STRING>.

=comment -----------------------------------------------------------------------
=comment #TP:0:flags:
=head3 Application flags: flags


The B<Gnome::GObject::Value> type of property I<flags> is C<G_TYPE_FLAGS>.

=comment -----------------------------------------------------------------------
=comment #TP:1:inactivity-timeout:
=head3 Inactivity timeout: inactivity-timeout


The B<Gnome::GObject::Value> type of property I<inactivity-timeout> is C<G_TYPE_UINT>.

=comment -----------------------------------------------------------------------
=comment #TP:1:is-busy:
=head3 Is busy: is-busy


Whether the application is currently marked as busy
=comment through [[mark-busy]] or [[g-application-bind-busy-property]].

The B<Gnome::GObject::Value> type of property I<is-busy> is C<G_TYPE_BOOLEAN>.

=comment -----------------------------------------------------------------------
=comment #TP:1:is-registered:
=head3 Is registered: is-registered

If register( has been called)
Default value: False

The B<Gnome::GObject::Value> type of property I<is-registered> is C<G_TYPE_BOOLEAN>.

=comment -----------------------------------------------------------------------
=comment #TP:1:is-remote:
=head3 Is remote: is-remote

If this application instance is remote
Default value: False

The B<Gnome::GObject::Value> type of property I<is-remote> is C<G_TYPE_BOOLEAN>.

=comment -----------------------------------------------------------------------
=comment #TP:0:resource-base-path:
=head3 Resource base path: resource-base-path

The base resource path for the application
Default value: Any

The B<Gnome::GObject::Value> type of property I<resource-base-path> is C<G_TYPE_STRING>.
=end pod
