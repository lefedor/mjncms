package MjNCMS::Template::Filter::roundnum;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010

#This is old school LMAO mode code. should be rewritten as cute plugin :)

BEGIN {
  use common::sense;
  use Template::Plugin::Filter;
  #for argumens enable
  $Template::Plugin::Filter::DYNAMIC=1;
  use base qw(Template::Plugin::Filter);
  use FindBin;
  use lib "$FindBin::Bin/../../..";
}

#call like [% t | $roundnum{'lim'=>'4'} %]
sub filter($$$$){
  my ($self, $object, %args) = ($_[0], $_[1], %{$_[3]});
  unless ($object =~ m/^-?\d+(\D\d+)?$/) {
    warn '***not_a_digit'; return 'not_a_digit';
  }
  $object =~ s/\D/\./;
  my $lim = ($args{'lim'} && $args{'lim'} =~ m/^\d+$/)? $args{'lim'}:2;
  my $out = sprintf "%.".$lim."f", $object || 0;

  return $out;
} 

1;
