use ExtUtils::MakeMaker;

require 5.006;

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'         => 'Set::CrossProduct',
	'ABSTRACT'     => 'work with the cross product of two or more sets',
	'VERSION_FROM' => 'lib/CrossProduct.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',

 	'PM'           => {
		'lib/CrossProduct.pm'=> '$(INST_LIBDIR)/CrossProduct.pm',
		},

	'PREREQ_PM'    => {
		'Test::More' => '0',
		},
	
	'EXE_FILES'    => [ qw(script/cross) ],
	
	'MAN3PODS'     => {
		'lib/CrossProduct.pm' => '$(INST_MAN3DIR)/Set::CrossProduct.3',
		},

	'dist'         => {
		'COMPRESS'        => 'gzip -9f',
		'SUFFIX'          => 'gz',
		},

    clean  => { FILES    => q|Set-CrossProduct-*| },

);
