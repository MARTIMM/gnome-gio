#TL:1:Gnome::Gio::AppInfoMonitor:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::AppInfoMonitor

Monitor application information for changes


=head1 Description

B<Gnome::Gio::AppInfoMonito>r is a very simple object used for monitoring the app info database for changes (ie: newly installed or removed applications). Call C<Gnome::Gio::AppInfo.monitor_get()> to get a B<Gnome::Gio::AppInfoMonitor> and connect to the "changed" signal.

In the usual case, applications should try to make note of the change (doing things like invalidating caches) but not act on it. In particular, applications should avoid making calls to B<Gnome::Gio::AppInfo> APIs in response to the change signal, deferring these until the time that the data is actually required.  The exception to this case is when application information is actually being displayed on the screen (eg: during a search or when the list of all applications is shown). The reason for this is that changes to the list of installed applications often come in groups (like during system updates) and rescanning the list on every change is pointless and expensive.


=head2 See Also

B<Gnome::Gio::AppInfo>


=head1 Synopsis

=head2 Declaration

  unit class Gnome::Gio::AppInfoMonitor;
  also is Gnome::GObject::Object


=head2 Uml Diagram

![](plantuml/AppInfo.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::AppInfoMonitor:api<1>;

  unit class MyGuiClass;
  also is Gnome::Gio::AppInfoMonitor;

  submethod new ( |c ) {
    # let the Gnome::Gio::AppInfoMonitor class process the options
    self.bless( :GAppInfoMonitor, |c);
  }

  submethod BUILD ( ... ) {
    ...
  }

=end comment


=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X:api<1>;
use Gnome::N::NativeLib:api<1>;
use Gnome::N::N-GObject:api<1>;
use Gnome::N::GlibToRakuTypes:api<1>;

use Gnome::GObject::Object:api<1>;


#-------------------------------------------------------------------------------
unit class Gnome::Gio::AppInfoMonitor:auth<github:MARTIMM>:api<1>;
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

Creates the B<Gnome::Gio::AppInfoMonitor> for the current thread-default main context.

The B<Gnome::Gio::AppInfoMonitor> will emit a "changed" signal in the thread-default main context whenever the list of installed applications (as reported by C<Gnome::Gio::AppInfo.get-all()>) may have changed.

You must only call C<.clear-object()> on the return value from under the same main context as you created it.

  multi method new ( )


=head3 :native-object

Create a AppInfoMonitor object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

# TM:0:new():inheriting
#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # add signal info in the form of w*<signal-name>.
  unless $signals-added {
    $signals-added = self.add-signal-types( $?CLASS.^name,
      :w1<changed>,
    );

    # signals from interfaces
    #_add_..._signal_types($?CLASS.^name);
  }


  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::AppInfoMonitor' #`{{ or %options<GAppInfoMonitor> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<___x___> {
        $no = %options<___x___>;
        $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        #$no = _g_app_info_monitor_new___x___($no);
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
        $no = _g_app_info_monitor_get();
      }
      #}}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GAppInfoMonitor');
  }
}

#-------------------------------------------------------------------------------
#TM:1::
#`{{
=begin pod
=head2 get

Gets the B<Gnome::Gio::AppInfoMonitor> for the current thread-default main context.

The B<Gnome::Gio::AppInfoMonitor> will emit a "changed" signal in the thread-default main context whenever the list of installed applications (as reported by C<g-app-info-get-all()>) may have changed.

You must only call C<g-object-unref()> on the return value from under the same main context as you created it.

Returns: a reference to a B<Gnome::Gio::AppInfoMonitor>

  method get ( --> GAppInfoMonitor )

=end pod

method get ( --> GAppInfoMonitor ) {
  g_app_info_monitor_get(self._get-native-object-no-reffing)
}
}}

sub _g_app_info_monitor_get (
   --> N-GObject
) is native(&gio-lib)
  is symbol('g_app_info_monitor_get')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-type:
=begin pod
=head2 get-type

Type of a GAppInfoMonitor

  method get-type ( --> N-GObject )

=end pod

method get-type ( --> N-GObject ) {

  g_app_info_monitor_get_type(
    self._get-native-object-no-reffing,
  )
}

sub g_app_info_monitor_get_type (
   --> N-GObject
) is native(&gio-lib)
  { * }
}}

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
=comment #TS:0:changed:
=head3 changed

  method handler (
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($appinfomonitor),
    *%user-options
  );

=item $appinfomonitor; the registered info moditor object
=item $_handle_id; the registered event handler id



=begin comment
=comment -----------------------------------------------------------------------
=comment #TS:0:launched:
=head3 launched

  method handler (
    Unknown type G_TYPE_APP_INFO $unknown type g_type_app_info,
    Unknown type G_TYPE_VARIANT $unknown type g_type_variant,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($appinfomonitor),
    *%user-options
  );

=item $appinfomonitor;
=item $unknown type g_type_app_info;
=item $unknown type g_type_variant;
=item $_handle_id; the registered event handler id

=end comment

=end pod
