#!/usr/bin/env perl
use Data::Dumper;

#dumb emu of Mojo::Parameters::param
sub param {
	my @values;
	my $wa = wantarray? 1:0;
	#print $wa."\n";
	return $wa? @values : $values[0];
}

$cfg = {
	a => ${[param()]}[0], 
	b => param(), 
	d => 'e', 
};

print Dumper($cfg);

=pod
EXPECTED OUT:
$VAR1 = {
          'a' => undef, 
          'b' => undef,
          'd' => 'e'
        };
REAL OUT:
$VAR1 = {
          'a' => 'b',
          'd' => 'e'
        };
=cut

#print scalar 'oyaebu12345';
