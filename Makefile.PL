use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              'NAME'	   => 'Tk::Multi',
              'VERSION' => '0.71',
              'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
              'PREREQ_PM' =>
              {
               'Tk' => 0
              }
             );
