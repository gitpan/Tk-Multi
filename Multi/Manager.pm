package Tk::Multi::Manager;

use strict;
use vars qw($VERSION @ISA $errno);

use Carp ;
use Tk::Derived;
use Tk::Frame;

@ISA = qw(Tk::Derived Tk::Frame);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

$VERSION = substr q$Revision: 1.9 $, 10;

Tk::Widget->Construct('MultiManager');

my $title_num = 0;

sub Populate
  {
    my ($cw,$args) = @_ ;
    
    require Tk::Menubutton;

    my $title =  delete $args->{'title'} || delete $args->{'-title'} || 
      'display';

    my $userMenu = delete $args->{menu} || delete $args->{-menu} ;
    if ($userMenu)
      {
        $cw->{menu}= $userMenu -> Menubutton (-text => $title) 
          -> pack(side => 'left' );
      }
    else
      {
        my $w_menu = $cw->Frame(-relief => 'raised', -borderwidth => 2);
        $w_menu->pack(-fill => 'x');
        $cw->{menu}= $w_menu -> Menubutton (-text => $title) 
          -> pack(side => 'left') ;
      }

    my $obj = $cw->{windowFrame} = $cw -> Frame -> pack ;

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


    $args{'title'} = $args{'-title'} || $cw->Class . "-" . $title_num++
      unless defined $args{'title'} ;
    my $title =  $args{'title'} ;

    my $slaveType = delete $args{'type'};
    croak("No type specified\n") unless defined $slaveType ;

    # add button if it doesn't exist
    if (defined $cw->{menu}{$title})
      {
        # display error message
        die "Window $title already exists\n";
      }
 
    $cw->{'show'}{$title} = 1 ;
    if (defined $args{'hidden'} )
      {
        $cw->{'show'}{$title} = 0 if $args{'hidden'} == 1 ;
        delete $args{'hidden'} ;
      }
    
    if (defined $cw->{slave}{$title})
      {
        $cw->updateVisi($title) ;
        return $cw->{slave}{$title} ;
      };

    my $frame = $cw -> {windowFrame} ;
     
    my $topmenu = $cw->{menu} ;
    $topmenu -> cascade(-label => $title ) ;

    my $cm = $topmenu -> cget(-menu);
    my $menu = $cm->Menu;
    $topmenu->entryconfigure($title, -menu => $menu);
    $menu->checkbutton(-label => 'show', 
                       -variable => \$cw->{'show'}{$title},
                      command => sub {$cw->updateVisi($title) ;});

    $cw->{submenu}{$title} = $menu ;

    my $destroyable = delete $args{'destroyable'} ;

    $cw->{slave}{$title} = 
      $frame -> $slaveType ('menu_button' => $menu, 
                            qw/relief raised borderwidth 2/,
                            %args);

    if (defined $destroyable and $destroyable)
      {
        $menu->command(-label=>'destroy', 
                       command => sub{$cw->destroySlave($title);} );
      }

    $cw->{slave}{$title} -> pack() if $cw->{'show'}{$title};

    return $cw->{slave}{$title} ;
  }


sub hide 
  {
    my $cw = shift ;
    my $title = shift ;
    $cw->{'show'}{$title} = 0;
    $cw-> updateVisi($title) ;
  }

sub show 
  {
    my $cw = shift ;
    my $title = shift ;
    $cw->{'show'}{$title} = 1;
    $cw-> updateVisi($title) ;
  }

sub updateVisi
  {
    my $cw = shift ;
    my $title = shift ;
    
    if ($cw->{'show'}{$title})
      {
        #raise it
        $cw->{slave}{$title} -> pack ;
      }
    else
      {
        #hide it
        $cw->{slave}{$title} -> packForget ;
      }
  }

sub destroySlave
  {
    my $cw = shift ;
    my $title = shift ;

    die "Slave $title does not exist\n" 
      unless defined $cw->{slave}{$title} ;

    # retrieve actual menu object from the MenuButtom
    my $cm = $cw->{menu} -> cget(-menu);

    $cw->{slave}{$title}->destroy;
    $cw->{submenu}{$title}->destroy;
    
    # delete the actual Menu entry from topmenu
    $cm -> delete($title) ;

    delete $cw->{'show'}{$title} ;
    delete $cw->{submenu}{$title} ;
    delete $cw->{slave}{$title} ;
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

=over 4

=item type

specifies the kind of Multi widget (ex MultiText).

=item title

specifies the title of the widget (mandatory).

=item hidden

specifies whether the widget is to be packed right now or not 
(default 0)

=item destroyable

a 'destroy' button is created if this parameter is defined (default no).
Returns the slave widget reference.

=back

=head2 hide('name of the slave');

Hide the slave.

=head2 show('name of the slave');

Show the slave.

=head2 destroySlave( 'name of the slave') ;

Destroy the slave

=head1 BUGS

When unpacking or destroying the last window, the enclosing frame does not
reduce its size. It's probably a matter of geometry propagation to the 
enclosing frame. 

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1997-1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi::Text(3)

=cut

