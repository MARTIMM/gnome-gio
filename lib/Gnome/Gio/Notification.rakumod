#TL:1:Gnome::Gio::Notification:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Notification

User Notifications (pop up messages)

=comment ![](images/X.png)

=head1 Description

B<Gnome::Gio::Notification> is a mechanism for creating a notification to be shown to the user -- typically as a pop-up notification presented by the desktop environment shell.

The key difference between B<Gnome::Gio::Notification> and other similar APIs is that, if supported by the desktop environment, notifications sent with B<Gnome::Gio::Notification> will persist after the application has exited, and even across system reboots.

Since the user may click on a notification while the application is not running, applications using B<Gnome::Gio::Notification> should be able to be started as a D-Bus service, using B<Gnome::Gio::Application>.

User interaction with a notification (either the default action, or buttons) must be associated with actions on the application (ie: "app." actions).  It is not possible to route user interaction through the notification itself, because the object will not exist if the application is autostarted as a result of a notification being clicked.

A notification can be sent with C<g-application-send-notification()>.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::Notification;
  also is Gnome::GObject::Object;


=comment head2 Uml Diagram

=comment ![](plantuml/.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::Notification:api<1>;

  unit class MyGuiClass;
  also is Gnome::Gio::Notification;

  submethod new ( |c ) {
    # let the Gnome::Gio::Notification class process the options
    self.bless( :N-GObject, |c);
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

use Gnome::Gio::Enums:api<1>;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::Notification:auth<github:MARTIMM>:api<1>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :title

Creates a new B<Gnome::Gio::Notification> with I<$title> as its title.

After populating the notification with more details, it can be sent to the desktop shell with C<Gnome::Gio::Application.send-notification()>. Changing any properties after this call will not have any effect until resending the notification.

  multi method new ( Str :$title! )


=head3 :native-object

Create a Notification object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )


=begin comment
=head3 :build-id

Create a Notification object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )
=end comment

=end pod

#TM:1:new(:title):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::Notification' #`{{ or %options<N-GObject> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists or %options<widget>:exists { }
    elsif %options<build-id>:exists { }

    # process all other options
    else {
      my $no;
      if %options<title>:exists {
        $no = _g_notification_new(%options<title>);
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
        $no = _g_notification_new();
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('N-GObject');

  }
}


#-------------------------------------------------------------------------------
#TM:0:add-button:
=begin pod
=head2 add-button

Adds a button to the notification that activates the action in I<$detailed-action> when clicked. That action must be an application-wide action (starting with "app."). If I<detailed-action> contains a target, the action will be activated with that target as its parameter.

See C<Gnome::Gio::Action.parse-detailed-name()> for a description of the format for I<$detailed-action>.

  method add-button ( Str $label, Str $detailed_action )

=item Str $label; label of the button
=item Str $detailed_action; a detailed action name

=end pod

method add-button ( Str $label, Str $detailed_action ) {

  g_notification_add_button(
    self._get-native-object-no-reffing, $label, $detailed_action
  );
}

sub g_notification_add_button (
  N-GObject $notification, gchar-ptr $label, gchar-ptr $detailed_action
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:add-button-with-target:
=begin pod
=head2 add-button-with-target

Adds a button to the notification that activates I<action> when clicked. I<action> must be an application-wide action (it must start with "app.").

If I<target-format> is given, it is used to collect remaining positional parameters into a B<Gnome::Gio::Variant> instance, similar to C<g-variant-new()>. I<action> will be activated with that B<Gnome::Gio::Variant> as its parameter.

  method add-button-with-target ( Str $label, Str $action, Str $target_format )

=item Str $label; label of the button
=item Str $action; an action name
=item Str $target_format; a B<Gnome::Gio::Variant> format string, or C<undefined> @...: positional parameters, as determined by I<target-format>

=end pod

method add-button-with-target ( Str $label, Str $action, Str $target_format ) {

  g_notification_add_button_with_target(
    self._get-native-object-no-reffing, $label, $action, $target_format
  );
}

sub g_notification_add_button_with_target (
  N-GObject $notification, gchar-ptr $label, gchar-ptr $action, gchar-ptr $target_format, Any $any = Any
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:add-button-with-target-value:
=begin pod
=head2 add-button-with-target-value

Adds a button to the notification that activates I<action> when clicked. I<action> must be an application-wide action (it must start with "app.").

If I<target> is non-C<undefined>, I<action> will be activated with I<target> as its parameter.

  method add-button-with-target-value ( Str $label, Str $action, N-GObject $target )

=item Str $label; label of the button
=item Str $action; an action name
=item N-GObject $target; a B<Gnome::Gio::Variant> to use as I<action>'s parameter, or C<undefined>

=end pod

method add-button-with-target-value ( Str $label, Str $action, $target is copy ) {
  $target .= _get-native-object-no-reffing unless $target ~~ N-GObject;

  g_notification_add_button_with_target_value(
    self._get-native-object-no-reffing, $label, $action, $target
  );
}

sub g_notification_add_button_with_target_value (
  N-GObject $notification, gchar-ptr $label, gchar-ptr $action, N-GObject $target
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:set-body:ex-application.pl6
=begin pod
=head2 set-body

Sets the body of the notification to I<body>.

  method set-body ( Str $body )

=item Str $body; the new body for the notification, or C<undefined>

=end pod

method set-body ( Str $body ) {

  g_notification_set_body(
    self._get-native-object-no-reffing, $body
  );
}

sub g_notification_set_body (
  N-GObject $notification, gchar-ptr $body
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-default-action:
=begin pod
=head2 set-default-action

Sets the default action of the notification to I<detailed-action>. This action is activated when the notification is clicked on.

The action in I<detailed-action> must be an application-wide action (it must start with "app."). If I<detailed-action> contains a target, the given action will be activated with that target as its parameter. See C<g-action-parse-detailed-name()> for a description of the format for I<detailed-action>.

When no default action is set, the application that the notification was sent on is activated.

  method set-default-action ( Str $detailed_action )

=item Str $detailed_action; a detailed action name

=end pod

method set-default-action ( Str $detailed_action ) {

  g_notification_set_default_action(
    self._get-native-object-no-reffing, $detailed_action
  );
}

sub g_notification_set_default_action (
  N-GObject $notification, gchar-ptr $detailed_action
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:set-default-action-and-target:
=begin pod
=head2 set-default-action-and-target

Sets the default action of the notification to I<action>. This action is activated when the notification is clicked on. It must be an application-wide action (it must start with "app.").

If I<target-format> is given, it is used to collect remaining positional parameters into a B<Gnome::Gio::Variant> instance, similar to C<g-variant-new()>. I<action> will be activated with that B<Gnome::Gio::Variant> as its parameter.

When no default action is set, the application that the notification was sent on is activated.

  method set-default-action-and-target ( Str $action, Str $target_format )

=item Str $action; an action name
=item Str $target_format; a B<Gnome::Gio::Variant> format string, or C<undefined> @...: positional parameters, as determined by I<target-format>

=end pod

method set-default-action-and-target ( Str $action, Str $target_format ) {

  g_notification_set_default_action_and_target(
    self._get-native-object-no-reffing, $action, $target_format
  );
}

sub g_notification_set_default_action_and_target (
  N-GObject $notification, gchar-ptr $action, gchar-ptr $target_format, Any $any = Any
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:set-default-action-and-target-value:
=begin pod
=head2 set-default-action-and-target-value

Sets the default action of the notification to I<action>. This action is activated when the notification is clicked on. It must be an application-wide action (start with "app.").

If I<target> is non-C<undefined>, I<action> will be activated with I<target> as its parameter.

When no default action is set, the application that the notification was sent on is activated.

  method set-default-action-and-target-value ( Str $action, N-GObject $target )

=item Str $action; an action name
=item N-GObject $target; a B<Gnome::Gio::Variant> to use as I<action>'s parameter, or C<undefined>

=end pod

method set-default-action-and-target-value ( Str $action, $target is copy ) {
  $target .= _get-native-object-no-reffing unless $target ~~ N-GObject;

  g_notification_set_default_action_and_target_value(
    self._get-native-object-no-reffing, $action, $target
  );
}

sub g_notification_set_default_action_and_target_value (
  N-GObject $notification, gchar-ptr $action, N-GObject $target
) is native(&gio-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:set-icon:
=begin pod
=head2 set-icon

Sets the icon of the notification to I<icon>.

  method set-icon ( GIcon $icon )

=item GIcon $icon; the icon to be shown in the notification, as a B<Gnome::Gio::Icon>

=end pod

method set-icon ( GIcon $icon ) {

  g_notification_set_icon(
    self._get-native-object-no-reffing, $icon
  );
}

sub g_notification_set_icon (
  N-GObject $notification, GIcon $icon
) is native(&gio-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:4:set-priority:ex-application.raku
=begin pod
=head2 set-priority

Sets the priority of the notification to I<priority>. See B<Gnome::Gio::NotificationPriority> for possible values.

  method set-priority ( GNotificationPriority $priority )

=item GNotificationPriority $priority; a B<Gnome::Gio::NotificationPriority>

=end pod

method set-priority ( GNotificationPriority $priority ) {

  g_notification_set_priority(
    self._get-native-object-no-reffing, $priority
  );
}

sub g_notification_set_priority (
  N-GObject $notification, GEnum $priority
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-title:
=begin pod
=head2 set-title

Sets the title of the notification to I<title>.

  method set-title ( Str $title )

=item Str $title; the new title for the notification

=end pod

method set-title ( Str $title ) {

  g_notification_set_title(
    self._get-native-object-no-reffing, $title
  );
}

sub g_notification_set_title (
  N-GObject $notification, gchar-ptr $title
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_notification_new:
#`{{
=begin pod
=head2 _g_notification_new

Creates a new B<Gnome::Gio::Notification> with I<title> as its title.

After populating the notification with more details, it can be sent to the desktop shell with C<g-application-send-notification()>. Changing any properties after this call will not have any effect until resending the notification.

Returns: a new B<Gnome::Gio::Notification> instance

  method _g_notification_new ( Str $title --> N-GObject )

=item Str $title; the title of the notification

=end pod
}}

sub _g_notification_new ( gchar-ptr $title --> N-GObject )
  is native(&gio-lib)
  is symbol('g_notification_new')
  { * }
