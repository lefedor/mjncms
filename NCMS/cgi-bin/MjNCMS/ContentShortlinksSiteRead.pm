package MjNCMS::ContentShortlinksSiteRead;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Routes on content-side [Site], Read part
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use base 'Mojolicious::Controller';

use MjNCMS::Config qw/:vars /;

########################################################################
#                       ROUTE CONTENT-SIDE CALLS
########################################################################

sub content_rt_shortlink_add_get () {
    
    my $self = shift;

    #$SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('urls', 'contentside_add', 'r')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'common';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }

    $TT_CFG{'tt_controller'} = 
        $TT_VARS{'tt_controller'} = 
            'content';
    $TT_CFG{'tt_action'} = 
        $TT_VARS{'tt_action'} = 
            'shortlink_add';

    $self->render('site_index', format => 'html');
    
} #-- content_rt_shortlink_add_get

sub content_rt_shortlink_redirect_get () {
    
    my $self = shift;
    
    my $res = &MjNCMS::Content::content_get_short_urls({
        'alias' => scalar $self->param('alias'), 
        'sugrp_id' => scalar $self->param('sugrp_id'), 
    });
    
    if(${$res}{'urls'} && scalar @{${$res}{'urls'}}){
        my $url = pop @{${$res}{'urls'}};
        $SESSION{'REDIR'} = {
            url => $url->{'orig_url'}, 
            no_rnd => 1
        };
        return;
    }
    
    $self->render(text => 'Redirect alias not found');
    
} #-- content_rt_shortlink_redirect_get

1;
