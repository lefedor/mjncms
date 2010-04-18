package MjNCMS::Service;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
# (c) Boris R Bondarchik, bbon@mail.ru, 2010
#

#
# Dr. Zoidberg: WO Wooo WooowOOoOo
# (c) Futurama
#

use common::sense;

use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;

use Mojo::ByteStream;
use Mojo::URL;
use Mojo::Loader;

use Encode qw/from_to /;#simple 'between charsets' encoder
use Crypt::Tea;#Tiny encription module, support client-side js decoding
use Date::Format qw/time2str /;
use DBI;
use POSIX qw /ceil /;

#for testing or reverce engeneering - like look inside M::Controller, etc
#sub t_of, could be commented, enable 1/0 over Config
use Data::Dumper;

BEGIN {
    use Exporter ();
    use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS /;
    @ISA         = qw/Exporter /;
    @EXPORT      = qw/ /;
    @EXPORT_OK   = qw/ /;
    
    %EXPORT_TAGS = (
      vars => [qw/ /],
      subs => [qw/
        from_to get_dbh trim inarray 
        sv_date2sql sv_date_sql sv_datetime_sql 
        sv_getips sv_sort_jscss sv_crypt sv_decrypt 
        sv_get_ctrlsum sv_chk_ctrlsum sv_dbh_quote_params 
        get_suffixed_params 
        t_of sv_cutpages sv_render_xml 
        sv_register_tt_call 
        
    /],
    );
    Exporter::export_ok_tags('vars');
    Exporter::export_ok_tags('subs');
    $SESSION{'BS'} = sub { Mojo::ByteStream->new(@_) };
    
}

sub get_dbh ($$$$$;$) {
    my ($host, $port, $database, $user, $pass, $enc) = @_;
    my $dbh;
    
    eval{
        $dbh = DBI->connect('DBI:mysql:' . $database . ':' . $host . ':' . $port, 
            $user, $pass, {
                RaiseError => 1, 
                PrintError => 1, 
                mysql_enable_utf8 => ($enc && $enc eq 'utf8')? 1:0
            }
        );
    };
    
    return $dbh || undef;
} #-- get_dbh


sub trim () {
    my @out = @_;
    for (@out) {
      s/^\s+//;
      s/\s+$//;
    }
    return wantarray ? @out : $out[0];
} #-- trim

sub inarray ($$;$$) {
  #Inarray - check if value or some of [@values] exist in [@array]
  #return position from "1" (0 is false/not found)
  #!!! FROM "1"         ^^^
  my @arr = @{$_[0]};
  my $el = $_[1];
  my $caseignore = $_[2];
  my $trimvals = $_[3];
  my ($i, $j, @els);

      if(ref $el && ref $el eq 'SCALAR'){
           push @els, ${$el};
      }
      elsif(ref $el && ref $el eq 'ARRAY'){
           @els = @{$el};
      }
      elsif(ref $el){
          return 0;
      }
      else{
          push @els, $el;
      }

      if($caseignore){
        for($i=0; $i<@els; $i++) {
            $els[$i]=lc $els[$i] if $els[$i];
        }
      }
      
      if($trimvals){
        for(my $i=0; $i<@arr; $i++) {
            $arr[$i]=~s/^\s+|\s+$// if $arr[$i];
        }
      }
  
  unless($caseignore){
      foreach $el (@els){
        for(my $i=0; $i<@arr; $i++) {
            if(defined($arr[$i]) && $arr[$i] eq $el) {return $i+1;}
        }
      }
  }
  else{
      foreach $el (@els){
        for(my $i=0; $i<@arr; $i++) {
            if(defined($arr[$i]) && (lc $arr[$i]) eq $el) {return $i+1;}
        }
      }
  }
        
  return 0;
}; #-- sub inarray

sub sv_date2sql ($) {
    #date > sql date auto parser
    my $date=$_[0];
    if(defined($date) && length($date)){
        $date =~ s/^'(.+?)'$/$1/;
        if ($date =~ m/^\d{4}\D\d{1,2}\D\d{1,2}$/){
            $date =~ s/^(\d{4})\D(\d{1,2})\D(\d{1,2})$/$1.'-'.sprintf("%02u", $2).'-'.sprintf("%02u", $3)/e;
            $date = qq~DATE('$date')~;
        }
        elsif ($date =~ m/^\d{1,2}\D\d{1,2}\D\d{4}$/){
            $date =~ s/^(\d{1,2})\D(\d{1,2})\D(\d{4})$/$3.'-'.sprintf("%02u", $2).'-'.sprintf("%02u", $1)/e;
            $date = qq~DATE('$date')~;
        }
        elsif ($date =~ m/^\d{8}$/){
            $date =~ s/^(\d{4})(\d{2})(\d{2})$/$1.'-'.$2.'-'.$3/e;
            $date = qq~DATE('$date')~;
        }
        elsif ($date =~ m/^\d{14}$/){
            #pass
        }
        elsif ($date =~ m/^\d{4}\D\d{1,2}\D\d{1,2}.+?\d{1,2}\D\d{1,2}\D\d{1,2}$/){
            $date =~ s/^(\d{1,2})\D(\d{1,2})\D(\d{4}).+?(\d{1,2})\D(\d{1,2})\D(\d{1,2})$/$3.'-'.sprintf("%02u", $2).'-'.sprintf("%02u", $1).' '.sprintf("%02u", $4).':'.sprintf("%02u", $5).':'.sprintf("%02u", $6)/e;
            $date = qq~DATE('$date')~;
        }
        else{
            #warn '*** wrong_indate';
            return 'NULL';
        }
    }
    else{
        return 'NULL';
    }
} #-- sv_date2sql

sub sv_date_sql () {
    #for sql caching - no CURRENT_DATE()
    return " DATE('" . time2str('%Y-%m-%d', time) . "') ";
} #-- sv_date_sql

sub sv_datetime_sql () {
    #for sql caching && get_inserted items by lock && insert date - no NOW()
    return q~ TIMESTAMP('~ . time2str('%Y-%m-%d %H:%M:%S', time) . q~') ~;
} #-- sv_datetime_sql

sub sv_getips () {
    return {
        proxyclient => $ENV{'HTTP_X_FORWARDED_FOR'}? $ENV{'HTTP_X_FORWARDED_FOR'}:undef, #1 ip before proxy; ++ can be HTTP_X_FORWARDED, HTTP_X_FORWARDED_FOR, HTTP_FORWARDED_FOR, HTTP_FORWARDED 
        proxy => $ENV{'HTTP_CLIENT_IP'}? $ENV{'HTTP_CLIENT_IP'}:undef, #2 proxy ip if HTTP_X_FORWARDED_FOR
        #X_CLIENT_IP => $ENV{'X_CLIENT_IP'}, #dunno )
        remote => $ENV{'REMOTE_ADDR'}? $ENV{'REMOTE_ADDR'}:undef, #3 server reply to - ip
        #HTTP_VIA => $ENV{'HTTP_VIA'}, #proxy label-name
    };
} #-- sv_getips

sub sv_sort_jscss ($) {
    #sort (file1.js55, file2.js20) consider digits @ end if they set (20 first, 55 next, no/standart - from 100)
    #css/.* are same
    my $arr_ref = $_[0];
    return @{[]} unless (ref $arr_ref && ref $arr_ref eq 'ARRAY');
    
    my(@sortedarray, %index, %filepaths, $path, $weight);
    my $sequencecounter = 0;
    foreach my $infile (@{$arr_ref}) {
        ($path, $weight) = $infile =~ m~^(.+?)(\d+)?$~;
        $weight = 100+$sequencecounter unless $weight;
        $filepaths{$sequencecounter} = $path;
        $index{$sequencecounter} = scalar($weight);
        $sequencecounter++;
    }

    if($sequencecounter){
        foreach my $seq_key(sort {$index{$a} <=> $index{$b}} keys %index){
            unless(&inarray(\@sortedarray, \$filepaths{$seq_key})){
                push @sortedarray, $filepaths{$seq_key};
            }
        }
        return @sortedarray;
    }
    return @{[]};
} #-- sv_sort_jscss


sub sv_crypt ($;$) {
    my $str = $_[0];
    my $key = $_[1]? $_[1] : $SESSION{'CRYPT_KEY'};
    return undef unless ($str && length($str));
    return $str = Crypt::Tea::encrypt($str, $key);
} #-- sv_crypt


sub sv_decrypt ($;$) {
    my $str = $_[0];
    my $key = $_[1]? $_[1] : $SESSION{'CRYPT_KEY'};
    return undef unless ($str && length($str));
    return $str = Crypt::Tea::decrypt($str, $key);
} #-- sv_decrypt


sub sv_get_ctrlsum ($) {
    my $str = $_[0]? &trim($_[0]) : undef;
    #this should be same @ chk_ctrlsum && get_ctrlsum
    my $sum = b($str.$SESSION{'MD_CHK_KEY'}.$str.length($str))->md5_sum;
    return $sum;
} #-- sv_get_ctrlsum

sub sv_chk_ctrlsum ($$) {
    my $str = $_[0]? &trim($_[0]) : undef;
    my $chk_sum = $_[1]? $_[1] : undef;
    #this should be same @ chk_ctrlsum && get_ctrlsum
    my $sum = b($str.$SESSION{'MD_CHK_KEY'}.$str.length($str))->md5_sum;
    return ($sum eq $chk_sum)? 1:0;
} #-- sv_chk_ctrlsum


sub sv_dbh_quote_params ($$) {
  my %data_hash = ($_[0] &&
    ref $_[0] && $_[0] eq 'HASH')? %{$_[0]}: undef;
  my @values = ($_[1] &&
    ref $_[1] && $_[1] eq 'ARRAY')? @{$_[1]}: undef;
  return undef unless scalar @values;
  
  my $str;
  @values = map {
    if(%data_hash){
        $str = defined $_ ? &trim($data_hash{$_}) : "";
    }
    else{
        $str = defined $_ ? &trim($SESSION{'REQ'} -> param($_)) : "";
    }
    length $str ? $SESSION{'DBH'} -> quote($str) : 'NULL'
  } @values;
  return @values;
} #-- dbh_quote_params

sub get_suffixed_params ($;$) {
    my $param_base = $_[0];
    my $template = $_[1] || '\d';
    my $quote = $_[2];
    my (%res, $p_i, $p_val);

    return %res unless length $param_base;

    my $pargs = '&'.$SESSION{'REQ'}->params();
    while($pargs =~ m/\&$param_base([$template]+)/g){
        $p_val = &trim(scalar $SESSION{'REQ'}->param($param_base.$1));
        $res{$1} = (length $p_val)? ($quote? ($SESSION{'DBH'}->quote($p_val)):$p_val) : undef;
    }
    return %res;
}; #-- sub get_suffixed_params

sub t_of () {
    #$SESSION{'ALLOW_T_OF'} = 1 unless $SESSION{'ALLOW_T_OF'};
    #$SESSION{'ALLOW_T_OF'} = 'alredy';
    if($SESSION{'ALLOW_T_OF'}){
        #for low level test immediatly
        if($SESSION{'ALLOW_T_OF'} eq 'alredy'){
            open TF, ">>test_of";
        }
        else {
            open TF, ">test_of";
            $SESSION{'ALLOW_T_OF'} = 'alredy';
        }
        print TF Dumper(@_);
        #print TF "\n";
        #print TF @_;
        print TF "\n\n";
        close TF;
    }
    return 1;
}; #-- sub t_of

sub sv_cutpages ($) {
  my %input = %{$_[0]};
  my $url = $input{'-url'} || $SESSION{'CURRENT_PAGE'} || $ENV{'REQUEST_URI'};
  my $cols = $input{'-maxcols'} || $SESSION{'PAGER_MAXCOLS'} || 10;
  my $items = $input{'-items_per_page'} || $SESSION{'PAGER_ITEMSPERPAGE'} || 25;
  my $pagearg = $input{'-page_arg'} || $SESSION{'PAGER_PAGEARG'} || 'page';
  $url = Mojo::URL->new($url);
  $url->query->remove($pagearg);
  $url = $url->to_string;
  
  $input{'-size'} = 0 unless $input{'-size'};
  my $count = ceil($input{'-size'}/$items);
  my $page = $input{'-page'} || 1; $page = $count if $page > $count;
  
  my $left_margin = $page-int($cols/2);
     $left_margin = 1 if $left_margin < 1;
     
  my $right_margin = $left_margin+$cols-1;
     $right_margin = $count if $right_margin > $count;
     
  my $left_ar = $items*($page-1);  my $right_ar = $left_ar+$items-1;
  
  $right_ar = $input{'-size'} - 1 if $right_ar >= $input{'-size'};

  my %pages = (
    current => $page, count=> $count,
    url => $url, start => $left_margin, stop => $right_margin,
    left_ar => $left_ar, right_ar => $right_ar, pagearg => $pagearg, 
  );
  return %pages;
} #-- sv_cutpages

sub sv_render_xml ($$;$) {
    my $controller = $_[0];
    my $text = $_[1];
    my $ctype = $_[2] || 'text/xml; charset='.$SESSION{'SITE_CODING'};
    
    return undef if ( !$controller || !$text );
    
    $controller->tx->res->headers->header('Content-Type' => $ctype);
    $controller->render_text($text);

} #-- sv_render_xml

sub sv_register_tt_call ($$) {
    #ololo Onotole v otake
    my ($controller, $function) = @_;
    my ($e);
    
    return undef if $TT_CALLS{$function};
    
    return undef unless (
        $controller && 
        length $controller && 
        $controller =~ /^[a-z0-9_]+$/ &&
        $function && 
        length $function && 
        $function =~ /^[a-z0-9_]+$/ 
    );
    
    $controller = $SESSION{'BS'}($controller)->camelize()->to_string();
    
    if (
        $SESSION{'REG_TT_CALL_RULES'} && 
        ref $SESSION{'REG_TT_CALL_RULES'} && 
        ref $SESSION{'REG_TT_CALL_RULES'} eq 'HASH' && 
        (
            ${${${${$SESSION{'REG_TT_CALL_RULES'}}{'*'}}{'*'}}{$controller}}{$function} || 
            #${${${${$SESSION{'REG_TT_CALL_RULES'}}{'*'}}{$TT_CFG{'tt_action'}}}{$controller}}{$function} || 
            ${${${${$SESSION{'REG_TT_CALL_RULES'}}{$TT_CFG{'tt_controller'}}}{'*'}}{$controller}}{$function}  || 
            ${${${${$SESSION{'REG_TT_CALL_RULES'}}{$TT_CFG{'tt_controller'}}}{$TT_CFG{'tt_action'}}}{$controller}}{$function} 
        )
    ) {
        
        #eval "require ${ENV{'MOJO_APP'}}::${controller}";
        #if ($@) {return undef}
        
        $e = Mojo::Loader->load("${ENV{'MOJO_APP'}}::${controller}");
        return undef if $e;

        $TT_CALLS{$function} = \&{"${ENV{'MOJO_APP'}}::${controller}::${function}"};
        
        return undef;
    }
    
    return undef;
}

1;
