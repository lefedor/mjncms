package MjNCMS::Menus;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Bender: My dreams are over before they began! 
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

########################################################################
#                           ROUTES
########################################################################

sub menus_rt_menus_get () {
    
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('menus', 'manage')) {
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
                'menus';
        $TT_CALLS{'menus_get_list'} = \&MjNCMS::Menus::menus_get_list;
    }
    $self->render('admin/admin_index');

} #-- menus_rt_menus_get

sub menus_rt_menus_add_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('menus', 'manage')) {
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
                'menus_add';
        $TT_VARS{'parent_menu_id'} = $self -> param('parent_menu_id') if $self -> param('parent_menu_id');
        $TT_CALLS{'menus_get_record'} = \&MjNCMS::Menus::menus_get_record if $self -> param('parent_menu_id');
    }
    $self->render('admin/admin_index');

} #-- menus_rt_menus_add_get

sub menus_rt_menus_add_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('menus', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Menus::menus_mk_node({
        parent => ((scalar $SESSION{'REQ'}->param('parent_menu_id'))? (scalar $SESSION{'REQ'}->param('parent_menu_id')):0), 
        name => scalar $SESSION{'REQ'}->param('menu_text'), 
        cname => scalar $SESSION{'REQ'}->param('menu_cname'), 
        is_active => scalar $SESSION{'REQ'}->param('menu_isactive'), 
        link => scalar $SESSION{'REQ'}->param('menu_link'), 
        lang => scalar $SESSION{'REQ'}->param('menu_lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/menus' unless $url;
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
            menu_id => $res->{'menu_id'}, 
            parent_menu_id => scalar $SESSION{'REQ'}->param('parent_menu_id'), 
            menu_level => $res->{'menu_level'}, 
            seq_order => $res->{'seq_order'}, 
            
        });
    }

} #-- menus_rt_menus_add_post

sub menus_rt_menus_delete_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('menus', 'manage')) {
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
                'menus_delete';
        $TT_VARS{'rm_menu_id'} = $self -> param('rm_menu_id');
        $TT_CALLS{'menus_get_record'} = \&MjNCMS::Menus::menus_get_record;
    }
    $self->render('admin/admin_index');

} #-- menus_rt_menus_delete_get

sub menus_rt_menus_delete_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('menus', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Menus::menus_rm_node(scalar $SESSION{'REQ'}->param('rm_menu_id'));
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/menus' unless $url;
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
            menu_id => scalar $SESSION{'REQ'}->param('rm_menu_id'), 
        });
    }

} #-- menus_rt_menus_delete_post

sub menus_rt_menus_edit_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('menus', 'manage')) {
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
                'menus_edit';
        $TT_VARS{'menu_id'} = $self -> param('menu_id');
        $TT_CALLS{'menus_get_record'} = 
            \&MjNCMS::Menus::menus_get_record;
        $TT_CALLS{'menus_get_record_tree'} = 
            \&MjNCMS::Menus::menus_get_record_tree;
        $TT_CALLS{'menus_get_parent_tree'} = 
            \&MjNCMS::Menus::menus_get_parent_tree;
    }
    $self->render('admin/admin_index');

} #-- menus_rt_menus_edit_get

sub menus_rt_menus_edit_post () {
    my $self = shift;

    unless ($SESSION{'USR'}->chk_access('menus', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Menus::menus_edit_node({
        menu_id => scalar $SESSION{'REQ'}->param('menu_id'), 
        name => scalar $SESSION{'REQ'}->param('menu_text'), 
        cname => scalar $SESSION{'REQ'}->param('menu_cname'), 
        link => scalar $SESSION{'REQ'}->param('menu_link'), 
        is_active => scalar $SESSION{'REQ'}->param('menu_isactive'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/menus' unless $url;
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
            menu_id => scalar $SESSION{'REQ'}->param('menu_id'), 
            
        });
    }

} #-- menus_rt_menus_edit_post

sub menus_rt_menus_setsequence_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('menus', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my %menus_weight = &get_suffixed_params('m_ord_');
    my $res = &MjNCMS::Menus::menus_set_sequence(\%menus_weight);

    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/menus' unless $url;
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
            parent_menu_id => scalar $SESSION{'REQ'}->param('parent_menu_id'), 
            
        });
    }

} #-- menus_rt_menus_setsequence_post

sub menus_rt_menus_managetrans_get () {
    my $self = shift;

    $SESSION{'PAGE_CACHABLE'} = 1;
    unless ($SESSION{'USR'}->chk_access('menus', 'manage')) {
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
                'menus_managetrans';
        $TT_VARS{'menu_id'} = $self -> param('menu_id');
        $TT_CALLS{'menus_get_transes'} = 
            \&MjNCMS::Menus::menus_get_transes;
        $TT_CALLS{'menus_get_record'} = 
            \&MjNCMS::Menus::menus_get_record;
    }
    $self->render('admin/admin_index');

} #-- menus_rt_menus_managetrans_get

sub menus_rt_menus_addtrans_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('menus', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Menus::menus_mk_trans_record({
        menu_id => scalar $SESSION{'REQ'}->param('menu_id'), 
        name => scalar $SESSION{'REQ'}->param('menu_trans'), 
        link => scalar $SESSION{'REQ'}->param('menu_altlink'), 
        lang => scalar $SESSION{'REQ'}->param('menu_lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/menus' unless $url;
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
            menu_id => $res->{'menu_id'}, 
            
        });
    }
} #-- menus_rt_menus_addtrans_post

sub menus_rt_menus_updtrans_post () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('menus', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Menus::menus_edit_trans_record({
        menu_id => scalar $SESSION{'REQ'}->param('menu_id'), 
        name => scalar $SESSION{'REQ'}->param('menu_trans'), 
        link => scalar $SESSION{'REQ'}->param('menu_altlink'), 
        lang => scalar $SESSION{'REQ'}->param('menu_lang'), 
        old_lang => scalar $SESSION{'REQ'}->param('menu_curtrans_lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/menus' unless $url;
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
            menu_id => $res->{'menu_id'}, 
            
        });
    }
} #-- menus_rt_menus_updtrans_post

sub menus_rt_menus_deltrans_get () {
    my $self = shift;
    
    unless ($SESSION{'USR'}->chk_access('menus', 'manage', 'w')) {
        $TT_CFG{'tt_controller'} = 
            $TT_VARS{'tt_controller'} = 
                'admin';
        $TT_CFG{'tt_action'} = 
            $TT_VARS{'tt_action'} = 
                'no_access_perm';
        $self->render('admin/admin_index');
        return;
    }
    
    my $res = &MjNCMS::Menus::menus_rm_trans_record({
        menu_id => scalar $self->param('menu_id'), 
        lang => scalar $self->param('menu_lang'), 
    });
    
    my $url;
    unless ($SESSION{'REQ_ISAJAX'}) {
        if ($SESSION{'REFERER'}) {
            $url = $SESSION{'REFERER'};
        }
        elsif ($SESSION{'HTTP_REFERER'}) {
            $url = $SESSION{'HTTP_REFERER'};
        }
        $url = $SESSION{'ADM_URL'}.'/menus' unless $url;
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
            menu_id => $res->{'menu_id'}, 
            
        });
    }
} #-- menus_rt_menus_deltrans_get


########################################################################
#                           INSTERNAL SUBS
########################################################################

sub menus_get_list () {
    
    my (
        $dbh, 
        $q, $res, $sth, $date_format, 
        @menus_list, @menus_ids, 
        $in_str, %menus_trans, 
    ) = ($SESSION{'DBH'}, );
    
    $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_md_fmt() );
    
    $q = qq~
        SELECT 
            mt.id, mt.level, mt.left_key, mt.right_key, 
            md.lang, md.text, md.link, md.extra_data, 
            md.cname, md.is_active, md.member_id, md.whoedit, 
            m_usr.name AS creator, m_usr.role_id AS creator_role_id, 
            e_usr.name AS editor, 
            DATE_FORMAT(md.ins, $date_format) AS md_ins, 
            DATE_FORMAT(md.upd, $date_format) AS md_upd 
        FROM ${SESSION{PREFIX}}menus_tree mt 
            LEFT JOIN ${SESSION{PREFIX}}menus_data md ON md.menu_id=mt.id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=md.member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=md.whoedit 
        WHERE mt.level=1 #root entrys only 
        ORDER BY md.ins ASC ; 
    ~;
    
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        while ($res = $sth->fetchrow_hashref()){
            $res->{'is_writable'} = 1 if (
                $SESSION{'USR'}->chk_access('menus', 'manage_any', 'r') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('menus', 'manage_others', 'r') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                )
            );
            push @menus_list, {%{$res}};
            push @menus_ids, $res -> {'id'};
        }
        $sth -> finish(); 
    };
    
    if (scalar @menus_ids) {
        %menus_trans = %{menus_get_transes([@menus_ids], [$SESSION{'USR'}->{'member_sitelng'}])};
    }
    
    return {
        q => $q, 
        menus_list => \@menus_list, 
        menus_trans => \%menus_trans, 
        
    };
    
} #-- menus_get_list

sub menus_get_record ($) {
    
    my $menus = $_[0];
    my $extra_cfg = $_[1];
    
    $extra_cfg = {} 
        unless (
            $extra_cfg && 
            ref $extra_cfg && 
            ref $extra_cfg eq 'HASH' 
        );
    
    my (
        $dbh,
        $q, $res, $sth, $date_format, 
        $in_str, %menus, @menus, 
        @to_trans, $transes, 
        
    ) = ($SESSION{'DBH'}, );
    
    if ($menus && ref $menus && ref $menus eq 'ARRAY'){
        @menus = @{$menus};
    }
    elsif($menus && $menus =~ /^\d+$/){
        push @menus, $menus;
    }
    else{
        return undef;
    }
    
    if ( !(scalar @menus) || (scalar (grep(/\D/, @menus))) ) {
        return undef;
    }
    
    $in_str = join ', ', @menus;
    
    $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_md_fmt() );
    
    $q = qq~
        SELECT 
            mt.id, md.menu_id, mt.level, mt.left_key, mt.right_key, 
            md.lang, md.text, md.link, md.extra_data, 
            md.cname, md.is_active, md.member_id, md.whoedit, 
            m_usr.name AS creator, m_usr.role_id AS creator_role_id, 
            e_usr.name AS editor, 
            DATE_FORMAT(md.ins, $date_format) AS md_ins, 
            DATE_FORMAT(md.upd, $date_format) AS md_upd 
        FROM ${SESSION{PREFIX}}menus_tree mt 
            LEFT JOIN ${SESSION{PREFIX}}menus_data md ON md.menu_id=mt.id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=md.member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=md.whoedit 
        WHERE mt.id IN ( $in_str ) 
        ORDER BY md.ins ASC ; 
    ~;
    
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        while ($res = $sth->fetchrow_hashref()){
            
            unless ($$extra_cfg{'disable_autotranslate'}) {
                if ($res->{'lang'} ne $SESSION{'LOC'}->{'CURRLANG'}) {
                    push @to_trans, $res->{'menu_id'};
                }
            }
            
            $menus{$res->{'id'}} = {%{$res}};
            ${$menus{$res->{'id'}}}{'is_writable'} = 1 if (
                $SESSION{'USR'}->chk_access('menus', 'manage_any', 'r') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('menus', 'manage_others', 'r') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                )
            );
        }
        $sth -> finish(); 
    };
    
    if (scalar @to_trans) {
        #!disable_autotranslate thing
        $transes = menus_get_transes([@to_trans], $SESSION{'LOC'}->{'CURRLANG'});
        foreach my $m_id (keys %{$transes}) {
            ${$menus{$m_id}}{'lang'} = $SESSION{'LOC'}->{'CURRLANG'};
            ${$menus{$m_id}}{'lang_istranslated'} = 1;
            ${$menus{$m_id}}{'text'} = 
                ${${$transes}{$m_id}}{$SESSION{'LOC'}->{'CURRLANG'}}{'text'} 
                    if ${${$transes}{$m_id}}{$SESSION{'LOC'}->{'CURRLANG'}}{'text'};
            ${$menus{$m_id}}{'link'} = 
                ${$transes}{$m_id}{$SESSION{'LOC'}->{'CURRLANG'}}{'link'} 
                    if ${$transes}{$m_id}{$SESSION{'LOC'}->{'CURRLANG'}}{'link'};
        }
    }
    
    return {
        q => $q, 
        records => \%menus, 
        
    };
    
} #-- menus_get_record

sub menus_get_record_tree ($) {
    
    my $menu_id = $_[0];
    my $mode = $_[1]? $_[1]:'as_array';

    my (
        $dbh, $q, $menuNS, 
        @menu_slaves, 
        %menu_slaves, 
    ) = ($SESSION{'DBH'}, );
    
    if ($menu_id && length $menu_id && $menu_id !~ /^\d+$/){
        $q = qq~
            SELECT menu_id 
            FROM ${SESSION{PREFIX}}menus_data 
            WHERE cname = ~ . ($dbh->quote($menu_id)) . qq~ 
            LIMIT 0,1 ; 
        ~;
        ($menu_id) = $dbh -> selectrow_array($q);
    }
    
    return {
        status => 'fail', 
        message => 'menu_id wrong fmt', 
    } unless $menu_id =~ /^\d+$/;

    $menuNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'menus_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };

    eval {
        #could return not 'ARRAY'
        @menu_slaves = @{$menuNS -> get_child_id(unit => $menu_id, branch => 'all')};
    };
    
    if ($mode ne 'as_hash') {
        return \@menu_slaves;
    }
    else{
        #mk here recrusive included hash tree for future
    }
    
} #-- menus_get_record_tree

sub menus_get_parent_tree ($) {
    
    my $menu_id = $_[0];
    my $mode = $_[1]? $_[1]:'as_array';

    my (
        $menuNS, 
        @menu_parents, 
        %menu_parents, 
    );
    
    return {
        status => 'fail', 
        message => 'menu_id wrong fmt', 
    } unless $menu_id =~ /^\d+$/;

    $menuNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'menus_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };

    @menu_parents = @{$menuNS -> get_parent_id(unit => $menu_id, branch => 'all')};
    
    if ($mode ne 'as_hash') {
        return \@menu_parents;
    }
    else{
        #mk here recrusive included hash tree for future
    }
    
} #-- menus_get_parent_tree

sub menus_get_transes ($;$) {
    
    my $menus_ids = $_[0];
    my $langs_ids = $_[1];
    
    return {} unless ($menus_ids && ref $menus_ids && ref $menus_ids eq 'ARRAY');

    $langs_ids = [$langs_ids, ] if (
        $langs_ids && 
        !(ref $langs_ids) && 
        $langs_ids =~ /^\w{2,4}$/ 
    );
    
    my (
        $dbh, 
        $q, $res, $sth, $date_format, 
        $in_str, %menus_transes, 
        @langs, 
        
    ) = ($SESSION{'DBH'}, );
    
    if (scalar @{$menus_ids} && !(scalar (grep(/\D/, @{$menus_ids})))) {
        $in_str = join ', ', @{$menus_ids};
        
        $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_md_fmt() );
        
        $q = qq~
            SELECT 
                mt.menu_id AS id, mt.menu_id, mt.lang, 
                mt.text, mt.link, 
                mt.member_id, mt.whoedit, 
                m_usr.name AS creator, 
                e_usr.name AS editor, 
                DATE_FORMAT(mt.ins, $date_format) AS mt_ins, 
                DATE_FORMAT(mt.upd, $date_format) AS mt_upd 
            FROM ${SESSION{PREFIX}}menus_trans mt 
                LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=mt.member_id 
                LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=mt.whoedit 
            WHERE mt.menu_id IN ( $in_str )  
        ~;
        if ($langs_ids && ref $langs_ids && ref $langs_ids eq 'ARRAY' && scalar @{$langs_ids}) {
            foreach my $lang (@{$langs_ids}) {
                next unless ($lang && length($lang));
                $lang = $dbh -> quote($lang);
                push @langs, $lang;
            }
            if (scalar @langs) {
                $in_str = join ', ', @langs;
                $q .= qq~
                    AND mt.lang IN ( $in_str ) 
                ~;
            }
        }
        $q .= ' ; ';
        eval {
          $sth = $dbh -> prepare($q);$sth -> execute();
          while ($res = $sth->fetchrow_hashref()){
              $menus_transes{$res->{'menu_id'}} = {} unless defined($menus_transes{$res->{'menu_id'}});
              $menus_transes{$res->{'menu_id'}}{$res->{'lang'}} = {%{$res}};
          }
          $sth -> finish();
        };
    }
    
    return \%menus_transes;
    
} #-- menus_get_transes

sub menus_mk_node ($) {
    
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
    
    if(${$cfg}{'is_active'}){
        ${$cfg}{'is_active'} = 1;
    }
    else{
        ${$cfg}{'is_active'} = 0;
    }
    
    my (
        $dbh, $sth, $res, $q, 
        $menuNS, $menu_id, $inscnt, 
        $sql_now, @parent_menu_slaves, 
        
    ) = ($SESSION{'DBH'}, );
    
    $sql_now = &sv_datetime_sql();
    
    if(${$cfg}{'cname'}){
        $q = qq~
            SELECT md.menu_id 
            FROM ${SESSION{PREFIX}}menus_data md 
            WHERE md.cname = ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cname'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'cname exist', 
        } if scalar $res -> {'menu_id'};
    }
    
    if(${$cfg}{'parent'}){
        $q = qq~
            SELECT 
                md.menu_id, md.member_id, md.lang, 
                m_usr.role_id AS creator_role_id 
            FROM ${SESSION{PREFIX}}menus_data md 
                LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=md.member_id 
            WHERE md.menu_id = ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'parent'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'parent not exist', 
        } unless scalar $res -> {'menu_id'};
        
        return {
            status => 'fail', 
            message => 'parent out of permissions', 
        } unless (
            $SESSION{'USR'}->chk_access('menus', 'manage_any', 'w') || 
            $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
            (
                $SESSION{'USR'}->chk_access('menus', 'manage_others', 'w') && 
                $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
            )
        );
        
        ${$cfg}{'lang'} = $res -> {'lang'};
    }
    
    $menuNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'menus_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };
    $menu_id = $menuNS->insert_unit(
        under => ${$cfg}{'parent'}, 
        order => 'B', 
    );
    
    return {
        status => 'fail', 
        message => 'error creating NS entry', 
    } unless scalar $menu_id;
    
    ${$cfg}{'link'} = '' unless ${$cfg}{'link'};
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}menus_data (
            menu_id, lang, text, link, 
            is_active, cname, member_id, ins
        ) VALUES (
            $menu_id, 
            ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'link'})) . qq~, 
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
        $menuNS->delete_unit($menu_id);
        return {
            status => 'fail', 
            message => 'sql ins menus_data entry fail', 
        }
    }

    @parent_menu_slaves = @{$menuNS -> get_child_id(unit => ${$cfg}{'parent'})};

    return {
        status => 'ok', 
        seq_order => (scalar @parent_menu_slaves), 
        menu_level => ($menuNS -> {'unit'} -> {'level'}+1), 
        menu_id => $menu_id, 
        message => 'All ok', 
    };
    
} #-- menus_mk_node

sub menus_edit_node ($) {
    
    my $cfg = shift;

    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'menu_id should be in digits', 
    } unless ${$cfg}{'menu_id'} =~ /^\d+$/;
    
    return {
        status => 'fail', 
        message => 'name len fail',
    } unless ${$cfg}{'name'} =~ /^.{1,32}$/; 

    if(${$cfg}{'is_active'}){
        ${$cfg}{'is_active'} = 1;
    }
    else{
        ${$cfg}{'is_active'} = 0;
    }
    
    my (
        $dbh, $sth, $res, $q, 
        $updcnt, $sql_now, 
    ) = ($SESSION{'DBH'}, );
    
    $sql_now = &sv_datetime_sql();  
    
    $q = qq~
        SELECT 
            md.menu_id, md.member_id, 
            m_usr.role_id AS creator_role_id, 
            mt.level AS lvl
        FROM ${SESSION{PREFIX}}menus_data md 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=md.member_id 
            LEFT JOIN ${SESSION{PREFIX}}menus_tree mt ON mt.id=md.menu_id 
        WHERE md.menu_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'menu_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'menu_id not exist', 
    } unless scalar $res -> {'menu_id'};
    
    return {
        status => 'fail', 
        message => 'menu writing out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('menus', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('menus', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );

    return {
        status => 'fail', 
        message => 'cname len fail',
    } if (
        (scalar $res -> {'lvl'}) == 1 &&
        ${$cfg}{'cname'} !~ /^.{1,16}$/
    ); 
    
    if(${$cfg}{'cname'}){
        $q = qq~
            SELECT md.menu_id 
            FROM ${SESSION{PREFIX}}menus_data md 
            WHERE md.cname = ? 
                AND md.menu_id != ? ; 
        ~;
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'cname'}, ${$cfg}{'menu_id'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        return {
            status => 'fail', 
            message => 'cname exist', 
        } if scalar $res -> {'menu_id'};
    }
    
    ${$cfg}{'link'} = '' unless ${$cfg}{'link'};
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}menus_data 
        SET 
            text=~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            cname=~ . ($dbh->quote(${$cfg}{'cname'})) . qq~, 
            link=~ . ($dbh->quote(${$cfg}{'link'})) . qq~, 
            is_active=~ . ($dbh->quote(${$cfg}{'is_active'})) . qq~, 
            whoedit=~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~
        WHERE menu_id = ~ . ($dbh->quote(${$cfg}{'menu_id'})) . qq~ ; 
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };
    
    unless (scalar $updcnt) {
        return {
            status => 'fail', 
            message => 'sql upd menus_data entry fail', 
        }
    }
    
    return {
        status => 'ok', 
        menu_id => ${$cfg}{'menu_id'}, 
        message => 'All ok', 
    };
    
} #-- menus_edit_node

sub menus_rm_node ($) {
    
    my $menus = $_[0];
    
    my (
        $dbh, $menuNS, 
        @menus, @writable_menus, @menu_slaves, 
        $q, $res, $sth, 
        $in_str, 
    ) = ($SESSION{'DBH'}, );
    
    if ($menus && ref $menus && ref $menus eq 'ARRAY'){
        @menus = @{$menus};
    }
    elsif($menus && $menus =~ /^\d+$/){
        push @menus, $menus;
    }
    else{
        return {
            status => 'fail', 
            message => 'input data fmt unknown', 
        }
    }
    
    if ( !(scalar @menus) || (scalar (grep(/\D/, @menus))) ) {
        return {
            status => 'fail', 
            message => 'input data fmt wrong', 
        }
    }
    
    $in_str = join ', ', @menus;
    
    $q = qq~
        SELECT 
            md.menu_id, md.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}menus_data md 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=md.member_id 
        WHERE md.menu_id IN ( $in_str ) ; 
    ~;
    eval {
      $sth = $dbh -> prepare($q);$sth -> execute();
      while ($res = $sth->fetchrow_hashref()){
          push @writable_menus, $res -> {'menu_id'} if (
            $SESSION{'USR'}->chk_access('menus', 'manage_any', 'w') || 
            $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
            (
                $SESSION{'USR'}->chk_access('menus', 'manage_others', 'w') && 
                $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
            )
        );
      }
      $sth -> finish();
    };

    return {
        status => 'fail', 
        message => 'all or some of requested menus !writable or !exist', 
    } unless ((scalar @menus) == (scalar @writable_menus));
    
    $menuNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'menus_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };

    foreach my $menu_id (@menus) {
        @menu_slaves = @{$menuNS -> get_child_id(unit => $menu_id, branch => 'all')};
        if ( $menuNS -> delete_unit($menu_id) ) {
            push @menu_slaves, $menu_id;
            
            $in_str = join ', ', @menu_slaves;

            $q = qq~
                DELETE 
                FROM ${SESSION{PREFIX}}menus_trans 
                WHERE menu_id IN ( $in_str ) ; 
            ~; 
            eval {
                $dbh -> do($q);
            };

            $q = qq~
                DELETE 
                FROM ${SESSION{PREFIX}}menus_data 
                WHERE menu_id IN ( $in_str ) ; 
            ~; 
            eval {
                $dbh -> do($q);
            };
            
        }
        else {
            return {
                status => 'fail', 
                message => 'Some of menu tree unit delition failed', 
            }
        }
        
    }
            
    return {
        status => 'ok', 
        message => 'All ok. Menu(s) deleted succesfully', 
    }
    
} #-- menus_rm_node

sub menus_set_sequence ($) {
    
    my %menus_weight = %{$_[0]};
    
    my (
        $dbh, 
        $q, $res, $sth, 
        $in_str, %menus_struct, 
        $records_cnt, $menuNS, 
    ) = ($SESSION{'DBH'}, );
    
    if ( !(scalar keys %menus_weight) || (scalar (grep(/\D/, keys %menus_weight))) ) {
        return {
            status => 'fail', 
            message => 'Some of menu ids not digital or no menus', 
        }
    }
    
    $in_str = join ', ', keys %menus_weight;
    
    $dbh -> do(qq~
        LOCK TABLES 
            ${SESSION{PREFIX}}menus_tree AS m WRITE, 
            ${SESSION{PREFIX}}menus_tree AS mp WRITE, 
            ${SESSION{PREFIX}}menus_data AS md READ, 
            ${SESSION{PREFIX}}users AS m_usr READ ; 
    ~);
    
    $q = qq~
        SELECT 
            m.id, m.level, md.member_id, mp.id AS pid, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}menus_tree m 
            LEFT JOIN ${SESSION{PREFIX}}menus_data md 
                ON md.menu_id=m.id 
            LEFT JOIN ${SESSION{PREFIX}}menus_tree mp 
                ON (
                    mp.level=( m.level - 1 ) 
                    AND 
                        mp.left_key<m.left_key 
                    AND 
                        mp.right_key>m.right_key 
                )
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=md.member_id 
        WHERE m.id IN ( $in_str ) AND m.level != 1 
        ORDER BY m.left_key ; 
    ~;
    
    $records_cnt = 0;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        while ($res = $sth->fetchrow_hashref()){
            
            next unless (
                $SESSION{'USR'}->chk_access('menus', 'manage_any', 'w') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('menus', 'manage_others', 'w') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                )
            );
            
            $menus_struct{$res -> {'level'}} = {} 
                unless defined $menus_struct{$res -> {'level'}};
            
            $menus_struct{$res -> {'level'}}{$res -> {'pid'}} = []
                unless defined 
                    $menus_struct{$res -> {'level'}}{$res -> {'pid'}};
                    
            push 
                @{$menus_struct{$res -> {'level'}}{$res -> {'pid'}}}, 
                    $res -> {'id'}; 
                    
            $records_cnt++;
        }
        $sth -> finish(); 
    };
    
    $dbh -> do("UNLOCK TABLES ; ");
    
    return {
        status => 'fail', 
        message => 'count chk fail some of menus not found or @lvl one or not writable', 
    } unless $records_cnt == (scalar keys %menus_weight);
    
    $menuNS = new MjNCMS::NS {
        table => $SESSION{'PREFIX'}.'menus_tree', 
        id => 'id', 
        type => 'N', 
        DBI => $SESSION{'DBH'}, 
    };
    
    foreach my $lvl (
        sort {
            $menus_struct{$a} > $menus_struct{$b} #backwards from deepest level
        } keys %menus_struct) {
            
        foreach my $pid (keys %{$menus_struct{$lvl}}) {
            foreach my $id (
                sort {
                    $menus_weight{$a} < $menus_weight{$b} #backwards move to front
                } @{${$menus_struct{$lvl}}{$pid}}
            ) {
                return {
                    status => 'fail', 
                    message => 'unit move failed for some reasons', 
                } unless (
                    $menuNS -> set_unit_under(
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
        message => 'All ok. Menu(s) resorted', 
    };
    
} #-- menus_set_sequence

sub menus_mk_trans_record ($) {
    
    my $cfg = shift;

    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'menu_id is not \d+', 
    } unless ${$cfg}{'menu_id'} =~ /^\d+$/;
    
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
            md.menu_id, md.member_id, md.lang, 
            m_usr.role_id AS creator_role_id
        FROM ${SESSION{PREFIX}}menus_data md 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=md.member_id 
        WHERE md.menu_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'menu_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'menu_id not exist', 
    } unless scalar $res -> {'menu_id'};
    
    return {
        status => 'fail', 
        message => 'that lang is menu default', 
    } if $res -> {'lang'} eq ${$cfg}{'lang'};
    
    return {
        status => 'fail', 
        message => 'menu writing out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('menus', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('menus', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        SELECT 
            #mt.menu_id, mt.lang 
            COUNT(*) AS cnt 
        FROM ${SESSION{PREFIX}}menus_trans mt 
        WHERE mt.menu_id = ? AND mt.lang = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'menu_id'}, ${$cfg}{'lang'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'trans for that lang exists', 
    } if scalar $res -> {'cnt'};
    
    $sql_now = &sv_datetime_sql();
    ${$cfg}{'link'} = '' unless ${$cfg}{'link'};
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}menus_trans (
            menu_id, lang, text, link, 
            member_id, ins
        ) VALUES (
            ~ . ($dbh->quote(${$cfg}{'menu_id'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'link'})) . qq~, 
            ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            ~ . ($sql_now) . qq~
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };
    
    return {
        status => 'fail', 
        message => 'sql ins menus_trans entry fail', 
    } unless scalar $inscnt;

    return {
        status => 'ok', 
        menu_id => ${$cfg}{'menu_id'}, 
        message => 'All ok', 
    };
    
} #-- menus_mk_trans_record

sub menus_edit_trans_record ($) {
    
    my $cfg = shift;

    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'menu_id is not \d+', 
    } unless ${$cfg}{'menu_id'} =~ /^\d+$/;
    
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
        message => 'old_lang unknown', 
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
            md.menu_id, md.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}menus_data md 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=md.member_id 
        WHERE md.menu_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'menu_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'menu_id not exist', 
    } unless scalar $res -> {'menu_id'};
    
    return {
        status => 'fail', 
        message => 'menu writing out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('menus', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('menus', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        SELECT 
            #mt.menu_id, mt.lang 
            COUNT(*) AS cnt 
        FROM ${SESSION{PREFIX}}menus_trans mt 
        WHERE 
            AND mt.lang != ?
            AND mt.menu_id = ? 
                AND mt.lang = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'old_lang'}, ${$cfg}{'menu_id'}, ${$cfg}{'lang'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'trans for that lang exists', 
    } if scalar $res -> {'cnt'};
    
    ${$cfg}{'link'} = '' unless ${$cfg}{'link'};
    
    $q = qq~
        UPDATE 
        ${SESSION{PREFIX}}menus_trans 
        SET 
            text=~ . ($dbh->quote(${$cfg}{'name'})) . qq~, 
            link=~ . ($dbh->quote(${$cfg}{'link'})) . qq~, 
            lang=~ . ($dbh->quote(${$cfg}{'lang'})) . qq~, 
            whoedit=~ . ($dbh->quote($SESSION{'USR'}->{'member_id_real'})) . qq~
        WHERE 
            menu_id = ~ . ($dbh->quote(${$cfg}{'menu_id'})) . qq~  
            AND lang = ~ . ($dbh->quote(${$cfg}{'old_lang'})) . qq~ ; 
    ~;
    eval {
        $updcnt = $dbh->do($q);
    };
    
    return {
        status => 'fail', 
        message => 'sql upd menus_trans entry fail', 
    } unless scalar $updcnt;

    return {
        status => 'ok', 
        menu_id => ${$cfg}{'menu_id'}, 
        message => 'All ok', 
    };

} #-- menus_edit_trans_record

sub menus_rm_trans_record ($) {
    
    my $cfg = shift;

    return {
            status => 'fail', 
            message => 'no input data', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    return {
        status => 'fail', 
        message => 'menu_id is not \d+', 
    } unless ${$cfg}{'menu_id'} =~ /^\d+$/;

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
            md.menu_id, md.member_id, 
            m_usr.role_id AS creator_role_id 
        FROM ${SESSION{PREFIX}}menus_data md 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=md.member_id 
        WHERE md.menu_id = ? ; 
    ~;
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'menu_id'});
        $res = $sth->fetchrow_hashref();
        $sth -> finish();
    };
    return {
        status => 'fail', 
        message => 'menu_id not exist', 
    } unless scalar $res -> {'menu_id'};
    
    return {
        status => 'fail', 
        message => 'menu writing out of permissions', 
    } unless (
        $SESSION{'USR'}->chk_access('menus', 'manage_any', 'w') || 
        $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
        (
            $SESSION{'USR'}->chk_access('menus', 'manage_others', 'w') && 
            $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
        )
    );
    
    $q = qq~
        DELETE 
        FROM ${SESSION{PREFIX}}menus_trans 
        WHERE menu_id = ~ . ($dbh->quote(${$cfg}{'menu_id'})) . qq~ 
            AND lang = ~ . ($dbh->quote(${$cfg}{'lang'})) . qq~ 
        LIMIT 1 ; 
    ~;
    eval {
        $delcnt = $dbh->do($q);
    };
    
    return {
        status => 'fail', 
        message => 'sql del menus_trans entry fail', 
    } unless scalar $delcnt;

    return {
        status => 'ok', 
        menu_id => ${$cfg}{'menu_id'}, 
        message => 'All ok', 
    };
    
} #-- menus_rm_trans_record

1;
