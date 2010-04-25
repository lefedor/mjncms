package MjNCMS::UsercontrollerSiteWrite;
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
use MjNCMS::Service qw/:subs /;

use MjNCMS::UsercontrollerSiteLibWrite;

use MjNCMS::UserSiteLibAny qw/:subs /;
use MjNCMS::UserSiteLibWrite;

########################################################################
#                       ROUTE CONTENT-SIDE CALLS
########################################################################

sub usercontroller_rt_user_login_post () {

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
    if ( 
        $SESSION{'CAPTCHA'} && 
        !$SESSION{'CAPTCHA'}->{'check_mjcaptcha'}()
    ) {
        $res = {
            status => 'fail', 
            message => 'Captcha do not match', 
        }
    }
    
    unless ($res) {
        if (&MjNCMS::UserSiteLibWrite::login({
            login => scalar $SESSION{'REQ'}->param('user'), 
            password => scalar $SESSION{'REQ'}->param('passwrd'), 
            passhsh => scalar $SESSION{'REQ'}->param('hash_passwrd'), 
            cookielength => scalar $SESSION{'REQ'}->param('cookielength'), 
            rememberme => scalar $SESSION{'REQ'}->param('rememberme'), 
        })) {
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
                message => 'Auth failed: ' . $SESSION{'USR'}->{'last_state'}, 
                
            };
        }
    }
    
    unless ($SESSION{'REQ_ISAJAX'}) {
        
        if ($SESSION{'REFERER'}) {
            $$res{'url'} = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $$res{'url'} = $SESSION{'HTTP_REFERER'};
        }
        else {
            $$res{'url'} = $SESSION{'USR'}->{'profile'}->{'startpage'};
        }
        $$res{'url'} = '/' unless $$res{'url'};
        
        $SESSION{'REDIR'} = {
            url => $$res{'url'}, 
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
    
} #-- usercontroller_rt_user_login_post

sub usercontroller_rt_user_rolesw_post () {
    
    my $self = shift;   
    
    $self->render(text => 'Disabled @ config')
        unless $SESSION{'ALLOW_SW_AWPROLES'};
    
    #have roles - can switch
    #unless ($SESSION{'USR'}->chk_access('users', 'switch_role', 'w')) {
    #    $TT_CFG{'tt_controller'} = 
    #        $TT_VARS{'tt_controller'} = 
    #            'commmon';
    #    $TT_CFG{'tt_action'} = 
    #        $TT_VARS{'tt_action'} = 
    #            'no_access_perm';
    #    $self->render('site_index', format => 'html');
    #    return;
    #}

    unless (
        $SESSION{'USR'}->{'member_id'} && 
        $SESSION{'USR'}->{'role_id'}
    ) {#not for guests
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'commmon';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }
    
    my (
        $dbh, $role_id, 
        $q, $res, $sth, 
        $updcnt, 
        
    ) = (
        $SESSION{'DBH'}, 
        scalar $SESSION{'REQ'}->param('ridsw'), 
    );
    
    unless (
        $role_id && #Still no guests
        $role_id =~ /^\d+$/ && 
        &inarray(
            $SESSION{'USR'}->{'role_alternatives_ids'}, 
            $role_id 
        )
    ) {
        $role_id = undef;
        $res = {
            status => 'fail', 
            message => 'You not allowed switch to selected role', 
            
        };
    }
    elsif ($SESSION{'USR'}->{'role_id'} == $role_id) {
        $res = {
            status => 'fail', 
            message => 'You\'ve selected current role', 
            
        };
    }
    else {
        
        $q = qq~
            UPDATE 
            ${SESSION{PREFIX}}users 
            SET 
                role_id = ~ . ($dbh->quote($role_id)) . qq~ 
            WHERE 
                member_id = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~ 
            ;
        ~;
        eval {
            $updcnt = $dbh->do($q);
        };

        $res = {
            status => 'fail', 
            message => 'sql upd into users entry fail', 
        } unless scalar $updcnt;
        
        $res = {
            status => 'ok', 
            message => 'Role switched', 
        }
        
    }
    
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $$res{'url'} = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $$res{'url'} = $SESSION{'HTTP_REFERER'};
        }
        else {
            $$res{'url'} = $SESSION{'USR'}->{'profile'}->{'startpage'};
        }
        $$res{'url'} = '/mjadmin' unless $$res{'url'};
        
        $SESSION{'REDIR'} = {
            url => $$res{'url'}, 
            msg => $SESSION{'LOC'}->loc($res->{'message'}), 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            role_id => $role_id, 
            
        });
    }

} #-- usercontroller_rt_user_rolesw_post

sub usercontroller_rt_user_usersw_post () {

    my $self = shift;

    $self->render(text => 'Disabled @ config')
        unless $SESSION{'ALLOW_SW_TOSLAVEUSERS'};
    
    #have users - can switch
    #unless ($SESSION{'USR'}->chk_access('users', 'switch_user', 'w')) {
    #    $TT_CFG{'tt_controller'} = 
    #        $TT_VARS{'tt_controller'} = 
    #            'commmon';
    #    $TT_CFG{'tt_action'} = 
    #        $TT_VARS{'tt_action'} = 
    #            'no_access_perm';
    #    $self->render('site_index', format => 'html');
    #    return;
    #}

    unless (
        $SESSION{'USR'}->{'member_id'} && 
        $SESSION{'USR'}->{'role_id'}
    ) {#not for guests
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'commmon';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('site_index', format => 'html');
        return;
    }
    
    my (
        $dbh, $replace_member_id, 
        $q, $res, $sth, 
        $updcnt, 
        
    ) = (
        $SESSION{'DBH'}, 
        scalar $SESSION{'REQ'}->param('midsw'), 
    );
    
    unless (
        $replace_member_id && #Still no guests
        $replace_member_id =~ /^\d+$/ && 
        &inarray(
            $SESSION{'USR'}->{'slave_users_ids'}, 
            $replace_member_id 
        )
    ) {
        $replace_member_id = undef;
        $res = {
            status => 'fail', 
            message => 'You not allowed switch to selected user',
            
        };
    }
    elsif (
        $replace_member_id == $SESSION{'USR'}->{'member_id'}
    ) {
        $res = {
            status => 'fail', 
            message => 'You\'ve selected current user', 
            
        };
    }
    else {
        #we update original user, so 'member_id_real' is must
        
        $replace_member_id = undef 
            if $replace_member_id == $SESSION{'USR'}->{'member_id_real'};
        
        $q = qq~
            UPDATE 
            ${SESSION{PREFIX}}users 
            SET 
                replace_member_id = ~ . ($dbh->quote($replace_member_id)) . qq~ 
            WHERE 
                member_id = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~ 
            ;
        ~;
        eval {
            $updcnt = $dbh->do($q);
        };

        $res = {
            status => 'fail', 
            message => 'sql upd into users entry fail', 
        } unless scalar $updcnt;
        
        $res = {
            status => 'ok', 
            message => 'User switched', 
        }
        
    }
    
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $$res{'url'} = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $$res{'url'} = $SESSION{'HTTP_REFERER'};
        }
        else {
            $$res{'url'} = $SESSION{'USR'}->{'profile'}->{'startpage'};
        }
        $$res{'url'} = '/mjadmin' unless $$res{'url'};
        
        $SESSION{'REDIR'} = {
            url => $$res{'url'}, 
            msg => $SESSION{'LOC'}->loc($res->{'message'}), 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            member_id => $replace_member_id, 
            
        });
    }

} #-- usercontroller_rt_user_usersw_post

sub usercontroller_rt_user_profile_post () {

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
    
    my (
        $dbh, $q, $updcnt, 
        $res, 
        
    ) = (
        $SESSION{'DBH'}, 
    );
        
    #unless ($res) {
        unless (
            &chk_pass(
                scalar $SESSION{'REQ'}->param('usr_pass'), 
            )
        ) {
            $res = {
                status => 'fail', 
                message => 'old password is not correct', 
            }
        }
    #}

    unless ($res) {
        if (
            (scalar $SESSION{'REQ'}->param('usr_lang')) && 
            !&inarray([keys %{$SESSION{'SITE_LANGS'}}], scalar $SESSION{'REQ'}->param('usr_lang'))
        ) {
            $res = {
                status => 'fail', 
                message => 'lang unknown', 
            };
        }
    }
    
    unless ($res) {
        if (
            scalar $SESSION{'REQ'}->param('new_usr_pass') 
        ) {
            unless (
                &MjNCMS::UserSiteLibWrite::change_password(
                    scalar $SESSION{'REQ'}->param('new_usr_pass'), 
                    scalar $SESSION{'REQ'}->param('new_usr_pass_retype'),
                    $SESSION{'USR'}->{'member_id'}
                )
            ) {
                $res = {
                    status => 'fail', 
                    message => 'pass did not changed', 
                };
            }
        }
    }
    
    unless ($res) {
        if (
            scalar $SESSION{'REQ'}->param('new_usr_email') && 
            scalar $SESSION{'REQ'}->param('new_usr_email') ne 
            $SESSION{'USR'}->{'profile'}->{'member_email'}
        ) {
            unless (
                &MjNCMS::UserSiteLibWrite::change_email(
                    scalar $SESSION{'REQ'}->param('new_usr_email'),
                    $SESSION{'USR'}->{'member_id'}
                )
            ) {
                $res = {
                    status => 'fail', 
                    message => 'email did not changed', 
                };
            }
        }
    }
    
    unless ($res) {
        if (
            (scalar $SESSION{'REQ'}->param('new_usr_lang')) && 
            !&inarray([keys %{$SESSION{'SITE_LANGS'}}], scalar $SESSION{'REQ'}->param('new_usr_lang'))
        ) {
            $res = {
                status => 'fail', 
                message => 'lang unknown', 
            };
        }
    }
    
    unless ($res) {
        unless (
            scalar $SESSION{'REQ'}->param('new_usr_name')
        ) {
            $res = {
                status => 'fail', 
                message => 'name chk fail', 
            };
        }
    }
    
    unless ($res) {
        if (
            scalar $SESSION{'REQ'}->param('new_usr_name') ne 
                $SESSION{'USR'}->{'profile'}->{'member_name'} || 
            scalar $SESSION{'REQ'}->param('new_usr_lang') ne 
                $SESSION{'USR'}->{'profile'}->{'member_lang'}
        ) {
                
            $q = qq~
                UPDATE 
                ${SESSION{PREFIX}}users 
                SET 
                    name = ~ . ($dbh->quote(scalar $SESSION{'REQ'}->param('new_usr_name'))) . qq~, 
                    site_lng = ~ . ($dbh->quote(scalar $SESSION{'REQ'}->param('new_usr_lang'))) . qq~ 
                WHERE 
                    member_id = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~ 
                ;
            ~;
            eval {
                $updcnt = $dbh->do($q);
            };

            $res = {
                status => 'fail', 
                message => 'sql upd into users entry fail', 
            } unless scalar $updcnt;
            
            $res = {
                status => 'ok', 
                message => 'All OK', 
            }
        }
        else {
            $res = {
                status => 'ok', 
                message => 'All OK', 
            }
        }
    }
    
    unless ($SESSION{'REQ_ISAJAX'}) {
        
        if ($SESSION{'REFERER'}) {
            $$res{'url'} = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $$res{'url'} = $SESSION{'HTTP_REFERER'};
        }
        else {
            $$res{'url'} = $SESSION{'USR'}->{'profile'}->{'startpage'};
        }
        $$res{'url'} = $SESSION{'USR_URL'}.'/profile' unless $$res{'url'};
        
        $SESSION{'REDIR'} = {
            url => $$res{'url'}, 
            msg => $SESSION{'LOC'}->loc($res->{'message'}), 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            
        });
    }
    
} #-- usercontroller_rt_user_profile_post

sub usercontroller_rt_user_register_post () {

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
    
    my (
        $res, $member_id, 
        $valcode, $html, $text 
    );

    #unless ($res) {
        if (
            $SESSION{'USR'}->{'member_id'}
        ) {
            $res = {
                status => 'fail', 
                message => 'You\'re registred alredy', 
            }
        }
    #}

    unless ($res) {
        if ( 
            $SESSION{'CAPTCHA'} && 
            !$SESSION{'CAPTCHA'}->{'check_mjcaptcha'}()
        ) {
            $res = {
                status => 'fail', 
                message => 'captcha do not match', 
            }
        }
    }

    unless ($res) {
        if (
            (scalar $SESSION{'REQ'}->param('usr_lang')) && 
            !&inarray([keys %{$SESSION{'SITE_LANGS'}}], scalar $SESSION{'REQ'}->param('usr_lang'))
        ) {
            $res = {
                status => 'fail', 
                message => 'lang unknown', 
            };
        }
    }
    
    unless ($res) {
        unless (
            scalar $SESSION{'REQ'}->param('usr_pass') 
            eq 
            scalar $SESSION{'REQ'}->param('usr_pass_retype') 
        ) {
            $res = {
                status => 'fail', 
                message => 'password do not match', 
            }
        }
    }
        
    unless ($res) {
        $member_id = &MjNCMS::UserSiteLibWrite::register({
            login => scalar $SESSION{'REQ'}->param('usr_login'), 
            name => scalar $SESSION{'REQ'}->param('usr_name'), 
            password => scalar $SESSION{'REQ'}->param('usr_pass'), 
            email => scalar $SESSION{'REQ'}->param('usr_email'), 
            lang =>  => scalar $SESSION{'REQ'}->param('usr_lang'), 
            role_id => $SESSION{'DEFAULT_REG_ROLE'} || 0, 
            is_cms_active => 0, 
            is_forum_active => 0, #need return valcode
            startpage => undef, 
        });
        
        unless (
            $member_id && 
            ref $member_id &&
            ref $member_id eq 'HASH' && 
            ${$member_id}{'member_id'} =~ /^\d+$/
        ) {
            $res = {
                status => 'fail', 
                message => 'user is not created: ' . $SESSION{'USR'}->{'last_state'}, 
            }
        }
        else {
            $valcode = ${$member_id}{'valcode'};
            $member_id = ${$member_id}{'member_id'};
            $res = {
                status => 'ok', 
                message => 'user is created', 
            }
        }
    }
    
    
    $TT_CFG{'tt_controller'} = 
        $TT_VARS{'tt_controller'} = 
            'user';
    
    $TT_VARS{'status'} = $res->{'status'};
    $TT_VARS{'message'} = $SESSION{'LOC'}->loc($res->{'message'});
    $TT_VARS{'member_id'} = $member_id;
    $TT_VARS{'confirmation_code'} = $valcode;

    if ($res->{'status'} ne 'ok') {
        
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'confirm';

        $self->render('site_index', format => 'html');
    
    }
    else {
        
        $TT_VARS{'make_it_simple'} = 1;
        $html = $self->render_partial(template => 'user/mail/confirm', format => 'html');
        $text = $self->render_partial(template => 'user/mail/confirm', format => 'txt');
        $TT_VARS{'make_it_simple'} = 0;
        
        if (
            $SESSION{'MAILER'}->new({
                to => (scalar $SESSION{'REQ'}->param('usr_name')) . 
                    ' <' . 
                        (scalar $SESSION{'REQ'}->param('usr_email')) . 
                            '>', 
                subject => $SESSION{'LOC'}->loc('Confirm registartion at') . ' ' . $SESSION{'SITE_NAME'}, 
                html => $html, 
                text => $text, 
            })->send()
        ){
        
            $TT_CFG{'tt_action'} = 
                $TT_VARS{'tt_action'} = 
                    'confirm_req';

            $self->render('site_index', format => 'html');
        }
        else {

            $TT_CFG{'tt_action'} = 
                $TT_VARS{'tt_action'} = 
                    'confirm';

            $self->render('site_index', format => 'html');
        
        }
    
    }
    
    return undef;
    
} #-- usercontroller_rt_user_register_post

sub usercontroller_rt_user_confirm_post () {

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
    
    #unless ($res) {
        if ( 
            $SESSION{'CAPTCHA'} && 
            !$SESSION{'CAPTCHA'}->{'check_mjcaptcha'}()
        ) {
            $res = {
                status => 'fail', 
                message => 'captcha do not match', 
            }
        }
    #}
    
    unless ($res) {
        if (
            &MjNCMS::UserSiteLibWrite::confirm_registration(
                scalar $SESSION{'REQ'}->param('confirmation_code'), 
                $SESSION{'AUTH_ON_CONFIRM'} 
            ) 
        ) {
            
            $res = {
                status => 'ok', 
                message => 'All OK', 
                
            };
        }
        else {
            $res = {
                status => 'fail', 
                message => 'Confirm failed. Wrong code or alredy confirmed?', 
                
            };
            $$res{'message'} .= ' '.$self->{'last_state'} if $self->{'last_state'};
        }
    }

    $SESSION{'PAGE_CACHABLE'} = 1;
    
    $TT_CFG{'tt_controller'} = 
        $TT_VARS{'tt_controller'} = 
            'user';
    $TT_CFG{'tt_action'} = 
        $TT_VARS{'tt_action'} = 
            'confirm_result';

    $TT_VARS{'status'} = $res->{'status'};
    $TT_VARS{'message'} = $SESSION{'LOC'}->loc($res->{'message'});

    $self->render('site_index', format => 'html');
    
} #-- usercontroller_rt_user_confirm_post

sub usercontroller_rt_user_forgot_password_post () {
    
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
    
    if ( 
        $SESSION{'CAPTCHA'} && 
        !$SESSION{'CAPTCHA'}->{'check_mjcaptcha'}()
    ) {
        $SESSION{'REDIR'} = {
            url => $SESSION{'USR_URL'} . '/forgot_password', 
            msg => $SESSION{'LOC'}->loc('Captcha typed incorrectly'), 
        };
        return;
    }
    
    my $res = &MjNCMS::UserSiteLibWrite::forgot_password({
        c => $self, 
        login => scalar $SESSION{'REQ'}->param('login'), 
        email => scalar $SESSION{'REQ'}->param('email'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'USR_URL'}.'/forgot_password' unless $url;
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
            role_id => $res->{'role_id'}, 
            
        });
    }
    
} #-- usercontroller_rt_user_forgot_password_post

sub usercontroller_rt_user_reconfirm_email_post () {
    
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
    
    if ( 
        $SESSION{'CAPTCHA'} && 
        !$SESSION{'CAPTCHA'}->{'check_mjcaptcha'}()
    ) {
        $SESSION{'REDIR'} = {
            url => $SESSION{'USR_URL'} . '/forgot_password', 
            msg => $SESSION{'LOC'}->loc('Captcha typed incorrectly'), 
        };
        return;
    }
    
    my $res = &MjNCMS::UserSiteLibWrite::reconfirm_email({
        c => $self, 
        login => scalar $SESSION{'REQ'}->param('login'), 
        email => scalar $SESSION{'REQ'}->param('email'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'USR_URL'}.'/login' unless $url;
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
            role_id => $res->{'role_id'}, 
            
        });
    }
    
} #-- usercontroller_rt_user_reconfirm_email_post

sub usercontroller_rt_user_rest_pass_get () {

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
        my $res = &MjNCMS::UsercontrollerSiteLibWrite::rest_password({
            c => $self, 
            login => scalar $self->param('login'), 
            crc => scalar $self->param('crc'), 
        });
        
        my $url;
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'USR_URL'}.'/login' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $SESSION{'LOC'}->loc($res->{'message'}), 
        };
        return;
        
    }
    
    return;

} #-- usercontroller_rt_user_rest_pass_get

1;
