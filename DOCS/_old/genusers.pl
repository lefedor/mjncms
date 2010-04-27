#! /usr/bin/perl -w
use strict;

use Digest::SHA1 qw(sha1_hex);

my $pref = 'mjsmf_';

my %users = (
    austin => 'powers',

);

for (keys %users) {
  my $login = $_;
  my $pass = $users{$login};
  #print $login, ' ', sha1_hex(lc($login) . $pass), "\n";
  print "UPDATE ${pref}members SET passwd='".sha1_hex(lc($login) . $pass)."' WHERE membername='$login' LIMIT 1 ; \n "
}

exit;
__DATA__
