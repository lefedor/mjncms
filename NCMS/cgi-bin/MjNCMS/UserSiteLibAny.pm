package MjNCMS::UserSiteLibAny;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use Digest::SHA1 qw/sha1_hex /;#smf reg requirement

BEGIN {
    use Exporter ();
    use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS /;
    @ISA         = qw/Exporter /;
    @EXPORT      = qw/ /;
    @EXPORT_OK   = qw/ /;
    
    %EXPORT_TAGS = (
      vars => [qw/ /],
      subs => [qw/

        _smf_gen_pass 

        _smf_chk_pass 
        chk_pass 

        _smf_get_user 
        users_get 
        get_users 
        
    /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
    
}

########################################################################
#                 Functions to read user data @ admin
########################################################################
#                   Driver-specific subs
########################################################################

sub _smf_gen_pass ($$;$) {
    
    my $login = shift;
    my $password = shift;
    
    return undef unless (
        $login && length $login &&
        $password && length $password 
    );
    
    return sha1_hex(lc($login) . $password);
    
}

sub _smf_chk_pass ($$$) {
    
    my (
        $password, $passhash, 
        $member_id, 
    ) = @_;
    
    return undef unless $member_id =~ /^\d+$/;
    
    return undef unless ($password || $passhash);

    my (
        $dbh, 
        $q, $sth, $res, 
        $sessid, 
        
    ) = (
        $SESSION{'DBH'},
    );
    
    $q = qq~ 
        SELECT 
            ID_MEMBER AS member_id, 
            passwd, memberName AS login
        FROM ${SESSION{FORUM_PREFIX}}members 
        WHERE ID_MEMBER = ? 
        LIMIT 0, 1; 
    ~;
    eval {
      $sth = $dbh->prepare($q);
      $sth -> execute($member_id);$res = $sth->fetchrow_hashref();
      $sth -> finish();
    };
    
    $sessid = $SESSION{'USR'}->{'PHP_SESSID'};
    $sessid = '' unless $sessid;
    $passhash = sha1_hex(&_smf_gen_pass($res->{'login'}, $password) . $sessid) unless $passhash;
    
    #If password match
    if (sha1_hex($res->{'passwd'} . $sessid) eq $passhash) {
        return 1;
    }
    
    return 0;
    
} #-- _smf_chk_pass

sub _smf_get_users ($) {
    
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
        $where_rule .= ' AND u.name = ' . $dbh->quote(${$cfg}{'name'}) . ' ';
    }
    
    if (defined ${$cfg}{'name_like'} && length ${$cfg}{'name_like'}){
        ${$cfg}{'name_like'} = $dbh->quote(${$cfg}{'name_like'});
        ${$cfg}{'name_like'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND u.name LIKE \'' . ${$cfg}{'name_like'} . '\' ';
    }
    
    if (defined ${$cfg}{'login'} && length ${$cfg}{'login'}){
        $where_rule .= ' AND m.memberName = ' . ($dbh->quote(${$cfg}{'login'})) . ' ';
    }
    
    if (defined ${$cfg}{'login_like'} && length ${$cfg}{'login_like'}){
        ${$cfg}{'login_like'} = $dbh->quote(${$cfg}{'login_like'});
        ${$cfg}{'login_like'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND m.memberName LIKE \'' . ${$cfg}{'login_like'} . '\' ';
    }
    
    if (defined ${$cfg}{'email'} && length ${$cfg}{'email'}){
        $where_rule .= ' AND m.emailAddress = ' . ($dbh->quote(${$cfg}{'email'})) . ' ';
    }
    
    if (defined ${$cfg}{'email_like'} && length ${$cfg}{'email_like'}){
        ${$cfg}{'email_like'} = $dbh->quote(${$cfg}{'email_like'});
        ${$cfg}{'email_like'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND m.emailAddress LIKE \'' . ${$cfg}{'email_like'} . '\' ';
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
            
            u.salt, #10.5 :)
            
            m.memberName AS login, #11
            m.realName AS forum_name, #12
            m.emailAddress AS email, #13
            m.timeOffset AS time_offset, #14
            m.is_activated AS is_forum_active, #15
            m.validation_code AS val_code, #16
            
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
                    
                    NULL, #10.5
                    
                    m.memberName AS login, #11
                    m.realName AS forum_name, #12
                    m.emailAddress AS email, #13
                    m.timeOffset AS time_offset, #14
                    m.is_activated, #15
                    m.validation_code AS val_code, #16
                    
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


########################################################################
#                           Universal calls
########################################################################


sub chk_pass ($;$$) {
    
    #Check if typed pass correct - profile update, etc 
    
    my (
        $password, $passhash, 
        $member_id, 
    ) = @_;

    $member_id = $SESSION{'USR'}->{'member_id'} 
        unless defined $member_id;
    
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
        return &_smf_chk_pass(
            $password, $passhash, 
            $member_id, 
        );
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;

} #-- chk_pass

sub users_get ($) {
    
    my $cfg = shift;
    
    $cfg = {} unless $cfg;

    my $mode = $SESSION{'USR'}->{'MODE'};
    my $users;
    
    if ($mode eq 'smf') {
        $users = &_smf_get_users($cfg);
        
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    my (
        $dbh, $sth, $res, $q, 
        
    ) = ($SESSION{'DBH'}, );

    if (
        ${$cfg}{'getreplaces'} && 
            $users && 
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

sub get_users ($) {

    my $cfg = shift;
    
    return &users_get($cfg);
    
} #-- get_users

1;
