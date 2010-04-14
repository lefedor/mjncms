package MjTestBase;

use Mojolicious::Lite;

use MjTestBase::test;

ladder sub {
	my $self = shift;

	$self->app->renderer->root('./my_tpls/');
};

get '/' => sub {
	my $self = shift;
	$self->render('helloroot');
};

if (scalar @ARGV){
	#if command line params is set
	shagadelic();
}
else {
	#example of out-of-box start ready settings
	shagadelic('fcgi_prefork', 
	#shagadelic('fastcgi', 
	#shagadelic('fcgi', 
	#shagadelic('daemon', 
		#'--daemonize'
		'--listen', 'mojotest:3042', 
		'--start', '4', 
		'--minspare', '4',
		'--maxspare', '10'
	);
}
