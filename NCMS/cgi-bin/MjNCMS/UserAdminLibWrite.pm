package MjNCMS::UserAdminLibWrite;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
#use MjNCMS::Service qw/:subs /;


########################################################################
#                 Functions to read user data @ admin
########################################################################
#                   Driver-specific subs
########################################################################


sub _smf_change_active ($$) {
    
    my $status = shift;
    my $member_id = shift;
    
    unless ($member_id =~ /^\d+$/) {
        $SESSION{'USR'}->{'last_state'} = 'wrong_member_id';
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
            $SESSION{'USR'}->{'last_state'} = 'update forum members table fail';
            return undef;
        }
        
    }
    
    return 1;
    
} #-- _smf_change_active


########################################################################
#                           Universal calls
########################################################################


sub set_forum_active ($;$){
    
    my $status = $_[0];
    my $member_id = defined($_[1])? $_[1]:$SESSION{'USR'}->{'member_id'};
    
    $status = $status? 1:0;
    
    #?
    return undef unless (
        $member_id == $SESSION{'USR'}->{'member_id'} || 
        $SESSION{'USR'}->is_user_writable( $member_id ) || 
        $SESSION{'USR'}->chk_access('users', 'manage', 'w') 
    );
    
    my $mode = $SESSION{'USR'}->{'MODE'};
    
    if ($mode eq 'smf') {
        return &_smf_change_active($status, $member_id);
        
    }
    else {
        $SESSION{'USR'}->{'last_state'} = 'wrong_auth_mode';
        return undef;
    }
    
    return undef;
    
} #-- set_forum_active

1;
