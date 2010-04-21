package MjNCMS::Date;
#
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#

#
# Professor: Good news, everyone. 
#   Tomorrow, you'll all be making a delivery to Ebola 9, the virus planet.
# Hermes: Why can't they go today?
# Professor: Because tonight's a special night 
#   and I want you all to be alive. 
#   It's the Academy of Inventors annual symposium. 
#
# Fry: Wow, you guys have every kind of meat here except human.
# Neptunian Vendor: What? You want human? 
#
# (c) Futurama
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use base 'Mojo::Base';
use Date::Format qw/time2str /;
use Date::Calc qw/ /;

require Time::Local;
require Time::Piece;

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

__PACKAGE__->attr('epoch');

sub new {
  my $self = {}; shift;
  
  bless $self;
  $self->epoch(time);
  return $self
}


sub fparse_lame {
   #parse with simple format mostly like Date::Calc, mysql, etc. Not complete (no abbriveatures keys)
   my ($self, $date, $fmt) = @_;

    return $self unless (
                defined $date &&
                defined $fmt &&
                length $fmt
        );

    my (
        $day, $month, $year, 
        $hour, $minute, $second, 
        $prechar, $currchar, $am_pm, 
        $epoch, 
    );
    
    $prechar = '';
    while($fmt=~/(.)/g){
        $currchar = $1;
        if($prechar.$currchar eq '%d' && $date =~ /^(\d{1,2})/){
            $day = $1;
            $date =~ s/^$day//;
            $day = int($day);
            return $self unless ($day<=31);
        }
        elsif($prechar.$currchar eq '%H' && $date =~ /^(\d{2})/){
            $hour = $1;
            $date =~ s/^$hour//;
            $hour = int($hour);
            return $self unless ($hour<=24);
        }
        elsif($prechar.$currchar eq '%I' && $date =~ /^(\d{2})/){
            $hour = $1;
            $date =~ s/^$hour//;
            $hour = int($hour);
            return $self unless ($hour<=12);
        }
        elsif($prechar.$currchar eq '%k' && $date =~ /^(\d{1,2})/){
            $hour = $1;
            $date =~ s/^$hour//;
            return $self unless ($hour<=24);
        }
        elsif($prechar.$currchar eq '%l' && $date =~ /^(\d{1,2})/){
            $hour = $1;
            $date =~ s/^$hour//;
            return $self unless ($hour<=12);
        }
        elsif($prechar.$currchar eq '%m' && $date =~ /^(\d{2})/){
            $month = $1;
            $date =~ s/^$month//;
            return $self unless ($month<=12);
        }
        elsif($prechar.$currchar eq '%L' && $date =~ /^(\d{1,2})/){
            $month = $1;
            $date =~ s/^$month//;
            $date = int($date);
            return $self unless ($month<=12);
        }
        elsif($prechar.$currchar eq '%M' && $date =~ /^(\d{1,2})/){
            $minute = $1;
            $date =~ s/^$minute//;
            $minute = int($minute);
            return $self unless ($minute<=59);
        }
        elsif(
            ($prechar.$currchar eq '%P' || $prechar.$currchar eq '%p') &&
            $date =~ /^(\w{2})/ 
        ){
            $am_pm = $1;
            $date =~ s/^$am_pm//;
            $am_pm = lc($am_pm);
            return $self if ($am_pm ne 'am' && $am_pm ne 'pm');
        }
        elsif($prechar.$currchar eq '%S' && $date =~ /^(\d{1,2})/){
            $second = $1;
            $date =~ s/^$second//;
            $second = int($second);
            return $self unless ($second<=59);
        }
        elsif($prechar.$currchar eq '%y' && $date =~ /^(\d{1,2})/){
            $year = $1;
            $date =~ s/^$year//;
            $year = int($year);
            if($year<=(${[gmtime time]}[5]-95)){#-100+5yrs @future
                $year = 2000+$year;
            }
            else{
                $year = 1900+$year;
            }
            return $self unless ($year);
        }
        elsif($prechar.$currchar eq '%Y' && $date =~ /^(\d{4})/){
            $year = $1;
            $date =~ s/^$year//;
            $year = int($year);
            return $self unless ($year);
        }
        elsif($prechar.$currchar eq '%s' && $date =~ /^(\d{,10})/){
            $second = $1;
            $date =~ s/^$second//;
            $second = int($second);
            ($second, $minute, $hour, $day, $month, $year) = gmtime $second;
            return $self unless ($year);
        }
        elsif($prechar.$currchar eq '%%'){
            $date =~ s/^%//;
        }
        elsif($currchar ne '%'){
            $date =~ s/^%?$currchar//;
        }
        
        $prechar = $currchar;
        #part of format
        next if $currchar eq '%';
        #trash
        $currchar = '\.' if $currchar eq '.';
        $currchar = '\?' if $currchar eq '?';
        $currchar = '\*' if $currchar eq '*';
        
        if($date =~ /^$currchar/){
            $date =~ s/^$currchar//;
        }
    }
    
    $second = 0 unless $second;
    if ($am_pm && $am_pm eq 'pm' && $hour<=12){
        $hour*=2;
    }
    
    # Prevent crash
    eval {
        $epoch =
          Time::Local::timegm($second, $minute, $hour, $day, $month, $year);
    };

    return $self if $@ || $epoch < 0;

    $self->epoch($epoch);

    return $self;

}


sub fparse {
   my ($self, $fmt, $date) = @_;

    return undef unless (
                defined $date 
    );
    
    $fmt = $SESSION{'LOC'}->get_dt_fmt() unless $fmt;

    my $t;
    eval{
        $t = Time::Piece->strptime($date, $fmt);
    };

    return undef if (!$t || $t->epoch() !~ /^(\-)?\d+$/);
    #With user time offset, from hrs to secs
    $self->epoch($t->epoch() - ($SESSION{'USR'}->{'profile'}->{'time_offset'} * 60 * 60));

    return $self->epoch();
}
sub fparse_d_m_y ($$$$) {
   my ($self, $d, $m, $y) = @_;

    return undef unless (
                defined $d &&
                $d =~ /^\d+$/ &&
                defined $m &&
                $m =~ /^\d+$/ &&
                defined $y &&
                $y =~ /^\d+$/ 
    );
    
    return Time::Local::timegm(0, 0, 0, $d, $m, $y);
}

sub fparse_y_m_d ($$$$) {
    my ($self, $y, $m, $d) = @_;
    return &fparse_d_m_y($self, $d,$m,$y);
}

sub fparse_m_d_y ($$$$) {
    my ($self, $m, $d, $y) = @_;
    return &fparse_d_m_y($self, $d,$m,$y);
}

sub to_fstring ($$;$) {
    my ($self, $fmt, $date) = @_;
    return $self unless defined $fmt;
    
    if (ref $fmt && ref $fmt eq 'ARRAY'){
        $fmt = join ' ', @{$fmt};
    }
    
    $date = $self->epoch() unless $date;
    return time2str($fmt, $date);
}

sub get_epoch ($) {
    my $self  = shift;
    return $self->epoch();
}

sub set_epoch ($$) {
    my $self  = shift; 
    my $epoch = shift;
    return undef if $epoch !~ /^\d+$/;
    $self->epoch($epoch); 
    return 1;
}

sub rest_epoch ($) {
    my $self  = shift; 
    $self->epoch(time);
    return $self->epoch();
}

sub date_sql ($;$) {
    my ($self, $date) = @_;
    
    $date = $self->epoch() unless $date;

    #for sql caching - no CURRENT_DATE()
    return " DATE('" . time2str('%Y-%m-%d', $date) . "') ";
} #-- date_sql

sub datetime_sql () {
    my ($self, $date) = @_;
    
    $date = $self->epoch() unless $date;
    
    #for sql caching && get_inserted items by lock && insert date - no NOW()
    return q~ TIMESTAMP('~ . time2str('%Y-%m-%d %H:%M:%S', $date) . q~') ~;
} #-- datetime_sql

sub get_by_fmt () {
    my ($self, $fmt, $date) = @_;
    
    $date = $self->epoch() unless $date;
    
    return undef unless $fmt;
    
    return time2str($fmt, $date);
}

sub strptime_and_sql () {
    #reformat date between sql, strptime anf JS, not finished
    my ($self, ) = @_;
    
    my @sql_entrys = (
        '%a',   #Abbreviated weekday name (Sun..Sat)
        '%b',   #Abbreviated month name (Jan..Dec)
        '%c',   #Month, numeric (0..12)
        '%D',   #Day of the month with English suffix (0th, 1st, 2nd, 3rd, …)
        '%d',   #Day of the month, numeric (00..31)
        '%e',   #Day of the month, numeric (0..31)
        '%f',   #Microseconds (000000..999999)
        '%H',   #Hour (00..23)
        '%h',   #Hour (01..12)
        '%I',   #Hour (01..12)
        '%i',   #Minutes, numeric (00..59)
        '%j',   #Day of year (001..366)
        '%k',   #Hour (0..23)
        '%l',   #Hour (1..12)
        '%M',   #Month name (January..December)
        '%m',   #Month, numeric (00..12)
        '%p',   #AM or PM
        '%p',   #AM or PM
        '%r',   #Time, 12-hour (hh:mm:ss followed by AM or PM)
        '%S',   #Seconds (00..59)
        '%s',   #Seconds (00..59)
        '%T',   #Time, 24-hour (hh:mm:ss)
        '%U',   #Week (00..53), where Sunday is the first day of the week
        '%u',   #Week (00..53), where Monday is the first day of the week
        '%V',   #Week (01..53), where Sunday is the first day of the week; used with '%X
        '%v',   #Week (01..53), where Monday is the first day of the week; used with '%x
        '%W',   #Weekday name (Sunday..Saturday)
        '%w',   #Day of the week (0=Sunday..6=Saturday)
        '%w',   #Day of the week (0=Sunday..6=Saturday) #!make +1 here
        '%X',   #Year for the week where Sunday is the first day of the week, numeric, four digits; used with '%V #! +1day here
        '%x',   #Year for the week, where Monday is the first day of the week, numeric, four digits; used with '%v
        '%Y',   #Year, numeric, four digits
        '%y',   #Year, numeric (two digits)
        '%%',   #A literal “'%” character
        '%x',   #x, for any “x” not listed above
    );
    my @strptime_entrys = (
        '%a', #abbreviated weekday name
        '%b', #abbreviated month name
        '%m', #month (01 to 12)
        undef, 
        '%d', #day of the month (01 to 31)
        '%e', #day of the month (1 to 31)
        undef, 
        '%H', #hour, using a 24-hour clock (00 to 23) #'%R', #time in 24 hour notation ?
        '%I', #hour, using a 12-hour clock (01 to 12)
        '%I', #hour, using a 12-hour clock (01 to 12)
        '%M', #minute
        '%j', #day of the year (001 to 366)
        '%H', #hour, using a 24-hour clock (00 to 23)
        '%I', #hour, using a 12-hour clock (01 to 12)
        '%B', #full month name
        '%m', #month (01 to 12)
        '%p', #either am or pm according to the given time value #'%r', #time in a.m. and p.m. notation 
        '%p', #either am or pm according to the given time value
        '%T', #time format: 21:05:57 #'%X', #time format: 21:05:57 ?
        '%S', #second
        '%S', #second
        '%T', #current time, equal to %H:%M:%S
        '%U', #week number of the current year, starting with the first Sunday as the first day of the first week
        '%W', #week number of the current year, starting with the first Monday as the first day of the first week
        undef,
        undef, 
        '%A', #full weekday name
        '%w', #day of the week as a decimal, Sunday=0 
        '%u', #weekday as a number (1 to 7), Monday=1. Warning: In Sun Solaris Sunday=1 #! -1 here!
        '%V', #The ISO 8601 week number of the current year (01 to 53), where week 1 is the first week that has at least 4 days in the current year, and with Monday as the first day of the week #! -1day here [sunday]
        '%V', #The ISO 8601 week number of the current year (01 to 53), where week 1 is the first week that has at least 4 days in the current year, and with Monday as the first day of the week
        '%Y', #year including the century #'%G', #4-digit year corresponding to the ISO week number (see %V).
        '%y', #year without a century (range 00 to 99)
        '%%', #a literal % character
        undef, 
        
    );
    
    my @js_entrys = (
        #Format      Description     Example
        's',    #The seconds of the minute between 0-59.    "0" to "59"
        'ss',   #The seconds of the minute with leading zero if required.   "00" to "59"
        'm',    #The minute of the hour between 0-59.   "0" or "59"
        'mm',   #The minute of the hour with leading zero if required.  "00" or "59"
        'h',    #The hour of the day between 1-12.  "1" to "12"
        'hh',   #The hour of the day with leading zero if required.     "01" to "12"
        'H',    #The hour of the day between 0-23.  "0" to "23"
        'HH',   #The hour of the day with leading zero if required.     "00" to "23"
        'd',    #The day of the month between 1 and 31.     "1" to "31"
        'dd',   #The day of the month with leading zero if required.    "01" to "31"
        'ddd ', #Abbreviated day name. Date.CultureInfo.abbreviatedDayNames.    "Mon" to "Sun"
        'dddd', #The full day name. Date.CultureInfo.dayNames.  "Monday" to "Sunday"
        'M',    #The month of the year between 1-12.    "1" to "12"
        'MM',   #The month of the year with leading zero if required.   "01" to "12"
        'MMM ', #Abbreviated month name. Date.CultureInfo.abbreviatedMonthNames.    "Jan" to "Dec"
        'MMMM', #The full month name. Date.CultureInfo.monthNames.  "January" to "December"
        'yy',   #Displays the year as a two-digit number.   "99" or "07"
        'yyyy', #Displays the full four digit year.     "1999" or "2007"
        't',    #Displays the first character of the A.M./P.M. designator. Date.CultureInfo.amDesignator or Date.CultureInfo.pmDesignator   "A" or "P"
        'tt',   #Displays the A.M./P.M. designator. Date.CultureInfo.amDesignator or Date.CultureInfo.pmDesignator  "AM" or "PM"
        'S',    #The ordinal suffix ("st, "nd", "rd" or "th") of the current day.   "st, "nd", "rd" or "th"

        #Custom Date and Time Format Specifiers

        #Format     Description     Example
        'd',    #The CultureInfo shortDate Format Pattern   "M/d/yyyy"
        'D',    #The CultureInfo longDate Format Pattern    "dddd, MMMM dd, yyyy"
        'F',    #The CultureInfo fullDateTime Format Pattern    "dddd, MMMM dd, yyyy h:mm:ss tt"
        'm',    #The CultureInfo monthDay Format Pattern    "MMMM dd"
        'r',    #The CultureInfo rfc1123 Format Pattern     "ddd, dd MMM yyyy HH:mm:ss GMT"
        's',    #The CultureInfo sortableDateTime Format Pattern    "yyyy-MM-ddTHH:mm:ss"
        't',    #The CultureInfo shortTime Format Pattern   "h:mm tt"
        'T',    #The CultureInfo longTime Format Pattern    "h:mm:ss tt"
        'u',    #The CultureInfo universalSortableDateTime Format Pattern   "yyyy-MM-dd HH:mm:ssZ"
        'y',    #The CultureInfo yearMonth Format Pattern   "MMMM, yyyy"

        #Separator Characters

        #Character  Name
        '/',    #forward slash
        ' ',    #space
        '.',    #period|dot
        '-',    #hyphen|dash
        ',',    #comma 
    );
    
    
    return undef;
} #-- strptime_and_sql

1;
