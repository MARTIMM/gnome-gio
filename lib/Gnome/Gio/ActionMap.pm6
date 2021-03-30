#TL:1:Gnome::Gio::ActionMap:

use v6;

#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::ActionMap

Interface for action containers

=head1 Description

The Gnome::Gio::ActionMap interface is implemented by B<Gnome::Gio::ActionGroup> implementations that operate by containing a number of named B<Gnome::Gio::Action> instances, such as B<Gnome::Gio::SimpleActionGroup>.

One useful application of this interface is to map the names of actions from various action groups to unique, prefixed names (e.g. by prepending "app." or "win."). This is the motivation for the 'Map' part of the interface name.


=head1 Synopsis
=head2 Declaration

  unit role Gnome::Gio::ActionMap;


=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

use Gnome::Gio::Action;
use Gnome::Gio::SimpleAction;

#-------------------------------------------------------------------------------
unit role Gnome::Gio::ActionMap:auth<github:MARTIMM>:ver<0.1.0>;

#-------------------------------------------------------------------------------
#`{{TODO
class N-GObjectEntry is export is repr('CStruct') {
  has Str $.name;

  void (* activate) (GSimpleAction *action,
                     GVariant      *parameter,
                     gpointer       user_data);

  const gchar *parameter_type;

  const gchar *state;

  void (* change_state) (GSimpleAction *action,
                         GVariant      *value,
                         gpointer       user_data);
};
}}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

# interfaces are not instantiated
#submethod BUILD ( *%options ) { }


#-------------------------------------------------------------------------------
#TM:2:add-action:
=begin pod
=head2 add-action

Adds an action to the action map.  If the action map already contains an action with the same name as I<$action> then the old action is dropped from the action map.  The action map takes its own reference on I<$action>.

  method add-action ( N-GObject $action )

=item N-GObject $action; an action object

=end pod

method add-action ( $action ) {
  my $no = $action;
  $no .= get-native-object-no-reffing unless $no ~~ N-GObject;

  g_action_map_add_action( self._f('GActionMap'), $no);
}

sub g_action_map_add_action ( N-GObject $action_map, N-GObject $action  )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:add-action-entries:
=begin pod
=head2 add-action-entries

A convenience function for creating multiple SimpleAction instances and adding them to this action map. The method will never call the native subroutine but will perform the necessary steps to add the action and register C<activate> and C<change-state> signals. Each entry in the Array is a Hash with the following keys;

=item Str :name; the name of the action. This must be defined.

=item Any :activate-handler-object; handler class object. If undefined, :activate will be ignored.

=item Str :activate; the callback method defined in C<activate-handler-object> to connect to the "activate" signal of the action. this can be undefined for stateful actions, in which case the default handler is used. For boolean-stated actions with no parameter, this behaves like a toggle. For other state types (and parameter type equal to the state type) this will be a function that just calls change_state (which you should provide).
=item Hash :activate-data; additional data to the C<.register-signal()>. May be undefined

=item Str :parameter-type; the type of the parameter that must be passed to the activate function for this action, given as a single GVariant type string (or undefined for no parameter)

=item Str :state; the initial state for this action, given in Variant text format. The state is parsed with no extra type information, so type tags must be added to the string if they are necessary. Stateless actions should not define this key. For more information look for L<GVariant Text Format|https://developer.gnome.org/glib/stable/gvariant-text.html>.

=item Any :change-state-handler-object; handler class object. If undefined, :change_state will be ignored.

=item Str :change-state the callback method defined in C<change-state-handler-object> to connect to the "change-state" signal of the action. All stateful actions should provide a handler here; stateless actions should not.
=item Hash :change-state-data; additional data to the C<.register-signal()>. May be undefined

This Hash will mimic the original structure GActionEntry close enough while being more flexible for Raku users.

  method add-action-entries ( Array $entries )

=item Array $entries; an array of hashes

=end pod

method add-action-entries ( Array $entries ) {

  for @$entries -> Hash $entry {
    next unless ?$entry<name>;

    my Gnome::Gio::SimpleAction $sa;
    my Gnome::Glib::VariantType $parameter-type;
    if ?$entry<parameter-type> {
      $parameter-type .= new(:type-string($entry<parameter-type>));
    }

    else {
      $parameter-type .= new(:native-object(N-GObject));
    }

    if ? $entry<state> {
      $sa .= new(
        :name($entry<name>), :$parameter-type,
        :state(Gnome::Glib::Variant.new(
          :parse($entry<state>))
        )
      );
    }

    else {
      $sa .= new( :name($entry<name>), :$parameter-type);
    }

    # Action methods should be available through widgets like Application
    self.add-action($sa);

    # register signals on simple action
    if ?$entry<activate-handler-object> and ?$entry<activate> {
      $sa.register-signal(
        $entry<activate-handler-object>, $entry<activate>, 'activate',
        #|%$entry<activate-data>
      );
    }

    if ?$entry<change-state-handler-object> and ?$entry<change-state> {
      $sa.register-signal(
        $entry<change-state-handler-object>, $entry<change-state>,
        'change-state', #|%$entry<change-state-data>
      );
    }
  }
}



#sub g_action_map_add_action_entries (
#  N-GObject $action_map, N-GObjectEntry $entries, gint $n_entries,
#  gpointer $user_data
#) is native(&gio-lib)
#  { * }


#-------------------------------------------------------------------------------
#TM:2:lookup-action:
=begin pod
=head2 lookup-action

Looks up the action with the name I<$action_name> in action map.  If no such action exists, returns an invalid object.

Returns: a Gnome::Gio::SimpleAction object

  method lookup-action (
    Str $action_name --> Gnome::Gio::SimpleAction
  )

=item  Str  $action_name; the name of an action

=end pod

method lookup-action ( Str $action_name --> Gnome::Gio::SimpleAction ) {

  Gnome::Gio::SimpleAction.new(
    :native-object(
      g_action_map_lookup_action( self._f('GActionMap'), $action_name)
    )
  )
}

sub g_action_map_lookup_action ( N-GObject $action_map, gchar-ptr $action_name --> N-GObject )
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:remove-action:
=begin pod
=head2 remove-action

Removes the named action from the action map.  If no action of this name is found in the map then nothing happens.

  method remove-action ( Str $action_name )

=item Str $action_name; the name of the action

=end pod

method remove-action ( Str $action_name ) {

  g_action_map_remove_action(
    self._f('GActionMap'), $action_name
  );
}

sub g_action_map_remove_action ( N-GObject $action_map, gchar-ptr $action_name  )
  is native(&gio-lib)
  { * }

























=finish
#-------------------------------------------------------------------------------
#TM:0:g_action_map_lookup_action:
=begin pod
=head2 [g_action_map_] lookup_action

Looks up the action with the name I<action_name> in action map.

If no such action exists, returns C<Any>.

Returns: (transfer none): a B<N-N-GObject>, or C<Any>

Since: 2.32

  method g_action_map_lookup_action ( Str $action_name --> N-GObject )

=item Str $action_name; the name of an action

=end pod

sub g_action_map_lookup_action ( N-GObject $action_map, Str $action_name --> N-GObject )
  is export
  is native(&gio-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_map_add_action:
=begin pod
=head2 [g_action_map_] add_action

Adds an action to the action map.

If the action map already contains an action with the same name
as I<action> then the old action is dropped from the action map.

The action map takes its own reference on I<action>.

Since: 2.32

  method g_action_map_add_action ( N-GObject $action )

=item N-GObject $action; a B<N-GObject>

=end pod

sub g_action_map_add_action ( N-GObject $action_map, N-GObject $action  )
  is native(&gio-lib)
  is export
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_action_map_remove_action:
=begin pod
=head2 [g_action_map_] remove_action

Removes the named action from the action map.

If no action of this name is in the map then nothing happens.

Since: 2.32

  method g_action_map_remove_action ( Str $action_name )

=item Str $action_name; the name of the action

=end pod

sub g_action_map_remove_action ( N-GObject $action_map, Str $action_name  )
  is native(&gio-lib)
  is export
  { * }


#`{{
#-------------------------------------------------------------------------------
#TM:0:g_action_map_add_action_entries:
=begin pod
=head2 [g_action_map_] add_action_entries

A convenience function for creating multiple B<GSimpleAction> instances
and adding them to a B<N-GObject>.

Each action is constructed as per one B<N-GObjectEntry>.

|[<!-- language="C" -->
static void
activate_quit (GSimpleAction *simple,
GVariant      *parameter,
gpointer       user_data)
{
exit (0);
}

static void
activate_print_string (GSimpleAction *simple,
GVariant      *parameter,
gpointer       user_data)
{
g_print ("C<s>\n", g_variant_get_string (parameter, NULL));
}

static N-GObjectGroup *
create_action_group (void)
{
const N-GObjectEntry entries[] = {
{ "quit",         activate_quit              },
{ "print-string", activate_print_string, "s" }
};
GSimpleActionGroup *group;

group = C<g_simple_action_group_new()>;
g_action_map_add_action_entries (G_ACTION_MAP (group), entries, G_N_ELEMENTS (entries), NULL);

return G_ACTION_GROUP (group);
}
]|

Since: 2.32

  method g_action_map_add_action_entries ( N-GObjectEntry $entries, Int $n_entries, Pointer $user_data )

=item N-GObjectEntry $entries; (array length=n_entries) (element-type N-GObjectEntry): a pointer to the first item in an array of B<N-GObjectEntry> structs
=item Int $n_entries; the length of I<entries>, or -1 if I<entries> is C<Any>-terminated
=item Pointer $user_data; the user data for signal connections

=end pod

sub g_action_map_add_action_entries ( N-GObject $action_map, N-GObjectEntry $entries, int32 $n_entries, Pointer $user_data  )
  is native(&gio-lib)
  is export
  { * }
}}
