package MjNCMS::ContentShortlinksSiteWrite;
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
use MjNCMS::ContentShortlinksSiteLibWrite;

########################################################################
#                       ROUTE CONTENT-SIDE CALLS
########################################################################

sub content_rt_shortlink_add_post () {
    
    my $self = shift;
    
    #$SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('urls', 'contentside_add', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'common';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }
    
    my $res = &MjNCMS::ContentShortlinksSiteLibWrite::surl_url_add({
        sugrp_id => scalar $self->param('sugrp_id'),
        alias => scalar $SESSION{'REQ'}->param('alias'),
        original_url => scalar $SESSION{'REQ'}->param('orig_url'),
        
    });

    $TT_CFG{'tt_controller'} = 
        $TT_VARS{'tt_controller'} = 
            'content';
    $TT_CFG{'tt_action'} = 
        $TT_VARS{'tt_action'} = 
            'shortlink_add_result';
    $TT_VARS{'status'} = $res->{'status'};
    $TT_VARS{'message'} = $SESSION{'LOC'}->loc($res->{'message'});
    $TT_VARS{'url_id'} = $res->{'url_id'};
    $TT_VARS{'alias'} = $res->{'alias'};

    $self->render('site_index', format => 'html');

} #-- content_rt_shortlink_add_post

1;
