package MjNCMS::Translations;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Zoyberg: Now open your mouth and lets have a look at that brain.
# 
# Bender: 001100010010011110100001101101110011
#
# (c) Futurama
#

use common::sense;
use base 'Mojolicious::Controller';

use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

########################################################################
#                           ROUTE CALLS
########################################################################

sub translations_rt_poollist_get () {
    my $self = shift;

    unless ($SESSION{'USR'}->chk_access('translations', 'manage')) {
        $SESSION{'PAGE_CACHABLE'} = 1;
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'translations_poollist';
        $TT_CALLS{'translations_poollist_get'} = \&MjNCMS::Translations::translations_poollist_get;
    }
    $self->render('admin/admin_index');

} #-- translations_rt_poollist_get

sub translations_rt_set_strings_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('translations', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'translations_set_strings';
        $TT_VARS{'lang'} = $self -> param('lang');
        $TT_VARS{'cnt'} = $MULTISESSION{'cnt'};
        $TT_CALLS{'translations_poollist_get'} = \&MjNCMS::Translations::translations_poollist_get;
    }
    $self->render('admin/admin_index');
} #-- translations_rt_set_strings_get

sub translations_rt_set_strings_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('translations', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my %src_strings = &get_suffixed_params('src_', 'A-Za-z0-9');
    my %trans_strings = &get_suffixed_params('trans_', 'A-Za-z0-9');
    my $res = &MjNCMS::Translations::set_strings({
        origs => \%src_strings, 
        transes => \%trans_strings, 
        lang => scalar $self->param('lang'), 
        
    });

    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/translations' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            lang => scalar $self->param('lang'), 
        });
    }

} #-- translations_rt_set_strings_post

sub translations_rt_clear_cache_get () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('translations', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Translations::translations_clear_cache(scalar $self->param('lang'));
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/translations' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            lang => scalar $self->param('lang'), 
        });
    }
} #-- translations_rt_clear_cache_get

########################################################################
#                           INTERNAL SUBS
########################################################################

sub translations_poollist_get () {
    return {
        status => 'fail', 
        message => 'MEMD || untranslated strings store disabled', 
    } unless ($SESSION{'MEMC_UNTRANS_STRS'} && $SESSION{'MEMD'});
    
    my %strings;
    my $untrans_hash = $SESSION{'MEMD'}->get('untrans_hash');
    
    return {} unless ${$untrans_hash}{$SESSION{'SERVER_URL'}} && 
        ref ${$untrans_hash}{$SESSION{'SERVER_URL'}} && 
            ref ${$untrans_hash}{$SESSION{'SERVER_URL'}} eq 'HASH';
    
    foreach my $lang (keys %{${$untrans_hash}{$SESSION{'SERVER_URL'}}}) {
        $strings{$lang} = [];
        foreach my $md5_sum (
            sort {
                ${$untrans_hash}{$SESSION{'SERVER_URL'}}{$lang}{$a} cmp ${$untrans_hash}{$SESSION{'SERVER_URL'}}{$lang}{$b}
            } keys %{${$untrans_hash}{$SESSION{'SERVER_URL'}}{$lang}}
        ) {
            push @{$strings{$lang}}, {
                    md5_sum => $md5_sum, 
                    string => ${$untrans_hash}{$SESSION{'SERVER_URL'}}{$lang}{$md5_sum}, 
                    
            };
        }
    }
    
    return \%strings;
} #-- translations_poollist_get

sub set_strings () {
    
    my $cfg = shift;
    my (
        $untrans_hash, $langfile_path, 
        $src, $trans, $dump, 
    );
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } unless (
        ${$cfg}{'lang'} && 
        &inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 

    return {
            status => 'fail', 
            message => 'no orig/transes input', 
    } unless (
        ${$cfg}{'origs'} && 
            ref ${$cfg}{'origs'} && 
                ref ${$cfg}{'origs'} eq 'HASH' && 
        ${$cfg}{'transes'} && 
            ref ${$cfg}{'transes'} && 
                ref ${$cfg}{'transes'} eq 'HASH' && 
        scalar keys %{${$cfg}{'origs'}} == scalar keys %{${$cfg}{'transes'}} 
    );
    
    return {
        status => 'fail', 
        message => 'MEMD || untranslated strings store disabled', 
    } unless ($SESSION{'MEMC_UNTRANS_STRS'} && $SESSION{'MEMD'});
    
    $untrans_hash = $SESSION{'MEMD'}->get('untrans_hash');
    
    return {} unless ${$untrans_hash}{$SESSION{'SERVER_URL'}} && 
        ref ${$untrans_hash}{$SESSION{'SERVER_URL'}} && 
            ref ${$untrans_hash}{$SESSION{'SERVER_URL'}} eq 'HASH' && 
                ${$untrans_hash}{$SESSION{'SERVER_URL'}}{${$cfg}{'lang'}} && 
                    ref ${$untrans_hash}{$SESSION{'SERVER_URL'}}{${$cfg}{'lang'}} && 
                        ref ${$untrans_hash}{$SESSION{'SERVER_URL'}}{${$cfg}{'lang'}} eq 'HASH';
    
    $langfile_path = 'MjNCMS/I18N/' . ${$cfg}{'lang'} . '.pm';

    return {
        status => 'fail', 
        message => 'Lang file not found', 
    } unless (-e $langfile_path);
    
    $dump = '';
    foreach my $md5_sum (keys %{${$cfg}{'transes'}}) {
        
        next unless ${${$cfg}{'transes'}}{$md5_sum} && length ${${$cfg}{'transes'}}{$md5_sum};
        
        if (${$untrans_hash}{$SESSION{'SERVER_URL'}}{${$cfg}{'lang'}}{$md5_sum}) {
            $src = ${$untrans_hash}{$SESSION{'SERVER_URL'}}{${$cfg}{'lang'}}{$md5_sum};
            $trans = ${${$cfg}{'transes'}}{$md5_sum};
            $src = $SESSION{'BS'}($src)->quote()->to_string();
            $trans = $SESSION{'BS'}($trans)->quote->to_string();
            $dump = 
                "\t" . $src . " => \n" . 
                "\t\t" . $trans . ", \n" ;
            delete ${$untrans_hash}{$SESSION{'SERVER_URL'}}{${$cfg}{'lang'}}{$md5_sum};
        }
        
    }
    
    $SESSION{'MEMD'}->set('untrans_hash', $untrans_hash);
    
    if ($dump) {
        $dump = qq~

#
\%Lexicon = (\%Lexicon ,
~ . $dump . qq~);

1;
~;
        open (TF, ">>$langfile_path");
        print TF $dump;
        close TF;
    }
    
    return {
        status => 'ok', 
        message => 'All ok, but restart required', 
        lang => ${$cfg}{'lang'}, 
    };
    
} #-- set_strings

sub translations_clear_cache ($) {
    return {
        status => 'fail', 
        message => 'MEMD || untranslated strings store disabled', 
    } unless ($SESSION{'MEMC_UNTRANS_STRS'} && $SESSION{'MEMD'});

    my $lang = shift;
    
    return {
        status => 'fail', 
        message => 'MEMD || untranslated strings store disabled', 
    } unless $lang =~ /^\w{2,4}$/;
    
    my $untrans_hash = $SESSION{'MEMD'}->get('untrans_hash');
    ${$untrans_hash}{$SESSION{'SERVER_URL'}}{$lang} = {};
    
    $SESSION{'MEMD'}->set('untrans_hash', $untrans_hash);
    
    return {
        status => 'ok', 
        message => 'All OK', 
    };
    
}

1;
