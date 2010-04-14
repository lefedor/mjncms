#!/usr/bin/env perl
#Test
use Mojo::Cookie::Response;
use Mojo::ByteStream b;
use CGI::Util;

my $str = 'aaaa;bbbb';
	
	my $tcookie = Mojo::Cookie::Response->new;
	$tcookie->name('test_cookie');
	$tcookie->path('/');
	$tcookie->expires();
	$tcookie->value($str);

print "1 (wrong - ';'): ".($tcookie->to_string)."\n";


	my $str2 = CGI::Util::escape($str);
	$tcookie = Mojo::Cookie::Response->new;
	$tcookie->name('test_cookie');
	$tcookie->path('/');
	$tcookie->expires();
	$tcookie->value($str2);

print "2: ".($tcookie->to_string)."\n";


	my $str3 = b($str)->url_escape;	
	$tcookie = Mojo::Cookie::Response->new;
	$tcookie->name('test_cookie');
	$tcookie->path('/');
	$tcookie->expires();
	$tcookie->value($str3);

print "2: ".($tcookie->to_string)."\n";
