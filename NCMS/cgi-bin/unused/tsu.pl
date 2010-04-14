$alias = '0';
$step = 500000;

sub na ($) {
	my $alias = shift;
	
	my $maxweight = 35; 
	#up to 8**35 = 2.251.875.390.625 combo. seems enough.
	#500k record == '9orw'
	my $max_sql_field_size = 8;
	
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
	
	return undef unless (
		defined $alias && 
		length $alias && 
		$alias =~ /^\w{1,$max_sql_field_size}$/ 
	);
	
	$alias = lc($alias);
	my ($next_alias, $letter);
	
	for ($i = 1; $i <= (length $alias); $i++) {
		if($i==1){
			$letter = substr($alias, -1)
		}
		else{
			$letter = substr($alias, -($i), -($i-1));
		}
		
		if (
			$weights{$letter} == $maxweight
		) {
			next;
		}
		elsif (
			$weights{$letter} < $maxweight
		) {
			$next_alias = substr($alias , 0, ((length $alias) - $i ));
			$next_alias .= $antiweights{$weights{$letter}+1};
			$next_alias .= '0' x ($i-1) if $i > 0;
			last;
		}
		else {
			return undef;
		}
	}
	
	$next_alias = '0' x ((length $alias) + 1) unless $next_alias;
	
	return undef if (length $next_alias) > $max_sql_field_size;
	
	return $next_alias;
}

while($step){
	print $alias = &na($alias);
	#print ':'.$step."\n";
	print "\n";
	$step--;
}
