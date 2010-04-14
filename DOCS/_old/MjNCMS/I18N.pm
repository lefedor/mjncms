package MjNCMS::I18N;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010

#
# Bender: That galaxy is signaling in binary. I should signal back, but I only know enough binary to ask where the bathroom is. 
#
# (c) Futurama
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use base qw/Locale::Maketext /;
#require Locale::Maketext::Lexicon;
use Locale::Maketext::Lexicon {
	#_auto   => 1,
	_style  => 'gettext',
	#_preload => 1,
	_decode => 1,#this do not fucking work (, using bytestream ->decode('UTF-8')->to_string()
	_encoding => 'utf-8',
};

#use encoding ':locale';

sub loc($$;$) {
	my $self = shift;
	#we're expecting phrases in EN as key
	#if text not exist, push it into memd cache for locating && translating later
	#over web ui or smth else: phrases are @
	#$SESSION{'MEMD'}->get('untrans_hash')->{$SESSION{'SERVER_URL'}}->{'phrase_md5sum'} = 'phrase';
	my ($trans_text, $curr_enc);
	if ($_[1]) {
		$curr_enc = $self->{'CURRLANG'};
		$self -> set_lang($_[1]);
	}
	
	$trans_text = '';
	eval{
		$trans_text = $self->{'LH'}->maketext($_[0]);
	};
	#if ($@) {&t_of($@);}
	
	if ($_[1]) {
		$self -> set_lang($curr_enc);
	}

    #when i save2file it's alredy utf, wtf :)?
    #return $SESSION{'BS'}($trans_text) if $trans_text;
    return $SESSION{'BS'}($trans_text)->decode('UTF-8')->to_string() if $trans_text;
    
    #no translation exists situation
    my ($untrans_hash, $md5_sum);
    if($SESSION{'MEMC_UNTRANS_STRS'} && $SESSION{'MEMD'}){
		$untrans_hash = $SESSION{'MEMD'}->get('untrans_hash');
		$untrans_hash = {} unless $untrans_hash;
		${$untrans_hash}{$SESSION{'SERVER_URL'}} = {} unless defined(${$untrans_hash}{$SESSION{'SERVER_URL'}});
		${$untrans_hash}{$SESSION{'SERVER_URL'}}{$self->{'CURRLANG'}} = {} unless defined(${$untrans_hash}{$SESSION{'SERVER_URL'}}{$self->{'CURRLANG'}});
		unless(defined(${$untrans_hash}{$SESSION{'SERVER_URL'}}{$self->{'CURRLANG'}}{$md5_sum = $SESSION{'BS'}($_[0])->md5_sum()->to_string()})){
			${$untrans_hash}{$SESSION{'SERVER_URL'}}{$self->{'CURRLANG'}}{$md5_sum} = $_[0];
			$SESSION{'MEMD'}->set('untrans_hash', $untrans_hash);
		}
	}
    return $_[0];
}

sub set_lang($$) { 
	my $self = $_[0];
	
	return undef unless ${$self->{'ACTIVE_LANGS'}}{$_[1]};#is @init?
	
	$self->{'CURRLANG'} = $_[1];
    $self->{'LH'} = __PACKAGE__ -> get_handle($_[1]);
    return 1;
} #-- set_lang

sub init_langs($$) {
    my $self = shift;
    my $lang_list = shift;
    return undef unless ($lang_list && ref $lang_list && ref $lang_list eq 'HASH' && scalar keys %{$lang_list});
	
	$self->{'ACTIVE_LANGS'} = {%{$lang_list}};
	
    foreach my $lang (keys %{$self->{'ACTIVE_LANGS'}}){
		Locale::Maketext::Lexicon->import({
			$lang => [ Gettext => ${$lang_list}{$lang}{'path'} ],
		});
	}

	return $self->set_lang($SESSION{'SITE_LANG_DEFT'});
} #-- init_langs

sub get_langs_list($) {
	my $self = shift;
	
	return $self->{'ACTIVE_LANGS'};
} #-- get_langs_list

sub get_date_fullmsk_sql($$) { 
	my $self = $_[0];
	#$self->{'CURRLANG'} = $_[1];

    return 1;
} #-- set_lang

sub get_dt_fmt () {
	#get current date+time fmt
	my $self = $_[0];
	my $lang = $self->{'CURRLANG'};
	
	return undef unless $lang;
	return ${$self->{'ACTIVE_LANGS'}}{$lang}{'date_fmt_full'} . 
		' ' . ${$self->{'ACTIVE_LANGS'}}{$lang}{'date_fmt_hrs'};
} #-- get_dt_fmt

sub get_d_fmt () {
	#get current date+time fmt
	my $self = $_[0];
	my $lang = $self->{'CURRLANG'};
	
	return undef unless $lang;
	return ${$self->{'ACTIVE_LANGS'}}{$lang}{'date_fmt_full'};
} #-- get_d_fmt

sub get_t_fmt () {
	#get current date+time fmt
	my $self = $_[0];
	my $lang = $self->{'CURRLANG'};
	
	return undef unless $lang;
	return ${$self->{'ACTIVE_LANGS'}}{$lang}{'date_fmt_hrs'};
} #-- get_t_fmt

sub get_mdt_fmt () {
	#get current date+time fmt
	my $self = $_[0];
	my $lang = $self->{'CURRLANG'};
	return undef unless $lang;
	return ${$self->{'ACTIVE_LANGS'}}{$lang}{'date_mfmt_full'} . 
		' ' . ${$self->{'ACTIVE_LANGS'}}{$lang}{'date_mfmt_hrs'};
} #-- get_mdt_fmt

sub get_md_fmt () {
	#get current date+time fmt
	my $self = $_[0];
	my $lang = $self->{'CURRLANG'};
	
	return undef unless $lang;
	return ${$self->{'ACTIVE_LANGS'}}{$lang}{'date_mfmt_full'};
} #-- get_md_fmt

sub get_mt_fmt () {
	#get current date+time fmt
	my $self = $_[0];
	my $lang = $self->{'CURRLANG'};
	
	return undef unless $lang;
	return ${$self->{'ACTIVE_LANGS'}}{$lang}{'date_mfmt_hrs'};
} #-- get_mt_fmt

1;
