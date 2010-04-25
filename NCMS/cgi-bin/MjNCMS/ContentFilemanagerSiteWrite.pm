package MjNCMS::ContentFilemanagerSiteWrite;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Routes on content-side [Site], Write part
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use base 'Mojolicious::Controller';

use MjNCMS::Config qw/:vars /;
#use MjNCMS::Service qw/:subs /;

use MjNCMS::ContentFilemanagerSiteLibWrite;

########################################################################
#                       ROUTE CONTENT-SIDE CALLS
########################################################################

sub content_rt_filemanager_connector_any () {
    my $self = shift;
    my $fm_responce; 
    
    unless ($SESSION{'USR'}->chk_access('filemanager', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }

    $fm_responce = &MjNCMS::ContentFilemanagerSiteLibWrite::fm_getresponce(
        scalar $SESSION{'REQ'}->param('action'), 
        scalar $SESSION{'REQ'}->param('filemanager_id'),
    );
    
    $fm_responce = {
        status => 'fail',
        message => 'unknown error on server side',
    } unless defined $fm_responce;
    
    if (ref $fm_responce && ref $fm_responce eq 'HASH') {
        $$fm_responce{'filemanager_id'} = $SESSION{'REQ'}->param('filemanager_id');
        $self->render_json($fm_responce);
    }
    else{
        $self->render_text($fm_responce);
    }
    
    return;
    
} #-- content_filemanager_connector_any

1;
