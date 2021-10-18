#TL:1:Gnome::Gio::AppInfo:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::AppInfo

Application information and launch contexts


=comment ![](images/X.png)


=head1 Description

B<Gnome::Gio::AppInfo> and B<Gnome::Gio::AppLaunchContext> are used for describing and launching applications installed on the system.

As of GLib 2.20, URIs will always be converted to POSIX paths (using C<g-file-get-path()>) when using C<launch()> even if the application requested a URI and not a POSIX path. For example, for a desktop-file based application with the C<Exec> key C<totem %U> and a single URI, C<sftp://foo/file.avi>, then C</home/user/.gvfs/sftp> on C<foo/file.avi> will be passed. This will only work if a set of suitable GIO extensions (such as gvfs 2.26 compiled with FUSE support), is available and operational; if this is not the case, the URI will be passed unmodified to the application. Some URIs, such as `mailto:`, of course cannot be mapped to a POSIX path (in gvfs there's no FUSE mount for it); such URIs will be passed unmodified to the application.

=begin comment
Specifically for gvfs 2.26 and later, the POSIX URI will be mapped back to the GIO URI in the B<Gnome::Gio::File> constructors (since gvfs implements the B<Gnome::Gio::Vfs> extension point). As such, if the application needs to examine the URI, it needs to use C<g-file-get-uri()> or similar on B<Gnome::Gio::File>. In other words, an application cannot assume that the URI passed to e.g. C<g-file-new-for-commandline-arg()> is equal to the result of C<g-file-get-uri()>. The following snippet illustrates this:
=end comment

=begin comment
|[
GFile *f;
char *uri;

file = g-file-new-for-commandline-arg (uri-from-commandline);

uri = g-file-get-uri (file);
strcmp (uri, uri-from-commandline) == 0;
g-free (uri);

if (g-file-has-uri-scheme (file, "cdda"))
  {
    // do something special with uri
  }
g-object-unref (file);
]|

This code will work when both `cdda://sr0/Track 1.wav` and `/home/user/.gvfs/cdda on sr0/Track 1.wav` is passed to the application. It should be noted that it's generally not safe for applications to rely on the format of a particular URIs. Different launcher applications (e.g. file managers) may have  different ideas of what a given URI means.
=end comment


=head2 See Also

B<Gnome::Gio::AppInfoMonitor> and B<Gnome::Gio::AppLaunchContext>


=head1 Synopsis

=head2 Declaration

  unit class Gnome::Gio::AppInfo;
  also is Gnome::GObject::Object;


=chead2 Uml Diagram

![](plantuml/AppInfo.svg)


=head2 Note

B<Gnome::Gio::AppInfo> is defined as an interface in the Gnome libraries and therefore should be defined as a Raku role. However, the Gtk modules like B<Gnome::Gtk3::AppChooser > returns B<Gnome::Gio::AppInfo> objects as if they are class objects. The only one which use the module as an interface, is GDesktopAppInfo which will not be implemented for the time being. When it does, it will inherit it as a class.

=end pod

#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::Error;
use Gnome::Glib::List;

use Gnome::GObject::Object;

use Gnome::Gio::Enums;
use Gnome::Gio::AppLaunchContext;
use Gnome::Gio::File;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::AppInfo:auth<github:MARTIMM>:ver<0.1.0>;
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
#my Bool $signals-added = False;

has Gnome::Glib::Error $.last-error;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :command-line, :application-name, :flags

Create a new B<Gnome::Gio::AppInfo> object. Note that for commandline, the quoting rules of the Exec key of the freedesktop.org Desktop Entry Specification are applied. For example, if the commandline contains percent-encoded URIs, the percent-character must be doubled in order to prevent it from being swallowed by Exec key unquoting. See the specification for exact quoting rules.

  multi method new (
    Str :$command-line!, Str :$application-name!,
    UInt :$flags = G_APP_INFO_CREATE_NONE
  )

=head3 :native-object

Create a B<Gnome::Gio::AppInfo> object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

# TM:0:new():inheriting
#TM:1:new(:command-line,:application-name,:flags):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  $!last-error .= new(:native-object(N-GError));

  # add signal info in the form of w*<signal-name>.
#  unless $signals-added {
#    $signals-added = self.add-signal-types( $?CLASS.^name,
#      :w2<launched>, :w1<launch-failed>, :w0<changed>,
#    );

    # signals from interfaces
    #_add_..._signal_types($?CLASS.^name);
#  }


  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::AppInfo' #`{{ or %options<GAppInfo> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      my CArray[N-GError] $error .= new;
      if %options<command-line>:exists and ?%options<application-name> {
        $no = _g_app_info_create_from_commandline(
          %options<command-line>, %options<application-name>,
          %options<flags> // G_APP_INFO_CREATE_NONE, $error
        );

        $!last-error .= new(:native-object($error[0]));
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
        $no = _g_app_info_new();
      }
      }}

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GAppInfo');
  }
}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

# interfaces are not instantiated
#submethod BUILD ( *%options ) { }

#`{{
# All interface calls should become methods
#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _g_app_info_interface ( $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &:("g_app_info_$native-sub"); };
# check for gtk_, gdk_, g_, pango_, cairo_ !!!
  try { $s = &:("gtk_$native-sub"); } unless ?$s;
  try { $s = &:($native-sub); } if !$s and $native-sub ~~ m/^ 'gtk_' /;

  $s;
}
}}

#`{{
#-------------------------------------------------------------------------------
# setup signals from interface
method _add_g_app_info_interface_signal_types ( Str $class-name ) {
  # add signal info in the form of w*<signal-name>.
  self.add-signal-types( $?CLASS.^name,
    :w0<changed>, :w1<launch-failed>, :w2<launched>,
  );
}
}}

#-------------------------------------------------------------------------------
#TM:0:add-supports-type:
=begin pod
=head2 add-supports-type

Adds a content type to the application information to indicate the application is capable of opening files with the given content type.

Returns: An invalid error object on success, valid on error. Check the C<.message()> of this object to see what happened.

  method add-supports-type ( Str $content-type --> Gnome::Glib::Error )

=item Str $content-type; a string.
=end pod

method add-supports-type ( Str $content-type --> Gnome::Glib::Error ) {
  my CArray[N-GError] $error .= new;
  g_app_info_add_supports_type(
    self._f('GAppInfo'), $content-type, $error
  ).Bool
}

sub g_app_info_add_supports_type (
  N-GObject $appinfo, gchar-ptr $content-type, CArray[N-GError] $error
  --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:can-delete:
=begin pod
=head2 can-delete

Obtains the information whether the B<Gnome::Gio::AppInfo> can be deleted. See C<delete()>.

Returns: C<True> if I<appinfo> can be deleted

  method can-delete ( --> Bool )

=end pod

method can-delete ( --> Bool ) {

  g_app_info_can_delete(
    self._f('GAppInfo'),
  ).Bool
}

sub g_app_info_can_delete (
  N-GObject $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:can-remove-supports-type:
=begin pod
=head2 can-remove-supports-type

Checks if a supported content type can be removed from an application.

Returns: C<True> if it is possible to remove supported content types from a given I<appinfo>, C<False> if not.

  method can-remove-supports-type ( --> Bool )

=end pod

method can-remove-supports-type ( --> Bool ) {

  g_app_info_can_remove_supports_type(
    self._f('GAppInfo'),
  ).Bool
}

sub g_app_info_can_remove_supports_type (
  N-GObject $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:delete:
=begin pod
=head2 delete

Tries to delete a B<Gnome::Gio::AppInfo>.

On some platforms, there may be a difference between user-defined B<Gnome::Gio::AppInfos> which can be deleted, and system-wide ones which cannot. See C<can-delete()>.

Virtual: do-delete

Returns: C<True> if I<appinfo> has been deleted

  method delete ( --> Bool )

=end pod

method delete ( --> Bool ) {

  g_app_info_delete(
    self._f('GAppInfo'),
  ).Bool
}

sub g_app_info_delete (
  N-GObject $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dup:
=begin pod
=head2 dup

Creates a duplicate of a B<Gnome::Gio::AppInfo>.

Returns: a duplicate of I<appinfo>.

  method dup ( --> N-GObject )

=end pod

method dup ( --> N-GObject ) {

  g_app_info_dup(
    self._f('GAppInfo'),
  )
}

sub g_app_info_dup (
  N-GObject $appinfo --> N-GObject
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:equal:
=begin pod
=head2 equal

Checks if two B<Gnome::Gio::AppInfo>s are equal.

Note that the check <emphasis>may not</emphasis> compare each individual field, and only does an identity check. In case detecting changes in the contents is needed, program code must additionally compare relevant fields.

Returns: C<True> if I<appinfo1> is equal to I<appinfo2>. C<False> otherwise.

  method equal ( N-GObject $appinfo2 --> Bool )

=item N-GObject $appinfo2; the second B<Gnome::Gio::AppInfo>.
=end pod

method equal ( N-GObject $appinfo2 --> Bool ) {

  g_app_info_equal(
    self._f('GAppInfo'), $appinfo2
  ).Bool
}

sub g_app_info_equal (
  N-GObject $appinfo1, N-GObject $appinfo2 --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-all:
=begin pod
=head2 get-all

Gets a list of all of the applications currently registered on this system.

For desktop files, this includes applications that have NoDisplay=true set or are excluded from display by means of OnlyShowIn or NotShowIn. See C<.should-show()>. The returned list does not include applications which have the Hidden key set.

Returns a newly allocated list of references to B<Gnome::Gio::AppInfo>s.

  method get-all ( --> Gnome::Glib::List )

=end pod

method get-all ( --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(g_app_info_get_all(self._f('GAppInfo')))
  )
}

sub g_app_info_get_all (
   --> N-GList
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-all-for-type:
=begin pod
=head2 get-all-for-type

Gets a list of all B<Gnome::Gio::AppInfo>s for a given content type, including the recommended and fallback GAppInfos. See C<.get-recommended-for-type()> and C<get-fallback-for-type()>.

  method get-all-for-type ( Str $content_type --> Gnome::Glib::List )

=item Str $content_type;
=end pod

method get-all-for-type ( Str $content_type --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(:native-object(
      g_app_info_get_all_for_type( self._f('GAppInfo'), $content_type)
    )
  )
}

sub g_app_info_get_all_for_type (
  gchar-ptr $content_type --> N-GList
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-commandline:
=begin pod
=head2 get-commandline

Gets the commandline with which the application will be started.

Returns: (type filename): a string containing the I<appinfo>'s commandline, or C<undefined> if this information is not available

  method get-commandline ( --> Str )

=end pod

method get-commandline ( --> Str ) {
  g_app_info_get_commandline(self._f('GAppInfo'))
}

sub g_app_info_get_commandline (
  N-GObject $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-default-for-type:
#TM:0:get-default-for-type-rk:
=begin pod
=head2 get-default-for-type, get-default-for-type-rk

Gets the default B<Gnome::Gio::AppInfo> for a given content type.

  method get-default-for-type (
    Str $content_type, Bool $must_support_uris
    --> N-GObject
  )

  method get-default-for-type-rk (
    Str $content_type, Bool $must_support_uris
    --> Gnome::Gio::AppInfo
  )

=item Str $content_type;
=item Bool $must_support_uris;
=end pod

method get-default-for-type (
  Str $content_type, Bool $must_support_uris --> N-GObject
) {
  g_app_info_get_default_for_type(
    self._f('GAppInfo'), $content_type, $must_support_uris
  )
}

method get-default-for-type-rk (
  Str $content_type, Bool $must_support_uris --> Gnome::Gio::AppInfo
) {
  Gnome::Gio::AppInfo.new(
    :native-object(
      g_app_info_get_default_for_type(
        self._f('GAppInfo'), $content_type, $must_support_uris
      )
    )
  )
}

sub g_app_info_get_default_for_type (
  gchar-ptr $content_type, gboolean $must_support_uris --> N-GObject
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-default-for-uri-scheme:
#TM:0:get-default-for-uri-scheme-rk:
=begin pod
=head2 get-default-for-uri-scheme, get-default-for-uri-scheme-rk

Gets the default application for handling URIs with the given URI scheme. A URI scheme is the initial part of the URI, up to but not including the ':', e.g. "http", "ftp" or "sip".

  method get-default-for-uri-scheme ( Str $uri_scheme --> N-GObject )

  method get-default-for-uri-scheme-rk (
    Str $uri_scheme --> Gnome::Gio::AppInfo
  )

=item Str $uri_scheme;
=end pod

method get-default-for-uri-scheme ( Str $uri_scheme --> N-GObject ) {
  g_app_info_get_default_for_uri_scheme( self._f('GAppInfo'), $uri_scheme)
}

method get-default-for-uri-scheme-rk (
  Str $uri_scheme --> Gnome::Gio::AppInfo
) {
  Gnome::Gio::AppInfo.new(
    :native-object(
      g_app_info_get_default_for_uri_scheme( self._f('GAppInfo'), $uri_scheme)
    )
  )
}

sub g_app_info_get_default_for_uri_scheme (
  gchar-ptr $uri_scheme --> N-GObject
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-description:
=begin pod
=head2 get-description

Gets a human-readable description of an installed application.

Returns: a string containing a description of the application I<appinfo>, or C<undefined> if none.

  method get-description ( --> Str )

=end pod

method get-description ( --> Str ) {
  g_app_info_get_description(self._f('GAppInfo'))
}

sub g_app_info_get_description (
  N-GObject $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-display-name:
=begin pod
=head2 get-display-name

Gets the display name of the application. The display name is often more descriptive to the user than the name itself.

Returns: the display name of the application for I<appinfo>, or the name if no display name is available.

  method get-display-name ( --> Str )

=end pod

method get-display-name ( --> Str ) {
  g_app_info_get_display_name(self._f('GAppInfo'))
}

sub g_app_info_get_display_name (
  N-GObject $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-executable:
=begin pod
=head2 get-executable

Gets the executable's name for the installed application.

Returns: (type filename): a string containing the I<appinfo>'s application binaries name

  method get-executable ( --> Str )

=end pod

method get-executable ( --> Str ) {
  g_app_info_get_executable(self._f('GAppInfo'))
}

sub g_app_info_get_executable (
  N-GObject $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-fallback-for-type:
=begin pod
=head2 get-fallback-for-type

Gets a list of fallback B<Gnome::Gio::AppInfo> for a given content type, i.e. those applications which claim to support the given content type by MIME type subclassing and not directly.

  method get-fallback-for-type ( Str $content_type --> N-GList )

=item Str $content_type;
=end pod

method get-fallback-for-type ( Str $content_type --> N-GList ) {
  g_app_info_get_fallback_for_type( self._f('GAppInfo'), $content_type)
}

sub g_app_info_get_fallback_for_type (
  gchar-ptr $content_type --> N-GList
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-icon:
=begin pod
=head2 get-icon

Gets the icon for the application.

Returns: the default B<Gnome::Gio::Icon> for I<appinfo> or C<undefined> if there is no default icon.

  method get-icon ( --> GIcon )

=end pod

method get-icon ( --> GIcon ) {

  g_app_info_get_icon(
    self._f('GAppInfo'),
  )
}

sub g_app_info_get_icon (
  N-GObject $appinfo --> GIcon
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:get-id:
=begin pod
=head2 get-id

Gets the ID of an application. An id is a string that identifies the application. The exact format of the id is platform dependent. For instance, on Unix this is the desktop file id from the xdg menu specification.

Note that the returned ID may be C<undefined>, depending on how the I<appinfo> has been constructed.

Returns: a string containing the application's ID.

  method get-id ( --> Str )

=end pod

method get-id ( --> Str ) {

  g_app_info_get_id(
    self._f('GAppInfo'),
  )
}

sub g_app_info_get_id (
  N-GObject $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-name:
=begin pod
=head2 get-name

Gets the installed name of the application.

Returns: the name of the application for I<appinfo>.

  method get-name ( --> Str )

=end pod

method get-name ( --> Str ) {
  g_app_info_get_name(self._f('GAppInfo'))
}

sub g_app_info_get_name (
  N-GObject $appinfo --> gchar-ptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-recommended-for-type:
=begin pod
=head2 get-recommended-for-type



  method get-recommended-for-type ( Str $content_type --> N-GList )

=item Str $content_type;
=end pod

method get-recommended-for-type ( Str $content_type --> N-GList ) {

  g_app_info_get_recommended_for_type(
    self._f('GAppInfo'), $content_type
  )
}

sub g_app_info_get_recommended_for_type (
  gchar-ptr $content_type --> N-GList
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-supported-types:
=begin pod
=head2 get-supported-types

Retrieves the list of content types that I<app-info> claims to support. If this information is not provided by the environment, this function will return C<undefined>. This function does not take in consideration associations added with C<add-supports-type()>, but only those exported directly by the application.

Returns:   (element-type utf8): a list of content types.

  method get-supported-types ( --> CArray[Str] )

=end pod

method get-supported-types ( --> CArray[Str] ) {

  g_app_info_get_supported_types(
    self._f('GAppInfo'),
  )
}

sub g_app_info_get_supported_types (
  N-GObject $appinfo --> gchar-pptr
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:launch:
=begin pod
=head2 launch

Launches the application. Passes I<files> to the launched application as arguments, using the optional I<context> to get information about the details of the launcher (like what screen it is on). On error, I<error> will be set accordingly.

To launch the application without arguments pass a C<undefined> I<files> list.

Note that even if the launch is successful the application launched can fail to start if it runs into problems during startup. There is no way to detect this.

Some URIs can be changed when passed through a GFile (for instance unsupported URIs with strange formats like mailto:), so if you have a textual URI you want to pass in as argument, consider using C<launch-uris()> instead.

The launched application inherits the environment of the launching process, but it can be modified with C<g-app-launch-context-setenv()> and C<g-app-launch-context-unsetenv()>.

On UNIX, this function sets the `GIO-LAUNCHED-DESKTOP-FILE` environment variable with the path of the launched desktop file and `GIO-LAUNCHED-DESKTOP-FILE-PID` to the process id of the launched process. This can be used to ignore `GIO-LAUNCHED-DESKTOP-FILE`, should it be inherited by further processes. The `DISPLAY` and `DESKTOP-STARTUP-ID` environment variables are also set, based on information provided in I<context>.

Returns: An error object which will be invalid on successful launch, valid otherwise and the error object must be checked for the error.

  method launch (
    Str @files, N-GObject $context
    --> Gnome::Glib::Error
  )

=item N-GList $files;  (element-type GFile): a B<Gnome::Gio::List> of B<Gnome::Gio::File> objects
=item N-GObject $context; a native B<Gnome::Gio::AppLaunchContext> or C<undefined>
=end pod

method launch (
  @files, $context is copy
  --> Gnome::Glib::Error
) {
  $context .= get-native-object-no-reffing unless $context ~~ N-GObject;
  my Gnome::Glib::List $flist .= new;
  my CArray[N-GError] $error;

  for @files -> $f {
    $flist .= append(Gnome::Gio::File.new(:path($f)));
  }

  my Bool $r = g_app_info_launch(
    self._f('GAppInfo'), $flist, $context, $error
  ).Bool;

  if $r {
    Gnome::Glib::Error.new(:native-object(N-GError))
  }

  else {
    Gnome::Glib::Error.new(:native-object($error[0]))
  }
}

sub g_app_info_launch (
  N-GObject $appinfo, N-GList $files, N-GObject $context, N-GError $error
  --> gboolean
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:launch-default-for-uri:
=begin pod
=head2 launch-default-for-uri

Utility function that launches the default application registered to handle the specified uri. Synchronous I/O is done on the uri to detect the type of the file if required.

The D-Bus–activated applications don't have to be started if your application terminates too soon after this function. To prevent this, use C<launch-default-for-uri()> instead.

Returns: C<True> on success, C<False> on error.

  method launch-default-for-uri ( Str $uri, GAppLaunchContext $context, N-GError $error --> Bool )

=item Str $uri; the uri to show
=item GAppLaunchContext $context; an optional B<Gnome::Gio::AppLaunchContext>
=item N-GError $error; return location for an error, or C<undefined>
=end pod

method launch-default-for-uri ( Str $uri, GAppLaunchContext $context, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_launch_default_for_uri(
    self._f('GAppInfo'), $uri, $context, $error
  ).Bool
}

sub g_app_info_launch_default_for_uri (
  gchar-ptr $uri, GAppLaunchContext $context, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:launch-default-for-uri-async:
=begin pod
=head2 launch-default-for-uri-async

Async version of C<launch-default-for-uri()>.

This version is useful if you are interested in receiving error information in the case where the application is sandboxed and the portal may present an application chooser dialog to the user.

This is also useful if you want to be sure that the D-Bus–activated applications are really started before termination and if you are interested in receiving error information from their activation.

  method launch-default-for-uri-async ( Str $uri, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item Str $uri; the uri to show
=item GAppLaunchContext $context; an optional B<Gnome::Gio::AppLaunchContext>
=item GCancellable $cancellable; a B<Gnome::Gio::Cancellable>
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is done
=item Pointer $user_data; data to pass to I<callback>
=end pod

method launch-default-for-uri-async ( Str $uri, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {

  g_app_info_launch_default_for_uri_async(
    self._f('GAppInfo'), $uri, $context, $cancellable, $callback, $user_data
  );
}

sub g_app_info_launch_default_for_uri_async (
  gchar-ptr $uri, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:launch-default-for-uri-finish:
=begin pod
=head2 launch-default-for-uri-finish

Finishes an asynchronous launch-default-for-uri operation.

Returns: C<True> if the launch was successful, C<False> if I<error> is set

  method launch-default-for-uri-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; return location for an error, or C<undefined>
=end pod

method launch-default-for-uri-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_launch_default_for_uri_finish(
    self._f('GAppInfo'), $result, $error
  ).Bool
}

sub g_app_info_launch_default_for_uri_finish (
  GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:launch-uris:
=begin pod
=head2 launch-uris

Launches the application. This passes the I<uris> to the launched application as arguments, using the optional I<context> to get information about the details of the launcher (like what screen it is on). On error, I<error> will be set accordingly.

To launch the application without arguments pass a C<undefined> I<uris> list.

Note that even if the launch is successful the application launched can fail to start if it runs into problems during startup. There is no way to detect this.

Returns: C<True> on successful launch, C<False> otherwise.

  method launch-uris ( N-GList $uris, GAppLaunchContext $context, N-GError $error --> Bool )

=item N-GList $uris;  (element-type utf8): a B<Gnome::Gio::List> containing URIs to launch.
=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext> or C<undefined>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method launch-uris ( $uris is copy, GAppLaunchContext $context, $error is copy --> Bool ) {
  $uris .= get-native-object-no-reffing unless $uris ~~ N-GList;
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_launch_uris(
    self._f('GAppInfo'), $uris, $context, $error
  ).Bool
}

sub g_app_info_launch_uris (
  N-GObject $appinfo, N-GList $uris, GAppLaunchContext $context, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:launch-uris-async:
=begin pod
=head2 launch-uris-async

Async version of C<launch-uris()>.

The I<callback> is invoked immediately after the application launch, but it waits for activation in case of D-Bus–activated applications and also provides extended error information for sandboxed applications, see notes for C<g-app-info-launch-default-for-uri-async()>.

  method launch-uris-async ( N-GList $uris, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data )

=item N-GList $uris;  (element-type utf8): a B<Gnome::Gio::List> containing URIs to launch.
=item GAppLaunchContext $context; a B<Gnome::Gio::AppLaunchContext> or C<undefined>
=item GCancellable $cancellable; a B<Gnome::Gio::Cancellable>
=item GAsyncReadyCallback $callback; a B<Gnome::Gio::AsyncReadyCallback> to call when the request is done
=item Pointer $user_data; data to pass to I<callback>
=end pod

method launch-uris-async ( $uris is copy, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, Pointer $user_data ) {
  $uris .= get-native-object-no-reffing unless $uris ~~ N-GList;

  g_app_info_launch_uris_async(
    self._f('GAppInfo'), $uris, $context, $cancellable, $callback, $user_data
  );
}

sub g_app_info_launch_uris_async (
  N-GObject $appinfo, N-GList $uris, GAppLaunchContext $context, GCancellable $cancellable, GAsyncReadyCallback $callback, gpointer $user_data
) is native(&gio-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:launch-uris-finish:
=begin pod
=head2 launch-uris-finish

Finishes a C<launch-uris-async()> operation.

Returns: C<True> on successful launch, C<False> otherwise.

  method launch-uris-finish ( GAsyncResult $result, N-GError $error --> Bool )

=item GAsyncResult $result; a B<Gnome::Gio::AsyncResult>
=item N-GError $error; a B<Gnome::Gio::Error>
=end pod

method launch-uris-finish ( GAsyncResult $result, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_launch_uris_finish(
    self._f('GAppInfo'), $result, $error
  ).Bool
}

sub g_app_info_launch_uris_finish (
  N-GObject $appinfo, GAsyncResult $result, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:remove-supports-type:
=begin pod
=head2 remove-supports-type

Removes a supported type from an application, if possible.

Returns: C<True> on success, C<False> on error.

  method remove-supports-type ( Str $content_type, N-GError $error --> Bool )

=item Str $content_type; a string.
=item N-GError $error; a B<Gnome::Gio::Error>.
=end pod

method remove-supports-type ( Str $content_type, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_remove_supports_type(
    self._f('GAppInfo'), $content_type, $error
  ).Bool
}

sub g_app_info_remove_supports_type (
  N-GObject $appinfo, gchar-ptr $content_type, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:reset-type-associations:
=begin pod
=head2 reset-type-associations

Removes all changes to the type associations done by C<.set_as_default_for_type()>, C<.set_as_default_for_extension()>, C<.add_supports_type()> or C<.remove_supports_type()>.

  method reset-type-associations ( Str $content_type )

=item Str $content_type;
=end pod

method reset-type-associations ( Str $content_type ) {
  g_app_info_reset_type_associations( self._f('GAppInfo'), $content_type);
}

sub g_app_info_reset_type_associations (
  gchar-ptr $content_type
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-as-default-for-extension:
=begin pod
=head2 set-as-default-for-extension

Sets the application as the default handler for the given file extension.

Returns: C<True> on success, C<False> on error.

  method set-as-default-for-extension ( Str $extension, N-GError $error --> Bool )

=item Str $extension; (type filename): a string containing the file extension (without the dot).
=item N-GError $error; a B<Gnome::Gio::Error>.
=end pod

method set-as-default-for-extension ( Str $extension, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_set_as_default_for_extension(
    self._f('GAppInfo'), $extension, $error
  ).Bool
}

sub g_app_info_set_as_default_for_extension (
  N-GObject $appinfo, gchar-ptr $extension, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-as-default-for-type:
=begin pod
=head2 set-as-default-for-type

Sets the application as the default handler for a given type.

Returns: C<True> on success, C<False> on error.

  method set-as-default-for-type ( Str $content_type, N-GError $error --> Bool )

=item Str $content_type; the content type.
=item N-GError $error; a B<Gnome::Gio::Error>.
=end pod

method set-as-default-for-type ( Str $content_type, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_set_as_default_for_type(
    self._f('GAppInfo'), $content_type, $error
  ).Bool
}

sub g_app_info_set_as_default_for_type (
  N-GObject $appinfo, gchar-ptr $content_type, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-as-last-used-for-type:
=begin pod
=head2 set-as-last-used-for-type

Sets the application as the last used application for a given type. This will make the application appear as first in the list returned by C<get-recommended-for-type()>, regardless of the default application for that content type.

Returns: C<True> on success, C<False> on error.

  method set-as-last-used-for-type ( Str $content_type, N-GError $error --> Bool )

=item Str $content_type; the content type.
=item N-GError $error; a B<Gnome::Gio::Error>.
=end pod

method set-as-last-used-for-type ( Str $content_type, $error is copy --> Bool ) {
  $error .= get-native-object-no-reffing unless $error ~~ N-GError;

  g_app_info_set_as_last_used_for_type(
    self._f('GAppInfo'), $content_type, $error
  ).Bool
}

sub g_app_info_set_as_last_used_for_type (
  N-GObject $appinfo, gchar-ptr $content_type, N-GError $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:should-show:
=begin pod
=head2 should-show

Checks if the application info should be shown in menus that list available applications.

Returns: C<True> if the I<appinfo> should be shown, C<False> otherwise.

  method should-show ( --> Bool )

=end pod

method should-show ( --> Bool ) {

  g_app_info_should_show(
    self._f('GAppInfo'),
  ).Bool
}

sub g_app_info_should_show (
  N-GObject $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:supports-files:
=begin pod
=head2 supports-files

Checks if the application accepts files as arguments.

Returns: C<True> if the I<appinfo> supports files.

  method supports-files ( --> Bool )

=end pod

method supports-files ( --> Bool ) {

  g_app_info_supports_files(
    self._f('GAppInfo'),
  ).Bool
}

sub g_app_info_supports_files (
  N-GObject $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:supports-uris:
=begin pod
=head2 supports-uris

Checks if the application supports reading files and directories from URIs.

Returns: C<True> if the I<appinfo> supports URIs.

  method supports-uris ( --> Bool )

=end pod

method supports-uris ( --> Bool ) {

  g_app_info_supports_uris(
    self._f('GAppInfo'),
  ).Bool
}

sub g_app_info_supports_uris (
  N-GObject $appinfo --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_app_info_create_from_commandline:
#`{{
=begin pod
=head2 create-from-commandline

  method create-from-commandline ( Str $commandline, Str $application_name, UInt $flags --> N-GObject )

=item Str $commandline;
=item Str $application_name;
=item UInt $flags; a mask with bits from GAppInfoCreateFlags.
=end pod

method _create-from-commandline (
  Str $commandline, Str $application_name, GFlag $flags, $error is copy
  --> N-GObject
) {
  my CArray[N-GError] $error .= new;
  g_app_info_create_from_commandline(
    self._f('GAppInfo'), $commandline, $application_name, $flags, $error
  )
}
}}

sub _g_app_info_create_from_commandline (
  gchar-ptr $commandline, gchar-ptr $application_name, GFlag $flags,
  CArray[N-GError] $error --> N-GObject
) is native(&gio-lib)
is symbol('g_app_info_create_from_commandline')
  { * }






=finish

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
    Gnome::GObject::Object :_widget($appinfo),
    *%user-options
  );

=item $appinfo;
=item $_handle_id; the registered event handler id

=comment -----------------------------------------------------------------------
=comment #TS:0:launch-failed:
=head3 launch-failed

  method handler (
    Str $str,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($appinfo),
    *%user-options
  );

=item $appinfo;
=item $str;
=item $_handle_id; the registered event handler id

=comment -----------------------------------------------------------------------
=comment #TS:0:launched:
=head3 launched

  method handler (
    N-GObject g_type_app_info,
    N-GObject g_type_variant,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($appinfo),
    *%user-options
  );

=item $appinfo;
=item $unknown type g_type_app_info;
=item $unknown type g_type_variant;
=item $_handle_id; the registered event handler id

=end pod
