#TL:1:Gnome::Gio::ActionGroup:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::ActionGroup

A group of actions

=comment ![](images/X.png)

=head1 Description


B<Gnome::Gio::ActionGroup> represents a group of actions. Actions can be used to expose functionality in a structured way, either from one part of a program to another, or to the outside world. Action groups are often used together with a B<GMenuModel> that provides additional representation data for displaying the actions to the user, e.g. in a menu.

The main way to interact with the actions in a GActionGroup is to activate them with `activate-action()`. Activating an action may require a B<GVariant> parameter. The required type of the parameter can be inquired with `get-action-parameter-type()`. Actions may be disabled, see `get-action-enabled()`. Activating a disabled action has no effect.

Actions may optionally have a state in the form of a B<GVariant>. The current state of an action can be inquired with `get-action-state(). Activating a stateful action may change its state, but it is also possible to set the state by calling `change-action-state()`.

As typical example, consider a text editing application which has an option to change the current font to 'bold'. A good way to represent this would be a stateful action, with a boolean state. Activating the action would toggle the state.

Each action in the group has a unique name (which is a string). All method calls, except `list-actions()` take the name of an action as an argument.

The B<Gnome::Gio::ActionGroup> API is meant to be the 'public' API to the action group. The calls here are exactly the interaction that 'external forces' (eg: UI, incoming D-Bus messages, etc.) are supposed to have with actions.  'Internal' APIs (ie: ones meant only to be accessed by the action group implementation) are found on subclasses.  This is why you will find - for example - `get-action-enabled()` but not an equivalent C<set()> call.

Signals are emitted on the action group in response to state changes on individual actions.

=comment Implementations of B<Gnome::Gio::ActionGroup> should provide implementations for the virtual functions `list-actions()` and `query-action()`. The other virtual functions should not be implemented - their "wrappers" are actually implemented with  calls to `query-action()`.

=head2 See Also

B<GAction>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::ActionGroup;

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::N-GVariant;
use Gnome::Glib::N-GVariantType;
use Gnome::Glib::Variant;
use Gnome::Glib::VariantType;

#-------------------------------------------------------------------------------
unit role Gnome::Gio::ActionGroup:auth<github:MARTIMM>:ver<0.1.0>;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

# interfaces are not instantiated
#submethod BUILD ( *%options ) { }

#-------------------------------------------------------------------------------
# setup signals from interface
method _add_action_group_signal_types ( Str $class-name ) {

  self.add-signal-types( $class-name,
    :w1<action-added action-removed action-state-changed>,
    :w2<action-enabled-changed>,
  );
}

#-------------------------------------------------------------------------------
#TM:1:action-added:
=begin pod
=head2 action-added

Emits the  I<action-added> signal on I<action-group>.  This function should only be called by B<GActionGroup> implementations.

  method action-added ( Str $action_name )

=item Str $action_name; the name of an action in the group

=end pod

method action-added ( Str $action_name ) {

  g_action_group_action_added(
    self._f('GActionGroup'), $action_name
  );
}

sub g_action_group_action_added ( N-GObject $action_group, gchar-ptr $action_name  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:action-enabled-changed:
=begin pod
=head2 action-enabled-changed

Emits the  I<action-enabled-changed> signal on I<action-group>.  This function should only be called by B<GActionGroup> implementations.

  method action-enabled-changed ( Str $action_name, Int $enabled )

=item Str $action_name; the name of an action in the group
=item Int $enabled; whether or not the action is now enabled

=end pod

method action-enabled-changed ( Str $action_name, Int $enabled ) {

  g_action_group_action_enabled_changed(
    self._f('GActionGroup'), $action_name, $enabled
  );
}

sub g_action_group_action_enabled_changed ( N-GObject $action_group, gchar-ptr $action_name, gboolean $enabled  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:action-removed:
=begin pod
=head2 action-removed

Emits the  I<action-removed> signal on I<action-group>.  This function should only be called by B<GActionGroup> implementations.

  method action-removed ( Str $action_name )

=item Str $action_name; the name of an action in the group

=end pod

method action-removed ( Str $action_name ) {

  g_action_group_action_removed(
    self._f('GActionGroup'), $action_name
  );
}

sub g_action_group_action_removed ( N-GObject $action_group, gchar-ptr $action_name  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:action-state-changed:
=begin pod
=head2 action-state-changed

Emits the  I<action-state-changed> signal on I<action-group>.  This function should only be called by B<GActionGroup> implementations.

  method action-state-changed ( Str $action_name, N-GVariant $state )

=item Str $action_name; the name of an action in the group
=item N-GVariant $state; the new state of the named action

=end pod

method action-state-changed ( Str $action_name, N-GVariant $state ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_action_group_action_state_changed(
    self._f('GActionGroup'), $action_name, $state
  );
}

sub g_action_group_action_state_changed ( N-GObject $action_group, gchar-ptr $action_name, N-GVariant $state  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:activate-action:
=begin pod
=head2 activate-action

Activate the named action within I<action-group>.  If the action is expecting a parameter, then the correct type of parameter must be given as I<$parameter>.  If the action is expecting no parameters then I<parameter> must be C<undefined>.  See `get-action-parameter-type()`.

  method activate-action ( Str $action_name, N-GVariant $parameter )

=item Str $action_name; the name of the action to activate
=item N-GVariant $parameter; (nullable): parameters to the activation

=end pod

method activate-action ( Str $action_name, $parameter ) {
  my $no = $parameter;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_action_group_activate_action(
    self._f('GActionGroup'), $action_name, $no
  );
}

sub g_action_group_activate_action ( N-GObject $action_group, gchar-ptr $action_name, N-GVariant $parameter  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:change-action-state:
=begin pod
=head2 change-action-state

Request for the state of the named action within I<action-group> to be changed to I<value>.  The action must be stateful and I<value> must be of the correct type. See `get-action-state-type()`.  This call merely requests a change.  The action may refuse to change its state or may change its state to something other than I<value>. See `get-action-state-hint()`.  If the I<value> GVariant is floating, it is consumed.

  method change-action-state ( Str $action_name, N-GVariant $value )

=item Str $action_name; the name of the action to request the change on
=item N-GVariant $value; the new state

=end pod

method change-action-state ( Str $action_name, $value ) {
  my $no = $value;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_action_group_change_action_state(
    self._f('GActionGroup'), $action_name, $no
  );
}

sub g_action_group_change_action_state ( N-GObject $action_group, gchar-ptr $action_name, N-GVariant $value  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-action-enabled:
=begin pod
=head2 get-action-enabled

Checks if the named action within I<action-group> is currently enabled.  An action must be enabled in order to be activated or in order to have its state changed from outside callers.

Returns: whether or not the action is currently enabled

  method get-action-enabled ( Str $action_name --> Bool )

=item Str $action_name; the name of the action to query

=end pod

method get-action-enabled ( Str $action_name --> Bool ) {

  g_action_group_get_action_enabled(
    self._f('GActionGroup'), $action_name
  ).Bool;
}

sub g_action_group_get_action_enabled ( N-GObject $action_group, gchar-ptr $action_name --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-action-parameter-type:
=begin pod
=head2 get-action-parameter-type

Queries the type of the parameter that must be given when activating the named action within I<action-group>.  When activating the action using [[activate-action]], the B<GVariant> given to that function must be of the type returned by this function.  In the case that this function returns C<undefined>, you must not give any B<GVariant>, but C<undefined> instead.  The parameter type of a particular action will never change but it is possible for an action to be removed and for a new action to be added with the same name but a different parameter type.

Returns: (nullable): the parameter type

  method get-action-parameter-type (
    Str $action_name --> Gnome::Glib::VariantType
  )

=item Str $action_name; the name of the action to query

=end pod

method get-action-parameter-type (
  Str $action_name --> Gnome::Glib::VariantType
) {

  Gnome::Glib::VariantType.new(:native-object(
      g_action_group_get_action_parameter_type(
        self._f('GActionGroup'), $action_name
      )
    )
  );
}

sub g_action_group_get_action_parameter_type ( N-GObject $action_group, gchar-ptr $action_name --> N-GVariantType )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-action-state:
=begin pod
=head2 get-action-state

Queries the current state of the named action within I<action-group>.  If the action is not stateful then C<undefined> will be returned.  If the action is stateful then the type of the return value is the type given by [[get-action-state-type]].  The return value (if non-C<undefined>) should be freed with [[g-variant-unref]] when it is no longer required.

Returns: the current state of the action

  method get-action-state (
    Str $action_name --> Gnome::Glib::Variant
  )

=item Str $action_name; the name of the action to query

=end pod

method get-action-state ( Str $action_name --> Gnome::Glib::Variant ) {

  Gnome::Glib::Variant.new(:native-object(
      g_action_group_get_action_state(
        self._f('GActionGroup'), $action_name
      )
    )
  );
}

sub g_action_group_get_action_state ( N-GObject $action_group, gchar-ptr $action_name --> N-GVariant )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-action-state-hint:
=begin pod
=head2 get-action-state-hint

Requests a hint about the valid range of values for the state of the named action within I<action-group>.  If C<undefined> is returned it either means that the action is not stateful or that there is no hint about the valid range of values for the state of the action.  If a B<GVariant> array is returned then each item in the array is a possible value for the state.  If a B<GVariant> pair (ie: two-tuple) is returned then the tuple specifies the inclusive lower and upper bound of valid values for the state.  In any case, the information is merely a hint.  It may be possible to have a state value outside of the hinted range and setting a value within the range may fail.  The return value (if non-C<undefined>) should be freed with [[g-variant-unref]] when it is no longer required.

Returns: the state range hint

  method get-action-state-hint ( Str $action_name --> Gnome::Glib::Variant )

=item Str $action_name; the name of the action to query

=end pod

method get-action-state-hint ( Str $action_name --> Gnome::Glib::Variant ) {

  Gnome::Glib::Variant.new(:native-object(
      g_action_group_get_action_state_hint(
        self._f('GActionGroup'), $action_name
      )
    )
  );
}

sub g_action_group_get_action_state_hint ( N-GObject $action_group, gchar-ptr $action_name --> N-GVariant )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-action-state-type:
=begin pod
=head2 get-action-state-type

Queries the type of the state of the named action within I<action-group>.  If the action is stateful then this function returns the B<GVariantType> of the state.  All calls to `change-action-state()` must give a B<GVariant> of this type and `g-action-group-get-action-state()` will return a B<GVariant> of the same type.  If the action is not stateful then this function will return C<undefined>. In that case, [[g-action-group-get-action-state]] will return C<undefined> and you must not call [[g-action-group-change-action-state]].  The state type of a particular action will never change but it is possible for an action to be removed and for a new action to be added with the same name but a different state type.

Returns: (nullable): the state type, if the action is stateful

  method get-action-state-type ( Str $action_name --> Gnome::Glib::VariantType )

=item Str $action_name; the name of the action to query

=end pod

method get-action-state-type ( Str $action_name --> Gnome::Glib::VariantType ) {

  Gnome::Glib::VariantType.new(:native-object(
      g_action_group_get_action_state_type(
        self._f('GActionGroup'), $action_name
      )
    )
  );
}

sub g_action_group_get_action_state_type ( N-GObject $action_group, gchar-ptr $action_name --> N-GVariantType )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:has-action:
=begin pod
=head2 has-action

Checks if the named action exists within I<action-group>.

Returns: whether the named action exists

  method has-action ( Str $action_name --> Bool )

=item Str $action_name; the name of the action to check for

=end pod

method has-action ( Str $action_name --> Bool ) {

  g_action_group_has_action(
    self._f('GActionGroup'), $action_name
  ).Bool;
}

sub g_action_group_has_action ( N-GObject $action_group, gchar-ptr $action_name --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:list-actions:
=begin pod
=head2 list-actions

Lists the actions contained within I<action-group>.

Returns: an array of the names of the actions in the group

  method list-actions ( --> Array  )

=end pod

method list-actions ( -->  Array ) {

  my CArray[Str] $as = g_action_group_list_actions(
    self._f('GActionGroup'),
  );

  my Array $a = [];
  my Int $i = 0;
  while $as[$i].defined {
    $a.push: $as[$i];
    $i++;
  }

  $a
}

sub g_action_group_list_actions ( N-GObject $action_group --> gchar-pptr )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:query-action:
=begin pod
=head2 query-action

Queries all aspects of the named action within an I<action-group>.  This function acquires the information available from `has-action()`, `get-action-enabled()`, `get-action-parameter-type()`, `get-action-state-type()`, `get-action-state-hint()` and `get-action-state()` with a single function call.

This provides two main benefits.  The first is the improvement in efficiency that comes with not having to perform repeated lookups of the action in order to discover different things about it.  The second is that implementing B<GActionGroup> can now be done by only overriding this one virtual function.

=comment The interface provides a default implementation of this function that calls the individual functions, as required, to fetch the information.  The interface also provides default implementations of those functions that call this function.  All implementations, therefore, must override either this function or all of the others.

=comment If the action exists, C<True> is returned and any of the requested fields (as indicated by having a non-C<undefined> reference passed in) are filled.  If the action doesn't exist, C<False> is returned and the fields may or may not have been modified.

Returns: A List if the action exists, else an empty List

  method query-action ( Str $action_name --> List )

=item Str $action_name; the name of an action in the group

The returned list holds;

=item Bool $enabled; if the action is presently enabled
=item Gnome::Glib::VariantType $parameter_type; the parameter type, or C<undefined> if none needed
=item Gnome::Glib::VariantType $state_type; the state type, or C<undefined> if stateless
=item Gnome::Glib::Variant $state_hint; the state hint, or C<undefined> if none
=item Gnome::Glib::Variant $state; the current state, or C<undefined> if stateless

=end pod

method query-action ( Str $action_name --> List ) {

  my gboolean $enabled;
  my $parameter_type = CArray[N-GVariantType].new(N-GVariantType);
  my $state_type = CArray[N-GVariantType].new(N-GVariantType);
  my $state_hint = CArray[N-GVariant].new(N-GVariant);
  my $state = CArray[N-GVariant].new(N-GVariant);

  my Int $r = g_action_group_query_action(
    self._f('GActionGroup'), $action_name, $enabled, $parameter_type,
    $state_type, $state_hint, $state
  );

  if $r {
    ( $enabled.Bool,
      Gnome::Glib::VariantType.new(:native-object($parameter_type[0])),
      Gnome::Glib::VariantType.new(:native-object($state_type[0])),
      Gnome::Glib::Variant.new(:native-object($state_hint[0])),
      Gnome::Glib::Variant.new(:native-object($state[0]))
    )
  }

  else {
    ()
  }
}

sub g_action_group_query_action (
  N-GObject $action_group, gchar-ptr $action_name, gboolean $enabled is rw,
  CArray[N-GVariantType] $parameter_type, CArray[N-GVariantType] $state_type,
  CArray[N-GVariant] $state_hint, CArray[N-GVariant] $state
  --> gboolean
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
=comment #TS:1:action-added:
=head3 action-added

Signals that a new action was just added to the group.
This signal is emitted after the action has been added
and is now visible.

  method handler (
    Str $action_name,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($action_group),
    *%user-options
  );

=item $action_group; the B<GActionGroup> that changed

=item $action_name; the name of the action in I<action-group>


=comment -----------------------------------------------------------------------
=comment #TS:0:action-enabled-changed:
=head3 action-enabled-changed

Signals that the enabled status of the named action has changed.

  method handler (
    Str $action_name,
    Int $enabled,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($action_group),
    *%user-options
  );

=item $action_group; the B<GActionGroup> that changed

=item $action_name; the name of the action in I<action-group>

=item $enabled; whether the action is enabled or not


=comment -----------------------------------------------------------------------
=comment #TS:0:action-removed:
=head3 action-removed

Signals that an action is just about to be removed from the group.
This signal is emitted before the action is removed, so the action
is still visible and can be queried from the signal handler.


  method handler (
    Str $action_name,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($action_group),
    *%user-options
  );

=item $action_group; the B<GActionGroup> that changed

=item $action_name; the name of the action in I<action-group>


=comment -----------------------------------------------------------------------
=comment #TS:0:action-state-changed:
=head3 action-state-changed

Signals that the state of the named action has changed.


  method handler (
    Str $action_name,
    Unknown type G_TYPE_VARIANT $value,
    Int :$_handle_id,
    Gnome::GObject::Object :_widget($action_group),
    *%user-options
  );

=item $action_group; the B<GActionGroup> that changed

=item $action_name; the name of the action in I<action-group>

=item $value; the new value of the state


=end pod
