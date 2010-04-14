@a = (1 ,2,  '3', '3');

if(scalar (grep(/\D/, @a))){
	print 'fail';
}
else{print 'yep';}
print "\n";
