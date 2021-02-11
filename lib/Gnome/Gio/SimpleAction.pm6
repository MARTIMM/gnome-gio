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

use Gnome::Glib::N-GVariant;
use Gnome::Glib::N-GVariantType;

use Gnome::Gio::Action;

#-------------------------------------------------------------------------------
unit class Gnome::Gio::SimpleAction:auth<github:MARTIMM>:ver<0.1.0>;
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

  multi method new ( Str :$name!, N-GVariantType :$parameter-type )

=item  Str  $name; the name of the action
=item N-GVariantType $parameter_type; the type of parameter that will be passed to handlers for the  I<activate> signal, or C<undefined> for no parameter


=head3 :name, :parameter-type, :state

Create a new stateful SimpleAction object. All future state values must have the same B<N-GVariantType> as the initial I<$state> variant object.

  multi method new (
    Str :$name!, N-GVariantType :$parameter_type, N-GVariant :$state!
  )

=item  Str  $name; the name of the action
=item N-GVariantType $parameter_type; the type of the parameter that will be passed to handlers for the  I<activate> signal, or C<undefined> for no parameter
=item N-GVariant $state; the initial state value of the action


=head3 :native-object

Create a SimpleAction object using a native object from elsewhere. See also B<Gnome::GObject::Object>.

  multi method new ( N-GObject :$native-object! )

=begin comment
Create a SimpleAction object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )
=end comment

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
        my $parameter-type = N-GVariantType;
        if %options<parameter-type>.defined {
          $parameter-type = %options<parameter-type>;
          $parameter-type .= get-native-object-no-reffing
            unless $parameter-type ~~ N-GVariantType;
        }

        if %options<state>.defined {
          my $state = %options<state>;
          $state .= get-native-object-no-reffing
            unless $state ~~ N-GVariant;

          $no = _g_simple_action_new_stateful(
            %options<name>, $parameter-type, $state
          );
        }

        else {
          $no = _g_simple_action_new( %options<name>, $parameter-type);
        }

        self.set-native-object($no);
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

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GSimpleAction');
  }
}

#-------------------------------------------------------------------------------
#TM:1:set-enabled:
=begin pod
=head2 set-enabled

Sets the action as enabled or not.  An action must be enabled in order to be activated or in order to have its state changed from outside callers.  This should only be called by the implementor of the action.  Users of the action should not attempt to modify its enabled flag.

  method set-enabled ( Bool $enabled )

=item Int $enabled; whether the action is enabled

=end pod

method set-enabled ( Bool $enabled ) {

  g_simple_action_set_enabled(
    self._f('GSimpleAction'), $enabled.Int
  );
}

sub g_simple_action_set_enabled ( N-GObject $simple, gboolean $enabled  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-state:
=begin pod
=head2 set-state

Sets the state of the action.  This directly updates the 'state' property to the given value.  This should only be called by the implementor of the action.  Users of the action should not attempt to directly modify the 'state' property.  Instead, they should call C<change-state()> to request the change.

  method set-state ( N-GVariant $value )

=item N-GVariant $value; the new B<N-GVariant> for the state

=end pod

method set-state ( $value ) {
  my $no = $value;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_simple_action_set_state(
    self._f('GSimpleAction'), $no
  );
}

sub g_simple_action_set_state ( N-GObject $simple, N-GVariant $value  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-state-hint:
=begin pod
=head2 set-state-hint

Sets the state hint for the action.  See C<get_state_hint()> in B<Gnome::Gio::Action> for more information about action state hints.

  method set-state-hint ( N-GVariant $state_hint )

=item N-GVariant $state_hint; a B<N-GVariant> representing the state hint, may be an undefined value.

=end pod

method set-state-hint ( $state_hint ) {
  my $no = $state_hint;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_simple_action_set_state_hint(
    self._f('GSimpleAction'), $no
  );
}

sub g_simple_action_set_state_hint ( N-GObject $simple, N-GVariant $state_hint  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_simple_action_new:
#`{{
=begin pod
=head2 _g_simple_action_new

Creates a new action.  The created action is stateless. See C<g_simple_action_new_stateful()> to create an action that has state.

Returns: a new B<GSimpleAction>

  method _g_simple_action_new (  Str  $name, N-GVariantType $parameter_type --> N-GObject )

=item  Str  $name; the name of the action
=item N-GVariantType $parameter_type; (nullable): the type of parameter that will be passed to handlers for the  I<activate> signal, or C<undefined> for no parameter

=end pod
}}

sub _g_simple_action_new ( gchar-ptr $name, N-GVariantType $parameter_type --> N-GObject )
  is native(&gio-lib)
  is symbol('g_simple_action_new')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_simple_action_new_stateful:
#`{{
=begin pod
=head2 _g_simple_action_new_stateful

Creates a new stateful action.  All future state values must have the same B<N-GVariantType> as the initial I<state>.  If the I<state> B<N-GVariant> is floating, it is consumed.

Returns: a new B<GSimpleAction>

  method _g_simple_action_new_stateful (  Str  $name, N-GVariantType $parameter_type, N-GVariant $state --> N-GObject )

=item  Str  $name; the name of the action
=item N-GVariantType $parameter_type; (nullable): the type of the parameter that will be passed to handlers for the  I<activate> signal, or C<undefined> for no parameter
=item N-GVariant $state; the initial state of the action

=end pod
}}

sub _g_simple_action_new_stateful (
  gchar-ptr $name, N-GVariantType $parameter_type, N-GVariant $state
  --> N-GObject
) is native(&gio-lib)
  is symbol('g_simple_action_new_stateful')
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


=comment -----------------------------------------------------------------------
=comment #TS:1:activate:
=head3 activate

Indicates that the action was just activated.

I<parameter> will always be of the expected type, i.e. the parameter type specified when the action was created. If an incorrect type is given when activating the action, this signal is not emitted.

If no handler is connected to this signal then the default behaviour for boolean-stated actions with a C<undefined> parameter type is to toggle them via the  I<change-state> signal. For stateful actions where the state type is equal to the parameter type, the default is to forward them directly to  I<change-state>.  This should allow almost all users of B<N-GSimpleAction> to connect only one handler or the other.

  method handler (
    N-GVariant $parameter,
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
    N-GVariant $value,
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


The B<N-GVariantType> of the state that the action has, or C<undefined> if the
action is stateless.


The B<Gnome::GObject::Value> type of property I<state-type> is C<G_TYPE_BOXED>.
=end pod
