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

BEGIN{
    use Exporter ();
    use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    @ISA         = qw(Exporter);
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    
    %EXPORT_TAGS = (
      vars => [qw()],
      subs => [qw(
        session_get session_store session_store_todb
        
    )],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
}

sub session_get($){
    #look @memd, than db, if no - create clean one
    my $sess_id = $_[0];
    
    my ($dbh, $q, $cnt_chk, $inscnt) = ($SESSION{'DBH'}, undef, 1);
    while(){
        $sess_id = $SESSION{'BS'}(rand())->md5_sum()->to_string();
        next if ($SESSION{'MEMD'} && $SESSION{'MEMD'}->get($sess_id));
        $q = "SELECT COUNT(*) AS cnt FROM ${SESSION{PREFIX}}session WHERE session_id=" . $dbh->quote($sess_id) . '; ';
        eval{
            ($cnt_chk, ) = $dbh -> selectrow_array($q);
        };
        next if $cnt_chk;
        $q = qq~
            INSERT INTO ${SESSION{PREFIX}}sessions 
                (session_id ,data) 
            VALUES 
                ($sess_id, '')
            ;
        ~;
        eval{
            $inscnt = $dbh -> do($q);
        };
        last if $inscnt;
    }
    return {
        sess_id => $sess_id,
        
    };
}

sub session_store(;$){
    #store to memd
    my $serobj = Data::Serializer->new(
        serializer => 'Storable',
        digester   => 'MD5',
        cipher     => 'DES',
        secret     => $SESSION{'CRYPT_KEY'},
        compress   => 1,
    );
    my $dumped_data = $serobj->serialize($SESSION{'SESS'});
}

sub session_store_todb(;$){
    #get from memd if !$SESSION{'SESS'}, store to db, rm from memd
    
}

1;
