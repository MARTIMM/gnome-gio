#TL:1:Gnome::Gio::SimpleAction:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::SimpleAction

A simple B<Gnome::Gio::Action> implementation


=head1 Description

A B<Gnome::Gio::SimpleAction> is the obvious simple implementation of the B<Gnome::Gio::Action> interface. This is the easiest way to create an action for purposes of adding it to a B<Gnome::Gio::SimpleActionGroup>.

See also B<Gnome::Gio::Action>.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::SimpleAction;
  also is Gnome::GObject::Object;
  also does Gnome::Gio::Action;


=head2 Uml Diagram

![](plantuml/SimpleAction.svg)


=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

use Gnome::GObject::Object;

use Gnome::Gio::Action;


#-------------------------------------------------------------------------------
unit class Gnome::Gio::SimpleAction:auth<github:MARTIMM>;
also is Gnome::GObject::Object;
also does Gnome::Gio::Action;

#-------------------------------------------------------------------------------
my Bool $signals-added = False;
#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :name, :parameter-type

Create a new stateless SimpleAction object.

  multi method new ( Str :$name!, N-GObject() :$parameter-type? )

=item $name; the name of the action
=item $parameter_type; the type of parameter that will be passed to handlers for the I<activate> signal. The $parameter_type is a native B<Gnome::Glib::Variant> object.


=head3 :name, :state, :parameter-type

Create a new stateful SimpleAction object. All future state values must have the same type as the initial I<$state> variant object.

  multi method new (
    Str :$name!, N-GObject() :$state!, N-GObject() :$parameter_type?
  )

=item $name; the name of the action
=item $parameter_type; the type of the parameter that will be passed to handlers for the  I<activate> signal. The $parameter_type is a native B<Gnome::Glib::VariantType> object.
=item $state; the initial state value of the action. The state is a native B<Gnome::Glib::Variant> object.


=head3 :native-object

Create a SimpleAction object using a native object from elsewhere. See also B<Gnome::GObject::Object>.

  multi method new ( N-GObject() :$native-object! )

=end pod

#TM:1:new(:name):
#TM:4:new(:native-object):
# TM:0:new(:build-id):
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
  if self.^name eq 'Gnome::Gio::SimpleAction' {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<name> {
        my N-GObject() $parameter-type = %options<parameter-type> // N-GObject;

        if %options<state>.defined {
          my N-GObject() $state = %options<state>;
          $no = _g_simple_action_new_stateful(
            %options<name>, $parameter-type, $state
          );
        }

        else {
          $no = _g_simple_action_new( %options<name>, $parameter-type);
        }

        self._set-native-object($no);
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
        $no = _g_simple_action_new();
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GSimpleAction');
  }
}

#-------------------------------------------------------------------------------
#TM:1:set-enabled:
=begin pod
=head2 set-enabled

Sets the action as enabled or not.

An action must be enabled in order to be activated or in order to have its state changed from outside callers.

This should only be called by the implementor of the action. Users of the action should not attempt to modify its enabled flag.

  method set-enabled ( Bool $enabled )

=item $enabled; whether the action is enabled
=end pod

method set-enabled ( Bool $enabled ) {
  g_simple_action_set_enabled( self._f('GSimpleAction'), $enabled);
}

sub g_simple_action_set_enabled ( N-GObject $simple, gboolean $enabled  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-state:
=begin pod
=head2 set-state

Sets the state of the action.

This directly updates the 'state' property to the given value.

This should only be called by the implementor of the action. Users of the action should not attempt to directly modify the 'state' property. Instead, they should call C<Gnome::Gio::Action.change-state()> to request the change.

=comment If the I<$value> B<Gnome::Glib::Variant> is floating, it is consumed.

  method set-state ( N-GObject() $value )

=item $value; the new value for the state. The state is a native B<Gnome::Glib::Variant> object.

=end pod

method set-state ( N-GObject() $value ) {
  g_simple_action_set_state( self._f('GSimpleAction'), $value);
}

sub g_simple_action_set_state ( N-GObject $simple, N-GObject $value  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-state-hint:
=begin pod
=head2 set-state-hint

Sets the state hint for the action.

See C<Gnome::Gio::Action.get_state_hint()> for more information about action state hints.

  method set-state-hint ( N-GObject() $state_hint )

=item $state_hint; a native B<Gnome::Gio::Variant> representing the state hint, may be an undefined value.

=end pod

method set-state-hint ( N-GObject() $state_hint ) {
  g_simple_action_set_state_hint( self._f('GSimpleAction'), $state_hint);
}

sub g_simple_action_set_state_hint ( N-GObject $simple, N-GObject $state_hint  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_simple_action_new:
#`{{
=begin pod
=head2 _g_simple_action_new

Creates a new action.  The created action is stateless. See C<g_simple_action_new_stateful()> to create an action that has state.

Returns: a new B<GSimpleAction>

  method _g_simple_action_new (  Str  $name, N-GObject $parameter_type --> N-GObject )

=item  Str  $name; the name of the action
=item N-GObject $parameter_type; (nullable): the type of parameter that will be passed to handlers for the  I<activate> signal, or C<undefined> for no parameter

=end pod
}}

sub _g_simple_action_new ( gchar-ptr $name, N-GObject $parameter_type --> N-GObject )
  is native(&gio-lib)
  is symbol('g_simple_action_new')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_simple_action_new_stateful:
#`{{
=begin pod
=head2 _g_simple_action_new_stateful

Creates a new stateful action.  All future state values must have the same B<N-GObject> as the initial I<state>.  If the I<state> B<N-GObject> is floating, it is consumed.

Returns: a new B<GSimpleAction>

  method _g_simple_action_new_stateful (  Str  $name, N-GObject $parameter_type, N-GObject $state --> N-GObject )

=item  Str  $name; the name of the action
=item N-GObject $parameter_type; (nullable): the type of the parameter that will be passed to handlers for the  I<activate> signal, or C<undefined> for no parameter
=item N-GObject $state; the initial state of the action

=end pod
}}

sub _g_simple_action_new_stateful (
  gchar-ptr $name, N-GObject $parameter_type, N-GObject $state
  --> N-GObject
) is native(&gio-lib)
  is symbol('g_simple_action_new_stateful')
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head1 Signals


=comment -----------------------------------------------------------------------
=comment #TS:1:activate:
=head2 activate

Indicates that the action was just activated.

I<$parameter> will always be of the expected type, i.e. the parameter type specified when the action was created. If an incorrect type is given when activating the action, this signal is not emitted.

If no handler is connected to this signal then the default behaviour for boolean-stated actions with an undefined parameter type is to toggle them via the I<change-state> signal.

For stateful actions where the state type is equal to the parameter type, the default is to forward them directly to I<change-state>. This should allow almost all users of B<Gnome::Gio::SimpleAction> to connect only one handler or the other.

  method handler (
    N-GObject $parameter,
    Gnome::Gio::SimpleAction :_widget($simple),
    Int :$_handler-id,
    N-GObject :$_native-object,
    *%user-options
  )

=item $parameter; a native B<Gnome::Gio::Variant>, the parameter to the activation, or C<undefined> if it has no parameter
=item $simple; The instance which registered the signal
=item $_handler-id; The handler id which is returned from the registration
=item $_native-object; The native object provided by the caller wrapped in the Raku object.
=item %user-options; A list of named arguments provided at the C<register-signal()> method

=comment -----------------------------------------------------------------------
=comment #TS:1:change-state:
=head2 change-state

Indicates that the action just received a request to change its state.

I<value> will always be of the correct state type, i.e. the type of the initial state passed to a C<new(:state, …)>. If an incorrect type is given when requesting to change the state, this signal is not emitted.

If no handler is connected to this signal then the default behaviour is to call C<set-state()> to set the state to the requested value. If you connect a signal handler then no default action is taken. If the state should change then you must call C<set-state()> from the handler.

=begin comment
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
set_state (action, value);
}
]|

The handler need not set the state to the requested value.
It could set it to any value at all, or take some other action.
=end comment

  method handler (
    N-GObject $parameter,
    Gnome::Gio::SimpleAction :_widget($simple),
    Int :$_handler-id,
    N-GObject :$_native-object,
    *%user-options
  )

=item $value; a native B<Gnome::Gio::Variant>, the requested value for the state, or C<undefined> if it has no parameter
=item $simple; The instance which registered the signal
=item $_handler-id; The handler id which is returned from the registration
=item $_native-object; The native object provided by the caller wrapped in the Raku object.
=item %user-options; A list of named arguments provided at the C<register-signal()> method

=end pod

#-------------------------------------------------------------------------------
=begin pod
=head1 Properties

=comment -----------------------------------------------------------------------
=comment #TP:1:enabled:
=head2 enabled

If the action can be activated

=item B<Gnome::GObject::Value> type of this property is G_TYPE_BOOLEAN
=item Parameter is readable and writable.
=item Default value is TRUE.


=comment -----------------------------------------------------------------------
=comment #TP:1:name:
=head2 name

The name used to invoke the action

=item B<Gnome::GObject::Value> type of this property is G_TYPE_STRING
=item Parameter is readable and writable.
=item Parameter is set on construction of object.
=item Default value is undefined.


=comment -----------------------------------------------------------------------
=comment #TP:0:parameter-type:
=head2 parameter-type

The type of GVariant passed to C<activate()>

=item B<Gnome::GObject::Value> type of this property is G_TYPE_BOXED
=item The type of this G_TYPE_BOXED object is G_TYPE_VARIANT_TYPE
=item Parameter is readable and writable.
=item Parameter is set on construction of object.


=comment -----------------------------------------------------------------------
=comment #TP:0:state:
=head2 state

The state the action is in

=item B<Gnome::GObject::Value> type of this property is G_TYPE_VARIANT
=item Parameter is readable and writable.
=item Parameter is set on construction of object.
=item Default value is undefined.


=comment -----------------------------------------------------------------------
=comment #TP:0:state-type:
=head2 state-type

The type of the state kept by the action

=item B<Gnome::GObject::Value> type of this property is G_TYPE_BOXED
=item The type of this G_TYPE_BOXED object is G_TYPE_VARIANT_TYPE
=item Parameter is readable.

=end pod










=finish
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


=comment -----------------------------------------------------------------------
=comment #TS:1:activate:
=head3 activate

Indicates that the action was just activated.

I<parameter> will always be of the expected type, i.e. the parameter type specified when the action was created. If an incorrect type is given when activating the action, this signal is not emitted.

If no handler is connected to this signal then the default behaviour for boolean-stated actions with a C<undefined> parameter type is to toggle them via the  I<change-state> signal. For stateful actions where the state type is equal to the parameter type, the default is to forward them directly to  I<change-state>.  This should allow almost all users of B<N-GSimpleAction> to connect only one handler or the other.

  method handler (
    N-GObject $parameter,
    Int :$_handle_id,
    Gnome::Gio::SimpleAction :_widget($simple),
    *%user-options
  );

=item $simple; the B<Gnome::Gio::SimpleAction>
=item $parameter; the parameter to the activation, or C<undefined> if it has no parameter

=comment -----------------------------------------------------------------------
=comment #TS:1:change-state:
=head3 change-state

Indicates that the action just received a request to change its state.

I<value> will always be of the correct state type, i.e. the type of the initial state passed to C<g_simple_action_new_stateful()>. If an incorrect type is given when requesting to change the state, this signal is not emitted.

If no handler is connected to this signal then the default behaviour is to call C<set-state()> to set the state to the requested value. If you connect a signal handler then no default action is taken. If the state should change then you must call C<set-state()> from the handler.

=begin comment
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
=end comment


  method handler (
    N-GObject $value,
    Int :$_handle_id,
    Gnome::Gio::SimpleAction :_widget($simple),
    *%user-options
  );

=item $simple; the B<GSimpleAction>

=item $value; the requested value for the state


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
=comment #TP:0:enabled:
=head3 Enabled


If I<action> is currently enabled.

If the action is disabled then calls to C<g_action_activate()> and
C<g_action_change_state()> have no effect.

=comment -----------------------------------------------------------------------
=comment #TP:0:name:
=head3 Action Name


The name of the action. This is mostly meaningful for identifying
the action once it has been added to a B<GSimpleActionGroup>.


The B<Gnome::GObject::Value> type of property I<name> is C<G_TYPE_STRING>.

=comment -----------------------------------------------------------------------
=comment #TP:0:parameter-type:
=head3 Parameter Type


The type of the parameter that must be given when activating the
action.


The B<Gnome::GObject::Value> type of property I<parameter-type> is C<G_TYPE_BOXED>.


The B<Gnome::GObject::Value> type of property I<enabled> is C<G_TYPE_BOOLEAN>.

=comment -----------------------------------------------------------------------
=comment #TP:0:state:
=head3 State


The state of the action, or C<undefined> if the action is stateless.


The B<Gnome::GObject::Value> type of property I<state> is C<G_TYPE_VARIANT>.

=comment -----------------------------------------------------------------------
=comment #TP:0:state-type:
=head3 State Type


The B<N-GObject> of the state that the action has, or C<undefined> if the
action is stateless.


The B<Gnome::GObject::Value> type of property I<state-type> is C<G_TYPE_BOXED>.
=end pod
