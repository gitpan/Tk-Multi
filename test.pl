# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib;
use Tk::Multi::Manager;
use Tk::Multi::Text;
use Tk::Multi::Canvas; 
require Tk::ErrorDialog; 
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict ;
my $toto ;
my $omw = MainWindow-> new ;

my $mw = $omw -> 
  Scrolled('Pane', Name => 'multiManager',
           -scrollbars => 'e',
           -height => '500',
           -sticky => 'we'
          ) -> pack (qw/fill x fill y/);

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );
$f->command(-label => 'Quit',  -command => sub{exit;} );

$mw -> Button (text => 'add', command => sub {$toto -> insertText("added\n")} ) 
  -> pack(qw/fill x/) ;

print "creating manager\n";
my $wmgr = $mw -> MultiManager ( 'title' => 'log test' ,
                             'menu' => $w_menu ) -> pack (qw/fill x fill y/);

print "Creating sub window toto\n";
$toto = $wmgr -> newSlave('type'=>'MultiText') ;
print "Creating sub window list\n";
my $list = $wmgr -> newSlave('type'=> 'MultiText', title => 'list',
                            height => '10', data => [1 .. 20] ) ;
$list->command(-label => 'display dummy',  
               -command => sub{$list->insertText("added dummy\n");} );

print "Creating sub window debug\n";
my $debug = $wmgr -> newSlave
  (
   'type'=>'MultiText', 
   'relief' => 'sunken' ,
   title => 'sunken debug',
   'hidden'=> 1, 
   'destroyable' => 1
  ) ;

print "Creating canvas sub window \n";
my $canvas = $wmgr -> newSlave
  (
   'type'=>'MultiCanvas',
   -scrollregion => [0,0,'41c' ,'52c'],
   title => 'draw'
  ) ;
$canvas -> createLine(1,1,'40c','50c', -fill => 'red') ;

$mw -> Button (text => 'destroy list slave', command => 
               sub {$wmgr -> destroySlave('list')} ) 
  -> pack ;

print "print Line try\n" ;
$list -> insertText("Salut les copains\n");

print "insert try\n";
$toto -> insert ('end',"toto is not titi\n");

print "creating 2nd manager without menu\n";

my $wmgr2 = $mw -> MultiManager ( 'title' => 'log test' ) -> pack (qw/fill x/);
my $list2 = $wmgr2 -> newSlave('type'=>'MultiText',) ;
my $list3 = $wmgr2 -> newSlave('type'=>'MultiText', title =>'another list') ;

MainLoop ; # Tk's

