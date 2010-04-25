package MjNCMS::Plugin::MjncmsLangPrefixedUrls;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Req MjncmsInit plugin loaded alredy (MjNCMS::MjI18N req)
#

use common::sense;
use base 'Mojolicious::Plugin';

use FindBin;
use lib "$FindBin::Bin/../../";

use MjNCMS::Config qw/:subs :vars /;
use MjNCMS::Service qw/:subs /;

use Mojo::URL;

sub register {
    my ($self, $app, $args) = @_;
    $args ||= {};

    $app->plugins->add_hook(
        before_dispatch => sub {
            
            #return undef unless (scalar keys %{$SESSION{'SITE_LANGS'}});
            #positive coun checked @ MjncmsInit alredy
            
            my ($self, $c) = @_;
            
            my ($url, $lang);
            $url = $c->tx->req->url->to_rel->to_string();
            
            $SESSION{'URL_LANG_PREFIX'} = '';#<< empty string by default <vvv
            if ($url =~ /^\/([A-Za-z]{2,4})\//){
                $lang = $1;
                if (
                    $lang && 
                    length $lang && 
                    &inarray([keys %{$SESSION{'SITE_LANGS'}}], $lang) 
                ) {
                    
                    $SESSION{'LOC'}->set_lang($lang) 
                        unless $SESSION{'LOC'}->get_lang() eq $lang;
                        
                    #Can use @temlates as part of url, == '' by default   ^^^
                    $SESSION{'URL_LANG_PREFIX'} = '/' . $lang; # no end slash
                    
                    #on route stage it's regular URL :)
                    #$url = $c->tx->req->url->clone->to_abs->to_string();
                    #unless ($url =~ /^\w+\:\/\//) {
                    #    #still relative
                    
                        #Does it always return relative? Need CHK!
                        $url =~ s/^\/$lang\//\//;
                        
                        
                    #}
                    #else {
                    #    #absolute, first match
                    #    $url =~ s/(\w)\/$lang\//$1\//;
                    #}

                    $c->tx->req->url(Mojo::URL->new($url));
                    
                }
            }
            
        }
    );
}

1;
