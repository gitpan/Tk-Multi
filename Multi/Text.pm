package Tk::Multi::Text ;

use strict;
use Tk::Derived;
use Tk::Frame;

use vars qw(@ISA $printCmd $defaultPrintCmd $VERSION);

@ISA = qw(Tk::Derived Tk::Frame);

( $VERSION ) = '$Revision: 1.7 $ ' =~ /\$Revision:\s+([^\s]+)/;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

$printCmd = $defaultPrintCmd = 'lp -ol70 -otl66 -o12 -olm10' ;

Tk::Widget->Construct('MultiText');

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

sub Populate
  {
    my ($cw,$args) = @_ ;
    
    require Tk::Label;
    require Tk::ROText;

    my $label = delete $args->{'label'} ;

    my $sf = $cw -> Frame ->pack ;
    
    my $title = delete $args->{'title'} ;
    $sf->Label(text => $title.' display')-> pack(side=>'left') 
      if defined $title  ;

    $title = defined $title ? $title : 'anonymous' ;
    $cw ->{'title'} = $title ;

    if (defined $label)
      {
        $cw ->{'label'}  = $label ;
        $cw -> Label (textvariable => \$cw ->{'label'})
          -> pack ;
      }

    my $menu = delete $args->{'menu_button'} ;
    die "MultiText: missing menu_button argument\n" unless defined $menu ;

    $menu->command(-label=>'decrease', command => [$cw, 'resize' , -5 ]);
    $menu->command(-label=>'increase', command => [$cw, 'resize', 5 ]);
    $menu->command(-label=>'print', command => [$cw, 'print' ]) ;
    $menu->command(-label=>'clear', command => [$cw, 'clear' ]);
    
    # text window
    my $textWindow = $cw -> ROText
      (relief => 'sunken', bd => '2', setgrid => 'true', height => 5);
    my $w_s = $cw -> Scrollbar(-command => ['yview', $textWindow]);
    $textWindow->configure(-yscrollcommand => ['set', $w_s]);
    $w_s->pack(-side => 'right', -fill => 'y');

    # can't usepackAdjust within a Notebook .
    #$textWindow->packAdjust(qw(fill both expand 1));
    $textWindow->pack ;

    $cw->ConfigSpecs(DEFAULT => [$textWindow]) ;
    $cw->Delegates(DEFAULT => $textWindow) ;

    if (defined $cw->{'data'})
      {
	foreach (@{$cw->{'data'}})
	  {
	    $textWindow-> insert ('end' ,$_) ;
	  }
      }
    
    $textWindow->yview('moveto', 1) ; # move diplay to the end
  }


sub resize
  {
    my $cw= shift ;
    my $inc = shift ;
    
    my $h = $cw -> cget('height') ;
    my $nh = $h+$inc ;
    if ($nh > 4)
      {
        $cw -> configure('height' => $nh);
      }
    else
      {
        $cw -> bell;
      }
  }

sub setSize
  {
    my $cw= shift ;
    my $nh = shift ;
    my $nw = shift ;            #optionnal width
    
    $cw->configure('height' => $nh) if $nh > 4 ;
    $cw->configure('width' => $nw) if defined $nw ;
  }

sub insertText
  {
    my $cw= shift ;
    my $text=shift ;
    
    $cw->insert('end',$text) ;
    $cw->yview('moveto', 1) ;
  }

sub print
  {
    my $cw= shift ;

    my $popup = $cw -> Toplevel ;
    $popup -> title ($cw->{'title'}.' print query') ;
    $popup -> grab ;
    $popup -> Label(text => 'modify print command as needed :') -> pack ;
    $popup -> Entry(textvariable => \$printCmd) -> pack(fill => 'x') ;
    my $f = $popup -> Frame -> pack(fill => 'x') ;
    $f -> Button (text => 'print', 
                  command => sub {$cw -> doPrint; $popup -> destroy ;})
      -> pack (side => 'left') ;
    $f -> Button (text => 'default', 
                  command => sub {$printCmd=$defaultPrintCmd;})
      -> pack (side => 'left') ;
    $f -> Button (text => 'cancel', command => sub {$popup -> destroy ;})
      -> pack (side => 'right') ;
  }

sub doPrint
  {
    my $cw= shift ;
    open(POUT,"|$printCmd") or die "Can't open print pipe $!\n";
    print POUT $cw ->{'label'},"\n\n" 
      if defined $cw ->{'label'} ;
    print POUT $cw->get('0.0','end') ;
    close POUT or die "print command failed: $!\n";
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

sub clear 
  {
    my $cw= shift ;
    
    $cw->delete('1.0','end') ;
  }

sub setPrintCmd
  {
    my $cw= shift ;
    $printCmd = shift ;
  }


1;
__END__


# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Tk::Multi::Text - Tk composite widget with a scroll window and more

=head1 SYNOPSIS

 use Tk::Multi::Manager;

 use Tk::Multi::Text ; 

 my $manager = yourWindow -> MultiManager 
  (
   menu => $menu_ref , # optionnal
   title => "windows" # optionnal
  ) -> pack ();

 # Don't pack it, the managet will do it
 my $w1 = $manager -> newSlave('type' => 'MultiText', 'title' => 'a_label');

=head1 DESCRIPTION

This composite widget features :

=over 4

=item *

a scrollable read-only text window (based on ROtext)

=item *

2 buttons ('++' and '--') to resize the window. (I should use packAdjust but I couldn't get it to work well. I may do it later)

=item *

a print button (The shell print command may be modified by setting 
$Tk::Multi::Text::printCmd to the appropriate shell command. By default, it is
set to 'lp -ol70 -otl66 -o12 -olm10') 

=item *

a clear button

=back

This widget will forward all unrecognize commands to the ROtext object.

Note that this widget should be created only by the Multi::Manager. 

=head1 WIDGET-SPECIFIC OPTIONS

=head2 title

Some text which will be displayed above the test window. 

=head2 menu_button

The log window feature a set of menu items which must be added in a menu.
This menu ref must be passed with the menu_button prameter 
to the object during its instaciation

=head1 WIDGET-SPECIFIC METHODS

=head2 setSize( heigth, [ width ])

Will resize the text window. Heigth lower than 5 are ignored.

=head2 insertText($some_text)

Insert the passed string at the bottom of the text window

=head2 print

Will raise a popup window with an Entry to modify the actual print command,
a print button, a default button (to restore the default print command),
and a cancel button.

=head2 doPrint

Print the label and the content of the text window. The print is invoked
by dumping the text content into a piped command. By default this command 
is set to 'lp -ol70 -otl66 -o12 -olm10' which works fine on my HP-UX
machine with A4 paper.

You may want to set up a new command to print correctly on your machine.
You may do it by using the setPrintCmd method or by invoking the 
'print' method.

=head2 setPrintCmd('print command')

Will set the $printCmd class variable to the passed string. You may use this
method to set the appropriate print command on your machine. Note that 
using this method will affect all other Tk::Multi::Text object since the
modified variable is not an instance variable but a class variable.

=head2 clear

Is just a delete('1.0','end') .

=head1 TO DO

I'm not really satisfied with print management. May be one day, I'll write a 
print management composite widget which will look like Netscape's print 
window. But that's quite low on my priority list. Any volunteer ?

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi(3), Tk::Multi::Manager(3)

=cut
