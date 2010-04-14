
$call = {controller=>'aaa', action=>'rrr'};
my $module = "${$call}{'controller'}::${$call}{'action'}";
print  $module;
