use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'         => 'Set::CrossProduct',
	'VERSION_FROM' => 'CrossProduct.pm',

	'PREREQ_PM'    => {
		'Test::More' => '0',
		},
		
	'MAN3PODS'     => {
		'CrossProduct.pm' => '$(INST_MAN3DIR)/Set::CrossProduct.3',
		},

	'dist'         => {
		'COMPRESS'        => 'gzip -9f',
		'SUFFIX'          => 'gz',
		},

    clean  => { FILES    => q|Set-CrossProduct-*| },

);
