package MjNCMS::Plugin::MjncmsRoutesExtra;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010

#
# Bender: Thats no flying saucer, thats my ass!
# (c) Futurama
#

use common::sense;
use base 'Mojolicious::Plugin';

use FindBin;
use lib "$FindBin::Bin/../../";

use locale;
use POSIX qw/locale_h /;

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use MojoX::Routes;

sub register {
    my ($self, $app, $args) = @_;
    
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
}

1;
