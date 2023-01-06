#TL:1:Gnome::Gio::ApplicationCommandLine:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::ApplicationCommandLine

A command-line invocation of an application

=comment ![](images/X.png)

=head1 Description

B<Gnome::Gio::ApplicationCommandLine> represents a command-line invocation of an application.  It is created by B<Gnome::Gio::Application> and emitted in the  I<command-line> signal and virtual function.

The class contains the list of arguments that the program was invoked with.  It is also possible to query if the commandline invocation was local (ie: the current process is running in direct response to the invocation) or remote (ie: some other process forwarded the commandline to this process).

The B<Gnome::Gio::ApplicationCommandLine> object can provide the I<argc> and I<argv> parameters for use with the B<Gnome::Gio::OptionContext> command-line parsing API, with the C<get-arguments()> function. See [gapplication-example-cmdline3.c][gapplication-example-cmdline3] for an example.

The exit status of the originally-invoked process may be set and messages can be printed to stdout or stderr of that process.  The lifecycle of the originally-invoked process is tied to the lifecycle of this object (ie: the process exits when the last reference is dropped).

The main use for B<Gnome::Gio::ApplicationCommandLine> (and the  I<command-line> signal) is 'Emacs server' like use cases: You can set the `EDITOR` environment variable to have e.g. git use your favourite editor to edit commit messages, and if you already have an instance of the editor running, the editing will happen in the running instance, instead of opening a new one. An important aspect of this use case is that the process that gets started by git does not return until the editing is done.

Normally, the commandline is completely handled in the  I<command-line> handler. The launching instance exits once the signal handler in the primary instance has returned, and the return value of the signal handler becomes the exit status of the launching instance.

=begin comment
|[<!-- language="C" -->
static int
command-line (GApplication            *application,
              GApplicationCommandLine *cmdline)
{
  gchar **argv;
  gint argc;
  gint i;

  argv = g-application-command-line-get-arguments (cmdline, &argc);

  g-application-command-line-print (cmdline,
                                    "This text is written back\n"
                                    "to stdout of the caller\n");

  for (i = 0; i < argc; i++)
    g-print ("argument C<d>: C<s>\n", i, argv[i]);

  g-strfreev (argv);

  return 0;
}
]|

The complete example can be found here:
[gapplication-example-cmdline.c](https://git.gnome.org/browse/glib/tree/gio/tests/gapplication-example-cmdline.c)

In more complicated cases, the handling of the comandline can be
split between the launcher and the primary instance.
|[<!-- language="C" -->
static gboolean
 test-local-cmdline (GApplication   *application,
                     gchar        ***arguments,
                     gint           *exit-status)
{
  gint i, j;
  gchar **argv;

  argv = *arguments;

  i = 1;
  while (argv[i])
    {
      if (g-str-has-prefix (argv[i], "--local-"))
        {
          g-print ("handling argument C<s> locally\n", argv[i]);
          g-free (argv[i]);
          for (j = i; argv[j]; j++)
            argv[j] = argv[j + 1];
        }
      else
        {
          g-print ("not handling argument C<s> locally\n", argv[i]);
          i++;
        }
    }

  *exit-status = 0;

  return FALSE;
}

static void
test-application-class-init (TestApplicationClass *class)
{
  G-APPLICATION-CLASS (class)->local-command-line = test-local-cmdline;

  ...
}
]|
In this example of split commandline handling, options that start
with `--local-` are handled locally, all other options are passed
to the  I<command-line> handler which runs in the primary
instance.

The complete example can be found here:
[gapplication-example-cmdline2.c](https://git.gnome.org/browse/glib/tree/gio/tests/gapplication-example-cmdline2.c)

If handling the commandline requires a lot of work, it may
be better to defer it.
|[<!-- language="C" -->
static gboolean
my-cmdline-handler (gpointer data)
{
  GApplicationCommandLine *cmdline = data;

  // do the heavy lifting in an idle

  g-application-command-line-set-exit-status (cmdline, 0);
  g-object-unref (cmdline); // this releases the application

  return G-SOURCE-REMOVE;
}

static int
command-line (GApplication            *application,
              GApplicationCommandLine *cmdline)
{
  // keep the application running until we are done with this commandline
  g-application-hold (application);

  g-object-set-data-full (G-OBJECT (cmdline),
                          "application", application,
                          (GDestroyNotify)g-application-release);

  g-object-ref (cmdline);
  g-idle-add (my-cmdline-handler, cmdline);

  return 0;
}
]|
In this example the commandline is not completely handled before
the  I<command-line> handler returns. Instead, we keep
a reference to the B<Gnome::Gio::ApplicationCommandLine> object and handle it
later (in this example, in an idle). Note that it is necessary to
hold the application until you are done with the commandline.

The complete example can be found here:
 * [gapplication-example-cmdline3.c](https://git.gnome.org/browse/glib/tree/gio/tests/gapplication-example-cmdline3.c)
=end comment



=head2 See Also

B<Gnome::Gio::Application>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::ApplicationCommandLine;
  also is Gnome::Gobject::Object;


=comment head2 Uml Diagram

=comment ![](plantuml/.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::ApplicationCommandLine;

  unit class MyGuiClass;
  also is Gnome::Gio::ApplicationCommandLine;

  submethod new ( |c ) {
    # let the Gnome::Gio::ApplicationCommandLine class process the options
    self.bless( :GApplicationCommandLine, |c);
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

use Gnome::Glib::Variant;
use Gnome::Glib::VariantDict;

use Gnome::GObject::Object;

use Gnome::Gio::File;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::ApplicationCommandLine:auth<github:MARTIMM>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=begin comment
=head3 default, no options

Create a new ApplicationCommandLine object.

  multi method new ( )
=end comment


=head3 :native-object

Create a ApplicationCommandLine object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

#TM:0:new():inheriting
#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::ApplicationCommandLine' #`{{ or %options<GApplicationCommandLine> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<___x___> {
        #$no = %options<___x___>;
        #$no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        #$no = _g_application_command_line_new___x___($no);
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
        $no = _g_application_command_line_new();
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GApplicationCommandLine');
  }
}

#`{{
#-------------------------------------------------------------------------------
# TM:0:create-file-for-arg:
=begin pod
=head2 create-file-for-arg

Creates a B<Gnome::Gio::File> corresponding to a filename that was given as part of the invocation of I<cmdline>.

=comment This differs from C<g-file-new-for-commandline-arg()> in that it resolves relative pathnames using the current working directory of the invoking process rather than the local process.

Returns: a new B<Gnome::Gio::File>

  method create-file-for-arg ( Str $arg --> Gnome::Gio::File )

=item Str $arg; (type filename): an argument from I<cmdline>

=end pod

method create-file-for-arg ( Str $arg --> Gnome::Gio::File ) {

  Gnome::Gio::File.new(
    :native-object(
      g_application_command_line_create_file_for_arg(
        self._get-native-object-no-reffing, $arg
      )
    )
  )
}

sub g_application_command_line_create_file_for_arg (
  N-GObject $cmdline, gchar-ptr $arg --> N-GFile
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:4:get-arguments:ex-application.raku
=begin pod
=head2 get-arguments

Gets the list of arguments that was passed on the command line.

The strings in the array may contain non-UTF-8 data on UNIX (such as filenames or arguments given in the system locale) but are always in UTF-8 on Windows.

=comment If you wish to use the return value with B<Gnome::Gio::OptionContext>, you must use C<g-option-context-parse-strv()>.

Returns: an array of strings containing the arguments

  method get-arguments ( --> Array[Str] )

=end pod

method get-arguments ( --> Array ) {

  my CArray[Str] $a = g_application_command_line_get_arguments(
    self._get-native-object-no-reffing, my int $argc
  );

#note "ac: $argc";
#note "a[0]: $a[0].ords()";
  my Array $args = [];
  my Int $i = 0;
  while $a[$i] {
    $args[$i] = $a[$i];
    $i++;
  }

  $args
}

sub g_application_command_line_get_arguments (
  N-GObject $cmdline, gint $argc is rw --> CArray[Str]
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-cwd:
=begin pod
=head2 get-cwd

Gets the working directory of the command line invocation. The string may contain non-utf8 data.

It is possible that the remote application did not send a working directory, so this may be C<undefined>.

The return value should not be modified or freed and is valid for as long as I<cmdline> exists.

Returns: the current directory, or C<undefined>

  method get-cwd ( --> Str )


=end pod

method get-cwd ( --> Str ) {

  g_application_command_line_get_cwd(
    self._get-native-object-no-reffing,
  )
}

sub g_application_command_line_get_cwd (
  N-GObject $cmdline --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-environ:
=begin pod
=head2 get-environ

Gets the contents of the 'environ' variable of the command line invocation, as would be returned by C<g-get-environ()>, ie as a C<undefined>-terminated list of strings in the form 'NAME=VALUE'. The strings may contain non-utf8 data.

The remote application usually does not send an environment. Use C<G-APPLICATION-SEND-ENVIRONMENT> to affect that. Even with this flag set it is possible that the environment is still not available (due to invocation messages from other applications).

The return value should not be modified or freed and is valid for as long as I<cmdline> exists.

See C<getenv()> if you are only interested in the value of a single environment variable.

Returns: the environment strings, or C<undefined> if they were not sent

  method get-environ ( --> CArray[Str] )


=end pod

method get-environ ( --> CArray[Str] ) {

  g_application_command_line_get_environ(
    self._get-native-object-no-reffing,
  )
}

sub g_application_command_line_get_environ (
  N-GObject $cmdline --> gchar-pptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:get-exit-status:ex-application.raku
=begin pod
=head2 get-exit-status

Gets the exit status of I<cmdline>. See C<set-exit-status()> for more information.

Returns: the exit status

  method get-exit-status ( --> Int )


=end pod

method get-exit-status ( --> Int ) {

  g_application_command_line_get_exit_status(
    self._get-native-object-no-reffing,
  )
}

sub g_application_command_line_get_exit_status (
  N-GObject $cmdline --> gint
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:get-is-remote:ex-application.raku
=begin pod
=head2 get-is-remote

Determines if I<cmdline> represents a remote invocation.

Returns: C<True> if the invocation was remote

  method get-is-remote ( --> Bool )


=end pod

method get-is-remote ( --> Bool ) {

  g_application_command_line_get_is_remote(
    self._get-native-object-no-reffing,
  ).Bool
}

sub g_application_command_line_get_is_remote (
  N-GObject $cmdline --> gboolean
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-options-dict:
=begin pod
=head2 get-options-dict

Gets the options there were passed to C<g-application-command-line()>.

If you did not override C<local-command-line()> then these are the same options that were parsed according to the B<Gnome::Gio::OptionEntrys> added to the application with C<g-application-add-main-option-entries()> and possibly modified from your GApplication::handle-local-options handler.

If no options were sent then an empty dictionary is returned so that you don't need to check for C<undefined>.

Returns: (transfer none): a B<Gnome::Gio::VariantDict> with the options

  method get-options-dict ( --> N-GObject )


=end pod

method get-options-dict ( --> N-GObject ) {

  g_application_command_line_get_options_dict(
    self._get-native-object-no-reffing,
  )
}

sub g_application_command_line_get_options_dict (
  N-GObject $cmdline --> N-GObject
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-platform-data:
=begin pod
=head2 get-platform-data

Gets the platform data associated with the invocation of I<cmdline>.

This is a B<Gnome::Gio::Variant> dictionary containing information about the context in which the invocation occurred. It typically contains information like the current working directory and the startup notification ID.

For local invocation, it will be C<undefined>.

Returns: the platform data, or C<undefined>

  method get-platform-data ( --> N-GObject )


=end pod

method get-platform-data ( --> N-GObject ) {

  g_application_command_line_get_platform_data(
    self._get-native-object-no-reffing,
  )
}

sub g_application_command_line_get_platform_data (
  N-GObject $cmdline --> N-GObject
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-stdin:
=begin pod
=head2 get-stdin

Gets the stdin of the invoking process.

The B<Gnome::Gio::InputStream> can be used to read data passed to the standard input of the invoking process. This doesn't work on all platforms. Presently, it is only available on UNIX when using a DBus daemon capable of passing file descriptors. If stdin is not available then C<undefined> will be returned. In the future, support may be expanded to other platforms.

You must only call this function once per commandline invocation.

Returns: (transfer full): a B<Gnome::Gio::InputStream> for stdin

  method get-stdin ( --> GInputStream )


=end pod

method get-stdin ( --> GInputStream ) {

  g_application_command_line_get_stdin(
    self._get-native-object-no-reffing,
  )
}

sub g_application_command_line_get_stdin (
  N-GObject $cmdline --> GInputStream
) is native(&gio-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:getenv:
=begin pod
=head2 getenv

Gets the value of a particular environment variable of the command line invocation, as would be returned by C<g-getenv()>. The strings may contain non-utf8 data.

The remote application usually does not send an environment. Use C<G_APPLICATION_SEND_ENVIRONMENT> to affect that. Even with this flag set it is possible that the environment is still not available (due to invocation messages from other applications).

The return value should not be modified or freed and is valid for as long as I<cmdline> exists.

Returns: the value of the variable, or C<undefined> if unset or unsent

  method getenv ( Str $name --> Str )

=item Str $name; (type filename): the environment variable to get

=end pod

method getenv ( Str $name --> Str ) {

  g_application_command_line_getenv(
    self._get-native-object-no-reffing, $name
  )
}

sub g_application_command_line_getenv (
  N-GObject $cmdline, gchar-ptr $name --> gchar-ptr
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:4:print:ex-application.raku
=begin pod
=head2 print

Prints message using the stdout print handler in the invoking process.

=comment If I<cmdline> is a local invocation then this is exactly equivalent to C<g-print()>. If I<cmdline> is remote then this is equivalent to calling C<g-print()> in the invoking process.

  method print ( Str $message )

=item Str $message; a message string

=end pod

method print ( Str $message ) {

  g_application_command_line_print(
    self._get-native-object-no-reffing, $message, Nil
  );
}

sub g_application_command_line_print (
  N-GObject $cmdline, gchar-ptr $message, Pointer
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:printerr:ex-application.raku
=begin pod
=head2 printerr

Formats a message and prints it using the stderr print handler in the invoking process.

=comment If I<cmdline> is a local invocation then this is exactly equivalent to C<g-printerr()>. If I<cmdline> is remote then this is equivalent to calling C<g-printerr()> in the invoking process.

  method printerr ( Str $message )

=item Str $message; a message string

=end pod

method printerr ( Str $message ) {

  g_application_command_line_printerr(
    self._get-native-object-no-reffing, $message, Nil
  );
}

sub g_application_command_line_printerr (
  N-GObject $cmdline, gchar-ptr $message, Pointer
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:set-exit-status:ex-application.raku
=begin pod
=head2 set-exit-status

Sets the exit status that will be used when the invoking process exits.

The return value of the  I<command-line> signal is passed to this function when the handler returns. This is the usual way of setting the exit status.

In the event that you want the remote invocation to continue running and want to decide on the exit status in the future, you can use this call. For the case of a remote invocation, the remote process will typically exit when the last reference is dropped on I<cmdline>. The exit status of the remote process will be equal to the last value that was set with this function.

In the case that the commandline invocation is local, the situation is slightly more complicated. If the commandline invocation results in the mainloop running (ie: because the use-count of the application increased to a non-zero value) then the application is considered to have been 'successful' in a certain sense, and the exit status is always zero. If the application use count is zero, though, the exit status of the local B<Gnome::Gio::ApplicationCommandLine> is used.

  method set-exit-status ( Int $exit_status )

=item Int $exit_status; the exit status

=end pod

method set-exit-status ( Int $exit_status ) {

  g_application_command_line_set_exit_status(
    self._get-native-object-no-reffing, $exit_status
  );
}

sub g_application_command_line_set_exit_status (
  N-GObject $cmdline, gint $exit_status
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head1 Properties

An example of using a string type property of a B<Gnome::Gtk3::Label> object. This is just showing how to set/read a property, not that it is the best way to do it. This is because a) The class initialization often provides some options to set some of the properties and b) the classes provide many methods to modify just those properties. In the case below one can use B<new(:label('my text label'))> or B<.set-text('my text label')>.

  my Gnome::Gtk3::Label $label .= new;
  my Gnome::GObject::Value $gv .= new(:init(G_TYPE_STRING));
  $label.get-property( 'label', $gv);
  $gv.set-string('my text label');

=head2 Supported properties

=comment -----------------------------------------------------------------------
=comment #TP:0:arguments:
=head3 Commandline arguments: arguments


The B<Gnome::GObject::Value> type of property I<arguments> is C<G_TYPE_VARIANT>.

=comment -----------------------------------------------------------------------
=comment #TP:0:is-remote:
=head3 Is remote: is-remote

TRUE if this is a remote commandline
Default value: False

The B<Gnome::GObject::Value> type of property I<is-remote> is C<G_TYPE_BOOLEAN>.

=comment -----------------------------------------------------------------------
=comment #TP:0:options:
=head3 Options: options


The B<Gnome::GObject::Value> type of property I<options> is C<G_TYPE_VARIANT>.

=comment -----------------------------------------------------------------------
=comment #TP:0:platform-data:
=head3 Platform data: platform-data


The B<Gnome::GObject::Value> type of property I<platform-data> is C<G_TYPE_VARIANT>.
=end pod
