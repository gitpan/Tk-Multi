use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              'NAME'	   => 'Tk::Multi',
              'VERSION' => '0.73',
              'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
              ($] >= 5.005 ?
               (ABSTRACT   => 'Manages several Text or Canvas widgets',
                AUTHOR     => 'Dominique Dumont (domi@barrayar.grenoble.hp.com)') : ()),
              'PREREQ_PM' =>
              {
               'Tk' => 0
              }
             );
