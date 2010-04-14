package MjNCMS::Template::Filter::jsquot;
# (c) Boris Bondarchik, bbon@mail.ru, 2010

BEGIN {
  use common::sense;
  use Template::Plugin::Filter;
  use base qw(Template::Plugin::Filter);
  use FindBin;
  use lib "$FindBin::Bin/../../..";
}

sub filter {
  my ($self, $text) = @_;
  $text =~ s/\'/\\\'/g;
  return $text;
} 

1;
