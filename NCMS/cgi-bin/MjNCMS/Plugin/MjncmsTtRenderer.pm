package MjNCMS::Plugin::MjncmsTtRenderer;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# 10 SIN
# 20 GOTO HELL
#
# Santa: Your Mistletoe Is No Match For My TOW Missile!
# (c) Futurama
#

use common::sense;
use base 'Mojolicious::Plugin';

use FindBin;
use lib "$FindBin::Bin/../../";

use MjNCMS::Renderer::TT;
use MjNCMS::Config qw/:vars /;
#use MjNCMS::Service qw/:subs /;

sub register {
    my ($self, $app) = @_;

    my $tt = MjNCMS::Renderer::TT->build(
        mojo => $app,
        template_options =>
          { 
            ANYCASE => 0, #derictives case
            INCLUDE_PATH => $TT_CFG{'includepath'}, #site-specific paths set ref
            ABSOLUTE => 0, #only relative paths
            RELATIVE => 1, #load files from root [includes, etc]
            AUTO_RESET => 1, #?check if req again later
            #UNICODE => 1, ENCODING => 'utf-8', 
            VARIABLES => {
                SESSION => \%SESSION, #global session env
                TT_VARS => \%TT_VARS, #tt vars zoo
                TT_CALLS => \%TT_CALLS, #tt subs zoo jail - clear, add only required subs, pass tpl
                tt_module => undef,
                tt_action => undef, 
                
            }, #alias for 'PRE_DEFINE => {}'
            WRAPPER => 'wrapper_index.tpl', #this is main template decorator
            PLUGINS => {}, #only in additional sence
            FILTERS => $TT_CFG{'filterlist'},  #site-specific filters set ref
            PLUGIN_BASE => 'MjNCMS::Template::Filter', #TT plugins, 'loc' also.
            COMPILE_DIR => '../tmp/tt_ctpls/anti_relative', #consider deepest MjNCMS::Config::$cfg_alternatives{'sitename'}::tt_tpls_root relative dir level-up :)
            
          }, 
    );

    # Add "tpl" handler
    $app->renderer->add_handler(tpl => $tt);
    $app->renderer->default_handler('tpl');
    $app->renderer->default_format('html');
    $app->renderer->encoding('utf-8');
    $app->renderer->types->type(tt => 'text/html');
    
}

1;
