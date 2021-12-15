#TL:1:Gnome::Gio::AppLaunchContext:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::AppLaunchContext

Application information and launch contexts


=comment ![](images/X.png)


=head1 Description

 B<Gnome::Gio::AppInfo> and B<Gnome::Gio::AppLaunchContext> are used for describing and launching applications installed on the system.


=head2 See Also

B<Gnome::Gio::AppInfo> and B<Gnome::Gio::AppInfoMonitor>


=head1 Synopsis

=head2 Declaration

  unit class Gnome::Gio::AppLaunchContext;
  also is Gnome::GObject::Object;


=comment head2 Uml Diagram

=comment ![](plantuml/.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::AppLaunchContext;

  unit class MyGuiClass;
  also is Gnome::Gio::AppLaunchContext;

  submethod new ( |c ) {
    # let the Gnome::Gio::AppLaunchContext class process the options
    self.bless( :GAppLaunchContext, |c);
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
unit class Gnome::Gio::AppLaunchContext:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::GObject::Object;

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 class N-GAppLaunchContext

Integrating the launch with the launching application. This is used to
handle for instance startup notification and launching the new application
on the same screen as the launching window.




=end pod

#TT:0:N-GAppLaunchContext:
class N-GAppLaunchContext is export is repr('CStruct') {
  has N-GObject $.parent_instance;
  has GAppLaunchContextPrivate $.priv;
}
}}

#-------------------------------------------------------------------------------
my Bool $signals-added = False;
#-------------------------------------------------------------------------------

=begin pod
=head1 Methods
=head2 new

=head3 default, no options

Create a new AppLaunchContext object.

  multi method new ( )

=head3 :native-object

Create a AppLaunchContext object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=head3 :build-id

Create a AppLaunchContext object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

#TM:0:new():inheriting
#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
#TM:4:new(:build-id):Gnome::GObject::Object

submethod BUILD ( *%options ) {

  # add signal info in the form of w*<signal-name>.
  unless $signals-added {
    $signals-added = self.add-signal-types( $?CLASS.^name,
      :w2<launched>, :w1<launch-failed>,
    );

    # signals from interfaces
    #_add_..._signal_types($?CLASS.^name);
  }


  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::AppLaunchContext' #`{{ or %options<GAppLaunchContext> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }
    elsif %options<build-id>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<___x___> {
        $no = %options<___x___>;
        $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        #$no = _g_app_launch_context_new___x___($no);
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

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      ##`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _g_app_launch_context_new();
      }
      #}}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GAppLaunchContext');
  }
}

#-------------------------------------------------------------------------------
#TM:0:get-display:
=begin pod
=head2 get-display

Gets the display string for the I<context>. This is used to ensure new applications are started on the same display as the launching application, by setting the `DISPLAY` environment variable.

Returns: a display string for the display.

  method get-display ( N-GObject $info, N-GList $files --> Str )

=item N-GObject $info; a B<Gnome::Gio::AppInfo>
=item N-GList $files; (element-type GFile): a B<Gnome::Gio::List> of B<Gnome::Gio::File> objects
=end pod

method get-display ( N-GObject $info, $files is copy --> Str ) {
  $files .= _get-native-object-no-reffing unless $files ~~ N-GList;

  g_app_launch_context_get_display(
    self._get-native-object-no-reffing, $info, $files
  )
}

sub g_app_launch_context_get_display (
  N-GObject $context, N-GObject $info, N-GList $files --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-environment:
=begin pod
=head2 get-environment

Gets the complete environment variable list to be passed to the child process when I<context> is used to launch an application. This is a C<undefined>-terminated array of strings, where each string has the form `KEY=VALUE`.

Returns:  (element-type filename) : the child's environment

  method get-environment ( --> CArray[Str] )

=end pod

method get-environment ( --> CArray[Str] ) {

  g_app_launch_context_get_environment(
    self._get-native-object-no-reffing,
  )
}

sub g_app_launch_context_get_environment (
  N-GObject $context --> gchar-pptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-startup-notify-id:
=begin pod
=head2 get-startup-notify-id

Initiates startup notification for the application and returns the `DESKTOP-STARTUP-ID` for the launched operation, if supported.

Startup notification IDs are defined in the [FreeDesktop.Org Startup Notifications standard](http://standards.freedesktop.org/startup-notification-spec/startup-notification-latest.txt").

Returns: a startup notification ID for the application, or C<undefined> if not supported.

  method get-startup-notify-id ( N-GObject $info, N-GList $files --> Str )

=item N-GObject $info; a B<Gnome::Gio::AppInfo>
=item N-GList $files; (element-type GFile): a B<Gnome::Gio::List> of of B<Gnome::Gio::File> objects
=end pod

method get-startup-notify-id ( N-GObject $info, $files is copy --> Str ) {
  $files .= _get-native-object-no-reffing unless $files ~~ N-GList;

  g_app_launch_context_get_startup_notify_id(
    self._get-native-object-no-reffing, $info, $files
  )
}

sub g_app_launch_context_get_startup_notify_id (
  N-GObject $context, N-GObject $info, N-GList $files --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:launch-failed:
=begin pod
=head2 launch-failed

Called when an application has failed to launch, so that it can cancel the application startup notification started in C<get-startup-notify-id()>.

  method launch-failed ( Str $startup_notify_id )

=item Str $startup_notify_id; the startup notification id that was returned by C<get-startup-notify-id()>.
=end pod

method launch-failed ( Str $startup_notify_id ) {

  g_app_launch_context_launch_failed(
    self._get-native-object-no-reffing, $startup_notify_id
  );
}

sub g_app_launch_context_launch_failed (
  N-GObject $context, gchar-ptr $startup_notify_id
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:setenv:
=begin pod
=head2 setenv

Arranges for I<variable> to be set to I<value> in the child's environment when I<context> is used to launch an application.

  method setenv ( Str $variable, Str $value )

=item Str $variable; (type filename): the environment variable to set
=item Str $value; (type filename): the value for to set the variable to.
=end pod

method setenv ( Str $variable, Str $value ) {

  g_app_launch_context_setenv(
    self._get-native-object-no-reffing, $variable, $value
  );
}

sub g_app_launch_context_setenv (
  N-GObject $context, gchar-ptr $variable, gchar-ptr $value
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:unsetenv:
=begin pod
=head2 unsetenv

Arranges for I<variable> to be unset in the child's environment when I<context> is used to launch an application.

  method unsetenv ( Str $variable )

=item Str $variable; (type filename): the environment variable to remove
=end pod

method unsetenv ( Str $variable ) {

  g_app_launch_context_unsetenv(
    self._get-native-object-no-reffing, $variable
  );
}

sub g_app_launch_context_unsetenv (
  N-GObject $context, gchar-ptr $variable
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_app_launch_context_new:
#`{{
=begin pod
=head2 _g_app_launch_context_new

Creates a new application launch context. This is not normally used, instead you instantiate a subclass of this, such as B<Gnome::Gio::AppLaunchContext>.

Returns: a B<Gnome::Gio::AppLaunchContext>.

  method _g_app_launch_context_new ( --> N-GObject )

=end pod
}}

sub _g_app_launch_context_new (  --> N-GObject )
  is native(&gio-lib)
  is symbol('g_app_launch_context_new')
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
=comment #TS:0:launch-failed:
=head3 launch-failed

The I<launch-failed> signal is emitted when a B<Gnome::Gio::AppInfo> launch fails. The startup notification id is provided, so that the launcher can cancel the startup notification.


  method handler (
    Str $startup_notify_id,
    Int :$_handle_id,
    Gnome::Gio::AppLaunchContext :_widget($context),
    *%user-options
  );

=item Gnome::Gio::AppLaunchContext $context; the object emitting the signal

=item $startup_notify_id; the startup notification id for the failed launch

=item $_handle_id; the registered event handler id

=comment -----------------------------------------------------------------------
=comment #TS:0:launched:
=head3 launched

The I<launched> signal is emitted when a B<Gnome::Gio::AppInfo> is successfully launched. The I<platform-data> is an GVariant dictionary mapping strings to variants (ie a{sv}), which contains additional, platform-specific data about this launch. On UNIX, at least the "pid" and "startup-notification-id" keys will be present.

  method handler (
    N-GObject $info,
    N-GObject $platform_data,
    Int :$_handle_id,
    Gnome::Gio::AppLaunchContext :_widget($context),
    *%user-options
  );

=item Gnome::Gio::AppLaunchContext $context; the object emitting the signal

=item N-GObject $info; the B<Gnome::Gio::AppInfo> that was just launched

=item N-GObject $platform_data; additional platform-specific data for this launch. This is a native B<Gnome::Glib::Variant>.

=item $_handle_id; the registered event handler id

=end pod
