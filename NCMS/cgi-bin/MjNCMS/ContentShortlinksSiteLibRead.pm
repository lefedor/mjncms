package MjNCMS::ContentShortlinksSiteLibRead;
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
       
       content_get_short_urls 
       
    /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
    
}

########################################################################
#                Functions to read short links data
########################################################################

sub content_get_short_urls (;$) {
    
    my $cfg = shift;
    
    $cfg = {} unless ($cfg && ref $cfg && ref $cfg eq 'HASH');

    my (
        $dbh, $sth, $res, $q, 
        @urls_ids, @urls, %urls, 
        
        $where_rule, $orderby, 
        $date_format, 
        
        $page, $items_pp, $start, $end, $limit, 
        
        $foundrows, %pages, 
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    $orderby = ' ORDER BY su.ins DESC ';
    $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_mdt_fmt() );

    
    if ( 
        ${$cfg}{'alias_id'} && 
        !(ref ${$cfg}{'alias_id'}) && 
        ${$cfg}{'alias_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' AND su.alias_id = ' . ($dbh->quote(${$cfg}{'alias_id'})) . ' ';
    }
    
    if ( 
        ${$cfg}{'alias_ids'} && 
        ref ${$cfg}{'alias_ids'} && 
        scalar @{${$cfg}{'alias_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'alias_ids'}})))
    ) {
        $where_rule .= ' AND su.alias_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'alias_ids'}}))) . ') ';
    }

    if ( 
        defined ${$cfg}{'sugrp_id'} && 
        !(ref ${$cfg}{'sugrp_id'}) && 
        ${$cfg}{'sugrp_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' AND su.sugrp_id = ' . ($dbh->quote(${$cfg}{'sugrp_id'})) . ' ';
    }
    elsif ( 
        defined ${$cfg}{'sugrp_id'} && 
        ${$cfg}{'sugrp_id'} eq 'no'
    ) {
        $where_rule .= ' AND su.sugrp_id IS NULL ';
    }
    
    if ( 
        defined ${$cfg}{'sugrp_ids'} && 
        ref ${$cfg}{'sugrp_ids'} && 
        scalar @{${$cfg}{'sugrp_ids'}} && 
        !(scalar (grep(/\D/, @{${$cfg}{'sugrp_ids'}})))
    ) {
        $where_rule .= ' AND su.sugrp_id IN ( ' . ($dbh->quote((join ', ', @{${$cfg}{'sugrp_ids'}}))) . ') ';
    }
    
    if (defined ${$cfg}{'alias'} && length ${$cfg}{'alias'}) {
        ${$cfg}{'alias'} = $dbh->quote(${$cfg}{'alias'});
        $where_rule .= ' AND su.alias = ' . ${$cfg}{'alias'} . ' ';
    }
    
    if (defined ${$cfg}{'alias_like'} && length ${$cfg}{'alias_like'}) {
        ${$cfg}{'alias_like'} = $dbh->quote(${$cfg}{'alias_like'});
        ${$cfg}{'alias_like'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND su.alias LIKE \'' . ${$cfg}{'alias_like'} . '\' ';
    }
    
    if (defined ${$cfg}{'original_url'} && length ${$cfg}{'original_url'}) {
        ${$cfg}{'original_url'} = $dbh->quote(${$cfg}{'original_url'});
        ${$cfg}{'original_url'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND su.original_url LIKE \'' . ${$cfg}{'alias'} . '\' ';
    }
    
    $where_rule =~ s/AND/WHERE/;

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
    
    $q = qq~
        SELECT SQL_CALC_FOUND_ROWS 
            su.alias_id, su.alias, 
            su.orig_url, su.member_id ~;
    if (${$cfg}{'get_extra_data'}) {
        $q .= qq~ , 
            su.sugrp_id, su.is_custom, 
            su.sha1_sum, 
            UNIX_TIMESTAMP(su.ins) AS ut_ins, 
            UNIX_TIMESTAMP(su.upd) AS ut_upd, 
            DATE_FORMAT(su.ins, $date_format) AS ins_fmt, 
            DATE_FORMAT(su.upd, $date_format) AS upd_fmt, 
            su.whoedit, 
            
            sug.name as sug_name,
            
            m_usr.name AS creator, m_usr.role_id AS creator_role_id, 
            e_usr.name AS editor
            
        ~;
    }
    $q .= qq~   FROM ${SESSION{PREFIX}}short_urls su ~;
    if (${$cfg}{'get_extra_data'}) {
        $q .= qq~ 
            LEFT JOIN ${SESSION{PREFIX}}short_url_groups sug ON sug.sugrp_id=su.sugrp_id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=su.member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=su.whoedit 
        ~;
    }
    $q .= qq~
        $where_rule 
        $orderby 
        $limit ; 
    ~;
    
    eval {
      $sth = $dbh -> prepare($q);$sth -> execute();
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
            push @urls, {%{$res}};
            push @urls_ids, $res -> {'alias_id'};
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
            $urls{$res -> {'alias_id'}} = {%{$res}};
          }
      }
      $sth -> finish();
      ($foundrows) = $dbh -> selectrow_array('SELECT FOUND_ROWS()');
    };
    
    @urls_ids = keys %urls if 
        (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash');
    
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
    
    return {
        q => $q, 
        urls => (${$cfg}{'mode'} && ${$cfg}{'mode'} eq 'as_hash')? \%urls:\@urls, 
        urls_ids => \@urls_ids, 
        pages => \%pages, 
        foundrows => $foundrows, 
    };

} #-- content_get_short_urls

1;
