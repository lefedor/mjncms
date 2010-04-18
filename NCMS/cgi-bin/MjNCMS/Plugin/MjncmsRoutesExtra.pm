package MjNCMS::Plugin::MjncmsRoutesExtra;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Bender: Thats no flying saucer, thats my ass!
# (c) Futurama
#

use common::sense;
use base 'Mojolicious::Plugin';

use FindBin;
use lib "$FindBin::Bin/../../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use MojoX::Routes;

sub register {
    my ($self, $app, $args) = @_;
    
    #Multisite things
    $app->routes->add_condition(

        host => sub {
            my ($r, $tx, $captures, $hosts) = @_;

            $hosts = ref $hosts? $hosts : [$hosts];

            # Match
            for my $host (@$hosts) {
                return $captures if $host eq lc $tx->req->url->base->host;
            }

            # Nothing
            return;
        }, 

        port => sub {
            my ($r, $tx, $captures, $ports) = @_;

            $ports = ref $ports? $ports : [$ports];

            # Match
            for my $port (@$ports) {
                return $captures if $port eq lc $tx->req->url->base->port;
            }

            # Nothing
            return;
        }, 

        scheme => sub {
            my ($r, $tx, $captures, $schemes) = @_;

            $schemes = ref $schemes? $schemes : [$schemes];

            # Match
            for my $scheme (@$schemes) {
                return $captures if $scheme eq lc $tx->req->url->base->scheme;
            }

            # Nothing
            return;
        }

    );
    
    #Access regulation thigs
    $app->routes->add_condition (
    
        role_id => sub {
            my ($r, $tx, $captures, $role_ids) = @_;
            
            $role_ids = $SESSION{'ADMIN_PANEL_ROLES'} 
                if $role_ids eq 'admin_panel_roles'; 
            
            $role_ids = ref $role_ids? $role_ids : [$role_ids];

            # Match
            for my $role_id (@$role_ids) {
                return $captures if $SESSION{'USR'}->{'role_id'} == $role_id;
            }

            # Nothing
            return;
        },
    
        awp_id => sub {
            my ($r, $tx, $captures, $awp_ids) = @_;
            
            $awp_ids = $SESSION{'ADMIN_PANEL_AWPS'} 
                if $awp_ids eq 'admin_panel_awps'; 
            
            $awp_ids = ref $awp_ids? $awp_ids : [$awp_ids];

            # Match
            for my $awp_id (@$awp_ids) {
                return $captures if $SESSION{'USR'}->{'awp_id'} == $awp_id;
            }

            # Nothing
            return;
        },
        
        awp_role_id => sub {
            my ($r, $tx, $captures, $awp_role_rule) = @_;
            my ($mode, $awp_ids, $role_ids) = ('or', );
            
            $mode = 'and' if $awp_role_rule =~ /\&\&/;
            
            $awp_role_rule =~ s/\s+//g;
            
            if ($mode eq 'or'){
                ($awp_ids, $role_ids) = split '||', $awp_role_rule;
            }
            else {
                ($awp_ids, $role_ids) = split '&&', $awp_role_rule;
            }
            
            $awp_ids = [split ',', $awp_ids]
                if $awp_ids =~ /\,/;
            $role_ids = [split ',', $role_ids]
                if $role_ids =~ /\,/;
            
            $awp_ids = $SESSION{'ADMIN_PANEL_AWPS'} 
                if $awp_ids eq 'admin_panel_awps'; 
                
            $role_ids = $SESSION{'ADMIN_PANEL_ROLES'} 
                if $role_ids eq 'admin_panel_roles';
            
            $awp_ids = ref $awp_ids? $awp_ids : [$awp_ids];
            $role_ids = ref $role_ids? $role_ids : [$role_ids];
            
            # Match
            if ($mode eq 'or'){
                return $captures if (
                    &inarray($awp_ids, $SESSION{'USR'}->{'awp_id'}) || 
                    &inarray($role_ids, $SESSION{'USR'}->{'role_id'}) 
                )
            }
            else {
                return $captures if (
                    &inarray($awp_ids, $SESSION{'USR'}->{'awp_id'}) && 
                    &inarray($role_ids, $SESSION{'USR'}->{'role_id'}) 
                )
            }

            # Nothing
            return;
        },

        ip => sub {
            my ($r, $tx, $captures, $allowed_ips) = @_;
            
            #my $client_ips = [values %{&sv_getips()}];
            my $client_ip = ${&sv_getips()}{'remote'};
            
            $allowed_ips = ref $allowed_ips? $allowed_ips : [$allowed_ips];

            # Match
            
            #for my $ip (@$client_ips) {
            #    return $captures if &inarray($allowed_ips, $ip);
            #}
            
            return $captures if &inarray($allowed_ips, $client_ip);

            # Nothing
            return;
        }
        
    );
    
}

1;
