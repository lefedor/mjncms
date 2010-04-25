package MjNCMS::ContentBlocksSiteLibRead;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
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
       
       blocks_get_access_roles 
       blocks_get_transes 
       content_get_blocks 
       
    /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
    
}


########################################################################
#                    Functions to read blocks data
########################################################################

sub blocks_get_transes ($) {
    
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
        %transes, $where_rule, 
        $date_format, 
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    if (
        ${$cfg}{'block_id'} &&
        ${$cfg}{'block_id'} =~ /^\d+$/
    ) {
        $where_rule .= ' AND bt.block_id = ' . ($dbh->quote(${$cfg}{'block_id'})) . ' ';
    }
    
    if (
        ${$cfg}{'block_ids'} &&
        ref ${$cfg}{'block_ids'} && 
        ref ${$cfg}{'block_ids'} eq 'ARRAY' && 
        !(scalar (grep(/\D/, @{${$cfg}{'block_ids'}})))
    ) {
        $where_rule .= ' AND bt.block_id IN (' . (join ', ', @{${$cfg}{'block_ids'}}) . ') ';
    }
    
    if (
        ${$cfg}{'lang'} &&
        ${$cfg}{'lang'} =~ /^\w{2,4}$/
    ) {
        $where_rule .= ' AND bt.lang = ' . ($dbh->quote(${$cfg}{'lang'})) . ' ';
    }
    elsif (
        ${$cfg}{'lang'} && 
        ref ${$cfg}{'lang'} && 
        ref ${$cfg}{'lang'} eq 'ARRAY' 
    ) {
        $where_rule .= ' AND bt.lang IN (' . (join ', ', (map( $dbh->quote($_), @{${$cfg}{'lang'}}))) . ') ';
    }
    
    $where_rule =~ s/AND/WHERE/;
        
    $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_md_fmt() );
    
    $q = qq~
        SELECT 
            bt.block_id AS id, bt.block_id, bt.lang, 
            bt.header, bt.body, 
            bt.member_id, bt.whoedit, 
            #do i need this?
            m_usr.name AS creator, 
            e_usr.name AS editor, 
            DATE_FORMAT(bt.ins, $date_format) AS bt_ins, 
            DATE_FORMAT(bt.upd, $date_format) AS bt_upd 
        FROM ${SESSION{PREFIX}}block_transes bt 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=bt.member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=bt.whoedit 
        $where_rule
    ~;
        
    eval {
        $sth = $dbh -> prepare($q);$sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            $transes{$res->{'block_id'}} = {} 
                unless defined $transes{ $res -> {'block_id'} };
            $transes{$res->{'block_id'}}{$res->{'lang'}} = {%{$res}};
        }
    };
    
    return {
        q => $q, 
        transes => \%transes, 
    }
    
} #-- blocks_get_transes

sub content_get_blocks (;$) {
    
    my $cfg = shift;
    
    $cfg = {} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    my (
        $dbh, $sth, $res, $q, 
        @blocks, %blocks, 
        @blocks_ids, 
        
        %access_roles, 
        $blocks_transes, 
        $blocks_access_roles, 
        
        $date_format, 
        
        $page, $items_pp, $start, $end, $limit, 
        
        $where_rule, $orderby, 
        
        $foundrows, %pages, 
        
        %to_trans, $transes, $trans_lang, 
        $block_res_tmp, 
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    if ( 
        ${$cfg}{'block_id'} && 
        !(ref ${$cfg}{'block_id'}) && 
        ${$cfg}{'block_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' AND b.block_id = ' . ($dbh->quote(${$cfg}{'block_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'block_ids'} && 
        ref ${$cfg}{'block_ids'} && 
        scalar @{${$cfg}{'block_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'block_ids'}})))
    ) {
        $where_rule .= ' AND b.block_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'block_ids'}}))) . ') ';
    }
    
    if (${$cfg}{'header'} && length ${$cfg}{'header'}) {
        ${$cfg}{'header'} = $dbh->quote(${$cfg}{'header'});
        ${$cfg}{'header'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND b.header LIKE \'' . ${$cfg}{'name'} . '\' ';
    }
    
    if (
        ${$cfg}{'alias'} && 
        !(ref ${$cfg}{'alias'}) &&
        length ${$cfg}{'alias'}
    ) {
        ${$cfg}{'alias'} = $dbh->quote(${$cfg}{'alias'});
        $where_rule .= ' AND b.alias = ' . ${$cfg}{'alias'} . ' ';
    }
    elsif (
        ${$cfg}{'alias'} && 
        ref ${$cfg}{'alias'} && 
        ref ${$cfg}{'alias'} eq 'ARRAY' 
    ) {
        $where_rule .= ' AND b.alias IN (' . (join ', ', (map( $dbh->quote($_), @{${$cfg}{'alias'}}))) . ') ';
    }
    
    if (${$cfg}{'alias_like'} && length ${$cfg}{'alias_like'}) {
        ${$cfg}{'alias_like'} = $dbh->quote(${$cfg}{'alias_like'});
        ${$cfg}{'alias_like'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND b.alias LIKE \'' . ${$cfg}{'alias_like'} . '\' ';
    }
    
    if (
        ${$cfg}{'lang'} && 
        length ${$cfg}{'lang'} && 
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$cfg}{'lang'}) 
    ) {
        $where_rule .= ' AND b.lang = ' . ($dbh->quote(${$cfg}{'lang'})) . ' ';
    }

    if ( 
        ${$cfg}{'member_id'} && 
        ${$cfg}{'member_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' AND b.member_id = ' . ($dbh->quote(${$cfg}{'member_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'is_active'} && 
        ${$cfg}{'is_active'} =~ /^(yes|no)$/i 
    ) {
        $where_rule .= ' AND b.is_active = ' . (((lc ${$cfg}{'is_active'}) eq 'yes')? '1':'0') . ' ';
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
            b.block_id AS id, b.block_id, 
            b.is_active, b.lang, b.alias, 
            b.header, b.body, 
            b.show_header, 
            b.use_access_roles, 
            b.member_id, 
            b.whoedit,
            UNIX_TIMESTAMP(b.ins) AS ut_ins, 
            UNIX_TIMESTAMP(b.upd) AS ut_upd, 
            DATE_FORMAT(b.ins, $date_format) AS ins_fmt, 
            DATE_FORMAT(b.upd, $date_format) AS upd_fmt, 

            m_usr.name AS creator, m_usr.role_id AS creator_role_id, 
            e_usr.name AS editor
            
        FROM ${SESSION{PREFIX}}blocks b 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=b.member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=b.whoedit ~;
    
    unless (${$cfg}{'skip_access_roles_rule'}) {
        $q .= qq~ LEFT JOIN ${SESSION{PREFIX}}blocks_access_roles bar 
            ON (
                b.use_access_roles = 1
                AND 
                    bar.block_id=b.block_id
                AND 
                    bar.role_id=~ . ($dbh->quote($SESSION{'USR'}->{'role_id'})) . qq~
            ) ~;
        $where_rule .= qq~ AND (
            b.use_access_roles != 1
            OR bar.block_id IS NOT NULL 
        ) ~;
    }
    
    
    
    $where_rule =~ s/AND/WHERE/;
            
    $q .= qq~ $where_rule 
    ~;
    
    $orderby = ' ORDER BY b.ins DESC ';
    if (
        ${$cfg}{'order'} && 
        length ${$cfg}{'order'} && 
        &inarray([
            'id', 'header', 
            'lang', 'ins', 
            'alias', 'is_active' ], ${$cfg}{'order'})
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
      unless ((${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash')) {
          while ($res = $sth->fetchrow_hashref()) {
              
            unless ($$cfg{'disable_autotranslate'}) {
                if (
                    $res->{'lang'} && #undef lang == (1 block for all lang)
                    $res->{'lang'} ne $trans_lang
                ) {
                    $to_trans{$res->{'block_id'}} = scalar @blocks;
                }
            }
              
            $res->{'is_writable'} = 1 if (
                $SESSION{'USR'}->chk_access('blocks', 'manage_any', 'r') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('blocks', 'manage_others', 'r') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                ) 
            );
            push @blocks, {%{$res}};
            push @blocks_ids, $res -> {'block_id'};
            $access_roles{$res -> {'block_id'}} = 1 if ($res -> {'use_access_roles'});
          }
      }
      else {
          while ($res = $sth->fetchrow_hashref()) {
              
            unless ($$cfg{'disable_autotranslate'}) {
                if (
                    $res->{'lang'} && #undef lang == (1 block for all lang)
                    $res->{'lang'} ne $trans_lang
                ) {
                    $to_trans{$res->{'block_id'}} = 1;
                }
            }
              
            $res->{'is_writable'} = 1 if (
                $SESSION{'USR'}->chk_access('blocks', 'manage_any', 'r') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('blocks', 'manage_others', 'r') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                ) 
            );
            $blocks{$res -> {'block_id'}} = {%{$res}};
            $access_roles{$res -> {'blocks_id'}} = 1 if ($res -> {'use_access_roles'});
          }
          
          @blocks_ids = keys %blocks;
          
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
    
    if (${$cfg}{'get_transes'} && scalar @blocks_ids) {
        $blocks_transes = ${&blocks_get_transes({
            block_ids => [@blocks_ids], 
            lang => ${$cfg}{'lang'}, 
        })}{'transes'};
    }
    
    if (${$cfg}{'get_access_roles'} && scalar keys %access_roles) {
        #This call will currently only from Admin Interface, 
        #Current sub is part of MjNCMS::Content in that situation 
        #because of Exporter
        $blocks_access_roles = ${&MjNCMS::Content::blocks_get_access_roles({
            block_ids => [@blocks_ids], 
        })}{'access_roles'};
    }
    
    if (scalar keys %to_trans) {
        #!disable_autotranslate thing
        $transes = ${&blocks_get_transes({
            block_ids => [keys %to_trans], 
            lang => $trans_lang, 
        })}{'transes'};
        
        unless ((${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash')) {
            foreach my $b_id (keys %{$transes}) {
                $block_res_tmp = $blocks[$to_trans{$b_id}];
                ${$block_res_tmp}{'lang'} = $trans_lang;
                ${$block_res_tmp}{'lang_istranslated'} = 1;
                ${$block_res_tmp}{'header'} = 
                    ${${$transes}{$b_id}}{$trans_lang}{'header'} 
                        if ${${$transes}{$b_id}}{$trans_lang}{'header'};
                ${$block_res_tmp}{'body'} = 
                    ${${$transes}{$b_id}}{$trans_lang}{'body'} 
                        if ${${$transes}{$b_id}}{$trans_lang}{'body'};
                $blocks[$to_trans{$b_id}] = $block_res_tmp;
            }
        }
        else {
            foreach my $p_id (keys %{$transes}) {
                ${$blocks{$p_id}}{'lang'} = $trans_lang;
                ${$blocks{$p_id}}{'lang_istranslated'} = 1;
                ${$blocks{$p_id}}{'header'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'header'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'header'};
                ${$blocks{$p_id}}{'body'} = 
                    ${${$transes}{$p_id}}{$trans_lang}{'body'} 
                        if ${${$transes}{$p_id}}{$trans_lang}{'body'};
            }
        }
    }
    
    return {
        q => $q, 
        blocks => (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash')? \%blocks:\@blocks, 
        blocks_ids => \@blocks_ids, 
        
        transes => $blocks_transes, 
        blocks_access_roles => $blocks_access_roles, 
        
        pages => \%pages, 
        foundrows => $foundrows, 
    };
    
} #-- content_get_blocks

1;
