package MjNCMS::UsercontrollerSiteLibWrite;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
#use MjNCMS::Service qw/:subs /;

use MjNCMS::UserSiteLibAny qw/:subs /;
use MjNCMS::UserSiteLibWrite;

########################################################################
#                    Functions to write user
########################################################################

sub rest_password ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input cfg', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'no input data',
    } unless (
        ${$cfg}{'login'} &&
        ${$cfg}{'crc'} && 
        ${$cfg}{'c'}
    ); 
    
    my (
        $dbh, $q , 
        $res, $ttv_save, 
        $html, $text, $new_pass, 
        
    ) = ($SESSION{'DBH'}, );
    
    if (${$cfg}{'login'}){
        
        $res = &get_users({
                login => ${$cfg}{'login'}, 
            });
        
        $res = pop @{$$res{'users'}};
        
    }
    else {
        return {
            status => 'fail', 
            message => 'Login is not defined', 
        }
    }
    
    if ($res && $$res{'member_id'}) { #Also guest protection :)
        
        $ttv_save = $TT_VARS{'make_it_simple'};
        $TT_VARS{'make_it_simple'} = 1;
        
        $TT_VARS{'passrest_login'} = $$res{'login'};
        $TT_VARS{'passrest_name'} = $$res{'name'};
        
        $TT_VARS{'passrest_crc'} = 
            $SESSION{'BS'}(
                $$res{'member_id'} . 
                $$res{'salt'} . 
                $$res{'ut_ins'} . 
                $SESSION{'MD_CHK_KEY'} . 
                ($SESSION{'DATE'}->get_by_fmt('-%Y-%m-%d-')) 
                    )->md5_sum()->to_string();
        
        unless (
            $TT_VARS{'passrest_crc'} eq 
            ${$cfg}{'crc'}
        ) {
            return {
                status => 'fail', 
                message => 'Password rest link You\'ve followed is not valid', 
            }
        }
        
        unless (
            &MjNCMS::UserSiteLibWrite::set_new_salt(undef, $$res{'member_id'})
        ) {
            return {
                status => 'fail', 
                message => 'Password rest failed. Try please again or contact administrator. Error E01.', 
            }
        }

        $new_pass = substr($SESSION{'BS'}(rand())->md5_sum()->to_string(), 0, (int(rand(27))+5));
        
        unless (
            &MjNCMS::UserSiteLibWrite::change_password($new_pass, $new_pass, $$res{'member_id'})
        ) {
            return {
                status => 'fail', 
                message => 'Password rest failed. Try please again or contact administrator. Error E02.', 
            }
        }
        
        $TT_VARS{'passrest_password'} = $new_pass;
        
        $html = ${$cfg}{'c'}->render_partial(template => 'user/mail/new_pass', format => 'html');
        $text = ${$cfg}{'c'}->render_partial(template => 'user/mail/new_pass', format => 'txt');
        
        $TT_VARS{'make_it_simple'} = $ttv_save;
        delete $TT_VARS{'passrest_login'};
        delete $TT_VARS{'passrest_crc'};
        delete $TT_VARS{'passrest_password'};
        
        if (
            $SESSION{'MAILER'}->new({
                to => ($$res{'name'}) . 
                    ' <' . 
                        ($$res{'email'}) . 
                            '>', 
                subject => $SESSION{'LOC'}->loc('Your new password at') . ' ' . $SESSION{'SITE_NAME'}, 
                html => $html, 
                text => $text, 
            })->send()
        ){
            return {
                    status => 'ok', 
                    message => 'Check your email for new password', 
            }
        }
        else {
            return {
                    status => 'fail', 
                    message => 'fail to send new password email', 
            }
        }
    }
    
    return {
            status => 'fail', 
            message => 'user not found', 
    }

} #-- rest_password

1;
