package Tk::Multi::Text ;

use strict;
require Tk::Multi::Any;
require Tk::Derived;

use vars qw(@ISA $printCmd $defaultPrintCmd $VERSION);

@ISA = qw(Tk::Derived Tk::Multi::Any);

$VERSION = substr q$Revision: 1.8 $, 10;

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

    $cw->{_printCmdRef} = \$printCmd ;
    $args->{_resize_amount} = 5 ;
    $cw->{minWidth} = 40 ;
    $cw->{minHeight} = 4 ;

    my $data = delete $args->{'data'} || delete $args->{'-data'} ;

#    my $slaveWindow = $args->{_slave} = $cw -> 
#      Scrolled('ROText',
 #              -scrollbars => 'oe',
    $args->{_slave} = [qw/ROText relief sunken bd 2 setgrid true height 5/];

    $cw-> SUPER::Populate($args);

    if (defined $data)
      {
        $cw-> insertText (@$data) ;
      }
    
    $cw->yview('moveto', 1) ; # move diplay to the end

  }    

sub insertText
  {
    my $cw= shift ;
    
    foreach (@_)
      {
        $cw->insert('end',$_) ;
      }
    $cw->yview('moveto', 1) ;
  }


sub clear 
  {
    my $cw= shift ;
    
    $cw->delete('1.0','end') ;
  }

sub resetPrintCmd
  {
    my $cw=shift ;
    $printCmd=$defaultPrintCmd ;
  }

sub printableDump
  {
    my $cw= shift ;
    return $cw->get('0.0','end') ;
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

2 buttons on the left side of the widget to resize height of the window. 
(I should use packAdjust but I couldn't get it to work well. I may do it later)

=item *

A print button (The shell print command may be modified by setting 
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

=head2 data

A string which will be displayed in the text window.

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

Print the title and the content of the text window. The print is invoked
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

=head1 Delegated methods

By default all widget method are delegated to the Text widget. Excepted :

=head2 command(-label => 'some text', -command => sub {...} )

Delegated to the menu entry managed by Multi::Manager. Will add a new command
to the aforementionned menu.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1997-1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi(3), Tk::Multi::Manager(3)

=cut
