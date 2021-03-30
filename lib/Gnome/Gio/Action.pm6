#TL:1:Gnome::Gio::Action:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::Action

An action interface


=head1 Description

B<Gnome::Gio::Action> represents a single named action.

The main interface to an action is that it can be activated with C<activate()>.  This results in the 'activate' signal being emitted.

An action may optionally have a state, in which case the state may be set with C<change-state()>.  This call takes a B<N-GObject>.  The correct type for the state is determined by a static state type (which is given at construction time).

The state may have a hint associated with it, specifying its valid range.

B<Gnome::Gio::Action> is merely the interface to the concept of an action, as described above.  Various implementations of actions exist, including B<GSimpleAction>.

In all cases, the implementing class is responsible for storing the name of the action, the parameter type, the enabled state, the optional state type and the state and emitting the appropriate signals when these change.  The implementor is responsible for filtering calls to C<activate()> and C<change-state()> for type safety and for the state being enabled.

Probably the only useful thing to do with a B<Gnome::Gio::Action> is to put it inside of a B<GSimpleActionGroup>.


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
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::Error;
use Gnome::Glib::Variant;
use Gnome::Glib::VariantType;

#-------------------------------------------------------------------------------
unit role Gnome::Gio::Action:auth<github:MARTIMM>:ver<0.1.0>;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

# interfaces are not instantiated
#submethod BUILD ( *%options ) { }

#-------------------------------------------------------------------------------
#TM:2:activate:
=begin pod
=head2 activate

Activates the action.  I<$parameter> must be the correct type of parameter for the action (ie: the parameter type given at construction time).  If the parameter type was undefined then I<$parameter> must also be undefined.  If the I<$parameter> GVariant is floating, it is consumed.

  method activate ( N-GObject $parameter )

=item N-GObject $parameter; the parameter to the activation

=end pod

method activate ( $parameter ) {
  my $no = $parameter;
  $no .= get-native-object-no-reffing unless $no ~~ N-GObject;

  g_action_activate(
    self._f('GAction'), $no
  );
}

sub g_action_activate ( N-GObject $action, N-GObject $parameter  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:change-state:
=begin pod
=head2 change-state

Request for the state of this action to be changed to I<$value>. The action must be stateful and I<value> must be of the correct type. See C<get-state-type()>.  This call merely requests a change.  The action may refuse to change its state or may change its state to something other than I<value>. See C<get-state-hint()>.

  method change-state ( N-GObject $value )

=item N-GObject $value; the new state

=end pod

method change-state ( $value ) {
  my $no = $value;
  $no .= get-native-object-no-reffing unless $no ~~ N-GObject;

  g_action_change_state(
    self._f('GAction'), $no
  );
}

sub g_action_change_state ( N-GObject $action, N-GObject $value  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:get-enabled:
=begin pod
=head2 get-enabled

Checks if this action is currently enabled.  An action must be enabled in order to be activated or in order to have its state changed from outside callers.

Returns: whether the action is enabled

  method get-enabled ( --> Bool )


=end pod

method get-enabled ( --> Bool ) {

  g_action_get_enabled(
    self._f('GAction'),
  ).Bool;
}

sub g_action_get_enabled ( N-GObject $action --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:get-name:
=begin pod
=head2 get-name

Queries the name of this action.

Returns: the name of the action.

  method get-name ( -->  Str  )


=end pod

method get-name ( -->  Str  ) {

  g_action_get_name(
    self._f('GAction'),
  );
}

sub g_action_get_name ( N-GObject $action --> gchar-ptr )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:get-parameter-type:
=begin pod
=head2 get-parameter-type

Queries the type of the parameter that must be given when activating this action.  When activating the action using C<activate()>, the B<N-GObject> given to that function must be of the type returned by this function.  In the case that this function returns undefined, you must not give any B<N-GObject>, but undefined instead.

Returns: the parameter type.

  method get-parameter-type ( --> Gnome::Glib::VariantType )

=end pod

method get-parameter-type ( --> Gnome::Glib::VariantType ) {

  Gnome::Glib::VariantType.new(
    :native-object(g_action_get_parameter_type(self._f('GAction')))
  );
}

sub g_action_get_parameter_type ( N-GObject $action --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:get-state:
=begin pod
=head2 get-state

Queries the current state of this action.  If the action is not stateful then undefined will be returned.  If the action is stateful then the type of the return value is the type given by C<get-state-type()>.  The return value (if not undefined) should be freed with C<clear-object()> when it is no longer required.

Returns: the current state of the action.

  method get-state ( --> Gnome::Glib::Variant )

=end pod

method get-state ( --> Gnome::Glib::Variant ) {

  Gnome::Glib::Variant.new(
    :native-object(g_action_get_state(self._f('GAction')))
  );
}

sub g_action_get_state ( N-GObject $action --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:get-state-hint:
=begin pod
=head2 get-state-hint

Requests a hint about the valid range of values for the state of this action.  If an undefined value is returned, it either means that the action is not stateful or that there is no hint about the valid range of values for the state of the action.
=comment  If a B<N-GObject> array is returned then each item in the array is a possible value for the state.  If a B<N-GObject> pair (ie: two-tuple) is returned then the tuple specifies the inclusive lower and upper bound of valid values for the state. In any case, the information is merely a hint.  It may be possible to have a state value outside of the hinted range and setting a value within the range may fail.
The returned value, if defined, should be freed with C<clear-object()> when it is no longer required.

Returns: the state range hint, an undefined, array or tuple Variant.

  method get-state-hint ( --> Gnome::Glib::Variant )

=end pod

method get-state-hint ( --> Gnome::Glib::Variant ) {

  Gnome::Glib::Variant.new(
    :native-object(g_action_get_state_hint(self._f('GAction')))
  );
}

sub g_action_get_state_hint ( N-GObject $action --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-state-type:
=begin pod
=head2 get-state-type

Queries the type of the state of this action.  If the action is stateful, then this function returns the B<Gnome::Glib::VariantType> of the state.  This is the type of the initial value given as the state. All calls to C<change-state()> must give a B<N-GObject> of this type and C<get-state()> will return a B<N-GObject> of the same type. If the action is not stateful, then this function will return an undefined type. In that case, C<get-state()> will return undefined and you must not call C<change-state()>.

Returns: the state type, if the action is stateful

  method get-state-type ( --> Gnome::Glib::VariantType )


=end pod

method get-state-type ( --> Gnome::Glib::VariantType ) {

  Gnome::Glib::VariantType.new(
    :native-object(g_action_get_state_type(self._f('GAction')))
  );
}

sub g_action_get_state_type ( N-GObject $action --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:name-is-valid:
=begin pod
=head2 name-is-valid

Checks if I<$action_name> is valid.  I<$action_name> is valid if it consists only of alphanumeric characters, plus '-' and '.'.  The empty string is not a valid action name.  It is an error to call this function with a non-utf8 I<action_name>.

Returns: C<True> if I<action_name> is valid

  method name-is-valid (  Str  $action_name --> Bool )

=item  Str  $action_name; an potential action name

=end pod

method name-is-valid (  Str  $action_name --> Bool ) {

  g_action_name_is_valid($action_name).Bool;
}

sub g_action_name_is_valid ( gchar-ptr $action_name --> gboolean )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:parse-detailed-name:
=begin pod
=head2 parse-detailed-name

Parses a detailed action name into its separate name and target components.  Detailed action names can have three formats.

The first format is used to represent an action name with no target value and consists of just an action name containing no whitespace or the characters ':', '(' or ')'.  For example: I<app.action>.

The second format is used to represent an action with a target value that is a non-empty string consisting only of alphanumerics, plus '-' and '.'.  In that case, the action name and target value are separated by a double colon ("::").  For example: I<app.action::target>.

The third format is used to represent an action with any type of target value, including strings.  The target value follows the action name, surrounded in parens.  For example: I<app.action(42)>.

The target value is parsed using C<parse()> from B<Gnome::Glib::Variant>.  If a tuple-typed value is desired, it must be specified in the same way, resulting in two sets of parens, for example: I<app.action((1,2,3))>.  A string target can be specified this way as well: I<app.action('target')>. For strings, this third format must be used if the target value is empty or contains characters other than alphanumerics, '-' and '.'.

Returns: A List

  method parse-detailed-name ( Str $detailed_name --> List )

=item Str $detailed_name; a detailed action name

The returned List contains;
=item Str $action_name; the action name
=item Gnome::Glib::Variant $target_value; the target value, or an undefined type for no target
=item Gnome::Glib::Error which is invalid if call returns successfull or is valid with an error message and code explaining the cause.

=end pod

method parse-detailed-name ( Str  $detailed_name --> List ) {

  my $an = CArray[Str].new('');
  my $tv = CArray[N-GObject].new(N-GObject);
  my $e = CArray[N-GError].new(N-GError);

  my Int $r = g_action_parse_detailed_name( $detailed_name, $an, $tv, $e);

  if $r {
#note "r: $r, $an[0], $tv[0]";
    ( $an[0], Gnome::Glib::Variant.new(:native-object($tv[0])),
      Gnome::Glib::Error.new(:native-object(N-GError))
    )
  }

  else {
#note "r: $r, $e[0].gist()";
    ( '', Gnome::Glib::Variant.new(:native-object(N-GObject)),
      Gnome::Glib::Error.new(:native-object($e[0]))
    )
  }
}

sub g_action_parse_detailed_name (
  gchar-ptr $detailed_name, gchar-pptr $action_name,
  CArray[N-GObject] $target_value, CArray[N-GError] $error --> gboolean
) is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:print-detailed-name:
=begin pod
=head2 print-detailed-name

Formats a detailed action name from I<$action_name> and I<$target_value>.  It is an error to call this function with an invalid action name.  This function is the opposite of C<parse-detailed-name()>. It will produce a string that can be parsed back to the I<$action_name> and I<$target_value> by that function.  See that function for the types of strings that will be printed by this function.

Returns: a detailed format string

  method print-detailed-name (
    Str $action_name, N-GObject $target_value
    --> Str
  )

=item  Str  $action_name; a valid action name
=item N-GObject $target_value; a B<N-GObject> target value, or undefined

=end pod

method print-detailed-name ( Str $action_name, $target_value --> Str ) {
  my $no = $target_value;
  $no .= get-native-object-no-reffing unless $no ~~ N-GObject;

  g_action_print_detailed_name( $action_name, $no);
}

sub g_action_print_detailed_name (
  gchar-ptr $action_name, N-GObject $target_value --> gchar-ptr
) is native(&gio-lib)
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

=comment -----------------------------------------------------------------------
=comment #TP:1:name:
=head3 Action Name

The name of the action.  This is mostly meaningful for identifying
the action once it has been added to a B<GActionGroup>. It is immutable.


The B<Gnome::GObject::Value> type of property I<name> is C<G_TYPE_STRING>.

=comment -----------------------------------------------------------------------
=comment #TP:0:parameter-type:
=head3 Parameter Type

The type of the parameter that must be given when activating the
action. This is immutable, and may be C<Any> if no parameter is needed when
activating the action.

The B<Gnome::GObject::Value> type of property I<parameter-type> is C<G_TYPE_BOXED>.

=comment -----------------------------------------------------------------------
=comment #TP:1:enabled:
=head3 Enabled

If this action is currently enabled.

If the action is disabled then calls to C<g_action_activate()> and
C<g_action_change_state()> have no effect.

The B<Gnome::GObject::Value> type of property I<enabled> is C<G_TYPE_BOOLEAN>.

=comment -----------------------------------------------------------------------
=comment #TP:0:state-type:
=head3 State Type


The B<N-GObject> of the state that the action has, or C<Any> if the
action is stateless. This is immutable.


The B<Gnome::GObject::Value> type of property I<state-type> is C<G_TYPE_BOXED>.

=comment -----------------------------------------------------------------------
=comment #TP:0:state:
=head3 State

The state of the action, or C<Any> if the action is stateless.

The B<Gnome::GObject::Value> type of property I<state> is C<G_TYPE_VARIANT>.
=end pod
