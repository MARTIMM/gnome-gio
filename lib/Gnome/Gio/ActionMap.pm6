#TL:1:Gnome::Gio::ActionMap:

use v6.d;

#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::ActionMap

Interface for action containers

=head1 Description

I<include>: gio/gio.h

The Gnome::Gio::ActionMap interface is implemented by B<Gnome::Gio::ActionGroup> implementations that operate by containing a number of named B<Gnome::Gio::Action> instances, such as B<Gnome::Gio::SimpleActionGroup>.

One useful application of this interface is to map the names of actions from various action groups to unique, prefixed names (e.g. by prepending "app." or "win."). This is the motivation for the 'Map' part of the interface name.

=head2 Known implementations

Gnome::Gio::ActionMap is implemented by

=item [Gnome::Gio::Application](Application.html)
=comment item Gnome::Gio::SimpleActionGroup.



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
use Gnome::Gio::Action;

#-------------------------------------------------------------------------------
unit role Gnome::Gio::ActionMap:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
#`{{TODO
class N-GActionEntry is export is repr('CStruct') {
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

#-------------------------------------------------------------------------------
#TM:1:new():interfacing
# interfaces are not instantiated

submethod BUILD ( *%options ) { }

#`{{
=begin pod
=head1 Methods
=head2 new

Create a new ActionMap object.

  multi method new ( )

Create a ActionMap object using a native object from elsewhere. See also B<Gnome::GObject::Object>.

  multi method new ( N-GObject :$native-object! )

Create a ActionMap object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

#TM:0:new():inheriting
#TM:0:new():
#TM:0:new(:native-object):
#TM:0:new(:build-id):

submethod BUILD ( *%options ) {



  # prevent creating wrong native-objects
  return unless self.^name eq 'Gnome::Gio::ActionMap';

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
    # self.set-native-object(g_action_map_new());
  }

  # only after creating the native-object, the gtype is known
  self.set-class-info('GActionMap');
}
}}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _action_map_interface ( $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &::("g_action_map_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  $s
}

#-------------------------------------------------------------------------------
#TM:0:g_action_map_lookup_action:
=begin pod
=head2 [g_action_map_] lookup_action

Looks up the action with the name I<action_name> in I<action_map>.

If no such action exists, returns C<Any>.

Returns: (transfer none): a B<N-GAction>, or C<Any>

Since: 2.32

  method g_action_map_lookup_action ( Str $action_name --> GAction )

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

Adds an action to the I<action_map>.

If the action map already contains an action with the same name
as I<action> then the old action is dropped from the action map.

The action map takes its own reference on I<action>.

Since: 2.32

  method g_action_map_add_action ( GAction $action )

=item GAction $action; a B<GAction>

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
and adding them to a B<GActionMap>.

Each action is constructed as per one B<GActionEntry>.

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

static GActionGroup *
create_action_group (void)
{
const GActionEntry entries[] = {
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

  method g_action_map_add_action_entries ( GActionEntry $entries, Int $n_entries, Pointer $user_data )

=item GActionEntry $entries; (array length=n_entries) (element-type GActionEntry): a pointer to the first item in an array of B<GActionEntry> structs
=item Int $n_entries; the length of I<entries>, or -1 if I<entries> is C<Any>-terminated
=item Pointer $user_data; the user data for signal connections

=end pod

sub g_action_map_add_action_entries ( N-GObject $action_map, GActionEntry $entries, int32 $n_entries, Pointer $user_data  )
  is native(&gio-lib)
  is export
  { * }
}}
