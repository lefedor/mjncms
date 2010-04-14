#!/usr/bin/perl

use Storable;

%table = (a=>'bbb', c=>{dd=>[1, 'e', 'b'], zz=>'yarr'});
 
$stor = Storable::freeze(\%table);


print $stor;
