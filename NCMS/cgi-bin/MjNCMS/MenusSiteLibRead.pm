package MjNCMS::MenusSiteLibRead;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Common library with menus functions 
# used only on content-side, READ part 
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
#use MjNCMS::Service qw/:subs /;
use MjNCMS::NS;

BEGIN {
    use Exporter ();
    use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS /;
    @ISA         = qw/Exporter /;
    @EXPORT      = qw/ /;
    @EXPORT_OK   = qw/ /;
    
    %EXPORT_TAGS = (
      vars => [qw/ /],
      subs => [qw/
       
       menus_get_transes 
       menus_get_record 
       menus_get_record_tree 
       
    /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
    
}

########################################################################
#                     Functions to read menus data
########################################################################


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
        $transes = &menus_get_transes([@to_trans], $SESSION{'LOC'}->{'CURRLANG'});
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

1;
