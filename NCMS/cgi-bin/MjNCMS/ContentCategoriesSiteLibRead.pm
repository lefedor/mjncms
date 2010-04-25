package MjNCMS::ContentCategoriesSiteLibRead;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
#use MjNCMS::Service qw/:subs /;

BEGIN {
    use Exporter ();
    use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS /;
    @ISA         = qw/Exporter /;
    @EXPORT      = qw/ /;
    @EXPORT_OK   = qw/ /;
    
    %EXPORT_TAGS = (
      vars => [qw/ /],
      subs => [qw/
       
       content_get_cattranses 
       content_get_catrecord 
       
    /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
    
}


########################################################################
#                    Functions to read cats data
########################################################################


sub content_get_cattranses ($;$) {
    
    my $cats_ids = $_[0];
    my $langs_ids = $_[1];
    
    return {} unless ($cats_ids && ref $cats_ids && ref $cats_ids eq 'ARRAY');
    
    my (
        $dbh, 
        $q, $res, $sth, $date_format, 
        $in_str, %cats_transes, 
        @langs, 
        
    ) = ($SESSION{'DBH'}, );
    
    if (scalar @{$cats_ids} && !(scalar (grep(/\D/, @{$cats_ids})))) {
        $in_str = join ', ', @{$cats_ids};
        
        $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_md_fmt() );
        
        $q = qq~
            SELECT 
                ct.cat_id, ct.lang, 
                ct.name, 
                ct.descr, ct.keywords, 
                ct.member_id, ct.whoedit, 
                m_usr.name AS creator, 
                e_usr.name AS editor, 
                DATE_FORMAT(ct.ins, $date_format) AS ct_ins, 
                DATE_FORMAT(ct.upd, $date_format) AS ct_upd 
            FROM ${SESSION{PREFIX}}cats_trans ct 
                LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=ct.member_id 
                LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=ct.whoedit 
            WHERE ct.cat_id IN ( $in_str )  
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
                    AND ct.lang IN ( $in_str ) 
                ~;
            }
        }
        $q .= ' ; ';
        eval {
          $sth = $dbh -> prepare($q);$sth -> execute();
          while ($res = $sth->fetchrow_hashref()) {
              $cats_transes{$res->{'cat_id'}} = {} unless defined($cats_transes{$res->{'cat_id'}});
              $cats_transes{$res->{'cat_id'}}{$res->{'lang'}} = {%{$res}};
          }
          $sth -> finish();
        };
    }
    
    return \%cats_transes;
    
} #-- content_get_cattranses

sub content_get_catrecord ($) {
    
    my $cats = $_[0];
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
        $in_str, @cats, %cats, 
        @to_trans, $transes, 
        $where_rule, 
        
    ) = ($SESSION{'DBH'}, );
    
    $where_rule = '';
    
    if ( 
        ${$extra_cfg}{'cat_id'} && 
        !(ref ${$extra_cfg}{'cat_id'}) && 
        ${$extra_cfg}{'cat_id'} =~ /^\d+$/ 
    ) {
        $where_rule .= ' AND cd.cat_id = ' . ($dbh->quote(${$extra_cfg}{'cat_id'})) . ' ';
    }
    
    if ( 
        ${$extra_cfg}{'cat_ids'} && 
        ref ${$extra_cfg}{'cat_ids'} && 
        scalar @{${$extra_cfg}{'cat_ids'}} && 
        !(scalar (grep(/\D/, @{${$extra_cfg}{'cat_ids'}}))) 
    ) {
        $where_rule .= ' AND cd.cat_id IN ( ' . ($dbh->quote((join ', ', @{${$extra_cfg}{'cat_ids'}}))) . ') ';
    }
    
    if (${$extra_cfg}{'name'} && length ${$extra_cfg}{'name'}) {
        ${$extra_cfg}{'name'} = $dbh->quote(${$extra_cfg}{'name'});
        ${$extra_cfg}{'name'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND cd.name LIKE \'' . ${$extra_cfg}{'name'} . '\' ';
    }
    
    ${$extra_cfg}{'slug'} = ${$extra_cfg}{'cname'} 
        if ${$extra_cfg}{'cname'};
    ${$extra_cfg}{'slug_like'} = ${$extra_cfg}{'cname_like'}
        if ${$extra_cfg}{'cname_like'};
        
    if (${$extra_cfg}{'slug'} && length ${$extra_cfg}{'slug'}) {
        ${$extra_cfg}{'slug'} = $dbh->quote(${$extra_cfg}{'slug'});
        $where_rule .= ' AND cd.cname = ' . ${$extra_cfg}{'slug'} . ' ';
    }
    
    if (${$extra_cfg}{'slug_like'} && length ${$extra_cfg}{'slug_like'}) {
        ${$extra_cfg}{'slug_like'} = $dbh->quote(${$extra_cfg}{'slug_like'});
        ${$extra_cfg}{'slug_like'} =~ s/^\'|\*|\'$/%/g;
        $where_rule .= ' AND cd.cname LIKE \'' . ${$extra_cfg}{'slug_like'} . '\' ';
    }
    
    if (
        ${$extra_cfg}{'lang'} && 
        length ${$extra_cfg}{'lang'} && 
        !&inarray([keys %{$SESSION{'SITE_LANGS'}}], ${$extra_cfg}{'lang'}) 
    ) {
        $where_rule .= ' AND cd.lang = ' . ($dbh->quote(${$extra_cfg}{'lang'})) . ' ';
    }
    
    if ($cats && ref $cats && ref $cats eq 'ARRAY') {
        @cats = @{$cats};
    }
    elsif ($cats && $cats =~ /^\d+$/) {
        push @cats, $cats;
    }
    else {
        return undef;
    }
    
    if ( 
        (
            !(scalar @cats) && 
            !(length $where_rule) 
        ) || 
        (scalar (grep(/\D/, @cats))) 
    ) {
        return undef;
    }
    
    if (scalar @cats) {
        $in_str = join ', ', @cats;
        $where_rule .= " AND ct.id IN ( $in_str ) ";
    }
    
    $date_format = $dbh -> quote( $SESSION{'LOC'} -> get_md_fmt() );
    
    $where_rule =~ s/AND/WHERE/;
    
    $q = qq~
        SELECT 
            ct.id, cd.cat_id, ct.level, ct.left_key, ct.right_key, 
            cd.lang, cd.name, cd.extra_data, 
            cd.descr, cd.keywords, 
            cd.cname, cd.is_active, cd.member_id, cd.whoedit, 
            m_usr.name AS creator, m_usr.role_id AS creator_role_id, 
            e_usr.name AS editor, 
            DATE_FORMAT(cd.ins, $date_format) AS cd_ins, 
            DATE_FORMAT(cd.upd, $date_format) AS cd_upd 
        FROM ${SESSION{PREFIX}}cats_tree ct 
            LEFT JOIN ${SESSION{PREFIX}}cats_data cd ON cd.cat_id=ct.id 
            LEFT JOIN ${SESSION{PREFIX}}users m_usr ON m_usr.member_id=cd.member_id 
            LEFT JOIN ${SESSION{PREFIX}}users e_usr ON e_usr.member_id=cd.whoedit 
        $where_rule 
        ORDER BY cd.ins ASC ; 
    ~;
    
    eval {
        $sth = $dbh -> prepare($q); $sth -> execute();
        while ($res = $sth->fetchrow_hashref()) {
            
            unless ($$extra_cfg{'disable_autotranslate'}) {
                if ($res->{'lang'} ne $SESSION{'LOC'}->{'CURRLANG'}) {
                    push @to_trans, $res->{'cat_id'};
                }
            }
            
            $cats{$res->{'id'}} = {%{$res}};
            ${$cats{$res->{'id'}}}{'is_writable'} = 1 if (
                $SESSION{'USR'}->chk_access('categories', 'manage_any', 'r') || 
                $SESSION{'USR'}->is_user_writable( $res -> {'member_id'} ) || 
                (
                    $SESSION{'USR'}->chk_access('categories', 'manage_others', 'r') && 
                    $res -> {'creator_role_id'} == $SESSION{'USR'}->{'role_id'} 
                )
            );
        }
        $sth -> finish(); 
    };
    
    if (scalar @to_trans) {
        #!disable_autotranslate thing
        $transes = &content_get_cattranses([@to_trans], $SESSION{'LOC'}->{'CURRLANG'});
        foreach my $c_id (keys %{$transes}) {
            ${$cats{$c_id}}{'lang'} = $SESSION{'LOC'}->{'CURRLANG'};
            ${$cats{$c_id}}{'lang_istranslated'} = 1;
            ${$cats{$c_id}}{'name'} = 
                ${${$transes}{$c_id}}{$SESSION{'LOC'}->{'CURRLANG'}}{'name'} 
                    if ${${$transes}{$c_id}}{$SESSION{'LOC'}->{'CURRLANG'}}{'name'};
            ${$cats{$c_id}}{'descr'} = 
                ${$transes}{$c_id}{$SESSION{'LOC'}->{'CURRLANG'}}{'descr'} 
                    if ${$transes}{$c_id}{$SESSION{'LOC'}->{'CURRLANG'}}{'descr'};
            ${$cats{$c_id}}{'keywords'} = 
                ${$transes}{$c_id}{$SESSION{'LOC'}->{'CURRLANG'}}{'keywords'} 
                    if ${$transes}{$c_id}{$SESSION{'LOC'}->{'CURRLANG'}}{'keywords'};
        }
    }
    
    return {
        q => $q, 
        records => \%cats, 
        
    };
} #-- content_get_catrecord


1;
