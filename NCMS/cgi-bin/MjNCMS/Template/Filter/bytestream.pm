package MjNCMS::Template::Filter::bytestream;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010

BEGIN {
  use common::sense;
  use Template::Plugin::Filter;
  use base qw(Template::Plugin::Filter);
  use FindBin;
  use lib "$FindBin::Bin/../../..";
  use MjNCMS::Config qw/:vars/;
}

our $VERSION = 1.00;

sub new {
    my ($class, $context, $format) = @_;;
    $context->define_filter('bytestream', [ \&bs_filter_factory => 1 ]);
    return \&bs_loc;
}

sub bs_loc {
    my $text = shift;
    my $action = shift;
    my $params = shift;
    $params = [] unless $params;
    $params = [$params, ] unless (
		$params && 
		ref $params && 
		ref $params eq 'ARRAY'
	);
    
    eval {
		$text = $SESSION{'BS'}($text)->$action ( @{$params} ) -> to_string () ;
	};#do not make error if action is mistaken
	return $text;
}

sub bs_filter_factory {
    my ($context, @args) = @_;
    return sub {
        my $text = shift;
        return bs_loc($text, @args);
    }
}

1;
