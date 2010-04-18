package MjNCMS::Template::Filter::loc;
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
    $context->define_filter('loc', [ \&loc_filter_factory => 1 ]);
    return \&tt_loc;
}

sub filter {
    my ($selft, $text, $enc) = @_;
    return $SESSION{'LOC'}->loc($text, $enc);
}

sub tt_loc {
    my $text  = shift;
    my $enc  = shift;
    return $SESSION{'LOC'}->loc($text, $enc);
}

sub loc_filter_factory {
    my ($context, @args) = @_;
    return sub {
        my $text = shift;
        return tt_loc($text, @args);
    }
}

1;
