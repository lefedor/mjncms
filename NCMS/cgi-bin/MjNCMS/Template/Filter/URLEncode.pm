package MjNCMS::Template::Filter::URLEncode;
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
    $context->define_filter('jsquot', [ \&urlenc_filter_factory => 1 ]);
    return \&urlenc;
}

sub filter {
  my ($self, $text) = @_;
  $text =~ s/([\x00-\x19"=\+\&#%;:\/<>\?{}|\\\\^~`\[\]\x7F-\xFF])/sprintf('%%%02X',ord($1))/eg;
  $text =~ s/\x20/+/g;
  return $text;
}  

sub urlenc {
  #my ($self, $text) = @_;
  my $text = shift;
  $text =~ s/([\x00-\x19"=\+\&#%;:\/<>\?{}|\\\\^~`\[\]\x7F-\xFF])/sprintf('%%%02X',ord($1))/eg;
  $text =~ s/\x20/+/g;
  return $text;
}

sub urlenc_filter_factory {
    my ($context, @args) = @_;
    return sub {
        my $text = shift;
        return urlenc($text, @args);
    }
}

1;
