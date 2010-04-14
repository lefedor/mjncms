#!/usr/bin/env perl

use common::sense;

use locale;
use POSIX qw(locale_h );
use lib qw(./ );

#use Mojolicious::Lite; # 'app', 'post', 'get', 'any', 'shagadelic' is exported
use base qw/Locale::Maketext /;
use Locale::Maketext::Lexicon;

Locale::Maketext::Lexicon->import({
		ru => [Gettext => 't.po'],
		_auto   => 1,
		_style  => 'gettext',
		_decode => 0,
});

my $lh = __PACKAGE__ -> get_handle('ru');

#print $lh;

print $lh->maketext('Hello');
