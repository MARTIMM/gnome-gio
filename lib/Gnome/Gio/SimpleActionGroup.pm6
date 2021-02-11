#TL:1:Gnome::Gio::SimpleActionGroup:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gio::SimpleActionGroup

A simple GActionGroup implementation

=comment ![](images/X.png)

=head1 Description

B<Gnome::Gio::SimpleActionGroup> is a hash table filled with native B<Gnome::Gio::Action> objects, implementing the B<Gnome::Gio::ActionGroup> and B<Gnome::Gio::ActionMap> interfaces.

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gio::SimpleActionGroup;
  also is Gnome::GObject::Object;
  also does Gnome::Gio::ActionGroup;
  also does Gnome::Gio::ActionMap;


=comment head2 Uml Diagram

=comment ![](plantuml/.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Gio::SimpleActionGroup;

  unit class MyGuiClass;
  also is Gnome::Gio::SimpleActionGroup;

  submethod new ( |c ) {
    # let the Gnome::Gio::SimpleActionGroup class process the options
    self.bless( :GSimpleActionGroup, |c);
  }

  submethod BUILD ( ... ) {
    ...
  }

=end comment
=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

use Gnome::GObject::Object;

use Gnome::Gio::ActionGroup;
use Gnome::Gio::ActionMap;
#-------------------------------------------------------------------------------
unit class Gnome::Gio::SimpleActionGroup:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::GObject::Object;
also does Gnome::Gio::ActionGroup;
also does Gnome::Gio::ActionMap;

#-------------------------------------------------------------------------------
my Bool $signals-added = False;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 default, no options

Create a new SimpleActionGroup object.

  multi method new ( )

=head3 :native-object

Create a SimpleActionGroup object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=head3 :build-id

Create a SimpleActionGroup object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )

=end pod

#TM:0:new():inheriting
#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
#TM:4:new(:build-id):Gnome::GObject::Object

submethod BUILD ( *%options ) {

  # add signal info in the form of group<signal-name>.
  # groups are e.g. signal, event, nativeobject etc
  unless $signals-added {
    $signals-added = True;
    self._add_action_group_signal_types($?CLASS.^name);
  }


  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gio::SimpleActionGroup' #`{{ or %options<GSimpleActionGroup> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists or %options<widget>:exists { }
    elsif %options<build-id>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<___x___> {
      #  $no = %options<___x___>;
      #  $no .= get-native-object-no-reffing unless $no ~~ N-GObject;
        #$no = _g_simple_action_group_new___x___($no);
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

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      ##`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _g_simple_action_group_new();
      }
      #}}

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GSimpleActionGroup');

  }
}

#`{{
#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &::("g_simple_action_group_$native-sub"); };
# check for gtk_, gdk_, g_, pango_, cairo_ !!!
  try { $s = &::("gtk_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'gtk_' /;

  #$s = self._xyz_interface($native-sub) unless ?$s;

  self.set-class-name-of-sub('GSimpleActionGroup');
  $s = callsame unless ?$s;

  $s;
}
}}


#-------------------------------------------------------------------------------
#TM:1:_g_simple_action_group_new:
#`{{
=begin pod
=head2 _g_simple_action_group_new

Creates a new, empty, B<Gnome::Gio::SimpleActionGroup>.

Returns: a new B<Gnome::Gio::SimpleActionGroup>

  method _g_simple_action_group_new ( --> GSimpleActionGroup )


=end pod
}}

sub _g_simple_action_group_new ( --> N-GObject )
  is native(&gio-lib)
  is symbol('g_simple_action_group_new')
  { * }
