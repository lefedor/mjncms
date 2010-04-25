package MjNCMS::UserSiteLibRead;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
#use MjNCMS::Service qw/:subs /;

use MjNCMS::UserSiteLibAny qw/:subs /;

use Mojo::Cookie::Response;

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
       _smf_chk_pass
       _smf_logout
       logout

        
    /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
    
}



########################################################################
#                 Functions to write user data @ site
########################################################################
#                   Driver-specific subs
########################################################################

sub _smf_logout ($) {
    
    my $self = $_[0] || $SESSION{'USR'};
    
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

########################################################################
#                           Universal calls
########################################################################


sub logout ($) {

    my $self = $_[0] || $SESSION{'USR'};

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

1;
