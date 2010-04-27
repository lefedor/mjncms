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
use MjNCMS::UserSiteLibRead qw/:subs /;

use Mojo::Cookie::Response;

use Digest::SHA1 qw/sha1_hex /;#smf reg requirement

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
  
  $self->{'PHP_SESSID'} = '';
  
  #$self->{'SESS'} = {};
  $self->{'SESSID'} = {};
  
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
#                           internal calls
########################################################################


sub _smf_auth ($;$) {
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
        member_login => 'guest', 
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
            if (
                $res->{'id_member'} && #is_found
                sha1_hex(($res->{'passwd'}) . ($res->{'passwordsalt'})) eq $cookie_passhash
            ) {
                return {
                    member_id => $cookie_member_id, 
                    member_email => $res->{'emailaddress'}, 
                    member_login => $res->{'membername'}, 
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


########################################################################
#                       public calls
########################################################################


sub auth ($) {
    
    #
    # Bender: I'm not giving my name to a machine!
    #
    
    my $self = $_[0];
    
    my $mode = $self->{'MODE'};
    
    my $auth_member = undef;
    if ($mode eq 'smf') {
        $auth_member = &_smf_auth($self);
        
        $auth_member = {member_id => 0, } unless (ref $auth_member eq 'HASH');
        $self->{'member_id'} = (defined($auth_member->{'member_id'}) && scalar $auth_member->{'member_id'})? (scalar $auth_member->{'member_id'}):0;
        $self->{'member_is_forum_active'} = defined($auth_member->{'member_is_active'})? $auth_member->{'member_is_active'}:$SESSION{'GUESTUSER_ISACTIVE'};
        ${$self->{'profile'}}{'member_email'} = $auth_member->{'member_email'} if $auth_member->{'member_email'};
        ${$self->{'profile'}}{'member_name'} = $auth_member->{'member_name'} if $auth_member->{'member_name'};
        ${$self->{'profile'}}{'member_login'} = $auth_member->{'member_login'} if $auth_member->{'member_login'};
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

    $self -> {'PHP_SESSID'} = $SESSION{'PHP_SESSID'};
        
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
        
        #Or once logged user will need wipe cookies by hands :)
        $self->logout();
        
        $dbh -> do("UNLOCK TABLES ; ");
        return undef;
    }
    
    $self->{'member_sitelng'} = #real lang used everywhere /jp/some - content in japan lang, 4example
        ${$self->{'profile'}}{'member_lang'} = #lang @ profile
            $ures->{'site_lng'} if $ures->{'site_lng'};
    
    #This will be done @MjncmsInit, also if lang defined @cfg will be checked
    #$SESSION{'LOC'}->set_lang($self->{'member_sitelng'});
    
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
                AND u.member_id!=~ . $ures->{'member_id'} . qq~ 
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
            SELECT 
                u.member_id, u.name, 
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
                #comment to allow resort later, but 1 more query
                push @{$self->{'slave_users'}}, {%{$res}};
                push @{$self->{'slave_users_ids'}}, $res->{'member_id'};
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
            SELECT 
                u.member_id, u.name, 
                a.awp_id, a.name AS awp_name, 
                r.role_id, r.name AS role_name,
                '1' AS is_slavers_slave 
            FROM ${SESSION{PREFIX}}users_extrareplaces ue 
                #LEFT JOIN ${SESSION{PREFIX}}users u ON r.role_id=ue.role_id  #WTF? o_0
                LEFT JOIN ${SESSION{PREFIX}}users u ON u.member_id=ue.slave_id 
                LEFT JOIN ${SESSION{PREFIX}}awps a ON a.awp_id=r.awp_id 
                LEFT JOIN ${SESSION{PREFIX}}users u ON u.member_id=ue.slave_id 
            WHERE ue.member_id=~ . ($ures->{'member_id'}) . ' ';
        if (scalar @{$self->{'slave_users_ids'}}) {
            $q .= qq~ AND ue.slave_id NOT IN (~ . (join ', ', @{$self->{'member_id'}}) . ') ';
        }
        $q .= ' ; ';
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute();
            while ($res = $sth->fetchrow_hashref()) {
                #commented to allow resort later, but 1 more query
                #push @{$self->{'slave_users'}}, {%{$res}};
                push @{$self->{'slave_users_ids'}}, $res->{'slave_id'};
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
    ${$self->{'profile'}}{'member_name'} = $ures -> {'name'} if $ures -> {'name'};

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

1;
