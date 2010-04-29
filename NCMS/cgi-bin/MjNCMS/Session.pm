package MjNCMS::Session;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Proffesor: I'm sciencing as fast as I can!
# (c) Futurama
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use Digest::SHA1 qw/sha1_hex /;
use Storable  qw/freeze thaw /;

sub new {
  my $self = {}; shift;
  
  $self->{'SESSID'} = undef;
  $self->{'DATA'} = {};
  $self->{'_HAS_CHANGED'} = 0;
  
  bless $self;
  return $self
  
} #-- new

sub _gen_sess_id ($) {
    my $self = shift;
    
    return sha1_hex((time()).(rand(time)).(rand()))
} #-- _gen_sess_id

sub get_sess_id ($) {
    my $self = shift;
    
    return $self->{'SESSID'};
} #-- get_sess_id

sub set_sess_id ($$) {
    my $self = shift;
    my $sess_id = shift;
    
    return undef unless $sess_id;
    
    $self->{'SESSID'} = $sess_id;
    
    return $self;
    
} #-- set_sess_id

sub load_data ($$) {
    my $self = shift;
    my $data = shift;
    
    return undef unless $data && (ref $data eq 'HASH');
    
    $self->{'DATA'} = {%{$data}};
    
    return $self;
    
} #-- load

sub unload_data ($) {
    my $self = shift;
    
    return {%{$self->{'DATA'}}};
    
} #-- unload

sub start_session ($) {
    my $self = shift;
    
    my (
        $dbh, $steps, $cnt_chk, $q,
        $mjncms_sess_cookie, 
        $mjncms_session, $mjn_sess_id, 
        $ips, $inscnt, 
    ) = ($SESSION{'DBH'}, 100, 0, );
    
    $mjncms_sess_cookie = $SESSION{'COOKIES_REQ'}{$SESSION{'SESS_COOKIE'}};
    
    if (
        $mjncms_sess_cookie && 
        (
            $mjn_sess_id = $mjncms_sess_cookie->value()
        )
    ) { 
        if (
            $SESSION{'MEMD'} && 
            $SESSION{'MEMD_CACHE_OPTS'}->{'sessions'} && 
            $SESSION{'MEMD_CACHE_OPTS'}->{'sessions'}->{'prefix'} 
        ) {
            $mjncms_session = $SESSION{'MEMD'}->get(
                $SESSION{'MEMD_CACHE_OPTS'}->{'sessions'}->{'prefix'} . 
                $mjn_sess_id
            );
            
            unless (
                $mjncms_session && 
                (ref $mjncms_session eq 'HASH') #&& 
                #${$mjncms_session}{'member_id'} == $SESSION{'USR'}->{'member_id'}
            ) {
                $mjncms_session = undef;
            }
        }
        
        unless ($mjncms_session) {
            #AND member_id =~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . 
            $q = qq~
                SELECT 
                    data
                FROM ${SESSION{PREFIX}}sessions 
                WHERE 
                    session_id =~ . $dbh->quote($mjn_sess_id) . '; ';
            
            eval {
                ($mjncms_session, ) = $dbh -> selectrow_array($q);
            };
            
            $mjncms_session = thaw($mjncms_session) if $mjncms_session;
            
            unless (
                $mjncms_session && 
                (ref $mjncms_session eq 'HASH') #&& 
                #${$mjncms_session}{'member_id'} == $SESSION{'USR'}->{'member_id'}
            ) {
                $mjncms_session = undef;
            }
        }
    }
    
    unless ($mjncms_session) {
        $mjncms_sess_cookie = undef;
    }
    
    unless (
        $mjncms_sess_cookie 
    ) { 
        
        if ($SESSION{'USR'}->{'member_id'}) {
            $q = qq~
                SELECT 
                    session_id, data 
                FROM ${SESSION{PREFIX}}sessions 
                WHERE member_id =~ . 
                    ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~
                ORDER BY upd DESC 
                LIMIT 0, 1 ; ~;
            ($mjn_sess_id, $mjncms_session) = $dbh -> selectrow_array($q);
            
            $mjncms_session = thaw($mjncms_session) if $mjncms_session;
            
        }
        
        unless (
            $mjn_sess_id && 
            $mjncms_session 
        ) {
            
            eval {
                $dbh -> do("LOCK TABLES ${SESSION{PREFIX}}sessions WRITE ; ");
            };
            
            $ips = &sv_getips();
            
            while ($steps > 0) {
                $mjn_sess_id = $self->_gen_sess_id();
                
                if (
                    $SESSION{'MEMD'} && 
                    $SESSION{'MEMD_CACHE_OPTS'}->{'sessions'} && 
                    $SESSION{'MEMD_CACHE_OPTS'}->{'sessions'}->{'prefix'} && 
                    $SESSION{'MEMD'}->get(
                        $SESSION{'MEMD_CACHE_OPTS'}->{'sessions'}->{'prefix'} . 
                        $mjn_sess_id
                    )
                ) {
                    $steps--;
                    next;
                }
                
                $cnt_chk = 0;
                $q = qq~
                    SELECT COUNT(*) AS cnt 
                    FROM ${SESSION{PREFIX}}sessions 
                    WHERE session_id =~ . $dbh->quote($mjn_sess_id) . '; ';
                eval {
                    ($cnt_chk, ) = $dbh -> selectrow_array($q);
                };
                

                if ($cnt_chk) {
                    $steps--;
                    next;
                }
                
                last;
            }
            
            return undef unless $steps;
            
            $mjncms_session = freeze {};
            
            $q = qq~
                INSERT INTO 
                ${SESSION{PREFIX}}sessions ( 
                    session_id, member_id, 
                    data, 
                    start_remote, start_proxy, start_proxyclient 
                ) VALUES (
                    ~ . ($dbh->quote($mjn_sess_id)) . qq~, 
                    ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
                    ~ . ($dbh->quote($mjncms_session)) . qq~, 
                    ~ . ($dbh->quote(${$ips}{'remote'})) . qq~, 
                    ~ . ($dbh->quote(${$ips}{'proxy'})) . qq~, 
                    ~ . ($dbh->quote(${$ips}{'proxyclient'})) . qq~ 
                ) ; 
            ~;
            eval {
                $inscnt = $dbh->do($q);
            };
            
            eval{
                $dbh -> do("UNLOCK TABLES ; ");
            };
            
            $mjncms_session = {};
        }
        
        $mjncms_sess_cookie = Mojo::Cookie::Response->new;
        $mjncms_sess_cookie->name($SESSION{'SESS_COOKIE'});
        $mjncms_sess_cookie->domain($SESSION{'SERVER_NAME'}) if $SESSION{'SERVER_NAME'} =~ /\w+\.\w+/;#2 segments min rfc
        $mjncms_sess_cookie->path('/');
        $mjncms_sess_cookie->httponly(1);# no js access on client-side
        $mjncms_sess_cookie->expires($SESSION{'COOKIE_FOREVER_TIME'});
        $mjncms_sess_cookie->comment($SESSION{'SERVER_NAME'}.':'.$SESSION{'SERVER_PORT'}.' SESSION cookie');
        $mjncms_sess_cookie->value($mjn_sess_id);
        $SESSION{'COOKIES_RES'}{$SESSION{'SESS_COOKIE'}} = $mjncms_sess_cookie;
            
    }

    $self->{'SESSID'} = $mjn_sess_id;
    $self->{'DATA'} = $mjncms_session;
    $self->{'_HAS_CHANGED'} = 0;
    
    return $self;
            
} #-- start_session

sub store_session ($) {
    my $self = shift;
    
    return $self unless $self->{'_HAS_CHANGED'};
    
    my $mjn_sess_id = $self->{'SESSID'};
        return undef unless $mjn_sess_id;
    my $mjncms_session = $self->{'DATA'};
        return undef 
            unless $mjncms_session && 
            ref $mjncms_session eq 'HASH';

    my (
        $dbh, $q, $ips, 
        $updcnt, 
        
    ) = ($SESSION{'DBH'}, );
    
    $ips = &sv_getips();
    
    if (
        $SESSION{'MEMD'} && 
        $SESSION{'MEMD_CACHE_OPTS'}->{'sessions'} && 
        $SESSION{'MEMD_CACHE_OPTS'}->{'sessions'}->{'prefix'} 
    ) {
        $SESSION{'MEMD'}->set(
            $SESSION{'MEMD_CACHE_OPTS'}->{'sessions'}->{'prefix'} . 
            $mjn_sess_id, 
            $mjncms_session
        );
    }
    
    $mjncms_session = freeze $mjncms_session;
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}sessions 
        SET 
            member_id = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            data = ~ . ($dbh->quote($mjncms_session)) . qq~, 
            last_remote = ~ . ($dbh->quote(${$ips}{'remote'})) . qq~, 
            last_proxy = ~ . ($dbh->quote(${$ips}{'proxy'})) . qq~, 
            last_proxyclient = ~ . ($dbh->quote(${$ips}{'proxyclient'})) . qq~ 
        WHERE session_id = ~ . ($dbh->quote($mjn_sess_id)) . qq~ ; 
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };
    
    return undef unless scalar $updcnt;
    
    return $self;
    
} #-- store_session

sub close_session ($) {
    my $self = shift;
    
    my $mjncms_sess_cookie = Mojo::Cookie::Response->new;
    $mjncms_sess_cookie->name($SESSION{'SESS_COOKIE'});
    $mjncms_sess_cookie->domain($SESSION{'SERVER_NAME'}) if $SESSION{'SERVER_NAME'} =~ /\w+\.\w+/;#2 segments min rfc
    $mjncms_sess_cookie->path('/');
    $mjncms_sess_cookie->httponly(1);# no js access on client-side
    $mjncms_sess_cookie->expires($SESSION{'COOKIE_FOREVER_TIME'});
    $mjncms_sess_cookie->comment($SESSION{'SERVER_NAME'}.':'.$SESSION{'SERVER_PORT'}.' SESSION cookie');
    $mjncms_sess_cookie->value('');
    $SESSION{'COOKIES_RES'}{$SESSION{'SESS_COOKIE'}} = $mjncms_sess_cookie;
    
    return $self;
} #-- close_session

sub get ($$) {
    my $self = shift;
    my $key = shift;
    
    return undef unless $key;
    
    return ${$self->{'DATA'}}{$key};
} #-- get

sub set ($$;$) {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    
    $self->{'_HAS_CHANGED'} = 1;
    
    unless (defined $value) {
        delete ${$self->{'DATA'}}{$key};
        #return 1;
        return undef;
    }
        
    return ${$self->{'DATA'}}{$key} = $value;
} #-- set

1;
