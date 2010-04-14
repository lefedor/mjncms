#!/usr/bin/perl

use Cache::Memcached::Fast;

my $mm = new Cache::Memcached::Fast({
	servers => [ 
		{ address => 'localhost:11211', weight => 2.5 },

	],
	namespace => '',
	connect_timeout => 0.2,
	io_timeout => 0.5,
	close_on_error => 1,
	compress_threshold => 100_000,
	compress_ratio => 0.9,
	compress_methods => [ 
		\&IO::Compress::Gzip::gzip,
		\&IO::Uncompress::Gunzip::gunzip 
	],
	max_failures => 3,
	failure_timeout => 2,
	ketama_points => 150,
	nowait => 1,
	hash_namespace => 1,
	serialize_methods => [ 
		\&Storable::freeze, 
		\&Storable::thaw 
	],
	utf8 => ($^V ge v5.8.1 ? 1 : 0),
	max_size => 256 * 1024,
});

$mm->set('hhh', {aa=>'bb', cc=>'rr'});


print $mm->get('hhh')->{'cc'};
