package Tk::Multi::Text ;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $printCmd);
use Tk::ROText;

require Exporter;
require AutoLoader;

@ISA = qw(Tk::Frame AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);
$VERSION = '0.01';

$printCmd = 'lp -ol70 -otl66 -o12 -olm10' ;

Tk::Widget->Construct('MultiText');

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

sub Populate
  {
    my ($cw,$args) = @_ ;
    
    my $label = delete $args->{'label'} ;

    my $sf = $cw -> Frame ->pack ;
    
    my $title = delete $args->{'title'} ;
    $sf->Label(text => $title.' display')-> pack(side=>'left') 
      if defined $title  ;

    $title = defined $title ? $title : 'anonymous' ;

    print "Creating window $title\n";

    if (defined $label)
      {
        $cw ->{dodu}{'label'}  = $label ;
        $cw -> Label (textvariable => \$cw ->{dodu}{'label'})
          -> pack ;
      }

    print "adding menus\n";
    my $menu = delete $args->{'menu_button'} ;
    die "MultiText: missing menu_button argument\n" unless defined $menu ;

    $menu->command(-label=>'decrease', command => [$cw, 'resize' , -5 ]);
    $menu->command(-label=>'increase', command => [$cw, 'resize', 5 ]);
    $menu->command(-label=>'print', command => [$cw, 'print' ]) ;
    $menu->command(-label=>'clear', command => [$cw, 'clear' ]);
    
    print "Creating ROtext $title\n";

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
    # optionnal command
#    if ($title eq 'dump' or $title eq 'remDump')
#      {
#	my $sf = $f -> Frame -> pack (side => 'left' ) ;
#	$cw->dumpSubWindow($title, $sf) ;
#	$textWindow -> configure(width => 60 ) ;
#      }

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
    $cw -> configure('height' => $nh) if $nh > 4 ;
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
    
    # if packed ? use $cw->packInfo 
    $cw->insert('end',$text) ;
    $cw->yview('moveto', 1) ;

    my @array = $cw->packInfo ;
    
    # might add a 'debug' like feature 
    unless ($array[0] eq '-in')
      {
        print ref($cw),"::",$cw->{name},": \n\t",$text ;
      }
  }

sub print
  {
    my $cw= shift ;

    open(POUT,"|$printCmd") or die "Can't open print pipe\n";
    print POUT $cw ->{'label'},"\n\n" 
      if defined $cw ->{'label'} ;
    print POUT $cw->{'textObj'}->get('0.0','end') ;
    close POUT ;
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

- a scrolable read-only text window (based on ROtext)
- 2 buttons ('++' and '--') to resize the window. (I should use packAdjust but I couldn't get it to work well. I may do it later)
- a print button (The shell print command may be modified by setting 
$Tk::Multi::Text::printCmd to the appropriate shell command. By default, it is
set to 'lp -ol70 -otl66 -o12 -olm10') 
- a clear button

This widget will forward all unrecognize commands to the ROtext object.

Note that this widget should be created only by the Multi::Manager. 

=head1 Additional configuration options

=head2 title

Some text which will be displayed above the test window. 

=head2 menu_button

The log window feature a set of menu items which must be added in a menu.
This menu ref must be passed with the menu_button prameter 
to the object during its instaciation

=head1 Additional methods

=head2 setSize( heigth, [ width ])

Will resize the text window. Heigth lower than 5 are ignored.

=head2 insertText($some_text)

Insert the passed string at the bottom of the text window

=head2 print

Print the label and the content of the text window.

=head2 clear

Is just a delete('1.0','end') .

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi(3), Tk::Multi::Manager(3)

=cut
