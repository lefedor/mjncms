#!/usr/bin/env perl
use Mojo::Path;

#example @ladder sub: $self->redirect_to('/_static/msg/no_auth.shtml'.'?state='. ($SESSION{'USR'} -> {'last_state'}));
my $path = Mojo::Path->new('/redirect/to.html?state=smth');
print "path is \"$path\"\n";#path is "/redirect/to.html%3Fstate=smth"
