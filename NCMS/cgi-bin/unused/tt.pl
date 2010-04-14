#!/usr/bin/perl

use base 'Locale::Maketext';
use Locale::Maketext::Lexicon;

    Locale::Maketext::Lexicon->import({
			en => [Gettext => 'mjcms_en.po'],
			_auto   => 1,
			_style  => 'gettext',
			_decode => 0,
    });
    
    Locale::Maketext::Lexicon->import({
			ru => [Gettext => 'mjcms_ru.po'],
			_auto   => 1,
			_style  => 'gettext',
			_decode => 0,
        
    });
    
 my $lh = __PACKAGE__ -> get_handle('en');
 
 print $lh;
 
 print $lh->maketext('Hello');
