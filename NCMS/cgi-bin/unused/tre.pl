use Mojo::URL;

$a = 's_sssds';
if($a =~ /^[0-9A-Za-z]+$/){
	print "111\n";
}
else{
	print "2222\n";
}



=pod
print "\n\n\n\n\n";

    my $url = Mojo::URL->new(
        'http://sri:foobar@kraih.com:3000/foo/bar?foo=bar#23'
    );

print $url->scheme;
print "\n";
=cut
