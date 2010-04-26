package MjNCMS::Plugin::MjncmsSessions;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Req MjncmsInit plugin loaded alredy 
#

#
# Proffesor: I'm sciencing as fast as I can!
# (c) Futurama
#

use common::sense;
use base 'Mojolicious::Plugin';

use FindBin;
use lib "$FindBin::Bin/../../";

use MjNCMS::Config qw/:subs :vars /;
#use MjNCMS::Service qw/:subs /;
use MjNCMS::Session;

sub register {
    my ($self, $app, $args) = @_;
    $args ||= {};

    $app->plugins->add_hook(
        before_dispatch => sub {
            my ($self, $c) = @_;
            
            $SESSION{'SESSION'} = MjNCMS::Session->new()->init_session();
            
            if ($SESSION{'SESSION'}) {
                
                $SESSION{'USR'}->{'SESSID'} = $SESSION{'SESSION'}->get_sess_id();
                #$SESSION{'USR'}->{'SESS'} = $SESSION{'SESSION'}->unload();
                
            }
            
            return 1;
        },
        
    );
    
        
    $app->plugins->add_hook(
        after_dispatch => sub {
            my ($self, $c) = @_;
            
            if ($SESSION{'SESSION'}) {
                
                $SESSION{'USR'}->{'SESSID'} = undef;
                #$SESSION{'SESSION'}->load($SESSION{'USR'}->{'SESS'});
                
                $SESSION{'SESSION'}->store_session();
                
            }
            
            return 1;
        },

    );
}

1;
