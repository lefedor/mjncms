package MjNCMS::ContentPagesSiteLibRead;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Common library with page functions 
# used only on content-side, READ part 
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

BEGIN {
    use Exporter ();
    use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS /;
    @ISA         = qw/Exporter /;
    @EXPORT      = qw/ /;
    @EXPORT_OK   = qw/ /;
    
    %EXPORT_TAGS = (
      vars => [qw/ /],
      subs => [qw/
       
       pages_get_transes 
       pages_get_access_roles
       content_get_pagerecord 
       
    /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
    
}


########################################################################
#                     Functions to read pages data
########################################################################


sub pages_get_transes ($) {

    my $cfg = shift; 
    
    return {
        status => 'fail', 
        message => 'page_id incorrect', 
    } unless (
        (
            ${$cfg}{'page_id'} &&
            ${$cfg}{'page_id'} =~ /^\d+$/
        ) || 
        (
            ${$cfg}{'page_ids'} && 
            ref ${$cfg}{'page_ids'} && 
            ref ${$cfg}{'page_ids'} eq 'ARRAY'
        )
    );
    
    my (
        $dbh, $sth, $res, $q, 
        %transes, $where_rule, 
        $date_format, 
        
    ) = ($SESSION{'DBH'}, );
    
    $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_mdt_fmt() );
    
    $where_rule = '';
    if (
        ${$cfg}{'page_id'} &&
        ${$cfg}{'page_id'} =~ /^\d+$/
    ) {
        $where_rule .= ' AND pt.page_id = ' . ($dbh->quote(${$cfg}{'page_id'})) . ' ';
    }
    
    if (
        ${$cfg}{'page_ids'} &&
        ref ${$cfg}{'page_ids'} && 
        ref ${$cfg}{'page_ids'} eq 'ARRAY' && 
        !(scalar (grep(/\D/, @{${$cfg}{'page_ids'}})))
    ) {
        $where_rule .= ' AND pt.page_id IN (' . (join ', ', @{${$cfg}{'page_ids'}}) . ') ';
    }
    
    if (
        ${$cfg}{'lang'} &&
        ${$cfg}{'lang'} =~ /^\w{2,4}$/
    ) {
        $where_rule .= ' AND pt.lang = ' . ($dbh->quote(${$cfg}{'lang'})) . ' ';
    }
    elsif (
        ${$cfg}{'lang'} && 
        ref ${$cfg}{'lang'} && 
        ref ${$cfg}{'lang'} eq 'ARRAY' 
    ) {
        $where_rule .= ' AND pt.lang IN (' . (join ', ', (map( $dbh->quote($_), @{${$cfg}{'lang'}}))) . ') ';
    }
    
    $where_rule =~ s/AND/WHERE/;
    
    $q = qq~
        SELECT 
            pt.page_id, pt.lang, 
            pt.intro, pt.body, pt.header, 
            pt.descr, pt.keywords, pt.custom_title,
            #do i need this?
            m_usr.name AS creator, 
            e_usr.name AS editor, 
            DATE_FORMAT(pt.ins, $date_format) AS pt_ins, 
            DATE_FORMAT(pt.upd, $date_format) AS pt_upd 
        FROM ${SESSION{PREFIX}}pages_translations pt 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=pt.member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=pt.whoedit 
        $where_rule 
        #ORDER BY pt.page_id ASC, pt.lang ASC 
    ~;
    eval {
        $sth = $dbh -> prepare($q);$sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            $transes{$res->{'page_id'}} = {} 
                unless defined $transes{ $res -> {'page_id'} };
            $transes{$res->{'page_id'}}{$res->{'lang'}} = {%{$res}};
        }
    };
    
    return {
        q => $q, 
        transes => \%transes, 
    }
} #-- pages_get_transes

sub pages_get_access_roles ($) {

    my $cfg = shift; 
    
    return {
        status => 'fail', 
        message => 'page_id incorrect', 
    } unless (
        (
            ${$cfg}{'page_id'} &&
            ${$cfg}{'page_id'} =~ /^\d+$/
        ) || 
        (
            ${$cfg}{'page_ids'} && 
            ref ${$cfg}{'page_ids'} && 
            ref ${$cfg}{'page_ids'} eq 'ARRAY'
        )
    );
    
    my (
        $dbh, $sth, $res, $q, 
        %access_roles, $where_rule
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    if (
        ${$cfg}{'page_id'} &&
        ${$cfg}{'page_id'} =~ /^\d+$/
    ) {
        $where_rule .= ' AND par.page_id = ' . ($dbh->quote(${$cfg}{'page_id'})) . ' ';
    }
    
    if (
        ${$cfg}{'page_ids'} &&
        ref ${$cfg}{'page_ids'} && 
        ref ${$cfg}{'page_ids'} eq 'ARRAY' && 
        !(scalar (grep(/\D/, @{${$cfg}{'page_ids'}})))
    ) {
        $where_rule .= ' AND par.page_id IN (' . (join ', ', @{${$cfg}{'page_ids'}}) . ') ';
    }
    
    $where_rule =~ s/AND/WHERE/;
    
    $q = qq~
        SELECT 
            par.page_id, par.role_id
        FROM ${SESSION{PREFIX}}pages_access_roles par
        $where_rule 
        #ORDER BY par.page_id ASC, par.role_id ASC 
    ~;
    eval {
        $sth = $dbh -> prepare($q);$sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            $access_roles{$res->{'page_id'}} = {} 
                unless defined $access_roles{ $res -> {'page_id'} };
            $access_roles{$res->{'page_id'}}{$res->{'role_id'}} = 1;
        }
    };
    
    return {
        q => $q, 
        access_roles => \%access_roles, 
    }
    
} #-- pages_get_access_roles

sub content_get_pagerecord ($) {
    
    #
    # Female-Mutant: Nice try Leela, but we're all saw Zapp
    #   Brannigan's webpage!
    #
    
    my $cfg = shift;
    
    $cfg = {} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    my (
        $dbh, $sth, $res, $q, 
        $dt_tmp, $date_format, 
        @pages_res, %pages_res, 
        @pages_ids, $pages_res,
        %access_roles, 
        
        $page, $items_pp, $start, $end, $limit, 
        
        $where_rule, $orderby, 
        
        $pages_transes, $pages_access_roles, 
        
        $foundrows, %pages, 
        
        %to_trans, $transes, $trans_lang, 
        $page_res_tmp, 
        
        @page_pieces, @page_pieces_tmp, 
        
    ) = ($SESSION{'DBH'}, );
    
    $$cfg{'page_page_num'} = 1 
        unless (
            $$cfg{'page_page_num'} && 
            $$cfg{'page_page_num'} =~ /^\d+$/
        );
    $$cfg{'page_page_num'} = $$cfg{'page_page_num'} - 1;
    
    $where_rule = '';
    if ( 
        ${$cfg}{'page_id'} && 
        !(ref ${$cfg}{'page_id'}) && 
        ${$cfg}{'page_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' AND p.page_id = ' . ($dbh->quote(${$cfg}{'page_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'page_ids'} && 
        ref ${$cfg}{'page_ids'} && 
        scalar @{${$cfg}{'page_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'page_ids'}})))
    ) {
        $where_rule .= ' AND p.page_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'page_ids'}}))) . ') ';
    }
    
    if ( 
        ${$cfg}{'cat_id'} && 
        !(ref ${$cfg}{'cat_id'}) && 
        ${$cfg}{'cat_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' AND p.cat_id = ' . ($dbh->quote(${$cfg}{'cat_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'cat_ids'} && 
        ref ${$cfg}{'cat_ids'} && 
        scalar @{${$cfg}{'cat_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'cat_ids'}})))
    ) {
        $where_rule .= ' AND p.cat_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'cat_ids'}}))) . ') ';
    }
    
    if (${$cfg}{'name'} && length ${$cfg}{'name'}) {
        ${$cfg}{'name'} = $dbh->quote(${$cfg}{'name'});
        ${$cfg}{'name'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND p.header LIKE \'' . ${$cfg}{'name'} . '\' ';
    }
    
    if (${$cfg}{'slug'} && length ${$cfg}{'slug'}) {
        ${$cfg}{'slug'} = $dbh->quote(${$cfg}{'slug'});
        $where_rule .= ' AND p.slug = ' . ${$cfg}{'slug'} . ' ';
    }
    
    if (${$cfg}{'slug_like'} && length ${$cfg}{'slug_like'}) {
        ${$cfg}{'slug_like'} = $dbh->quote(${$cfg}{'slug_like'});
        ${$cfg}{'slug_like'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND p.slug LIKE \'' . ${$cfg}{'slug_like'} . '\' ';
    }
    
    if (
        ${$cfg}{'lang'} && 
        length ${$cfg}{'lang'} && 
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'}) 
    ) {
        $where_rule .= ' AND p.lang = ' . ($dbh->quote(${$cfg}{'lang'})) . ' ';
    }

    if ( 
        ${$cfg}{'author_id'} && 
        ${$cfg}{'author_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' AND p.author_id = ' . ($dbh->quote(${$cfg}{'author_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'is_published'} && 
        ${$cfg}{'is_published'} =~ /^(yes|no)$/i 
    ) {
        $where_rule .= ' AND p.is_published = ' . (((lc ${$cfg}{'is_published'}) eq 'yes')? '1':'0') . ' ';
    }
    
    if ( 
        ${$cfg}{'from_dd'} && 
        ${$cfg}{'from_dd'} =~ /^\d+$/ && 
        ${$cfg}{'from_mm'} && 
        ${$cfg}{'from_mm'} =~ /^\d+$/ && 
        ${$cfg}{'from_yyyy'} && 
        ${$cfg}{'from_yyyy'} =~ /^\d+$/ 
    ) {
        $dt_tmp = $SESSION{'DATE'}->fparse_d_m_y(${$cfg}{'from_dd'}, ${$cfg}{'from_mm'}, ${$cfg}{'from_yyyy'});
        $dt_tmp = $SESSION{'DATE'}->date_sql($dt_tmp);
        $where_rule .= ' AND p.ins >= ' . $dt_tmp . ' ';
    }
    
    if ( 
        ${$cfg}{'to_dd'} && 
        ${$cfg}{'to_dd'} =~ /^\d+$/ && 
        ${$cfg}{'to_mm'} && 
        ${$cfg}{'to_mm'} =~ /^\d+$/ && 
        ${$cfg}{'to_yyyy'} && 
        ${$cfg}{'to_yyyy'} =~ /^\d+$/ 
    ) {
        $dt_tmp = $SESSION{'DATE'}->fparse_d_m_y(${$cfg}{'to_dd'}, ${$cfg}{'to_mm'}, ${$cfg}{'to_yyyy'});
        $dt_tmp += 60*60*24;#include last day (?)
        $dt_tmp = $SESSION{'DATE'}->date_sql($dt_tmp);
        $where_rule .= ' AND p.ins <= ' . $dt_tmp . ' ';
    }
    
    $limit = '';
    unless (${$cfg}{'get_all_records'}) {
        $page = ${$cfg}{'page'} || 1;
        $page = 1 unless $page =~ m/^\d+$/;

        $items_pp = ${$cfg}{'items_pp'} || $SESSION{'PAGER_ITEMSPERPAGE'} || 25;
        $items_pp = $SESSION{'PAGER_ITEMSPERPAGE'} unless $items_pp =~ m/^\d+$/;
        $start = ($page - 1 ) * $items_pp;
        $end = $items_pp || 0;
        $limit = "LIMIT $start, $end" if $end;
    }
    
    $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_mdt_fmt() );
    
    $q = qq~
        SELECT SQL_CALC_FOUND_ROWS 
            p.page_id AS id, p.page_id, 
            p.is_published, p.cat_id, p.lang, p.slug, 
            p.intro, p.body, p.header, p.descr, p.keywords, 
            p.showintro, p.use_customtitle, p.custom_title, 
            p.allow_comments, p.comments_mode, 
            p.use_password, p.password, 
            p.use_access_roles, 
            p.comments_count, 
            p.author_id, 
            p.member_id, 
            p.whoedit,
            UNIX_TIMESTAMP(p.ins) AS ut_ins, 
            UNIX_TIMESTAMP(p.upd) AS ut_upd, 
            UNIX_TIMESTAMP(p.dt_created) AS ut_dt_created, 
            UNIX_TIMESTAMP(p.dt_publishstart) AS ut_dt_publishstart, 
            UNIX_TIMESTAMP(p.dt_publishend) AS ut_dt_publishend, 
            DATE_FORMAT(p.ins, $date_format) AS ins_fmt, 
            DATE_FORMAT(p.upd, $date_format) AS upd_fmt, 
            DATE_FORMAT(p.dt_created, $date_format) AS dt_created_fmt, 
            IF (p.dt_publishstart, 
                DATE_FORMAT(p.dt_publishstart, $date_format), NULL ) AS dt_publishstart_fmt, 
            IF (p.dt_publishend, 
                DATE_FORMAT(p.dt_publishend, $date_format), NULL )  AS dt_publishend_fmt, 
            
            cd.name AS cat_name, 
            cd.cname AS cat_cname, 
            a_usr.name AS author, a_usr.role_id AS author_role_id, 
            m_usr.name AS creator, m_usr.role_id AS creator_role_id, 
            e_usr.name AS editor
            
        FROM ${SESSION{PREFIX}}pages p 
            LEFT JOIN ${SESSION{PREFIX}}cats_data cd ON cd.cat_id=p.cat_id 
            LEFT JOIN ${SESSION{PREFIX}}users a_usr ON a_usr.member_id=p.author_id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=p.member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=p.whoedit ~;
    
    unless (${$cfg}{'skip_access_roles_rule'}) {
        $q .= qq~ LEFT JOIN ${SESSION{PREFIX}}pages_access_roles par 
            ON (
                p.use_access_roles = 1
                AND 
                    par.page_id=p.page_id
                AND 
                    par.role_id=~ . ($dbh->quote($SESSION{'USR'}->{'role_id'})) . qq~
            ) ~;
        $where_rule .= qq~ AND (
            p.use_access_roles != 1
            OR par.page_id IS NOT NULL) ~;
    }
    
    
    
    $where_rule =~ s/AND/WHERE/;
            
    $q .= qq~ $where_rule 
    ~;
    
    $orderby = ' ORDER BY p.ins DESC ';
    if (
        ${$cfg}{'order'} && 
        length ${$cfg}{'order'} && 
        &inarray([
            'id', 'header', 
            'lang', 'ins', 'dt_publishstart_fmt', 
            'dt_publishend', 'is_published', 
            'slug', 'custom_title' ], ${$cfg}{'order'})
    ) {
        $orderby = ' ORDER BY p.' . ${$cfg}{'order'} . ' ';
        if (
            ${$cfg}{'ord_direction'} && 
            uc(${$cfg}{'ord_direction'}) =~ /^(ASC|DESC)$/
        ) {
            $orderby .= ' ' . ((${$cfg}{'ord_direction'} eq 'DESC')? 'DESC':'ASC') . ' ';
        }
    }
    
    $q .= " $orderby ";
    $q .= " $limit ";
    $q .= ' ; ';
    
    $trans_lang = ((${$cfg}{'lang'})? ${$cfg}{'lang'}:$SESSION{'LOC'}->{'CURRLANG'});
    
    eval {
      $sth = $dbh -> prepare($q);$sth -> execute();
      unless (${$cfg}{'res_ashash'}) {
          while ($res = $sth->fetchrow_hashref()) {
              
            unless ($$cfg{'disable_autotranslate'}) {
                if ($res->{'lang'} ne $trans_lang) {
                    $to_trans{$res->{'page_id'}} = scalar @pages_res;
                }
            }
            
            if (
                !$$cfg{'skip_pagination'} && 
                $SESSION{'PAGE_PAGER_SPLITTER'} && 
                ref $SESSION{'PAGE_PAGER_SPLITTER'} eq 'ARRAY' && 
                scalar @{$SESSION{'PAGE_PAGER_SPLITTER'}}
            ) {
                @page_pieces = ($res -> {'body'}, );
                foreach my $splitter (@{$SESSION{'PAGE_PAGER_SPLITTER'}}) {
                    @page_pieces_tmp = ();
                    foreach my $piece (@page_pieces) {
                         push @page_pieces_tmp, split $splitter, $piece;
                    }
                    @page_pieces = @page_pieces_tmp;
                }
                $res -> {'page_pages_size'} = scalar @page_pieces;
                
                #If page not exist - show first one
                $$cfg{'page_page_num'} = 0 
                    if $$cfg{'page_page_num'} >= $res -> {'page_pages_size'};
                
                $res -> {'body'} = $page_pieces[$$cfg{'page_page_num'}];
                
                $res -> {'page_page_num'} = $$cfg{'page_page_num'} + 1;
                
                @page_pieces_tmp = ();
                @page_pieces = ();
            }
            
            $res->{'is_writable'} = 1 if (
                $SESSION{'USR'}->chk_access('pages', 'manage_any', 'r') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('pages', 'manage_others', 'r') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                ) || 
                $SESSION{'USR'}->chk_access('pages', 'manage_any', 'r') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'author_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('pages', 'manage_others', 'r') && 
                    $res -> {'author_role_id'} == $SESSION{'USR'}->{'role_id'} 
                ) 
            );
            push @pages_res, {%{$res}};
            push @pages_ids, $res -> {'page_id'};
            $access_roles{$res -> {'page_id'}} = 1 if ($res -> {'use_access_roles'});
          }
      }
      else {
          while ($res = $sth->fetchrow_hashref()) {
              
            unless ($$cfg{'disable_autotranslate'}) {
                if ($res->{'lang'} ne $trans_lang) {
                    $to_trans{$res->{'page_id'}} = 1;
                }
            }
            
            if (
                !$$cfg{'skip_pagination'} && 
                $SESSION{'PAGE_PAGER_SPLITTER'} && 
                ref $SESSION{'PAGE_PAGER_SPLITTER'} eq 'ARRAY' && 
                scalar @{$SESSION{'PAGE_PAGER_SPLITTER'}}
            ) {
                @page_pieces = ($res -> {'body'}, );
                foreach my $splitter (@{$SESSION{'PAGE_PAGER_SPLITTER'}}) {
                    @page_pieces_tmp = ();
                    foreach my $piece (@page_pieces) {
                         push @page_pieces_tmp, split $splitter, $piece;
                    }
                    @page_pieces = @page_pieces_tmp;
                }
                $res -> {'page_pages_size'} = scalar @page_pieces;
                
                #If page not exist - show first one
                $$cfg{'page_page_num'} = 0
                    if $$cfg{'page_page_num'} >= $res -> {'page_pages_size'};
                
                $res -> {'body'} = $page_pieces[$$cfg{'page_page_num'}];
                
                $res -> {'page_page_num'} = $$cfg{'page_page_num'} + 1;
                
                @page_pieces_tmp = ();
                @page_pieces = ();
            }
            
            $res->{'is_writable'} = 1 if (
                $SESSION{'USR'}->chk_access('pages', 'manage_any', 'r') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('pages', 'manage_others', 'r') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                ) || 
                $SESSION{'USR'}->chk_access('pages', 'manage_any', 'r') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'author_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('pages', 'manage_others', 'r') && 
                    $res -> {'author_role_id'} == $SESSION{'USR'}->{'role_id'} 
                ) 
            );
            $pages_res{$res -> {'page_id'}} = {%{$res}};
            $access_roles{$res -> {'page_id'}} = 1 if ($res -> {'use_access_roles'});
          }
          
          @pages_ids = keys %pages_res;
          
      }
      $sth -> finish();
      ($foundrows) = $dbh -> selectrow_array('SELECT FOUND_ROWS()');
    };
    
    unless (${$cfg}{'get_all_records'}) {
        %pages = ( count => 1, );
        %pages = &sv_cutpages(
          {
            '-size' => $foundrows, 
            '-items_per_page' => $items_pp, 
            '-page' => ${$cfg}{'page'}, 
          }
        ) if $items_pp;
    }
    
    if (${$cfg}{'get_transes'} && scalar @pages_ids) {
        $pages_transes = ${&pages_get_transes({
            page_ids => [@pages_ids], 
            lang => ${$cfg}{'lang'}, 
        })}{'transes'};
    }
    
    if (${$cfg}{'get_access_roles'} && scalar keys %access_roles) {
        $pages_access_roles = ${&pages_get_access_roles({
            page_ids => [@pages_ids], 
        })}{'access_roles'};
    }
    
    if (scalar keys %to_trans) {
        #!disable_autotranslate thing
        $transes = ${&pages_get_transes({
            page_ids => [keys %to_trans], 
            lang => $trans_lang, 
        })}{'transes'};
        
        unless (${$cfg}{'res_ashash'}) {
            foreach my $p_id (keys %{$transes}) {
                $page_res_tmp = $pages_res[$to_trans{$p_id}];
                ${$page_res_tmp}{'lang'} = $trans_lang;
                ${$page_res_tmp}{'lang_istranslated'} = 1;
                ${$page_res_tmp}{'intro'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'intro'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'intro'};
                ${$page_res_tmp}{'body'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'body'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'body'};
                ${$page_res_tmp}{'header'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'header'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'header'};
                ${$page_res_tmp}{'descr'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'descr'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'descr'};
                ${$page_res_tmp}{'keywords'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'keywords'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'keywords'};
                ${$page_res_tmp}{'custom_title'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'custom_title'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'custom_title'};
                $pages_res[$to_trans{$p_id}] = $page_res_tmp;
            }
        }
        else {
            foreach my $p_id (keys %{$transes}) {
                ${$pages_res{$p_id}}{'lang'} = $trans_lang;
                ${$pages_res{$p_id}}{'lang_istranslated'} = 1;
                ${$pages_res{$p_id}}{'intro'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'intro'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'intro'};
                ${$pages_res{$p_id}}{'body'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'body'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'body'};
                ${$pages_res{$p_id}}{'header'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'header'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'header'};
                ${$pages_res{$p_id}}{'descr'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'descr'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'descr'};
                ${$pages_res{$p_id}}{'keywords'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'keywords'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'keywords'};
                ${$pages_res{$p_id}}{'custom_title'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'custom_title'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'custom_title'};
            }
        }
    }

    unless (${$cfg}{'res_ashash'}) {
        $pages_res = \@pages_res;
    }
    else {
        $pages_res = \%pages_res;
    }
    
    return {
        q => $q, 
        pages_res => $pages_res, 
        pages_ids => \@pages_ids, 
        
        transes => $pages_transes, 
        pages_access_roles => $pages_access_roles, 
        
        pages => \%pages, 
        foundrows => $foundrows, 
    };
} #-- content_get_pagerecord

1;
