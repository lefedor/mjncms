package MjNCMS::ContentShortlinksSiteLibWrite;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
#use MjNCMS::Service qw/:subs /;

use Digest::SHA1 qw/sha1_hex /;#urls chk_sum

BEGIN {
    use Exporter ();
    use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS /;
    @ISA         = qw/Exporter /;
    @EXPORT      = qw/ /;
    @EXPORT_OK   = qw/ /;
    
    %EXPORT_TAGS = (
      vars => [qw/ /],
      subs => [qw/
       
       _surl_next_url_alias 
       surl_url_add 
       
    /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
}

########################################################################
#                Functions to write short links data
########################################################################

sub _surl_next_url_alias ($) {
    
    my $alias = shift;

    #up to 8**35 = 2.251.875.390.625 combo. seems enough.
    #500k record just eq '9orw'

    my (
        $maxweight, 
        $max_sql_field_size, 
        $next_alias, $char
    ) = (35, 8); # %weights max weight, #sql field max size
    
    return undef unless (
        defined $alias && 
        length $alias && 
        $alias =~ /^[0-9A-Za-z]{1,$max_sql_field_size}$/ 
    );
    
    my %weights = (
        '0' => 0, 
        '1' => 1, 
        '2' => 2, 
        '3' => 3, 
        '4' => 4, 
        '5' => 5, 
        '6' => 6, 
        '7' => 7, 
        '8' => 8, 
        '9' => 9, 
        'a' => 10, 
        'b' => 11, 
        'c' => 12, 
        'd' => 13, 
        'e' => 14, 
        'f' => 15, 
        'g' => 16, 
        'h' => 17, 
        'i' => 18, 
        'j' => 19, 
        'k' => 20, 
        'l' => 21, 
        'm' => 22, 
        'n' => 23, 
        'o' => 24, 
        'p' => 25, 
        'q' => 26, 
        'r' => 27, 
        's' => 28, 
        't' => 29, 
        'u' => 30, 
        'v' => 31, 
        'w' => 32, 
        'x' => 33, 
        'y' => 34, 
        'z' => 35, 
        
    );
    
    my %antiweights = (
        0 => '0',
        1 => '1',
        2 => '2',
        3 => '3',
        4 => '4',
        5 => '5',
        6 => '6',
        7 => '7',
        8 => '8',
        9 => '9',
        10 => 'a',
        11 => 'b',
        12 => 'c',
        13 => 'd',
        14 => 'e',
        15 => 'f',
        16 => 'g',
        17 => 'h',
        18 => 'i',
        19 => 'j',
        20 => 'k',
        21 => 'l',
        22 => 'm',
        23 => 'n',
        24 => 'o',
        25 => 'p',
        26 => 'q',
        27 => 'r',
        28 => 's',
        29 => 't',
        30 => 'u',
        31 => 'v',
        32 => 'w',
        33 => 'x',
        34 => 'y',
        35 => 'z',
    );
    
    $alias = lc($alias);
    
    for (my $i = 1; $i <= (length $alias); $i++) {
        if ($i==1) {
            $char = substr($alias, -1)
        }
        else{
            $char = substr($alias, -($i), -($i-1));
        }
        
        if (
            $weights{$char} == $maxweight
        ) {
            next;
        }
        elsif (
            $weights{$char} < $maxweight
        ) {
            $next_alias = substr($alias , 0, ((length $alias) - $i ));
            $next_alias .= $antiweights{$weights{$char}+1};
            $next_alias .= '0' x ($i-1) if $i >= 1;
            last;
        }
        else {
            return undef;
        }
    }
    
    $next_alias = '0' x ((length $alias) + 1) unless $next_alias;
    
    return undef if (length $next_alias) > $max_sql_field_size;
    
    return $next_alias;
    
} #-- _surl_next_url_alias

sub surl_url_add () {
    
    my $cfg = shift;
    
    return {
            status => 'fail', 
            message => 'no input cfg', 
    } unless ($cfg && ref $cfg && ref $cfg eq 'HASH');
    
    ${$cfg}{'alias'} = undef unless (
        defined ${$cfg}{'alias'} &&
        length ${$cfg}{'alias'} && 
        ${$cfg}{'alias'} =~ /^[0-9A-Za-z]{1,8}$/ 
    );
    
    ${$cfg}{'alias'} = lc(${$cfg}{'alias'});
    
    return {
        status => 'fail', 
        message => 'original_url chk fail',
    } unless (
        defined(${$cfg}{'original_url'}) &&
        length ${$cfg}{'original_url'} &&
        (
            ${$cfg}{'original_url'} =~ /^\w+\:\/\// ||
            ${$cfg}{'original_url'} =~ /^\/w+/ 
        )
    ); 

    ${$cfg}{'sugrp_id'} = undef unless ${$cfg}{'sugrp_id'} =~ /^\d+$/;
    
    my (
        $dbh, $res, $sth, $q, 
        $sha1_sum, $is_custom, 
        $alias_match, $steps,
        $inscnt, $alias_id, 
        
    ) = ($SESSION{'DBH'}, );
    
    $sha1_sum = sha1_hex(${$cfg}{'original_url'});

    eval {
        $dbh -> do(qq~
            LOCK TABLES 
                ${SESSION{PREFIX}}short_urls WRITE,  
                ${SESSION{PREFIX}}short_urls AS in_su READ ; 
        ~);
    };
    
    unless ($SESSION{'SHORT_URLS_ALLOW_MULTIALIAS'}) {
    
        $q = qq~
            SELECT 
                alias_id, alias 
            FROM ${SESSION{PREFIX}}short_urls 
            WHERE 
                sha1_sum = ? 
                    AND sugrp_id~;
                    
        if (defined ${$cfg}{'sugrp_id'} && ${$cfg}{'sugrp_id'} =~ /^\d+$/) {
            $q .= ' = ' . ${$cfg}{'sugrp_id'} . ' ; ';
        }
        else {
            $q .= ' IS NULL ; ';
        }
        
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute($sha1_sum);
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        
        if (scalar $res -> {'alias_id'}) {
            $dbh -> do("UNLOCK TABLES ; ");
            return {
                status => 'ok', 
                alias => lc($res -> {'alias'}), 
                alias_id => $res -> {'alias_id'}, 
                message => 'All ok, but url exist, exist alias returned.', 
                
            }
        }
        
    }
    
    if (${$cfg}{'alias'}) {
        
        $is_custom = 1;
        $q = qq~
            SELECT 
                alias_id 
            FROM ${SESSION{PREFIX}}short_urls 
            WHERE 
                alias = ? 
                    AND sugrp_id~;
                    
        if (defined ${$cfg}{'sugrp_id'} && ${$cfg}{'sugrp_id'} =~ /^\d+$/) {
            $q .= ' = ' . ${$cfg}{'sugrp_id'} . ' ; ';
        }
        else {
            $q .= ' IS NULL ; ';
        }
        
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute(${$cfg}{'alias'});
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        
        if (scalar $res -> {'alias_id'}) {
            $dbh -> do("UNLOCK TABLES ; ");
            return {
                status => 'fail', 
                message => 'alias exist', 
            }
        }
        
    }
    else {
        
        $q = qq~
            SELECT alias_id, alias
            FROM ${SESSION{PREFIX}}short_urls
            WHERE 
                alias_id IN (
                    SELECT MAX(alias_id) AS m_aid 
                    FROM ${SESSION{PREFIX}}short_urls in_su 
                    WHERE is_custom = 0
                        AND sugrp_id~;
                    
                        if (defined ${$cfg}{'sugrp_id'} && ${$cfg}{'sugrp_id'} =~ /^\d+$/) {
                            $q .= ' = ' . ${$cfg}{'sugrp_id'} . '  ';
                        }
                        else {
                            $q .= ' IS NULL  ';
                        }
                        
                    $q .= qq~ )
            ;
        ~;
        
        eval {
            $sth = $dbh -> prepare($q); $sth -> execute();
            $res = $sth->fetchrow_hashref();
            $sth -> finish();
        };
        
        $alias_match = 
            (defined($res -> {'alias'}) && length $res -> {'alias'})? 
                lc($res -> {'alias'}):'0';
        
        $alias_match = &_surl_next_url_alias($alias_match);
        
        $steps = 300;#srch lower for '300' @ return{'message'}
        while ($alias_match && ($steps > 0)) {

            unless (defined $alias_match && length $alias_match) {
                $dbh -> do("UNLOCK TABLES ; ");
                return {
                    status => 'fail', 
                    message => 'next alias not found in auto mode', 
                }
            }
            
            $q = qq~
                SELECT 
                    alias_id 
                FROM ${SESSION{PREFIX}}short_urls 
                WHERE 
                    alias = ? 
                    AND sugrp_id~;
                    
            if (defined ${$cfg}{'sugrp_id'} && ${$cfg}{'sugrp_id'} =~ /^\d+$/) {
                $q .= ' = ' . ${$cfg}{'sugrp_id'} . ' ; ';
            }
            else {
                $q .= ' IS NULL ; ';
            }
        
            eval {
                $sth = $dbh -> prepare($q); $sth -> execute($alias_match);
                $res = $sth->fetchrow_hashref();
                $sth -> finish();
            };
            
            if (scalar $res->{'alias_id'}) {
                $alias_match = &_surl_next_url_alias($alias_match);
                $steps--;
                next;
            }
            else {
                ${$cfg}{'alias'} = $alias_match;
                $alias_match = 0;
                last;
            }
            
        }
        
        unless ($steps) {
            $dbh -> do("UNLOCK TABLES ; ");
            return {
                status => 'fail', 
                message => '300 tryes, but still not found next alias automatically', 
            }
        }
        
        $is_custom = 0;
    }
    
    $q = qq~
        INSERT INTO 
        ${SESSION{PREFIX}}short_urls (
            sugrp_id, is_custom, alias, 
            sha1_sum, orig_url, 
            member_id, ins
        ) VALUES (
            ~ . ($dbh->quote(${$cfg}{'sugrp_id'})) . qq~, 
            ~ . ($dbh->quote($is_custom)) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'alias'})) . qq~, 
            ~ . ($dbh->quote($sha1_sum)) . qq~, 
            ~ . ($dbh->quote(${$cfg}{'original_url'})) . qq~, 
            ~ . ($dbh->quote($SESSION{'USR'}->{'member_id'})) . qq~, 
            NOW() 
        ) ; 
    ~;
    eval {
        $inscnt = $dbh->do($q);
    };
    
    unless (scalar $inscnt) {
        $dbh -> do("UNLOCK TABLES ; ");
        return {
            status => 'fail', 
            message => 'sql ins into short_url_groups entry fail', 
        }
    }

    $q = qq~ SELECT LAST_INSERT_ID() AS lid; ~;
    eval {
        ($alias_id) = $dbh -> selectrow_array($q);
    };

    $dbh -> do("UNLOCK TABLES ; ");
    return {
        status => 'ok', 
        alias => ${$cfg}{'alias'}, 
        sugrp_id => $alias_id, 
        message => 'All ok', 
    };
    
} #-- surl_url_add

1;
