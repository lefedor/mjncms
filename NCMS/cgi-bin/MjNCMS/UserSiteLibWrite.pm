package MjNCMS::UserSiteLibWrite;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use MjNCMS::UserSiteLibAny qw/:subs /;

use Mojo::Cookie::Response;

use Digest::SHA1 qw/sha1_hex /;#smf reg requirement
use PHP::Serialization qw/serialize /;#smf auth req

#
#BEGIN {
#    use Exporter ();
#    use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS /;
#    @ISA         = qw/Exporter /;
#    @EXPORT      = qw/ /;
#    @EXPORT_OK   = qw/ /;
#    
#    %EXPORT_TAGS = (
#      vars => [qw/ /],
#      subs => [qw/
#       _chk_email
#       _smf_register
#       _smf_reg_confirm
#       _smf_rm_record
#       _smf_login
#       _smf_change_email
#       _smf_change_password
#       register
#       register_hs
#       confirm_registration
#       login
#       change_email
#       change_password
#       set_cms_active
#       set_new_salt
#        
#    /],
#    );
#    Exporter::export_ok_tags('vars');
#    Exporter::export_ok_tags('subs');
#    
#}
#

########################################################################
#                 Functions to write user data @ site
########################################################################
#                   Driver-specific subs
########################################################################

sub _chk_email ($) {
    my $email = shift;
    return 1 if (
        $email =~ /^[A-Za-z0-9_\-\.]+\@([A-Za-z0-9_\-]+\.)+[A-Za-z]{2,4}$/
    );
    return undef;
}

sub _smf_register ($) {
    
    my $cfg = shift;
    return {
        status => 'fail', 
        message => 'No cfg'
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail',
        message => 'Login chk fail', 
    } unless (
        defined ${$cfg}{'login'} && 
        length ${$cfg}{'login'}
    );
    
    return {
        status => 'fail',
        message => 'Password chk fail', 
    } unless (
        defined ${$cfg}{'password'} && 
        length ${$cfg}{'password'}
    );
    
    my (
        $dbh, $q, 
        $passhash, 
        
    ) = ($SESSION{'DBH'}, );
    
    ${$cfg}{'is_forum_active'} = ${$cfg}{'is_forum_active'}? 1:0;
    unless (${$cfg}{'is_forum_active'}) {
        ${$cfg}{'validation_code'} = ${$cfg}{'validation_code'}? 
            ${$cfg}{'validation_code'} : 
                substr($SESSION{'BS'}( (time()) . ${$cfg}{'email'} . (time()) )->md5_sum()->to_string(), 0, 10);
                return {
                    status => 'fail',
                    message => 'Valcode chk fail', 
                } unless (${$cfg}{'validation_code'} =~ m/^\w{10}$/);
    }
    else {
        ${$cfg}{'validation_code'} = ''
    }

    return {
        status => 'fail',
        message => 'Regdata login/pass chk fail', 
    } unless(
        ${$cfg}{'login'} && 
        (
            !defined(${$cfg}{'email'}) || 
            length(${$cfg}{'email'})
        ) && 
        ${$cfg}{'password'}
    );
    unless (${$cfg}{'skip_login_chk'}) {
        return {
            status => 'fail',
            message => 'Only latin letters and numbers at password', 
        } unless (${$cfg}{'login'} =~ m/^[-._!+~0-9a-zA-Z]{3,80}$/); 
    } 
    ###return -5 unless ($usrpass =~ m/^[-._!@#$%^&*(){}+~0-9a-zA-Z]+$/); #password content chk?
    return {
        status => 'fail',
        message => 'Email chk fail', 
    } unless (
        !defined(${$cfg}{'email'}) || 
        (&_chk_email(${$cfg}{'email'}))
    );#($usremail =~ m~^\'[-_.a-zA-Z0-9]+\@([-_.a-zA-Z0-9]+\.)+[a-zA-Z]{2,4}\'$~));
    
    $passhash = &_smf_gen_pass(${$cfg}{'login'}, ${$cfg}{'password'});
    return {
        status => 'fail',
        message => 'Passhash was not created', 
    } unless $passhash;
    
    my $cnt_chk = 0;
    eval {
        $dbh->do(qq~ LOCK TABLES ${SESSION{FORUM_PREFIX}}members WRITE ; ~);
        $q = "SELECT COUNT(*) AS cnt FROM ${SESSION{FORUM_PREFIX}}members WHERE memberName=" . $dbh->quote(${$cfg}{'login'}) . '; ';
        ($cnt_chk) = $dbh -> selectrow_array($q);
    };
    if ($cnt_chk) {
        $dbh -> do("UNLOCK TABLES ; ");
        return {
            status => 'fail', 
            message => 'Username is alredy taken',
        }
    }

    if(defined(${$cfg}{'email'})) {
        eval {
            $q = "SELECT COUNT(*) AS cnt FROM ${SESSION{FORUM_PREFIX}}members WHERE emailAddress=" . $dbh->quote(${$cfg}{'email'}) . '; ';
            ($cnt_chk) = $dbh -> selectrow_array($q);
        };
        if ($cnt_chk) {
            $dbh -> do("UNLOCK TABLES ; ");
            return {
                status => 'fail', 
                message => 'Email is alredy taken',
            }
        }
    }
    else {
        ${$cfg}{'email'} = '';#not NULL
    }
    
    ${$cfg}{'realname'} = ${$cfg}{'login'}
        unless defined ${$cfg}{'realname'};
    
    my ($inscnt, $member_id, $res);
    
     $q = qq~ 
        INSERT INTO ${SESSION{FORUM_PREFIX}}members (
            memberName, dateRegistered, realName, 
            emailAddress, hideEmail, 
            passwordSalt, passwd, is_activated, 
            validation_code, lngfile, buddy_list, 
            pm_ignore_list, messageLabels, personalText, 
            websiteTitle, websiteUrl, location, 
            ICQ, MSN, signature, avatar, usertitle, 
            memberIP, memberIP2, 
            secretQuestion, additionalGroups )
        VALUES ( 
            ~ . $dbh->quote(${$cfg}{'login'}) . ', UNIX_TIMESTAMP(NOW()),' . $dbh->quote(${$cfg}{'realname'}) . q~,
            ~ . $dbh->quote(${$cfg}{'email'}) .q~, 1,
            SUBSTR(MD5(UNIX_TIMESTAMP()/(RAND()*RAND())),1,4), 
            ~ . ($dbh->quote($passhash)) . q~, 
            ~ . $dbh->quote(${$cfg}{'is_forum_active'}) . q~, 
            ~ . $dbh->quote(${$cfg}{'validation_code'}) . q~, '', '', '', '', '', '', '', '', '', 
            '', '', '', '', '', '', '', '' 
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };

    if (scalar $inscnt) {
            eval {
              $q = qq~ SELECT LAST_INSERT_ID() AS lid; ~;
              ($member_id) = $dbh -> selectrow_array($q);
            };
            
            #all done, return hashlink:
            $dbh -> do("UNLOCK TABLES ; ");
            return {
                status => 'ok', 
                message => 'All OK', 
                member_id => $member_id,
                valcode => ((${$cfg}{'is_forum_active'})? undef:${$cfg}{'validation_code'}),
            };
    }
    else {
        $dbh -> do("UNLOCK TABLES ; ");
        return {
            status => 'fail',
            message => 'User forum record was not created',
        }; 
    }
} #-- _smf_register

sub _smf_reg_confirm ($;$) {
    
    my $confirmation_code = $_[0]? &trim($_[0]):undef; # $SESSION{'REQ'}->param('user');
    my $auth_after = $_[1]? $_[1]:undef;
    
    return {
        status => 'fail', 
        message => 'no validation code', 
        
    } unless $confirmation_code && length $confirmation_code;
    
    my (
        $dbh, 
        $q, $sth, $res, 
        $updcnt, 
        $member_id, $login, 
        $passhash, $sessid, 
        
    ) = (
        $SESSION{'DBH'}, 
        undef, 
        undef, {}, 
    );
    
    $q = qq~
        SELECT 
            ID_MEMBER AS member_id, 
            memberName AS login, 
            passwd AS passhash 
        FROM ${SESSION{FORUM_PREFIX}}members 
        WHERE validation_code = ? 
            AND is_activated = 0 ; 
    ~;

    eval {
        $sth = $dbh -> prepare($q); $sth -> execute($confirmation_code);
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'unconfirmed user not exist', 
    } unless scalar $res -> {'member_id'};
    
    $member_id = $res -> {'member_id'};
    $login = $res -> {'login'};
    $passhash = $res -> {'passhash'};
    
    $q = qq~
        UPDATE 
        ${SESSION{FORUM_PREFIX}}members 
        SET 
            validation_code = '', 
            is_activated = 1
        WHERE ID_MEMBER = $member_id ; 
    ~;
    
    eval {
        $updcnt = $dbh->do($q);
    };
    
    return {
        status => 'fail', 
        message => 'fail to update user entry', 
    } unless scalar $updcnt;
    
    if ($auth_after) {
        
        $sessid = $SESSION{'USR'}->{'PHP_SESSID'};
        $sessid = '' unless $sessid;
        $passhash = sha1_hex($passhash . $sessid);
        $res = &_smf_login({
            login => $login, 
            password => undef, 
            passhash => $passhash, 
        });
        
        return {
            status => 'ok', 
            message => 'OK, but auth failed', 
            member_id => $member_id, 
        } unless (
            $res && 
            ref $res && 
            ref $res eq 'HASH' && 
            ${$res}{'auth_success'}
        );
        
    }
    
    return {
        status => 'ok', 
        message => 'All OK', 
        member_id => $member_id, 
    };
    
} #-- _smf_reg_confirm

sub _smf_rm_record ($) {
    
    my $member_id = shift;
    
    return undef unless ($member_id && $member_id =~ /^\d+$/);
    
    my $q = qq~
        DELETE FROM ${SESSION{FORUM_PREFIX}}members 
        WHERE ID_MEMBER='$member_id' ;
    ~;
    eval {$SESSION{'DBH'}->do($q);};
    
    return 1;
    
}

sub _smf_login ($) {
    
    my $cfg = shift;
    return {
        status => 'fail', 
        message => 'No cfg'
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail',
        message => 'Login chk fail', 
    } unless (
        defined ${$cfg}{'login'} && 
        length ${$cfg}{'login'}
    );
    return {
        status => 'fail',
        message => 'Password data not found', 
    } unless (defined(${$cfg}{'password'}) || defined(${$cfg}{'passhash'}));
    
    my $cookielength = ${$cfg}{'cookielength'};
    
    my $session_php = $SESSION{'COOKIES_REQ'}{$SESSION{'SESS_COOKIE_PHP'}};

    my (
        $dbh, 
        $q, $sth, $res, 
        $cnt_chk, $rand_code, 
        $timeuntil, @arr2ser, 
        $smfcookie, $sessid, 
        
    ) = (
        $SESSION{'DBH'}, 
        undef, 
        undef, {}, 
    );
    
    if (!$session_php) {#no PHP session
        
        eval {
            $dbh -> do("LOCK TABLES ${SESSION{FORUM_PREFIX}}sessions WRITE ; ");
        };
        
        while(){
            $sessid = $SESSION{'BS'}(rand())->md5_sum()->to_string();
            eval {
                ($cnt_chk) = $dbh -> selectrow_array(qq~
                    SELECT COUNT(*) AS cnt 
                    FROM ${SESSION{FORUM_PREFIX}}sessions 
                    WHERE session_id='$sessid' ; 
                ~);
            };
            last unless scalar $cnt_chk;
        }
        
        $session_php = Mojo::Cookie::Response->new;
        $session_php->name($SESSION{'SESS_COOKIE_PHP'});
        $session_php->domain($SESSION{'SERVER_NAME'}) if $SESSION{'SERVER_NAME'} =~ /\w+\.\w+/;#2 segments min rfc
        $session_php->path('/');
        $session_php->httponly(1);# no js access on client-side
        $session_php->comment($SESSION{'SERVER_NAME'}.':'.$SESSION{'SERVER_PORT'}.' PHP SESSION cookie');
        $session_php->value($sessid);
        $SESSION{'COOKIES_RES'}{$SESSION{'SESS_COOKIE_PHP'}} = $session_php;

        $rand_code = $SESSION{'BS'}($sessid . rand())->md5_sum()->to_string();

        my $data = 'rand_code|s:' . length($rand_code) . qq~:"$rand_code";~ 
        . 'USER_AGENT|s:' . length($SESSION{'HTTP_USER_AGENT'}) 
        . qq~:"$SESSION{'HTTP_USER_AGENT'}";~ ;
        $data = $dbh -> quote($data);

        eval {
            $dbh -> do(qq~
                REPLACE INTO ${SESSION{FORUM_PREFIX}}sessions 
                    (session_id, last_update, data) 
                VALUES 
                    (~ . ($dbh -> quote($sessid)) . qq~, ~ . (time()) . qq~, $data) ; 
            ~);
        };
        $dbh -> do("UNLOCK TABLES ; ");
        
        $sessid = '';#auth passwd hash could be alredy send (phpsess == '')
        
    }
    else {
        $sessid = $session_php->value();
    }
    
    ${$cfg}{'passhash'} = sha1_hex(&_smf_gen_pass(${$cfg}{'login'}, ${$cfg}{'password'}) . $sessid) unless ${$cfg}{'passhash'};

    $q = qq~
        SELECT 
        m.id_member AS member_id, m.passwd, m.passwordsalt, u.startpage 
        FROM ${SESSION{FORUM_PREFIX}}members m 
            LEFT JOIN ${SESSION{PREFIX}}users u ON u.member_id=m.ID_MEMBER 
        WHERE m.membername = ? 
        LIMIT 0,1 ;
    ~;
    eval {
        $dbh -> do(qq~
            LOCK TABLES 
                ${SESSION{FORUM_PREFIX}}members AS m READ, 
                ${SESSION{PREFIX}}users AS u READ ; 
        ~);
        
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'login'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    $dbh -> do("UNLOCK TABLES ; ");
    
    return {
        status => 'fail',
        message => 'User not found', 
        
    } unless scalar $res->{'member_id'};

    return {
        status => 'fail',
        message => 'Wrong password', 
        
    } unless (sha1_hex($res->{'passwd'} . $sessid) eq ${$cfg}{'passhash'});
    
    #Set auth cookie
    $timeuntil = time() + 155520000; #psas@coockie expire [secs since yr 1970] - now +5 years
    $cookielength = -1 unless $cookielength =~ m/^\-{0,1}\d+$/;
    $timeuntil = time() + 60 * $cookielength if ($cookielength > 0);
    $cookielength = $timeuntil;
    
    @arr2ser = ($res->{'member_id'}, sha1_hex($res->{'passwd'} . $res->{'passwordsalt'}), $timeuntil, 2);
    
    $smfcookie = Mojo::Cookie::Response->new;
    $smfcookie->name($SESSION{'AUTH_COOKIE'});
    $smfcookie->domain($SESSION{'SERVER_NAME'}) if $SESSION{'SERVER_NAME'} =~ /\w+\.\w+/;#2 segments min rfc
    $smfcookie->path('/');
    $smfcookie->httponly(1);# no js access on client-side
    $smfcookie->expires($cookielength);
    $smfcookie->comment($SESSION{'SERVER_NAME'}.':'.$SESSION{'SERVER_PORT'}.' SMF Auth cookie');
    $smfcookie->value(serialize(\@arr2ser));
    $SESSION{'COOKIES_RES'}{$SESSION{'AUTH_COOKIE'}} = $smfcookie;
    
    return {
        status => 'ok',
        message => 'All OK', 
        
        auth_success => 1, 
        
        member_id => $res->{'member_id'}, 
        #passwd => $res->{'passwd'}, #don't need now, unsecure 
        #passwordsalt => $res->{'passwordsalt'}, # -//- uncomment if req
        startpage => $res->{'startpage'}, 
    }
    
} #-- _smf_login

sub _smf_change_email ($$) {
    
    my $email = $_[0];
    my $member_id = $_[1];
    
    unless (&_chk_email($email)) {
        $SESSION{'USR'}->{'last_state'} = 'wrong_email';
        return undef;
    }
    
    unless ($member_id =~ /^\d+$/) {
        $SESSION{'USR'}->{'last_state'} = 'wrong_member_id';
        return undef;
    }

    my (
        $dbh, 
        $q, $updcnt, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        UPDATE ${SESSION{FORUM_PREFIX}}members 
        SET 
            emailAddress = ~ . ($dbh->quote($email)) . qq~ 
        WHERE ID_MEMBER = ~ . ($dbh->quote($member_id)) . q~ ;
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };
    
    unless (
        scalar $updcnt
    ){
        $SESSION{'USR'}->{'last_state'} = 'update forum members table fail';
        return undef;
    }
    
    return 1;
    
} #-- _smf_change_email

sub _smf_change_password ($$$) {
    
    my $pass = $_[0];
    my $pass_retype = $_[1];
    my $member_id = $_[2];
    
    unless ($member_id =~ /^\d+$/) {
        $SESSION{'USR'}->{'last_state'} = 'wrong_member_id';
        return undef;
    }
    
     unless (
        $pass && 
        length $pass && 
        $pass eq $pass_retype 
    ) {
        $SESSION{'USR'}->{'last_state'} = 'wrong_pass';
        return undef;
    }

    my (
        $dbh, $sth, $res, 
        $q, $updcnt, $sessid, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~ 
        SELECT 
            ID_MEMBER AS member_id, 
            memberName AS login
        FROM ${SESSION{FORUM_PREFIX}}members 
        WHERE ID_MEMBER = ? ;
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute($member_id);
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'member_id not exist or wrong', 
    } unless (
        $res -> {'member_id'} =~ /^\d+$/ &&
        length $res -> {'login'}
    );
    
    my $passum = &_smf_gen_pass($res -> {'login'}, $pass);
    
    $q = qq~
        UPDATE ${SESSION{FORUM_PREFIX}}members 
        SET 
            passwd = ~ . ($dbh->quote($passum)) . qq~ 
        WHERE ID_MEMBER = ~ . ($dbh->quote($member_id)) . q~ ;
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };
    
    unless (
        scalar $updcnt
    ){
        $SESSION{'USR'}->{'last_state'} = 'update forum members table fail';
        return undef;
    }
    
    if ($SESSION{'USR'}->{'member_id_real'} == $member_id) {
        #if user shange own pass - stay auth
        $sessid = $SESSION{'USR'}->{'PHP_SESSID'};
        $sessid = '' unless $sessid;
        $passum = sha1_hex($passum . $sessid);
        &_smf_login({
            login => $res -> {'login'}, 
            password => undef, 
            passhash => $passum,
        });
    }
    
    return 1;
    
} #-- _smf_change_password


########################################################################
#                           Universal calls
########################################################################


sub register ($) {
    
    my $cfg = shift;
    unless ($cfg && ref $cfg && ref $cfg eq 'HASH') {
        $SESSION{'USR'}->{'last_state'} = 'cfg was not set';
        return undef;
    }

    ${$cfg}{'role_id'} = defined(${$cfg}{'role_id'})? ${$cfg}{'role_id'}:($SESSION{'DEFAULT_REG_ROLE'} || 0);

    ${$cfg}{'is_cms_active'} = ${$cfg}{'is_cms_active'}? 1:0;    
    ${$cfg}{'is_forum_active'} = ${$cfg}{'is_forum_active'}? 1:0;
    
    my $salt = undef;
    
    unless (${$cfg}{'role_id'} =~ m/^\d+$/) {
        $SESSION{'USR'}->{'last_state'} = 'wrong_role';
        return undef;
    }

    ${$cfg}{'startpage'} = ${$cfg}{'startpage'}? &trim(${$cfg}{'startpage'}) : '/';
    
    my $mode = $SESSION{'USR'}->{'MODE'};
    my (
        $dbh, $res, 
        $q, $inscnt, 
    ) = ($SESSION{'DBH'}, );
    
    if ($mode eq 'smf') {
        $res = &_smf_register({
            login => ${$cfg}{'login'}, 
            password => ${$cfg}{'password'}, 
            email => ${$cfg}{'email'}, 
            realname => ${$cfg}{'name'}, 
            is_forum_active => ${$cfg}{'is_forum_active'}, 
            validation_code => ${$cfg}{'validation_code'}, 
            skip_login_chk => ${$cfg}{'skip_login_chk'}
        });
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    if (
        $res && ref $res eq 'HASH' && 
        ${$res}{'status'} eq 'ok'
    ) {
        
        $salt = substr($SESSION{'BS'}(rand() . time())->md5_sum()->to_string(), 0, 16);
        
        $dbh -> do(qq~ LOCK TABLES ${SESSION{PREFIX}}users WRITE ; ~);
        
        $q = qq~
            INSERT INTO 
            ${SESSION{PREFIX}}users (
                member_id, role_id, name, # 0 1 2
                site_lng, whoedit, startpage, # 3 4 5
                salt, #6
                is_cms_active #7
            ) VALUES (
                ~ . ($dbh->quote(${$res}{'member_id'})) . q~, 
                ~ . ($dbh->quote(${$cfg}{'role_id'})) . q~, 
                ~ . ($dbh->quote(${$cfg}{'name'})) . q~, 
                ~ . ($dbh->quote(${$cfg}{'lang'})) . q~, 
                ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . q~, 
                ~ . ($dbh->quote(${$cfg}{'startpage'})) . q~, 
                ~ . ($dbh->quote($salt)) . q~, 
                ~ . ($dbh->quote(${$cfg}{'is_cms_active'})) . q~ 
            ) ; ~;
            
            eval {
                $inscnt = $dbh->do($q);
            };
            
            unless (scalar $inscnt) {
                $dbh -> do("UNLOCK TABLES ; ");
                $SESSION{'USR'}->{'last_state'} = 'users_ins_query_fail';

                &_smf_rm_record(${$res}{'member_id'});
                return undef;
            }

        $dbh -> do("UNLOCK TABLES ; ");
        return $res; #={member_id => \d+, valcode => \w+}
        
    }
    else {
        $SESSION{'USR'}->{'last_state'} = ${$res}{'message'};
        return undef;
    }
    
    return undef;
    
} #-- register

sub delete_forum_record ($) {
    
    #LOL :), self-distruction if error :))))
    my $member_id = defined($_[0])? $_[0]:$SESSION{'USR'}->{'member_id'};
    
    my $mode = $SESSION{'USR'}->{'MODE'};
    
    if ($mode eq 'smf') {
        return &_smf_rm_record($member_id);
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;

} #-- delete_forum_record

sub confirm_registration ($;$) {
    
    my $confirmation_code = $_[0];
    my $auth_if_success = $_[1];

    my $mode = $SESSION{'USR'}->{'MODE'};
    
    my $res;
    
    if ($mode eq 'smf') {
        $res = &_smf_reg_confirm($confirmation_code, $auth_if_success);
        unless (
            $res && 
            ref $res && 
            ref $res eq 'HASH' && 
            ${$res}{'status'} eq 'ok' &&
            ${$res}{'member_id'} =~ /^\d+$/
        ) {
            $SESSION{'USR'}->{'last_state'} = 'confirmation_failed';
            return undef;
        }
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    if (
        &set_cms_active(1, ${$res}{'member_id'}) 
    ) {
        return 1;
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'Forum record activated, but cms NOT';
        return undef;
    }
    
    return undef;
    
} #-- confirm_registration

sub login ($){

    my $cfg = shift;
    
    return undef unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    unless (
        defined ${$cfg}{'login'} && 
        length ${$cfg}{'login'} 
    ) {
        $SESSION{'USR'}->{'last_state'} = 'Wrong login'; 
        return undef;
    }
    
    unless (
        defined(${$cfg}{'password'}) || 
        defined(${$cfg}{'passhsh'})
    ) {
        $SESSION{'USR'}->{'last_state'} = 'Wrong password data'; 
        return undef;
    };
    
    my $cookielength = ${$cfg}{'cookielength'};

    my $mode = $SESSION{'USR'}->{'MODE'};
    my (
        $res, $member_id, 
        $timeuntil, $rem_cookie, 
    );
    
    if (${$cfg}{'rememberme'}) {
        $timeuntil = time() + 155520000; #psas@coockie expire [secs since yr 1970] = (now +5 years)
        $cookielength = -1 unless $cookielength =~ m/^\-{0,1}\d+$/;
        
        $rem_cookie = Mojo::Cookie::Response->new;
        $rem_cookie->name($SESSION{'REM_COOKIE'});
        $rem_cookie->domain($SESSION{'SERVER_NAME'}) if $SESSION{'SERVER_NAME'} =~ /\w+\.\w+/;#2 segments min rfc
        $rem_cookie->path('/');
        $rem_cookie->httponly(1);# no js access on client-side
        $rem_cookie->expires($timeuntil);
        $rem_cookie->comment($SESSION{'SERVER_NAME'}.':'.$SESSION{'SERVER_PORT'}.' Auth remember cookie');
        $rem_cookie->value(${$cfg}{'login'} . '|' . $cookielength);#time_for - is only digit (\-)?\d+ [for correct re parsing backwards]!
        $SESSION{'COOKIES_RES'}{$SESSION{'REM_COOKIE'}} = $rem_cookie;
    }
    
    if ($mode eq 'smf') {
        $res = &_smf_login({
            login => ${$cfg}{'login'}, 
            password => ${$cfg}{'password'}, 
            passhash => ${$cfg}{'passhsh'}, 
            cookielength => ${$cfg}{'cookielength'},
        });
        if (
            $res && 
            ref $res eq 'HASH' && 
            ${$res}{'status'} eq 'ok'
        ) {
             ${$SESSION{'USR'}->{'profile'}}{'startpage'} = 
                ${$member_id}{'startpage'}? ${$member_id}{'startpage'}:'/';
             $SESSION{'USR'}->{'member_id'} = $SESSION{'USR'}->{'member_id_real'} = ${$member_id}{'member_id'};
             return 1;
        }
        else {
            $SESSION{'USR'}->{'last_state'} = ${$res}{'message'};
            return undef;
        }
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;

} #-- login

sub change_email ($;$){
        
    my $email = $_[0];
    my $member_id = defined($_[1])? $_[1]:$SESSION{'USR'}->{'member_id'};
    
    return undef unless $member_id; #No guests id = 0
    
    #?
    #
    #return undef unless (
    #    $member_id == $SESSION{'USR'}->{'member_id'} || 
    #    $SESSION{'USR'}->is_user_writable( $member_id ) || 
    #    $SESSION{'USR'}->chk_access('users', 'manage', 'w') 
    #);
    #

    my $mode = $SESSION{'USR'}->{'MODE'};
    
    if ($mode eq 'smf') {
        return &_smf_change_email($email, $member_id);
        
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;
    
} #-- change_email

sub change_password ($$;$) {
    
    my $pass = $_[0];
    my $pass_retype = $_[1];
    my $member_id = defined($_[2])? $_[2]:$SESSION{'USR'}->{'member_id'};
    
    return undef unless $member_id; #No guests id = 0
    
    #?
    #
    #return undef unless (
    #    $member_id == $SESSION{'USR'}->{'member_id'} || 
    #    $SESSION{'USR'}->is_user_writable( $member_id ) || 
    #    $SESSION{'USR'}->chk_access('users', 'manage', 'w') 
    #);
    #

    my $mode = $SESSION{'USR'}->{'MODE'};
    
    if ($mode eq 'smf') {
        return &_smf_change_password($pass, $pass_retype, $member_id);
        
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;
    
} #-- change_password

sub set_cms_active ($;$) {
    
    my $status = $_[0];
    my $member_id = defined($_[1])? $_[1]:$SESSION{'USR'}->{'member_id'};
    
    $status = $status? 1:0;
    
    #?
    #
    #return undef unless (
    #    $member_id == $SESSION{'USR'}->{'member_id'} || 
    #    $SESSION{'USR'}->is_user_writable( $member_id ) || 
    #    $SESSION{'USR'}->chk_access('users', 'manage', 'w') 
    #);
    #
    
    my (
        $dbh, $q, 
        $updcnt, 
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}users 
        SET 
            is_cms_active = $status 
        WHERE member_id = $member_id ; 
    ~;
    
    eval{
        $updcnt = $dbh -> do($q);
    };
    
    if (scalar $updcnt) {
        return 1;
    }
    
    return undef;
    
} #-- set_cms_active

sub set_new_salt (;$$){
    
    my $salt = $_[0];
    my $member_id = defined($_[1])? $_[1]:$SESSION{'USR'}->{'member_id'};
    
    return undef unless $member_id; #No guests id = 0
    
    $salt = substr($SESSION{'BS'}(rand())->md5_sum()->to_string(), 0, 16)
        unless $salt;
    
    #?
    #
    #return undef unless (
    #    $member_id == $SESSION{'USR'}->{'member_id'} || 
    #    $SESSION{'USR'}->is_user_writable( $member_id ) || 
    #    $SESSION{'USR'}->chk_access('users', 'manage', 'w') 
    #);
    #
    
    my (
        $dbh, $q, 
        $updcnt, 
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}users 
        SET 
            salt = ~ . ($dbh->quote($salt)) . qq~ 
        WHERE member_id = ~ . ($dbh->quote($member_id)) . qq~ ; 
    ~;
    
    eval{
        $updcnt = $dbh -> do($q);
    };
    
    if (scalar $updcnt) {
        return $salt;
    }
    
    return undef;
    
} #-- set_new_salt

sub reconfirm_email ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input cfg', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'no input data',
    } unless (
        ${$cfg}{'c'} && 
        (
            ${$cfg}{'login'} ||
            ${$cfg}{'email'}
        )
    ); 
    
    my (
        $dbh, $q , 
        $res, $ttv_save, 
        $html, $text, 
        
    ) = ($SESSION{'DBH'}, );
    
    if (${$cfg}{'login'}){
        
        $res = &get_users({
                login => ${$cfg}{'login'}, 
            });
        
        $res = pop @{$$res{'users'}};
        
    }
    
    if (!$res && ${$cfg}{'email'}){
        
        $res = &get_users({
                email => ${$cfg}{'email'}, 
            });
        
        $res = pop @{$$res{'users'}};
        
    }
    
    if ($res && $$res{'member_id'}) { #Also guest protection :)
        
        unless (
            $$res{'val_code'} &&
            !$$res{'is_forum_active'}
        ) {
            return {
                status => 'fail', 
                message => 'Seems like user email alredy confirmed', 
            }
        }
        
        $ttv_save = $TT_VARS{'make_it_simple'};
        $TT_VARS{'make_it_simple'} = 1;
        $TT_VARS{'confirmation_code'} = $$res{'val_code'};
        
        $html = ${$cfg}{'c'}->render_partial(template => 'user/mail/confirm', format => 'html');
        $text = ${$cfg}{'c'}->render_partial(template => 'user/mail/confitm', format => 'txt');
        
        $TT_VARS{'make_it_simple'} = $ttv_save;
        delete $TT_VARS{'confirmation_code'};
        
        if (
            $SESSION{'MAILER'}->new({
                to => ($$res{'name'}) . 
                    ' <' . 
                        ($$res{'email'}) . 
                            '>', 
                subject => $SESSION{'LOC'}->loc('New confirmation email for') . ': ' . $SESSION{'SITE_NAME'}, 
                html => $html, 
                text => $text, 
            })->send()
        ){
            return {
                status => 'ok', 
                message => 'Check your mail for confirmation link', 
            }
        }
        else {
            return {
                status => 'fail', 
                message => 'fail to send confirmation email', 
            }
        }
    }
    
    return {
        status => 'fail', 
        message => 'user not found', 
    }
    
} #-- reconfirm_email

sub forgot_password ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input cfg', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'no input data',
    } unless (
        ${$cfg}{'c'} && 
        (
            ${$cfg}{'login'} ||
            ${$cfg}{'email'}
        )
    ); 
    
    my (
        $dbh, $q , 
        $res, $ttv_save, 
        $html, $text, 
        
    ) = ($SESSION{'DBH'}, );
    
    if (${$cfg}{'login'}){
        
        $res = &get_users({
                login => ${$cfg}{'login'}, 
            });
        
        $res = pop @{$$res{'users'}};
        
    }
    
    if (!$res && ${$cfg}{'email'}){
        
        $res = &get_users({
                email => ${$cfg}{'email'}, 
            });
        
        $res = pop @{$$res{'users'}};
        
    }
    
    if ($res && $$res{'member_id'}) { #Also guest protection :)
        
        $ttv_save = $TT_VARS{'make_it_simple'};
        $TT_VARS{'make_it_simple'} = 1;
        
        $TT_VARS{'passrest_login'} = $$res{'login'};
        $TT_VARS{'passrest_crc'} = 
            $SESSION{'BS'}(
                $$res{'member_id'} . 
                $$res{'salt'} . 
                $$res{'ut_ins'} . 
                $SESSION{'MD_CHK_KEY'} . 
                ($SESSION{'DATE'}->get_by_fmt('-%Y-%m-%d-')) 
                    )->md5_sum()->to_string();
        
        $html = ${$cfg}{'c'}->render_partial(template => 'user/mail/forgot', format => 'html');
        $text = ${$cfg}{'c'}->render_partial(template => 'user/mail/forgot', format => 'txt');
        
        $TT_VARS{'make_it_simple'} = $ttv_save;
        delete $TT_VARS{'passrest_login'};
        delete $TT_VARS{'passrest_crc'};
        
        if (
            $SESSION{'MAILER'}->new({
                to => ($$res{'name'}) . 
                    ' <' . 
                        ($$res{'email'}) . 
                            '>', 
                subject => $SESSION{'LOC'}->loc('Rest password at') . ' ' . $SESSION{'SITE_NAME'}, 
                html => $html, 
                text => $text, 
            })->send()
        ){
            return {
                    status => 'ok', 
                    message => 'Check your email for password rest link', 
            }
        }
        else {
            return {
                    status => 'fail', 
                    message => 'fail to send password rest email', 
            }
        }
    }
    
    return {
            status => 'fail', 
            message => 'user not found', 
    }
    
} #-- forgot_password

1;
