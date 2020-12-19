#TL:0:Gnome::Gio::SimpleAction:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::SimpleAction

A simple B<Gnome::Gio::Action> implementation

=head1 Description

A B<Gnome::Gio::SimpleAction> is the obvious simple implementation of the B<Gnome::Gio::Action> interface. This is the easiest way to create an action for purposes of adding it to a B<Gnome::Gio::SimpleActionGroup>.

See also B<Gnome::Gio::Action>.


=head2 Implemented Interfaces

Gnome::Gio::SimpleAction implements
=item [Gnome::Gio::Action](Action.html)
=comment item [Gnome::Gio::PropertyAction](PropertyAction.html)


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::SimpleAction;
  also is Gnome::GObject::Object;
  also does Gnome::Gio::Action;
=comment  also does Gnome::Gio::PropertyAction;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::GObject::Object;
use Gnome::Gio::Action;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::SimpleAction:auth<github:MARTIMM>;
also is Gnome::GObject::Object;
also does Gnome::Gio::Action;
#also does Gnome::Gio::PropertyAction;

#-------------------------------------------------------------------------------
my Bool $signals-added = False;
#-------------------------------------------------------------------------------

=begin pod
=head1 Methods
=head2 new

Create a new stateless or stateful SimpleAction object.

  multi method new ( Str :name!, Bool :stateful = False )

Create a SimpleAction object using a native object from elsewhere. See also B<Gnome::GObject::Object>.

  multi method new ( N-GObject :$native-object! )

Create a SimpleAction object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

#TM:1:new(:name):
#TM:0:new(:native-object):
#TM:0:new(:build-id):

submethod BUILD ( *%options ) {

  # add signal info in the form of w*<signal-name>.
  unless $signals-added {
    $signals-added = self.add-signal-types( $?CLASS.^name,
      :w1<activate change-state>,
    );

    # signals from interfaces
    #_add_..._signal_types($?CLASS.^name);
  }


  # prevent creating wrong native-objects
  return unless self.^name eq 'Gnome::Gio::SimpleAction';

  # process all named arguments
  if ? %options<name> {
    my $no;
    my Bool $stfl = %options<stateful> // False;
    if $stfl {
      $no = g_simple_action_new_stateful( %options<name>, N-GObject);
    }

    else {
      $no = g_simple_action_new( %options<name>, N-GObject);
    }

    self.set-native-object($no);
  }

  elsif ? %options<widget> || ? %options<native-object> ||
     ? %options<build-id> {
    # provided in Gnome::GObject::Object
  }

  elsif %options.keys.elems {
    die X::Gnome.new(
      :message(
        'Unsupported, undefined, incomplete or wrongly typed options for ' ~
        self.^name ~ ': ' ~ %options.keys.join(', ')
      )
    );
  }

  # create default object
#  else {
#    self.set-native-object(g_simple_action_new(N-GObject));
#  }

  # only after creating the native-object, the gtype is known
  self.set-class-info('GSimpleAction');
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("g_simple_action_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;
  $s = self._action_interface($native-sub) unless ?$s;
#  $s = self._orientable_interface($native-sub) unless ?$s;

  self.set-class-name-of-sub('GSimpleAction');
  $s = callsame unless ?$s;

  $s;
}


#-------------------------------------------------------------------------------
#TM:2:g_simple_action_new:new(:name,:stateful)
=begin pod
=head2 g_simple_action_new

Creates a new action.

The created action is stateless. See C<g_simple_action_new_stateful()> to create an action that has state.

Returns: a new native B<GSimpleAction>

  method g_simple_action_new (
    Str $name, N-GObject $parameter_type
    --> N-GObject
  )

=item Str $name; the name of the action
=item N-GObject $parameter_type; (nullable): the type of parameter that will be passed to handlers for the  I<activate> signal, or C<Any> for no parameter

=end pod

#TODO $parameter_type is a GVariantType
sub g_simple_action_new ( Str $name, N-GObject $parameter_type --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_simple_action_new_stateful:new(:name,:stateful)
=begin pod
=head2 [g_simple_action_] new_stateful

Creates a new stateful action.

All future state values must have the same B<GVariantType> as the initial
I<state>.

If the I<state> B<GVariant> is floating, it is consumed.

Returns: a new B<GSimpleAction>

  method g_simple_action_new_stateful (
    Str $name, N-GObject $parameter_type,
    N-GObject $state
    --> N-GObject
  )

=item Str $name; the name of the action
=item N-GObject $parameter_type; (nullable): the type of the parameter that will be passed to handlers for the  I<activate> signal, or C<Any> for no parameter
=item N-GObject $state; the initial state of the action

=end pod

#TODO $parameter_type is a GVariant
sub g_simple_action_new_stateful ( Str $name, N-GObject $parameter_type, N-GObject $state --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_simple_action_set_enabled:
=begin pod
=head2 [g_simple_action_] set_enabled

Sets the action as enabled or not. An action must be enabled in order to be activated or in order to have its state changed from outside callers.

This should only be called by the implementor of the action.  Users of the action should not attempt to modify its enabled flag.

  method g_simple_action_set_enabled ( Int $enabled )

=item Int $enabled; whether the action is enabled

=end pod

sub g_simple_action_set_enabled ( N-GObject $simple, int32 $enabled  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_simple_action_set_state:
=begin pod
=head2 [g_simple_action_] set_state

Sets the state of the action.

This directly updates the 'state' property to the given value.

This should only be called by the implementor of the action.  Users
of the action should not attempt to directly modify the 'state'
property.  Instead, they should call C<g_action_change_state()> to
request the change.

If the I<value> GVariant is floating, it is consumed.

  method g_simple_action_set_state ( N-GObject $value )

=item N-GObject $value; the new B<GVariant> for the state

=end pod

sub g_simple_action_set_state ( N-GObject $simple, N-GObject $value  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_simple_action_set_state_hint:
=begin pod
=head2 [g_simple_action_] set_state_hint

Sets the state hint for the action.

See C<g_action_get_state_hint()> for more information about
action state hints.

  method g_simple_action_set_state_hint ( N-GObject $state_hint )

=item N-GObject $state_hint; (nullable): a B<GVariant> representing the state hint

=end pod

sub g_simple_action_set_state_hint ( N-GObject $simple, N-GObject $state_hint  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head1 Signals

There are two ways to connect to a signal. The first option you have is to use C<register-signal()> from B<Gnome::GObject::Object>. The second option is to use C<g_signal_connect_object()> directly from B<Gnome::GObject::Signal>.

=head2 First method

The positional arguments of the signal handler are all obligatory as well as their types. The named attributes C<:$widget> and user data are optional.

  # handler method
  method mouse-event ( N-GdkEvent $event, :$widget ) { ... }

  # connect a signal on window object
  my Gnome::Gtk3::Window $w .= new( ... );
  $w.register-signal( self, 'mouse-event', 'button-press-event');

=head2 Second method

  my Gnome::Gtk3::Window $w .= new( ... );
  my Callable $handler = sub (
    N-GObject $native, N-GdkEvent $event, OpaquePointer $data
  ) {
    ...
  }

  $w.connect-object( 'button-press-event', $handler);

Also here, the types of positional arguments in the signal handler are important. This is because both methods C<register-signal()> and C<g_signal_connect_object()> are using the signatures of the handler routines to setup the native call interface.

=head2 Supported signals


=comment #TS:4:activate:ex-application.pl6
=head3 activate

Indicates that the action was just activated.

I<$parameter> will always be of the expected type, i.e. the parameter type specified when the action was created. If an incorrect type is given when activating the action, this signal is not emitted.

Since GLib 2.40, if no handler is connected to this signal then the default behaviour for boolean-stated actions with an C<Any> parameter type is to toggle them via the  I<change-state> signal. For stateful actions where the state type is equal to the parameter type, the default is to forward them directly to I<change-state>.  This should allow almost all users of B<Gnome::Gio::SimpleAction> to connect only one handler or the other.

  method handler (
    N-GVariant $parameter,
    Int :$_handler_id,
    Gnome::GObject::Object :_widget($simple),
    *%user-options
  );

=item $simple; the B<Gnome::Gio::SimpleAction>
=item $parameter; the parameter to the activation, or C<Any> if it has no parameter

=comment #TS:0:change-state:
=head3 change-state

Indicates that the action just received a request to change its
state.

I<value> will always be of the correct state type, i.e. the type of the
initial state passed to C<g_simple_action_new_stateful()>. If an incorrect
type is given when requesting to change the state, this signal is not
emitted.

If no handler is connected to this signal then the default
behaviour is to call C<g_simple_action_set_state()> to set the state
to the requested value. If you connect a signal handler then no
default action is taken. If the state should change then you must
call C<g_simple_action_set_state()> from the handler.

An example of a 'change-state' handler:
|[<!-- language="C" -->
static void
change_volume_state (GSimpleAction *action,
GVariant      *value,
gpointer       user_data)
{
gint requested;

requested = g_variant_get_int32 (value);

// Volume only goes from 0 to 10
if (0 <= requested && requested <= 10)
g_simple_action_set_state (action, value);
}
]|

The handler need not set the state to the requested value.
It could set it to any value at all, or take some other action.

  method handler (
    Unknown type G_TYPE_VARIANT $value,
    Int :$_handler_id,
    Gnome::GObject::Object :_widget($simple),
    *%user-options
  );

=item $simple; the B<Gnome::Gio::SimpleAction>

=item $value; (nullable): the requested value for the state


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

=comment #TP:0:name:
=head3 Action Name


The name of the action. This is mostly meaningful for identifying
the action once it has been added to a B<GSimpleActionGroup>.

The B<Gnome::GObject::Value> type of property I<name> is C<G_TYPE_STRING>.

=comment #TP:0:parameter-type:
=head3 Parameter Type


The type of the parameter that must be given when activating the
action.

The B<Gnome::GObject::Value> type of property I<parameter-type> is C<G_TYPE_BOXED>.

=comment #TP:0:enabled:
=head3 Enabled


If I<action> is currently enabled.
If the action is disabled then calls to C<g_action_activate()> and
C<g_action_change_state()> have no effect.

The B<Gnome::GObject::Value> type of property I<enabled> is C<G_TYPE_BOOLEAN>.

=comment #TP:0:state-type:
=head3 State Type


The B<GVariantType> of the state that the action has, or C<Any> if the
action is stateless.

The B<Gnome::GObject::Value> type of property I<state-type> is C<G_TYPE_BOXED>.

=comment #TP:0:state:
=head3 State


The state of the action, or C<Any> if the action is stateless.

The B<Gnome::GObject::Value> type of property I<state> is C<G_TYPE_VARIANT>.
=end pod
