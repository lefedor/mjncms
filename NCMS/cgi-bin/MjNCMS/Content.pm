package MjNCMS::Content;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Bender: Suck my luck!
#
# Leela: Remember, professor. Bender is Santa. You don't need to hurt him. 
#
# (c) Futurama
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use base 'Mojolicious::Controller';

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

use MjNCMS::NS;

use MjNCMS::Usercontroller;

use MjNCMS::ContentCategoriesSiteLibRead qw/:subs /;
use MjNCMS::ContentPagesSiteLibRead qw/:subs /;
use MjNCMS::ContentShortlinksSiteLibRead qw/:subs /;
use MjNCMS::ContentShortlinksSiteLibWrite qw/:subs /;
use MjNCMS::ContentBlocksSiteLibRead qw/:subs /;

########################################################################
#                           ROUTE ADMIN CALLS
########################################################################

sub content_rt_cats_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('categories', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_cats';
        $TT_CALLS{'content_get_catrecord_tree'} = \&MjNCMS::Content::content_get_catrecord_tree;
        $TT_CALLS{'content_get_catrecord'} = \&MjNCMS::Content::content_get_catrecord;
    }
    $self->render('admin/admin_index');

} #-- content_rt_cats_get



sub content_rt_addcats_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('categories', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_cat_add';
        $TT_VARS{'parent_cat_id'} = $self -> param('parent_cat_id') if $self -> param('parent_cat_id');
        $TT_CALLS{'content_get_catrecord'} = \&MjNCMS::Content::content_get_catrecord if $self -> param('parent_cat_id');
    }
    $self->render('admin/admin_index');
    
} #-- content_rt_addcats_get

sub content_rt_addcats_post () {

    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('categories', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::cats_mk_node({
        parent => scalar $SESSION{'REQ'}->param('parent_cat_id')? $SESSION{'REQ'}->param('parent_cat_id'):0, 
        name => scalar $SESSION{'REQ'}->param('cat_name'), 
        cname => scalar $SESSION{'REQ'}->param('cat_cname'), 
        descr => scalar $SESSION{'REQ'}->param('cat_description'), 
        keywords => scalar $SESSION{'REQ'}->param('cat_keywords'), 
        is_active => scalar $SESSION{'REQ'}->param('cat_isactive'), 
        lang => scalar $SESSION{'REQ'}->param('cat_lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/cats' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            cat_id => $res->{'cat_id'}, 
            parent_cat_id => scalar $SESSION{'REQ'}->param('parent_cat_id'), 
            cat_level => $res->{'cat_level'}, 
            seq_order => $res->{'seq_order'}, 
            
        });
    }
    
} #-- content_rt_addcats_post

sub content_rt_editcats_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('categories', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_cat_edit';
        $TT_VARS{'cat_id'} = $self -> param('cat_id');
        $TT_CALLS{'content_get_catrecord'} = \&MjNCMS::Content::content_get_catrecord;
    }
    $self->render('admin/admin_index');
    
} #-- content_rt_editcats_get

sub content_rt_editcats_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('categories', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::cats_edit_node({
        cat_id => scalar $SESSION{'REQ'}->param('cat_id'), 
        name => scalar $SESSION{'REQ'}->param('cat_name'), 
        cname => scalar $SESSION{'REQ'}->param('cat_cname'), 
        descr => scalar $SESSION{'REQ'}->param('cat_description'), 
        keywords => scalar $SESSION{'REQ'}->param('cat_keywords'), 
        is_active => scalar $SESSION{'REQ'}->param('cat_isactive'), 
        lang => scalar $SESSION{'REQ'}->param('cat_lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/cats' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            cat_id => scalar $SESSION{'REQ'}->param('cat_id'), 
            
        });
    }
    
} #-- content_rt_editcats_post

sub content_rt_delcats_get () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('categories', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::cats_rm_node(scalar $self->param('rm_cat_id'));
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/cats' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            rm_cat_id => scalar $SESSION{'REQ'}->param('rm_cat_id'), 
        });
    }

} #-- content_rt_delcats_get

sub content_rt_setcatsequence_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('categories', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my %cats_weight = &get_suffixed_params('c_ord_');
    my $res = &MjNCMS::Content::cats_set_sequence(\%cats_weight);

    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/cats' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            
        });
    }

} #-- content_rt_setcatsequence_post

sub content_rt_cats_managetrans_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('categories', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_cat_managetrans';
        $TT_VARS{'cat_id'} = $self -> param('cat_id');
        $TT_CALLS{'content_get_catrecord'} = 
            \&MjNCMS::Content::content_get_catrecord;
        $TT_CALLS{'content_get_cattranses'} = 
            \&MjNCMS::Content::content_get_cattranses;
    }
    $self->render('admin/admin_index');
    
} #-- content_rt_cats_managetrans_get

sub content_rt_cats_addtrans_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('categories', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::cats_mk_trans_record({
        cat_id => scalar $SESSION{'REQ'}->param('cat_id'), 
        name => scalar $SESSION{'REQ'}->param('cat_trans'), 
        descr => scalar $SESSION{'REQ'}->param('cat_description'), 
        keywords => scalar $SESSION{'REQ'}->param('cat_keywords'), 
        lang => scalar $SESSION{'REQ'}->param('cat_lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/cats' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            cat_id => $res->{'cat_id'}, 
            cat_lang => $res->{'cat_lang'}, 
            
        });
    }
} #-- content_rt_cats_addtrans_post

sub content_rt_cats_updtrans_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('categories', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::cats_edit_trans_record({
        cat_id => scalar $SESSION{'REQ'}->param('cat_id'), 
        name => scalar $SESSION{'REQ'}->param('cat_trans'), 
        descr => scalar $SESSION{'REQ'}->param('cat_description'), 
        keywords => scalar $SESSION{'REQ'}->param('cat_keywords'), 
        lang => scalar $SESSION{'REQ'}->param('cat_lang'), 
        old_lang => scalar $SESSION{'REQ'}->param('cat_curtrans_lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/cats' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            cat_id => $res->{'cat_id'}, 
            
        });
    }
} #-- content_rt_cats_updtrans_post

sub content_rt_cats_deltrans_get () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('categories', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::cats_rm_trans_record({
        cat_id => scalar $self->param('cat_id'), 
        lang => scalar $self->param('cat_lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/cats' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            cat_id => $res->{'cat_id'}, 
            
        });
    }
} #-- content_rt_cats_deltrans_get

sub content_rt_pages_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('pages', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_pages';
        $TT_CALLS{'content_get_pagerecord'} = \&MjNCMS::Content::content_get_pagerecord;
    }
    $self->render('admin/admin_index');

} #-- content_rt_pages_get

sub content_rt_addpages_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('pages', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_page_add';
        $TT_CALLS{'content_get_catrecord_tree'} = \&MjNCMS::Content::content_get_catrecord_tree;
        $TT_CALLS{'content_get_catrecord'} = \&MjNCMS::Content::content_get_catrecord;
        $TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
    }
    $self->render('admin/admin_index');

} #-- content_rt_addpages_get

sub content_rt_addpages_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('pages', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::pages_add_page({
        cat_id => scalar ((scalar $SESSION{'REQ'}->param('parent_cat_id'))? (scalar $SESSION{'REQ'}->param('parent_cat_id')):0), 
        is_published => scalar $SESSION{'REQ'}->param('page_ispublished'), 
        lang => scalar $SESSION{'REQ'}->param('page_lang'),
        slug => scalar $SESSION{'REQ'}->param('page_slug'), 
        intro => scalar $SESSION{'REQ'}->param('page_intro'), 
        body => scalar $SESSION{'REQ'}->param('page_body'), 
        header => scalar $SESSION{'REQ'}->param('page_header'), 
        descr => scalar $SESSION{'REQ'}->param('page_descr'), 
        keywords => scalar $SESSION{'REQ'}->param('page_keywords'), 
        
        showintro => scalar $SESSION{'REQ'}->param('page_showintro'), 
        
        use_customtitle => scalar $SESSION{'REQ'}->param('page_use_customtitle'), 
        custom_title => scalar $SESSION{'REQ'}->param('page_custom_title'), 
        allow_comments => scalar $SESSION{'REQ'}->param('page_allowcomments'), 
        comments_mode => scalar $SESSION{'REQ'}->param('page_comments_mode'), 
        
        use_password => scalar $SESSION{'REQ'}->param('page_use_password'), 
        password => scalar $SESSION{'REQ'}->param('page_password'), 
        
        use_access_roles => scalar $SESSION{'REQ'}->param('page_use_access_roles'), 
        access_roles => [$SESSION{'REQ'}->param('page_access_roles')], 
        
        author_id => scalar $SESSION{'REQ'}->param('page_author_id'), 
        
        dt_created => scalar $SESSION{'REQ'}->param('page_dt_created'), 
        dt_publishstart => scalar $SESSION{'REQ'}->param('page_dt_publishstart'), 
        dt_publishend => scalar $SESSION{'REQ'}->param('page_dt_publishend'),
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/pages' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            page_id => $res->{'cat_id'}, 
            parent_cat_id => scalar $SESSION{'REQ'}->param('parent_cat_id'), 
            
        });
    }
    
} #-- content_rt_addpages_post

sub content_rt_editpages_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('pages', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_page_edit';
        $TT_VARS{'page_id'} = $self -> param('page_id');
        $TT_CALLS{'content_get_catrecord_tree'} = \&MjNCMS::Content::content_get_catrecord_tree;
        $TT_CALLS{'content_get_catrecord'} = \&MjNCMS::Content::content_get_catrecord;
        $TT_CALLS{'content_get_pagerecord'} = \&MjNCMS::Content::content_get_pagerecord;
        $TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
    }
    $self->render('admin/admin_index');

} #-- content_rt_editpages_get

sub content_rt_editpages_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('pages', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::pages_edit_page({
        cat_id => scalar ((scalar $SESSION{'REQ'}->param('parent_cat_id'))? (scalar $SESSION{'REQ'}->param('parent_cat_id')):0), 
        
        page_id => scalar $self->param('page_id'), 
        
        is_published => scalar $SESSION{'REQ'}->param('page_ispublished'), 
        lang => scalar $SESSION{'REQ'}->param('page_lang'),
        slug => scalar $SESSION{'REQ'}->param('page_slug'), 
        intro => scalar $SESSION{'REQ'}->param('page_intro'), 
        body => scalar $SESSION{'REQ'}->param('page_body'), 
        header => scalar $SESSION{'REQ'}->param('page_header'), 
        descr => scalar $SESSION{'REQ'}->param('page_descr'), 
        keywords => scalar $SESSION{'REQ'}->param('page_keywords'), 
        
        showintro => scalar $SESSION{'REQ'}->param('page_showintro'), 
        
        use_customtitle => scalar $SESSION{'REQ'}->param('page_use_customtitle'), 
        custom_title => scalar $SESSION{'REQ'}->param('page_custom_title'), 
        
        allow_comments => scalar $SESSION{'REQ'}->param('page_allowcomments'), 
        comments_mode => scalar $SESSION{'REQ'}->param('page_comments_mode'), 
        
        use_password => scalar $SESSION{'REQ'}->param('page_use_password'), 
        password => scalar $SESSION{'REQ'}->param('page_password'), 
        
        use_access_roles => scalar $SESSION{'REQ'}->param('page_use_access_roles'), 
        access_roles => [$SESSION{'REQ'}->param('page_access_roles')], 
        
        author_id => scalar $SESSION{'REQ'}->param('page_author_id'), 
        
        dt_created => scalar $SESSION{'REQ'}->param('page_dt_created'), 
        dt_publishstart => scalar $SESSION{'REQ'}->param('page_dt_publishstart'), 
        dt_publishend => scalar $SESSION{'REQ'}->param('page_dt_publishend'),
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/pages' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            page_id => $res->{'cat_id'}, 
            parent_cat_id => scalar $SESSION{'REQ'}->param('parent_cat_id'), 
            
        });
    }
    
} #-- content_rt_editpages_post

sub content_rt_deletepages_get () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('pages', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::pages_delete_page({
        page_id => scalar $self->param('page_id'), 
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/pages' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            page_id => $res->{'page_id'}, 
            
        });
    }
} #-- content_rt_deletepages_get

sub content_rt_page_managetrans_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('pages', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_page_managetrans';
        $TT_VARS{'page_id'} = $self -> param('page_id');
        $TT_CALLS{'pages_get_transes'} = \&MjNCMS::Content::pages_get_transes;
    }
    $self->render('admin/admin_index');

} #-- content_rt_page_managetrans_get

sub content_rt_page_managetrans_add_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('pages', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_page_managetrans_add';
        $TT_VARS{'page_id'} = $self -> param('page_id');
        $TT_CALLS{'content_get_pagerecord'} = \&MjNCMS::Content::content_get_pagerecord;
        $TT_CALLS{'pages_get_transes'} = \&MjNCMS::Content::pages_get_transes;
    }
    $self->render('admin/admin_index');

} #-- content_rt_page_managetrans_add_get

sub content_rt_page_managetrans_save_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('pages', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::page_translation_save ({
        page_id => scalar $self->param('page_id'), 
        
        lang => scalar $SESSION{'REQ'}->param('page_lang'),

        intro => scalar $SESSION{'REQ'}->param('page_intro'), 
        body => scalar $SESSION{'REQ'}->param('page_body'), 
        header => scalar $SESSION{'REQ'}->param('page_header'), 
        descr => scalar $SESSION{'REQ'}->param('page_descr'), 
        keywords => scalar $SESSION{'REQ'}->param('page_keywords'), 
        
        custom_title => scalar $SESSION{'REQ'}->param('page_custom_title'), 
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/page_managetrans/' . (scalar $self->param('page_id')) unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            page_id => scalar $self->param('page_id'), 
            lang => scalar $SESSION{'REQ'}->param('page_lang'), 
        });
    }
    
} #-- content_rt_page_managetrans_save_post

sub content_rt_page_managetrans_edit_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('pages', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_page_managetrans_edit';
        $TT_VARS{'page_id'} = $self -> param('page_id');
        $TT_VARS{'lang'} = $self -> param('lang');
        $TT_CALLS{'content_get_pagerecord'} = \&MjNCMS::Content::content_get_pagerecord;
        $TT_CALLS{'pages_get_transes'} = \&MjNCMS::Content::pages_get_transes;
    }
    $self->render('admin/admin_index');

    
} #-- content_rt_page_managetrans_edit_get

sub content_rt_page_managetrans_update_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('pages', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::page_translation_update ({
        page_id => scalar $self->param('page_id'), 
        old_lang => scalar $self->param('old_lang'),
        
        lang => scalar $SESSION{'REQ'}->param('page_lang'),

        intro => scalar $SESSION{'REQ'}->param('page_intro'), 
        body => scalar $SESSION{'REQ'}->param('page_body'), 
        header => scalar $SESSION{'REQ'}->param('page_header'), 
        descr => scalar $SESSION{'REQ'}->param('page_descr'), 
        keywords => scalar $SESSION{'REQ'}->param('page_keywords'), 
        
        custom_title => scalar $SESSION{'REQ'}->param('page_custom_title'), 
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/page_managetrans/' . (scalar $self->param('page_id')) unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            page_id => scalar $self->param('page_id'), 
            lang => scalar $self->param('lang'), 
            
        });
    }
    
} #-- content_rt_page_managetrans_update_post

sub content_rt_page_managetrans_delete_get () {
    
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('pages', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::page_translation_delete({
        page_id => scalar $self->param('page_id'), 
        lang => scalar $self->param('lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/page_managetrans/' . (scalar $self->param('page_id')) unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            page_id => scalar $self->param('page_id'), 
            lang => scalar $self->param('lang'), 
        });
    }

} #-- content_rt_page_managetrans_delete_get

sub content_rt_short_urls_get () {
    my $self = shift;
    
    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('urls', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_short_urls';
        $TT_CALLS{'content_get_short_url_groups'} = \&MjNCMS::Content::content_get_short_url_groups;
        $TT_CALLS{'content_get_short_urls'} = \&MjNCMS::Content::content_get_short_urls;
    }
    $self->render('admin/admin_index');

} #-- content_rt_short_urls_get

sub content_rt_short_url_groups_add_get () {
    my $self = shift;
    
    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('urls', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_short_url_groups_add';
    }
    $self->render('admin/admin_index');

} #-- content_rt_short_urls_get

sub content_rt_short_url_groups_add_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('urls', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::surl_group_add({
        name => scalar $SESSION{'REQ'}->param('sugrp_name'),
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/short_urls' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            sugrp_id => $res->{'sugrp_id'}, 
            
        });
    }
    
} #-- content_rt_short_url_groups_add_post

sub content_rt_short_url_groups_edit_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('urls', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_short_url_groups_edit';
        $TT_VARS{'sugrp_id'} = $self -> param('sugrp_id');
        $TT_CALLS{'content_get_short_url_groups'} = \&MjNCMS::Content::content_get_short_url_groups;
    }
    $self->render('admin/admin_index');

} #-- content_rt_short_url_groups_edit_get

sub content_rt_short_url_groups_edit_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('urls', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::surl_group_edit({
        sugrp_id => scalar $self->param('sugrp_id'),
        name => scalar $SESSION{'REQ'}->param('sugrp_name'),
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/short_urls' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            sugrp_id => $res->{'sugrp_id'}, 
            
        });
    }
    
} #-- content_rt_short_url_groups_edit_post

sub content_rt_short_url_groups_delete_get () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('urls', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::surl_group_delete({
        sugrp_id => scalar $self->param('sugrp_id'), 
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/short_urls' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            sugrp_id => $res->{'sugrp_id'}, 
            
        });
    }
} #-- content_rt_short_url_groups_delete_get

sub content_rt_short_urls_add_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('urls', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::surl_url_add({
        sugrp_id => scalar $SESSION{'REQ'}->param('surl_sugrp_id'),
        alias => scalar $SESSION{'REQ'}->param('surl_shortcut_alias'),
        original_url => scalar $SESSION{'REQ'}->param('surl_orig_url'),
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/short_urls' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            url_id => $res->{'url_id'}, 
            url_alias => $res->{'alias'}, 
            
        });
    }
    
} #-- content_rt_short_urls_add_post

sub content_rt_short_urls_delete_get () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('urls', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::surl_url_delete({
        alias_id => scalar $self->param('alias_id'), 
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/short_urls' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            alias_id => $res->{'alias_id'}, 
            
        });
    }
} #-- content_rt_short_urls_delete_get

sub content_filemanager_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('filemanager', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_filemanager';
    }
    $self->render('admin/admin_index');
} #-- content_filemanager_get

sub content_rt_blocks_get () {
    my $self = shift;
    
    $SESSION{'PAGE_CACHABLE'} = 1;
    
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_blocks';
        $TT_CALLS{'content_get_blocks'} = \&MjNCMS::Content::content_get_blocks;
    }
    $self->render('admin/admin_index');
    
} #-- content_rt_blocks_get

sub content_rt_blocks_add_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }

    $TT_CFG{'tt_controller'} = 
        $TT_VARS{'tt_controller'} = 
            'admin';
    $TT_CFG{'tt_action'} = 
        $TT_VARS{'tt_action'} = 
            'content_blocks_add';
    $TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
    $self->render('admin/admin_index');
    
} #-- content_rt_blocks_add_get

sub content_rt_blocks_add_psot () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::blocks_add_block({
        alias => scalar $SESSION{'REQ'}->param('block_alias'), 
        lang => scalar $SESSION{'REQ'}->param('block_lang'),
        
        is_active => scalar $SESSION{'REQ'}->param('block_isactive'), 
        
        show_header => scalar $SESSION{'REQ'}->param('block_show_header'), 
        header => scalar $SESSION{'REQ'}->param('block_header'), 
        body => scalar $SESSION{'REQ'}->param('block_body'), 
                
        access_roles => [$SESSION{'REQ'}->param('block_access_roles')], 
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/blocks' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            block_id => $res->{'block_id'}, 
            
        });
    }
    
} #-- content_rt_blocks_add_psot

sub content_rt_blocks_edit_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }

    $TT_CFG{'tt_controller'} = 
        $TT_VARS{'tt_controller'} = 
            'admin';
    $TT_CFG{'tt_action'} = 
        $TT_VARS{'tt_action'} = 
            'content_blocks_edit';
    $TT_VARS{'block_id'} = $self->param('block_id');
    $TT_CALLS{'awproles_get'} = \&MjNCMS::Usercontroller::awproles_get;
    $TT_CALLS{'content_get_blocks'} = \&MjNCMS::Content::content_get_blocks;
    $self->render('admin/admin_index');
    
} #-- content_rt_blocks_edit_get

sub content_rt_blocks_edit_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::blocks_edit_block({
        block_id => scalar $self->param('block_id'), 
        
        alias => scalar $SESSION{'REQ'}->param('block_alias'), 
        lang => scalar $SESSION{'REQ'}->param('block_lang'),
        
        is_active => scalar $SESSION{'REQ'}->param('block_isactive'), 
        
        show_header => scalar $SESSION{'REQ'}->param('block_show_header'), 
        header => scalar $SESSION{'REQ'}->param('block_header'), 
        body => scalar $SESSION{'REQ'}->param('block_body'), 
                
        access_roles => [$SESSION{'REQ'}->param('block_access_roles')], 
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/blocks' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            block_id => $res->{'block_id'}, 
            
        });
    }
    
} #-- content_rt_blocks_edit_post

sub content_rt_blocks_delete_get () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::blocks_delete_block({
        block_id => scalar $self->param('block_id'), 
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/pages' unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            page_id => $res->{'page_id'}, 
            
        });
    }
} #-- content_rt_blocks_delete_get

sub content_rt_blocks_managetrans_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_blocks_managetrans';
        $TT_VARS{'block_id'} = $self -> param('block_id');
        $TT_CALLS{'blocks_get_transes'} = \&MjNCMS::ContentBlocksSiteLibRead::blocks_get_transes;
    }
    $self->render('admin/admin_index');

} #-- content_rt_blocks_managetrans_get

sub content_rt_blocks_managetrans_add_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_blocks_managetrans_add';
        $TT_VARS{'block_id'} = $self -> param('block_id');
        $TT_CALLS{'content_get_blocks'} = \&MjNCMS::ContentBlocksSiteLibRead::content_get_blocks;
    }
    $self->render('admin/admin_index');
    
} #-- content_rt_blocks_managetrans_add_get

sub content_rt_blocks_managetrans_add_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('pages', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::blocks_translation_save ({
        block_id => scalar $self->param('block_id'), 
        
        lang => scalar $SESSION{'REQ'}->param('block_lang'),
        
        header => scalar $SESSION{'REQ'}->param('block_header'), 
        body => scalar $SESSION{'REQ'}->param('block_body'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/block/tanses/' . (scalar $self->param('block_id')) unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            block_id => scalar $self->param('block_id'), 
            lang => scalar $SESSION{'REQ'}->param('block_lang'), 
        });
    }
    
} #-- content_rt_blocks_managetrans_add_post

sub content_rt_blocks_managetrans_edit_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
    }
    else {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'content_blocks_managetrans_edit';
        $TT_VARS{'block_id'} = $self -> param('block_id');
        $TT_VARS{'lang'} = $self -> param('lang');
        $TT_CALLS{'content_get_blocks'} = \&MjNCMS::ContentBlocksSiteLibRead::content_get_blocks;
    }
    $self->render('admin/admin_index');
    
} #-- content_rt_blocks_managetrans_edit_get

sub content_rt_blocks_managetrans_edit_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::blocks_translation_edit ({
        block_id => scalar $self->param('block_id'), 
        old_lang => scalar $self->param('old_lang'),
        
        lang => scalar $SESSION{'REQ'}->param('block_lang'),
        
        header => scalar $SESSION{'REQ'}->param('block_header'), 
        body => scalar $SESSION{'REQ'}->param('block_body'), 
        
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/blocks/transes/' . (scalar $self->param('block_id')) unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            block_id => scalar $self->param('block_id'), 
            lang => scalar $self->param('lang'), 
            
        });
    }
} #-- content_rt_blocks_managetrans_edit_post

sub content_rt_blocks_managetrans_delete_get () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('blocks', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Content::blocks_translation_delete({
        block_id => scalar $self->param('block_id'), 
        lang => scalar $self->param('lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/content/blocks/transes/' . (scalar $self->param('block_id')) unless $url;
        $SESSION{'REDIR'} = {
            url => $url, 
            msg => $res->{'message'}, 
        };
        return;
    }
    else {
        $self->render_json({
            status => $res->{'status'}, 
            message => $SESSION{'LOC'}->loc($res->{'message'}), 
            block_id => scalar $self->param('block_id'), 
            lang => scalar $self->param('lang'), 
        });
    }

} #-- content_rt_blocks_managetrans_delete_get

########################################################################
#                           INTERNAL SUBS
########################################################################

#sub _clear_html ($) {
#MjNCMS::Template::Filter::safe_page_html;# AS TT filter - on demand
#}; #-- _clear_html

sub _rest_memd_cats ($) {
    
    return undef unless (
        $SESSION{'MEMD'} && 
        $SESSION{'MEMD_CACHE_OPTS'}->{'categories'} && 
        $SESSION{'MEMD_CACHE_OPTS'}->{'categories'}->{'prefix'}
    );
    
    my $cfg = shift;
    
    $cfg = {
        cat_id => $cfg, 
        
    } unless (
            $cfg && 
            ref $cfg && 
            ref $cfg eq 'HASH' 
        );
    
    my (
        $dbh, 
        $q, $res, $sth, 
        $where_rule, $catNS, 
        @cats, 
        %cat_cnames, %cat_ids, 
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    
    if ( 
        ${$cfg}{'cat_id'} && 
        !(ref ${$cfg}{'cat_id'}) && 
        ${$cfg}{'cat_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' OR cat_id = ' . ($dbh->quote(${$cfg}{'cat_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'cat_ids'} && 
        ref ${$cfg}{'cat_ids'} && 
        scalar @{${$cfg}{'cat_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'cat_ids'}}))) 
    ) {
        $where_rule .= ' OR cat_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'cat_ids'}}))) . ') ';
    }
    
    if (${$cfg}{'cname'} && length ${$cfg}{'cname'}) {
        ${$cfg}{'cname'} = $dbh->quote(${$cfg}{'cname'});
        $where_rule .= ' OR cname = ' . ${$cfg}{'cname'} . ' ';
    }
    
    if ( 
        ${$cfg}{'cnames'} && 
        ref ${$cfg}{'cnames'} && 
        scalar @{${$cfg}{'cnames'}} 
    ) {
        $where_rule .= ' OR cname IN ( ' . (join ', ', (map( $dbh->quote($_), @{${$cfg}{'cnames'}}))) . ') ';
    }
    
    $where_rule =~ s/OR/WHERE/;
    
    $q = qq~
        SELECT 
            cat_id 
        FROM ${SESSION{PREFIX}}cats_data 
        $where_rule ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            push @cats, $res->{'cat_id'};
        }
    };
    
    return undef unless scalar @cats;
    
    $catNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'cats_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };

    foreach my $cid (@cats){
        next if $cat_ids{$cid};
        foreach my $cpid (@{&content_get_catparent_tree($cid)}){
            $cat_ids{$cpid} = 1 if $cpid && $cpid =~ /^\d+$/;#no 'root'
        }
        $cat_ids{$cid} = 1;
    }
    
    return undef unless scalar keys %cat_ids;
    
    $q = qq~
        SELECT 
            cd.cat_id, cd.cname, COUNT(*) AS pages_cnt 
        FROM ${SESSION{PREFIX}}cats_data cd 
            LEFT JOIN ${SESSION{PREFIX}}pages p 
                ON p.cat_id=cd.cat_id 
        WHERE cd.cat_id IN (~ . (join ', ', (keys %cat_ids)) . q~) 
        GROUP BY cd.cat_id ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            $cat_ids{$res->{'cat_id'}} = $res->{'pages_cnt'};
            $cat_cnames{$res->{'cname'}} = $res->{'pages_cnt'} if $res->{'cname'};
        }
    };
    
    foreach my $cname (keys %cat_cnames){
        foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
            $SESSION{'MEMD'}->delete(
                ($SESSION{'MEMD_CACHE_OPTS'}->{'categories'}->{'prefix'}) . 
                'cl_' . $lang . '_' . 
                'ccname_' . $cname 
            );
        }
        for (my $i=1;$i<=$cat_cnames{$cname};$i++){
            foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
                $SESSION{'MEMD'}->delete(
                    ($SESSION{'MEMD_CACHE_OPTS'}->{'categories'}->{'prefix'}) . 
                    'cl_' . $lang . '_' . 
                    'cp_' . $i . '_' . 
                    'ccname_' . $cname 
                );
            }
        }
    }
    
    foreach my $cat_id (keys %cat_ids){
        foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
            $SESSION{'MEMD'}->delete(
                ($SESSION{'MEMD_CACHE_OPTS'}->{'categories'}->{'prefix'}) . 
                'cl_' . $lang . '_' . 
                'cid_' . $cat_id 
            );
        }
        for (my $i=1;$i<=$cat_ids{$cat_id};$i++){
            foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
                $SESSION{'MEMD'}->delete(
                    ($SESSION{'MEMD_CACHE_OPTS'}->{'categories'}->{'prefix'}) . 
                    'cl_' . $lang . '_' . 
                    'cp_' . $i . '_' . 
                    'cid_' . $cat_id 
                );
            }
        }
    }
    
    unless (${$cfg}{'skip_pages'}){
        &_rest_memd_cats({
            cat_ids => [keys %cat_ids], 
            skip_cats => 1, 
        });
    }
    
    return undef;
} #-- _rest_memd_cats

sub _rest_memd_pages ($) {
    
    return undef unless (
        $SESSION{'MEMD'} && 
        $SESSION{'MEMD_CACHE_OPTS'}->{'pages'} && 
        $SESSION{'MEMD_CACHE_OPTS'}->{'pages'}->{'prefix'}
    );
    
    my $cfg = shift;
    
    $cfg = {
        page_id => $cfg, 
        
    } unless (
            ref $cfg && 
            ref $cfg eq 'HASH' 
        );
    
    my (
        $dbh, 
        $q, $res, $sth, 
        $where_rule, 
        %cats, %page_ids, %page_slugs,
        @page_pieces, @page_pieces_tmp, 
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    
    if ( 
        ${$cfg}{'page_id'} && 
        !(ref ${$cfg}{'page_id'}) && 
        ${$cfg}{'page_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' OR page_id = ' . ($dbh->quote(${$cfg}{'page_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'page_ids'} && 
        ref ${$cfg}{'page_ids'} && 
        scalar @{${$cfg}{'page_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'page_ids'}}))) 
    ) {
        $where_rule .= ' OR page_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'page_ids'}}))) . ') ';
    }
    
    if (${$cfg}{'slug'} && length ${$cfg}{'slug'}) {
        ${$cfg}{'slug'} = $dbh->quote(${$cfg}{'slug'});
        $where_rule .= ' OR slug = ' . ${$cfg}{'slug'} . ' ';
    }
    
    if ( 
        ${$cfg}{'slugs'} && 
        ref ${$cfg}{'slugs'} && 
        scalar @{${$cfg}{'slugs'}} 
    ) {
        $where_rule .= ' OR slug IN ( ' . (join ', ', (map( $dbh->quote($_), @{${$cfg}{'slugs'}}))) . ') ';
    }
    
    if ( 
        ${$cfg}{'cat_id'} && 
        !(ref ${$cfg}{'cat_id'}) && 
        ${$cfg}{'cat_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' OR cat_id = ' . ($dbh->quote(${$cfg}{'cat_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'cat_ids'} && 
        ref ${$cfg}{'cat_ids'} && 
        scalar @{${$cfg}{'cat_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'cat_ids'}}))) 
    ) {
        $where_rule .= ' OR cat_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'cat_ids'}}))) . ') ';
    }
    
    $where_rule =~ s/OR/WHERE/;
    
    $q = qq~
        SELECT 
        page_id, cat_id, slug ~;
        if (
            $SESSION{'PAGE_PAGER_SPLITTER'} && 
            ref $SESSION{'PAGE_PAGER_SPLITTER'} eq 'ARRAY' && 
            scalar @{$SESSION{'PAGE_PAGER_SPLITTER'}} 
        ){
            $q .= q~ , body ~;
        }
    $q .= qq~ 
        FROM ${SESSION{PREFIX}}pages 
        $where_rule ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            $cats{$res->{'cat_id'}} = 1;
            
            if (
                $res -> {'body'}
            ){
                @page_pieces = ($res -> {'body'}, );
                foreach my $splitter (@{$SESSION{'PAGE_PAGER_SPLITTER'}}) {
                    @page_pieces_tmp = ();
                    foreach my $piece (@page_pieces) {
                         push @page_pieces_tmp, split $splitter, $piece;
                    }
                    @page_pieces = @page_pieces_tmp;
                }
            }
            else {
                @page_pieces = (1, )
            }
                
            $page_ids{$res->{'page_id'}} = scalar @page_pieces;
            $page_slugs{$res->{'slug'}} = $page_ids{$res->{'page_id'}} if $res->{'slug'};
        }
    };
    
    foreach my $slug (keys %page_slugs){
        foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
            $SESSION{'MEMD'}->delete(
                ($SESSION{'MEMD_CACHE_OPTS'}->{'pages'}->{'prefix'}) . 
                'pl_' . $lang . '_' . 
                'pslug_' . $slug 
            );
        }
        for (my $i=1;$i<=$page_slugs{$slug};$i++){
            foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
                $SESSION{'MEMD'}->delete(
                    ($SESSION{'MEMD_CACHE_OPTS'}->{'pages'}->{'prefix'}) . 
                    'pl_' . $lang . '_' . 
                    'p_' . $i . '_' . 
                    'pslug_' . $slug 
                );
            }
        }
    }
    
    foreach my $page_id (keys %page_ids){
        foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
            $SESSION{'MEMD'}->delete(
                ($SESSION{'MEMD_CACHE_OPTS'}->{'pages'}->{'prefix'}) . 
                'pl_' . $lang . '_' . 
                'pid_' . $page_id 
            );
        }
        for (my $i=1;$i<=$page_ids{$page_id};$i++){
            foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
                $SESSION{'MEMD'}->delete(
                    ($SESSION{'MEMD_CACHE_OPTS'}->{'pages'}->{'prefix'}) . 
                    'pl_' . $lang . '_' . 
                    'p_' . $i . '_' . 
                    'pid_' . $page_id 
                );
            }
        }
    }
    
    unless (${$cfg}{'skip_cats'}){
        &_rest_memd_cats({
            cat_ids => [keys %cats], 
            skip_pages => 1, 
        });
    }
    
    return undef;
} #-- _rest_memd_pages

sub _rest_memd_blocks () {
    
    return undef unless (
        $SESSION{'MEMD'} && 
        $SESSION{'MEMD_CACHE_OPTS'}->{'blocks'} && 
        $SESSION{'MEMD_CACHE_OPTS'}->{'blocks'}->{'prefix'}
    );
    
    my $cfg = shift;
    
    $cfg = {
        block_id => $cfg, 
        
    } unless (
            $cfg && 
            ref $cfg && 
            ref $cfg eq 'HASH' 
        );
    
    my (
        $dbh, 
        $q, $res, $sth, 
        $where_rule, 
        %block_ids, %block_aliases, 
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    
    if ( 
        ${$cfg}{'block_id'} && 
        !(ref ${$cfg}{'block_id'}) && 
        ${$cfg}{'block_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' OR block_id = ' . ($dbh->quote(${$cfg}{'block_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'block_ids'} && 
        (ref ${$cfg}{'block_ids'} eq 'ARRAY') && 
        scalar @{${$cfg}{'block_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'block_ids'}}))) 
    ) {
        $where_rule .= ' OR block_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'block_ids'}}))) . ') ';
    }
    
    if (${$cfg}{'alias'} && length ${$cfg}{'alias'}) {
        ${$cfg}{'alias'} = $dbh->quote(${$cfg}{'alias'});
        $where_rule .= ' OR alias = ' . ${$cfg}{'alias'} . ' ';
    }
    
    if ( 
        ${$cfg}{'aliases'} && 
        ref ${$cfg}{'aliases'} && 
        scalar @{${$cfg}{'aliases'}} 
    ) {
        $where_rule .= ' OR alias IN ( ' . (join ', ', (map( $dbh->quote($_), @{${$cfg}{'aliases'}}))) . ') ';
    }
    
    $where_rule =~ s/OR/WHERE/;
    
    $q = qq~
        SELECT 
            b.block_id, b.alias 
        FROM ${SESSION{PREFIX}}blocks b 
        $where_rule ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            $block_ids{$res->{'block_id'}} = 1;
            $block_aliases{$res->{'alias'}} = 1 if $res->{'alias'};
        }
    };
    
    foreach my $alias (keys %block_aliases){
        foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
            $SESSION{'MEMD'}->delete(
                ($SESSION{'MEMD_CACHE_OPTS'}->{'categories'}->{'prefix'}) . 
                'bl_' . $lang . '_' . 
                'bal_' . $alias 
            );
        }
    }
    
    foreach my $block_id (keys %block_ids){
        foreach my $lang (keys %{$SESSION{'SITE_LANGS'}}) {
            $SESSION{'MEMD'}->delete(
                ($SESSION{'MEMD_CACHE_OPTS'}->{'categories'}->{'prefix'}) . 
                'bl_' . $lang . '_' . 
                'bid_' . $block_id 
            );
        }
    }
    
    return undef;
} #-- _rest_memd_blocks

sub content_get_catrecord_tree ($) {
    
    my $cat_id = $_[0];
    my $mode = $_[1]? $_[1]:'as_array';

    my (
        $dbh, $q, $catNS, 
        @cat_slaves, 
        %cat_slaves, 
    ) = ($SESSION{'DBH'}, );
    
    if ($cat_id && length $cat_id && $cat_id !~ /^\d+$/) {
        $q = qq~
            SELECT cat_id 
            FROM ${SESSION{PREFIX}}cats_data 
            WHERE cname = ~ . ($dbh->quote($cat_id)) . qq~ 
            LIMIT 0,1 ; 
        ~;
        ($cat_id) = $dbh -> selectrow_array($q);
    }
    
    return {
        status => 'fail', 
        message => 'cat_id wrong fmt', 
    } unless $cat_id =~ /^\d+$/;

    $catNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'cats_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };

    eval {
        #could return not 'ARRAY'
        @cat_slaves = @{$catNS -> get_child_id(unit => $cat_id, branch => 'all')};
    };
    
    if ($mode ne 'as_hash') {
        return \@cat_slaves;
    }
    else {
        #mk here recrusive included hash tree for future
    }
    
} #-- content_get_catrecord_tree

sub content_get_catparent_tree ($) {
    
    my $cat_id = $_[0];
    my $mode = $_[1]? $_[1]:'as_array';

    my (
        $catNS, 
        @cat_parents, 
        %cat_parents, 
    );
    
    return {
        status => 'fail', 
        message => 'cat_id wrong fmt', 
    } unless $cat_id =~ /^\d+$/;

    $catNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'cats_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };

    @cat_parents = @{$catNS -> get_parent_id(unit => $cat_id, branch => 'all')};
    
    if ($mode ne 'as_hash') {
        return \@cat_parents;
    }
    else {
        #mk here recrusive included hash tree for future
    }
    
} #-- content_get_catparent_tree

sub cats_mk_node ($) {
    
    my $cfg = shift;

    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'parent unknown', 
    } unless ${$cfg}{'parent'} =~ /^\d+$/;
    
    return {
        status => 'fail', 
        message => 'name len fail',
    } unless ${$cfg}{'name'} =~ /^.{1,32}$/; 
    
    return {
        status => 'fail', 
        message => 'cname len fail',
    } if (
        !(scalar ${$cfg}{'parent'}) && 
        ${$cfg}{'cname'} !~ /^.{1,16}$/ 
    ); 

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        !(scalar ${$cfg}{'parent'}) && 
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 
    
    if (${$cfg}{'is_active'}) {
        ${$cfg}{'is_active'} = 1;
    }
    else {
        ${$cfg}{'is_active'} = 0;
    }
    
    my (
        $dbh, $sth, $res, $q, 
        $catNS, $cat_id, $inscnt, 
        $sql_now, @parent_cat_slaves, 
        
    ) = ($SESSION{'DBH'}, );
    
    $sql_now = &sv_datetime_sql();
    
    if (${$cfg}{'cname'}) {
        $q = qq~
            SELECT cd.cat_id 
            FROM ${SESSION{PREFIX}}cats_data cd 
            WHERE cd.cname = ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cname'});
            $res = $sth->fetchrow_hashref();
        };
        return {
            status => 'fail', 
            message => 'cname exist', 
        } if scalar $res -> {'cat_id'};
    }
    
    if (${$cfg}{'parent'}) {
        $q = qq~
            SELECT 
                cd.cat_id, cd.member_id, cd.lang, 
                m_usr.role_id AS creator_role_id
            FROM ${SESSION{PREFIX}}cats_data cd 
                LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
            WHERE cd.cat_id = ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'parent'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'parent not exist', 
        } unless scalar $res -> {'cat_id'};
        
        return {
            status => 'fail', 
            message => 'parent out of permissions', 
        } unless (
            $SESSION{'USR'}->chk_access('categories', 'manage_any', 'w') || 
            $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
            (
                $SESSION{'USR'}->chk_access('categories', 'manage_others', 'w') && 
                $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
            )
        );
        
        ${$cfg}{'lang'} = $res -> {'lang'};

    }
    
    $catNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'cats_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };
    $cat_id = $catNS->insert_unit(
        under => ${$cfg}{'parent'}, 
        order => 'B', 
    );
    
    return {
        status => 'fail', 
        message => 'error creating NS entry', 
    } unless scalar $cat_id;
    
    ${$cfg}{'descr'} = '' unless ${$cfg}{'descr'};
    ${$cfg}{'keywords'} = '' unless ${$cfg}{'keywords'};
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}cats_data (
            cat_id, lang, name, 
            descr, keywords, 
            is_active, cname, member_id, ins
        ) VALUES (
            $cat_id, 
            ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'descr'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'keywords'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'is_active'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'cname'})) . qq~, 
            ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            ~ . ($sql_now) . qq~
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };

    unless (scalar $inscnt) {
        $catNS->delete_unit($cat_id);
        return {
            status => 'fail', 
            message => 'sql ins cats_data entry fail', 
        }
    }

    @parent_cat_slaves = @{$catNS -> get_child_id(unit => ${$cfg}{'parent'})};
    
    &_rest_memd_cats(${$cfg}{'parent'});
    
    return {
        status => 'ok', 
        seq_order => (scalar @parent_cat_slaves), 
        cat_level => ($catNS -> {'unit'} -> {'level'}+1), 
        cat_id => $cat_id, 
        message => 'All ok', 
    };
    
} #-- cats_mk_node

sub cats_edit_node ($) {
    
    my $cfg = shift;

    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'cat_id should be in digits', 
    } unless ${$cfg}{'cat_id'} =~ /^\d+$/;
    
    return {
        status => 'fail', 
        message => 'name len fail',
    } unless ${$cfg}{'name'} =~ /^.{1,32}$/; 
    
    return {
        status => 'fail', 
        message => 'cname len fail',
    } if (
        ${$cfg}{'cname'} !~ /^.{1,16}$/ 
    ); 

    if (${$cfg}{'is_active'}) {
        ${$cfg}{'is_active'} = 1;
    }
    else {
        ${$cfg}{'is_active'} = 0;
    }
    
    my (
        $dbh, $sth, $res, $q, 
        $updcnt, $sql_now, 
    ) = ($SESSION{'DBH'}, );
    
    $sql_now = &sv_datetime_sql();  
    
    $q = qq~
        SELECT 
            cd.cat_id, cd.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}cats_data cd 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
        WHERE cd.cat_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cat_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'cat_id not exist', 
    } unless scalar $res -> {'cat_id'};
    
    return {
        status => 'fail', 
        message => 'cat_id writing out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('categories', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('categories', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    if (${$cfg}{'cname'}) {
        $q = qq~
            SELECT cd.cat_id 
            FROM ${SESSION{PREFIX}}cats_data cd 
            WHERE cd.cname = ? 
                AND cd.cat_id != ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cname'}, ${$cfg}{'cat_id'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'cname exist', 
        } if scalar $res -> {'cat_id'};
    }
    
    ${$cfg}{'descr'} = '' unless ${$cfg}{'descr'};
    ${$cfg}{'keywords'} = '' unless ${$cfg}{'keywords'};
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}cats_data 
        SET 
            name=~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            cname=~ . ($dbh->quote(${$cfg}{'cname'})) . qq~, 
            descr=~ . ($dbh->quote(${$cfg}{'descr'})) . qq~, 
            keywords=~ . ($dbh->quote(${$cfg}{'keywords'})) . qq~, 
            is_active=~ . ($dbh->quote(${$cfg}{'is_active'})) . qq~, 
            whoedit=~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~
        WHERE cat_id = ~ . ($dbh->quote(${$cfg}{'cat_id'})) . qq~ ; 
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };
    
    unless (scalar $updcnt) {
        return {
            status => 'fail', 
            message => 'sql upd cat_data entry fail', 
        }
    }
    
    &_rest_memd_cats(${$cfg}{'cat_id'});
    
    return {
        status => 'ok', 
        cat_id => ${$cfg}{'cat_id'}, 
        message => 'All ok', 
    };
    
} #-- cats_edit_node

sub cats_rm_node ($) {
    
    my $cats = $_[0];
    
    my (
        $dbh, $catNS, 
        @cats, @writable_cats, @cat_slaves, 
        $q, $res, $sth, 
        $in_str, 
    ) = ($SESSION{'DBH'}, );
    
    if ($cats && ref $cats && ref $cats eq 'ARRAY') {
        @cats = @{$cats};
    }
    elsif ($cats && $cats =~ /^\d+$/) {
        push @cats, $cats;
    }
    else {
        return {
            status => 'fail', 
            message => 'input data fmt unknown', 
        }
    }
    
    if ( !(scalar @cats) || (scalar (grep(/\D/, @cats))) ) {
        return {
            status => 'fail', 
            message => 'input data fmt wrong', 
        }
    }
    
    $in_str = join ', ', @cats;
    
    $q = qq~
        SELECT 
            cd.cat_id, cd.member_id, 
            m_usr.role_id AS creator_role_id
        FROM ${SESSION{PREFIX}}cats_data cd 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
        WHERE cd.cat_id IN ( $in_str ) ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q);$sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            push @writable_cats, $res -> {'cat_id'} if (
                $SESSION{'USR'}->chk_access('categories', 'manage_any', 'w') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('categories', 'manage_others', 'w') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                )
            );
        }
        $sth -> finish();
    };

    return {
        status => 'fail', 
        message => 'all or some of requested cats !writable or !exist', 
    } unless ((scalar @cats) == (scalar @writable_cats));
    
    $catNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'cats_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };

    foreach my $cat_id (@cats) {
    &_rest_memd_cats($cat_id);
        @cat_slaves = @{$catNS -> get_child_id(unit => $cat_id, branch => 'all')};
        if ( $catNS -> delete_unit($cat_id) ) {
            push @cat_slaves, $cat_id;
            
            $in_str = join ', ', @cat_slaves;

            $q = qq~
                DELETE 
                FROM ${SESSION{PREFIX}}cats_trans 
                WHERE cat_id IN ( $in_str ) ; 
            ~; 
            eval {
                $dbh -> do($q);
            };

            $q = qq~
                DELETE 
                FROM ${SESSION{PREFIX}}cats_data 
                WHERE cat_id IN ( $in_str ) ; 
            ~; 
            eval {
                $dbh -> do($q);
            };
            
        }
        else {
            return {
                status => 'fail', 
                message => 'Some of cats tree unit delition failed', 
            }
        }
        
    }
            
    return {
        status => 'ok', 
        message => 'All ok. Catsegories(s) deleted succesfully', 
    }
    
} #-- cats_rm_node

sub cats_set_sequence ($) {
    
    my %cats_weight = %{$_[0]};
    
    my (
        $dbh, 
        $q, $res, $sth, 
        $in_str, %cats_struct, 
        $records_cnt, $catNS, 
    ) = ($SESSION{'DBH'}, );
    
    if ( !(scalar keys %cats_weight) || (scalar (grep(/\D/, keys %cats_weight))) ) {
        return {
            status => 'fail', 
            message => 'Some of cats ids not digital or no cats', 
        }
    }
    
    $in_str = join ', ', keys %cats_weight;
    
    $dbh -> do(qq~
        LOCK TABLES 
            ${SESSION{PREFIX}}cats_tree AS c WRITE, 
            ${SESSION{PREFIX}}cats_tree AS cp WRITE, 
            ${SESSION{PREFIX}}cats_data AS cd READ, 
            ${SESSION{PREFIX}}users AS m_usr READ ; 
    ~);
    
    $q = qq~
        SELECT 
            c.id, c.level, cd.member_id, cp.id AS pid, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}cats_tree c 
            LEFT JOIN ${SESSION{PREFIX}}cats_data cd 
                ON cd.cat_id=c.id 
            LEFT JOIN ${SESSION{PREFIX}}cats_tree cp 
                ON (
                    cp.level=( c.level - 1 )
                    AND 
                        cp.left_key<c.left_key 
                    AND 
                        cp.right_key>c.right_key 
                )
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
        WHERE c.id IN ( $in_str )
        ORDER BY c.left_key ; 
    ~;
    
    $records_cnt = 0;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            
            next unless (
                $SESSION{'USR'}->chk_access('categories', 'manage_any', 'w') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('categories', 'manage_others', 'w') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                )
            );
            
            $cats_struct{$res -> {'level'}} = {} 
                unless defined $cats_struct{$res -> {'level'}};
            
            $cats_struct{$res -> {'level'}}{$res -> {'pid'}} = []
                unless defined 
                    $cats_struct{$res -> {'level'}}{$res -> {'pid'}};
                    
            push 
                @{$cats_struct{$res -> {'level'}}{$res -> {'pid'}}}, 
                    $res -> {'id'}; 
                    
            $records_cnt++;
        }
        $sth -> finish(); 
    };
    
    $dbh -> do("UNLOCK TABLES ; ");
    
    return {
        status => 'fail', 
        message => 'count chk fail some of cats not found or not writable', 
    } unless $records_cnt == (scalar keys %cats_weight);
    
    $catNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'cats_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };
    
    foreach my $lvl (
        sort {
            $cats_struct{$a} > $cats_struct{$b} #backwards from deepest level
        } keys %cats_struct) {
            
        foreach my $pid (keys %{$cats_struct{$lvl}}) {
            foreach my $id (
                sort {
                    $cats_weight{$a} < $cats_weight{$b} #backwards move to front
                } @{${$cats_struct{$lvl}}{$pid}}
            ) {
                return {
                    status => 'fail', 
                    message => 'Cat unit move failed for some reasons', 
                } unless (
                    $catNS -> set_unit_under(
                        unit => $id,
                        under => $pid,
                        order => 'top',
                    )
                );
            }
        }
        
    }
    
    return {
        status => 'ok', 
        message => 'All ok. Cats(s) resorted', 
    };
    
} #-- cats_set_sequence

sub cats_mk_trans_record ($) {
    
    my $cfg = shift;

    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'cat_id is not \d+', 
    } unless ${$cfg}{'cat_id'} =~ /^\d+$/;
    
    return {
        status => 'fail', 
        message => 'name len fail',
    } unless ${$cfg}{'name'} =~ /^.{1,32}$/; 
    
    return {
        status => 'fail', 
        message => 'lang unknown', 
    } unless (
        &inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 
    
    
    my (
        $dbh, $sth, $res, $q, 
        $inscnt, $sql_now,
        
    ) = ($SESSION{'DBH'}, );

    $q = qq~
        SELECT 
            cd.cat_id, cd.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}cats_data cd 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
        WHERE cd.cat_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cat_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'cat_id not exist', 
    } unless scalar $res -> {'cat_id'};
    
    return {
        status => 'fail', 
        message => 'cat writing out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('categories', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('categories', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        SELECT 
            #ct.cat_id, ct.lang 
            COUNT(*) AS cnt 
        FROM ${SESSION{PREFIX}}cats_trans ct 
        WHERE ct.cat_id = ? AND ct.lang = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cat_id'}, ${$cfg}{'lang'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'trans for that lang exists', 
    } if scalar $res -> {'cnt'};
    
    $sql_now = &sv_datetime_sql();
    ${$cfg}{'descr'} = '' unless ${$cfg}{'descr'};
    ${$cfg}{'keywords'} = '' unless ${$cfg}{'keywords'};
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}cats_trans (
            cat_id, lang, name, 
            descr, keywords, 
            member_id, ins
        ) VALUES (
            ~ . ($dbh->quote(${$cfg}{'cat_id'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'descr'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'keywords'})) . qq~, 
            ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            ~ . ($sql_now) . qq~
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };
    
    return {
        status => 'fail', 
        message => 'sql ins cats_trans entry fail', 
    } unless scalar $inscnt;
    
    &_rest_memd_cats(${$cfg}{'cat_id'});
    
    return {
        status => 'ok', 
        cat_id => ${$cfg}{'cat_id'}, 
        cat_lang => ${$cfg}{'lang'}, 
        message => 'All ok', 
    };
    
} #-- cats_mk_trans_record

sub cats_edit_trans_record ($) {
    
    my $cfg = shift;

    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'cat_id is not \d+', 
    } unless ${$cfg}{'cat_id'} =~ /^\d+$/;
    
    return {
        status => 'fail', 
        message => 'name len fail',
    } unless ${$cfg}{'name'} =~ /^.{1,32}$/; 
    
    return {
        status => 'fail', 
        message => 'lang unknown', 
    } unless (
        ${$cfg}{'old_lang'} && 
        &inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'old_lang'})
    ); 
    
    return {
        status => 'fail', 
        message => 'lang unknown', 
    } unless (
        ${$cfg}{'lang'} && 
        &inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 
    
    my (
        $dbh, $sth, $res, $q, 
        $updcnt, $sql_now,
        
    ) = ($SESSION{'DBH'}, );

    $q = qq~
        SELECT 
            cd.cat_id, cd.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}cats_data cd 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
        WHERE cd.cat_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cat_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'cat_id not exist', 
    } unless scalar $res -> {'cat_id'};
    
    return {
        status => 'fail', 
        message => 'cat writing out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('categories', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('categories', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        SELECT 
            #ct.cat_id, ct.lang 
            COUNT(*) AS cnt 
        FROM ${SESSION{PREFIX}}cats_trans ct 
        WHERE 
            AND ct.lang != ? 
                AND ct.cat_id = ? 
                    AND ct.lang = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'old_lang'}, ${$cfg}{'cat_id'}, ${$cfg}{'lang'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'trans for that lang exists', 
    } if scalar $res -> {'cnt'};
    
    ${$cfg}{'descr'} = '' unless ${$cfg}{'descr'};
    ${$cfg}{'keywords'} = '' unless ${$cfg}{'keywords'};
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}cats_trans 
        SET 
            name=~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            descr=~ . ($dbh->quote(${$cfg}{'descr'})) . qq~, 
            keywords=~ . ($dbh->quote(${$cfg}{'keywords'})) . qq~, 
            lang=~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            whoedit=~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~
        WHERE 
            cat_id = ~ . ($dbh->quote(${$cfg}{'cat_id'})) . qq~ 
            AND lang = ~ . ($dbh->quote(${$cfg}{'old_lang'})) . qq~ 
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };
    
    return {
        status => 'fail', 
        message => 'sql upd cats_trans entry fail', 
    } unless scalar $updcnt;

    &_rest_memd_cats(${$cfg}{'cat_id'});

    return {
        status => 'ok', 
        cat_id => ${$cfg}{'cat_id'}, 
        message => 'All ok', 
    };

} #-- cats_edit_trans_record

sub cats_rm_trans_record ($) {
    
    my $cfg = shift;

    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'cat_id is not \d+', 
    } unless ${$cfg}{'cat_id'} =~ /^\d+$/;

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } unless (
        &inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 
    
    my (
        $dbh, $sth, $res, $q, 
        $delcnt, $sql_now,
        
    ) = ($SESSION{'DBH'}, );

    $q = qq~
        SELECT 
            cd.cat_id, cd.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}cats_data cd 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
        WHERE cd.cat_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cat_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'cat_id not exist', 
    } unless scalar $res -> {'cat_id'};
    
    return {
        status => 'fail', 
        message => 'cat writing out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('categories', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('categories', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        DELETE 
        FROM ${SESSION{PREFIX}}cats_trans 
        WHERE cat_id = ~ . ($dbh->quote(${$cfg}{'cat_id'})) . qq~ 
            AND lang = ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~ 
        LIMIT 1 ; 
    ~;
    eval {
        $delcnt = $dbh->do($q);
    };
    
    return {
        status => 'fail', 
        message => 'sql del cats_trans entry fail', 
    } unless scalar $delcnt;

    &_rest_memd_cats(${$cfg}{'cat_id'});

    return {
        status => 'ok', 
        cat_id => ${$cfg}{'cat_id'}, 
        message => 'All ok', 
    };
} #-- cats_rm_trans_record

sub pages_add_page ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no access to add page', 
    } unless (
        $SESSION{'USR'}->chk_access('pages', 'manage', 'w') 
    );
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    my $sql_now = &sv_datetime_sql();
    
    return {
        status => 'fail', 
        message => 'cat_id incorrect', 
    } unless ${$cfg}{'cat_id'} =~ /^\d+$/;

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 
    
    return {
        status => 'fail', 
        message => 'slug len fail',
    } if (
        ${$cfg}{'slug'} &&
        ${$cfg}{'slug'} !~ /^.{1,128}$/ 
    );
    
    return {
        status => 'fail', 
        message => 'header len fail',
    } if (
        !${$cfg}{'header'} ||
        ${$cfg}{'header'} !~ /^.{1,64}$/
    ); 
    
    if (${$cfg}{'is_published'}) {
        ${$cfg}{'is_published'} = 1;
    }
    else {
        ${$cfg}{'is_published'} = 0;
    }

    if (${$cfg}{'showintro'}) {
        ${$cfg}{'showintro'} = 1;
    }
    else {
        ${$cfg}{'showintro'} = 0;
    }
    
    return {
        status => 'fail', 
        message => 'intro len fail',
    } unless ${$cfg}{'intro'}; 
    
    if (${$cfg}{'use_customtitle'}) {
        ${$cfg}{'use_customtitle'} = 1;
    }
    else {
        ${$cfg}{'use_customtitle'} = 0;
    }
    
    return {
        status => 'fail', 
        message => 'custom_title len fail',
    } if (
        ${$cfg}{'custom_title'} &&
        ${$cfg}{'custom_title'} !~ /^.{1,64}$/
    ); 
    
    if (${$cfg}{'allow_comments'}) {
        ${$cfg}{'allow_comments'} = 1;
    }
    else {
        ${$cfg}{'allow_comments'} = 0;
    }
    
    return {
        status => 'fail', 
        message => 'comments_mode len fail',
    } if (
        ${$cfg}{'comments_mode'} && 
        ${$cfg}{'comments_mode'} !~ /^.{1,8}$/
    ); 
    
    if (${$cfg}{'use_password'}) {
        ${$cfg}{'use_password'} = 1;
    }
    else {
        ${$cfg}{'use_password'} = 0;
    }
    
    return {
        status => 'fail', 
        message => 'password len fail',
    } if (
        ${$cfg}{'password'} &&
        ${$cfg}{'password'} !~ /^.{1,64}$/
    ); 
    
    if (${$cfg}{'use_access_roles'}) {
        ${$cfg}{'use_access_roles'} = 1;
    }
    else {
        ${$cfg}{'use_access_roles'} = 0;
    }

    return {
        status => 'fail', 
        message => 'author format incorrect', 
    } unless (
        ${$cfg}{'author_id'} =~ /^\d+$/ 
    );
    
    my (
        $dbh, $sth, $res, $q, 
        $page_id, $inscnt, 
        $dt_fmt, @qs, 
        
    ) = ($SESSION{'DBH'}, );
    
    unless (
            $SESSION{'USR'}->chk_access('pages', 'manage_any', 'w') || 
            $SESSION{'USR'}->is_user_writable( ${$cfg}{'author_id'} )
    ) {
        $q = qq~
            SELECT 
                ua.member_id, ua.role_id 
            FROM ${SESSION{PREFIX}}users ua 
            WHERE ua.member_id = ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'author_id'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        
        return {
            status => 'fail', 
            message => 'author incorrect or is not writable', 
        } unless (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'role_id'} == $SESSION{'USR'}->{'role_id'} 
        );
    }
    
    $dt_fmt = $SESSION{'LOC'}->get_dt_fmt();
    
    if (${$cfg}{'dt_created'}) {
        ${$cfg}{'dt_created'} = $SESSION{'DATE'}->fparse($dt_fmt, ${$cfg}{'dt_created'});
        ${$cfg}{'dt_created'} = (${$cfg}{'dt_created'} =~ /^\d+$/)? 
            $SESSION{'DATE'}->datetime_sql(${$cfg}{'dt_created'}): 'NULL';
    }
    unless (${$cfg}{'dt_created'}) {
        ${$cfg}{'dt_created'} = $sql_now;
    }
    
    if (${$cfg}{'dt_publishstart'}) {
        ${$cfg}{'dt_publishstart'} = $SESSION{'DATE'}->fparse($dt_fmt, ${$cfg}{'dt_publishstart'});
        ${$cfg}{'dt_publishstart'} =  (${$cfg}{'dt_publishstart'} =~ /^\d+$/)? 
            $SESSION{'DATE'}->datetime_sql(${$cfg}{'dt_publishstart'}): 'NULL';
    }
    unless (${$cfg}{'dt_publishstart'}) {
        ${$cfg}{'dt_publishstart'} = 'NULL';
    }
    
    if (${$cfg}{'dt_publishend'}) {
        ${$cfg}{'dt_publishend'} = $SESSION{'DATE'}->fparse($dt_fmt, ${$cfg}{'dt_publishend'});
        ${$cfg}{'dt_publishend'} =  (${$cfg}{'dt_publishend'} =~ /^\d+$/)? 
            $SESSION{'DATE'}->datetime_sql(${$cfg}{'dt_publishend'}): 'NULL';
    }
    unless (${$cfg}{'dt_publishend'}) {
        ${$cfg}{'dt_publishend'} = 'NULL';
    }
    
    if (${$cfg}{'slug'}) {
        $q = qq~
            SELECT p.page_id 
            FROM ${SESSION{PREFIX}}pages p 
            WHERE p.slug = ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'slug'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'slug exist', 
        } if scalar $res -> {'page_id'};
    }
    else { ${$cfg}{'slug'} = undef; }
    
    if (${$cfg}{'cat_id'}) {
        $q = qq~
            SELECT 
                cd.cat_id, cd.member_id, 
                m_usr.role_id AS creator_role_id 
            FROM ${SESSION{PREFIX}}cats_data cd 
                LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
            WHERE cd.cat_id = ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cat_id'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'parent not exist', 
        } unless scalar $res -> {'cat_id'};
        
        return {
            status => 'fail', 
            message => 'parent out of permissions', 
        } unless (
            $SESSION{'USR'}->chk_access('categories', 'manage_any', 'w') || 
            $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
            (
                $SESSION{'USR'}->chk_access('categories', 'manage_others', 'w') && 
                $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
            )
        );
    }
    else { ${$cfg}{'cat_id'} = 0; }
    
    ${$cfg}{'descr'} = '' unless ${$cfg}{'descr'};
    ${$cfg}{'keywords'} = '' unless ${$cfg}{'keywords'};
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}pages (
            is_published, cat_id, lang, slug, 
            intro, body, header, descr, keywords, 
            showintro, 
            use_customtitle, custom_title, 
            allow_comments, comments_mode, 
            use_password, password, 
            use_access_roles, 
            comments_count, 
            author_id, member_id, 
            ins, 
            dt_created, dt_publishstart, dt_publishend
        ) VALUES (
            ~ . ($dbh->quote(${$cfg}{'is_published'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'cat_id'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'slug'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'intro'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'body'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'header'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'descr'})) . qq~,  
            ~ . ($dbh->quote(${$cfg}{'keywords'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'showintro'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'use_customtitle'})) . qq~,  
            ~ . ($dbh->quote(${$cfg}{'custom_title'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'allow_comments'})) . qq~,  
            ~ . ($dbh->quote(${$cfg}{'comments_mode'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'use_password'})) . qq~,  
            ~ . ($dbh->quote(${$cfg}{'password'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'use_access_roles'})) . qq~,  
            
            0,
            
            ~ . ($dbh->quote(${$cfg}{'author_id'})) . qq~,  
            ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            
            ~ . ($sql_now) . qq~, 
            
            ~ . (${$cfg}{'dt_created'}) . qq~,  
            ~ . (${$cfg}{'dt_publishstart'}) . qq~,  
            ~ . (${$cfg}{'dt_publishend'}) . qq~ 
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };

    unless (scalar $inscnt) {
        return {
            status => 'fail', 
            message => 'sql ins into pages entry fail', 
        }
    }

    $q = qq~ SELECT LAST_INSERT_ID() AS lid; ~;
    eval {
        ($page_id) = $dbh -> selectrow_array($q);
    };
    
    if (${$cfg}{'use_access_roles'}) {
        if (
            scalar @{${$cfg}{'access_roles'}} && 
            !(scalar (grep(/\D/, @{${$cfg}{'access_roles'}})))
        ) {
            
            foreach my $r (@{${$cfg}{'access_roles'}}){
                push @qs, qq~ ( $page_id, $r, ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~, NOW()) ~;
            }
            $q = qq~
                INSERT INTO 
                ${SESSION{PREFIX}}pages_access_roles ( 
                    page_id, role_id, whoedit, ins 
                ) 
                VALUES ~ . (join ', ', @qs) . ' ; ';
            eval {
                $inscnt = $dbh -> do($q);
            };
            return {
                status => 'ok', 
                parent_cat_id => ${$cfg}{'cat_id'}, 
                page_id => $page_id, 
                message => 'All ok, but access roles creation failed', 
            } unless (scalar $inscnt == scalar @qs);
            
        }
    }
    
    &_rest_memd_cats(${$cfg}{'cat_id'});
    
    return {
        status => 'ok', 
        parent_cat_id => ${$cfg}{'cat_id'}, 
        page_id => $page_id, 
        message => 'All ok', 
    };
} #-- pages_add_page

sub pages_edit_page ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    my $sql_now = &sv_datetime_sql();
    
    return {
        status => 'fail', 
        message => 'cat_id incorrect', 
    } unless ${$cfg}{'cat_id'} =~ /^\d+$/;
    
    return {
        status => 'fail', 
        message => 'page_id incorrect', 
    } unless ${$cfg}{'page_id'} =~ /^\d+$/;

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 
    
    return {
        status => 'fail', 
        message => 'slug len fail',
    } if (
        ${$cfg}{'slug'} &&
        ${$cfg}{'slug'} !~ /^.{1,128}$/ 
    );
    
    return {
        status => 'fail', 
        message => 'header len fail',
    } if (
        !${$cfg}{'header'} ||
        ${$cfg}{'header'} !~ /^.{1,64}$/
    ); 
    
    if (${$cfg}{'is_published'}) {
        ${$cfg}{'is_published'} = 1;
    }
    else {
        ${$cfg}{'is_published'} = 0;
    }

    if (${$cfg}{'showintro'}) {
        ${$cfg}{'showintro'} = 1;
    }
    else {
        ${$cfg}{'showintro'} = 0;
    }
    
    return {
        status => 'fail', 
        message => 'intro len fail',
    } unless ${$cfg}{'intro'}; 
    
    if (${$cfg}{'use_customtitle'}) {
        ${$cfg}{'use_customtitle'} = 1;
    }
    else {
        ${$cfg}{'use_customtitle'} = 0;
    }
    
    return {
        status => 'fail', 
        message => 'custom_title len fail',
    } if (
        ${$cfg}{'custom_title'} &&
        ${$cfg}{'custom_title'} !~ /^.{1,64}$/
    ); 
    
    if (${$cfg}{'allow_comments'}) {
        ${$cfg}{'allow_comments'} = 1;
    }
    else {
        ${$cfg}{'allow_comments'} = 0;
    }
    
    return {
        status => 'fail', 
        message => 'comments_mode len fail',
    } if (
        ${$cfg}{'comments_mode'} && 
        ${$cfg}{'comments_mode'} !~ /^.{1,8}$/
    ); 
    
    if (${$cfg}{'use_password'}) {
        ${$cfg}{'use_password'} = 1;
    }
    else {
        ${$cfg}{'use_password'} = 0;
    }
    
    return {
        status => 'fail', 
        message => 'password len fail',
    } if (
        ${$cfg}{'password'} &&
        ${$cfg}{'password'} !~ /^.{1,64}$/
    ); 
    
    if (${$cfg}{'use_access_roles'}) {
        ${$cfg}{'use_access_roles'} = 1;
    }
    else {
        ${$cfg}{'use_access_roles'} = 0;
    }

    return {
        status => 'fail', 
        message => 'author incorrect', 
    } unless (
        ${$cfg}{'author_id'} =~ /^\d+$/ 
    );
    
    my (
        $dbh, $sth, $res, $q, 
        $inscnt, $updcnt, 
        $dt_fmt, @qs, 
        
    ) = ($SESSION{'DBH'}, );
    
    unless (
            $SESSION{'USR'}->chk_access('pages', 'manage_any', 'w') || 
            $SESSION{'USR'}->is_user_writable( ${$cfg}{'author_id'} )
    ) {
        $q = qq~
            SELECT 
                ua.member_id, ua.role_id 
            FROM ${SESSION{PREFIX}}users ua 
            WHERE ua.member_id = ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'author_id'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        
        return {
            status => 'fail', 
            message => 'author incorrect or is not writable', 
        } unless (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'role_id'} == $SESSION{'USR'}->{'role_id'} 
        );
    }
    
    $dt_fmt = $SESSION{'LOC'}->get_dt_fmt();
    
    if (${$cfg}{'dt_created'}) {
        ${$cfg}{'dt_created'} = $SESSION{'DATE'}->fparse($dt_fmt, ${$cfg}{'dt_created'});
        ${$cfg}{'dt_created'} = (${$cfg}{'dt_created'} =~ /^\d+$/)? 
            $SESSION{'DATE'}->datetime_sql(${$cfg}{'dt_created'}): 'NULL';
    }
    unless (${$cfg}{'dt_created'}) {
        ${$cfg}{'dt_created'} = $sql_now;
    }
    
    if (${$cfg}{'dt_publishstart'}) {
        ${$cfg}{'dt_publishstart'} = $SESSION{'DATE'}->fparse($dt_fmt, ${$cfg}{'dt_publishstart'});
        ${$cfg}{'dt_publishstart'} =  (${$cfg}{'dt_publishstart'} =~ /^\d+$/)? 
            $SESSION{'DATE'}->datetime_sql(${$cfg}{'dt_publishstart'}): 'NULL';
    }
    unless (${$cfg}{'dt_publishstart'}) {
        ${$cfg}{'dt_publishstart'} = 'NULL';
    }
    
    if (${$cfg}{'dt_publishend'}) {
        ${$cfg}{'dt_publishend'} = $SESSION{'DATE'}->fparse($dt_fmt, ${$cfg}{'dt_publishend'});
        ${$cfg}{'dt_publishend'} =  (${$cfg}{'dt_publishend'} =~ /^\d+$/)? 
            $SESSION{'DATE'}->datetime_sql(${$cfg}{'dt_publishend'}): 'NULL';
    }
    unless (${$cfg}{'dt_publishend'}) {
        ${$cfg}{'dt_publishend'} = 'NULL';
    }

    $q = qq~
        SELECT 
            p.page_id, p.author_id, p.member_id, 
            a_usr.role_id AS author_role_id, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}pages p 
            LEFT JOIN ${SESSION{PREFIX}}users a_usr ON a_usr.member_id=p.author_id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=p.member_id 
        WHERE p.page_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'page_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'page not exist', 
    } unless scalar $res -> {'page_id'};
    
    return {
        status => 'fail', 
        message => 'page out of permissions', 
    } unless (
        #$res -> {'author_id'} == ${$cfg}{'author_id'} || 
        $SESSION{'USR'}->chk_access('pages', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'author_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'author_role_id'} == $SESSION{'USR'}->{'role_id'} 
        ) ||
        #$res -> {'member_id'} == $SESSION{'USR'}->{'member_id'} || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    if (defined ${$cfg}{'slug'}) {
        $q = qq~
            SELECT p.page_id 
            FROM ${SESSION{PREFIX}}pages p 
            WHERE p.slug = ? 
                AND p.page_id != ? ; 
        ~;
        
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'slug'}, ${$cfg}{'page_id'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'slug exist', 
        } if scalar $res -> {'page_id'};
    }
    else { ${$cfg}{'slug'} = undef; }
    
    if (${$cfg}{'cat_id'}) {
        $q = qq~
            SELECT 
                cd.cat_id, cd.member_id, 
                m_usr.role_id AS creator_role_id 
            FROM ${SESSION{PREFIX}}cats_data cd 
                LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
            WHERE cd.cat_id = ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cat_id'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'parent not exist', 
        } unless scalar $res -> {'cat_id'};
        
        return {
            status => 'fail', 
            message => 'parent out of permissions', 
        } unless (
            $SESSION{'USR'}->chk_access('categories', 'manage_any', 'w') || 
            $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
            (
                $SESSION{'USR'}->chk_access('categories', 'manage_others', 'w') && 
                $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
            )
        );
    }
    else { ${$cfg}{'cat_id'} = 0; }
    
    ${$cfg}{'descr'} = '' unless ${$cfg}{'descr'};
    ${$cfg}{'keywords'} = '' unless ${$cfg}{'keywords'};
    
    if ($SESSION{'CONTENT_ARCHIVE_PAGES'}) {
        $q = qq~
            INSERT INTO 
            ${SESSION{PREFIX}}pages_archive (
                page_id, 
                is_published, cat_id, lang, slug, 
                intro, body, header, descr, keywords, 
                showintro, 
                use_customtitle, custom_title, 
                allow_comments, comments_mode, 
                use_password, password, 
                use_access_roles, 
                comments_count, 
                author_id, member_id, 
                whoedit,
                ins, 
                dt_created, dt_publishstart, dt_publishend
            ) 
            SELECT 
                p.page_id, 
                p.is_published, p.cat_id, p.lang, p.slug, 
                p.intro, p.body, p.header, p.descr, p.keywords, 
                p.showintro, 
                p.use_customtitle, p.custom_title, 
                p.allow_comments, p.comments_mode, 
                p.use_password, p.password, 
                p.use_access_roles, 
                p.comments_count, 
                p.author_id, p.member_id, 
                ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~, 
                p.ins, 
                p.dt_created, p.dt_publishstart, p.dt_publishend 
            FROM ${SESSION{PREFIX}}pages p
            WHERE p.page_id = ~ . ($dbh->quote(${$cfg}{'page_id'})) . ' ; ';
        eval {
            $inscnt = $dbh->do($q);
        };
        unless (scalar $inscnt) {
            return {
                status => 'fail', 
                message => 'sql ins into pages_archive fail', 
            }
        }
    }
    
    #Make check @ transes first
    #lang = ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}pages 
        SET 
            is_published = ~ . ($dbh->quote(${$cfg}{'is_published'})) . qq~, 
            cat_id = ~ . ($dbh->quote(${$cfg}{'cat_id'})) . qq~, 
            slug = ~ . ($dbh->quote(${$cfg}{'slug'})) . qq~, 
            intro = ~ . ($dbh->quote(${$cfg}{'intro'})) . qq~, 
            body = ~ . ($dbh->quote(${$cfg}{'body'})) . qq~, 
            header = ~ . ($dbh->quote(${$cfg}{'header'})) . qq~, 
            descr = ~ . ($dbh->quote(${$cfg}{'descr'})) . qq~,  
            keywords = ~ . ($dbh->quote(${$cfg}{'keywords'})) . qq~, 
            showintro = ~ . ($dbh->quote(${$cfg}{'showintro'})) . qq~, 
            use_customtitle = ~ . ($dbh->quote(${$cfg}{'use_customtitle'})) . qq~,  
            custom_title = ~ . ($dbh->quote(${$cfg}{'custom_title'})) . qq~, 
            allow_comments = ~ . ($dbh->quote(${$cfg}{'allow_comments'})) . qq~,  
            comments_mode = ~ . ($dbh->quote(${$cfg}{'comments_mode'})) . qq~, 
            use_password = ~ . ($dbh->quote(${$cfg}{'use_password'})) . qq~,  
            password = ~ . ($dbh->quote(${$cfg}{'password'})) . qq~, 
            use_access_roles = ~ . ($dbh->quote(${$cfg}{'use_access_roles'})) . qq~,  
            author_id = ~ . ($dbh->quote(${$cfg}{'author_id'})) . qq~,  
            whoedit = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~, 
            dt_created = ~ . (${$cfg}{'dt_created'}) . qq~,  
            dt_publishstart = ~ . (${$cfg}{'dt_publishstart'}) . qq~,  
            dt_publishend = ~ . (${$cfg}{'dt_publishend'}) . qq~ 
        WHERE page_id = ~ . ($dbh->quote(${$cfg}{'page_id'})) . ' ; ';
    eval {
        $updcnt = $dbh->do($q);
    };

    unless (scalar $updcnt) {
        return {
            status => 'fail', 
            message => 'sql upd pages record fail', 
        }
    }

    $q = qq~
        DELETE 
        FROM ${SESSION{PREFIX}}pages_access_roles 
        WHERE page_id = ~ . ($dbh->quote(${$cfg}{'page_id'})) . ' ; ';
    eval{
        $dbh->do($q);
    };
    if (${$cfg}{'use_access_roles'}) {
        if (
            scalar @{${$cfg}{'access_roles'}} && 
            !(scalar (grep(/\D/, @{${$cfg}{'access_roles'}})))
        ) {
            
            foreach my $r (@{${$cfg}{'access_roles'}}){
                push @qs, qq~ ( ~ . ($dbh->quote(${$cfg}{'page_id'})) . qq~, $r, ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~, NOW() ) ~;
            }
            $q = qq~
                INSERT INTO 
                ${SESSION{PREFIX}}pages_access_roles ( 
                    page_id, role_id, whoedit, ins 
                ) 
                VALUES ~ . (join ', ', @qs) . ' ; ';
            eval {
                $inscnt = $dbh -> do($q);
            };
            return {
                status => 'ok', 
                page_id =>  ${$cfg}{'page_id'}, 
                message => 'All ok, but access roles creation failed', 
            } unless (scalar $inscnt == scalar @qs);
            
        }
    }
    
    &_rest_memd_pages(${$cfg}{'page_id'});
    
    return {
        status => 'ok', 
        page_id =>  ${$cfg}{'page_id'}, 
        message => 'All ok', 
    };
} #-- pages_edit_page

sub pages_delete_page ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail', 
        message => 'page_id incorrect', 
    } unless ${$cfg}{'page_id'} =~ /^\d+$/;
    
    my (
        $dbh, $sth, $res, $q, 
        $delcnt, $cat_id, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        SELECT p.cat_id, 
            p.page_id, p.author_id, p.member_id, 
            a_usr.role_id AS author_role_id, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}pages p 
            LEFT JOIN ${SESSION{PREFIX}}users a_usr ON a_usr.member_id=p.author_id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=p.member_id 
        WHERE p.page_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'page_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'page not exist', 
    } unless scalar $res -> {'page_id'};
    
    return {
        status => 'fail', 
        message => 'page out of permissions', 
    } unless (
        #$res -> {'author_id'} == ${$cfg}{'author_id'} || 
        $SESSION{'USR'}->chk_access('pages', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'author_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'author_role_id'} == $SESSION{'USR'}->{'role_id'} 
        ) ||
        #$res -> {'member_id'} == $SESSION{'USR'}->{'member_id'} || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $cat_id = $res -> {'cat_id'};
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}pages_access_roles 
        WHERE page_id = ~ . ($dbh->quote(${$cfg}{'page_id'})) . ' ; ';
    eval{
        $dbh -> do($q);
    };
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}pages_archive 
        WHERE page_id = ~ . ($dbh->quote(${$cfg}{'page_id'})) . ' ; ';
    eval{
        $dbh -> do($q);
    };
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}pages_translations 
        WHERE page_id = ~ . ($dbh->quote(${$cfg}{'page_id'})) . ' ; ';
    eval{
        $dbh -> do($q);
    };
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}pages 
        WHERE page_id = ~ . ($dbh->quote(${$cfg}{'page_id'})) . ' ; ';
    eval{
        $dbh -> do($q);
    };
    
    &_rest_memd_cats($cat_id);
    
    return {
        status => 'ok', 
        page_id =>  ${$cfg}{'page_id'}, 
        message => 'All ok', 
    };
} #-- pages_delete_page

sub page_translation_save ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail', 
        message => 'page_id incorrect', 
    } unless ${$cfg}{'page_id'} =~ /^\d+$/;

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 

    return {
        status => 'fail', 
        message => 'header len fail',
    } if (
        !${$cfg}{'header'} ||
        ${$cfg}{'header'} !~ /^.{1,64}$/
    ); 
    
    return {
        status => 'fail', 
        message => 'intro len fail',
    } unless ${$cfg}{'intro'}; 
    
    return {
        status => 'fail', 
        message => 'custom_title len fail',
    } if (
        ${$cfg}{'custom_title'} &&
        ${$cfg}{'custom_title'} !~ /^.{1,64}$/
    ); 
    
    my (
        $dbh, $sth, $res, $q, 
        $inscnt, 
        $sql_now, 
        
    ) = ($SESSION{'DBH'}, );
    
    $sql_now = &sv_datetime_sql();
    
    $q = qq~
        SELECT 
            p.page_id, p.author_id, p.member_id, 
            p.lang, 
            a_usr.role_id AS author_role_id, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}pages p 
            LEFT JOIN ${SESSION{PREFIX}}users a_usr ON a_usr.member_id=p.author_id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=p.member_id 
        WHERE p.page_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'page_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'page not exist', 
    } unless scalar $res -> {'page_id'};
    
    return {
        status => 'fail', 
        message => 'page trans lang match page real lang', 
    } if $res -> {'lang'} eq ${$cfg}{'lang'};
    
    return {
        status => 'fail', 
        message => 'page out of permissions', 
    } unless (
        #$res -> {'author_id'} == ${$cfg}{'author_id'} || 
        $SESSION{'USR'}->chk_access('pages', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'author_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'author_role_id'} == $SESSION{'USR'}->{'role_id'} 
        ) ||
        #$res -> {'member_id'} == $SESSION{'USR'}->{'member_id'} || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        SELECT 
            #pt.page_id, pt.lang,  
            COUNT(*) AS cnt 
        FROM ${SESSION{PREFIX}}pages_translations pt 
        WHERE pt.page_id = ? AND pt.lang = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'page_id'}, ${$cfg}{'lang'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'trans for that lang exists', 
    } if scalar $res -> {'cnt'};
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}pages_translations (
            page_id, lang, 
            intro, body, header, descr, keywords, 
            custom_title, 
            member_id, 
            ins
        ) VALUES (
            ~ . ($dbh->quote(${$cfg}{'page_id'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'intro'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'body'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'header'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'descr'})) . qq~,  
            ~ . ($dbh->quote(${$cfg}{'keywords'})) . qq~, 
            

            ~ . ($dbh->quote(${$cfg}{'custom_title'})) . qq~, 
            
            ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            
            ~ . ($sql_now) . qq~
            
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };

    unless (scalar $inscnt) {
        return {
            status => 'fail', 
            message => 'sql ins into pages_translations entry fail', 
        }
    }
    
    &_rest_memd_pages(${$cfg}{'page_id'});
    
    return {
        page_id => ${$cfg}{'page_id'}, 
        lang => ${$cfg}{'lang'}, 
        status => 'ok', 
        message => 'All OK', 
    };
    
} #-- page_translation_save

sub page_translation_update ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail', 
        message => 'page_id incorrect', 
    } unless ${$cfg}{'page_id'} =~ /^\d+$/;

    return {
        status => 'fail', 
        message => 'current lang unknown', 
    } if (
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'old_lang'})
    ); 

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 

    return {
        status => 'fail', 
        message => 'header len fail',
    } if (
        !${$cfg}{'header'} ||
        ${$cfg}{'header'} !~ /^.{1,64}$/
    ); 
    
    return {
        status => 'fail', 
        message => 'intro len fail',
    } unless ${$cfg}{'intro'}; 
    
    return {
        status => 'fail', 
        message => 'custom_title len fail',
    } if (
        ${$cfg}{'custom_title'} &&
        ${$cfg}{'custom_title'} !~ /^.{1,64}$/
    ); 
    
    my (
        $dbh, $sth, $res, $q, 
        $updcnt, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        SELECT 
            p.page_id, p.author_id, p.member_id, 
            p.lang, 
            a_usr.role_id AS author_role_id, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}pages p 
            LEFT JOIN ${SESSION{PREFIX}}users a_usr ON a_usr.member_id=p.author_id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=p.member_id 
        WHERE p.page_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'page_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'page not exist', 
    } unless scalar $res -> {'page_id'};
    
    return {
        status => 'fail', 
        message => 'page trans lang match page real lang', 
    } if $res -> {'lang'} eq ${$cfg}{'lang'};
    
    return {
        status => 'fail', 
        message => 'page out of permissions', 
    } unless (
        #$res -> {'author_id'} == ${$cfg}{'author_id'} || 
        $SESSION{'USR'}->chk_access('pages', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'author_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'author_role_id'} == $SESSION{'USR'}->{'role_id'} 
        ) ||
        #$res -> {'member_id'} == $SESSION{'USR'}->{'member_id'} || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        SELECT 
            #pt.page_id, pt.lang,  
            COUNT(*) AS cnt 
        FROM ${SESSION{PREFIX}}pages_translations pt 
        WHERE 
            pt.page_id = ? 
                AND pt.lang = ? 
                    AND pt.lang != ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'page_id'}, ${$cfg}{'lang'}, ${$cfg}{'old_lang'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'trans for that lang exists', 
    } if scalar $res -> {'cnt'};
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}pages_translations 
        SET 
            lang = ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            intro = ~ . ($dbh->quote(${$cfg}{'intro'})) . qq~, 
            body = ~ . ($dbh->quote(${$cfg}{'body'})) . qq~, 
            header = ~ . ($dbh->quote(${$cfg}{'header'})) . qq~, 
            descr = ~ . ($dbh->quote(${$cfg}{'descr'})) . qq~, 
            keywords = ~ . ($dbh->quote(${$cfg}{'keywords'})) . qq~, 
            custom_title = ~ . ($dbh->quote(${$cfg}{'custom_title'})) . qq~, 
            whoedit = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~
        WHERE 
            page_id = ~ . ($dbh->quote(${$cfg}{'page_id'})) . qq~ 
                AND lang = ~ . ($dbh->quote(${$cfg}{'old_lang'})) . qq~ 
        ; 
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };

    unless (scalar $updcnt) {
        return {
            status => 'fail', 
            message => 'sql upd into pages_translations entry fail', 
        }
    }
    
    &_rest_memd_pages(${$cfg}{'page_id'});
    
    return {
        page_id => ${$cfg}{'page_id'}, 
        lang => ${$cfg}{'lang'}, 
        status => 'ok', 
        message => 'All OK', 
    };
    
} #-- page_translation_update

sub page_translation_delete ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail', 
        message => 'page_id incorrect', 
    } unless ${$cfg}{'page_id'} =~ /^\d+$/;

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 
    
    my (
        $dbh, $sth, $res, $q, 
        $delcnt, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        SELECT 
            p.page_id, p.author_id, p.member_id, 
            p.lang, 
            a_usr.role_id AS author_role_id, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}pages p 
            LEFT JOIN ${SESSION{PREFIX}}users a_usr ON a_usr.member_id=p.author_id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=p.member_id 
        WHERE p.page_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'page_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'page not exist', 
    } unless scalar $res -> {'page_id'};
    
    return {
        status => 'fail', 
        message => 'page trans lang match page real lang', 
    } if $res -> {'lang'} eq ${$cfg}{'lang'};
    
    return {
        status => 'fail', 
        message => 'page out of permissions', 
    } unless (
        #$res -> {'author_id'} == ${$cfg}{'author_id'} || 
        $SESSION{'USR'}->chk_access('pages', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'author_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'author_role_id'} == $SESSION{'USR'}->{'role_id'} 
        ) ||
        #$res -> {'member_id'} == $SESSION{'USR'}->{'member_id'} || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~ 
        DELETE 
        FROM ${SESSION{PREFIX}}pages_translations 
        WHERE 
            page_id = ~ . ($dbh->quote(${$cfg}{'page_id'})) . qq~ 
                AND lang = ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~ 
        ; 
    ~;
    eval {
        $delcnt = $dbh->do($q);
    };

    unless (scalar $delcnt) {
        return {
            status => 'fail', 
            message => 'sql del into pages_translations entry fail', 
        }
    }
    
    &_rest_memd_pages(${$cfg}{'page_id'});
    
    return {
        page_id => ${$cfg}{'page_id'}, 
        lang => ${$cfg}{'lang'}, 
        status => 'ok', 
        message => 'All OK', 
    };
    
} #-- page_translation_delete

sub content_get_short_url_groups (;$) {
    
    my $cfg = shift;
    
    $cfg = {} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    my (
        $dbh, $sth, $res, $q, 
        @sugrps, %sugrps, 
        $date_format, $where_rule, $orderby
    ) = ($SESSION{'DBH'}, );
    
    $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_mdt_fmt() );
    $where_rule = '';
    $orderby = ' ORDER BY sug.name ASC ';
    
    if ( 
        ${$cfg}{'sugrp_id'} && 
        !(ref ${$cfg}{'sugrp_id'}) && 
        ${$cfg}{'sugrp_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' AND sug.sugrp_id = ' . ($dbh->quote(${$cfg}{'sugrp_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'sugrp_ids'} && 
        ref ${$cfg}{'sugrp_ids'} && 
        scalar @{${$cfg}{'sugrp_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'sugrp_ids'}})))
    ) {
        $where_rule .= ' AND sus.sugrp_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'sugrp_id'}}))) . ') ';
    }
    
    $q = qq~
        SELECT 
            sug.sugrp_id, sug.name, 
            UNIX_TIMESTAMP(sug.ins) AS ut_ins, 
            UNIX_TIMESTAMP(sug.upd) AS ut_upd, 
            DATE_FORMAT(sug.ins, $date_format) AS ins_fmt, 
            DATE_FORMAT(sug.upd, $date_format) AS upd_fmt, 
            sug.member_id, sug.whoedit, 
            m_usr.name AS creator, m_usr.role_id AS creator_role_id, 
            e_usr.name AS editor 
        FROM ${SESSION{PREFIX}}short_url_groups sug 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=sug.member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=sug.whoedit 
        $where_rule 
        $orderby ; 
    ~;
    
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        unless (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash') {
            while ($res = $sth->fetchrow_hashref()) {
                $res->{'is_writable'} = 1 if (
                    $SESSION{'USR'}->chk_access('urls', 'manage_any', 'r') || 
                    $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                    (
                        $SESSION{'USR'}->chk_access('urls', 'manage_others', 'r') && 
                        $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                    )
                );
                push @sugrps, {%{$res}};
            }
        }
        else {
            while ($res = $sth->fetchrow_hashref()) {
                $res->{'is_writable'} = 1 if (
                    $SESSION{'USR'}->chk_access('urls', 'manage_any', 'r') || 
                    $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                    (
                        $SESSION{'USR'}->chk_access('urls', 'manage_others', 'r') && 
                        $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                    )
                );
                $sugrps{ $res -> {'sugrp_id'} } = {%{$res}};
            }
        }
        $sth -> finish();
    };
    
    return {
        q => $q, 
        sugrps => (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash')? \%sugrps:\@sugrps, 
    };
} #-- content_get_short_url_groups

sub surl_group_add ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input cfg', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail', 
        message => 'name len fail',
    } if (
        !defined(${$cfg}{'name'}) ||
        ${$cfg}{'name'} !~ /^.{1,32}$/
    ); 
    
    my (
        $dbh, $q, 
        $inscnt, $sugrp_id, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}short_url_groups (
            name,
            member_id, ins 
        ) VALUES (
            ~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            NOW() 
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };
    
    unless (scalar $inscnt) {
        return {
            status => 'fail', 
            message => 'sql ins into short_url_groups entry fail', 
        }
    }

    $q = qq~ SELECT LAST_INSERT_ID() AS lid; ~;
    eval {
        ($sugrp_id) = $dbh -> selectrow_array($q);
    };

    return {
        status => 'ok', 
        sugrp_id => $sugrp_id, 
        message => 'All ok', 
    };
    
} #-- surl_group_add

sub surl_group_edit ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input cfg', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'sugrp_id incorrect', 
    } unless ${$cfg}{'sugrp_id'} =~ /^\d+$/;
    
    return {
        status => 'fail', 
        message => 'name len fail',
    } if (
        !defined(${$cfg}{'name'}) ||
        ${$cfg}{'name'} !~ /^.{1,32}$/
    ); 
    
    my (
        $dbh, $sth, $res, $q, 
        $updcnt, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        SELECT 
            sug.sugrp_id, sug.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}short_url_groups sug
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=sug.member_id 
        WHERE sug.sugrp_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'sugrp_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'sugrp not exist', 
    } unless scalar $res -> {'sugrp_id'};
    
    return {
        status => 'fail', 
        message => 'sugrp out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('urls', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('urls', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        UPDATE
        ${SESSION{PREFIX}}short_url_groups 
        SET
            name = ~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            whoedit = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~ 
        WHERE sugrp_id = ~ . ($dbh->quote(${$cfg}{'sugrp_id'})) . qq~ ;
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };
    
    unless (scalar $updcnt) {
        return {
            status => 'fail', 
            message => 'sql upd into short_url_groups entry fail', 
        }
    }

    return {
        status => 'ok', 
        sugrp_id => ${$cfg}{'sugrp_id'}, 
        message => 'All ok', 
    };
    
} #-- surl_group_edit

sub surl_group_delete ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input cfg', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'sugrp_id incorrect', 
    } unless ${$cfg}{'sugrp_id'} =~ /^\d+$/;
    
    my (
        $dbh, $sth, $res, $q, 
        $delcnt, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        SELECT 
            sug.sugrp_id, sug.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}short_url_groups sug 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=sug.member_id 
        WHERE sug.sugrp_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'sugrp_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'sugrp not exist', 
    } unless scalar $res -> {'sugrp_id'};
    
    return {
        status => 'fail', 
        message => 'sugrp out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('urls', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('urls', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}short_urls 
        WHERE sugrp_id = ~ . ($dbh->quote(${$cfg}{'sugrp_id'})) . qq~ ;
    ~;
    eval {
        $delcnt = $dbh->do($q);
    };
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}short_url_groups 
        WHERE sugrp_id = ~ . ($dbh->quote(${$cfg}{'sugrp_id'})) . qq~ ;
    ~;
    eval {
        $delcnt = $dbh->do($q);
    };
    
    unless (scalar $delcnt) {
        return {
            status => 'fail', 
            message => 'sql del into short_url_groups entry fail', 
        }
    }

    return {
        status => 'ok', 
        sugrp_id => ${$cfg}{'sugrp_id'}, 
        message => 'All ok', 
    };
    
} #-- surl_group_delete

sub surl_url_delete ($) {
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input cfg', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'alias_id incorrect', 
    } unless ${$cfg}{'alias_id'} =~ /^\d+$/;
    
    my (
        $dbh, $sth, $res, $q, 
        $delcnt, 
        
    ) = ($SESSION{'DBH'}, );
    
    $q = qq~
        SELECT 
            su.alias_id, su.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}short_urls su 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=su.member_id 
        WHERE su.alias_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'alias_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'alias not exist', 
    } unless scalar $res -> {'alias_id'};
    
    return {
        status => 'fail', 
        message => 'alias out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('urls', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('urls', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}short_urls 
        WHERE alias_id = ~ . ($dbh->quote(${$cfg}{'alias_id'})) . qq~ ;
    ~;
    eval {
        $delcnt = $dbh->do($q);
    };
    
    unless (scalar $delcnt) {
        return {
            status => 'fail', 
            message => 'sql del into short_urls entry fail', 
        }
    }

    return {
        status => 'ok', 
        alias_id => ${$cfg}{'alias_id'}, 
        message => 'All ok', 
    };
    
} #-- surl_url_delete

sub blocks_get_access_roles () {

    my $cfg = shift; 
    
    return {
        status => 'fail', 
        message => 'block_id incorrect', 
    } unless (
        (
            ${$cfg}{'block_id'} &&
            ${$cfg}{'block_id'} =~ /^\d+$/
        ) || 
        (
            ${$cfg}{'block_ids'} && 
            ref ${$cfg}{'block_ids'} && 
            ref ${$cfg}{'block_ids'} eq 'ARRAY'
        )
    );
    
    my (
        $dbh, $sth, $res, $q, 
        %access_roles, $where_rule
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    if (
        ${$cfg}{'block_id'} &&
        ${$cfg}{'block_id'} =~ /^\d+$/
    ) {
        $where_rule .= ' AND bar.block_id = ' . ($dbh->quote(${$cfg}{'block_id'})) . ' ';
    }
    
    if (
        ${$cfg}{'block_ids'} &&
        ref ${$cfg}{'block_ids'} && 
        ref ${$cfg}{'block_ids'} eq 'ARRAY' && 
        !(scalar (grep(/\D/, @{${$cfg}{'block_ids'}})))
    ) {
        $where_rule .= ' AND bar.block_id IN (' . (join ', ', @{${$cfg}{'block_ids'}}) . ') ';
    }
    
    $where_rule =~ s/AND/WHERE/;
    
    $q = qq~
        SELECT 
             bar.block_id, bar.role_id 
        FROM ${SESSION{PREFIX}}blocks_access_roles bar
        $where_rule 
        #ORDER BY bar.page_id ASC, bar.role_id ASC 
    ~;
    eval {
        $sth = $dbh -> prepare($q);$sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            $access_roles{$res->{'block_id'}} = {} 
                unless defined $access_roles{ $res -> {'block_id'} };
            $access_roles{$res->{'block_id'}}{$res->{'role_id'}} = 1;
        }
    };
    
    return {
        q => $q, 
        access_roles => \%access_roles, 
    }
    
} #-- blocks_get_access_roles

sub blocks_add_block ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        ${$cfg}{'lang'} ne 'any_lang' &&
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    );
    ${$cfg}{'lang'} = undef if ${$cfg}{'lang'} eq 'any_lang';

    return {
        status => 'fail', 
        message => 'header len fail',
    } if (
        !${$cfg}{'header'} ||
        ${$cfg}{'header'} !~ /^.{1,64}$/
    ); 
    
    return {
        status => 'fail', 
        message => 'body len fail',
    } unless ${$cfg}{'body'}; 
    
    return {
        status => 'fail', 
        message => 'alias len fail',
    } if (
        ${$cfg}{'alias'} &&
        ${$cfg}{'alias'} !~ /^.{1,32}$/
    ); 
    
    if (${$cfg}{'is_active'}) {
        ${$cfg}{'is_active'} = 1;
    }
    else {
        ${$cfg}{'is_active'} = 0;
    }
    
    if (${$cfg}{'show_header'}) {
        ${$cfg}{'show_header'} = 1;
    }
    else {
        ${$cfg}{'show_header'} = 0;
    }
    
    if (
        scalar @{${$cfg}{'access_roles'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'access_roles'}})))
    ) {
        ${$cfg}{'use_access_roles'} = 1;
    }
    else {
        ${$cfg}{'use_access_roles'} = 0;
    }
    
    my (
        $dbh, $sth, $res, $q, 
        $inscnt, 
        $block_id, @qs, 
        
    ) = ($SESSION{'DBH'}, );
    
    if (defined ${$cfg}{'alias'}) {
        $q = qq~
            SELECT b.block_id 
            FROM ${SESSION{PREFIX}}blocks b 
            WHERE b.alias = ? ; 
        ~;
        
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'alias'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'alias taken', 
        } if scalar $res -> {'block_id'};
    }
    else {
        ${$cfg}{'alias'} = undef;
    }
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}blocks (
            lang, is_active, 
            use_access_roles,
            show_header, alias,  
            header, body, 
            member_id, 
            ins
        ) VALUES (
            ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'is_active'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'use_access_roles'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'show_header'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'alias'})) . qq~, 

            ~ . ($dbh->quote(${$cfg}{'header'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'body'})) . qq~, 

            ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            
            NOW() 
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };

    unless (scalar $inscnt) {
        return {
            status => 'fail', 
            message => 'sql ins into blocks entry fail', 
        }
    }

    $q = qq~ SELECT LAST_INSERT_ID() AS lid; ~;
    eval {
        ($block_id) = $dbh -> selectrow_array($q);
    };
    
    if (${$cfg}{'use_access_roles'}) {
            
            foreach my $r (@{${$cfg}{'access_roles'}}){
                push @qs, qq~ ( $block_id, $r, ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~, NOW()) ~;
            }
            $q = qq~
                INSERT INTO 
                ${SESSION{PREFIX}}blocks_access_roles ( 
                    block_id, role_id, whoedit, ins 
                ) 
                VALUES ~ . (join ', ', @qs) . ' ; ';
            eval {
                $inscnt = $dbh -> do($q);
            };
            return {
                status => 'ok', 
                block_id => $block_id, 
                message => 'All ok, but access roles creation failed', 
            } unless (scalar $inscnt == scalar @qs);

    }
    
    return {
        status => 'ok', 
        block_id => $block_id, 
        message => 'All ok', 
    };
    
} #-- blocks_add_block

sub blocks_edit_block ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        ${$cfg}{'lang'} ne 'any_lang' &&
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    );
    ${$cfg}{'lang'} = undef if ${$cfg}{'lang'} eq 'any_lang';

    return {
        status => 'fail', 
        message => 'header len fail',
    } if (
        !${$cfg}{'header'} ||
        ${$cfg}{'header'} !~ /^.{1,64}$/
    ); 
    
    return {
        status => 'fail', 
        message => 'body len fail',
    } unless ${$cfg}{'body'}; 
    
    return {
        status => 'fail', 
        message => 'alias len fail',
    } if (
        ${$cfg}{'alias'} &&
        ${$cfg}{'alias'} !~ /^.{1,32}$/
    ); 
    
    if (${$cfg}{'is_active'}) {
        ${$cfg}{'is_active'} = 1;
    }
    else {
        ${$cfg}{'is_active'} = 0;
    }
    
    if (${$cfg}{'show_header'}) {
        ${$cfg}{'show_header'} = 1;
    }
    else {
        ${$cfg}{'show_header'} = 0;
    }
    
    if (
        scalar @{${$cfg}{'access_roles'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'access_roles'}})))
    ) {
        ${$cfg}{'use_access_roles'} = 1;
    }
    else {
        ${$cfg}{'use_access_roles'} = 0;
    }
    
    my (
        $dbh, $sth, $res, $q, 
        $updcnt, $inscnt, 
        @qs, 
        
    ) = ($SESSION{'DBH'}, );
    

    $q = qq~
        SELECT 
            b.block_id, b.member_id, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}blocks b 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=b.member_id 
        WHERE b.block_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'block_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'block not exist', 
    } unless scalar $res -> {'block_id'};
    
    return {
        status => 'fail', 
        message => 'block out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('blocks', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    if (defined ${$cfg}{'alias'}) {
        $q = qq~
            SELECT b.block_id 
            FROM ${SESSION{PREFIX}}blocks b 
            WHERE b.alias = ? 
                AND b.block_id != ? ; 
        ~;
        
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'alias'}, ${$cfg}{'block_id'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'alias taken', 
        } if scalar $res -> {'block_id'};
    }
    else { ${$cfg}{'alias'} = undef; }

    #Make check @ transes first
    #lang = ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}blocks 
        SET
            is_active = ~ . ($dbh->quote(${$cfg}{'is_active'})) . qq~, 
            use_access_roles = ~ . ($dbh->quote(${$cfg}{'use_access_roles'})) . qq~, 
            show_header = ~ . ($dbh->quote(${$cfg}{'show_header'})) . qq~, 
            alias = ~ . ($dbh->quote(${$cfg}{'alias'})) . qq~, 
            header = ~ . ($dbh->quote(${$cfg}{'header'})) . qq~, 
            body = ~ . ($dbh->quote(${$cfg}{'body'})) . qq~, 
            whoedit = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~ 
        WHERE block_id = ~ . ($dbh->quote(${$cfg}{'block_id'})) . qq~ ; 
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };

    unless (scalar $updcnt) {
        return {
            status => 'fail', 
            message => 'sql upd into blocks entry fail', 
        }
    }
    
    $q = qq~
        DELETE 
        FROM ${SESSION{PREFIX}}blocks_access_roles 
        WHERE block_id = ~ . ($dbh->quote(${$cfg}{'block_id'})) . ' ; ';
    eval{
        $dbh->do($q);
    };
    if (${$cfg}{'use_access_roles'}) {
        if (
            scalar @{${$cfg}{'access_roles'}} && 
            !(scalar (grep(/\D/, @{${$cfg}{'access_roles'}})))
        ) {
            
            foreach my $r (@{${$cfg}{'access_roles'}}){
                push @qs, qq~ ( ~ . ($dbh->quote(${$cfg}{'block_id'})) . qq~, $r, ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~, NOW() ) ~;
            }
            $q = qq~
                INSERT INTO 
                ${SESSION{PREFIX}}blocks_access_roles ( 
                    block_id, role_id, whoedit, ins 
                ) 
                VALUES ~ . (join ', ', @qs) . ' ; ';
            eval {
                $inscnt = $dbh -> do($q);
            };
            return {
                status => 'ok', 
                block_id =>  ${$cfg}{'block_id'}, 
                message => 'All ok, but access roles creation failed', 
            } unless (scalar $inscnt == scalar @qs);
            
        }
    }
    
    return {
        status => 'ok', 
        block_id =>  ${$cfg}{'block_id'}, 
        message => 'All ok', 
    };
    
} #-- blocks_edit_block

sub blocks_delete_block ($) {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail', 
        message => 'block_id incorrect', 
    } unless ${$cfg}{'block_id'} =~ /^\d+$/;
    
    my (
        $dbh, $sth, $res, $q, 
        $delcnt, 
        
    ) = ($SESSION{'DBH'}, );

    $q = qq~
        SELECT 
            b.block_id, b.member_id, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}blocks b 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=b.member_id 
        WHERE b.block_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'block_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'block not exist', 
    } unless scalar $res -> {'block_id'};
    
    return {
        status => 'fail', 
        message => 'block out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('blocks', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('pages', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}blocks_access_roles 
        WHERE block_id = ~ . ($dbh->quote(${$cfg}{'block_id'})) . ' ; ';
    eval {
        $dbh -> do($q);
    };
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}blocks_translations
        WHERE block_id = ~ . ($dbh->quote(${$cfg}{'block_id'})) . ' ; ';
    eval {
        $dbh -> do($q);
    };
    
    $q = qq~
        DELETE FROM 
        ${SESSION{PREFIX}}blocks 
        WHERE block_id = ~ . ($dbh->quote(${$cfg}{'block_id'})) . ' ; ';
    eval {
        $dbh -> do($q);
    };
    
    return {
        status => 'ok', 
        block_id =>  ${$cfg}{'block_id'}, 
        message => 'All ok', 
    };

} #-- blocks_delete_block

sub blocks_translation_save () {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail', 
        message => 'block_id incorrect', 
    } unless ${$cfg}{'block_id'} =~ /^\d+$/;

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 

    return {
        status => 'fail', 
        message => 'header len fail',
    } if (
        !${$cfg}{'header'} ||
        ${$cfg}{'header'} !~ /^.{1,64}$/
    ); 

    return {
        status => 'fail', 
        message => 'body len fail',
    } unless ${$cfg}{'body'}; 
    
    my (
        $dbh, $sth, $res, $q, 
        $inscnt, 
        $sql_now, 
        
    ) = ($SESSION{'DBH'}, );
    
    $sql_now = &sv_datetime_sql();
    
    $q = qq~
        SELECT 
            b.block_id, b.member_id, 
            b.lang, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}blocks b 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=b.member_id 
        WHERE b.block_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'block_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'block not exist', 
    } unless scalar $res -> {'block_id'};
    
    return {
        status => 'fail', 
        message => 'block trans lang match block real lang', 
    } if $res -> {'lang'} eq ${$cfg}{'lang'};
    
    return {
        status => 'fail', 
        message => 'block out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('blocks', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('blocks', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        SELECT 
            #bt.block_id, bt.lang,  
            COUNT(*) AS cnt 
        FROM ${SESSION{PREFIX}}blocks_translations bt 
        WHERE bt.block_id = ? AND bt.lang = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'block_id'}, ${$cfg}{'lang'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'trans for that lang exists', 
    } if scalar $res -> {'cnt'};
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}blocks_translations (
            block_id, lang, 
            header, body, 
            member_id, 
            ins
        ) VALUES (
            ~ . ($dbh->quote(${$cfg}{'block_id'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            
            ~ . ($dbh->quote(${$cfg}{'header'})) . qq~,             
            ~ . ($dbh->quote(${$cfg}{'body'})) . qq~, 
            
            ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            
            ~ . ($sql_now) . qq~
            
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };

    unless (scalar $inscnt) {
        return {
            status => 'fail', 
            message => 'sql ins into blocks_translations entry fail', 
        }
    }
    
    &_rest_memd_blocks(${$cfg}{'block_id'});
    
    return {
        block_id => ${$cfg}{'block_id'}, 
        lang => ${$cfg}{'lang'}, 
        status => 'ok', 
        message => 'All OK', 
    };
    
} #-- blocks_translation_save

sub blocks_translation_edit () {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail', 
        message => 'block_id incorrect', 
    } unless ${$cfg}{'block_id'} =~ /^\d+$/;

    return {
        status => 'fail', 
        message => 'lang unknown', 
    } if (
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'})
    ); 
    
    return {
        status => 'fail', 
        message => 'old lang unknown', 
    } if (
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'old_lang'})
    ); 

    return {
        status => 'fail', 
        message => 'header len fail',
    } if (
        !${$cfg}{'header'} ||
        ${$cfg}{'header'} !~ /^.{1,64}$/
    ); 

    return {
        status => 'fail', 
        message => 'body len fail',
    } unless ${$cfg}{'body'}; 
    
    my (
        $dbh, $sth, $res, $q, 
        $updcnt, 
        $sql_now, 
        
    ) = ($SESSION{'DBH'}, );
    
    $sql_now = &sv_datetime_sql();
    
    $q = qq~
        SELECT 
            b.block_id, b.member_id, 
            b.lang, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}blocks b 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=b.member_id 
        WHERE b.block_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'block_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'block not exist', 
    } unless scalar $res -> {'block_id'};
    
    return {
        status => 'fail', 
        message => 'block trans lang match block real lang', 
    } if $res -> {'lang'} eq ${$cfg}{'lang'};
    
    return {
        status => 'fail', 
        message => 'block out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('blocks', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('blocks', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        SELECT 
            #bt.block_id, bt.lang,  
            COUNT(*) AS cnt 
        FROM ${SESSION{PREFIX}}blocks_translations bt 
        WHERE 
            bt.block_id = ? 
                AND bt.lang = ? 
                    AND bt.lang != ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'block_id'}, ${$cfg}{'lang'}, ${$cfg}{'old_lang'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'trans for that lang exists', 
    } if scalar $res -> {'cnt'};
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}blocks_translations 
        SET 
            lang = ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            
            header = ~ . ($dbh->quote(${$cfg}{'header'})) . qq~, 
            body = ~ . ($dbh->quote(${$cfg}{'body'})) . qq~, 
            
            whoedit = ~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~
        WHERE 
            block_id = ~ . ($dbh->quote(${$cfg}{'block_id'})) . qq~ 
                AND lang = ~ . ($dbh->quote(${$cfg}{'old_lang'})) . qq~ 
        ; 
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };

    unless (scalar $updcnt) {
        return {
            status => 'fail', 
            message => 'sql upd into blocks_translations entry fail', 
        }
    }
    
    &_rest_memd_blocks(${$cfg}{'block_id'});
    
    return {
        page_id => ${$cfg}{'page_id'}, 
        lang => ${$cfg}{'lang'}, 
        status => 'ok', 
        message => 'All OK', 
    };
    
} #-- blocks_translation_edit

sub blocks_translation_delete {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    return {
        status => 'fail', 
        message => 'block_id incorrect', 
    } unless ${$cfg}{'block_id'} =~ /^\d+$/;
    
    my (
        $dbh, $sth, $res, $q, 
        $delcnt, 
        $sql_now, 
        
    ) = ($SESSION{'DBH'}, );
    
    $sql_now = &sv_datetime_sql();
    
    $q = qq~
        SELECT 
            b.block_id, b.member_id, 
            m_usr.role_id AS member_role_id 
        FROM ${SESSION{PREFIX}}blocks b 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=b.member_id 
        WHERE b.block_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'block_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'block not exist', 
    } unless scalar $res -> {'block_id'};
    
    return {
        status => 'fail', 
        message => 'block out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('blocks', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('blocks', 'manage_others', 'w') && 
            $res -> {'member_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~ 
        DELETE 
        FROM ${SESSION{PREFIX}}blocks_translations 
        WHERE 
            block_id = ~ . ($dbh->quote(${$cfg}{'block_id'})) . qq~ 
                AND lang = ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~ 
        ; 
    ~;
    eval {
        $delcnt = $dbh->do($q);
    };

    unless (scalar $delcnt) {
        return {
            status => 'fail', 
            message => 'sql del into blocks_translations entry fail', 
        }
    }
    
    &_rest_memd_blocks(${$cfg}{'block_id'});
    
    return {
        block_id => ${$cfg}{'block_id'}, 
        lang => ${$cfg}{'lang'}, 
        status => 'ok', 
        message => 'All OK', 
    };
    
} #-- blocks_translation_delete

1;
