package MjNCMS::MjI18N;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Bender: That galaxy is signaling in binary. I should signal back, but I only know enough binary to ask where the bathroom is. 
#
# Fry: I bet Leela's holding out for a nice guy with one eye.
# Bender: That'll take forever, what she oughtta do is find a nice guy with two eyes and poke one out.
# Fry: Yeah that'd be a time saver.
#
# Zapp Branigan: This time we are shure that she is woman, right? -Yes.. - Invite her in my quarters.
#
# (c) Futurama
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use locale;
use POSIX qw/locale_h /;

sub new ($$) {
    my $self = {}; shift;
    $self->{'MOJO_CONTROLLER'} = shift;
    
    return undef unless $self->{'MOJO_CONTROLLER'};
    
    bless $self;
    return $self
}

sub loc($$;$) {
    my $self = shift;
    #we're expecting phrases in EN as key
    #if text not exist, push it into memd cache for locating && translating later
    #over web ui or smth else: phrases are @
    #$SESSION{'MEMD'}->get('untrans_hash')->{$SESSION{'SERVER_URL'}}->{'parse_str_md5sum'} = 'parse str';
    my (@to_trans, $trans_text, $curr_enc);
    
    if ($_[1]) {
        $curr_enc = $self->{'CURRLANG'};
        $self -> set_lang($_[1]);
    }
    
    $trans_text = '';
    unless (ref $_[0]) {
        push @to_trans, $_[0];
    }
    elsif (ref $_[0] && ref $_[0] eq 'ARRAY') {
        @to_trans = @{$_[0]};
    }
    else{
        return $_[0];
    }
    eval {
        $trans_text = $self->{'MOJO_CONTROLLER'}->stash->{'i18n'}->localize(@to_trans);
    };
    #if ($@) {&t_of($@);}
    
    if ($_[1]) {
        $self -> set_lang($curr_enc);
    }

    #return $trans_text if $trans_text;
    return $SESSION{'BS'}($trans_text)->decode('UTF-8')->to_string() if $trans_text;
    
    #no translation exists situation
    my ($untrans_hash, $md5_sum);
    if($SESSION{'MEMC_UNTRANS_STRS'} && $SESSION{'MEMD'}){
        $untrans_hash = $SESSION{'MEMD'}->get('untrans_hash');
        $untrans_hash = {} unless $untrans_hash;
        ${$untrans_hash}{$SESSION{'SERVER_URL'}} = {} unless defined(${$untrans_hash}{$SESSION{'SERVER_URL'}});
        ${$untrans_hash}{$SESSION{'SERVER_URL'}}{$self->{'CURRLANG'}} = {} unless defined(${$untrans_hash}{$SESSION{'SERVER_URL'}}{$self->{'CURRLANG'}});
        foreach my $transfail_str (@to_trans){
            unless(defined(${$untrans_hash}{$SESSION{'SERVER_URL'}}{$self->{'CURRLANG'}}{$md5_sum = $SESSION{'BS'}($transfail_str)->md5_sum()->to_string()})){
                ${$untrans_hash}{$SESSION{'SERVER_URL'}}{$self->{'CURRLANG'}}{$md5_sum} = $transfail_str;
            }
        }
        $SESSION{'MEMD'}->set('untrans_hash', $untrans_hash);
    }
    return join ' ', @to_trans;
}

sub set_lang($$) { 
    
    #
    # Morbo: Kittens gives morbo gas...
    #
    
    my $self = $_[0];
    my $locale;

    return undef unless ${$self->{'ACTIVE_LANGS'}}{$_[1]};#is @init?
    
    $self->{'CURRLANG'} = $_[1];
    $self->{'MOJO_CONTROLLER'}->stash->{'i18n'}->languages($_[1]);

    $locale = ${$self->{'ACTIVE_LANGS'}}{$_[1]}{'locale'} || $SESSION{'SITE_LOCALE'} || 'en_US.UTF-8';
            
    eval {
        setlocale(LC_CTYPE, $locale);
        setlocale(LC_ALL, $locale);
    } if $locale;
    
    return 1;
} #-- set_lang

sub init_langs($$) {
    my $self = shift;
    my $lang_list = shift;
    return undef unless ($lang_list && ref $lang_list && ref $lang_list eq 'HASH' && scalar keys %{$lang_list});
    
    $self->{'ACTIVE_LANGS'} = {%{$lang_list}};
    
    return $self->set_lang($SESSION{'SITE_LANG_DEFT'});
} #-- init_langs

sub get_langs_list($) {
    my $self = shift;
    
    return $self->{'ACTIVE_LANGS'};
} #-- get_langs_list

sub get_date_fullmsk_sql($$) { 
    my $self = $_[0];
    #$self->{'CURRLANG'} = $_[1];
    #here should be smth or whattf ?
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
