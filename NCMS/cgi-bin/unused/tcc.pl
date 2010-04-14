$cookielength = 'aa';
$cookielength = -1 unless $cookielength =~ m/^\-{0,1}\d+$/;

print $cookielength;
