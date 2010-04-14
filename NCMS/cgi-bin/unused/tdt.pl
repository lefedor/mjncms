#use Mojo::Date;

#$d = Mojo::Date->new();
#$myd='11.03.2010 13:39';

#$d->fparse($myd, '%d.%m.%Y %H:%M');
#print $d->get_epoch();

use Date::Format qw/time2str /;
use Time::Piece;
use POSIX::strptime;
use DateTime::Format::Strptime;

$f = '%d.%m.%Y %H:%M';
$d = '17.03.2010 22:49';

#$t = Time::Piece->strptime("3rd 8 2003", "%drd %m %Y");
$t = Time::Piece->strptime($d, $f);
#print $t->epoch();
#print $t->tzoffset = 3;
print time2str('%Y-%m-%d %H:%M:%S', $t->epoch());# - 3*60*60);
print "\n";print "\n";

my $Strp = new DateTime::Format::Strptime(
                                pattern     => $f,
                                locale      => 'ru_RU.UTF-8',
                                time_zone   => 'Europe/Moscow',
                        );

print $dt = $Strp->parse_datetime($d);
print "\n";
$Strp->pattern('%s') ;
#print time2str('%Y-%m-%d %H:%M:%S', $dt);
print "\n";
print time2str('%Y-%m-%d %H:%M:%S', $Strp->format_datetime($dt));
print $Strp->errmsg;
#$e = POSIX::strptime($d, $f);
#print time2str('%Y-%m-%d %H:%M:%S', $e);

#print Time::Piece->strftime($myd, '%d.%m.%Y %H:%M');

#print time;
#require Time::Local;
#print $epoch = Time::Local::timegm(1, 0, 0, '22', '11', '1983');

