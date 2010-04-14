package MjNCMS::TestExtraCall;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010

#
# Zoidberg: Hooray, I'm helping!
#
# (c) Futurama
#

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

sub new {
  my $self = {}; shift;

  if(@_){
	$self->{'C'} = shift;#Mojolicious::Controller
  }

  bless $self;
  return $self
} #-- new

sub make_extra_run () {
	my $self = $_[0];
	my $args = $_[1]? $_[1]:undef;
	
	&t_of('kick_me');
	
	$SESSION{'EXTRARUN'} = 'YEP';
	$SESSION{'EXTRARUN_CNTRR'} = $self->{'C'};
	$SESSION{'EXTRARUN_ARG'} = $args;
	
} #-- make_extra_run

1;
