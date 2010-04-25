package MjNCMS::ContentPagesSiteRead;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Routes on content-side [Site], Read part
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use base 'Mojolicious::Controller';

use MjNCMS::Config qw/:vars /;
use MjNCMS::ContentPagesSiteLibRead;
#use MjNCMS::ContentCategoriesSiteLibRead;

########################################################################
#                       ROUTE CONTENT-SIDE CALLS
########################################################################

sub content_rt_page_get () {

    #shift->render(text => 'Hello from MjNCMS');
    my $self = shift;

    #$SESSION{'PAGE_CACHABLE'} = 1;

    $TT_CFG{'tt_controller'} = 
        $TT_VARS{'tt_controller'} = 
            'content';
    $TT_CFG{'tt_action'} = 
        $TT_VARS{'tt_action'} = 
            'page';
    
    $TT_VARS{'page_id'} = $self->param('page_id');
    $TT_VARS{'page_slug'} = $self->param('page_slug');
    $TT_VARS{'page_slug'} = pop @{[split '/', $TT_VARS{'page_slug'}]}; 
    $TT_VARS{'page_num'} = $self->param('page_num');
    
    $TT_CALLS{'content_get_pagerecord'} = 
        \&MjNCMS::ContentPagesSiteLibRead::content_get_pagerecord;

    
    #$self->render(text => 'This is it');# 155 r/s
    $self->render('site_index', format => 'html');
    #$self->render(template => 'content/content_page', format => 'html', handler=>'tpl'); #116 r/s #simplifyed
    #$self->render(template => 'content/content_page', format => 'html', handler=>'ep'); #121 r/s #alredy was simple )
    
} #-- content_rt_page_get

1;
