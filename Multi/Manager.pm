package Tk::Multi::Manager;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $errno);

use Carp ;
use Tk ;

require Exporter;
require AutoLoader;

@ISA = qw(Tk::Frame AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);
$VERSION = '0.01';

Tk::Widget->Construct('MultiManager');

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

sub Populate
  {
    my ($cw,$args) = @_ ;
    
    my $title = 'display';
    $title = delete $args->{title} if defined $args->{title} ;
    
    if (defined $args->{menu})
      {
        $cw->{dodu}{menu}= $args->{menu} -> Menubutton (-text => $title) 
          -> pack(side => 'left' );
      }
    else
      {
        my $w_menu = $cw->Frame(-relief => 'raised', -borderwidth => 2);
        $w_menu->pack(-fill => 'x');
        $cw->{dodu}{menu}= $w_menu -> Menubutton (-text => $title) 
          -> pack(side => 'left') ;
      }

    my $obj = $cw->{dodu}{windowFrame} = $cw -> Frame -> pack ;

    $cw->ConfigSpecs(DEFAULT => [$obj]) ;
    $cw->Delegates(DEFAULT => $obj) ;
  }

# may add a new Note to the note book
# or create a separate sub-window to see windows side by side
# or move a Note to a separate window 
# and vice-versa ?
sub newSlave
  {
    my $cw = shift ;
    my %args = @_ ;

    my $title = $args{'title'} ;
    croak("No title specified\n") unless defined $title ;

    my $slaveType = delete $args{'type'};
    croak("No type specified\n") unless defined $slaveType ;

    # add button if it doesn't exist
    if (defined $cw->{dodu}{menu}{$title})
      {
        # display error message
        die "Window $title already exists\n";
      }
 
    $cw->{dodu}{show}{$title} = 
      not (defined $args{'hidden'} ? delete $args{'hidden'}: 0 ) ;
    
    if (defined $cw->{dodu}{slave}{$title})
      {
        $cw->toggleVisi($title) ;
        return $cw->{dodu}{slave}{$title} ;
      };

    my $frame = $cw -> {dodu}{windowFrame} ;
     
    my $topmenu = $cw->{dodu}{menu} ;
    $topmenu -> cascade(-label => $title ) ;

    my $cm = $topmenu -> cget(-menu);
    my $menu = $cm->Menu;
    $topmenu->entryconfigure($title, -menu => $menu);
    $menu->checkbutton(-label => 'show', 
                       -variable => \$cw->{dodu}{show}{$title},
                      command => sub {$cw->toggleVisi($title) ;});

    $cw->{dodu}{submenu}{$title} = $menu ;

    $cw->{dodu}{slave}{$title} = 
      $frame -> $slaveType ('menu_button' => $menu, %args);

    if ($args{'destroyable'})
      {
        $menu->command(-label=>'destroy', 
                       command => sub{$cw->destroySlave($title);} );
      }

    $cw->{dodu}{slave}{$title} -> pack if $cw->{dodu}{show}{$title};

    return $cw->{dodu}{slave}{$title} ;
  }

sub toggleVisi
  {
    my $cw = shift ;
    my $title = shift ;
    
    if ($cw->{dodu}{show}{$title})
      {
        #raise it
        $cw->{dodu}{slave}{$title} -> pack ;
      }
    else
      {
        #hide it
        $cw->{dodu}{slave}{$title} -> packForget ;
      }
  }

sub destroySlave
  {
    my $cw = shift ;
    my $title = shift ;

    # retrieve actual menu object from the MenuButtom
    my $cm = $cw->{dodu}{menu} -> cget(-menu);

    $cw->{dodu}{slave}{$title}->destroy;
    $cw->{dodu}{submenu}{$title}->destroy;
    
    # delete the actual Menu entry from topmenu
    $cm -> delete($title) ;

    delete $cw->{dodu}{show}{$title} ;
    delete $cw->{dodu}{submenu}{$title} ;
    delete $cw->{dodu}{slave}{$title} ;
  }

1;
__END__


=head1 NAME

Tk::Multi::Manager - Tk composite widget managing Tk::Multi slaves

=head1 SYNOPSIS

 use Tk::Multi::Manager ;
 use Tk::Multi::Text ; # if you use MultiText as a slave

 my $manager = yourWindow -> MultiManager 
  (
   menu => $menu_ref , # optionnal
   title => "windows" # optionnal
  ) -> pack ();

 # Don't pack it, the managet will do it
 my $w1 = $manager -> newSlave('type' => 'MultiText', 'title' => 'a_label');

=head1 DESCRIPTION

The manager is a composite widget made of a menu cascade of check buttons 
and slaves which can be Tk::Multi::Text.

The user can add windows to the manager. Each window visibility is 
controled by a check button in the menu cascade.
The check button actually tells the packer to forget the window. note that
the window object is not destroyed.

=head1 Constructor configuration options

=head2 menu

The widget may use a 'menu' argument which will be used to create a menu 
item and releveant sub-menus to control the sub-window.
If not provided, the widget will create a its own menu.

=head2 title

The optionnal title argument contains the title of the menu created by the 
manager.

=head1 Methods

=head2 newSlave('type' => 'MultiXXX', 'title'=> 'name', ['hidden' => 1] ) ;

Create a new slave to manager. Returns the slave widget object. 
 'type' specifies the kind of Multi widget (ex MultiText).
 'title' specifies the title of the widget (mandatory).
 'hidden' specifies whether the widget is to be packed tight now or not 
(default 0)
 'destroyable' A 'destroy' button is created if this parameter is defined (default no).

=head2 destroySlave( 'name of the slave') ;

Destroy the slave

=head1 BUGS

When unpacking or destroying the last window, the enclosing frame does not
reduce its size. It's probably a matter of geometry propagation to the 
enclosing frame. 

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi::Text(3)

=cut
