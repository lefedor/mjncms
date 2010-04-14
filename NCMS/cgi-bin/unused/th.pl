#!/usr/bin/env perl

use Mojolicious::Lite; # 'app', 'post', 'get', 'any', 'shagadelic' is exported

ladder sub {
	my $self = shift;
	open F, '>headertest';
	print F $self->tx->req->headers->header('User-Agent');#somewhy it returns ref=ARRAY
	print F "\nyarr\n";
	print F ''.$self->tx->req->headers->header('User-Agent');#this is OK
	close F;
};

any '/' => sub {
	my $self = shift;
	$self->render(text => 'Test');
};

if (scalar @ARGV){
	#if command line params is set
	shagadelic();
}
else {
	#example of out-of-box start ready settings
	#shagadelic('fcgi_prefork', 
	#shagadelic('fastcgi', 
	#shagadelic('fcgi', 
	shagadelic('daemon', 
		#'--daemonize'
		#'--listen', 'mojotest:3042', 
		#'--start', '4', 
		#'--minspare', '4',
		#'--maxspare', '10'
	);
}
