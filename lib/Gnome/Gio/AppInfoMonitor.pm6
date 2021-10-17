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


=comment head2 Uml Diagram

=comment ![](plantuml/.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::AppInfoMonitor;

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

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;


#-------------------------------------------------------------------------------
unit class Gnome::Gio::AppInfoMonitor:auth<github:MARTIMM>:ver<0.1.0>;

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

#-------------------------------------------------------------------------------
my Bool $signals-added = False;
#-------------------------------------------------------------------------------

=begin pod
=head1 Methods
=head2 new

=head3 default, no options

Create a new AppInfoMonitor object.

  multi method new ( )

=head3 :native-object

Create a AppInfoMonitor object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=head3 :build-id

Create a AppInfoMonitor object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

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
      :w1<changed>, :w2<launched>, :w0<changed>,
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
    elsif %options<build-id>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<___x___> {
        $no = %options<___x___>;
        $no .= get-native-object-no-reffing unless $no ~~ N-GObject;
        #$no = _g_app_info_monitor_new___x___($no);
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
        $no = _g_app_info_monitor_new();
      }
      }}

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GAppInfoMonitor');
  }
}


#-------------------------------------------------------------------------------
#TM:0:g-app-info-add-supports-type:
=begin pod
=head2 g-app-info-add-supports-type

Adds a content type to the application information to indicate the application is capable of opening files with the given content type.

Returns: C<True> on success, C<False> on error.

  method g-app-info-add-supports-type ( GAppInfo $appinfo, Str $content_type, N-GError $error --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=item Str $content_type; a string.
=item N-GError $error; a B<Gnome::Gio::Error>.
=end pod

method g-app-info-add-supports-type ( GAppInfo $appinfo, Str $content_type, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_add_supports_type(
    self.get-native-object-no-reffing, $appinfo, $content_type, $error
  ).Bool
}

sub g_app_info_add_supports_type (
  GAppInfo $appinfo, gchar-ptr $content_type, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-can-delete:
=begin pod
=head2 g-app-info-can-delete

Obtains the information whether the B<Gnome::Gio::AppInfo> can be deleted. See C<g-app-info-delete()>.

Returns: C<True> if I<appinfo> can be deleted

  method g-app-info-can-delete ( GAppInfo $appinfo --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>
=end pod

method g-app-info-can-delete ( GAppInfo $appinfo --> Bool ) {

  g_app_info_can_delete(
    self.get-native-object-no-reffing, $appinfo
  ).Bool
}

sub g_app_info_can_delete (
  GAppInfo $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-can-remove-supports-type:
=begin pod
=head2 g-app-info-can-remove-supports-type

Checks if a supported content type can be removed from an application.

Returns: C<True> if it is possible to remove supported content types from a given I<appinfo>, C<False> if not.

  method g-app-info-can-remove-supports-type ( GAppInfo $appinfo --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-can-remove-supports-type ( GAppInfo $appinfo --> Bool ) {

  g_app_info_can_remove_supports_type(
    self.get-native-object-no-reffing, $appinfo
  ).Bool
}

sub g_app_info_can_remove_supports_type (
  GAppInfo $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-create-from-commandline:
=begin pod
=head2 g-app-info-create-from-commandline



  method g-app-info-create-from-commandline ( Str $commandline, Str $application_name, GAppInfoCreateFlags $flags, N-GError $error --> GAppInfo )

=item Str $commandline;
=item Str $application_name;
=item GAppInfoCreateFlags $flags;
=item N-GError $error;
=end pod

method g-app-info-create-from-commandline ( Str $commandline, Str $application_name, GAppInfoCreateFlags $flags, $error is copy --> GAppInfo ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_create_from_commandline(
    self.get-native-object-no-reffing, $commandline, $application_name, $flags, $error
  )
}

sub g_app_info_create_from_commandline (
  gchar-ptr $commandline, gchar-ptr $application_name, GEnum $flags, N-GError $error --> GAppInfo
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-delete:
=begin pod
=head2 g-app-info-delete

Tries to delete a B<Gnome::Gio::AppInfo>.

On some platforms, there may be a difference between user-defined B<Gnome::Gio::AppInfos> which can be deleted, and system-wide ones which cannot. See C<g-app-info-can-delete()>.

Virtual: do-delete

Returns: C<True> if I<appinfo> has been deleted

  method g-app-info-delete ( GAppInfo $appinfo --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>
=end pod

method g-app-info-delete ( GAppInfo $appinfo --> Bool ) {

  g_app_info_delete(
    self.get-native-object-no-reffing, $appinfo
  ).Bool
}

sub g_app_info_delete (
  GAppInfo $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-dup:
=begin pod
=head2 g-app-info-dup

Creates a duplicate of a B<Gnome::Gio::AppInfo>.

Returns: a duplicate of I<appinfo>.

  method g-app-info-dup ( GAppInfo $appinfo --> GAppInfo )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-dup ( GAppInfo $appinfo --> GAppInfo ) {

  g_app_info_dup(
    self.get-native-object-no-reffing, $appinfo
  )
}

sub g_app_info_dup (
  GAppInfo $appinfo --> GAppInfo
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-equal:
=begin pod
=head2 g-app-info-equal

Checks if two B<Gnome::Gio::AppInfos> are equal.

Note that the check <emphasis>may not</emphasis> compare each individual field, and only does an identity check. In case detecting changes in the contents is needed, program code must additionally compare relevant fields.

Returns: C<True> if I<appinfo1> is equal to I<appinfo2>. C<False> otherwise.

  method g-app-info-equal ( GAppInfo $appinfo1, GAppInfo $appinfo2 --> Bool )

=item GAppInfo $appinfo1; the first B<Gnome::Gio::AppInfo>.
=item GAppInfo $appinfo2; the second B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-equal ( GAppInfo $appinfo1, GAppInfo $appinfo2 --> Bool ) {

  g_app_info_equal(
    self.get-native-object-no-reffing, $appinfo1, $appinfo2
  ).Bool
}

sub g_app_info_equal (
  GAppInfo $appinfo1, GAppInfo $appinfo2 --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-all:
=begin pod
=head2 g-app-info-get-all



  method g-app-info-get-all ( --> N-GList )

=end pod

method g-app-info-get-all ( --> N-GList ) {

  g_app_info_get_all(
    self.get-native-object-no-reffing,
  )
}

sub g_app_info_get_all (
   --> N-GList
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-all-for-type:
=begin pod
=head2 g-app-info-get-all-for-type



  method g-app-info-get-all-for-type ( Str $content_type --> N-GList )

=item Str $content_type;
=end pod

method g-app-info-get-all-for-type ( Str $content_type --> N-GList ) {

  g_app_info_get_all_for_type(
    self.get-native-object-no-reffing, $content_type
  )
}

sub g_app_info_get_all_for_type (
  gchar-ptr $content_type --> N-GList
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-commandline:
=begin pod
=head2 g-app-info-get-commandline

Gets the commandline with which the application will be started.

Returns: (type filename): a string containing the I<appinfo>'s commandline, or C<undefined> if this information is not available

  method g-app-info-get-commandline ( GAppInfo $appinfo --> Str )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>
=end pod

method g-app-info-get-commandline ( GAppInfo $appinfo --> Str ) {

  g_app_info_get_commandline(
    self.get-native-object-no-reffing, $appinfo
  )
}

sub g_app_info_get_commandline (
  GAppInfo $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-default-for-type:
=begin pod
=head2 g-app-info-get-default-for-type



  method g-app-info-get-default-for-type ( Str $content_type, Bool $must_support_uris --> GAppInfo )

=item Str $content_type;
=item Bool $must_support_uris;
=end pod

method g-app-info-get-default-for-type ( Str $content_type, Bool $must_support_uris --> GAppInfo ) {

  g_app_info_get_default_for_type(
    self.get-native-object-no-reffing, $content_type, $must_support_uris
  )
}

sub g_app_info_get_default_for_type (
  gchar-ptr $content_type, gboolean $must_support_uris --> GAppInfo
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-default-for-uri-scheme:
=begin pod
=head2 g-app-info-get-default-for-uri-scheme



  method g-app-info-get-default-for-uri-scheme ( Str $uri_scheme --> GAppInfo )

=item Str $uri_scheme;
=end pod

method g-app-info-get-default-for-uri-scheme ( Str $uri_scheme --> GAppInfo ) {

  g_app_info_get_default_for_uri_scheme(
    self.get-native-object-no-reffing, $uri_scheme
  )
}

sub g_app_info_get_default_for_uri_scheme (
  gchar-ptr $uri_scheme --> GAppInfo
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-description:
=begin pod
=head2 g-app-info-get-description

Gets a human-readable description of an installed application.

Returns: a string containing a description of the application I<appinfo>, or C<undefined> if none.

  method g-app-info-get-description ( GAppInfo $appinfo --> Str )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-get-description ( GAppInfo $appinfo --> Str ) {

  g_app_info_get_description(
    self.get-native-object-no-reffing, $appinfo
  )
}

sub g_app_info_get_description (
  GAppInfo $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-display-name:
=begin pod
=head2 g-app-info-get-display-name

Gets the display name of the application. The display name is often more descriptive to the user than the name itself.

Returns: the display name of the application for I<appinfo>, or the name if no display name is available.

  method g-app-info-get-display-name ( GAppInfo $appinfo --> Str )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-get-display-name ( GAppInfo $appinfo --> Str ) {

  g_app_info_get_display_name(
    self.get-native-object-no-reffing, $appinfo
  )
}

sub g_app_info_get_display_name (
  GAppInfo $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-executable:
=begin pod
=head2 g-app-info-get-executable

Gets the executable's name for the installed application.

Returns: (type filename): a string containing the I<appinfo>'s application binaries name

  method g-app-info-get-executable ( GAppInfo $appinfo --> Str )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>
=end pod

method g-app-info-get-executable ( GAppInfo $appinfo --> Str ) {

  g_app_info_get_executable(
    self.get-native-object-no-reffing, $appinfo
  )
}

sub g_app_info_get_executable (
  GAppInfo $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-fallback-for-type:
=begin pod
=head2 g-app-info-get-fallback-for-type



  method g-app-info-get-fallback-for-type ( Str $content_type --> N-GList )

=item Str $content_type;
=end pod

method g-app-info-get-fallback-for-type ( Str $content_type --> N-GList ) {

  g_app_info_get_fallback_for_type(
    self.get-native-object-no-reffing, $content_type
  )
}

sub g_app_info_get_fallback_for_type (
  gchar-ptr $content_type --> N-GList
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-icon:
=begin pod
=head2 g-app-info-get-icon

Gets the icon for the application.

Returns: the default B<Gnome::Gio::Icon> for I<appinfo> or C<undefined> if there is no default icon.

  method g-app-info-get-icon ( GAppInfo $appinfo --> GIcon )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-get-icon ( GAppInfo $appinfo --> GIcon ) {

  g_app_info_get_icon(
    self.get-native-object-no-reffing, $appinfo
  )
}

sub g_app_info_get_icon (
  GAppInfo $appinfo --> GIcon
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-id:
=begin pod
=head2 g-app-info-get-id

Gets the ID of an application. An id is a string that identifies the application. The exact format of the id is platform dependent. For instance, on Unix this is the desktop file id from the xdg menu specification.

Note that the returned ID may be C<undefined>, depending on how the I<appinfo> has been constructed.

Returns: a string containing the application's ID.

  method g-app-info-get-id ( GAppInfo $appinfo --> Str )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-get-id ( GAppInfo $appinfo --> Str ) {

  g_app_info_get_id(
    self.get-native-object-no-reffing, $appinfo
  )
}

sub g_app_info_get_id (
  GAppInfo $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-name:
=begin pod
=head2 g-app-info-get-name

Gets the installed name of the application.

Returns: the name of the application for I<appinfo>.

  method g-app-info-get-name ( GAppInfo $appinfo --> Str )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-get-name ( GAppInfo $appinfo --> Str ) {

  g_app_info_get_name(
    self.get-native-object-no-reffing, $appinfo
  )
}

sub g_app_info_get_name (
  GAppInfo $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-recommended-for-type:
=begin pod
=head2 g-app-info-get-recommended-for-type



  method g-app-info-get-recommended-for-type ( Str $content_type --> N-GList )

=item Str $content_type;
=end pod

method g-app-info-get-recommended-for-type ( Str $content_type --> N-GList ) {

  g_app_info_get_recommended_for_type(
    self.get-native-object-no-reffing, $content_type
  )
}

sub g_app_info_get_recommended_for_type (
  gchar-ptr $content_type --> N-GList
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-get-supported-types:
=begin pod
=head2 g-app-info-get-supported-types

Retrieves the list of content types that I<app-info> claims to support. If this information is not provided by the environment, this function will return C<undefined>. This function does not take in consideration associations added with C<g-app-info-add-supports-type()>, but only those exported directly by the application.

Returns:   (element-type utf8): a list of content types.

  method g-app-info-get-supported-types ( GAppInfo $appinfo --> CArray[Str] )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo> that can handle files
=end pod

method g-app-info-get-supported-types ( GAppInfo $appinfo --> CArray[Str] ) {

  g_app_info_get_supported_types(
    self.get-native-object-no-reffing, $appinfo
  )
}

sub g_app_info_get_supported_types (
  GAppInfo $appinfo --> gchar-pptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-launch:
=begin pod
=head2 g-app-info-launch

Launches the application. Passes I<files> to the launched application as arguments, using the optional I<context> to get information about the details of the launcher (like what screen it is on). On error, I<error> will be set accordingly.

To launch the application without arguments pass a C<undefined> I<files> list.

Note that even if the launch is successful the application launched can fail to start if it runs into problems during startup. There is no way to detect this.

Some URIs can be changed when passed through a GFile (for instance unsupported URIs with strange formats like mailto:), so if you have a textual URI you want to pass in as argument, consider using C<g-app-info-launch-uris()> instead.

The launched application inherits the environment of the launching process, but it can be modified with C<g-app-launch-context-setenv()> and C<g-app-launch-context-unsetenv()>.

On UNIX, this function sets the `GIO-LAUNCHED-DESKTOP-FILE` environment variable with the path of the launched desktop file and `GIO-LAUNCHED-DESKTOP-FILE-PID` to the process id of the launched process. This can be used to ignore `GIO-LAUNCHED-DESKTOP-FILE`, should it be inherited by further processes. The `DISPLAY` and `DESKTOP-STARTUP-ID` environment variables are also set, based on information provided in I<context>.

Returns: C<True> on successful launch, C<False> otherwise.

  method g-app-info-launch ( GAppInfo $appinfo, N-GList $files, GAppLaunchContext $context, N-GError $error --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>
=item N-GList $files;  (element-type GFile): a B<Gnome::Gio::List> of B<Gnome::Gio::File> objects
=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext> or C<undefined>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method g-app-info-launch ( GAppInfo $appinfo, $files is copy, GAppLaunchContext $context, $error is copy --> Bool ) {
  $files .= get-native-object-no-reffing unless $files ~~ N-GList;
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_launch(
    self.get-native-object-no-reffing, $appinfo, $files, $context, $error
  ).Bool
}

sub g_app_info_launch (
  GAppInfo $appinfo, N-GList $files, GAppLaunchContext $context, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-launch-default-for-uri:
=begin pod
=head2 g-app-info-launch-default-for-uri

Utility function that launches the default application registered to handle the specified uri. Synchronous I/O is done on the uri to detect the type of the file if required.

The D-Bus–activated applications don't have to be started if your application terminates too soon after this function. To prevent this, use C<g-app-info-launch-default-for-uri()> instead.

Returns: C<True> on success, C<False> on error.

  method g-app-info-launch-default-for-uri ( Str $uri, GAppLaunchContext $context, N-GError $error --> Bool )

=item Str $uri; the uri to show
=item GAppLaunchContext $context; an optional B<Gnome::Gio::AppLaunchContext>
=item N-GError $error; return location for an error, or C<undefined>
=end pod

method g-app-info-launch-default-for-uri ( Str $uri, GAppLaunchContext $context, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_launch_default_for_uri(
    self.get-native-object-no-reffing, $uri, $context, $error
  ).Bool
}

sub g_app_info_launch_default_for_uri (
  gchar-ptr $uri, GAppLaunchContext $context, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-launch-default-for-uri-async:
=begin pod
=head2 g-app-info-launch-default-for-uri-async

Async version of C<g-app-info-launch-default-for-uri()>.

This version is useful if you are interested in receiving error information in the case where the application is sandboxed and the portal may present an application chooser dialog to the user.

This is also useful if you want to be sure that the D-Bus–activated applications are really started before termination and if you are interested in receiving error information from their activation.

  method g-app-info-launch-default-for-uri-async ( Str $uri, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $uri; the uri to show
=item GAppLaunchContext $context; an optional B<Gnome::Gio::AppLaunchContext>
=item GCancellable $cancellable; a B<Gnome::Gio::Cancellable>
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is done
=item Pointer $user_data; data to pass to I<callback>
=end pod

method g-app-info-launch-default-for-uri-async ( Str $uri, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_app_info_launch_default_for_uri_async(
    self.get-native-object-no-reffing, $uri, $context, $cancellable, $callback, $user_data
  );
}

sub g_app_info_launch_default_for_uri_async (
  gchar-ptr $uri, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-launch-default-for-uri-finish:
=begin pod
=head2 g-app-info-launch-default-for-uri-finish

Finishes an asynchronous launch-default-for-uri operation.

Returns: C<True> if the launch was successful, C<False> if I<error> is set

  method g-app-info-launch-default-for-uri-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; return location for an error, or C<undefined>
=end pod

method g-app-info-launch-default-for-uri-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_launch_default_for_uri_finish(
    self.get-native-object-no-reffing, $result, $error
  ).Bool
}

sub g_app_info_launch_default_for_uri_finish (
  GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-launch-uris:
=begin pod
=head2 g-app-info-launch-uris

Launches the application. This passes the I<uris> to the launched application as arguments, using the optional I<context> to get information about the details of the launcher (like what screen it is on). On error, I<error> will be set accordingly.

To launch the application without arguments pass a C<undefined> I<uris> list.

Note that even if the launch is successful the application launched can fail to start if it runs into problems during startup. There is no way to detect this.

Returns: C<True> on successful launch, C<False> otherwise.

  method g-app-info-launch-uris ( GAppInfo $appinfo, N-GList $uris, GAppLaunchContext $context, N-GError $error --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>
=item N-GList $uris;  (element-type utf8): a B<Gnome::Gio::List> containing URIs to launch.
=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext> or C<undefined>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method g-app-info-launch-uris ( GAppInfo $appinfo, $uris is copy, GAppLaunchContext $context, $error is copy --> Bool ) {
  $uris .= get-native-object-no-reffing unless $uris ~~ N-GList;
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_launch_uris(
    self.get-native-object-no-reffing, $appinfo, $uris, $context, $error
  ).Bool
}

sub g_app_info_launch_uris (
  GAppInfo $appinfo, N-GList $uris, GAppLaunchContext $context, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-launch-uris-async:
=begin pod
=head2 g-app-info-launch-uris-async

Async version of C<g-app-info-launch-uris()>.

The I<callback> is invoked immediately after the application launch, but it waits for activation in case of D-Bus–activated applications and also provides extended error information for sandboxed applications, see notes for C<g-app-info-launch-default-for-uri-async()>.

  method g-app-info-launch-uris-async ( GAppInfo $appinfo, N-GList $uris, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>
=item N-GList $uris;  (element-type utf8): a B<Gnome::Gio::List> containing URIs to launch.
=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext> or C<undefined>
=item GCancellable $cancellable; a B<Gnome::Gio::Cancellable>
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is done
=item Pointer $user_data; data to pass to I<callback>
=end pod

method g-app-info-launch-uris-async ( GAppInfo $appinfo, $uris is copy, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {
  $uris .= get-native-object-no-reffing unless $uris ~~ N-GList;

  g_app_info_launch_uris_async(
    self.get-native-object-no-reffing, $appinfo, $uris, $context, $cancellable, $callback, $user_data
  );
}

sub g_app_info_launch_uris_async (
  GAppInfo $appinfo, N-GList $uris, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-launch-uris-finish:
=begin pod
=head2 g-app-info-launch-uris-finish

Finishes a C<g-app-info-launch-uris-async()> operation.

Returns: C<True> on successful launch, C<False> otherwise.

  method g-app-info-launch-uris-finish ( GAppInfo $appinfo, GAsyncResult $result, N-GError $error --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>
=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method g-app-info-launch-uris-finish ( GAppInfo $appinfo, GAsyncResult $result, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_launch_uris_finish(
    self.get-native-object-no-reffing, $appinfo, $result, $error
  ).Bool
}

sub g_app_info_launch_uris_finish (
  GAppInfo $appinfo, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-remove-supports-type:
=begin pod
=head2 g-app-info-remove-supports-type

Removes a supported type from an application, if possible.

Returns: C<True> on success, C<False> on error.

  method g-app-info-remove-supports-type ( GAppInfo $appinfo, Str $content_type, N-GError $error --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=item Str $content_type; a string.
=item N-GError $error; a B<Gnome::Gio::Error>.
=end pod

method g-app-info-remove-supports-type ( GAppInfo $appinfo, Str $content_type, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_remove_supports_type(
    self.get-native-object-no-reffing, $appinfo, $content_type, $error
  ).Bool
}

sub g_app_info_remove_supports_type (
  GAppInfo $appinfo, gchar-ptr $content_type, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-reset-type-associations:
=begin pod
=head2 g-app-info-reset-type-associations



  method g-app-info-reset-type-associations ( Str $content_type )

=item Str $content_type;
=end pod

method g-app-info-reset-type-associations ( Str $content_type ) {

  g_app_info_reset_type_associations(
    self.get-native-object-no-reffing, $content_type
  );
}

sub g_app_info_reset_type_associations (
  gchar-ptr $content_type
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-set-as-default-for-extension:
=begin pod
=head2 g-app-info-set-as-default-for-extension

Sets the application as the default handler for the given file extension.

Returns: C<True> on success, C<False> on error.

  method g-app-info-set-as-default-for-extension ( GAppInfo $appinfo, Str $extension, N-GError $error --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=item Str $extension; (type filename): a string containing the file extension (without the dot).
=item N-GError $error; a B<Gnome::Gio::Error>.
=end pod

method g-app-info-set-as-default-for-extension ( GAppInfo $appinfo, Str $extension, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_set_as_default_for_extension(
    self.get-native-object-no-reffing, $appinfo, $extension, $error
  ).Bool
}

sub g_app_info_set_as_default_for_extension (
  GAppInfo $appinfo, gchar-ptr $extension, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-set-as-default-for-type:
=begin pod
=head2 g-app-info-set-as-default-for-type

Sets the application as the default handler for a given type.

Returns: C<True> on success, C<False> on error.

  method g-app-info-set-as-default-for-type ( GAppInfo $appinfo, Str $content_type, N-GError $error --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=item Str $content_type; the content type.
=item N-GError $error; a B<Gnome::Gio::Error>.
=end pod

method g-app-info-set-as-default-for-type ( GAppInfo $appinfo, Str $content_type, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_set_as_default_for_type(
    self.get-native-object-no-reffing, $appinfo, $content_type, $error
  ).Bool
}

sub g_app_info_set_as_default_for_type (
  GAppInfo $appinfo, gchar-ptr $content_type, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-set-as-last-used-for-type:
=begin pod
=head2 g-app-info-set-as-last-used-for-type

Sets the application as the last used application for a given type. This will make the application appear as first in the list returned by C<g-app-info-get-recommended-for-type()>, regardless of the default application for that content type.

Returns: C<True> on success, C<False> on error.

  method g-app-info-set-as-last-used-for-type ( GAppInfo $appinfo, Str $content_type, N-GError $error --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=item Str $content_type; the content type.
=item N-GError $error; a B<Gnome::Gio::Error>.
=end pod

method g-app-info-set-as-last-used-for-type ( GAppInfo $appinfo, Str $content_type, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_set_as_last_used_for_type(
    self.get-native-object-no-reffing, $appinfo, $content_type, $error
  ).Bool
}

sub g_app_info_set_as_last_used_for_type (
  GAppInfo $appinfo, gchar-ptr $content_type, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-should-show:
=begin pod
=head2 g-app-info-should-show

Checks if the application info should be shown in menus that list available applications.

Returns: C<True> if the I<appinfo> should be shown, C<False> otherwise.

  method g-app-info-should-show ( GAppInfo $appinfo --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-should-show ( GAppInfo $appinfo --> Bool ) {

  g_app_info_should_show(
    self.get-native-object-no-reffing, $appinfo
  ).Bool
}

sub g_app_info_should_show (
  GAppInfo $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-supports-files:
=begin pod
=head2 g-app-info-supports-files

Checks if the application accepts files as arguments.

Returns: C<True> if the I<appinfo> supports files.

  method g-app-info-supports-files ( GAppInfo $appinfo --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-supports-files ( GAppInfo $appinfo --> Bool ) {

  g_app_info_supports_files(
    self.get-native-object-no-reffing, $appinfo
  ).Bool
}

sub g_app_info_supports_files (
  GAppInfo $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-info-supports-uris:
=begin pod
=head2 g-app-info-supports-uris

Checks if the application supports reading files and directories from URIs.

Returns: C<True> if the I<appinfo> supports URIs.

  method g-app-info-supports-uris ( GAppInfo $appinfo --> Bool )

=item GAppInfo $appinfo; a B<Gnome::Gio::AppInfo>.
=end pod

method g-app-info-supports-uris ( GAppInfo $appinfo --> Bool ) {

  g_app_info_supports_uris(
    self.get-native-object-no-reffing, $appinfo
  ).Bool
}

sub g_app_info_supports_uris (
  GAppInfo $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-launch-context-get-display:
=begin pod
=head2 g-app-launch-context-get-display

Gets the display string for the I<context>. This is used to ensure new applications are started on the same display as the launching application, by setting the `DISPLAY` environment variable.

Returns: a display string for the display.

  method g-app-launch-context-get-display ( GAppLaunchContext $context, GAppInfo $info, N-GList $files --> Str )

=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext>
=item GAppInfo $info; a B<Gnome::Gio::AppInfo>
=item N-GList $files; (element-type GFile): a B<Gnome::Gio::List> of B<Gnome::Gio::File> objects
=end pod

method g-app-launch-context-get-display ( GAppLaunchContext $context, GAppInfo $info, $files is copy --> Str ) {
  $files .= get-native-object-no-reffing unless $files ~~ N-GList;

  g_app_launch_context_get_display(
    self.get-native-object-no-reffing, $context, $info, $files
  )
}

sub g_app_launch_context_get_display (
  GAppLaunchContext $context, GAppInfo $info, N-GList $files --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-launch-context-get-environment:
=begin pod
=head2 g-app-launch-context-get-environment

Gets the complete environment variable list to be passed to the child process when I<context> is used to launch an application. This is a C<undefined>-terminated array of strings, where each string has the form `KEY=VALUE`.

Returns:  (element-type filename) : the child's environment

  method g-app-launch-context-get-environment ( GAppLaunchContext $context --> CArray[Str] )

=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext>
=end pod

method g-app-launch-context-get-environment ( GAppLaunchContext $context --> CArray[Str] ) {

  g_app_launch_context_get_environment(
    self.get-native-object-no-reffing, $context
  )
}

sub g_app_launch_context_get_environment (
  GAppLaunchContext $context --> gchar-pptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-launch-context-get-startup-notify-id:
=begin pod
=head2 g-app-launch-context-get-startup-notify-id

Initiates startup notification for the application and returns the `DESKTOP-STARTUP-ID` for the launched operation, if supported.

Startup notification IDs are defined in the [FreeDesktop.Org Startup Notifications standard](http://standards.freedesktop.org/startup-notification-spec/startup-notification-latest.txt").

Returns: a startup notification ID for the application, or C<undefined> if not supported.

  method g-app-launch-context-get-startup-notify-id ( GAppLaunchContext $context, GAppInfo $info, N-GList $files --> Str )

=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext>
=item GAppInfo $info; a B<Gnome::Gio::AppInfo>
=item N-GList $files; (element-type GFile): a B<Gnome::Gio::List> of of B<Gnome::Gio::File> objects
=end pod

method g-app-launch-context-get-startup-notify-id ( GAppLaunchContext $context, GAppInfo $info, $files is copy --> Str ) {
  $files .= get-native-object-no-reffing unless $files ~~ N-GList;

  g_app_launch_context_get_startup_notify_id(
    self.get-native-object-no-reffing, $context, $info, $files
  )
}

sub g_app_launch_context_get_startup_notify_id (
  GAppLaunchContext $context, GAppInfo $info, N-GList $files --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-launch-context-launch-failed:
=begin pod
=head2 g-app-launch-context-launch-failed

Called when an application has failed to launch, so that it can cancel the application startup notification started in C<g-app-launch-context-get-startup-notify-id()>.

  method g-app-launch-context-launch-failed ( GAppLaunchContext $context, Str $startup_notify_id )

=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext>.
=item Str $startup_notify_id; the startup notification id that was returned by C<g-app-launch-context-get-startup-notify-id()>.
=end pod

method g-app-launch-context-launch-failed ( GAppLaunchContext $context, Str $startup_notify_id ) {

  g_app_launch_context_launch_failed(
    self.get-native-object-no-reffing, $context, $startup_notify_id
  );
}

sub g_app_launch_context_launch_failed (
  GAppLaunchContext $context, gchar-ptr $startup_notify_id
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-launch-context-new:
=begin pod
=head2 g-app-launch-context-new

Creates a new application launch context. This is not normally used, instead you instantiate a subclass of this, such as B<Gnome::Gio::AppLaunchContext>.

Returns: a B<Gnome::Gio::AppLaunchContext>.

  method g-app-launch-context-new ( --> GAppLaunchContext )

=end pod

method g-app-launch-context-new ( --> GAppLaunchContext ) {

  g_app_launch_context_new(
    self.get-native-object-no-reffing,
  )
}

sub g_app_launch_context_new (
   --> GAppLaunchContext
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-launch-context-setenv:
=begin pod
=head2 g-app-launch-context-setenv

Arranges for I<variable> to be set to I<value> in the child's environment when I<context> is used to launch an application.

  method g-app-launch-context-setenv ( GAppLaunchContext $context, Str $variable, Str $value )

=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext>
=item Str $variable; (type filename): the environment variable to set
=item Str $value; (type filename): the value for to set the variable to.
=end pod

method g-app-launch-context-setenv ( GAppLaunchContext $context, Str $variable, Str $value ) {

  g_app_launch_context_setenv(
    self.get-native-object-no-reffing, $context, $variable, $value
  );
}

sub g_app_launch_context_setenv (
  GAppLaunchContext $context, gchar-ptr $variable, gchar-ptr $value
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-app-launch-context-unsetenv:
=begin pod
=head2 g-app-launch-context-unsetenv

Arranges for I<variable> to be unset in the child's environment when I<context> is used to launch an application.

  method g-app-launch-context-unsetenv ( GAppLaunchContext $context, Str $variable )

=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext>
=item Str $variable; (type filename): the environment variable to remove
=end pod

method g-app-launch-context-unsetenv ( GAppLaunchContext $context, Str $variable ) {

  g_app_launch_context_unsetenv(
    self.get-native-object-no-reffing, $context, $variable
  );
}

sub g_app_launch_context_unsetenv (
  GAppLaunchContext $context, gchar-ptr $variable
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get:
=begin pod
=head2 get

Gets the B<Gnome::Gio::AppInfoMonitor> for the current thread-default main context.

The B<Gnome::Gio::AppInfoMonitor> will emit a "changed" signal in the thread-default main context whenever the list of installed applications (as reported by C<g-app-info-get-all()>) may have changed.

You must only call C<g-object-unref()> on the return value from under the same main context as you created it.

Returns: a reference to a B<Gnome::Gio::AppInfoMonitor>

  method get ( --> GAppInfoMonitor )

=end pod

method get ( --> GAppInfoMonitor ) {

  g_app_info_monitor_get(
    self.get-native-object-no-reffing,
  )
}

sub g_app_info_monitor_get (
   --> GAppInfoMonitor
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-type:
=begin pod
=head2 get-type



  method get-type ( --> N-GObject )

=end pod

method get-type ( --> N-GObject ) {

  g_app_info_monitor_get_type(
    self.get-native-object-no-reffing,
  )
}

sub g_app_info_monitor_get_type (
   --> N-GObject
) is native(&gio-lib)
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
=comment #TS:0:changed:
=head3 changed

  method handler (
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($appinfomonitor),
    *%user-options
  );

=item $appinfomonitor;
=item $_handle_id; the registered event handler id

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

=end pod
