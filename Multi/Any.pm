package Tk::Multi::Any ;

use strict;
require Tk::Derived;
require Tk::Frame;

use vars qw(@ISA $VERSION $incHeightBm $decHeightBm $incWidthBm $decWidthBm);

$incHeightBm = 'incH' ;
$decHeightBm = 'decH';
$incWidthBm = 'incW' ;
$decWidthBm = 'decW';

@ISA = qw(Tk::Derived Tk::Frame);

$VERSION = substr q$Revision: 1.5 $, 10;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

sub Populate
  {
    my ($cw,$args) = @_ ;
    

    my $slaveArgs = delete $args->{'_slave'} ;
    $cw->BackTrace("$cw: No _slave defined\n") unless defined $slaveArgs ;
    
    my $title = delete $args->{'title'} || delete $args->{'-title'} || 
      'anonymous';
    $cw ->{'title'} = $title ;

    my $resizeNb = delete $args->{'_resize_amount'} ;
    die "No _resize_amount passed to ",ref($cw),"\n" unless defined $resizeNb ;

    # not advertised yet, may change when Scrolled works
    my $hScroll = delete $args->{'_hscroll'} ;

    my $packSlaveArgs = delete $args->{'_pack'} || [] ;
    my $menu = delete $args->{'menu_button'} || delete $args->{'-menu_button'};
    die "Multi window $title: missing menu_button argument\n" 
      unless defined $menu ;

    my $titleLabel = $cw->Label(text => $title.' display')-> pack() ;

    my $slaveFrame = $cw -> Frame ->pack(@$packSlaveArgs) ;
    
    $menu->command(-label=>'print', command => [$cw, 'print' ]) ;
    $menu->command(-label=>'clear', command => [$cw, 'clear' ]);
    
    # use Images (see p32) (BITMAP -> used as image option in button )
    $cw ->_defineHBM () 
      if (scalar grep($_ eq $incHeightBm, $cw->imageNames) == 0) ;
    $cw->_defineWBM() 
      if (defined $hScroll and
          (scalar grep($_ eq $decWidthBm, $cw->imageNames) == 0) 
         ) ;

    my $b_f = $slaveFrame -> Frame -> pack (-fill => 'y',side => 'left') ;
    $b_f -> Button (-image => $incHeightBm,
                   -command => [$cw, 'resize', $resizeNb ]) 
      -> pack (side => 'top') ;

    $b_f -> Button (-image => $decHeightBm,
                    -command => [$cw, 'resize', -$resizeNb ]) 
      -> pack (side => 'top') ;

    my $what = shift @$slaveArgs ;
    my $slaveWindow = $slaveFrame -> $what ( @$slaveArgs )  ;

    # can't usepackAdjust within a Notebook .
    #$slaveWindow->packAdjust(qw(fill both expand 1));
    my $w_s = $slaveFrame -> Scrollbar(-command => ['yview', $slaveWindow]);
    $slaveWindow->configure(-yscrollcommand => ['set', $w_s]);
    $w_s->pack(-side => 'right', -fill => 'y');

    if (defined $hScroll)
      {
        $b_f -> Button (-image => $incWidthBm,
                        -command => [$cw, 'resize', 0, $resizeNb ]) 
          -> pack (side => 'top') ;
        $b_f -> Button (-image => $decWidthBm,
                        -command => [$cw, 'resize', 0, -$resizeNb ]) 
          -> pack (side => 'top') ;
        
        my $cw_hscroll = $slaveFrame->Scrollbar
          (
           -orient => 'horiz',
           -command => [$slaveWindow => 'xview'],
          );

        $slaveWindow->configure(-xscrollcommand => [$cw_hscroll => 'set']);
        $cw_hscroll->pack(-side => 'bottom', -fill => 'x');
      }

    $slaveWindow -> pack() ;

    my $obj = $what eq 'Text' ? $slaveWindow : $cw ;
    my $subref = sub {$menu->Popup(-popover => 'cursor', -popanchor => 'nw')};

    $obj->bind ('<Button-3>', $subref);

    $titleLabel -> bind('<Button-3>', $subref);

    # print stuff
    $cw->{_printToFile} = 0;
    $cw->{_printFile} = '';

    $cw->ConfigSpecs('relief' => ['SELF'],
                     'borderwidth' => ['SELF'],
                    'width' => [$slaveWindow],
                    'height' => [$slaveWindow],
                     'DEFAULT' => [$slaveWindow]
                    ) ;
    $cw->Delegates('command' => $menu, 
                   DEFAULT => $slaveWindow) ;

  }

#hidden method

sub _defineHBM
  {
    my $cw = shift ;

    $cw->Bitmap 
      ($incHeightBm, 
       -data =>'
#define incHeight_width 9
#define incHeight_height 20
static char incHeight_bits[] = {
   0x10, 0x00, 0x38, 0x00, 0x54, 0x00, 0x92, 0x00, 0x11, 0x01, 0x10, 0x00,
   0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x10, 0x00,
   0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x11, 0x01, 0x92, 0x00, 0x54, 0x00,
   0x38, 0x00, 0x10, 0x00}; ' ) ;
    $cw->Bitmap ($decHeightBm, -data => '
#define decHeight_width 9
#define decHeight_height 20
static char decHeight_bits[] = {
   0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x11, 0x01, 0x92, 0x00, 0x54, 0x00,
   0x38, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x10, 0x00, 0x38, 0x00, 0x54, 0x00, 0x92, 0x00, 0x11, 0x01, 0x10, 0x00,
   0x10, 0x00, 0x10, 0x00}; ') ;
  }

#hidden method
sub _defineWBM
  {
    my $cw = shift ;
    $cw->Bitmap 
      ($incWidthBm, 
       -data =>'
#define incWidth_width 20
#define incWidth_height 9
static char incWidth_bits[] = {
   0x10, 0x80, 0x00, 0x08, 0x00, 0x01, 0x04, 0x00, 0x02, 0x02, 0x00, 0x04,
   0xff, 0xff, 0x0f, 0x02, 0x00, 0x04, 0x04, 0x00, 0x02, 0x08, 0x00, 0x01,
   0x10, 0x80, 0x00};
' ) ;
    $cw->Bitmap ($decWidthBm, -data => '
#define decWidth_width 20
#define decWidth_height 9
static char decWidth_bits[] = {
   0x04, 0x00, 0x02, 0x08, 0x00, 0x01, 0x10, 0x80, 0x00, 0x20, 0x40, 0x00,
   0x7f, 0xe0, 0x0f, 0x20, 0x40, 0x00, 0x10, 0x80, 0x00, 0x08, 0x00, 0x01,
   0x04, 0x00, 0x02};
') ;
  }

sub resize
  {
    my $cw= shift ;
    my $h_inc = shift ;
    my $w_inc = shift ;

    my $nh ;
    my $nw ;

    if (defined $h_inc and $h_inc != 0)
      {
        $nh = $cw -> cget('height') ;
        $nh += $h_inc ;
      }

    if (defined $w_inc and $w_inc != 0)
      {
        $nw = $cw -> cget('width') ;
        $nw += $w_inc ;
      }
    $cw -> setSize($nh,$nw) ;
  }

sub setSize
  {
    my $cw= shift ;
    my $nh = shift ;
    my $nw = shift ;

    if (defined $nh)
      {
        if ($nh >= $cw->{minHeight})
          {$cw->configure('height' => $nh);}
        else {$cw -> bell;}
      }

    if (defined $nw)
      {
        if ( $nw >= $cw->{minWidth} ) 
          {$cw->configure('width' => $nw);}
        else {$cw -> bell;}
      }
  }

sub print
  {
    my $cw= shift ;

    my $popup = $cw -> Toplevel ;
    $popup -> title ($cw->{'title'}.' print query') ;
    $popup -> grab ;
    $popup -> Label(text => 'modify print command as needed :') -> pack ;
    my $pentry = $popup -> Entry(textvariable => $cw->{_printCmdRef}) 
      -> pack(fill => 'x') ;
    $popup -> Label(text => 'print on file :') -> pack ;
    my $fentry = $popup -> Entry(textvariable => \$cw->{_printFile},
                                state => 'disabled' ) ;

    $popup -> Checkbutton
      (
       -text => 'print to file',
       -variable => \$cw->{_printToFile},
       command => sub 
       {
         if ($cw->{_printToFile})
           {
             $fentry->configure(state => 'normal');
             $pentry->configure(state => 'disabled');
           }
         else
           {
             $pentry->configure(state => 'normal');
             $fentry->configure(state => 'disabled');
           }
       }
      ) -> pack ;

    $fentry -> pack(fill => 'x') ;

    my $f = $popup -> Frame -> pack(fill => 'x') ;
    $f -> Button (text => 'print', 
                  command => sub {
                    $cw -> doPrint(); 
                    $popup -> destroy ;
                  })
      -> pack (side => 'left') ;
    $f -> Button (text => 'default', 
                  command => sub {$cw->resetPrintCmd();})
      -> pack (side => 'left') ;
    $f -> Button (text => 'cancel', command => sub {$popup -> destroy ;})
      -> pack (side => 'right') ;
  }

sub doPrint
  {
    my $cw= shift ;

    if ($cw->{_printToFile})
      {
        open(POUT,'>'.$cw->{_printFile}) 
          or die "Can't open file $cw->{_printFile}$!\n";
        print POUT $cw->printableDump() ;
        close POUT or die "print command failed: $!\n";
      }
    else
      {
        my $ref = $cw->{_printCmdRef};
        open(POUT,'|'.$$ref) or die "Can't open print pipe $!\n";
        print POUT $cw->printableDump() ;
        close POUT or die "print command failed: $!\n";
      }
  }

sub hide
  { 
    my $cw= shift ;
    
    my @array = $cw -> packInfo ;

    if ($array[0] eq '-in')
      {
        $cw -> packForget() ;
      }
    else
      {
        print "Can't do packForget\n";
      }
  }

sub setPrintCmd
  {
    my $cw= shift ;
    my $ref = $cw->{_printCmdRef} ;
    $$ref = shift ;
  }


1;
__END__


# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Tk::Multi::Any - Tk virtual composite widget 

=head1 SYNOPSIS

 package Tk::Multi::YourWidget ;
 use strict;
 require Tk::Multi::Any;
 require Tk::Derived;

 use vars qw(@ISA $printCmd $defaultPrintCmd $VERSION);

 @ISA = qw(Tk::Derived Tk::Multi::Any);

 ( $VERSION ) = '$Revision: 1.5 $ ' =~ /\$Revision:\s+([^\s]+)/;

 $printCmd = $defaultPrintCmd = 'lp -owhatever' ;

 Tk::Widget->Construct('YourWidget');


 use Tk::Multi::Any ; 

 sub Populate
  {
    my ($cw,$args) = @_ ;
    require Tk::Label;
    require Tk::ROText;

    $cw->{_printCmdRef} = \$printCmd ;
    $args->{_resize_amount} = 5 ;# units depend on your widget type
    $cw->{minWidth} = 40 ; 
    $cw->{minHeight} = 4 ;

    $args->{_slave} = $cw -> 
 #      Scrolled('ROText',
 #              -scrollbars => 'oe',
      ROText( relief => 'sunken', bd => '2', setgrid => 'true', height => 5);

    $cw-> SUPER::Populate($args) -> pack ;

  }

=head1 DESCRIPTION

This virtual class must be inherited by your composite widget to make a 
brand new composite widget usable to Tk::Multi::Manager


=head1 WIDGET-SPECIFIC OPTIONS

=head2 title

Some text which will be displayed above the slave window. 

=head2 menu_button

The slave window feature a set of menu items which must be added in a menu.
This menu ref must be passed with the menu_button prameter 
to the object during its instanciation. Usually, this parameter is passed 
by the Multi::Manager.

=head1 WIDGET-SPECIFIC METHODS

=head2 setSize( height, [ width ])

Will resize the text window. 

=head2 resize ( height_increment [, width_increment])

Will increment or decrement the slave window size.

=head2 print

Will raise a popup window with an Entry to modify the actual print command,
a print button, a default button (to restore the default print command),
and a cancel button.

=head2 hide

Will hide the widget.

=head2 setPrintCmd('print command')

Will set the $printCmd class variable to the passed string. You may use this
method to set the appropriate print command on your machine. Note that 
using this method will all other instance of YourWidget since the
modified variable is not an instance variable but a class variable.

=head2 doPrint

Print the title and the content of the text window. The print is invoked
by dumping the text content into a piped command. By default this command 
is set to 'lp -ol70 -otl66 -o12 -olm10' which works fine on my HP-UX
machine with A4 paper.

You may want to set up a new command to print correctly on your machine.
You may do it by using the setPrintCmd method or by invoking the 
'print' method.

=head1 Delegated methods

By default all widget method are delegated to the Text widget. Excepted :

=head2 command(-label => 'some text', -command => sub {...} )

Delegated to the menu entry managed by Multi::Manager. Will add a new command
to the aforementionned menu.

=head1 Mandatory method in child class

The following methods must be defined in your child class.

=head2 Populate

Must define the slave widget included in the Multi class. Within this 
Populate method, you must define the following paramaters which are to 
be passed to Any::Populate.

=item *

_slave: Array ref containing the specs of the slave widget (for instance 
[qw/ROText bd 2/]). No default. 

=item *

_resize_amount: Number or string which will be used to 
increment or decrement the slave
window size.

=item *

_hscroll: Slave window will have a horizontal scroll if set to 1 (default 0)

=item *

_pack:  Pack arguments used when packing the frame containing the slave window.
(empty by default).


=item *

minWidth : minimum width of the widget

=item *

minHeight : minimum height of the widget

=item *

_printCmdRef: a reference to the $printCmd class variable.

=head2 clear

Clear the slave widget

=head2 resetPrintCmd 

=head2 printableDump

Must return a string usable to print the content of the slave widget.

=head2 BUGS

Popup menus don't work on canvas based widget. In this case the Popup 
appears on the title on top of the widget.

=head1 TO DO

I'm not really satisfied with print management. May be one day, I'll write a 
print management composite widget which will look like Netscape's print 
window. But that's quite low on my priority list. Any volunteer ?

Use Scrolled to get better scrolling interface.

Disable button when size limit is reached (or use PackAdjust when it's fixed)

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1997-1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi(3), Tk::Multi::Manager(3)

=cut
