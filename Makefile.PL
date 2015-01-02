use ExtUtils::MakeMaker;

require 5.008;

eval "use Test::Manifest 1.21";

WriteMakefile(
	'NAME'         => 'Set::CrossProduct',
	'ABSTRACT'     => 'work with the cross product of two or more sets',
	'VERSION_FROM' => 'lib/Set/CrossProduct.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',

	'PREREQ_PM'    => {
		'Test::More' => '0.95',
		},
	
	'EXE_FILES'    => [ qw(script/cross) ],
	
    clean  => { FILES    => q|Set-CrossProduct-*| },
	);
