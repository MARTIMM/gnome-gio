#TL:0:Gnome::Gio::Action:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Action

An action interface

=head1 Description

B<Gnome::Gio::Action> represents a single named action.

The main interface to an action is that it can be activated with
C<g_action_activate()>.  This results in the 'activate' signal being
emitted.  An activation has a B<GVariant> parameter (which may be
C<Any>).  The correct type for the parameter is determined by a static
parameter type (which is given at construction time).

An action may optionally have a state, in which case the state may be
set with C<g_action_change_state()>.  This call takes a B<GVariant>.  The
correct type for the state is determined by a static state type
(which is given at construction time).

The state may have a hint associated with it, specifying its valid
range.

B<Gnome::Gio::Action> is merely the interface to the concept of an action, as
described above.  Various implementations of actions exist, including
B<GSimpleAction>.

In all cases, the implementing class is responsible for storing the
name of the action, the parameter type, the enabled state, the
optional state type and the state and emitting the appropriate
signals when these change.  The implementor is responsible for filtering
calls to C<g_action_activate()> and C<g_action_change_state()> for type
safety and for the state being enabled.

Probably the only useful thing to do with a B<Gnome::Gio::Action> is to put it
inside of a B<GSimpleActionGroup>.


=begin comment
=head2 Known implementations

Gnome::Gio::Action is implemented by
=comment item Gnome::Gio::PropertyAction
=item [Gnome::Gio::SimpleAction](SimpleAction.html)


=end comment

=head1 Synopsis
=head2 Declaration

  unit role Gnome::Gio::Action;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::Glib::Error;

#-------------------------------------------------------------------------------
unit role Gnome::Gio::Action:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

#-------------------------------------------------------------------------------
#TM:1:new():interfacing
# interfaces are not instantiated
submethod BUILD ( *%options ) { }

#`{{
=begin pod
=head1 Methods
=head2 new

Create a new Action object.

  multi method new ( )

Create a Action object using a native object from elsewhere. See also B<Gnome::GObject::Object>.

  multi method new ( N-GObject :$native-object! )

Create a Action object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

#TM:0:new():inheriting
#TM:0:new():
#TM:0:new(:native-object):
#TM:0:new(:build-id):

submethod BUILD ( *%options ) {



  # prevent creating wrong native-objects
  return unless self.^name eq 'Gnome::Gio::Action';

  # process all named arguments
  if ? %options<widget> || ? %options<native-object> ||
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
  else {
    # self.set-native-object(g_action_new());
  }

  # only after creating the native-object, the gtype is known
  self.set-class-info('GAction');
}
}}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
# Hook for modules using this interface. Same principle as _fallback but
# does not need callsame. Also this method must be usable without
# an instanciated object.
method _action_interface ( Str $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &::("g_action_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::("$native-sub"); } if !$s and $native-sub ~~ m/^ 'g_' /;
  $s
}

#-------------------------------------------------------------------------------
#TM:0:g_action_get_name:
=begin pod
=head2 [g_action_] get_name

Queries the name of I<action>.

Returns: the name of the action B<Gnome::Gio::Action>

  method g_action_get_name ( --> Str )


=end pod

sub g_action_get_name ( N-GObject $action --> Str )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_get_parameter_type:
=begin pod
=head2 [g_action_] get_parameter_type

Queries the type of the parameter that must be given when activating
I<action>.

When activating the action using C<g_action_activate()>, the B<GVariant>
given to that function must be of the type returned by this function.

In the case that this function returns C<Any>, you must not give any
B<GVariant>, but C<Any> instead.

Returns: (nullable): the parameter type
B<Gnome::Gio::Action>
  method g_action_get_parameter_type ( --> N-GObject )


=end pod

sub g_action_get_parameter_type ( N-GObject $action --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_get_state_type:
=begin pod
=head2 [g_action_] get_state_type

Queries the type of the state of I<action>.

If the action is stateful (e.g. created with
C<g_simple_action_new_stateful()>) then this function returns the
B<GVariantType> of the state.  This is the type of the initial value
given as the state. All calls to C<g_action_change_state()> must give a
B<GVariant> of this type and C<g_action_get_state()> will return a
B<GVariant> of the same type.

If the action is not stateful (e.g. created with C<g_simple_action_new()>)
then this function will return C<Any>. In that case, C<g_action_get_state()>
will return C<Any> and you must not call C<g_action_change_state()>.

Returns: (nullable): the state type, if the action is stateful
B<Gnome::Gio::Action>
  method g_action_get_state_type ( --> N-GObject )


=end pod

sub g_action_get_state_type ( N-GObject $action --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_get_state_hint:
=begin pod
=head2 [g_action_] get_state_hint

Requests a hint about the valid range of values for the state of
I<action>.

If C<Any> is returned it either means that the action is not stateful
or that there is no hint about the valid range of values for the
state of the action.

If a B<GVariant> array is returned then each item in the array is a
possible value for the state.  If a B<GVariant> pair (ie: two-tuple) is
returned then the tuple specifies the inclusive lower and upper bound
of valid values for the state.

In any case, the information is merely a hint.  It may be possible to
have a state value outside of the hinted range and setting a value
within the range may fail.

The return value (if non-C<Any>) should be freed with
C<g_variant_unref()> when it is no longer required.

Returns: (nullable) (transfer full): the state range hint
B<Gnome::Gio::Action>
  method g_action_get_state_hint ( --> N-GObject )


=end pod

sub g_action_get_state_hint ( N-GObject $action --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_get_enabled:
=begin pod
=head2 [g_action_] get_enabled

Checks if I<action> is currently enabled.

An action must be enabled in order to be activated or in order to
have its state changed from outside callers.

Returns: whether the action is enabled
B<Gnome::Gio::Action>
  method g_action_get_enabled ( --> Int )


=end pod

sub g_action_get_enabled ( N-GObject $action --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_get_state:
=begin pod
=head2 [g_action_] get_state

Queries the current state of I<action>.

If the action is not stateful then C<Any> will be returned.  If the
action is stateful then the type of the return value is the type
given by C<g_action_get_state_type()>.

The return value (if non-C<Any>) should be freed with
C<g_variant_unref()> when it is no longer required.

Returns: (transfer full): the current state of the action
B<Gnome::Gio::Action>
  method g_action_get_state ( --> N-GObject )


=end pod

sub g_action_get_state ( N-GObject $action --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_change_state:
=begin pod
=head2 [g_action_] change_state

Request for the state of I<action> to be changed to I<value>.

The action must be stateful and I<value> must be of the correct type.
See C<g_action_get_state_type()>.

This call merely requests a change.  The action may refuse to change
its state or may change its state to something other than I<value>.
See C<g_action_get_state_hint()>.

If the I<value> GVariant is floating, it is consumed.
B<Gnome::Gio::Action>
  method g_action_change_state ( N-GObject $value )

=item N-GObject $value; the new state

=end pod

sub g_action_change_state ( N-GObject $action, N-GObject $value  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_activate:
=begin pod
=head2 g_action_activate

Activates the action.

I<parameter> must be the correct type of parameter for the action (ie:
the parameter type given at construction time).  If the parameter
type was C<Any> then I<parameter> must also be C<Any>.

If the I<parameter> GVariant is floating, it is consumed.
B<Gnome::Gio::Action>
  method g_action_activate ( N-GObject $parameter )

=item N-GObject $parameter; (nullable): the parameter to the activation

=end pod

sub g_action_activate ( N-GObject $action, N-GObject $parameter  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_name_is_valid:
=begin pod
=head2 [g_action_] name_is_valid

Checks if I<action_name> is valid.

I<action_name> is valid if it consists only of alphanumeric characters,
plus '-' and '.'.  The empty string is not a valid action name.

It is an error to call this function with a non-utf8 I<action_name>.
I<action_name> must not be C<Any>.

Returns: C<1> if I<action_name> is valid
B<Gnome::Gio::Action>
  method g_action_name_is_valid ( Str $action_name --> Int )

=item Str $action_name; an potential action name

=end pod

sub g_action_name_is_valid ( Str $action_name --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_parse_detailed_name:
=begin pod
=head2 [g_action_] parse_detailed_name

Parses a detailed action name into its separate name and target
components.

Detailed action names can have three formats.

The first format is used to represent an action name with no target
value and consists of just an action name containing no whitespace
nor the characters ':', '(' or ')'.  For example: "app.action".

The second format is used to represent an action with a target value
that is a non-empty string consisting only of alphanumerics, plus '-'
and '.'.  In that case, the action name and target value are
separated by a double colon ("::").  For example:
"app.action::target".

The third format is used to represent an action with any type of
target value, including strings.  The target value follows the action
name, surrounded in parens.  For example: "app.action(42)".  The
target value is parsed using C<g_variant_parse()>.  If a tuple-typed
value is desired, it must be specified in the same way, resulting in
two sets of parens, for example: "app.action((1,2,3))".  A string
target can be specified this way as well: "app.action('target')".
For strings, this third format must be used if * target value is
empty or contains characters other than alphanumerics, '-' and '.'.

Returns: C<1> if successful, else C<0> with I<error> set
B<Gnome::Gio::Action>
  method g_action_parse_detailed_name ( Str $detailed_name, CArray[Str] $action_name, N-GObject $target_value, N-GError $error --> Int )

=item Str $detailed_name; a detailed action name
=item CArray[Str] $action_name; (out): the action name
=item N-GObject $target_value; (out): the target value, or C<Any> for no target
=item N-GError $error; a pointer to a C<Any> B<GError>, or C<Any>

=end pod

sub g_action_parse_detailed_name ( Str $detailed_name, CArray[Str] $action_name, N-GObject $target_value, N-GError $error --> int32 )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_print_detailed_name:
=begin pod
=head2 [g_action_] print_detailed_name

Formats a detailed action name from I<action_name> and I<target_value>.

It is an error to call this function with an invalid action name.

This function is the opposite of C<g_action_parse_detailed_name()>.
It will produce a string that can be parsed back to the I<action_name>
and I<target_value> by that function.

See that function for the types of strings that will be printed by
this function.

Returns: a detailed format string
B<Gnome::Gio::Action>
  method g_action_print_detailed_name ( Str $action_name, N-GObject $target_value --> Str )

=item Str $action_name; a valid action name
=item N-GObject $target_value; (nullable): a B<GVariant> target value, or C<Any>

=end pod

sub g_action_print_detailed_name ( Str $action_name, N-GObject $target_value --> Str )
  is native(&gio-lib)
  { * }

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


The name of the action.  This is mostly meaningful for identifying
the action once it has been added to a B<GActionGroup>. It is immutable.


The B<Gnome::GObject::Value> type of property I<name> is C<G_TYPE_STRING>.

=comment #TP:0:parameter-type:
=head3 Parameter Type


The type of the parameter that must be given when activating the
action. This is immutable, and may be C<Any> if no parameter is needed when
activating the action.


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
action is stateless. This is immutable.


The B<Gnome::GObject::Value> type of property I<state-type> is C<G_TYPE_BOXED>.

=comment #TP:0:state:
=head3 State


The state of the action, or C<Any> if the action is stateless.


The B<Gnome::GObject::Value> type of property I<state> is C<G_TYPE_VARIANT>.
=end pod
