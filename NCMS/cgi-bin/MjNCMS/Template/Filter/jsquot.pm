package MjNCMS::Template::Filter::jsquot;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
# (c) Boris R Bondarchik, bbon@mail.ru, 2010

BEGIN {
  use common::sense;
  use Template::Plugin::Filter;
  use base qw(Template::Plugin::Filter);
  use FindBin;
  use lib "$FindBin::Bin/../../..";
}

our $VERSION = 1.00;

sub new {
    my ($class, $context, $format) = @_;;
    $context->define_filter('jsquot', [ \&jsquot_filter_factory => 1 ]);
    return \&jsquot;
}

sub filter {
  my ($self, $text) = @_;
  $text =~ s/\'/\\\'/g;
  return $text;
} 

sub jsquot {
  #my ($self, $text) = @_;
  my $text = shift;
  $text =~ s/\'/\\\'/g;
  return $text;
}

sub jsquot_filter_factory {
    my ($context, @args) = @_;
    return sub {
        my $text = shift;
        return jsquot($text, @args);
    }
}

1;
