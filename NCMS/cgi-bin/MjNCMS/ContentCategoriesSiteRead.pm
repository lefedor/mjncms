package MjNCMS::ContentCategoriesSiteRead;
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
use MjNCMS::ContentCategoriesSiteLibRead;
use MjNCMS::ContentPagesSiteLibRead;

########################################################################
#                       ROUTE CONTENT-SIDE CALLS
########################################################################

sub content_rt_category_get () {

    my $self = shift;

    #$SESSION{'PAGE_CACHABLE'} = 1;

    $TT_CFG{'tt_controller'} = 
        $TT_VARS{'tt_controller'} = 
            'content';
    $TT_CFG{'tt_action'} = 
        $TT_VARS{'tt_action'} = 
            'category';
    $TT_VARS{'category_id'} = $self->param('category_id');
    $TT_VARS{'category_slug'} = $self->param('category_slug');
    $TT_VARS{'category_slug'} = pop @{[split '/', $TT_VARS{'category_slug'}]}; 
    $TT_VARS{'category_page_num'} = $self->param('page_num');
    
    $TT_CALLS{'content_get_pagerecord'} = 
        \&MjNCMS::ContentPagesSiteLibRead::content_get_pagerecord;
        
    $TT_CALLS{'content_get_catrecord'} = 
        \&MjNCMS::ContentCategoriesSiteLibRead::content_get_catrecord;
    $TT_CALLS{'content_get_catparent_tree'} = 
        \&MjNCMS::ContentCategoriesSiteLibRead::content_get_catparent_tree;

    $self->render('site_index', format => 'html');
    
} #-- content_rt_category_get

1;
