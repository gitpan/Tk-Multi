############################################################
#
# $Header: /home/domi/Tools/perlDev/Tk_Multi/Multi/RCS/Toplevel.pm,v 1.5 1999/01/04 12:32:20 domi Exp $
#
# $Source: /home/domi/Tools/perlDev/Tk_Multi/Multi/RCS/Toplevel.pm,v $
# $Revision: 1.5 $
# $Locker:  $
# 
############################################################

package Tk::Multi::Toplevel ;

use Carp ;

use strict ;
require Tk::Toplevel;
require Tk::Derived;

use vars qw(@ISA $VERSION) ;
$VERSION = sprintf "%d.%03d", q$Revision: 1.5 $ =~ /(\d+)\.(\d+)/;

@ISA = qw(Tk::Derived Tk::Toplevel);

Tk::Widget->Construct('MultiTop') ;


sub Populate
  {
    my ($cw,$args) = @_ ;

    require Tk::Multi::Manager ;
    require Tk::Multi::Text ;
    require Tk::ObjScanner ;
    
    $cw->{manager} = delete $args->{manager} || $cw ;
    $cw->{podName} = delete $args->{podName} ;
    $cw->{podSection} = delete $args->{podSection} ;

    my $showDebug = sub 
      { 
        # must not create 2 scanner windows
        unless (scalar grep(ref($_ ) eq 'Tk::ObjScanner', $cw->children))
          {
            $cw -> ObjScanner('caller' => $cw->{manager}) 
              -> pack(expand => 1);
          }
      } ;

    # create common menu bar
    my $w_menu = $cw ->
      Frame(-relief => 'raised', -borderwidth => 2) -> pack(-fill => 'x');

    my $fmenu= $w_menu->Menubutton(-text => 'File', -underline => 0) ;
    $fmenu-> pack(side => 'left' );

    $cw->Advertise('fileMenu' => $fmenu->menu);

    $fmenu->command
      (
       -label => 'close',  
       -command => sub{$cw->destroy;}
      );

    $fmenu->command
      (
       -label => 'show internals...',  
       -command => $showDebug 
      );

    $cw->Advertise('menubar' => $w_menu);

    # load MultiText::manager
    my $mmgr = $cw -> MultiManager 
      ( 
       'title' => 'windows' , 
       'menu' => $w_menu ,
       'help' => sub {$cw->showHelp() ;}
      ) 
        -> pack (expand => 1, fill => 'both');
    
    $cw->Advertise('multiMgr' => $mmgr);
    # bind dump info 
    #$self->{tk}{toplevel}->bind ('<Meta-d>', $showDebug);
    

    $cw->ConfigSpecs(
                     'relief' => [$cw],
                     'borderwidth' => [$cw],
                     'DEFAULT' => [$cw]
                    ) ;
    $cw->Delegates
      (
       newSlave => 'multiMgr',
       hide => 'multiMgr',
       show => 'multiMgr',
       destroySlave => 'multiMgr',
       'add' => 'fileMenu',
       'delete' => 'fileMenu',
       'insert' => 'fileMenu',
       DEFAULT => $cw
      ) ;

    # needed to avoid geometry problems with packAdjuster
    #$cw->DoWhenIdle(sub{ $cw->packPropagate(0);}) ;
    $cw->SUPER::Populate($args);
  }


sub menuCommand
  {
    my $cw = shift ;
    my %args = @_ ;
    my $name = $args{name};

    unless (defined $cw->Subwidget($args{menu}))
      {
        my $mb = $cw->Subwidget('menubar') -> 
          Menubutton (-text => $args{menu}) ;
        $mb-> pack ( fill => 'x' , side => 'left');
        $cw->Advertise($args{menu} => $mb );
        
        # first fill
        $mb->command (-label => $name, command => $args{command}) ;
        @{$cw->{menuItems}{$args{menu}}} = ($name);
        return ;
      }

    push @{$cw->{menuItems}{$args{menu}}}, $name;

    my %hash;
    my $i = 1 ;
    map($hash{$_}= $i++, sort @{$cw->{menuItems}{$args{menu}}}) ;

    my $pos = $hash{$name} == ($i-1) ? 'end' : $hash{$name} ;
    $cw->Subwidget($args{menu}) -> menu -> insert
      (
       $pos,'command',
       -label => $name,
       command => $args{command}
      );
  }

sub menuRemove
  {
    my $cw = shift ;
    my %args = @_ ; # name , menu
    my $name = $args{name}; # can be an array ref

    my %hash;
    my $i = 1;
    map($hash{$_}= $i++, sort @{$cw->{menuItems}{$args{menu}}}) ;

    my @array = ref($name) ? @$name : ($name) ;
    foreach (@array)
      {
        my $pos = $hash{$_} == ($i-1) ? 'end' : $hash{$_} ;

        $cw->Subwidget($args{menu}) -> menu ->delete($pos) ;
        delete $hash{$_};
        @{$cw->{menuItems}{$args{menu}}} = keys %hash ; # ugly
      }
    
    # cleanup 
    if (scalar @{$cw->{menuItems}{$args{menu}}} == 0)
      {
        delete $cw->{menuItems}{$args{menu}};
        $cw->Subwidget($args{menu})-> destroy ;
      }
  }

sub showHelp
  {
    my $cw = shift ;
    my %args = @_ ; 
    my $podName = $args{pod} ;
    my $podSection = $args{section} ;

    require Tk::Pod::Text ;
    require Tk::Pod ;
    
    my $class =  defined $podName ? $podName : 
      defined $cw->{podName} ? $cw->{podName} : ref($cw);
    my $section = defined $podSection ? $podSection :
      defined  $cw->{podSection} ? $cw->{podSection} : 'DESCRIPTION' ;

    my $podSpec = $class.'/"'.$section.'"' ;

    my $topTk = $cw->MainWindow ;

    #print "podW is ",ref($podWidget)," children ",$topTk->children,"\n";
    my ($pod)  = grep (ref($_) eq 'Tk::Pod',$topTk->children) ;
    #print "1 pod is $pod, ",ref($pod),"\n";

    unless (defined $pod) 
      {
        #print "Creating Tk::Pod\n";
        $pod = $topTk->Pod() ;
      }

    #print "2 pod is $pod, ",ref($pod),"\n";

#    $podWidget = $topTk->Pod() 
#      unless (defined $podWidget and ref($podWidget) eq 'Tk::Pod' );

    # first param is 'reuse' or 'new'.
    # Pod::Text cannot find a section befire it is displayed
    #print $podSpec,"\n";
    $pod->Subwidget('pod')->Link('reuse',undef, $podSpec)

  }

1;

__END__

=head1 NAME

Tk::Multi::Toplevel - Toplevel MultiManager

=head1 SYNOPSIS

 use Multi::Toplevel ;

 my $mw = MainWindow-> new ;
 
 my $p = $mw->MultiTop();

 # If Multi::Toplevel is the only Tk window of your application
 $mw -> withdraw ; # hide the main window
 # destroy the main window when close is called
 $p -> OnDestroy(sub{$mw->destroy});

 # add a 'bar' menu with a 'foo' button on the menu bar
 $p->menuCommand(name => 'foo', menu => 'bar', 
                 sub => sub{warn "invoked  bar->foo\n";});

 # add a menu button on the 'File' menu
 $p->add(
         'command', 
         -label => 'baz', 
         command => sub {warn "invoked  File->baz\n";}
        );

=head1 DESCRIPTION

This class is a Tk::Multi::Manager packed in a Toplevel window. It features
also :
 - a 'File->show internal...' button to invoke an Object Scanner 
   (See Tk::ObjScanner(3))
 - a facility to manage user menus with sorted buttons
 - a help facility based on Tk::Pod

=head1 Users menus

By default the Multi::Toplevel widget comes with 3 menubuttons:
 - 'File' for the main widget commands
 - 'windows' to manage the Multi slaves widget
 - 'Help'

The user can also add its own menus and menu buttons to the main menubar. 
When needed the user can call the menuCommand method to add a new menu button
(and as new menu if necessary) . Then the user can remove the menu button 
with the menuRemove command.

For instance, if the user call :
 $widget->->menuCommand(name => 'foo', menu => 'example', 
   sub => \&a_sub);
  
The menubar will feature a new 'example' menu with a 'foo' button.

Then if the user call : 
 $widget->->menuCommand(name => 'bar', menu => 'example', 
   sub => \&a_sub);

The menubar will feature a new 'bar' button in the 'example' menu. Note that 
menu buttons are sorted alphabetically.

Then if the user call : 
 $widget->menuRemove(name => 'bar', menu => 'example');

The bar button will be removed from the menu bar.

=head1 Constructor configuration options

=head2 manager

Object reference that will be scanned by the ObjScanner. Usefull when you
want to debug the object that actually use the Multi::TopLevel. By default
the ObjScanner will scan the Multi::TopLevel object.

=head2 podName

This the name of the pod file that will be displayed with the 
'Help'->'global' button. This should be set to the pod file name of the
class or the application using this widget. 

By default, the help button will display the pod file of
Multi::TopLevel.

=head2 podSection

This the section of the pod file that will be displayed with the 
'Help'->'global' button.

By default, the help button will display the 'DESCRIPTION' pod section.

=head1 Advertised widgets

 - fileMenu: 'File' Tk::Menu (on the left of the menu bar)
 - menubar : the Tk::Frame containing the menu buttons
 - multiMgr: The Tk::Multi::Manager
 
Users menus are also advertised (See below)

=head1 delegated methods

 - newSlave, hide, show, destroySlave : To the Tk::Multi::Manager 
 - add, delete, insert : To the 'File' Tk::Menu

=head1 Methods

=head2 menuCommand ( name => button_name , menu => menu_name , command => subref )

Will add the 'button_name' button in the 'menu_name' menu to invoke the sub 
ref. If necessary, the 'menu_name' menu will be created.

=head2 menuRemove ( name => button_name , menu => menu_name )

Will remove the 'button_name' button from the 'menu_name' menu.
If no buttons are left, the 'menu_name' menu will be removed from the menu
bar.

=head2 showHelp ( [pod => pod_file_name], [section => pod_section] )

Will invoke Tk::Pod of the pod file and pod_section.

By default, the pod file and section will be the one passed to the constructor
or 'Tk::Multi::Toplevel' and 'DESCRIPTION'

=head1 BUGS

Users menu does not fold when you insert a lot of buttons.

Tk::Pod 0.10 does not display the specified section. Use a later version or
this patch (http://www.xray.mpe.mpg.de/mailing-lists/ptk/1998-11/msg00033.html)

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998-1999 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi::Manager(3), Tk::Pod(3), Tk::ObjScanner(3),
Tk::mega(3)

=cut


