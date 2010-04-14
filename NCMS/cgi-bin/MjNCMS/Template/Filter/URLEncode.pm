package MjNCMS::Template::Filter::URLEncode;
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
  $text =~ s/([\x00-\x19"=\+\&#%;:\/<>\?{}|\\\\^~`\[\]\x7F-\xFF])/sprintf('%%%02X',ord($1))/eg;
  $text =~ s/\x20/+/g;
  return $text;
} 

1;
