package MjNCMS::User;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
# (c) Boris R Bondarchik, bbon@mail.ru, 2010
#

#
# Professor: Who did this? Answer now or be punished.
# Leela: Fine, I admit it. It was me.
# Professor: You will be punished! 
#
# Bender: Hey Sexy Mama... Wanna Kill All Humans?
#
# Bender: Oh no! Not the magnet!
#
# (c) Futurama
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use Mojo::Cookie::Response;

use Digest::SHA1 qw/sha1_hex /;#smf reg requirement
use PHP::Serialization qw/serialize unserialize /;#smf auth req

use locale;
use POSIX qw/locale_h /;

sub new {
  my $self = {}; shift;

  if(@_){ 
    $self->{'MOJO'} = shift;
  }
  return undef unless $self->{'MOJO'};

  if(@_){ 
    $self->{'MODE'} = shift;
  }
  
  $self->{'MODE'} = 'smf' unless $self->{'MODE'};
  
  $self->{'last_state'} = undef;
  
  $self->{'awp_id'} = 0;
  $self->{'role_id'} = 0;
  $self->{'member_id'} = 0;
  $self->{'member_id_real'} = 0;
  
  $self->{'member_is_cms_active'} = 0;
  $self->{'member_is_forum_active'} = 0;
  $self->{'member_sitelng'} = undef;
  
  $self->{'profile'} = {};
  $self->{'premissions'} = {};
  $self->{'slave_users'} = [];#member_id itself will also there, it's hashes wth data - id, name, role, etc
  $self->{'slave_users_ids'} = [];#member_id itself will also there, just id's [\d+, ...]
  $self->{'role_alternatives'} = [];
  $self->{'role_alternatives_ids'} = [];
  
  bless $self;
  return $self
} #-- new

########################################################################
#internal calls
########################################################################
sub _chk_email ($) {
    my $email = shift;
    return 1 if (
        $email =~ /^[A-Za-z0-9_\-\.]+\@([A-Za-z0-9_\-]+\.)+[A-Za-z]{2,4}$/
    );
    return undef;
}

sub _smf_gen_pass ($$;$) {
    my $login = shift;
    my $password = shift;
    
    return undef unless (
        $login && length $login &&
        $password && length $password 
    );
    return sha1_hex(lc($login) . $password);
}

sub _smf_auth($) {
    my $self = $_[0];

    my $smfcookie = $SESSION{'COOKIES_REQ'}{$SESSION{'AUTH_COOKIE'}};
    my $session_php = $SESSION{'COOKIES_REQ'}{$SESSION{'SESS_COOKIE_PHP'}};

    
    my (
        $sessid, $smfcookie_val, 
        $cookie_member_id, $cookie_passhash, $cookie_timeout, 
        $rand_code, 
        $q, $sth, $res, $dbh, $cnt_chk, 
        $guest_hash, $steps, 
        
    );
    
    $guest_hash = { 
        member_id => 0, 
        member_email => undef, 
        member_name => 'Guest', 
        member_is_active => $SESSION{'GUESTUSER_ISACTIVE'}, 
        time_offset => $SESSION{'SITE_TIME_OFFSET'},
    };
    
    $dbh = $SESSION{'DBH'};
    
    if ($smfcookie) {
        $smfcookie_val = $smfcookie->value();
        #See function Login2() for regexp in /public_html/smf/Sources/LogInOut.php
        $smfcookie_val =~ m/^a:[34]:\{i:0;(i:\d{1,6}|s:[1-8]:"\d{1,8}");i:1;s:(0|40):"([a-fA-F0-9]{40})?";i:2;[id]:(\d{1,14});(i:3;i:\d;)?\}$/;
        ($cookie_member_id, $cookie_passhash, $cookie_timeout) = ($1, $3, $4);

        $cookie_member_id =~ m/(\d+)/; 
        $cookie_member_id = scalar $1;
        
        #If smf auth coockie exists
        if (scalar $cookie_member_id) {
            if ($session_php) {
                $sessid = $session_php->value();
                eval { 
                    ($rand_code) = $dbh -> selectrow_array("SELECT data FROM ${SESSION{FORUM_PREFIX}}sessions WHERE session_id=" . $dbh->quote($sessid) .  ' LIMIT 0, 1 ; ');
                    if ($rand_code){
                        $rand_code =~ m/^.*rand_code[^\"]*\"([^\"]+)\".*$/; $rand_code = $1; # VVV example next if VVV
                    }
                }
            }
            
            if (!$session_php || !$rand_code) {#no PHP session
                eval {
                    $dbh -> do("LOCK TABLES ${SESSION{FORUM_PREFIX}}sessions WRITE ; ");
                };
                
                $steps = 100;
                while($steps > 0){
                    $sessid = $SESSION{'BS'}(rand())->md5_sum()->to_string();
                    eval {
                        ($cnt_chk) = $dbh -> selectrow_array(qq~
                            SELECT COUNT(*) AS cnt 
                            FROM ${SESSION{FORUM_PREFIX}}sessions 
                            WHERE session_id='$sessid' ; 
                        ~);
                    };
                    last unless scalar $cnt_chk;
                    $steps--;
                }

                if (scalar $cnt_chk) {
                    $dbh -> do("UNLOCK TABLES ; ");
                    return $guest_hash;
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
                
                eval {
                    $dbh -> do("UNLOCK TABLES ; ");
                };
            }
            
            $q = qq~ 
                SELECT 
                    passwd, id_member, is_activated, emailaddress, 
                    membername, realname, passwordsalt, 
                    unix_timestamp(NOW()) as now_stamp, 
                    timeOffset 
                FROM ${SESSION{FORUM_PREFIX}}members ms 
                WHERE ID_MEMBER = ? #ololo 
                LIMIT 0, 1; 
            ~;
            eval {
              $sth = $dbh->prepare($q);
              $sth -> execute($cookie_member_id);$res = $sth->fetchrow_hashref();
              $sth -> finish();
            };
            
            #If password match
            if (sha1_hex(($res->{'passwd'}) . ($res->{'passwordsalt'})) eq $cookie_passhash) {
                return {
                    member_id => $cookie_member_id, 
                    member_email => $res->{'emailaddress'}, 
                    member_name => $res->{'realname'}? $res->{'realname'}:$res->{'membername'}, 
                    member_is_active => (scalar $res->{'is_activated'})? 1:0, 
                    time_offset => $res->{'timeOffset'},
                    
                } if ($cookie_timeout - $res->{'now_stamp'} > 0);
            }
        }
        
    }
    
    #no SMF Auth coockie - present usr sa guest
    return $guest_hash;
} #-- _smf_auth

sub _smf_register ($$$;$$$$$$$) {
    my $self = $_[0];
    #all input expected unquoted
    my $usrname = $_[1]? &trim($_[1]) : undef;
        return -1 unless defined $usrname;
    my $usrpass = $_[2]? &trim($_[2]) : undef;
        return -2 unless defined $usrpass;
    my $usremail = $_[3]? &trim($_[3]) : ''; #$usrname.'@nohost.nodomain'; #?
    my $realname = $_[4]? &trim($_[4]) : '';
    
    my $dbh = $SESSION{'DBH'};
    my ($q, $usrpass_sum);#$sth);
    
    my $is_activated = $_[5]? 1:0;
    my $validation_code = '';
    unless ($is_activated) {
        $validation_code = $_[6]? &trim($_[6]) :  substr($SESSION{'BS'}( (time()) . $usremail . (time()) )->md5_sum()->to_string(), 0, 10);
        return -3 unless ($validation_code =~ m/^\w{10}$/);
    }

    return -4 unless($usrname && (!defined($usremail) || length($usremail)) && $usrpass);
    unless ($_[7]) { return -6 unless ($usrname =~ m/^[-._!+~0-9a-zA-Z]{3,80}$/); } #$_[7] - force username check
    ###return -5 unless ($usrpass =~ m/^[-._!@#$%^&*(){}+~0-9a-zA-Z]+$/); #password content chk?
    return -6 unless (!defined($usremail) || (&_chk_email($usremail)));#($usremail =~ m~^\'[-_.a-zA-Z0-9]+\@([-_.a-zA-Z0-9]+\.)+[a-zA-Z]{2,4}\'$~));
    
    $usrpass_sum = &_smf_gen_pass($usrname, $usrpass);
        return -7 unless $usrpass_sum;
    
    my $cnt_chk = 0;
    eval {
        $dbh->do(qq~ LOCK TABLES ${SESSION{FORUM_PREFIX}}members WRITE ; ~);
        $q = "SELECT COUNT(*) AS cnt FROM ${SESSION{FORUM_PREFIX}}members WHERE memberName=" . $dbh->quote($usrname) . '; ';
        ($cnt_chk) = $dbh -> selectrow_array($q);
    };
    if ($cnt_chk) {
        $dbh -> do("UNLOCK TABLES ; ");
        return -8; #username is alredy taken
    }

    if(defined($usremail)) {
        eval {
            $q = "SELECT COUNT(*) AS cnt FROM ${SESSION{FORUM_PREFIX}}members WHERE emailAddress=" . $dbh->quote($usremail) . '; ';
            ($cnt_chk) = $dbh -> selectrow_array($q);
        };
        if ($cnt_chk) {
            $dbh -> do("UNLOCK TABLES ; ");
            return -9 if $cnt_chk; #email is alredy taken
        }
    }
    else {
        $usremail = "";
    }
    
    #check reg attempts counter >>HERE<< later, no captcha!
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
            ~ . $dbh->quote($usrname) . ', UNIX_TIMESTAMP(NOW()),' . $dbh->quote($realname) . q~,
            ~ . $dbh->quote($usremail) .q~, 1,
            SUBSTR(MD5(UNIX_TIMESTAMP()/(RAND()*RAND())),1,4), 
            ~ . ($dbh->quote($usrpass_sum)) . q~, 
            ~ . $dbh->quote($is_activated) . q~, 
            ~ . $dbh->quote($validation_code) . q~, '', '', '', '', '', '', '', '', '', 
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
                member_id => $member_id,
                valcode => (($is_activated)? undef:$validation_code),
            };
    }
    else {
        $dbh -> do("UNLOCK TABLES ; ");
        return -10; #user forum record was not created
    }
} #-- _smf_register

sub _smf_login($;$$$$) {
    my $self = $_[0];
    
    #all input expected unquoted
    my $usrname = $_[1]? &trim($_[1]):undef; # $SESSION{'REQ'}->param('user');
        return -1 unless defined $usrname;
    my $usrpass = $_[2]? &trim($_[2]):undef; # $SESSION{'REQ'}->param('passwrd');
    my $passhash = $_[3]? &trim($_[3]):undef; # $SESSION{'REQ'}->param('hash_passwrd');
        return -2 unless (defined($usrpass) || defined($passhash));
    
    my $cookielength = $_[4]? &trim($_[4]):$SESSION{'REQ'}->param('cookielength');
    
    my $session_php = $SESSION{'COOKIES_REQ'}{$SESSION{'SESS_COOKIE_PHP'}};
    my $sessid;

    my $dbh = $SESSION{'DBH'};
    my (
        $q, $sth, $res, 
        $cnt_chk, $rand_code, 
        $timeuntil, @arr2ser, 
        $smfcookie, 
        
    ) = (undef, undef, {}, );
    
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
    
    $passhash = sha1_hex(&_smf_gen_pass($usrname, $usrpass) . $sessid) unless $passhash;

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
        
        $sth = $dbh -> prepare($q); $sth -> execute($usrname);
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    $dbh -> do("UNLOCK TABLES ; ");
    
    return -3 unless scalar $res->{'member_id'};

    return -4 unless (sha1_hex($res->{'passwd'} . $sessid) eq $passhash);
    
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
        auth_success => 1, 
        
        member_id => $res->{'member_id'}, 
        #passwd => $res->{'passwd'}, #don't need now, unsecure 
        #passwordsalt => $res->{'passwordsalt'}, # -//- uncomment if req
        startpage => $res->{'startpage'}, 
    }
} #-- _smf_login

sub _smf_rm_record($$) {
    my $self = $_[0];
    my $member_id = $_[1];
    
    return undef unless ($member_id && $member_id =~ /^\d+$/);
    
    my $q = qq~
        DELETE FROM ${SESSION{FORUM_PREFIX}}members 
        WHERE ID_MEMBER='$member_id' ;
    ~;
    eval {$SESSION{'DBH'}->do($q);};
    
    return 1;
}

sub _smf_logout($) {
    my $self = $_[0];
    
    my $smfcookie = Mojo::Cookie::Response->new;
    $smfcookie->name($SESSION{'AUTH_COOKIE'});
    $smfcookie->domain($SESSION{'SERVER_NAME'}) if $SESSION{'SERVER_NAME'} =~ /\w+\.\w+/;#2 segments min rfc
    $smfcookie->path('/');
    $smfcookie->httponly(1);# no js access on client-side
    $smfcookie->expires(-1);
    $smfcookie->comment($SESSION{'SERVER_NAME'}.':'.$SESSION{'SERVER_PORT'}.' SMF DeAuth cookie');
    $smfcookie->value('');
    $SESSION{'COOKIES_RES'}{$SESSION{'AUTH_COOKIE'}} = $smfcookie; 
    
    return 1;
} #-- _smf_logout

sub _smf_get_users ($$) {
    my $self = shift;
    my $cfg = shift;
    $cfg = {} unless $cfg;

    my (
        $dbh, $sth, $res, $q, 
        $where_rule, $orderby, $dt_tmp, 
        
        $page, $items_pp, $start, $end, $limit, 
        
        $foundrows, %pages, 
        
        $date_format, $foundrows, 
        %users, @users, @users_ids, 
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    
    if (defined ${$cfg}{'name'} && length ${$cfg}{'name'}){
        ${$cfg}{'name'} = $dbh->quote(${$cfg}{'name'});
        ${$cfg}{'name'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND u.name LIKE \'' . ${$cfg}{'name'} . '\' ';
    }
    
    if (defined ${$cfg}{'login'} && length ${$cfg}{'login'}){
        ${$cfg}{'login'} = $dbh->quote(${$cfg}{'login'});
        ${$cfg}{'login'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND m.memberName LIKE \'' . ${$cfg}{'login'} . '\' ';
    }
    
    if (
        defined ${$cfg}{'id'} && 
            !(ref ${$cfg}{'id'}) && 
                ${$cfg}{'id'} =~ /^\d+$/ 
    ){
        $where_rule .= ' AND u.member_id = ' . ($dbh -> quote(${$cfg}{'id'})) . ' ';
    }
    
    if (${$cfg}{'ids'} && 
        ref ${$cfg}{'ids'} && 
            ${$cfg}{'ids'} eq 'ARRAY' && 
                scalar @{${$cfg}{'ids'}} && 
                    !(scalar (grep(/\D/, @{${$cfg}{'ids'}})))) { 
        $where_rule .= ' AND u.member_id IN ( ' . (join ', ', @{${$cfg}{'ids'}}) . ' ) ';
    }
    
    if (
        defined ${$cfg}{'nid'} && 
            !(ref ${$cfg}{'nid'}) && 
                ${$cfg}{'nid'} =~ /^\d+$/ 
    ){
        $where_rule .= ' AND u.member_id != ' . ($dbh -> quote(${$cfg}{'nid'})) . ' ';
    }
    
    if (${$cfg}{'nids'} && 
        ref ${$cfg}{'nids'} && 
            ${$cfg}{'nids'} eq 'ARRAY' && 
                scalar @{${$cfg}{'nids'}} && 
                    !(scalar (grep(/\D/, @{${$cfg}{'nids'}})))) { 
        $where_rule .= ' AND u.member_id NOT IN ( ' . (join ', ', @{${$cfg}{'nids'}}) . ' ) ';
    }
    
    if ( ${$cfg}{'is_forum_active'} ){
        $where_rule .= ' AND m.is_activated = 1 ';
    }
    
    if ( ${$cfg}{'is_cms_active'} ){
        $where_rule .= ' AND u.is_cms_active = 1 ';
    }
    
    if ( 
        ${$cfg}{'from_dd'} && 
        ${$cfg}{'from_dd'} =~ /^\d+$/ && 
        ${$cfg}{'from_mm'} && 
        ${$cfg}{'from_mm'} =~ /^\d+$/ && 
        ${$cfg}{'from_yyyy'} && 
        ${$cfg}{'from_yyyy'} =~ /^\d+$/ 
    ){
        $dt_tmp = $SESSION{'DATE'}->fparse_d_m_y(${$cfg}{'from_dd'}, ${$cfg}{'from_mm'}, ${$cfg}{'from_yyyy'});
        $where_rule .= ' AND UNIX_TIMESTAMP(u.ins) >= UNIX_TIMESTAMP(' . $dt_tmp . ') ';
    }
    
    if ( 
        ${$cfg}{'to_dd'} && 
        ${$cfg}{'to_dd'} =~ /^\d+$/ && 
        ${$cfg}{'to_mm'} && 
        ${$cfg}{'to_mm'} =~ /^\d+$/ && 
        ${$cfg}{'to_yyyy'} && 
        ${$cfg}{'to_yyyy'} =~ /^\d+$/ 
    ){
        $dt_tmp = $SESSION{'DATE'}->fparse_d_m_y(${$cfg}{'to_dd'}, ${$cfg}{'to_mm'}, ${$cfg}{'to_yyyy'});
        $dt_tmp += 60*60*24;#include last day (?)
        $where_rule .= ' AND UNIX_TIMESTAMP(u.ins) <= UNIX_TIMESTAMP(' . $dt_tmp . ') ';
    }
    
    $limit = '';
    unless (${$cfg}{'get_all_records'}) {
        $page = ${$cfg}{'page'} || 1;
        $page = 1 unless $page =~ m/^\d+$/;

        $items_pp = ${$cfg}{'items_pp'} || $SESSION{'PAGER_ITEMSPERPAGE'} || 25;
        $items_pp = $SESSION{'PAGER_ITEMSPERPAGE'} unless $items_pp =~ m/^\d+$/;
        $start = ($page - 1 ) * $items_pp;
        $end = $items_pp || 0;
        $limit = "LIMIT $start, $end" if $end;
    }
    
    $orderby = ' ORDER BY u.ins DESC ';
    if (
        ${$cfg}{'order'} && 
        length ${$cfg}{'order'} && 
        &inarray([
            'name', 'login', 
            'ins', 'is_cms_active', 'is_forum_active', 'awp_role', 
        ], ${$cfg}{'order'})
    ) {
        if (
            &inarray(['name', 'ins'], ${$cfg}{'order'})
        ){
            ${$cfg}{'order'} = 'u.' . ${$cfg}{'order'};
        }
        elsif (${$cfg}{'order'} eq 'login') {
            ${$cfg}{'order'} = 'm.ID_MEMBER';
        }
        elsif (${$cfg}{'order'} eq 'awp_role') {
            ${$cfg}{'order'} = 'm.ID_MEMBER';
        }
        elsif (${$cfg}{'order'} eq 'is_cms_active') {
            ${$cfg}{'order'} = 'u.is_cms_active';
        }
        elsif (${$cfg}{'order'} eq 'is_forum_active') {
            ${$cfg}{'order'} = 'm.is_activated';
        }
        $q .= 'ORDER BY ' . ${$cfg}{'order'} . ' ';
        if (
            ${$cfg}{'ord_direction'} && 
            uc(${$cfg}{'ord_direction'}) =~ /^(ASC|DESC)$/
        ) {
            $q .= ' ' . ((${$cfg}{'ord_direction'} eq 'DESC')? 'DESC':'ASC') . ' ';
        }
    }
    
    $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_mdt_fmt() );
    
    $q = qq~
        SELECT 
            u.member_id, u.replace_member_id, #0-1
            u.is_cms_active, #2
            u.name, u.site_lng, #4
            UNIX_TIMESTAMP(u.ins) AS ut_ins, #5
            UNIX_TIMESTAMP(u.upd) AS ut_upd, #6
            DATE_FORMAT(u.ins, $date_format) AS ins_fmt, #7
            DATE_FORMAT(u.upd, $date_format) AS upd_fmt, #8
            u.whoedit, #9
            
            u.startpage, #10
            
            m.memberName AS login, #11
            m.realName AS forum_name, #12
            m.emailAddress AS email, #13
            m.timeOffset AS time_offset, #14
            m.is_activated AS is_forum_active, #15
            m. validation_code AS val_code, #16
            
            a.awp_id, a.name AS awp_name, #17
            r.role_id, r.name AS role_name, #20
            
            a.sequence AS a_sequence, #21
            r.sequence AS r_sequence, #22
            
            r_usr.name AS replace_name, #23
            e_usr.name AS editor, #24
            
            '1' AS is_cmsuser #25
            
        FROM ${SESSION{PREFIX}}users u 
            LEFT JOIN ${SESSION{FORUM_PREFIX}}members m 
                ON m.ID_MEMBER=u.member_id 
            LEFT JOIN ${SESSION{PREFIX}}roles r 
                ON r.role_id=u.role_id 
            LEFT JOIN ${SESSION{PREFIX}}awps a 
                ON a.awp_id=r.awp_id 
                
            LEFT JOIN ${SESSION{PREFIX}}users r_usr ON r_usr.member_id=u.replace_member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=u.whoedit 
    ~;
    
    if ( ${$cfg}{'incl_notincms'} ){
        $q = qq~
            SELECT ttbl.*
            FROM (
                $q
                UNION ALL 
                SELECT 
                    m.ID_MEMBER, NULL, #0-1
                    NULL, #2
                    m.realName, NULL, #4
                    m.dateRegistered, #5
                    NULL, #6
                    NULL, #7
                    NULL, #8
                    NULL, #9
                    
                    NULL, #10
                    
                    m.memberName AS login, #11
                    m.realName AS forum_name, #12
                    m.emailAddress AS email, #13
                    m.timeOffset AS time_offset, #14
                    m.is_activated, #15
                    m. validation_code AS val_code, #16
                    
                    NULL, NULL, #18
                    NULL, NULL, #20
                    
                    NULL, #21
                    NULL, #22
                    
                    NULL, #23
                    NULL, #24
                    
                    NULL #25
                
                FROM ${SESSION{FORUM_PREFIX}}members m 
                WHERE m.ID_MEMBER NOT IN (
                    SELECT member_id 
                    FROM ${SESSION{PREFIX}}users u 
                )
            ) AS ttbl
        ~;
        
        $where_rule =~ s/AND\s+(\w+\()?\w+\./AND $1ttbl\./g;
        $where_rule =~ s/ttbl.is_activated/ttbl.is_forum_active/;
        $orderby =~ s/(BY|\,)\s+\w+\./$1 ttbl\./g;
        $orderby =~ s/ttbl.ins/ttbl.ut_ins/;
    }

    $where_rule =~  s/AND/WHERE/;

    $q .= qq~
        $where_rule 
        $orderby 
        $limit ; 
    ~;
    
    $q =~ s/SELECT/SELECT SQL_CALC_FOUND_ROWS/;
    
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        unless (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash') {
            while ($res = $sth->fetchrow_hashref()) {
                push @users, {%{$res}};
                push @users_ids, $res -> {'member_id'};
            }
        }
        else{
            while ($res = $sth->fetchrow_hashref()) {
                $users{$res->{'member_id'}} = {%{$res}};
                push @users_ids, $res -> {'member_id'};
            }
        }
        $sth -> finish();
        ($foundrows) = $dbh -> selectrow_array('SELECT FOUND_ROWS()');
    };
    
    unless (${$cfg}{'get_all_records'}) {
        %pages = ( count => 1, );
        %pages = &sv_cutpages(
          {
            '-size' => $foundrows, 
            '-items_per_page' => $items_pp, 
            '-page' => ${$cfg}{'page'}, 
          }
        ) if $items_pp;
    }
    
    return {
        q => $q, 
        users => (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash')? \%users:\@users, 
        users_ids => \@users_ids, 
        pages => \%pages, 
        foundrows => $foundrows, 
    }
} #-- _smf_get_user

sub _smf_change_email ($$$) {
    my $self = $_[0];
    my $email = $_[1];
    my $member_id = $_[2];
    
    unless (&_chk_email($email)) {
        $self->{'last_state'} = 'wrong_email';
        return undef;
    }
    
    unless ($member_id =~ /^\d+$/) {
        $self->{'last_state'} = 'wrong_member_id';
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
        $self->{'last_state'} = 'update forum members table fail';
        return undef;
    }
    
    return 1;
} #-- _smf_change_email

sub _smf_change_password ($$$$) {
    my $self = $_[0];
    my $pass = $_[1];
    my $pass_retype = $_[2];
    my $member_id = $_[3];
    
    unless ($member_id =~ /^\d+$/) {
        $self->{'last_state'} = 'wrong_member_id';
        return undef;
    }
    
     unless (
        $pass && 
        length $pass && 
        $pass eq $pass_retype 
    ) {
        $self->{'last_state'} = 'wrong_pass';
        return undef;
    }

    my (
        $dbh, $sth, $res, 
        $q, $updcnt, 
        
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
        $self->{'last_state'} = 'update forum members table fail';
        return undef;
    }
    
    return 1;
} #-- _smf_changepass

sub _smf_change_active ($$$) {
    my $self = $_[0];
    my $status = $_[1];
    my $member_id = $_[2];
    
    unless ($member_id =~ /^\d+$/) {
        $self->{'last_state'} = 'wrong_member_id';
        return undef;
    }

    my (
        $dbh, $sth, $res, 
        $q, $updcnt, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~ 
        SELECT 
            ID_MEMBER AS member_id, 
            is_activated AS is_forum_active
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
        $res -> {'member_id'} =~ /^\d+$/ 
    );
    
    if($res -> {'is_forum_active'} != $status) {
    
        $q = qq~
            UPDATE ${SESSION{FORUM_PREFIX}}members 
            SET 
                is_activated = ~ . ($dbh->quote($status)) . qq~ 
            WHERE ID_MEMBER = ~ . ($dbh->quote($member_id)) . q~ ;
        ~;
        eval {
            $updcnt = $dbh->do($q);
        };
    
        unless (
            scalar $updcnt
        ){
            $self->{'last_state'} = 'update forum members table fail';
            return undef;
        }
        
    }
    
    return 1;
} #-- _smf_change_active

########################################################################
#public calls
########################################################################
sub auth ($) {
    my $self = $_[0];
    
    my $mode = $self->{'MODE'};
    
    my $auth_member = undef;
    if ($mode eq 'smf') {
        $auth_member = &_smf_auth($self);
        $auth_member = {member_id => 0, } unless (ref $auth_member && ref $auth_member eq 'HASH');
        $self->{'member_id'} = (defined($auth_member->{'member_id'}) && scalar $auth_member->{'member_id'})? (scalar $auth_member->{'member_id'}):0;
        $self->{'member_is_forum_active'} = defined($auth_member->{'member_is_active'})? $auth_member->{'member_is_active'}:$SESSION{'GUESTUSER_ISACTIVE'};
        ${$self->{'profile'}}{'member_email'} = $auth_member->{'member_email'} if $auth_member->{'member_email'};
        ${$self->{'profile'}}{'member_name'} = $auth_member->{'member_name'} if $auth_member->{'member_name'};
        ${$self->{'profile'}}{'time_offset'} = $auth_member->{'time_offset'} if defined($auth_member->{'member_name'});#can be 0
        ${$self->{'profile'}}{'time_offset'} = $SESSION{'SITE_TIME_OFFSET'} 
            unless (
                defined ${$self->{'profile'}}{'time_offset'} &&
                ${$self->{'profile'}}{'time_offset'} =~ /^\d+$/
            );
    }
    else {
        $self->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }

    $self -> {'PHP_SESSID'} = $SESSION{'COOKIES_REQ'}{$SESSION{'SESS_COOKIE_PHP'}}->value 
        if $SESSION{'COOKIES_REQ'}{$SESSION{'SESS_COOKIE_PHP'}};
        
    my (
        $dbh, $uq, $q, 
        $res, $ures, 
        $sth, $in_str, 
        @role_alternatives, 
        
    ) = ($SESSION{'DBH'}, );
    
    $dbh -> do(qq~
        LOCK TABLES 
        ${SESSION{PREFIX}}users AS u READ, 
        ${SESSION{PREFIX}}roles AS r READ, 
        ${SESSION{PREFIX}}awps AS a READ, 
        ${SESSION{PREFIX}}role_alternatives AS ra READ, 
        ${SESSION{PREFIX}}users_extrareplaces AS ue READ, 
        ${SESSION{PREFIX}}permissions AS p READ, 
        ${SESSION{PREFIX}}permission_types AS pt READ ; 
    ~);
    
    $uq = qq~
        SELECT 
            u.member_id, u.replace_member_id, u.is_cms_active, 
            u.role_id, r.awp_id, u.name, u.site_lng, 
            a.name AS awp_name, a.sequence AS awp_sequence, 
            r.name AS role_name, r.sequence AS role_sequence, 
            '1' AS user_isfound 
        FROM ${SESSION{PREFIX}}users u 
            LEFT JOIN ${SESSION{PREFIX}}roles r ON r.role_id=u.role_id 
            LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
        WHERE u.member_id = ? ; 
    ~;
    
    eval {
      $sth = $dbh->prepare($uq);
      $sth -> execute($self->{'member_id'});$ures = $sth->fetchrow_hashref();
      $sth -> finish();
    };
    
    unless ($ures && (scalar $ures->{'user_isfound'})) {
        $self->{'member_id'} = $self->{'member_id_real'} = 0;
        $self->{'member_is_forum_active'} = 0;
        $self->{'member_is_cms_active'} = 0;
        $self->{'profile'} = {};
        $self->{'last_state'} = 'user_missed';
        
        $dbh -> do("UNLOCK TABLES ; ");
        return undef;
    }
    
    unless ($ures->{'is_cms_active'}) {
        $self->{'member_id'} = $self->{'member_id_real'} = 0;
        $self->{'member_is_forum_active'} = 0;
        $self->{'member_is_cms_active'} = 0;
        $self->{'profile'} = {};
        $self->{'last_state'} = 'user_banned';
        
        $dbh -> do("UNLOCK TABLES ; ");
        return undef;
    }
    
    $self->{'member_sitelng'} = $ures->{'site_lng'} if $ures->{'site_lng'};
    
    if (scalar $ures->{'member_id'}) { #no slaves for guests member_id=0 :)
        
        #Slaves - users @ current awp which @roles with highter seq (under/slaved/etc)
        push @{$self->{'slave_users'}}, {
            member_id => $ures->{'member_id'}, 
            name => $ures->{'name'}, 
            awp_id => $ures->{'awp_id'}, 
            awp_name => $ures->{'awp_name'}, 
            role_id => $ures->{'role_id'}, 
            role_name => $ures->{'role_name'}, 
        };#user record itself
        push @{$self->{'slave_users_ids'}}, $ures->{'member_id'};
        
        #get slaves users @current awp [role seq > than current user role]
        $q = qq~ 
            SELECT 
                u.member_id, u.name, 
                a.awp_id, a.name AS awp_name, 
                r.role_id, r.name AS role_name 
            FROM ${SESSION{PREFIX}}roles r 
                LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
                LEFT JOIN ${SESSION{PREFIX}}users u ON u.role_id=r.role_id 
            WHERE r.awp_id=~ . $ures->{'awp_id'} . qq~ 
                AND r.sequence>~ . $ures->{'role_sequence'} . qq~ 
            ORDER BY r.sequence ASC ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute();
            while ($res = $sth->fetchrow_hashref()) {
              push @{$self->{'slave_users'}}, {%{$res}};
              push @{$self->{'slave_users_ids'}}, $res->{'member_id'};
            }
            $sth -> finish();
        };
        
        $q = qq~
            SELECT u.member_id, u.name, 
                a.awp_id, a.name AS awp_name, 
                r.role_id, r.name AS role_name 
            FROM ${SESSION{PREFIX}}users_extrareplaces ue 
                LEFT JOIN ${SESSION{PREFIX}}users u ON u.member_id=ue.slave_id 
                LEFT JOIN ${SESSION{PREFIX}}roles r ON r.role_id=u.role_id 
                LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
            WHERE ue.member_id=~ . ($ures->{'member_id'}) . ' ';
        if (scalar @{$self->{'slave_users_ids'}}) {
            $q .= qq~ AND ue.slave_id NOT IN (~ . (join ', ', @{$self->{'slave_users_ids'}}) . ') ';
        }
        $q .= ' ; ';
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute();
            while ($res = $sth->fetchrow_hashref()) {
                #commented to allow resort later, but 1 more query
                #push @{$self->{'slave_users'}}, {%{$res}};
                push @{$self->{'slave_users_ids'}}, $ures->{'member_id'};
            }
            $sth -> finish();
        };

    }
    
    $self->{'member_id_real'} = $self->{'member_id'};
    if (
        $ures->{'replace_member_id'} && 
        $ures->{'replace_member_id'} =~ /^\d+$/ && 
        $ures->{'replace_member_id'} != $self->{'member_id'} 
    ) {
        
        $self->{'member_id'} = $ures->{'replace_member_id'};
        
        eval {
          $sth = $dbh->prepare($uq);
          $sth -> execute($self->{'member_id'});$ures = $sth->fetchrow_hashref();
          $sth -> finish();
        };
        
        unless ($ures && (scalar $ures->{'user_isfound'})) {
            $self->{'last_state'} = 'replaced_user_missed';
            warn '***' . $self->{'last_state'};#? rewrite to mojo log
            $self->{'member_id'} = $self->{'member_id_real'};
            eval {
              $sth = $dbh->prepare($uq);
              $sth -> execute($self->{'member_id'});$ures = $sth->fetchrow_hashref();
              $sth -> finish();
            };
        }
        
        #${$self->{'profile'}}{'member_email'} = ;#email usefulier left orig?
        ${$self->{'profile'}}{'member_name'} = $ures->{'name'} if $ures->{'name'};
        
        $q = qq~ 
            SELECT 
                u.member_id, u.name, 
                a.awp_id, a.name AS awp_name, 
                r.role_id, r.name AS role_name,
                '1' AS is_slavers_slave
            FROM ${SESSION{PREFIX}}roles r 
                LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
                LEFT JOIN ${SESSION{PREFIX}}users u ON u.role_id=r.role_id 
            WHERE r.awp_id=~ . $ures->{'awp_id'} . qq~ 
                AND r.sequence>~ . $ures->{'role_sequence'} . qq~ 
            ORDER BY r.sequence ASC ~;
        if (scalar @{$self->{'slave_users_ids'}}) {
            $q .= qq~ AND u.member_id NOT IN (~ . (join ', ', @{$self->{'slave_users_ids'}}) . ') ';
        }
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute();
            while ($res = $sth->fetchrow_hashref()) {
                #commented to allow resort later, but 1 more query
                #push @{$self->{'slave_users'}}, {%{$res}};
                push @{$self->{'slave_users_ids'}}, $res->{'member_id'};
            }
            $sth -> finish();
        };
        
        $q = qq~
            SELECT u.member_id, u.name, 
                a.awp_id, a.name AS awp_name, 
                r.role_id, r.name AS role_name,
                '1' AS is_slavers_slave 
            FROM ${SESSION{PREFIX}}users_extrareplaces ue 
                LEFT JOIN ${SESSION{PREFIX}}users u ON r.role_id=ue.role_id 
                LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
                LEFT JOIN ${SESSION{PREFIX}}users u ON u.member_id=ue.slave_id 
            WHERE ue.member_id=~ . ($ures->{'member_id'}) . ' ';
        if (scalar @{$self->{'slave_users_ids'}}) {
            $q .= qq~ AND ue.slave_id NOT IN (~ . (join ', ', @{$self->{'slave_users_ids'}}) . ') ';
        }
        $q .= ' ; ';
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute();
            while ($res = $sth->fetchrow_hashref()) {
                #commented to allow resort later, but 1 more query
                #push @{$self->{'slave_users'}}, {%{$res}};
                push @{$self->{'slave_users_ids'}}, $res->{'member_id'};
            }
            $sth -> finish();
        };
        
    }
    
    if (
        scalar @{$self->{'slave_users_ids'}} && 
        scalar @{$self->{'slave_users_ids'}} != scalar @{$self->{'slave_users'}}
    ) {
    #there are some extra users need to be resorted

        $in_str = join ', ', @{$self->{'slave_users_ids'}};
    
        $self->{'slave_users'} = [];
        $self->{'slave_users_ids'} = [];

        #Slaves - users @ current awp which @roles with highter seq (under/slaved/etc)
        push @{$self->{'slave_users'}}, {
            member_id => $ures->{'member_id'}, 
            name => $ures->{'name'}, 
            awp_id => $ures->{'awp_id'}, 
            awp_name => $ures->{'awp_name'}, 
            role_id => $ures->{'role_id'}, 
            role_name => $ures->{'role_name'}, 
        };#user record itself
        push @{$self->{'slave_users_ids'}}, $ures->{'member_id'};

        $q = qq~ 
            SELECT 
                u.member_id, u.name, 
                a.awp_id, a.name AS awp_name, 
                r.role_id, r.name AS role_name 
            FROM ${SESSION{PREFIX}}users u 
                LEFT JOIN ${SESSION{PREFIX}}roles r ON r.role_id=u.role_id 
                LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
            WHERE 
                u.member_id IN (~ . $in_str . qq~) 
                AND 
                u.member_id!=~ . $ures->{'member_id'} . qq~ 
            ORDER BY a.sequence ASC, r.sequence ASC ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute();
            while ($res = $sth->fetchrow_hashref()) {
              push @{$self->{'slave_users'}}, {%{$res}};
              push @{$self->{'slave_users_ids'}}, $ures->{'member_id'};
            }
            $sth -> finish();
        };
    }
    
    $self->{'awp_id'} = $ures -> {'awp_id'};
    $self->{'awp_name'} = $ures -> {'awp_name'};
    $self->{'role_id'} = $ures -> {'role_id'};
    $self->{'role_name'} = $ures -> {'role_name'};
    ${$self->{'profile'}}{'member_name'} = $ures -> {'name '} if $ures -> {'name '};

    if (scalar $ures->{'member_id'}) { #no role alternatives for guests member_id=0 :)
        #Role alternatives - user can be allowed to switch his awp:role place
        $q = qq~ 
            SELECT 
                ra.member_id, 
                a.awp_id, a.name AS awp_name, 
                r.role_id, r.name AS role_name 
            FROM ${SESSION{PREFIX}}role_alternatives ra 
                LEFT JOIN ${SESSION{PREFIX}}roles r ON ra.role_id=r.role_id 
                LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
            WHERE ra.member_id = ? 
            ORDER BY a.sequence ASC, r.sequence ASC ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute($self->{'member_id'});
            while ($res = $sth->fetchrow_hashref()) {
              push @role_alternatives, $res->{'role_id'};
              push @{$self->{'role_alternatives'}}, {%{$res}};
              push @{$self->{'role_alternatives_ids'}}, $res->{'role_id'};
            }
            $sth -> finish();
        };
        
        if (scalar @role_alternatives) {
            unless (&inarray([@role_alternatives], $self->{'role_id'})) {
                $self->{'last_state'} = 'role_at_alts_missed';
                
                $dbh -> do("UNLOCK TABLES ; ");
                return undef;
            }
        }
    }
    
    unless (
        $SESSION{'USR_PERMISSIONS_PREFEDINED'} && 
            ref $SESSION{'USR_PERMISSIONS_PREFEDINED'} && 
                ref $SESSION{'USR_PERMISSIONS_PREFEDINED'} eq 'HASH' && 
                    defined ${$SESSION{'USR_PERMISSIONS_PREFEDINED'}}{$self->{'role_id'}} && 
                        ref ${$SESSION{'USR_PERMISSIONS_PREFEDINED'}}{$self->{'role_id'}} &&
                            ref ${$SESSION{'USR_PERMISSIONS_PREFEDINED'}}{$self->{'role_id'}} eq 'HASH' 
    ) {
        $q = qq~ 
            SELECT 
                pt.controller, pt.action, p.r, p.w 
            FROM ${SESSION{PREFIX}}permissions p 
                LEFT JOIN ${SESSION{PREFIX}}permission_types pt 
                    ON pt.permission_id=p.permission_id
            WHERE p.role_id = ?
                OR p.awp_id = ?
            ORDER BY pt.controller ASC, pt.action ASC ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute($self->{'role_id'}, $self->{'awp_id'});
            while ($res = $sth->fetchrow_hashref()) {
                ${$self->{'premissions'}}{$res->{'controller'}} = {} 
                    unless defined(${$self->{'premissions'}}{$res->{'controller'}});
                ${${$self->{'premissions'}}{$res->{'controller'}}}{$res->{'action'}} = {} 
                    unless defined(${${$self->{'premissions'}}{$res->{'controller'}}}{$res->{'action'}});
                ${${$self->{'premissions'}}{$res->{'controller'}}}{$res->{'action'}}{'r'} = 1
                    if $res->{'r'};#else it not even defined :)
                ${${$self->{'premissions'}}{$res->{'controller'}}}{$res->{'action'}}{'w'} = 1
                    if $res->{'w'};#also
                
                #delete if empty @ end
                delete ${${$self->{'premissions'}}{$res->{'controller'}}}{$res->{'action'}} 
                    unless scalar keys %{${${$self->{'premissions'}}{$res->{'controller'}}}{$res->{'action'}}};
                delete ${$self->{'premissions'}}{$res->{'controller'}} 
                    unless scalar keys %{${$self->{'premissions'}}{$res->{'controller'}}};
            }
            $sth -> finish();
        };
    }
    else {
        $self->{'premissions'} = ${$SESSION{'USR_PERMISSIONS_PREFEDINED'}}{$self->{'role_id'}};
    }
    $dbh -> do("UNLOCK TABLES ; ");
    return 1;
} #-- auth

sub register ($$$) {
    my (
        $self, $login, $password, # 0 1 2
        $email, $realname,  # 3 4 
        $role_id, # 5 
        $is_cms_active, #6
        $is_forum_active, $validation_code, # 7 8
        $startpage, $lang, # 9 10
        $skip_login_chk # 11
    ) = @_;

    my @deny_reasons = ('', 
        'undef_login', 
        'undef_pass',  
        'valcode_wrongfmt', 
        'login_email_pass_chk_fail', 
        'passwd_fmt_fail', 
        'email_chk_fmt_fail', 
        'passwd_gen_fail', 
        'username_taken', 
        'email_taken', 
        'forum_ins_query_fail', 
    );

    $role_id = defined($_[5])? &trim($_[5]):($SESSION{'DEFAULT_REG_ROLE'} || 0);

    my $is_cms_active = $_[6]? 1:0;    
    my $is_forum_active = $_[7]? 1:0;
    
    unless ($role_id =~ m/^\d+$/) {
        $self->{'last_state'} = 'wrong_role';
        return undef;
    }

    $startpage = $_[8]? &trim($_[8]) : '/';
    
    my $mode = $self->{'MODE'};
    my (
        $member_id, 
        $dbh, $q, $inscnt, 
    );
    $dbh = $SESSION{'DBH'};
    
    if ($mode eq 'smf') {
        $member_id = &_smf_register(
            $self, $login, $password, 
            $email, $realname, 
            $is_forum_active, $validation_code, 
            $skip_login_chk 
        );
    }
    else {
        $self->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    if (ref $member_id && ref $member_id eq 'HASH' && ${$member_id}{'member_id'} =~ /^\d+$/) {
        
        $dbh -> do(qq~ LOCK TABLES ${SESSION{PREFIX}}users WRITE ; ~);
        
        $q = qq~
            INSERT INTO 
            ${SESSION{PREFIX}}users (
                member_id, role_id, name, # 0 1 2
                site_lng, whoedit, startpage, # 3 4 5
                is_cms_active #6
            ) VALUES (
                ~ . ($dbh->quote(${$member_id}{'member_id'})) . q~, #0
                ~ . ($dbh->quote($role_id)) . q~, #1
                ~ . ($dbh->quote($realname)) . q~, #2
                ~ . ($dbh->quote($lang)) . q~, #3
                ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . q~, #4
                ~ . ($dbh->quote($startpage)) . q~, #5
                ~ . ($dbh->quote($is_cms_active)) . q~ #5
            ) ; ~;
            
            eval {
                $inscnt = $dbh->do($q);
            };
            
            unless (scalar $inscnt) {
                $dbh -> do("UNLOCK TABLES ; ");
                $self->{'last_state'} = 'users_ins_query_fail';

                &_smf_rm_record($self, ${$member_id}{'member_id'});
                return undef;
            }

        $dbh -> do("UNLOCK TABLES ; ");
        return $member_id; #{member_id => \d+, valcode => \w+}
        
    }
    else{
        $self->{'last_state'} = $deny_reasons[($member_id*(-1))];
        return undef;
    }
    
    return undef;
    
} #-- register

sub register_hs ($$) {
    #hashed api to &register
    my $self = $_[0];
    my $cfg = $_[1];
    return undef unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return &register(
        $self, ${$cfg}{'login'}, ${$cfg}{'password'}, # 0 1 2
        ${$cfg}{'email'}, ${$cfg}{'name'}, # 3 4
        ${$cfg}{'role_id'}, # 5
        ${$cfg}{'is_cms_active'}, #6
        ${$cfg}{'is_forum_active'}, ${$cfg}{'validation_code'}, #7 8
        ${$cfg}{'startpage'}, ${$cfg}{'lang'}, #9 10
        ${$cfg}{'skip_login_chk'} #11
    );
}

sub login($;$$$$$) {
    my $self = $_[0];

    my @deny_reasons = ('', 
        'undef_login', 
        'undef_pass_or_passhash',  
        'wronglogin', 
        'worngpass', 
    );

    my $usrname = $_[1]? &trim($_[1]):$SESSION{'REQ'}->param('user');
        unless (defined $usrname) {$self->{'last_state'} = $deny_reasons[((-1)*(-1))]; return undef;}
    my $usrpass = defined($_[2])? &trim($_[2]):$SESSION{'REQ'}->param('passwrd');
    my $passhash = defined($_[3])? &trim($_[3]):$SESSION{'REQ'}->param('hash_passwrd');
        unless (defined($usrpass) || defined($passhash)) {$self->{'last_state'} = $deny_reasons[((-2)*(-1))]; return undef;};
    
    my $cookielength = defined($_[4])? &trim($_[4]):$SESSION{'REQ'}->param('cookielength');

    my $rememberme = defined($_[5])? $_[5]:$SESSION{'REQ'}->param('rememberme');

    if($SESSION{'CAPTCHA'} && !$SESSION{'CAPTCHA'}->{'check_mjcaptcha'}()){
        $self->{'last_state'} = 'captcha_failed';
        return undef;
    }

    my $mode = $self->{'MODE'};
    my (
        $member_id, 
        $timeuntil, $rem_cookie, 
    );
    
    if($rememberme){
        $timeuntil = time() + 155520000; #psas@coockie expire [secs since yr 1970] = (now +5 years)
        $cookielength = -1 unless $cookielength =~ m/^\-{0,1}\d+$/;
        
        $rem_cookie = Mojo::Cookie::Response->new;
        $rem_cookie->name($SESSION{'REM_COOKIE'});
        $rem_cookie->domain($SESSION{'SERVER_NAME'}) if $SESSION{'SERVER_NAME'} =~ /\w+\.\w+/;#2 segments min rfc
        $rem_cookie->path('/');
        $rem_cookie->httponly(1);# no js access on client-side
        $rem_cookie->expires($timeuntil);
        $rem_cookie->comment($SESSION{'SERVER_NAME'}.':'.$SESSION{'SERVER_PORT'}.' Auth remember cookie');
        $rem_cookie->value($usrname . '|' . $cookielength);#time_for - is only digit (\-)?\d+ [for correct re parsing backwards]!
        $SESSION{'COOKIES_RES'}{$SESSION{'REM_COOKIE'}} = $rem_cookie;
    }
    
    if ($mode eq 'smf') {
        $member_id = &_smf_login($self, $usrname, $usrpass, $passhash, $cookielength);
        if (ref $member_id && ref $member_id eq 'HASH' && ${$member_id}{'member_id'} =~ /^\d+$/) {
             ${$self->{'profile'}}{'startpage'} = ${$member_id}{'startpage'}? ${$member_id}{'startpage'}:'/';
             $self->{'member_id'} = $self->{'member_id_real'} = ${$member_id}{'member_id'};
             return 1;
        }
        else {
            $self->{'last_state'} = $deny_reasons[($member_id*(-1))];
            return undef;
        }
    }
    else {
        $self->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;

} #-- login

sub login_hs ($$$;) {
    #hashed api to &login
    my $self = $_[0];
    my $cfg = $_[1];
    return undef unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    return &login(
        $self, ${$cfg}{'login'}, ${$cfg}{'password'}, # 0 1 2
        ${$cfg}{'passhsh'}, ${$cfg}{'cookielength'}, # 3 4
        ${$cfg}{'rememberme'}, # 5
    );
}

sub logout($) {
    my $self = $_[0];

    my $mode = $self->{'MODE'};
    
    if ($mode eq 'smf') {
        &_smf_logout($self);
        return 1;
    }
    else {
        $self->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;
    
} #-- logout

sub chk_access($$;$$) {
    my $self = $_[0];
    my $controller = $_[1];
    my $action = $_[2];
    my $mode = $_[3]? $_[3]:'r';# r || w
    
    return 0 if (!$controller || lc($mode) !~ /^(r|w)$/);
    
    if ($controller && $action && $mode) {
        unless (ref $action ) {
            return defined($self->{'premissions'}->{$controller}->{$action}->{$mode})? 1:0;
        }
        elsif (ref $action && ref $action eq 'ARRAY' && scalar @{$action}) {
            foreach my $action_opt (@{$action}){
                return 1 if 
                    defined($self->{'premissions'}->{$controller}->{$action_opt}->{$mode});
            }
            return 0;
        }
        else{
            return 0;
        }
        return 0;
    }
    
    return 0;
} #-- chk_access

sub get_usersddata ($$) {
    #is this sub used smw currently? get_users should be much better. but this faster
    #may be for user sw, there are need only role/name data by id
    my $self = $_[0];
    my $users_ids = $_[1];
    my $mode = $_[2]? $_[2]:'as_array';
    
    return {error => 'user_ids is not set'}  unless $users_ids;
    
    unless (ref $users_ids && ref $users_ids eq 'ARRAY'){
        $users_ids = [$users_ids];
    }
    
    my (
        $dbh, $sth, $res, $q, 
        $in_str, @members, %members
        
    ) = ($SESSION{'DBH'}, );
    
    if ( !(scalar @{$users_ids}) || (scalar (grep(/\D/, @{$users_ids}))) ) {
        return {error => 'user_ids count is not enough'};
    }
    
    $in_str = join ', ', @{$users_ids};
    
    $q = qq~
        SELECT 
            u.member_id, u.role_id, u.name, 
            u.role_id, r.awp_id, u.site_lng, 
            a.name AS awp_name, a.sequence AS awp_sequence, 
            r.name AS role_name, r.sequence AS role_sequence 
        FROM ${SESSION{PREFIX}}users u 
            LEFT JOIN ${SESSION{PREFIX}}roles r ON r.role_id=u.role_id 
            LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
        WHERE u.member_id IN ( ? ) 
        ORDER BY a.sequence ASC, r.sequence ASC ; 
    ~;
    
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute($in_str);
            if ($mode eq 'as_array') {
                while ($res = $sth->fetchrow_hashref()) {
                  push @members, {%{$res}};
                }
            }
            else {
                while ($res = $sth->fetchrow_hashref()) {
                  $members{$res->{'member_id'}} = {%{$res}};
                }
            }
            $sth -> finish();
            
        };
    
    return {
        q => $q, 
        data_hash => \%members, 
        data_arr => \@members, 
    };
    
} #-- get_usersddata

sub is_user_writable ($$) {
    my ($self, $member_id) = @_;
    
    return undef unless $member_id =~ /^\d+$/;
    
    return 1 if 
        (
            $member_id == $self->{'member_id'} || 
            &inarray($self->{'slave_users_ids'}, $member_id) 
        );
    return undef;
} #-- is_user_writable

sub users_get ($;$) {
    my $self = shift;
    my $cfg = shift;
    $cfg = {} unless $cfg;

    my $mode = $self->{'MODE'};
    my $users;
    
    if ($mode eq 'smf') {
        $users = &_smf_get_users($self, $cfg);
        
    }
    else {
        $self->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    my (
        $dbh, $sth, $res, $q, 
        
    ) = ($SESSION{'DBH'}, );

    if (
        ${$cfg}{'getreplaces'} && 
            $users && 
                ref $users && 
                    ref $users eq 'HASH' && 
                        scalar @{${$users}{'users_ids'}}
    ) {
        
        ${$users}{'users_extrareplaces'} = {};
        $q = qq~
            SELECT member_id, slave_id 
            FROM ${SESSION{PREFIX}}users_extrareplaces 
            WHERE member_id IN ( ~ . (join ', ', @{${$users}{'users_ids'}}) . q~ ) ; ~;
        ${$users}{'q_er'} = $q;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute();
            while ($res = $sth->fetchrow_hashref()) {
                ${${$users}{'users_extrareplaces'}}{$res -> {'member_id'}} = []
                    unless defined ${${$users}{'users_extrareplaces'}}{$res -> {'member_id'}};
                push @{${${$users}{'users_extrareplaces'}}{$res -> {'member_id'}}}, $res -> {'slave_id'};
            }
            $sth -> finish();
        };
        
    }
    
    if (
        ${$cfg}{'getrolealternatives'} && 
            $users && 
                ref $users && 
                    ref $users eq 'HASH' && 
                        scalar @{${$users}{'users_ids'}}
    ) {
        
        ${$users}{'users_rolealternatives'} = {};
        $q = qq~
            SELECT member_id, role_id 
            FROM ${SESSION{PREFIX}}role_alternatives 
            WHERE member_id IN ( ~ . (join ', ', @{${$users}{'users_ids'}}) . q~ ) ; ~;
        ${$users}{'q_ra'} = $q;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute();
            while ($res = $sth->fetchrow_hashref()) {
                ${${$users}{'users_rolealternatives'}}{$res -> {'member_id'}} = {}
                    unless defined ${${$users}{'users_rolealternatives'}}{$res -> {'member_id'}};
                ${${${$users}{'users_rolealternatives'}}{$res -> {'member_id'}}}{$res -> {'role_id'}} 
                    = 1;
            }
            $sth -> finish();
        };
        
    }
    
    return $users;
    
} #-- users_get

sub change_email ($$;$){
    my $self = $_[0];
    my $email = $_[1];
    my $member_id = defined($_[2])? $_[2]:$self->{'member_id'};

    my $mode = $self->{'MODE'};
    
    if ($mode eq 'smf') {
        return &_smf_change_email($self, $email, $member_id);
        
    }
    else {
        $self->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;
} #-- change_email

sub change_password ($$$;$) {
    my $self = $_[0];
    my $pass = $_[1];
    my $pass_retype = $_[2];
    my $member_id = defined($_[3])? $_[3]:$self->{'member_id'};

    my $mode = $self->{'MODE'};
    
    if ($mode eq 'smf') {
        return &_smf_change_password($self, $pass, $pass_retype, $member_id);
        
    }
    else {
        $self->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;
} #-- change_password

sub set_cms_active ($$;$){
    my $self = $_[0];
    my $status = $_[1];
    my $member_id = defined($_[2])? $_[2]:$self->{'member_id'};
    
    $status = $status? 1:0;
    
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
}

sub set_forum_active ($$;$){
    my $self = $_[0];
    my $status = $_[1];
    my $member_id = defined($_[2])? $_[2]:$self->{'member_id'};
    
    $status = $status? 1:0;

    my $mode = $self->{'MODE'};
    
    if ($mode eq 'smf') {
        return &_smf_change_active($self, $status, $member_id);
        
    }
    else {
        $self->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;
}

1;
