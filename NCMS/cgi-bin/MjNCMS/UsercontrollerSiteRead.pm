package MjNCMS::UsercontrollerSiteRead;
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
#use MjNCMS::UsercontrollerSiteLibRead;
use MjNCMS::UserSiteLibRead;

########################################################################
#                       ROUTE CONTENT-SIDE CALLS
########################################################################

sub usercontroller_rt_user_login_get () {

    my $self = shift;

    unless ($SESSION{'USR'}->chk_access('users', 'auth')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'commmon';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }
    else {
        $SESSION{'PAGE_CACHABLE'} = 1;
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'user';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'login';
    }
    $self->render('site_index', format => 'html');

} #-- usercontroller_rt_user_login_get

sub usercontroller_rt_user_logout_any () {
    
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('users', 'auth', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'common';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('index');
        return;
    }
    
    my $res;
    if (&MjNCMS::UserSiteLibRead::logout()) {
        $res = {
            status => 'ok', 
            message => 'All OK', 
            member_id => $SESSION{'USR'}->{'member_id'}, 
            member_name => $SESSION{'USR'}->{'profile'}->{'member_name'}, 
            
        };
    }
    else {
        $res = {
            status => 'fail', 
            message => 'Logout failed: ' . $SESSION{'USR'}->{'last_state'}, 
            
        };
    }
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = '/' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $SESSION{'LOC'}->loc($res->{'message'}), 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            member_id => $res->{'member_id'}, 
            member_name => $res->{'member_name'}, 
            
        });
    }
    
} #-- usercontroller_rt_user_logout_any

sub usercontroller_rt_user_profile_get () {

    my $self = shift;

    unless ($SESSION{'USR'}->chk_access('users', 'auth')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'commmon';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }
    else {
        $SESSION{'PAGE_CACHABLE'} = 1;
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'user';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'profile';
    }
    $self->render('site_index', format => 'html');

} #-- usercontroller_rt_user_profile_get

sub usercontroller_rt_user_register_get () {

    my $self = shift;

    unless ($SESSION{'USR'}->chk_access('users', 'auth')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'commmon';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }
    else {
        $SESSION{'PAGE_CACHABLE'} = 1;
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'user';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'register';
    }
    $self->render('site_index', format => 'html');

} #-- usercontroller_rt_user_register_get

sub usercontroller_rt_user_confirm_get () {

    my $self = shift;

    unless ($SESSION{'USR'}->chk_access('users', 'auth')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'commmon';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }
    else {
        $SESSION{'PAGE_CACHABLE'} = 1;
        
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'user';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'confirm';

        $TT_VARS{'confirmation_code'} = $self->param('confirmation_code'), 

    }
    $self->render('site_index', format => 'html');

} #-- usercontroller_rt_user_confirm_get

sub usercontroller_rt_user_forgot_password_get () {

    my $self = shift;

    unless ($SESSION{'USR'}->chk_access('users', 'auth')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'commmon';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }
    else {
        $SESSION{'PAGE_CACHABLE'} = 1;
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'user';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'forgot';
    }
    $self->render('site_index', format => 'html');

} #-- usercontroller_rt_user_forgot_password_get

sub usercontroller_rt_user_reconfirm_email_get () {

    my $self = shift;

    unless ($SESSION{'USR'}->chk_access('users', 'auth')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'commmon';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }
    else {
        $SESSION{'PAGE_CACHABLE'} = 1;
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'user';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'reconfirm';
    }
    $self->render('site_index', format => 'html');

} #-- usercontroller_rt_user_reconfirm_email_get

1;
