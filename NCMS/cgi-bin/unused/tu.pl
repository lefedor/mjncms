use Mojo::URL;
use Data::Dumper;

my $url = Mojo::URL->new('http://ya.ru/get/some');

$url->query->params([foo => 'bar', some => 'fuck']);
$url->query->remove('some');
$url->query->params([@{$url->query->params()}, some => 'else']);

print $url->host;

